#!/bin/bash

PREFIX=${1:-default}
STACK_PREFIX="helloworld-$PREFIX"

TARGET_PREFIX=${2:-default}
TARGET_STACK_PREFIX="helloworld-$TARGET_PREFIX"

aws cloudformation update-stack --capabilities CAPABILITY_IAM --stack-name $STACK_PREFIX-pipe --template-body file://cloudformation/pipeline.yaml --parameters \
	ParameterKey=CodeCommitRepositoryARN,UsePreviousValue=true \
	ParameterKey=CodeCommitRepositoryName,UsePreviousValue=true \
	ParameterKey=DockerLocalTag,UsePreviousValue=true \
	ParameterKey=RepoUrl,UsePreviousValue=true \
	ParameterKey=FargateStackName,UsePreviousValue=true \
	ParameterKey=NetworkStack,UsePreviousValue=true \
	ParameterKey=LoadBalancerStack,UsePreviousValue=true \
	ParameterKey=DatabaseStack,UsePreviousValue=true \
	ParameterKey=DBPassSSMName,UsePreviousValue=true \
	ParameterKey=CloudFormationRole,UsePreviousValue=true \
	ParameterKey=TargetGroup,UsePreviousValue=true \
	ParameterKey=TargetGroup2,UsePreviousValue=true \
	ParameterKey=Stage2FargateStackName,ParameterValue=$TARGET_STACK_PREFIX-ecs \
	ParameterKey=Stage2LoadBalancerStack,ParameterValue=$TARGET_STACK_PREFIX-alb
