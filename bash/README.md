# JIT LLM: Bash

The bash POC uses a starting-prompt.txt file. This POC is designed specifically to expect a bash script from the LLM. It parses ```bash {contents} ``` from the response, and then runs this new code. What the bash script actually does is irrelevant for poc.sh source code. Poc.sh only needs a valid bash script returned from the LLM model. 

poc.sh also checks if ollama is installed, and uses or downloads a specific model called 'qwen2.5-coder' 

poc.sh can use different models, or even pick a random model if you want. qwen2.5-coder was used for reliability testing, for the sake of having a longterm proof of concept on Github specifically.

