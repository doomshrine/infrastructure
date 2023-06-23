# Docker

This playbook provides an automated installation of Docker using the `geerlingguy.docker` role. It also includes the configuration and execution of basic containers.

## Host groups

To run this playbook, you need to define a host group named `dockerhost`. The playbook will only be executed on the hosts specified within this host group.

## Variables

### `shoutrrr_notifications_url`

This variable specifies the Shoutrrr notifications URL, which is required for Watchtower deployment. For the URL format and additional information, please refer to the [shoutrrr documentation](https://containrrr.dev/shoutrrr/0.7/).

