#!/bin/bash

PREFIX=${1:-default}
STACK_PREFIX="helloworld-$PREFIX"

aws cloudformation create-stack --stack-name $STACK_PREFIX-git --template-body file://cloudformation/codecommit.yaml

aws cloudformation wait stack-create-complete --stack-name $STACK_PREFIX-git
