## Usage

Auf der Proxmox-Node:

```bash
git clone https://github.com/TimProg29/LXC_Auto_SSH_To_Host lxc-ssh-bootstrap
cd lxc-ssh-bootstrap
chmod +x scripts/*.sh
sudo ./scripts/create-key.sh <LXC_ID> <KEY_NAME>
