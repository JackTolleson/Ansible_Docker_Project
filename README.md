# Automated Container Orchestration Pipeline

Provisions a bare Linux VM into a running Kubernetes cluster serving a 
containerized Flask app — fully automated from a separate controller machine, 
with no manual steps on the target.

## Architecture

- **controller-vm** (Ubuntu) — runs Ansible
- **client-vm** (CentOS/RHEL, 192.168.56.101) — the provisioned target
- Connected over SSH on a VirtualBox host-only network

## What it does

1. `ansible/container-config.yml` provisions the client from scratch: installs 
   dependencies, adds the Docker CE repo, removes `podman-docker` (which 
   conflicts with Docker CE on RHEL-family systems), installs and starts Docker, 
   then installs MicroK8s via snap.
2. The Flask app is containerized with the included Dockerfile.
3. `ansible/deploy-containers.yml` applies a Kubernetes Deployment (10 replicas) 
   and a ClusterIP Service via `microk8s kubectl`.

See `screenshots/` for verification: Ansible play recaps, `docker ps`/`docker stats`, 
and `kubectl get all` showing 10/10 pods running behind the service.

## Stack
Ansible · Docker · Kubernetes (MicroK8s) · Flask · VirtualBox · RHEL/Ubuntu

## Notes

- **Credentials in `inventory.ini` are placeholders.** The original used plaintext 
  SSH and sudo passwords; a production setup should use SSH keys and Ansible Vault.
- VM creation and host-only network configuration are not automated here — they 
  were done manually before running the playbooks.
- Deployment uses `imagePullPolicy: IfNotPresent` since the image is built locally 
  on the target rather than pulled from a registry.
- Each VM uses two network adapters: NAT (internet access for package installs) and VirtualBox host-only (the 192.168.56.x private network the controller and client use to reach each other). The host-only interface must be brought up on the guest (ip link set enp0s8 up) before Ansible can connect.

## What I'd do differently

- SSH keys + Ansible Vault instead of plaintext credentials
- Push the image to a registry rather than building on the target
- Use Ansible's dedicated k8s module for applying manifests, rather than shelling out to kubectl with a heredoc
- Add readiness/liveness probes to the Deployment
