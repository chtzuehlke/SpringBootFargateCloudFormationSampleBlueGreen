#!/bin/bash

PREFIX=${1:-default}
STACK_PREFIX="helloworld-$PREFIX"

VERSION=$2
REMOTE_TAG=$(./get-stack-output.sh $STACK_PREFIX-ecr DockerRepoUrl):$VERSION

CLOUD_FORMATION_ROLE=$(./get-stack-output.sh $STACK_PREFIX-sg CloudFormationRole)

if [ "$(./get-stack-output.sh $STACK_PREFIX-alb BlueTarget)" == "two" ]; then
	aws cloudformation update-stack --capabilities CAPABILITY_IAM --stack-name $STACK_PREFIX-ecs \
		--role-arn $CLOUD_FORMATION_ROLE \
		--use-previous-template --parameters \
		ParameterKey=NetworkStack,UsePreviousValue=true \
		ParameterKey=LoadBalancerStack,UsePreviousValue=true \
		ParameterKey=DatabaseStack,UsePreviousValue=true \
		ParameterKey=DBPassSSMName,UsePreviousValue=true \
		ParameterKey=TargetGroup,UsePreviousValue=true \
		ParameterKey=DockerImage,UsePreviousValue=true \
		ParameterKey=TargetGroup2,UsePreviousValue=true \
		ParameterKey=DockerImage2,ParameterValue=$REMOTE_TAG    
else
	aws cloudformation update-stack --capabilities CAPABILITY_IAM --stack-name $STACK_PREFIX-ecs \
		--role-arn $CLOUD_FORMATION_ROLE \
		--use-previous-template --parameters \
		ParameterKey=NetworkStack,UsePreviousValue=true \
		ParameterKey=LoadBalancerStack,UsePreviousValue=true \
		ParameterKey=DatabaseStack,UsePreviousValue=true \
		ParameterKey=DBPassSSMName,UsePreviousValue=true \
		ParameterKey=TargetGroup,UsePreviousValue=true \
		ParameterKey=DockerImage,ParameterValue=$REMOTE_TAG \
		ParameterKey=TargetGroup2,UsePreviousValue=true \
		ParameterKey=DockerImage2,UsePreviousValue=true    
fi
