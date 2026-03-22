#!/bin/bash

# Manual deployment script for OpenClaw to Windows endpoint
# This script logs detailed output for debugging connection issues

LOG_FILE="/home/admin/.openclaw/workspace/ansible-openclaw/manual_deploy_log_$(date +%Y%m%d_%H%M%S).txt"
INVENTORY_FILE="/home/admin/.openclaw/workspace/ansible-openclaw/inventory.yaml"
PLAYBOOK_FILE="/home/admin/.openclaw/workspace/ansible-openclaw/deploy_openclaw.yaml"
TARGET="windows-endpoint"

# Function to log messages
echo_log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

# Start logging
echo_log "Starting manual deployment script for OpenClaw to $TARGET"

# Check if sshpass is installed
echo_log "Checking for sshpass installation..."
if ! command -v sshpass &> /dev/null; then
    echo_log "sshpass not found. Installing sshpass..."
    sudo apt update && sudo apt install -y sshpass 2>&1 | tee -a "$LOG_FILE"
    if [ $? -ne 0 ]; then
        echo_log "ERROR: Failed to install sshpass. Please install it manually."
        exit 1
    fi
fi

# Test basic SSH connection
echo_log "Testing SSH connection to $TARGET..."
sshpass -p '356356' ssh -o "StrictHostKeyChecking=no" -o "UserKnownHostsFile=/dev/null" user@192.168.50.202 "echo 'SSH connection successful'" 2>&1 | tee -a "$LOG_FILE"
if [ $? -eq 0 ]; then
    echo_log "SSH connection test successful."
else
    echo_log "ERROR: SSH connection test failed. Check network, SSH service, or credentials."
    exit 1
fi

# Test Ansible ping
echo_log "Testing Ansible ping to $TARGET..."
ansible $TARGET -m ping -i "$INVENTORY_FILE" -vvv 2>&1 | tee -a "$LOG_FILE"
if [ $? -eq 0 ]; then
    echo_log "Ansible ping test successful."
else
    echo_log "ERROR: Ansible ping test failed. Check the detailed log above for errors."
    exit 1
fi

# Run Ansible playbook for deployment
echo_log "Running Ansible playbook to deploy OpenClaw to $TARGET..."
ansible-playbook -i "$INVENTORY_FILE" "$PLAYBOOK_FILE" --limit "$TARGET" -vvv 2>&1 | tee -a "$LOG_FILE"
if [ $? -eq 0 ]; then
    echo_log "Deployment successful. Check the log for details."
else
    echo_log "ERROR: Deployment failed. Check the detailed log above for errors."
fi

echo_log "Manual deployment script completed. Log saved to $LOG_FILE"

echo "Script execution completed. Please check the log file at $LOG_FILE and share the output for further diagnosis if needed."
