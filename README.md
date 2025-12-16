# LXC Auto SSH to Host

Automated creation of SSH keys inside LXC containers and registration of the public keys on the Proxmox host.  
This allows LXC containers to securely control the Proxmox node via SSH (e.g. `pct start / stop / status`).

This project is intended for setups where one or more LXC containers act as **management or control instances**.

---

## Features

### 🔐 SSH Key Management
- Automatic generation of **ed25519 SSH keys** inside the LXC
- Automatic insertion of the public key into `authorized_keys` on the Proxmox host
- Correct permission handling (`700 ~/.ssh`, `600 authorized_keys`)
- **No `command="..."` forced command entries**  
  → remote SSH commands work normally

### 🧠 Proxmox Integration
- Native Proxmox `pct` usage over SSH
- LXC containers can control other containers on the node
- Privileges are handled exclusively via `sudoers`

### ⚙️ Fully Script-Based
- Clone the repository
- Run a single command with the **container ID**
- No manual configuration required

---

## Requirements

- Proxmox VE (node with `pct`)
- LXC containers (privileged or unprivileged)
- Root access on the Proxmox host
- Git installed

---

## Installation

### Clone the repository
```bash
git clone https://github.com/TimProg29/LXC_Auto_SSH_To_Host.git
cd LXC_Auto_SSH_To_Host
```

### Make scripts executable
```bash
chmod +x scripts/*.sh
```

---

## Usage

### Create an SSH key for an LXC container
```bash
sudo ./scripts/create-key.sh <LXC_ID> <KEY_NAME>
```

Example:
```bash
sudo ./scripts/create-key.sh 108 cloudkey
```

**Result:**
- SSH key is created inside the LXC at:
  ```
  /root/.ssh/cloudkey_ed25519
  ```
- Public key is added to:
  ```
  /home/lxcctl/.ssh/authorized_keys
  ```
- All permissions are set automatically

---

## Testing the Connection

Inside the LXC:
```bash
ssh -i /root/.ssh/cloudkey_ed25519 lxcctl@<PROXMOX_NODE_IP> "sudo pct list"
```

If no password is requested and the container list is shown, the setup is working correctly.

---

## Security & Design Decisions

- **No forced commands** in `authorized_keys`
- Authorization is handled via `/etc/sudoers.d/`
- Each LXC container uses its **own unique SSH key**
- Keys are clearly identifiable via comments:
  ```
  <keyname>@lxc-<id>
  ```

---

## Common Use Cases

- On-demand start/stop of LXC containers
- Central management containers
- Web UIs controlling other containers
- Automation and orchestration tasks

---

## Troubleshooting

### `Permission denied (publickey)`
- Verify the key exists in `authorized_keys`
- Check permissions:
```bash
chmod 700 /home/lxcctl/.ssh
chmod 600 /home/lxcctl/.ssh/authorized_keys
```

## License

MIT License
