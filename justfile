#!/usr/bin/env -S just --justfile
# Shebang above is not necessary, but it allows you to run this file directly

# Check if all dependencies are installed
dependencies:
    #!/usr/bin/env bash
    set -e

    FAIL=0
    for dir in */; do
        if [ -f "$dir/justfile" ]; then
            echo "Dependencies for $dir"
            cd "$dir"
            if ! just dependencies; then
                FAIL=1
            fi
            cd ..
        fi
    done

    if [ $FAIL -eq 1 ]; then
        exit 1
    fi

# Build all templates using Packer
templates:
    #!/usr/bin/env bash
    set -e

    cd templates

    for dir in */; do
        tpl="$(basename ${dir})"
        if [ -d "$dir" ]; then
            echo "Building template ${tpl}"
            just build "${tpl}"
        fi
    done

# Generate ssh keypair for ansible
keygen:
    #!/usr/bin/env bash
    set -e

    if [ ! -f ~/.ssh/ansible ]; then
        ssh-keygen -t ed25519 -f ~/.ssh/ansible -N ''
    fi

# Install pre-commit hooks
hooks:
    pre-commit install --hook-type pre-commit
    pre-commit install --hook-type commit-msg

# Build and serve docs locally
serve-docs:
    docker run \
        --rm \
        --interactive \
        --tty \
        --volume $(pwd):/app:ro \
        --publish 8000:8000 \
        --pull=always \
        docker.io/library/python:latest \
            bash -c "cd /app && \
                pip install -r docs/requirements.txt && \
                mkdocs serve \
                    --dev-addr 0.0.0.0:8000 \
                    --livereload"

# Build docs for publishing (should be run in CI only)
build-docs VERSION:
    #!/usr/bin/env -S bash
    set -e

    # Check if run in CI (GitHub Actions)
    if [[ -z "${CI}" ]]; then
        echo "This script should only be run in CI"
        exit 1
    fi

    # First, install requirements for building docs
    pip install -r docs/requirements.txt

    version="{{VERSION}}"

    # Determine if this is a prerelease version
    if echo "${version}" | grep -E -- "-(alpha|beta|rc)\.[0-9]+" > /dev/null; then
        prerelease="true"
    else
        prerelease="false"
    fi

    # Remove the leading 'v' if present
    version="${version#v}"

    # Extract the MAJOR and MINOR components
    major="${version%%.*}"
    minor="${version#*.}"
    minor="${minor%%.*}"

    trimmed="${major}.${minor}"

    echo "Building docs for version ${trimmed}"
    echo "Prerelease: ${prerelease}"

    if git show-ref --quiet refs/heads/gh-pages ; then
        if [[ "${prerelease}" == "true" ]]; then
            mike deploy --push --update-aliases --rebase "${trimmed}"
        else
            mike deploy --push --update-aliases --rebase "${trimmed}" latest
        fi
    else
        mike deploy --push --update-aliases --rebase "${trimmed}" latest
        mike set-default --push latest
    fi

# Generate configuration for packer and terraform
config:
    #!/usr/bin/env bash
    set -e

    echo -n "Proxmox Address: "; read PM_ADDRESS
    echo -n "Proxmox Node: "; read PM_NODE
    echo -n "Proxmox User: "; read PM_USER
    echo -n "Proxmox Password (not echoed): "; read -s PM_PASS; echo ''
    echo -n "Storage for ISOs: "; read ISO_STORAGE
    echo -n "Storage for VMs: "; read VM_STORAGE
    echo -n "Template Prefix: "; read TEMPLATE_PREFIX

    mkdir -p ~/.config/{packer,terraform}/

    echo "Generating configuration files..."

    cat > ~/.config/packer/variables.pkrvars.hcl <<EOF
    # general configuration
    vm_prefix = "${TEMPLATE_PREFIX}" # prefix for all templates

    # proxmox specific configuration
    proxmox_addr     = "${PM_ADDRESS}" # address of the proxmox server
    proxmox_node     = "${PM_NODE}"    # node to use for building templates
    proxmox_username = "${PM_USER}"    # username to use for proxmox
    proxmox_password = "${PM_PASS}"    # password to use for proxmox
    iso_storage      = "${ISO_STORAGE}" # storage pool to use for ISOs
    EOF
    echo "Generated packer configuration file at ~/.config/packer/variables.pkrvars.hcl"

    cat > ~/.config/terraform/variables.tfvars <<EOF
    # proxmox specific configuration

    proxmox_addr     = "${PM_ADDRESS}" # address of the proxmox server
    proxmox_node     = "${PM_NODE}"    # node to use for building templates
    proxmox_username = "${PM_USER}"    # username to use for proxmox
    proxmox_password = "${PM_PASS}"    # password to use for proxmox
    storage          = "${VM_STORAGE}" # storage pool to use for VMs
    EOF
    echo "Generated terraform configuration file at ~/.config/terraform/variables.tfvars"

##########################################################################
# MAAS - Metal as a Service
#   This section contains all targets needed for deploying MAAS
#-------------------------------------------------------------------------

# Deploy MAAS (runs [maas_tpl maas_infra maas_up])
maas: maas_tpl maas_infra maas_up

# Create MAAS VM template
maas_tpl:
    cd templates && just build ubuntu-22.04

# Bring up MAAS infra
maas_infra:
    cd terraform && just plan maas-22.04 && just apply maas-22.04

# Instal MAAS on infra
maas_up:
    cd ansible && just maas

##########################################################################
# K3s - Simple, opinionated K3s cluster
#   This section contains all targets needed for deployment of opinionated
#   K3s cluster, including Rocky-9 hosts, Cilium CNI and others.
#-------------------------------------------------------------------------

# Deploy K3s cluster (runs [k3s_tpl k3s_infra k3s_infra_init k3s_up])
k3s: k3s_tpl k3s_infra k3s_infra_init k3s_up

# Create Rocky-9 template for K3s
k3s_tpl:
    cd templates && just build rocky-9

# Bring up K3s infra
k3s_infra:
    cd terraform && just plan rocky-9-k3s && just apply rocky-9-k3s

# Initialize infra for K3s deployment
k3s_infra_init:
    cd ansible && just k3s_inventory && just new_host

# Deploy K3s on infra
k3s_up:
    cd clusters && just k3s

# Deploy cilium on k3s
k3s_cilium:
    cd clusters && just cilium

# Deploy kured on K3s
k3s_kured SHOUTRR_URL:
    cd clusters && just kured_configure {{SHOUTRR_URL}}
    cd clusters && just kured
