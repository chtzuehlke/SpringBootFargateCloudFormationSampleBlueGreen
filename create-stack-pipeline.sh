#!/bin/bash

PREFIX=${1:-default}
STACK_PREFIX="helloworld-$PREFIX"

LOCAL_TAG=chtzuehlke/sample-web-workload:latest
REPO_URL=$(./get-stack-output.sh $STACK_PREFIX-ecr DockerRepoUrl)

CODECOMMIT_ARN=$(./get-stack-output.sh $STACK_PREFIX-git CodeCommitRepositoryARN)
CODECOMMIT_NAME=$(./get-stack-output.sh $STACK_PREFIX-git CodeCommitRepositoryName)

DB_PASSWORD_PARAM_NAME=$STACK_PREFIX-db-pwd

CLOUD_FORMATION_ROLE=$(./get-stack-output.sh $STACK_PREFIX-sg CloudFormationRole)

TARGET_GROUP1=$(./get-stack-output.sh $STACK_PREFIX-alb TargetGroup)
TARGET_GROUP2=$(./get-stack-output.sh $STACK_PREFIX-alb TargetGroup2)

TARGET_PREFIX=${2:-default2}
TARGET_STACK_PREFIX="helloworld-$TARGET_PREFIX"

TARGET_DB_PASSWORD_PARAM_NAME=$TARGET_STACK_PREFIX-db-pwd

TARGET_TARGET_GROUP1=$(./get-stack-output.sh $TARGET_STACK_PREFIX-alb TargetGroup)
TARGET_TARGET_GROUP2=$(./get-stack-output.sh $TARGET_STACK_PREFIX-alb TargetGroup2)

TARGET_CLOUD_FORMATION_ROLE=$(./get-stack-output.sh $TARGET_STACK_PREFIX-sg CloudFormationRole)

aws cloudformation create-stack --capabilities CAPABILITY_IAM --stack-name $STACK_PREFIX-pipe --template-body file://cloudformation/pipeline.yaml --parameters \
	ParameterKey=CodeCommitRepositoryARN,ParameterValue=$CODECOMMIT_ARN \
	ParameterKey=CodeCommitRepositoryName,ParameterValue=$CODECOMMIT_NAME \
	ParameterKey=DockerLocalTag,ParameterValue=$LOCAL_TAG \
	ParameterKey=RepoUrl,ParameterValue=$REPO_URL \
	ParameterKey=FargateStackName,ParameterValue=$STACK_PREFIX-ecs \
	ParameterKey=NetworkStack,ParameterValue=$STACK_PREFIX-sg \
	ParameterKey=LoadBalancerStack,ParameterValue=$STACK_PREFIX-alb \
	ParameterKey=DatabaseStack,ParameterValue=$STACK_PREFIX-rds \
	ParameterKey=DBPassSSMName,ParameterValue=$DB_PASSWORD_PARAM_NAME \
	ParameterKey=CloudFormationRole,ParameterValue=$CLOUD_FORMATION_ROLE \
	ParameterKey=TargetGroup,ParameterValue=$TARGET_GROUP1 \
	ParameterKey=TargetGroup2,ParameterValue=$TARGET_GROUP2 \
	ParameterKey=Stage2FargateStackName,ParameterValue=$TARGET_STACK_PREFIX-ecs \
	ParameterKey=Stage2LoadBalancerStack,ParameterValue=$TARGET_STACK_PREFIX-alb \
	ParameterKey=Stage2DBPassSSMName,ParameterValue=$TARGET_DB_PASSWORD_PARAM_NAME \
	ParameterKey=Stage2DatabaseStack,ParameterValue=$TARGET_STACK_PREFIX-rds \
	ParameterKey=Stage2NetworkStack,ParameterValue=$TARGET_STACK_PREFIX-sg \
	ParameterKey=Stage2TargetGroup,ParameterValue=$TARGET_TARGET_GROUP1 \
	ParameterKey=Stage2TargetGroup2,ParameterValue=$TARGET_TARGET_GROUP2 \
	ParameterKey=Stage2CloudFormationRole,ParameterValue=$TARGET_CLOUD_FORMATION_ROLE

aws cloudformation wait stack-create-complete --stack-name $STACK_PREFIX-pipe
