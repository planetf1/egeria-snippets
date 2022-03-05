#!/bin/sh
URI=`./getpguri.sh|sed 's/employees-primary.postgres.svc/158.176.183.28/g'`
psql "${URI}" < employees_data.sql
