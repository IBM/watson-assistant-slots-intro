#!/bin/bash -x
export CONVERSATION_PASSWORD=$(echo "$CONVERSATION_SERVICE_WATSON_PIZZERIA" | jq -r '.password')
export CONVERSATION_USERNAME=$(echo "$CONVERSATION_SERVICE_WATSON_PIZZERIA" | jq -r '.username')
npm start
