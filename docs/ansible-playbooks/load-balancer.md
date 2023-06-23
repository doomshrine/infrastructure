# Load balancer for K8s API Server

## Host groups

### `loadbalancer`

The `loadbalancer` host group contains the hosts responsible for load balancing the Kubernetes API server.

## Variables

### `subnet`

The `subnet` variable specifies the subnet configuration for the load balancer.

### `gateway`

The `gateway` variable holds the gateway information required for the load balancer configuration.

### `interface`

The `interface` variable defines the network interface used by the load balancer.

### `netmask`

The `netmask` variable stores the netmask value used in the load balancer configuration.

### `controlplane1`, `controlplane2`, `controlplane3`

These variables represent the control plane nodes that the load balancer will direct traffic to.
