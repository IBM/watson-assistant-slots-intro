#!/bin/bash
#set -x

#View build properties
cat build.properties

#Check cluster availability
ip_addr=$(bx cs workers $PIPELINE_KUBERNETES_CLUSTER_NAME | grep normal | awk '{ print $2 }')
if [ -z $ip_addr ]; then
    echo "$PIPELINE_KUBERNETES_CLUSTER_NAME not created or workers not ready"
    exit 1
fi

# Check Helm/Tiller
echo "CHECKING TILLER (Helm's server component)"
helm init --upgrade
while true; do
tiller_deployed=$(kubectl --namespace=kube-system get pods | grep tiller | grep Running | grep 1/1 )
if [[ "${tiller_deployed}" != "" ]]; then
    echo "Tiller ready."
    break;
fi
echo "Waiting for Tiller to be ready."
sleep 1
done

echo "DEPLOYING..."
CHART_NAME=IBMGENERATED
helm upgrade ${RELEASE_NAME} ./chart/${CHART_NAME} --install --debug

echo ""
echo "DEPLOYED SERVICE:"
kubectl describe services ${CHART_NAME}

echo ""
echo "DEPLOYED PODS:"
kubectl describe pods --selector app=${CHART_NAME}-selector

port=$(kubectl get services | grep ${CHART_NAME} | sed 's/.*:\([0-9]*\).*/\1/g')
echo ""
echo "VIEW THE APPLICATION AT: http://$ip_addr:$port"