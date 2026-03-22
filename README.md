# OpenClaw Multi-Machine Deployment with Ansible

This project provides a framework for deploying OpenClaw across multiple machines using Ansible. It is designed to be scalable, allowing for easy expansion beyond the initial three nodes (Mac, Ubuntu, Windows).

## Project Overview

The goal of this project is to deploy OpenClaw on multiple machines with unique API keys per node, managed from a central controller machine. The deployment includes setting up a monitoring dashboard, security configurations, and skill permissions.

## Checklist Phases

### Phase 0: Goal Confirmation
- Define the goal: Deploy OpenClaw on 3 computers (Mac, Ubuntu, Windows).
- Identify the controller machine (running Ansible).
- Define dashboard requirements (Token usage, Skill invocation, Status).
- Confirm unique API keys for each machine.

### Phase 1: Environment Preparation (Controller)
- Install Ansible on the controller machine (Ubuntu or Mac).
- Create the project folder `ansible-openclaw`.

### Phase 2: Ansible Project Structure
- Set up the project structure:
  ```
  ansible-openclaw/
  ├── inventory.yaml
  ├── deploy_openclaw.yaml
  ├── remove_openclaw.yaml
  ├── templates/
  │   └── OpenClaw.json.j2
  ├── host_vars/
  │   ├── node1.yaml
  │   ├── node2.yaml
  │   ├── node3.yaml
  │   └── example.yaml
  └── scripts/
      └── create_vms.sh
  ```

### Phase 3: Key and Configuration Management
- Define unique API keys for each node in `host_vars/nodeX.yaml`.
- Create a JSON template (`OpenClaw.json.j2`) with variable placeholders for keys and skills.
- Configure default skills (enable/disable).

### Phase 4: Deploy OpenClaw
- Write `deploy_openclaw.yaml` playbook to:
  - Install Docker.
  - Create `/opt/openclaw` directory (or `C:\OpenClaw` on Windows).
  - Copy configuration files.
  - Start the OpenClaw container.
- Execute deployment with: `ansible-playbook -i inventory.yaml deploy_openclaw.yaml`

### Phase 5: Deployment Validation
- Verify on each machine:
  - OpenClaw is running.
  - API key is correct.
  - Skills are operational.
  - Test a simple task (e.g., file operation or API call).

### Phase 6: Monitoring System
- Install Prometheus on the controller for metrics collection.
- Install Grafana for visualization.
- Connect Prometheus to node metrics endpoints.
- Set up dashboards for Token usage, Skill calls, Error rate, and Task count.

### Phase 7: Security and Permissions
- Manage API keys with Ansible Vault.
- Disable high-risk skills (e.g., filesystem, browser).
- Define allowed functionalities per node.
- (Advanced) Design data filtering and restrict external API transmission.

### Phase 8: Management Interface (Advanced)
- Develop a simple Web Dashboard to:
  - Display status of each OpenClaw instance.
  - Show Token and Skill usage.
  - Support remote configuration updates.
  - Allow permission toggling.

## Node Machine Preparation

### Mac / Ubuntu Nodes
- Enable SSH (`sudo systemctl enable ssh` and `sudo systemctl start ssh` on Ubuntu; enable 'Remote Login' in System Preferences on Mac).
- Verify SSH access from the controller.

### Windows Nodes
- Install OpenSSH Server or enable WinRM (`Enable-PSRemoting -Force` in PowerShell).
- Test remote connection from the controller.

### Connectivity Test
- Update `inventory.yaml` with actual node IPs and usernames.
- Run `ansible all -m ping -i inventory.yaml` to confirm connectivity.

## Scaling Beyond Three Nodes

To expand the deployment to more than three machines:
1. Add new nodes to `inventory.yaml` under `openclaw_nodes` group. Example:
   ```yaml
   node4:
     ansible_host: 192.168.1.104  # Replace with actual IP
     ansible_user: user4          # Replace with actual username
   ```
