#!/bin/bash +x
docker build -t gwsu2008/jenkins-python3:latest .
if [ $? -ne 0 ]; then
	exit 1
fi
exit 0
docker push gwsu2008/jenkins-python3:latest
if [ $? -ne 0 ]; then
	exit 1
fi
