/**
 * Terraform Directed Acyclic Graph (DAG) & State Locking Simulator
 */

export function resolveExecutionOrder(nodes, dependencies) {
  const inDegree = {};
  const adj = {};

  nodes.forEach(n => {
    inDegree[n] = 0;
    adj[n] = [];
  });

  dependencies.forEach(([parent, child]) => {
    if (!adj[parent]) adj[parent] = [];
    adj[parent].push(child);
    inDegree[child] = (inDegree[child] || 0) + 1;
  });

  const queue = nodes.filter(n => inDegree[n] === 0);
  const order = [];

  while (queue.length > 0) {
    const current = queue.shift();
    order.push(current);

    (adj[current] || []).forEach(neighbor => {
      inDegree[neighbor]--;
      if (inDegree[neighbor] === 0) {
        queue.push(neighbor);
      }
    });
  }

  if (order.length !== nodes.length) {
    throw new Error('Cycle detected in dependency graph');
  }

  return order;
}

export function resolveVariable(sources) {
  const precedence = ['cli', 'auto_tfvars', 'tfvars', 'env', 'default'];
  for (const source of precedence) {
    if (sources[source] !== undefined) {
      return { value: sources[source], source };
    }
  }
  return { value: null, source: 'none' };
}

export class RemoteStateLockManager {
  constructor(lockTable = 'terraform-state-lock') {
    this.lockTable = lockTable;
    this.activeLock = null;
  }

  acquireLock(lockId, who, operation) {
    if (this.activeLock) {
      throw new Error(`Error acquiring the state lock: State already locked by ${this.activeLock.who} (Lock ID: ${this.activeLock.lockId}, Operation: ${this.activeLock.operation})`);
    }
    this.activeLock = {
      lockId,
      who,
      operation,
      created: new Date().toISOString()
    };
    return this.activeLock;
  }

  releaseLock(lockId) {
    if (!this.activeLock) {
      return false;
    }
    if (this.activeLock.lockId !== lockId) {
      throw new Error(`Cannot release lock: Mismatched lock ID (${lockId} vs ${this.activeLock.lockId})`);
    }
    this.activeLock = null;
    return true;
  }
}
