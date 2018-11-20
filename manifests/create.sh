#!/bin/bash

# run this file from the root of the repository
export KEY_FILE=ca.key
export CERT_FILE=ca.crt
export CERT_NAME=tls
# change the domain to one that you are able to create domain entries for
export SHORTBREAD_HOST=jimmy.eats.world
# add your private docker hub url
export DOCKER_HUB="myprivhub.com"
# add the repo where you'll push the image
export DOCKER_REPO="myrepo"
# add the name of the dockercfg secret in kubernetes
export DOCKER_REPO_SECRET="kubernetes-docker-secret"
docker build -f Dockerfile -t "${DOCKER_HUB}/${DOCKER_REPO}:app" .
docker build -f Dockerfile-db -t "${DOCKER_HUB}/${DOCKER_REPO}:db" .
docker push ${DOCKER_HUB}\/${DOCKER_REPO}:app
docker push ${DOCKER_HUB}\/${DOCKER_REPO}:db
openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout ${KEY_FILE} -out ${CERT_FILE} -subj "/CN=${SHORTBREAD_HOST}/O=${SHORTBREAD_HOST}"
# create namespace shray
kubectl create ns shray
# add tls secrets
kubectl -n shray create secret tls ${CERT_NAME} --key ${KEY_FILE} --cert ${CERT_FILE}
# create kubernetes objects pointing to proper domains/secrets
sed -e "s/SHORTBREAD_HOST/$SHORTBREAD_HOST/g" -e "s/DOCKER_REPO_SECRET/$DOCKER_REPO_SECRET/g" -e "s/REGISTRY_URL/${DOCKER_HUB}\/${DOCKER_REPO}/g"  manifests/all-in-one.yml.tmpl > all-in-one.yml
# apply them
kubectl apply -f all-in-one.yml