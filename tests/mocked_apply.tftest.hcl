# Mock providers (Terraform 1.7+) answer every call with fake data, so an
# apply completes without touching the filesystem or the network. The
# defaults below make the random suffix predictable.

mock_provider "random" {
  mock_resource "random_pet" {
    defaults = {
      id = "brave-otter"
    }
  }
}

mock_provider "local" {}

variables {
  project     = "acme"
  environment = "staging"
}

run "document_has_a_predictable_name" {
  assert {
    condition     = output.resource_name == "acme-staging-brave-otter"
    error_message = "The resource name must be prefix plus the pet suffix."
  }

  assert {
    condition     = jsondecode(local_file.network_plan.content).name == "acme-staging-brave-otter"
    error_message = "The document must carry the same name."
  }

  assert {
    condition     = jsondecode(local_file.network_plan.content).revision == sha256(jsonencode(jsondecode(local_file.network_plan.content).subnets))
    error_message = "The revision must be the hash of the subnet layout."
  }
}

run "document_path_uses_the_prefix" {
  assert {
    condition     = endswith(output.document_path, "/out/acme-staging-network.json")
    error_message = "The document file name must use the name prefix."
  }
}
