#!/bin/zsh
echo -n 'USER: ' 
kubectl get secrets employees-pguser-employees -o go-template='{{.data.user | base64decode}}'
echo 
echo -n 'PASSWORD: '
kubectl get secrets employees-pguser-employees -o go-template='{{.data.password | base64decode}}'
echo
echo 'Service info:'
kubectl get services
