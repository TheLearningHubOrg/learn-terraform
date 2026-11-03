# The starter is a Terraform configuration, not a server. The image packs
# the Terraform binary, the locked providers and the configuration, and its
# default command runs the test suite, so `docker run` reproduces CI.

ARG TERRAFORM_VERSION=1.12.2

# ---- build: fetch providers, lint and test once at build time ---------------
FROM hashicorp/terraform:${TERRAFORM_VERSION} AS build
WORKDIR /src

# Providers depend only on these two files, so this layer stays cached until
# a provider version changes.
COPY versions.tf .terraform.lock.hcl ./
RUN terraform init -backend=false -input=false -lockfile=readonly

COPY . .
RUN terraform init -backend=false -input=false -lockfile=readonly \
 && terraform fmt -check -recursive \
 && terraform validate \
 && terraform test

# ---- runtime: slim Alpine with only the binary and the initialised project --
FROM alpine:3.22 AS runtime
RUN apk add --no-cache ca-certificates \
 && adduser -D learner
COPY --from=build /bin/terraform /usr/local/bin/terraform
WORKDIR /home/learner/starter
COPY --from=build --chown=learner:learner /src ./
USER learner
ENV TF_IN_AUTOMATION=1
CMD ["terraform", "test"]
