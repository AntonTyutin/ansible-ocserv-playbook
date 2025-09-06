# VPN Server Infrastructure with Ansible

This repository contains Ansible playbooks for deploying and managing a complete VPN server infrastructure using OpenConnect (ocserv), HAProxy load balancer, and automated SSL certificate management with ACME.sh.

## Project Overview

This project automates the deployment of:
- **OpenConnect VPN Server (ocserv)** - Enterprise-grade VPN solution
- **HAProxy** - High-performance load balancer and SSL termination
- **ACME.sh** - Automated SSL certificate management with Let's Encrypt
- **Security hardening** - UFW firewall, fail2ban, and system security
- **User management** - Automated VPN user creation and static IP assignment

## Prerequisites

- Docker and Docker Compose (for containerized Ansible execution)
- SSH access to target servers
- Domain names configured to point to your server
- Vault password for encrypted variables

## Quick Start

1. **Clone and setup**:
```bash
git clone <repository-url>
cd ansible
```

2. **Configure your inventory**:
```bash
cp inventory/hosts.yml.example inventory/hosts.yml
# Edit inventory/hosts.yml with your server details
```

3. **Set vault password**:
```bash
export VAULT_PASS="your-vault-password"
```

4. **Deploy the infrastructure**:
```bash
make play
```

## Architecture

The project deploys a two-tier architecture:

### 1. Generic Server Setup (`all` hosts)
- **Security role**: UFW firewall, fail2ban, SSH hardening
- **Common role**: User creation, SSH key setup, NAT configuration
- **Facts role**: System information gathering

### 2. VPN Server Setup (`vpns` hosts)
- **ocserv role**: OpenConnect VPN server with latest version compilation
- **haproxy role**: Load balancer with SSL termination
- **acme.sh role**: Automated SSL certificate management

## Available Make Commands

- `make vendor` - Install all required Ansible roles
- `make shell` - Open interactive shell in Ansible container
- `make play` - Deploy the complete infrastructure
- `make dry-run` - Test deployment without making changes

## Configuration

### Inventory Structure

The `inventory/hosts.yml` file defines two host groups:

```yaml
all:           # All servers (generic setup)
  hosts:
    server1:      # Your server
      ansible_host: xxx.xxx.xxx.xxx
      ansible_user: user

vpns:          # VPN servers only
  hosts:
    server1:      # Same server with VPN-specific config
      acme_domains: [...]
      ocserv_users: [...]
      haproxy_config_routes_web: [...]
```

### VPN User Configuration

Users are defined in the inventory with support for:
- **Static IP assignment** - Each user gets a dedicated IP range
- **Password authentication** - Encrypted passwords using Ansible Vault
- **Certificate authentication** - Optional client certificates

Example user configuration:
```yaml
ocserv_users:
  - name: router-user
    ipv4_network: 10.100.200.0
    ipv4_netmask: 255.255.255.252
    password: !vault |
      $ANSIBLE_VAULT;1.1;AES256
      [encrypted-password]
```

### SSL Certificate Management

ACME.sh automatically manages SSL certificates for:
- **VPN domain** - Main VPN access domain
- **Web services** - Additional domains for web applications
- **Auto-renewal** - Certificates are automatically renewed

### HAProxy Configuration

HAProxy provides:
- **SSL termination** - Handles HTTPS/TLS for all services
- **Load balancing** - Routes traffic to backend services
- **Web and TCP routing** - Supports both HTTP and raw TCP connections

## Roles Overview

### Custom Roles

- **`acme.sh`** - SSL certificate automation with Let's Encrypt
- **`ocserv`** - OpenConnect VPN server deployment and configuration
- **`haproxy`** - Load balancer setup with SSL termination
- **`security`** - System hardening and firewall configuration
- **`common`** - Basic system setup and user management
- **`facts`** - System information gathering

### External Roles

- **`geerlingguy.security`** - Comprehensive security hardening
- **`robertdebock.fail2ban`** - Intrusion prevention system

## Security Features

- **UFW Firewall** - Restrictive default policy with specific allow rules
- **Fail2ban** - Automatic IP blocking for failed login attempts
- **SSH Hardening** - Disabled root login, key-based authentication only
- **NAT Configuration** - Proper IP forwarding for VPN traffic
- **Encrypted Secrets** - All passwords stored in Ansible Vault

## Network Configuration

The VPN server creates a virtual network interface (`vpns`) with:
- **IP Range**: 10.100.10.0/24 (configurable)
- **Static IPs**: Per-user IP assignments
- **DNS**: Google (8.8.8.8) and Cloudflare (1.1.1.1) DNS servers
- **Routing**: Full tunnel mode (all traffic through VPN)

## Usage Examples

### Deploy to all servers:
```bash
make play
```

### Test configuration without changes:
```bash
make dry-run
```

### Access Ansible container for debugging:
```bash
make shell
```

### Update VPN users:
1. Edit `inventory/hosts.yml`
2. Add/remove users in `ocserv_users` section
3. Run `make play`

## File Structure

```
├── playbook.yml              # Main deployment playbook
├── inventory/
│   ├── hosts.yml            # Server inventory and configuration
│   └── group_vars/          # Group-specific variables
├── roles/
│   ├── acme.sh/             # SSL certificate management
│   ├── ocserv/              # VPN server configuration
│   ├── haproxy/             # Load balancer setup
│   ├── security/            # Security hardening
│   ├── common/              # Basic system setup
│   └── facts/               # System information
├── files/                   # Static files (CA certificates, etc.)
├── vendors/                 # External Ansible roles
├── docker-compose.yml       # Container configuration
├── Dockerfile              # Ansible container image
└── Makefile                # Build and deployment commands
```

## License

This project is licensed under the MIT License.
