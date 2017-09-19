# Running watson-conversation-slots-intro in a Container on Bluemix with Kubernetes

This directory allows you to deploy the `watson-conversation-slots-intro` application into a container running on Bluemix, using Kubernetes

The commands below use environment variables for various specific names. Either run the following to export the ENV variables, or substitue your names in the commands or exports:
```
$ export CLUSTER_NAME=Watson
$ export CONVERSATION_SERVICE=conversation-service-watson-pizzeria
$ export CONFIG_MAP=watson-pizzeria-config
$ export POD_NAME=watson-pizzeria-pod.yml
$ export KUBE_SERVICE=pizza-bot
$ export CONTAINER_ENV_VARIABLE=CONVERSATION_SERVICE_WATSON_PIZZERIA
```


# Steps

## Create the Kubernetes cluster

* Follow the instructions to [Create a Kubernetes Cluster](https://github.com/IBM/container-journey-template).
```
$ bx cs cluster-create --name $CLUSTER_NAME
```

## Create the Watson Conversation Service and Bind to your Cluster

Either follow the instructions to [Create a Conversation Service](https://console.ng.bluemix.net/catalog/services/conversation) or Perform the following from the Bluemix CLI:

* Create the Watson Conversation service.

```
$ bx service create conversation free $CONVERSATION_SERVICE
```


* Verify that the service instance is created.

```
$ bx service list
```

* Obtain the ID of your cluster.

```
$ bx cs clusters
```

* Bind the service instance to your cluster.

```
$ bx cs cluster-service-bind <cluster-ID> $CONVERSATION_SERVICE
```

## Load the Watson Conversation

* Follow the instructions to [Load the Watson Conversation](https://github.com/IBM/watson-conversation-slots-intro#4-configure-watson-conversation)

## Create a Kubernetes Configuration Map with the Workspace ID

* Create a Kubernetes Configuration Map

```
$ kubectl create configmap $CONFIG_MAP \
    --from-literal=workspace_id=<WorkSpace_ID>
```

* Verify that the configuration is set

```
$ kubectl get configmaps $CONFIG_MAP -o yaml
```

## Deploy the Pod

* Deploy

```
$ kubectl create -f $POD_NAME
```

* Identify the **Public IP** address of your worker.

```
$ bx cs workers $CLUSTER_NAME
``` 

* Identify the external port your pod is listening on. Note: The pizza-bot container listens on port 3000. Kubernetes maps this a publicly addressable port.

```
$ kubectl get services $KUBE_SERVICE
```

* Access the application using `http://<IP Address>:<Port>`

## Look Under the Hood

Now that you have created and bound a service instance to your cluster, let's take a deeper look at what is happening behind the scenes.


* Binding the conversation service to your cluster creates a Kubernets secret named binding-${CONVERSATION_SERVICE} .

* The secret contains a key named binding with its data being a JSON string of the form 

```
{"url":"https://gateway.watsonplatform.net/conversation/api",
 "username":"service-instance-user-uuid",
 "password":"service-instance-password"}.
```

The secret is mapped into the container as an environment variable through the Kubernetes pod configuration.

```
          - name: $CONTAINER_ENV_VARIABLE
            valueFrom:
              secretKeyRef:
                name: binding-${CONVERSATION_SERVICE}
                key: binding
```

* For an application that expects the service credentials to be set in the environment variables CONVERSATION_USERNAME and CONVERSATION_PASSWORD, we set these in the container environment. 

* Example usage is to have a script that is run when the container is started. We can then parse them from the  environment variable $CONTAINER_ENV_VARIABLE using the jq utility:

```
export CONVERSATION_USERNAME=$(echo "${CONVERSATION_ENV_VARIABLE}" |
                                jq -r '.username')

```

You can see the defined secrets in the Kubernetes dashboard by running ``kubctrl proxy`` and accessing http://127.0.0.1:8001/ui
