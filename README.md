# Oh My GPT Zsh Plugin

Oh My GPT is a Zsh plugin that provides an easy-to-use interface for interacting with OpenAI's GPT models directly from your terminal. It allows you to send queries, analyze files, and get AI-powered assistance for various tasks.

## Features

- Interact with GPT-3.5 and GPT-4 models
- Send custom queries or file contents for analysis
- Save responses to output files
- Built-in error handling and dependency checks

## Installation

### Prerequisites

Ensure you have the following installed:

- zsh
- curl
- jq

### Using Antigen

1. If you haven't already, install [Antigen](https://github.com/zsh-users/antigen).

2. Add the following line to your `.zshrc` file:

   ```zsh
   antigen bundle vicotrbb/oh-my-gpt
   ```

3. Reload your `.zshrc` or restart your terminal:

   ```zsh
   source ~/.zshrc
   ```

### Manual Installation

1. Clone this repository:

   ```zsh
   git clone https://github.com/vicotrbb/oh-my-gpt.git ~/.oh-my-zsh/custom/plugins/oh-my-gpt
   ```

2. Add the plugin to your `.zshrc` file:

   ```zsh
   plugins=(... oh-my-gpt)
   ```

3. Reload your `.zshrc` or restart your terminal:

   ```zsh
   source ~/.zshrc
   ```

## Configuration

1. Set your OpenAI API key in your `.zshrc` file:

   ```zsh
   export OPENAI_API_KEY="your-api-key-here"
   ```

## Usage

### Basic Query

To send a basic query to the GPT model, use the following command:

```zsh
gpt "Your question or prompt here"
```

For example:

```zsh
gpt "What is the capital of France?"
```

### Using Different Models

You can specify which model to use with the `--model` flag:

```zsh
gpt --model gpt-3.5-turbo "Explain quantum computing in simple terms"
```

### Analyzing Files

To analyze the contents of a file, use the `--file` flag:

```zsh
gpt --file path/to/your/file.txt "Summarize this file"
```

### Saving Output

To save the response to a file, use the `--output` flag:

```zsh
gpt "Write a short story about AI" --output story.txt
```

### Combining Options

You can combine various options:

```zsh
gpt --model gpt-4 --file code.py "Explain this code" --output explanation.md
```

## Support

You like this project? You can always support by donating: <a href='https://buy.stripe.com/4gw14c91D8Qu09O5kk'>![image](https://img.shields.io/badge/Stripe-626CD9?style=for-the-badge&logo=Stripe&logoColor=white)</a>
