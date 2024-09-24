#!/bin/zsh

gpt() {
  if [[ ! $+commands[curl] ]]; then echo "Curl must be installed."; return 1; fi
  if [[ ! $+commands[jq] ]]; then echo "Jq must be installed."; return 1; fi
  if [[ ! -v OPENAI_API_KEY ]]; then echo "Must set OPENAI_API_KEY to your API key. Check your ~/.zshrc file"; return 1; fi

  # Define available models and set the default to the latest one
  available_models=("gpt-3.5-turbo" "gpt-4")
  default_model="gpt-4"
  model="$default_model"  # Default to the latest model
  user_input=""
  file_path=""
  output_file=""

  # Parse arguments
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --model)
        shift
        model="$1"
        if [[ ! " ${available_models[@]} " =~ " ${model} " ]]; then
          echo "Unknown model: $model. Available models: ${available_models[*]}"
          return 1
        fi
        ;;
      --input)
        shift
        user_input="$1"
        ;;
      --file)
        shift
        file_path="$1"
        if [[ ! -f "$file_path" ]]; then
          echo "File does not exist: $file_path"
          return 1
        fi
        ;;
      --output)
        shift
        output_file="$1"
        if [[ -f "$output_file" ]]; then
          # Append underscore to avoid overwriting
          output_file="${output_file%.*}_$(date +%s).${output_file##*.}"
        fi
        ;;
      *)
        user_input="$*"
        break
        ;;
    esac
    shift
  done

  # Ensure there is user input or file input
  if [[ -z "$user_input" && -z "$file_path" ]]; then
    echo "No input provided. Use --input or [command] [argument] or --file."
    return 1
  fi

  # If a file is provided, read the file contents as its own separate input
  if [[ -n "$file_path" ]]; then
    file_content=$(<"$file_path")
    user_input="Input: $user_input. File content: $file_content"
  fi

  # Function to display loading dots
  show_loading() {
    while :; do
      for s in / - \\ \|; do
        printf "\rLoading... %s" "$s"
        sleep 0.1
      done
    done
  }

  # Start loading dots in the background and disown the process to avoid showing job termination messages
  { show_loading & } 2>/dev/null
  loading_pid=$!
  disown

  # Create the JSON payload and pass it as a file to the curl request
  request_data=$(jq -n --arg model "$model" --arg input "$user_input" '{
    model: $model,
    messages: [
      {
        role: "system",
        content: "You are an in-line Zsh assistant running on Linux. Your task is to provide assistance with various kinds of user input, which may include analyzing scripts, providing examples, or helping with development-related questions. Respond accordingly based on the input, including any content from uploaded files."
      },
      {
        role: "user",
        content: $input
      }
    ]
  }')

  # Make the request to OpenAI and capture both the response and errors
  api_response=$(echo "$request_data" | curl https://api.openai.com/v1/chat/completions -s \
    -H "Content-Type: application/json" \
    -H "Authorization: Bearer $OPENAI_API_KEY" \
    -d @-)

    # Kill the loading dots process once the response is received
  kill $loading_pid 2>/dev/null
  wait $loading_pid 2>/dev/null
  printf "\r%s\r" "$(printf ' %.0s' {1..20})"  # Clear the loading message

  # Check for errors in the raw API response
  if [[ "$api_response" == "" || "$api_response" == "null" ]]; then
    echo "Error: Received an empty or null response from OpenAI API."
    echo "Full API response: $api_response"
    return 1
  fi

  # Extract the content of the response using jq
  response=$(echo "$api_response" | jq -R '.' | jq -s '.' | jq -r 'join("")' | jq -r '.choices[0].message.content')

  # Handle the case where jq fails to extract the response
  if [[ "$response" == "null" || -z "$response" ]]; then
    echo "Error: Unable to extract response from OpenAI API."
    echo "Full API response: $api_response"
    return 1
  fi

  # Output response to file if requested, otherwise print to console
  if [[ -n "$output_file" ]]; then
    echo "$response" > "$output_file"
    echo "Response saved to $output_file"
  else
    echo "$response"
  fi
}
