#!/bin/sh
STACKS=$(ls *.yaml)
for STACK in $STACKS; do
	NAME=$(basename $STACK .yaml)
	echo "deploying stack $NAME"
	docker stack up --detach --compose-file $STACK $NAME
done
