#!/bin/bash

# Script to create multiple VMs for OpenClaw endpoint simulation

NUM_VMS=3
VM_PREFIX="openclaw-vm"
BASE_DIR="/var/lib/libvirt/images"
ISO_URL="https://releases.ubuntu.com/22.04.3/ubuntu-22.04.3-live-server-amd64.iso"
ISO_PATH="$BASE_DIR/ubuntu-22.04.3.iso"

# Ensure base directory exists
sudo mkdir -p "$BASE_DIR"

# Download Ubuntu ISO if not already downloaded
if [ ! -f "$ISO_PATH" ]; then
  echo "Downloading Ubuntu ISO..."
  sudo wget -O "$ISO_PATH" "$ISO_URL"
fi

# Create VMs
for i in $(seq 1 $NUM_VMS); do
  VM_NAME="$VM_PREFIX-$i"
  VM_DISK="$BASE_DIR/$VM_NAME.qcow2"
  
  echo "Creating VM: $VM_NAME"
  
  # Create disk image
  sudo qemu-img create -f qcow2 "$VM_DISK" 10G
  
  # Install VM with virt-install
  sudo virt-install \
    --name "$VM_NAME" \
    --ram 2048 \
    --vcpus 2 \
    --disk path="$VM_DISK",format=qcow2 \
    --os-type linux \
    --os-variant ubuntu22.04 \
    --network network=default \
    --graphics vnc,listen=0.0.0.0 \
    --noautoconsole \
    --location "$ISO_PATH" \
    --extra-args "autoinstall ds=nocloud-net;s=http://_gateway:3003/"
  
  echo "VM $VM_NAME created. Use 'virsh list --all' to check status."
done

echo "All VMs created. After installation, configure SSH access and update inventory.yaml with VM IPs."
