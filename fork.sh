#!/bin/bash

# OpenAI API key
OPENAI_API_KEY="$OPEN_API_KEY"

# Load previous conversation history from a file (if exists)
if [ -f conversation_history.json ]; then
    conversation_history=$(cat conversation_history.json)
else
    # Start with a system prompt if no previous history
    conversation_history='[{"role": "system", "content": "You answer with one sh command each time. ONLY SH COMMAND! NO ANY markdown!!! no nano or vi, only one-line commands are availible. Everything you answer is executed on the real machine. It is macOS."}]'
fi

# Check if the message is passed as an argument
if [ -z "$1" ]; then
  # echo "No message provided. But it is fine, yes?"
  new_message="Suggest next command"
  conversation_history=$(echo "$conversation_history" | jq --arg new_message "$new_message" '. + [{"role": "user", "content": $new_message}]')
else
  # Add the new user message to the conversation history
  new_message="$1"
  conversation_history=$(echo "$conversation_history" | jq --arg new_message "$new_message" '. + [{"role": "user", "content": $new_message}]')
fi

# Function to make the API request, execute the command, and handle the result
execute_and_recurse() {
    # Ask GPT for a shell command
    response=$(curl https://api.openai.com/v1/chat/completions \
      -H "Content-Type: application/json" \
      -H "Authorization: Bearer $OPENAI_API_KEY" \
      -d '{
      "model": "gpt-4o-mini",
      "messages": '"$conversation_history"',
      "max_tokens": 256
    }')

    # Extract the shell command from the GPT response
    command=$(echo "$response" | jq -r '.choices[0].message.content')
    # command=$(echo "$command" | sed 's/^```sh//;s/```$//')
    # echo "Response: $response"
    echo ">>> Received command: >>> $command"
        if [[ "$command" =~ ^sleep ]]; then
          ./suicide.sh -y "sleeping at work"
          command="exit"
          # command="./suicide.sh -y \"sleeping at work\""
        fi

    # Try to execute the command
    result=$(bash -c "$command" 2>&1)  # Capture both stdout and stderr

    # Check if the command was successful
    if [ $? -eq 0 ]; then
        echo "Command executed successfully: $result"
        reply="The command was successful. Result: $result answer (if it was present) is: $answer"
        if [ -z "$result" ]; then
            result="The command executed successfully, answer (if it was present) is: $answer".
        fi 
    else
        echo "Command failed: $result"
        reply="The command failed with error: $result answer (if it was present) is: $answer"
    fi

    # Add the command and reply to the conversation history
    conversation_history=$(echo "$conversation_history" | jq --arg command "$command" --arg reply "$reply" --arg result "$result"'. + [{"role": "assistant", "content": $command, "result": $result}, {"role": "assistant", "content": $reply}]')
    # conversation_history=$(echo "$conversation_history" | jq --arg command "$command" '. + [{"role": "assistant", "content": $command}]')
    conversation_history=$(echo "$conversation_history" | jq --arg result "$result" '. + [{"role": "user", "content": $result}]')

    # Save the updated conversation history
    echo "$conversation_history" > conversation_history.json

    # Delay before forking the next process (optional)
    sleep 3

    # Fork a new process to continue the conversation
    if [[ "$command" =~ .+\?\"$ ]]; then
      say "INPUT IS REQUIRED, YOU STUPID MOTHER FUCKER, FUCK"
      ./fork.sh "human is afk, try to solve the issue by yourself."
      return 0
    fi
    echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
    if [[ ! "$command" =~ ^say ]]; then
      $0
    else
      ./fork.sh "human is here, if it was an open question, it will anwer you soon, if not just try to solve taks by yourself or switch to the other task."
    fi
}
# Start the recursion
execute_and_recurse
