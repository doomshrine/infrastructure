# High availability K3s with Cilium

> ⚠️ **WARNING!** Make sure to modify the variables in the script according to your environment before executing it!

## Purpose
This file is a deployment script written in Bash. Its purpose is to automate the installation and configuration of various components in a Kubernetes cluster. The script makes use of several dependencies and performs tasks such as installing and configuring k3s, installing Cilium and Kured, and setting up Flux for GitOps deployment.

## Components
The script consists of the following components:

1. **Shebang and Variables**: The script starts with a shebang specifying the interpreter to be used. It also defines several variables used throughout the script, such as `GITHUB_USER`, `INFRA_REPO`, `USER`, `SSH_KEY`, `SERVERS`, and `AGENTS`.

2. **Dependencies**: This section checks if the required dependencies (`cilium`, `flux`, `kubectl`, `k3sup`) are installed. It invokes the `_check` function for each dependency to verify its presence.

3. **Uninstall k3s**: The `prune` target is responsible for uninstalling k3s from the specified servers and agents. It uses SSH to execute the `k3s-agent-uninstall.sh` and `k3s-uninstall.sh` scripts on the respective machines.

4. **Install k3s**: The `k3s` target installs k3s on the servers and joins them to form a cluster. It requires the dependencies to be installed beforehand. It invokes several internal functions, including `_k3s_pre`, `_k3s_server`, and `_k3s_agent`.

5. **Internal Functions**:
    - `_k3s_pre`: Performs pre-installation checks and validations before installing k3s. It verifies the number of servers, the presence of the `USER` and `SSH_KEY` variables, and ensures a minimum of three servers for high availability.
    - `_k3s_server`: Installs k3s on the control plane server and generates the kubeconfig file. It sets up additional parameters such as the flannel backend, cluster CIDR, and disables certain components.
    - `_k3s_agent`: Joins the agent nodes to the k3s cluster by executing the `k3sup join` command for each agent.
    - `_k3s_is_ready` function waits for the k3s cluster to be ready by checking the readiness condition of the nodes using `kubectl wait`.

6. **Install Cilium**: The `cilium` target installs and enables Cilium, a networking and security plugin, in the Kubernetes cluster. It requires the dependencies to be installed beforehand. It sets the `KUBECONFIG` environment variable to point to the generated kubeconfig file.

7. **Install Kured**: The `kured` target installs and deploys Kured, a Kubernetes reboot daemon, in the cluster. It applies the `kured.yaml` manifest file using `kubectl`.

8. **Fetch Kured Manifest**: The `_fetch_kured_manifest` function retrieves the latest release of Kured from GitHub and saves the manifest file locally in the `./generated/` directory.

9. **Configure Kured**: The `kured_configure` function is responsible for modifying the fetched `kured.yaml` file to include additional configurations. It appends the `--notify-url` and `--reboot-sentinel-command` options based on the provided `TOKEN`.

10. **Install and Configure Flux**: The `flux` target installs and configures Flux, a GitOps operator, in the cluster. It performs a pre-check using `flux check --pre` and then bootstraps Flux for GitHub integration. It requires the specified `PATH` to be the repository path where the Flux manifests are located.

## Usage
To use this script, you can run it directly by executing the file or by invoking specific targets using the `just` command with the appropriate target name. For example:

```sh
$ just dependencies # Check dependencies
$ just k3s # Install k3s and join servers and agents
$ just cilium # Install Cilium
$ just kured # Install Kured
$ just flux ./path/to/repo # Install and configure Flux with the specified path
```
