# New host

## Host groups

### `new`

The `new` host group is used for managing new hosts that are added to the system.

## Variables

### `new_user`

The `new_user` variable specifies the user account to be created on the new host.

### `hostname`

The `hostname` variable contains the desired hostname for the new host.

### `tailscale_key`

The `tailscale_key` variable holds the Tailscale key required for connecting the new host to the network.

### `static_route`

This variable defines a static route configuration. Note that it is a conditional variable, and if set, the variables [`subnet`](#subnet), [`gateway`](#gateway), and [`interface`](#interface) must also be set.

### `subnet`

The `subnet` variable specifies the subnet configuration for the new host.

### `gateway`

The `gateway` variable holds the gateway information required for the new host configuration.

### `interface`

The `interface` variable defines the network interface used by the new host.

### `ipv4`

The `ipv4` variable contains the IPv4 address for the new host.

### `netmask`

The `netmask` variable stores the netmask value used in the new host configuration.

### `disk_device`

The `disk_device` variable specifies the disk device to be used on the new host.

### `partition_number`

This variable represents the partition number on the specified `disk_device`. It is a group variable and must be set along with [`partition_size`](#partition_size) if used.

### `partition_size`

The `partition_size` variable defines the size of the partition on the specified `disk_device`. It is a group variable and must be set along with [`partition_number`](#partition_number) if used.

### `skip_reboot`

This variable indicates whether a manual reboot is required after the configuration. If set, a manual reboot is necessary.
