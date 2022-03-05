egeria-lab.sh
 - Shell script to install coco pharma chart to k8s
 - specifies override file below (to use image with postgres connector)

lab-pg-chartoverride.yaml
 - override file for helm
 - specifies alternate container image - egeria 3.5 + postgres connector in a container

postgres-20220305a.ipynb
 - filenames will change
 - current work in progress notebook
 - run the normal coco configure/start first, THEN run this notebook
 - data will be imported from postgres


