#!/bin/bash -x
export CONVERSATION_USERNAME=$(echo "$service_watson_conversation" | jq -r '.username')
export CONVERSATION_PASSWORD=$(echo "$service_watson_conversation" | jq -r '.password')
npm start
