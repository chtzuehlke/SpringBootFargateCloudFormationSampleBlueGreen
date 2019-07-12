#!/bin/bash

PREFIX=${1:-default}
STACK_PREFIX="helloworld-$PREFIX"

BLUE_TARGET=${2:-one}

aws cloudformation update-stack --stack-name $STACK_PREFIX-alb --use-previous-template --parameters \
	ParameterKey=NetworkStack,UsePreviousValue=true \
	ParameterKey=CertificateArn,UsePreviousValue=true \
	ParameterKey=BlueTarget,ParameterValue=$BLUE_TARGET
