.PHONY: all image package dist clean deploy

all: package

image:
	docker build --tag amazonlinux:nodejs .

package: image
	docker run --rm --volume ${PWD}/lambda:/build amazonlinux:nodejs npm install --production

dist: package
	cd lambda && zip -FS -q -r ../dist/function.zip *

clean:
	rm -r lambda/node_modules
	docker rmi --force amazonlinux:nodejs

deploy:
	docker run --rm -it --volume ${PWD}:/usr/src/app rabbitbird/awscli:1.1 bash -c 'aws configure && bin/deploy'
