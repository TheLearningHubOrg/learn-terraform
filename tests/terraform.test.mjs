import { describe, it } from 'node:test';
import assert from 'node:assert/strict';

describe('Terraform Directed Acyclic Graph (DAG) Engine', () => {
  function resolveExecutionOrder(nodes, dependencies) {
    const inDegree = {};
    const adj = {};
    
    nodes.forEach(n => {
      inDegree[n] = 0;
      adj[n] = [];
    });

    dependencies.forEach(([parent, child]) => {
      adj[parent].push(child);
      inDegree[child] = (inDegree[child] || 0) + 1;
    });

    const queue = nodes.filter(n => inDegree[n] === 0);
    const order = [];

    while (queue.length > 0) {
      const current = queue.shift();
      order.push(current);

      adj[current].forEach(neighbor => {
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

  it('determines correct topological execution order for dependent resources', () => {
    const nodes = ['aws_vpc.main', 'aws_subnet.public', 'aws_security_group.web', 'aws_instance.app'];
    const dependencies = [
      ['aws_vpc.main', 'aws_subnet.public'],
      ['aws_vpc.main', 'aws_security_group.web'],
      ['aws_subnet.public', 'aws_instance.app'],
      ['aws_security_group.web', 'aws_instance.app']
    ];

    const order = resolveExecutionOrder(nodes, dependencies);
    assert.equal(order[0], 'aws_vpc.main');
    assert.equal(order[order.length - 1], 'aws_instance.app');
  });

  it('throws an error when a circular dependency is declared', () => {
    const nodes = ['res_a', 'res_b'];
    const dependencies = [
      ['res_a', 'res_b'],
      ['res_b', 'res_a']
    ];

    assert.throws(() => {
      resolveExecutionOrder(nodes, dependencies);
    }, /Cycle detected in dependency graph/);
  });
});

describe('HCL2 Collection Transformations: count vs for_each', () => {
  it('demonstrates index shifting vulnerability with count', () => {
    const originalList = ['subnet-a', 'subnet-b', 'subnet-c'];
    const originalKeys = originalList.map((_, idx) => `subnet[${idx}]`);

    // Remove middle element
    const updatedList = ['subnet-a', 'subnet-c'];
    const updatedKeys = updatedList.map((_, idx) => `subnet[${idx}]`);

    // In count, subnet-c moved from index 2 to index 1 -> triggers destruction!
    assert.equal(originalKeys[2], 'subnet[2]');
    assert.equal(updatedKeys[1], 'subnet[1]');
  });

  it('demonstrates key stability with for_each', () => {
    const originalSet = new Set(['us-east-1a', 'us-east-1b', 'us-east-1c']);
    const updatedSet = new Set(['us-east-1a', 'us-east-1c']);

    // Key for us-east-1c remains completely unchanged
    assert.ok(originalSet.has('us-east-1c'));
    assert.ok(updatedSet.has('us-east-1c'));
  });
});

describe('Terraform Variable Resolution Precedence', () => {
  function resolveVariable(sources) {
    // Order of precedence: cli > auto_tfvars > tfvars > env > default
    const precedence = ['cli', 'auto_tfvars', 'tfvars', 'env', 'default'];
    for (const source of precedence) {
      if (sources[source] !== undefined) {
        return sources[source];
      }
    }
    return null;
  }

  it('prioritizes CLI flags over environment variables and defaults', () => {
    const sources = {
      default: 't3.micro',
      env: 't3.small',
      tfvars: 't3.medium',
      cli: 'm5.large'
    };
    assert.equal(resolveVariable(sources), 'm5.large');
  });

  it('falls back to environment variables when tfvars and CLI are omitted', () => {
    const sources = {
      default: 't3.micro',
      env: 't3.large'
    };
    assert.equal(resolveVariable(sources), 't3.large');
  });
});
