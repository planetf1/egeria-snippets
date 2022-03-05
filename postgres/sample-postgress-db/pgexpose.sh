#!/bin/zsh
PG_CLUSTER_PRIMARY_POD=$(kubectl get pod -o name \
	  -l postgres-operator.crunchydata.com/cluster=employees,postgres-operator.crunchydata.com/role=master)
kubectl expose ${PG_CLUSTER_PRIMARY_POD} --type=LoadBalancer --port=5432 --target-port=5432 --name employees
