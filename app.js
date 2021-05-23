/**
 * Copyright 2015 IBM Corp. All Rights Reserved.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

'use strict';

require('dotenv').config({
  silent: true
});

var WatsonConversationSetup = require('./lib/watson-conversation-setup');
var DEFAULT_NAME = 'watson-conversation-slots-intro';
var fs = require('fs'); // file system for loading JSON
var AssistantV1 = require('ibm-watson/assistant/v1');
const { getAuthenticatorFromEnvironment } = require('ibm-watson/auth');

var express = require('express'); // app server
var bodyParser = require('body-parser'); // parser for post requests

var app = express();

// Bootstrap application settings
app.use(express.static('./public')); // load UI from public folder
app.use(bodyParser.json());

var workspaceID; // workspaceID will be set when the workspace is created or validated.

// Set to false if you want the app to not immediately fail.
// App will come up and ask user to provide proper Watson Assistant credentials.
const failOnMissingCredentials = true;

// Authentication relies on env settings
let auth;
let initError = false;
let conversation;

try {
  auth = getAuthenticatorFromEnvironment('CONVERSATION');

  conversation = new AssistantV1({
    version: '2021-04-15',
    authenticator: auth
  });

  var conversationSetup = new WatsonConversationSetup(conversation);

  // handle issue with proper syntax of json file
  // Assistant tooling for export uses 'dialog_nodes', but SDK requires 'dialogNodes'
  var workspaceJson = JSON.parse(fs.readFileSync('data/watson-pizzeria.json'));
  if ('dialog_nodes' in workspaceJson && !('dialogNodes' in workspaceJson)) {
    workspaceJson.dialogNodes = workspaceJson.dialog_nodes;
  }
  var conversationSetupParams = { default_name: DEFAULT_NAME, workspace_json: workspaceJson };
  conversationSetup.setupConversationWorkspace(conversationSetupParams, (err, data) => {
    if (err) {
      //handleSetupError(err);
      console.log('Setup Error: ' + err);
    } else {
      console.log('Assistant is ready!');
      workspaceID = data;
    }
  });
} catch (e) {
  console.log('Assistant initialization error: ' + e);
  if (failOnMissingCredentials) {
    throw(e);
  } else {
    console.log('Will continue with limited functionality');
    initError = true;
  }
}

// Endpoint to be call from the client side
app.post('/api/message', function(req, res) {

  if (initError) {
    return res.json({
      output: {
        text: 'Watson Assistant credentials are invalid. Please add/verify them and try again.'
      }
    });
  }
  else if (!workspaceID) {
    return res.json({
      output: {
        text: 'Assistant initialization in progress. Please try again.'
      }
    });
  }

  var payload = {
    workspaceId: workspaceID,
    context: req.body.context || {},
    input: req.body.input || {}
  };
  // Send the input to the conversation service
  conversation.message(payload, function(err, data) {
    if (err) {
      return res.status(err.code || 500).json(err);
    }
    return res.json(updateMessage(payload, data));
  });
});

// add health endpoint
app.get('/health', (req, res) => {
  console.log('Health Check called');
  res.send('UP');
});

/**
 * Updates the response text using the intent confidence
 * @param  {Object} input The request to the Assistant service
 * @param  {Object} response The response from the Assistant service
 * @return {Object}          The response with the updated message
 */
function updateMessage(input, response) {
  var responseText = null;
  var result = response.result;
  if (!result.output) {
    result.output = {};
  } else {
    return result;
  }
  if (result.intents && result.intents[0]) {
    var intent = result.intents[0];
    // Depending on the confidence of the response the app can return different messages.
    // The confidence will vary depending on how well the system is trained. The service will always try to assign
    // a class/intent to the input. If the confidence is low, then it suggests the service is unsure of the
    // user's intent . In these cases it is usually best to return a disambiguation message
    // ('I did not understand your intent, please rephrase your question', etc..)
    if (intent.confidence >= 0.75) {
      responseText = 'I understood your intent was ' + intent.intent;
    } else if (intent.confidence >= 0.5) {
      responseText = 'I think your intent was ' + intent.intent;
    } else {
      responseText = 'I did not understand your intent';
    }
  }
  result.output.text = responseText;
  return result;
}

module.exports = app;
