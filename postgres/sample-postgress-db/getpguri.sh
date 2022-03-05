#!/bin/zsh
kubectl get secrets employees-pguser-employees -o go-template='{{.data.uri | base64decode}}'
