#!/bin/sh

echo
echo "Building cihm-ingestwip:latest"

docker build -t cihm-ingestwip:latest .

if [ "$?" -ne "0" ]; then
  exit $?
fi


docker login docker.c7a.ca

if [ "$?" -ne "0" ]; then
  echo 
  echo "Error logging into the c7a Docker registry."
  exit 1
fi

TAG=`date -u +"%Y%m%d%H%M%S"`

echo
echo "Tagging cihm-ingestwip:latest as docker.c7a.ca/cihm-ingestwip:$TAG"

docker tag cihm-ingestwip:latest docker.c7a.ca/cihm-ingestwip:$TAG

if [ "$?" -ne "0" ]; then
  exit $?
fi

echo
echo "Pushing docker.c7a.ca/cihm-ingestwip:$TAG"

docker push docker.c7a.ca/cihm-ingestwip:$TAG

if [ "$?" -ne "0" ]; then
  exit $?
fi

echo
echo "Push sucessful. Create a new issue at:"
echo
echo "https://github.com/crkn-rcdr/Systems-Administration/issues/new?title=New+Packaging+image:+%60docker.c7a.ca/cihm-ingestwip:$TAG%60&body=Please+describe+the+changes+in+this+update%2e"
echo
echo "to alert the systems team. Don't forget to describe what's new!"