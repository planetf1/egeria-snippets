#!/bin/sh

helm install lab egeria/odpi-egeria-lab -f ./lab-pg-chartoverride.yaml --devel
