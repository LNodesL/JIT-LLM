# JIT-LLM 

Just in time language models for realworld software development.

- Prompt a local LLM to generate source code

- Run new source code


JIT-LLM is a concept, and this codebase demonstrates the concept. 

JIT LLM programs do not have their own source code for their own features. They generate those on the fly, just in time for the user in runtime. JIT-LLM programs can be different, or even broken per usage. However, careful error correction and testing can be added for JIT bug fixing, to always generate a working program for the user.

As an AI model is improved, so is any JIT LLM program using that model. 

If a new model is created that is better, a proper JIT LLM program can simply swap to the newer model, improving its capabilities immediately.

JIT LLM as a concept and software development philosophy can be utilized in largescale projects or smaller widgets. It is up to the developer to use the correct LLM models, settings, and add in use-case specific error catching, prompt formats, etc. 


## Inception

You can create a starting prompt that creates a script that creates a new LLM session, so that you generate code with an LLM, and that new code fires up an LLM to generate even more code. You can technically chain this, or even set this up as a recursive loop for infinite generations, although that may freeze up a client computer. Be careful that you do not create unintentional, automated LLM loops that can run forever on your computer, generating its own code and compiling, running, and updating your system for any purpose if you give it system permissions.
