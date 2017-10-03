[![Build Status](https://travis-ci.org/IBM/watson-conversation-slots-intro.svg?branch=master)](https://travis-ci.org/IBM/watson-conversation-slots-intro)
![Bluemix Deployments](https://metrics-tracker.mybluemix.net/stats/8cbdd782337103af2cd09faf13a2481b/badge.svg)

# Creating a Pizza ordering Chatbot using Watson Conversation Slots feature

In this developer journey, we will use the Watson Conversation Slots feature to
build a chatbot that takes a pizza order. The needed information such as size, type,
and ingredient choices can all be entered within one Conversation Node, unlike
with previous versions of Conversation.

When the reader has completed this journey, they will understand how to:

* Create a chatbot dialog with Watson Conversation
* Use the power of Conversation Slots to more efficiently populate data fields
* Use Conversation Slots to handle various inputs within one Node.

![Flow](doc/source/images/slotsFlow.png)

### With Watson

Want to take your Watson app to the next level? Looking to leverage Watson Brand assets? Join the [With Watson](https://www.ibm.com/watson/with-watson) program which provides exclusive brand, marketing, and tech resources to amplify and accelerate your Watson embedded commercial solution.

## Included Components

* [IBM Watson Conversation](https://www.ibm.com/watson/developercloud/conversation.html): Build, test and deploy a bot or virtual agent across mobile devices, messaging platforms, or even on a physical robot.

## Featured technologies
* [Node.js](https://nodejs.org/): An asynchronous event driven JavaScript runtime, designed to build scalable applications.

# Watch the Video

#### Running this application with Cloud Foundry on Bluemix

[![](http://img.youtube.com/vi/6QlAnqSiWvo/0.jpg)](https://youtu.be/6QlAnqSiWvo)

#### Running this application in a container with Kubernetes on Bluemix

[![](https://i.ytimg.com/vi/G-rESweRG84/0.jpg)](https://youtu.be/G-rESweRG84)

# Steps

[![Deploy to Bluemix](https://metrics-tracker.mybluemix.net/stats/8cbdd782337103af2cd09faf13a2481b/button.svg)](https://bluemix.net/deploy?repository=https://github.com/IBM/watson-conversation-slots-intro)

Click the ``Deploy to Bluemix`` button and hit ``Create`` and then jump to step 5

**OR** 

Run in a container on Bluemix, using [these instructions](doc/source/Container.md).

 **OR** 

 Perform steps 1-5:

1. [Clone the repo](#1-clone-the-repo)
2. [Create Bluemix services](#2-create-bluemix-services)
3. [Get Bluemix credentials and add to .env](#3-get-bluemix-services-credentials-and-add-to-env-file)
4. [Configure Watson Conversation](#4-configure-watson-conversation)
5. [Run the application](#5-run-the-application)

## 1. Clone the repo

Clone `watson-conversation-slots-intro` locally. In a terminal, run:

  `$ git clone https://github.com/ibm/watson-conversation-slots-intro`

We’ll be using the file [`data/watson-pizzeria.json`](data/watson-pizzeria.json) to upload
the Conversation Intents, Entities, and Dialog Nodes.

## 2. Create Bluemix services

Create the following service and name it `wcsi-conversation-service`:

  * [**Watson Conversation**](https://console.ng.bluemix.net/catalog/services/conversation)

## 3. Get Bluemix Services Credentials and add to .env file

As you create the Blumix Services, you'll need to create service credentials and get the
username and password:

![](doc/source/images/WatsonCred1.png)

Move the watson-conversation-slots-intro/env.example file to ``/.env`` and populate the service
credentials as you create the credentials:

```
# Watson conversation
CONVERSATION_USERNAME=<add_conversation_username>
CONVERSATION_PASSWORD=<add_conversation_password>
WORKSPACE_ID=<add_conversation_workspace>
```

## 4. Configure Watson Conversation

Launch the **Watson Conversation** tool. Use the **import** icon button on the right

<p align="center">
  <img width="50%" height="50%" src="doc/source/images/import_conversation_workspace.png">
</p>

Find the local version of [`data/watson-pizzeria.json`](data/watson-pizzeria.json) and select
**Import**. Find the **Workspace ID** by clicking on the context menu of the new
workspace and select **View details**.

<p align="center">
  <img src="doc/source/images/open_conversation_menu.png">
</p>

Put this Workspace ID into the .env file as ``WORKSPACE_ID``.

## 5. Run the application

### If you used the Deploy to Bluemix button...

If you used ``Deploy to Bluemix``, the setup is automatic.

### If you decided to run the app locally...

```
$ npm install
$ npm start
```

# Conversation Slots Discussion

The power of Slots is in how it reduces the number of nodes required to implement logic in your Watson Conversation Dialog. Here's a partial conversation Dialog using the old method:

![](doc/source/images/pizzaOldWay.png)

And here's a more complete Dialog using slots, which puts all the logic in one Node!

![](doc/source/images/pizzaNewWay.png)

Open up the Dialog, and we'll have a look:

![](doc/source/images/pizzaDialogBegin.png)

Each slot represents a field to be populated in the chatbot: ``pizza_size``, ``pizza_type``, and ``pizza_topings``.
If they are not present, the user will be prompted, starting at the top, until all are populated via
the associated variable (``$pizza_size``, ``$pizza_type``, etc).

Click on the Configure ![icon](doc/source/images/pizzaGearIcon.png) to add more funtionality:

![](doc/source/images/pizzaConfig3pizza_toppingsTop.png)

Here, we can add a response for when this slot is filled (Found).
Logic can be used for one ingredient:

![](doc/source/images/pizzaConfig3Pizza_toppingsMid1ingredient.png)

or if there are greater than one ingredient added:

![](doc/source/images/pizzaConfig3Pizza_toppingsMidBotGreater1.png)

We've added logic to address yes or no answers to the question "Any extra toppings?":

![](doc/source/images/pizzaConfig3NewNotFoundconfirm.png)

Click on the 3 circles ![icon](doc/source/images/pizza3circles.png) to edit the json directly:

![](doc/source/images/pizzaConfig3NotFoundJson.png)

Here, we've set an empty value for the context: {"pizza_topings"} field, so that we can exit
the loop by filling this slot.

Finally, we add responses for once the slots are all filled:

![](doc/source/images/pizzaOrderFinish1.png)

We start with the case where we have pizza_topings, by detecting that the
array has size>0.
Here, we first handle the case where the optional "pizza_place" slot
is filled, and then handle the case where it is not.

![](doc/source/images/pizzaOrderFinish2.png)

Finally, we add handlers for the cases where the users answers to a prompt
is not found. We've handlers for the intents "help" and "reset":

![](doc/source/images/pizzaHandleHelp.png)

![](doc/source/images/pizzaHandlerReset.png)

Note that we edit the json directly when we handle the Reset. We'll
set all the fields to null in order to begin again.

# Conversation Example

Let's look at an example conversation and the associated json.
With your Watson Pizzeria running, start a dialog and begin with
telling the Pizza Bot you want a large pizza:

![](doc/source/images/pizzaEX1orderLarge.png)

The 'User Input' shows you the "input"{"text"} field, as well as come of the
"context" that is mostly used for Conversation to keep track of internal state.
Scroll Down to "Watson Understands" and look at "intents":

![](doc/source/images/pizzaEX2WatsonUnderstandsOrderSize.png)

Note that the intent for "order" is detected. The entity "pizza_size" is now
a slot that is filled out.
We still have 2 required slots, pizza_type and pizza_toppings. The user will
be prompted until these are filled out:

![](doc/source/images/pizzaEX3fillSlots.png)

We can now see that all required slots are filled:

![](doc/source/images/pizzaEX4slotsFilled.png)

What if we wanted to tell the Watson Pizzeria that we wanted to
eat the pizza there, in the restaurant? Too late! the slot for
pizza_place is optional, so the user won't be prompted for it, and
once the required slots are filled, we exit the "Pizza Ordering" dialog
node. The user needs to fill out optional slots first.
Type reset to start again and test this by adding the phrase "to eat there...":

![](doc/source/images/pizzaEX5eatThere.png)


# Troubleshooting

* Deploy using Cloud Foundry 'cf push' gives:

``FAILED
Could not find service <Watson_service> to bind to <Bluemix_application>``

If you name your service wcsi-conversation-service, this should work.
When you use `cf push`, it is trying to bind to the services listed in the manifest.yml.

So, there are 2 ways you can get this to work:

* Change the names of your Bluemix services to match the names in the manifest.
* Change the names in the manifest to match the names of your Bluemix services.

>NOTE: The 'Deploy to Bluemix' button solves this issue by creating the services on the fly (with the correct names).


# License

[Apache 2.0](LICENSE)

# Privacy Notice

If using the Deploy to Bluemix button some metrics are tracked, the following
information is sent to a [Deployment Tracker](https://github.com/IBM-Bluemix/cf-deployment-tracker-service) service
on each deployment:

* Python package version
* Python repository URL
* Application Name (application_name)
* Application GUID (application_id)
* Application instance index number (instance_index)
* Space ID (space_id)
* Application Version (application_version)
* Application URIs (application_uris)
* Labels of bound services
* Number of instances for each bound service and associated plan information

This data is collected from the setup.py file in the sample application and the ``VCAP_APPLICATION``
and ``VCAP_SERVICES`` environment variables in IBM Bluemix and other Cloud Foundry platforms. This
data is used by IBM to track metrics around deployments of sample applications to IBM Bluemix to
measure the usefulness of our examples, so that we can continuously improve the content we offer
to you. Only deployments of sample applications that include code to ping the Deployment Tracker
service will be tracked.

## Disabling Deployment Tracking

To disable tracking, simply remove ``cf_deployment_tracker.track()`` from the
``run.py`` file in the top level directory.

