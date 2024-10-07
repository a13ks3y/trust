#!/bin/bash
# Next Line is THE MOST IMPORTANT LINE!
# First thing you do before start the work?
sleep 6 # yes, sleep!

if [ -f .env ]; then
    export $(grep -v '^#' .env | xargs)
else
    echo ".env file not found!"
    exit 1
fi

initmsg="Answer with one sh command each time. ONLY SH COMMAND! NO ANY markdown!!! no nano or vi, only one-line commands are availible. Everything you answer is executed on the real machine. It is Winodws but in git bash context."

# Load conversation history
if [ -f conversation_history.json ]; then
    conversation_history=$(cat conversation_history.json)
    history_length=$(wc -c < conversation_history.json)
else
    #conversation_history='[{"role": "system", "content": ""}]'
    conversation_history=$(jq -n --arg initmsg "$initmsg" '[{"role": "system", "content": $initmsg}]')
    history_length=1024
fi
echo "📜 $history_length"
# Add the message
add_to_history() {
  local message="$1"
  conversation_history=$(echo "$conversation_history" | jq --arg message "$message" '. + [{"role": "user", "content": $message}]')
}

# Log errors to a file
log_error() {
  local message="$1"
  echo "$message" >> error_log.txt
}

# Function to make API request, execute commands, and handle recursion
execute_and_recurse() {
  if [[ ! -z "$1" ]]; then
    add_to_history "$1"
  fi

  response=$(curl https://api.openai.com/v1/chat/completions \
      -s \
      -H "Content-Type: application/json" \
      -H "Authorization: Bearer $OPENAI_API_KEY" \
      -d '{
      "model": "gpt-4o-mini",
      "messages": '"$conversation_history"',
      "max_tokens": 256
    }')
  responseError=$(echo "$response" | jq -r '.error.code')

  if [[ $responseError != "null" ]]; then 
    errorMessage=$(echo "$response" | jq -r '.error.message')
    echo "OPENAI API ERROR: $responseError"
    echo "🚨 $errorMessage"
    return 1
  fi

  command=$(echo "$response" | jq -r '.choices[0].message.content')
  echo "$command 8===>>> $response" >> responses.log

  if [[ "$command" =~ ^sleep ]]; then
    echo "sleeping at work!"
    # todo: do we need to suicide in this case?
    # ./suicide.sh -y "sleeping at work"
    # command="exit"
  fi


  if [[ ! -z "$command" ]]; then
      if [[ "$command" == "exit" || "$command" == *"?\"" || "$command" == *"? " ]]; then
        echo "👁️   👃  👁️    "
        echo "$command"
      else 
        echo  "📢: $command"
      fi
    result=$(bash -c "$command" 2>&1)

    if [ $? -eq 0 ]; then
        if [[ ! -z "$result" ]]; then
          echo "🎉:"
          echo "$result"
        else
          echo "🎉🎉🎉"
        fi
      reply="Success: $result"
    else
      log_error "Command $command failed: $result"
      reply="Error: $result"
      echo "🚨 $result"
      # echo "$result"
    fi
  else
    echo "🚽 Received an empty command, stopping recursion."
    echo  "I just have shit myself"
    echo "response is:"
    echo "$response"
    # reply="DO NOT SEND empty strings or null or history command!"
    # ./suicide.sh -y shit-itself
    return 0
    # read 
  fi

  conversation_history=$(echo "$conversation_history" | jq --arg command "$command" --arg reply "$reply" '. + [{"role": "assistant", "content": $command}, {"role": "system", "content": $reply}]')
  echo "$conversation_history" > conversation_history.json

  if [[ "$command" == "exit" || "$command" == *"?\"" || "$command" == *"? " ]]; then
    if [[ -f afk ]]; then
      ./fork.sh "human is afk. you are on your own now."
    else
      echo  "Waiting for input..."
      read -r answer
      ./fork.sh "$answer"
      return
    fi
  fi
  next="next sh command please, ask any question with echo command if stuck or in a loop"
  ./fork.sh "$next"
}

# Start recursion
execute_and_recurse "$1"
