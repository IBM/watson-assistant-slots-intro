[![Build Status](https://travis-ci.org/IBM/watson-conversation-slots-intro.svg?branch=master)](https://travis-ci.org/IBM/watson-conversation-slots-intro)

# Creating a Pizza ordering Chatbot using Watson Assistant Slots feature

> Watson Conversation is now Watson Assistant. Although some images in this code pattern may show the service as Watson Conversation, the steps and processes will still work.

In this Code Pattern, we will use the Watson Assistant Slots feature to
build a chatbot that takes a pizza order. The needed information such as size, type,
and ingredient choices can all be entered within one Assistant Node, unlike
with previous versions of Assistant.

When the reader has completed this Code Pattern, they will understand how to:

* Create a chatbot dialog with Watson Assistant
* Use the power of Assistant Slots to more efficiently populate data fields
* Use Assistant Slots to handle various inputs within one Node.

![](doc/source/images/architecture.png)

## Flow

1. User sends messages to the application (running locally or on IBM Cloud).
2. The application sends the user message to IBM Watson Assistant service, and displays the ongoing chat in a web page.
3. Watson Assistant uses the Slots feature to fill out the required fields for a pizza order, and sends requests for additional information back to the running application.

## Included Components

* [IBM Watson Assistant](https://www.ibm.com/watson/developercloud/conversation.html): Build, test and deploy a bot or virtual agent across mobile devices, messaging platforms, or even on a physical robot.

## Featured technologies
* [Node.js](https://nodejs.org/): An asynchronous event driven JavaScript runtime, designed to build scalable applications.

# Watch the Video

#### Running this application with Cloud Foundry on IBM Cloud

[![](http://img.youtube.com/vi/6QlAnqSiWvo/0.jpg)](https://youtu.be/6QlAnqSiWvo)

#### Running this application in a container with Kubernetes on IBM Cloud

[![](https://i.ytimg.com/vi/G-rESweRG84/0.jpg)](https://youtu.be/G-rESweRG84)

# Steps

## Deploy to IBM Cloud

[![Deploy to IBM Cloud](https://bluemix.net/deploy/button.png)](https://bluemix.net/deploy?repository=https://github.com/IBM/watson-conversation-slots-intro)

Click the ``Deploy to IBM Cloud`` button and hit ``Create`` and then jump to step 5.

**OR**

## Run in container

Run in a container on IBM Cloud, using [these instructions](doc/source/Container.md).

 **OR**

## Run locally
 Perform steps 1-5:

1. [Clone the repo](#1-clone-the-repo)
2. [Create IBM Cloud services](#2-create-ibm-cloud-services)
3. [Get IBM Cloud credentials and add to .env](#3-get-ibm-cloud-services-credentials-and-add-to-env-file)
4. [Configure Watson Assistant](#4-configure-watson-conversation)
5. [Run the application](#5-run-the-application)

### 1. Clone the repo

Clone `watson-conversation-slots-intro` locally. In a terminal, run:

  `$ git clone https://github.com/ibm/watson-conversation-slots-intro`

We’ll be using the file [`data/watson-pizzeria.json`](data/watson-pizzeria.json) to upload
the Assistant Intents, Entities, and Dialog Nodes.

### 2. Create IBM Cloud services

Create the following service and name it `wcsi-conversation-service`:

  * [**Watson Assistant**](https://console.ng.bluemix.net/catalog/services/conversation)

### 3. Get IBM Cloud service credentials and add to .env file

As you create the IBM Cloud services, you'll need to create service credentials and get the
username and password:

![](doc/source/images/WatsonCred1.png)

Move the `watson-conversation-slots-intro/env.example` file to ``/.env`` and populate the service
credentials as you create the credentials:

```
# Watson conversation
CONVERSATION_USERNAME=<add_conversation_username>
CONVERSATION_PASSWORD=<add_conversation_password>
WORKSPACE_ID=<add_conversation_workspace>
```

### 4. Configure Watson Assistant

Launch the **Watson Assistant** tool. Use the `import` icon button on the right

<p align="center">
  <img width="50%" height="50%" src="doc/source/images/import_conversation_workspace.png">
</p>

Find the local version of [`data/watson-pizzeria.json`](data/watson-pizzeria.json) and select
`Import`. Find the `Workspace ID` by clicking on the context menu of the new
workspace and select `View details`.

<p align="center">
  <img src="doc/source/images/open_conversation_menu.png">
</p>

Put this `Workspace ID` into the `.env file as ``WORKSPACE_ID``.

### 5. Run the application

#### If you used the Deploy to IBM Cloud button...

If you used ``Deploy to IBM Cloud``, the setup is automatic.

#### If you decided to run the app locally...

```
$ npm install
$ npm start
```

# Assistant Slots Discussion

The power of Slots is in how it reduces the number of nodes required to implement logic in your Watson Assistant Dialog. Here's a partial conversation Dialog using the old method:

![](doc/source/images/pizzaOldWay.png)

And here's a more complete Dialog using slots, which puts all the logic in one Node!

![](doc/source/images/pizzaNewWay.png)

Open up the Dialog, and we'll have a look:

![](doc/source/images/pizzaDialogBegin.png)

Each slot represents a field to be populated in the chatbot: ``pizza_size``, ``pizza_type``, and ``pizza_topings``.
If they are not present, the user will be prompted, starting at the top, until all are populated via
the associated variable (``$pizza_size``, ``$pizza_type``, etc).

Click on the Configure ![icon](doc/source/images/pizzaGearIcon.png) to add more functionality:

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

We start with the case where we have "pizza_topings", by detecting that the
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

# Assistant Example

Let's look at an example conversation and the associated json.
With your Watson Pizzeria running, start a dialog and begin with
telling the Pizza Bot you want a large pizza:

![](doc/source/images/pizzaEX1orderLarge.png)

The 'User Input' shows you the "input"{"text"} field, as well as come of the
"context" that is mostly used for Assistant to keep track of internal state.
Scroll Down to `Watson Understands` and look at `intents`:

![](doc/source/images/pizzaEX2WatsonUnderstandsOrderSize.png)

Note that the intent for "order" is detected. The entity "pizza_size" is now
a slot that is filled out.
We still have 2 required slots, "pizza_type" and "pizza_toppings". The user will
be prompted until these are filled out:

![](doc/source/images/pizzaEX3fillSlots.png)

We can now see that all required slots are filled:

![](doc/source/images/pizzaEX4slotsFilled.png)

What if we wanted to tell the Watson Pizzeria that we wanted to
eat the pizza there, in the restaurant? Too late! the slot for
"pizza_place" is optional, so the user won't be prompted for it, and
once the required slots are filled, we exit the "Pizza Ordering" dialog
node. The user needs to fill out optional slots first.
Type reset to start again and test this by adding the phrase "to eat there...":

![](doc/source/images/pizzaEX5eatThere.png)


# Troubleshooting

* Deploy using Cloud Foundry `cf push` gives:

``FAILED
Could not find service <Watson_service> to bind to <IBM_Cloud_application>``

If you name your service `wcsi-conversation-service`, this should work.
When you use `cf push`, it is trying to bind to the services listed in the `manifest.yml`.

So, there are 2 ways you can get this to work:

* Change the names of your IBM Cloud services to match the names in the manifest.
* Change the names in the manifest to match the names of your IBM Cloud services.

>NOTE: The `Deploy to IBM Cloud` button solves this issue by creating the services on the fly (with the correct names).


# License

[Apache 2.0](LICENSE)

# Links

* [Demo on youtube](https://youtu.be/6QlAnqSiWvo)
* [IBM Watson Assistant Docs](https://console.bluemix.net/docs/services/conversation/dialog-build.html#dialog-build)
* [Blog for IBM Watson Assistant Slots Code Pattern](https://developer.ibm.com/code/2017/09/19/managing-resources-efficiently-watson-conversation-slots/)

# Learn more

* **Artificial Intelligence Code Patterns**: Enjoyed this Code Pattern? Check out our other [AI Code Patterns](https://developer.ibm.com/code/technologies/artificial-intelligence/).
* **AI and Data Code Pattern Playlist**: Bookmark our [playlist](https://www.youtube.com/playlist?list=PLzUbsvIyrNfknNewObx5N7uGZ5FKH0Fde) with all of our Code Pattern videos
* **With Watson**: Want to take your Watson app to the next level? Looking to utilize Watson Brand assets? [Join the With Watson program](https://www.ibm.com/watson/with-watson/) to leverage exclusive brand, marketing, and tech resources to amplify and accelerate your Watson embedded commercial solution.
* **Kubernetes on IBM Cloud**: Deliver your apps with the combined the power of [Kubernetes and Docker on IBM Cloud](https://www.ibm.com/cloud-computing/bluemix/containers)

