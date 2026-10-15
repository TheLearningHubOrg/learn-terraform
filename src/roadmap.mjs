/**
 * The Learning Hub - HashiCorp Terraform & OpenTofu Enterprise IaC Roadmap
 */

export const TERRAFORM_STAGES = [
  {
    stageNumber: 1,
    title: "Foundations, HCL2 Syntax & Core Architecture",
    domainFocus: "Providers, resources, data sources, inputs, outputs, local values, and HCL2 type constraints",
    completed: true,
    keyTopics: ["Provider Registry Protocol", "Resource Lifecycle", "HCL2 Type System", "Expressions & Functions"]
  },
  {
    stageNumber: 2,
    title: "State Management, Backends & Concurrency Locking",
    domainFocus: "State file anatomy, remote backends (S3 + DynamoDB), state locking, import & rm commands",
    completed: true,
    keyTopics: ["State Storage & Deserialization", "DynamoDB Lock Table", "State Drift Detection", "terraform import vs moved block"]
  },
  {
    stageNumber: 3,
    title: "The Graph Engine, Plan Lifecycle & Drift Mechanics",
    domainFocus: "Directed Acyclic Graph (DAG) construction, topological sort, parallelism, refresh & apply phases",
    completed: true,
    keyTopics: ["DAG Cycle Prevention", "Targeted Applies (-target)", "Tainted Resources", "Destroy-Before-Create Lifecycle"]
  },
  {
    stageNumber: 4,
    title: "Reusable Modules, Composition & Terragrunt",
    domainFocus: "Public/Private module registries, root vs child modules, version pinning, DRY configs with Terragrunt",
    completed: true,
    keyTopics: ["Semantic Versioning", "Module Outputs as Contract", "Terragrunt Dependency Blocks", "Monorepo vs Polyrepo IaC"]
  },
  {
    stageNumber: 5,
    title: "Enterprise Hardening, Policy as Code & Security",
    domainFocus: "HashiCorp Sentinel, Open Policy Agent (OPA) / Rego, checkov, tfsec, zero-trust secrets integration",
    completed: true,
    keyTopics: ["Static Code Analysis (tfsec)", "OPA Conftest Enforcement", "Vault Dynamic Credentials", "Secret Masking in State"]
  },
  {
    stageNumber: 6,
    title: "Multi-Environment CI/CD Pipelines & Automation",
    domainFocus: "GitHub Actions / GitLab CI automated plan/apply, speculative plans, Atlantis pull-request workflows",
    completed: true,
    keyTopics: ["Speculative Plans in PRs", "Atlantis GitOps", "Plan File Encryption", "Rollback Strategies"]
  },
  {
    stageNumber: 7,
    title: "Staff Cloud Platform Architect Interview Handbook",
    domainFocus: "40+ staff scenario Q&As, state file corruption recovery, massive graph memory bottlenecks, OpenTofu migration",
    completed: true,
    keyTopics: ["State Disaster Recovery", "OpenTofu vs Terraform BSL", "Cross-Account State Peering", "Massive Scale Concurrency (10k+ nodes)"]
  }
];

export function getCompletedCount() {
  return TERRAFORM_STAGES.filter(s => s.completed).length;
}

export function getProgressPercentage() {
  return Math.round((getCompletedCount() / TERRAFORM_STAGES.length) * 100);
}
