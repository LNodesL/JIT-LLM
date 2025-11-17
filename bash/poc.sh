#!/bin/bash

# Check if ollama is installed
if ! command -v ollama &> /dev/null; then
    echo "Error: ollama is not installed. Please install ollama first."
    exit 1
fi

# Check if qwen2.5-coder model is installed
if ! ollama list | grep -q "qwen2.5-coder"; then
    echo "qwen2.5-coder model not found. Pulling it now..."
    ollama pull qwen2.5-coder
    if [ $? -ne 0 ]; then
        echo "Error: Failed to pull qwen2.5-coder model"
        exit 1
    fi
fi

# Read the starting instructions
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROMPT_FILE="$SCRIPT_DIR/starting-prompt.txt"

if [ ! -f "$PROMPT_FILE" ]; then
    echo "Error: starting-prompt.txt not found at $PROMPT_FILE"
    exit 1
fi

PROMPT_CONTENT=$(cat "$PROMPT_FILE")

# Get response from ollama
RESPONSE=$(ollama run qwen2.5-coder "$PROMPT_CONTENT")

if [ $? -ne 0 ]; then
    echo "Error: Failed to get response from ollama"
    exit 1
fi

# Parse the response for ```bash {contents} ``` format
# Extract the first code block and clean it up
BASH_CODE=""

# Use awk to extract code between first ```bash or ``` and next ```
# Handle variations: ```bash, ```, or ```bash with trailing text
BASH_CODE=$(echo "$RESPONSE" | awk '
    BEGIN { in_block = 0 }
    /^```/ {
        if (in_block == 0) {
            in_block = 1
            next
        }
        if (in_block == 1) {
            exit
        }
    }
    in_block == 1 {
        print
    }
')

# If that didn't work, try extracting from shebang
if [ -z "$BASH_CODE" ]; then
    BASH_CODE=$(echo "$RESPONSE" | awk '
        /^#!/ {
            p = 1
            print
            next
        }
        p == 1 {
            if (/^```/) {
                exit
            }
            print
        }
    ')
fi

# Clean up: remove any lines that are ONLY markdown markers (with optional whitespace)
BASH_CODE=$(echo "$BASH_CODE" | sed 's/^[[:space:]]*```[[:space:]]*$//' | sed '/^$/d')

# Check if we found any code
if [ -z "$BASH_CODE" ]; then
    echo "Error: No bash code found in the response"
    echo "Response was:"
    echo "$RESPONSE"
    exit 1
fi

# Write the extracted code to a temporary file and execute it
# This is safer than eval and handles special characters better
TMP_SCRIPT=$(mktemp)
echo "$BASH_CODE" > "$TMP_SCRIPT"
chmod +x "$TMP_SCRIPT"

# Execute the extracted bash code
echo "Executing the extracted bash code:"
echo "---"
echo "$BASH_CODE"
echo "---"
echo ""

bash "$TMP_SCRIPT"
EXIT_CODE=$?

# Clean up
rm -f "$TMP_SCRIPT"

exit $EXIT_CODE

