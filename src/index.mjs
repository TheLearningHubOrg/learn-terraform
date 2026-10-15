import { resolveExecutionOrder, resolveVariable, RemoteStateLockManager } from './dag-engine.mjs';
import { TERRAFORM_STAGES, getCompletedCount, getProgressPercentage } from './roadmap.mjs';

console.log('======================================================');
console.log('  The Learning Hub - Terraform & OpenTofu Enterprise IaC');
console.log('======================================================');
console.log('Engine: Directed Acyclic Graph (DAG) + State Lock Engine');
console.log('Compatibility: HashiCorp Terraform 1.9+ & OpenTofu 1.8+\n');

// 1. DAG Topological Order Resolution
console.log('--- 1. Directed Acyclic Graph (DAG) Plan Execution ---');
const resourceNodes = [
  'aws_vpc.primary',
  'aws_internet_gateway.gw',
  'aws_subnet.public_a',
  'aws_subnet.public_b',
  'aws_security_group.lb_sg',
  'aws_lb.web_alb',
  'aws_instance.app_cluster'
];

const dependencies = [
  ['aws_vpc.primary', 'aws_internet_gateway.gw'],
  ['aws_vpc.primary', 'aws_subnet.public_a'],
  ['aws_vpc.primary', 'aws_subnet.public_b'],
  ['aws_vpc.primary', 'aws_security_group.lb_sg'],
  ['aws_subnet.public_a', 'aws_lb.web_alb'],
  ['aws_subnet.public_b', 'aws_lb.web_alb'],
  ['aws_security_group.lb_sg', 'aws_lb.web_alb'],
  ['aws_subnet.public_a', 'aws_instance.app_cluster'],
  ['aws_security_group.lb_sg', 'aws_instance.app_cluster']
];

const executionPlan = resolveExecutionOrder(resourceNodes, dependencies);
console.log('Topological Dependency Resolution Order:');
executionPlan.forEach((res, idx) => {
  console.log(`  Step ${idx + 1}: ${res}`);
});

// 2. Remote State Locking Simulation
console.log('\n--- 2. DynamoDB Remote State Locking Engine ---');
const lockMgr = new RemoteStateLockManager('terraform-locks-prod');
const lock = lockMgr.acquireLock('lock-8f92a1', 'deploy-agent@ci-runner-4', 'OperationTypeApply');
console.log(`Acquired Lock: [ID: ${lock.lockId}] Holder: ${lock.who} at ${lock.created}`);

try {
  // Concurrent apply attempt
  lockMgr.acquireLock('lock-999999', 'developer@laptop', 'OperationTypeApply');
} catch (err) {
  console.log(`Expected Concurrency Conflict: ${err.message}`);
}
lockMgr.releaseLock(lock.lockId);
console.log('State Lock released successfully.\n');

// 3. Variable Precedence
console.log('--- 3. HCL2 Variable Precedence Resolution ---');
const resolved = resolveVariable({
  default: 't3.micro',
  env: 't3.medium',
  tfvars: 'm5.large',
  cli: 'c6i.2xlarge'
});
console.log(`Resolved Instance Type: ${resolved.value} (precedence source: ${resolved.source})\n`);

// 4. 7-Stage Pedagogical Roadmap
console.log('--- 4. 7-Stage Terraform & OpenTofu Masterclass Roadmap ---');
for (const stage of TERRAFORM_STAGES) {
  const icon = stage.completed ? '[OK]' : '[..]';
  console.log(` ${icon} Stage ${stage.stageNumber}: ${stage.title}`);
  console.log(`      Focus: ${stage.domainFocus}`);
  console.log(`      Topics: ${stage.keyTopics.join(', ')}`);
}

const completed = getCompletedCount();
const percent = getProgressPercentage();
console.log('------------------------------------------------------');
console.log(`Progress: ${completed}/7 Stages Complete (${percent}%)`);
console.log('======================================================\n');
