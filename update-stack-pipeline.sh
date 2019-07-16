#!/bin/bash

PREFIX=${1:-default}
STACK_PREFIX="helloworld-$PREFIX"

TARGET_PREFIX=${2:-default}
TARGET_STACK_PREFIX="helloworld-$TARGET_PREFIX"

TARGET_DB_PASSWORD_PARAM_NAME=$TARGET_STACK_PREFIX-db-pwd

TARGET_TARGET_GROUP1=$(./get-stack-output.sh $TARGET_STACK_PREFIX-alb TargetGroup)
TARGET_TARGET_GROUP2=$(./get-stack-output.sh $TARGET_STACK_PREFIX-alb TargetGroup2)

TARGET_CLOUD_FORMATION_ROLE=$(./get-stack-output.sh $TARGET_STACK_PREFIX-sg CloudFormationRole)

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
	ParameterKey=Stage2LoadBalancerStack,ParameterValue=$TARGET_STACK_PREFIX-alb \
	ParameterKey=Stage2DBPassSSMName,ParameterValue=$TARGET_DB_PASSWORD_PARAM_NAME \
	ParameterKey=Stage2DatabaseStack,ParameterValue=$TARGET_STACK_PREFIX-rds \
	ParameterKey=Stage2NetworkStack,ParameterValue=$TARGET_STACK_PREFIX-sg \
	ParameterKey=Stage2TargetGroup,ParameterValue=$TARGET_TARGET_GROUP1 \
	ParameterKey=Stage2TargetGroup2,ParameterValue=$TARGET_TARGET_GROUP2 \
	ParameterKey=Stage2CloudFormationRole,ParameterValue=$TARGET_CLOUD_FORMATION_ROLE
