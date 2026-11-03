# A real apply with the real providers. terraform test destroys everything
# it created once the file finishes, so out/ is cleaned up automatically.

variables {
  project     = "acme"
  environment = "dev"
  owner       = "platform-team"
}

run "writes_the_network_document" {
  command = apply

  assert {
    condition     = can(regex("^acme-dev-[a-z]+-[a-z]+$", output.resource_name))
    error_message = "random_pet must add a two-word suffix."
  }

  assert {
    condition     = fileexists(output.document_path)
    error_message = "The document must exist on disk after apply."
  }

  assert {
    condition     = length(jsondecode(file(output.document_path)).subnets) == 9
    error_message = "The document on disk must list nine subnets."
  }
}

run "suffix_is_stable_across_applies" {
  command = apply

  # Same keepers as the first run, so random_pet must not be replaced.
  assert {
    condition     = output.resource_name == run.writes_the_network_document.resource_name
    error_message = "The suffix changed although no keeper changed."
  }
}
