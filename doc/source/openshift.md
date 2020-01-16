# Run on RedHat OpenShift

This document shows how to run the `watson-assistant-slots-intro` application in a container running on RedHat OpenShift.

## Prerequisites

You will need a running OpenShift cluster, or OKD cluster. You can provision [OpenShift on the IBM Cloud](https://cloud.ibm.com/kubernetes/catalog/openshiftcluster).

## Steps

### Create the application deployment

* In your cluster, open your project or click on `+ Create Project` to create one.
* In the `Overview` tab, click on `Browse Catalog`

![Browse Catalog](https://github.com/IBM/pattern-utils/blob/master/openshift/openshift-browse-catalog.png)

* Choose the `Node.js` app container and click `Next`.

![Choose Node.js](https://github.com/IBM/pattern-utils/blob/master/openshift/openshift-choose-nodejs.png)

* Give your app a name and add `https://github.com/IBM/watson-assistant-slots-intro` for the github repo, then click `Create`.

![Add github repo](https://github.com/IBM/pattern-utils/blob/master/openshift/openshift-add-github-repo.png)

### Configure Watson Assistant

The following instructions will depend on if you are provisioning Assistant from IBM Cloud or from an IBM Cloud Pak for Data cluster. Choose one:

<details><summary>Provision on IBM Cloud</summary>
<p>

* Find the Assistant service in your IBM Cloud Dashboard.
* Click on the `Manage` tab and then click on `Launch Watson Assistant`.
* Go to the `Skills` tab.
* Click `Create skill`
* Select the `Dialog skill` option and then click `Next`.
* Click the `Import skill` tab.
* Click `Choose JSON file`, go to your cloned repo dir, and `Open` the workspace.json file in [`data/watson-pizzeria.json`](../../data/watson-pizzeria.json).
* Select `Everything` and click `Import`.

</p>
</details>

<details><summary>Provision on IBM Cloud Pak for Data</summary>
<p>

* Find the Assistant service in your list of `Provisioned Instances` in your IBM Cloud Pak for Data Dashboard.
* Click on `View Details` from the options menu associated with your Assistant service.
* Click on `Open Watson Assistant`.
* Go to the `Skills` tab.
* Click `Create skill`
* Select the `Dialog skill` option and then click `Next`.
* Click the `Import skill` tab.
* Click `Choose JSON file`, go to your cloned repo dir, and `Open` the workspace.json file in [`data/watson-pizzeria.json`](../../data/watson-pizzeria.json).
* Select `Everything` and click `Import`.

</p>
</details>

To find the `WORKSPACE_ID` for Watson Assistant:

* Go back to the `Skills` tab.
* Find the card for the workspace you would like to use. Look for `WatsonPizzeria`.
* Click on the three dots in the upper right-hand corner of the card and select `View API Details`.
* Copy the `Workspace ID` GUID.

!["Get Workspace ID"](https://raw.githubusercontent.com/IBM/pattern-utils/master/watson-assistant/assistantPostSkillGetID.gif)

* In the next step, you will need to aadd this `Workspace ID` to your application config map.

### Create config map to store Watson Assistant credentials

* Back in the OpenShift or OKD UI, click on the `Resources` tab and choose `Config Maps` and then `Create Config Map`.

* Add a key for `WORKSPACE_ID` and the value you copied for the Workspace ID. Click `Add item` to continue.

* Add a key for `PORT` with the value `8080`.

![add config map](https://github.com/IBM/pattern-utils/blob/master/openshift/openshift-generic-config-map.png)

The remaining credentials to add will depend on if you provisioned Assistant from IBM Cloud or from an IBM Cloud Pak for Data cluster. Choose one:

<details><summary>Provision on IBM Cloud</summary>
<p>

* Retrieve the `apikey` and `url` from your Watson Assistant service credentials:

!["Assistant Credentials"](https://raw.githubusercontent.com/IBM/pattern-utils/master/watson-assistant/watson_assistant_api_key.png)

* Add keys for `CONVERSATION_IAM_APIKEY` and `CONVERSATION_URL` to store your credentials.

</p>
</details>

<details><summary>Provision on IBM Cloud Pak for Data</summary>
<p>

* Retreive the `URL` from your Watson Assistant service details panel:

!["CPD Credentials"](images/cpd-assistant-details.png)

* Add the key `CONVERSATION_URL` to store this value.

* Additionally, you will need to add the following keys and values:

  * `CONVERSATION_AUTH_TYPE` and set value to `cp4d`
  * `CONVERSATION_AUTH_URL` and set value to the URL of your IBM Cloud Pak for Data cluster
  * `CONVERSATION_AUTH_DISABLE_SSL` and set value to `true`
  * `CONVERSATION_USERNAME` and set value to the IBM Cloud Pak for Data cluser username
  * `CONVERSATION_PASSWORD` and set value to the IBM Cloud Pak for Data cluser password
  * `CONVERSATION_DISABLE_SSL` and set value to `true`

</p>
</details>

### Bind Watson Assistant service to your application

* Go to the `Applications` tab, choose `Deployments` and the `Environment` tab. Under `Environment From` `Config Map/Secret` choose the config map you just created [1]. Save the config [2]. The app will re-deploy automatically, or click `Deploy` to re-deploy manually [3]. To see the variables in the Config Map that will be exported in the app environment, click `View Details`.

![add config map to app](https://github.com/IBM/pattern-utils/blob/master/openshift/openshift-add-config-map-to-app.png)

### Run the application

* Under `Applications` -> `Routes` you will see your app. Click on the `Hostname` to see your Pizza ordering chat bot in action.

![pizza bot demo](images/pizza-bot-demo.png)

[![return](https://raw.githubusercontent.com/IBM/pattern-utils/master/deploy-buttons/return.png)](https://github.com/IBM/watson-assistant-slots-intro#deployment-options)
