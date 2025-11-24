#!/bin/bash

docker network create --driver bridge --internal traefik
docker network create --driver bridge --internal lldap
