
IMAGE_VERSION=0.0.16
IMAGE_NAME=ateam_app

build:
	docker-compose build 
	docker tag $(IMAGE_NAME):latest 498061775412.dkr.ecr.us-east-1.amazonaws.com/$(IMAGE_NAME):latest
	docker tag $(IMAGE_NAME):latest 498061775412.dkr.ecr.us-east-1.amazonaws.com/$(IMAGE_NAME):$(IMAGE_VERSION)

push: 
	aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin 498061775412.dkr.ecr.us-east-1.amazonaws.com
	docker push 498061775412.dkr.ecr.us-east-1.amazonaws.com/$(IMAGE_NAME):latest
	docker push 498061775412.dkr.ecr.us-east-1.amazonaws.com/$(IMAGE_NAME):$(IMAGE_VERSION)