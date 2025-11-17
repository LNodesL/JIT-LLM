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
# Extract content between ```bash and ```
BASH_CODE=$(echo "$RESPONSE" | sed -n '/```bash/,/```/p' | sed '1d;$d')

# If no code found, try alternative patterns
if [ -z "$BASH_CODE" ]; then
    # Try without the "bash" keyword
    BASH_CODE=$(echo "$RESPONSE" | sed -n '/```/,/```/p' | sed '1d;$d')
fi

# Check if we found any code
if [ -z "$BASH_CODE" ]; then
    echo "Error: No bash code found in the response"
    echo "Response was:"
    echo "$RESPONSE"
    exit 1
fi

# Execute the extracted bash code
echo "Executing the extracted bash code:"
echo "---"
echo "$BASH_CODE"
echo "---"
echo ""

eval "$BASH_CODE"

