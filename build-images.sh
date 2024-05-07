for CONTEXT in images/*; do
	IMAGE_NAME=$(basename $CONTEXT)
	docker build \
		--tag registry.aredherring.tech/$IMAGE_NAME:latest \
		-f $CONTEXT/Dockerfile \
		$CONTEXT
done
