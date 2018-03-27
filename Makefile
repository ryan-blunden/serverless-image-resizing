.PHONY: all image package dist clean deploy

all: package

image:
	docker image build --tag amazonlinux:nodejs .

package: image
	docker container run --rm --volume ${PWD}/lambda:/build amazonlinux:nodejs npm install --production

dist: package
	cd lambda && zip -FS -q -r ../dist/function.zip *

clean:
	rm -r lambda/node_modules
	docker image rm --force amazonlinux:nodejs

deploy:
	docker container run --rm -it --volume ${PWD}:/usr/src/app rabbitbird/awscli:1.0 bash -c 'aws configure && bin/deploy'

delete:
	docker container run --rm -it --volume ${PWD}:/usr/src/app rabbitbird/awscli:1.0 bash -c 'aws configure && image_bucket_name=${IMAGE_BUCKET_NAME} deployment_bucket_name=${DEPLOYMENT_BUCKET_NAME} bin/delete'