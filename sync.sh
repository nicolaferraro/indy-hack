#!/bin/sh

set -e

echo "Building local project to download dependencies..."
mvn -s settings.xml clean install

operator_pod=$(oc get pod -l camel.apache.org/component=operator -o=jsonpath='{.items[0].metadata.name}' --ignore-not-found)

if [ -z "$operator_pod" ]; then
    echo "Operator pod not found in current namespace"
    exit 1
fi

echo "Operator pod name is $operator_pod"

#echo "Applying maven settings..."
#oc apply -f camel-k-maven-settings.yaml

echo "Syncing local repo..."
set +e
oc rsync repo/ $operator_pod:/tmp/artifacts/m2/
set -e

echo "You can ignore permission errors on camel k libs..."

echo "Run a 'kamel reset' to re-initialize camel k."
