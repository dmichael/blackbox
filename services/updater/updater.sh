#!/usr/bin/env bash

echo "Checking for core updates"

# ----------------------------------------
# Update the core system (this repository)
# ----------------------------------------

CURRENT="$(git rev-parse HEAD)"

REMOTE="$(git ls-remote origin HEAD  | awk '{ print $1}')"


if [[ "$CURRENT" != "$REMOTE" ]]; then
  echo "Core update available"

  git pull origin master

  echo "Restarting the blackbox.service"
  systemctl restart blackbox.service
  # We exit here because the `make start` command does a docker pull.
  # .. also, lets not put too much stress on the restart process which can take 15 mins
  exit 0
fi

echo "No core updates available"

# ----------------------------------------
# Update containers
# ----------------------------------------

echo "Checking for container updates"

# https://stackoverflow.com/questions/26423515/how-to-automatically-update-your-docker-containers-if-base-images-are-updated

make start


exit 0

set -e


for IMAGE in crypdex/pivx
do
  CID=$(docker ps | grep $IMAGE | awk '{print $1}')
  docker pull $IMAGE

  for im in $CID
  do
    LATEST=`docker inspect --format "{{.Id}}" $IMAGE`
    RUNNING=`docker inspect --format "{{.Image}}" $im`
    NAME=`docker inspect --format '{{.Name}}' $im | sed "s/\///g"`
    echo "Latest:" $LATEST
    echo "Running:" $RUNNING
    if [ "$RUNNING" != "$LATEST" ];then
      echo "Upgrading $NAME"
      docker-compose up -d -t 180 ${NAME}# 3 minute timeout
#      stop docker-$NAME
#      docker rm -f $NAME
#      start docker-$NAME
    else
      echo "$NAME up to date"
    fi
  done
done

