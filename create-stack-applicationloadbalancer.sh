#!/bin/bash

PREFIX=${1:-default}
STACK_PREFIX="helloworld-$PREFIX"

SSL_CERT_ARN=${2:-NONE}

BLUE_TARGET=one

aws cloudformation create-stack --stack-name $STACK_PREFIX-alb --template-body file://cloudformation/applicationloadbalancer.yaml --parameters \
	ParameterKey=NetworkStack,ParameterValue=$STACK_PREFIX-sg \
	ParameterKey=CertificateArn,ParameterValue="$SSL_CERT_ARN" \
	ParameterKey=BlueTarget,ParameterValue=$BLUE_TARGET
