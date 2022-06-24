#!/bin/bash

PROJECT=$1
REGION=$2
IMAGE=$3

DOCKERFILE_PATH='../../../../../../../../go-microservices-realworld-example-app-users-service'

pushd "$DOCKERFILE_PATH" || exit 1
gcloud builds submit --project "$PROJECT" --region "$REGION" --tag "$IMAGE" || exit 1
popd || exit 1
