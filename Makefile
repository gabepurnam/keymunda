COMMIT_HASH:=$(shell git log -n1 --format=format:'%H')
export COMMIT_HASH
build:
	@echo "##############################################"
	@echo "                  START BUILD                 "
	@echo "##############################################"
	@echo ">>> UPDATING COMMIT_HASH"
	@echo $(COMMIT_HASH)
	@echo ">>> BUILDING IMAGE"
	docker build -t gabepurnam/keymunda:latest -t gabepurnam/keymunda:$${COMMIT_HASH} .
	@echo ">>> PUSHING INTO REPO WITH TAG COMMIT_HASH"
	docker push gabepurnam/keymunda:$${COMMIT_HASH}
	@echo ">>> PUSHING INTO REPO WITH TAG LATEST"
	docker push gabepurnam/keymunda:latest
	@echo "##############################################"
	@echo "                 BUILD FINISHED               "
	@echo "##############################################"

update-minikube:
	minikube cache delete gabepurnam/keymunda:latest
	docker pull gabepurnam/keymunda:latest
	minikube cache add gabepurnam/keymunda:latest
