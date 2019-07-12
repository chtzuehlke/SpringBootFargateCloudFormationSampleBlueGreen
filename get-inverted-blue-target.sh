#!/bin/bash

PREFIX=${1:-default}
STACK_PREFIX="helloworld-$PREFIX"

if [ "$(./get-stack-output.sh $STACK_PREFIX-alb BlueTarget)" == "one" ]; then
    echo "two"
else
    echo "one"
fi
