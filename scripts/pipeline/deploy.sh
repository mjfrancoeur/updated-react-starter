#!/bin/bash
set -xe

# Make sure the cluster is running and get the ip_address
ip_addr=$(bx cs workers $PIPELINE_KUBERNETES_CLUSTER_NAME | grep normal | awk '{ print $2 }')
if [ -z $ip_addr ]; then
  echo "$PIPELINE_KUBERNETES_CLUSTER_NAME not created or workers not ready"
  exit 1
fi

# Initialize script variables
NAME="talent-ui"

DEPLOYMENT_FILE="deployment.yml"
echo "Creating deployment file $DEPLOYMENT_FILE"

# Build the deployment file
DEPLOYMENT=$(cat deployment.yml)

# Substitute the variables
echo "$DEPLOYMENT" > $DEPLOYMENT_FILE
sed -i 's/$BUILD_NUMBER/'"$BUILD_NUMBER"'/g' $DEPLOYMENT_FILE

# Show the file that is about to be executed
echo ""
echo "DEPLOYING USING MANIFEST:"
echo "cat $DEPLOYMENT_FILE"
cat $DEPLOYMENT_FILE
echo ""

echo "GET THE PODS"
echo | kubectl get pods

echo "GET THE SECRETS"
echo | kubectl get secrets

# Execute the file
echo "KUBERNETES APPLY:"
kubectl apply -f $DEPLOYMENT_FILE
echo ""

echo ""
echo "DEPLOYED SERVICE:"
kubectl describe services $NAME-service
echo ""
echo "DEPLOYED PODS:"
kubectl describe pods --selector app=$NAME
echo ""

# Show the IP address and the PORT of the running app
port=$(kubectl get services | grep "$NAME-service " | sed 's/.*:\([0-9]*\).*/\1/g')
echo "RUNNING APPLICATION:"
echo "URL=http://$ip_addr"
echo "PORT=$port"
echo ""
echo "$NAME running at: http://$ip_addr:$port"