2. Create corresponding `host_vars/node4.yaml` with unique API key and skill settings.
3. The `deploy_openclaw.yaml` playbook will automatically apply to all nodes listed in `inventory.yaml`.

## Simulation with Docker Containers

To test the deployment process without real machines, we simulated three endpoints using Docker containers:
- **Setup**: Created three Docker containers (`node1-sim`, `node2-sim`, `node3-sim`) to mimic real endpoints, each accessible via SSH on different ports (2221, 2222, 2223).
- **Deployment**: Updated `inventory.yaml` to include these simulated endpoints and used Ansible to deploy OpenClaw configuration files to each container.
- **Result**: Successfully simulated the deployment process, including unique API key assignment per endpoint and configuration file distribution. Note that OpenClaw service startup was simulated due to nested Docker limitations.
- **Limitations**: This simulation validates the Ansible workflow but does not run actual OpenClaw instances. For real task execution, deploy to physical or cloud machines.

## Attempted Deployment to Real Windows Endpoint

An attempt was made to deploy OpenClaw to a real Windows endpoint (IP: 192.168.50.202):
- **Challenges**: Encountered persistent connection issues using both WinRM and SSH, despite successful local SSH access and ping tests from the controller.
- **Issues**: Ansible failed to create temporary directories, indicating potential permission or configuration issues with SSH/WinRM on Windows.
- **Outcome**: Due to unresolved connectivity problems, automated deployment via Ansible was not successful.
- **Recommendation**: Manual deployment of OpenClaw on the Windows endpoint is advised as a workaround.

### Manual Deployment Steps for Windows
1. **Install Docker Desktop** (if not already installed):
   - Download and install from the Docker official website (https://www.docker.com/products/docker-desktop).
   - Ensure Docker Desktop is running.
2. **Create Directory `C:\OpenClaw`**:
   - Create a directory for OpenClaw configuration files.
3. **Create Configuration File `C:\OpenClaw\OpenClaw.json`**:
   - Copy the following content to `C:\OpenClaw\OpenClaw.json`, replacing `openai_key` with your actual API key:
     ```json
     {
       "api": {
         "openai": {
           "key": "your-actual-api-key"
         }
       },
       "skills": {
         "filesystem": false,
         "browser": false
       }
     }
     ```
4. **Run OpenClaw Container**:
   - Open Command Prompt (cmd) or PowerShell and run:
     ```
     docker run -d --name openclaw --restart always -v C:\OpenClaw:C:\app\config -p 8080:8080 openclaw/openclaw:latest
     ```
5. **Verify OpenClaw is Running**:
   - Check if the container is running:
     ```
     docker ps
     ```
   - Access `http://192.168.50.202:8080` (if a web interface is available) or interact with OpenClaw as needed.

## Final Completion Criteria
- OpenClaw running simultaneously on all target machines.
- One-click deployment/update via Ansible.
- Unique and securely managed API keys per node.
- Dashboard available for usage monitoring.
- Basic skill permission controls in place.

## Usage

1. Update `inventory.yaml` with actual node IPs and usernames.
2. Set real API keys in `host_vars/nodeX.yaml` files. **Important**: Do NOT commit files with real API keys to version control. Use `host_vars/example.yaml` as a reference to create your own configuration files, and consider adding `host_vars/` to `.gitignore` or using Ansible Vault for encryption.
3. Run connectivity test: `ansible all -m ping -i inventory.yaml`.
4. Deploy OpenClaw: `ansible-playbook -i inventory.yaml deploy_openclaw.yaml`.

## Removal of OpenClaw

To remove OpenClaw from nodes, use the provided playbook:
- Execute removal with: `ansible-playbook -i inventory.yaml remove_openclaw.yaml`
- Or limit to specific node: `ansible-playbook -i inventory.yaml remove_openclaw.yaml --limit <node-name>`

For further assistance or customization, refer to the OpenClaw documentation or contact support.
