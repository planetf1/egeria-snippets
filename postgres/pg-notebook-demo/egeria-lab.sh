#!/bin/sh
helm repo add egeria https://odpi.github.io/egeria-charts
helm repo update
helm install lab egeria/odpi-egeria-lab -f ./lab-pg-chartoverride.yaml
