# Copyright 2017 The Kubernetes Authors.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

.PHONY: all driver-registrar clean test

IMAGE_NAME=quay.io/k8scsi/driver-registrar
IMAGE_VERSION=canary

ifdef V
TESTARGS = -v -args -alsologtostderr -v 5
else
TESTARGS =
endif


all: driver-registrar

driver-registrar:
	mkdir -p bin
	CGO_ENABLED=0 GOOS=linux go build -a -ldflags '-extldflags "-static"' -o ./bin/driver-registrar ./cmd/driver-registrar

clean:
	rm -rf bin deploy/docker/driver-registrar

container: driver-registrar
	cp bin/driver-registrar deploy/docker
	docker build -t $(IMAGE_NAME):$(IMAGE_VERSION) deploy/docker

push: container
	docker push $(IMAGE_NAME):$(IMAGE_VERSION)

test:
	go test `go list ./... | grep -v 'vendor'` $(TESTARGS)
	go vet `go list ./... | grep -v vendor`
