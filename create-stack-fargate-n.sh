#!/bin/bash

PREFIX=$1
STACK_PREFIX="helloworld-$PREFIX"

SOURCE_PREFIX=$2
SOURCE_STACK_PREFIX="helloworld-$SOURCE_PREFIX"

if [ "$(./get-stack-output.sh $SOURCE_STACK_PREFIX-alb BlueTarget)" == "two" ]; then
	REMOTE_TAG=$(./get-stack-output.sh $SOURCE_STACK_PREFIX-ecs DockerImage)
else
	REMOTE_TAG=$(./get-stack-output.sh $SOURCE_STACK_PREFIX-ecs DockerImage2)
fi

DB_PASSWORD_PARAM_NAME=$STACK_PREFIX-db-pwd

CLOUD_FORMATION_ROLE=$(./get-stack-output.sh $STACK_PREFIX-sg CloudFormationRole)

TARGET_GROUP1=$(./get-stack-output.sh $STACK_PREFIX-alb TargetGroup)
TARGET_GROUP2=$(./get-stack-output.sh $STACK_PREFIX-alb TargetGroup2)

aws cloudformation create-stack --capabilities CAPABILITY_IAM --stack-name $STACK_PREFIX-ecs \
	--role-arn $CLOUD_FORMATION_ROLE \
	--template-body file://cloudformation/fargate.yaml --parameters \
	ParameterKey=NetworkStack,ParameterValue=$STACK_PREFIX-sg \
	ParameterKey=LoadBalancerStack,ParameterValue=$STACK_PREFIX-alb \
	ParameterKey=DatabaseStack,ParameterValue=$STACK_PREFIX-rds \
	ParameterKey=DBPassSSMName,ParameterValue=$DB_PASSWORD_PARAM_NAME \
	ParameterKey=TargetGroup,ParameterValue=$TARGET_GROUP1 \
	ParameterKey=DockerImage,ParameterValue=$REMOTE_TAG \
	ParameterKey=TargetGroup2,ParameterValue=$TARGET_GROUP2 \
	ParameterKey=DockerImage2,ParameterValue=$REMOTE_TAG
