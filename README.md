# Salt Service Deployment Lab

> A guide to deploying automated web services using SaltStack

## Project Overview

In this project, you'll design and implement Salt states to manage packages, services, and files. The team will work together to design, document, and implement an automated workflow that provisions a lightweight web service that displays a custom landing page, such as "Welcome to the HPC Internship Cluster."

## Project Deliverables

At the end of this project you should have:
- Salt state files that install and configure a web service
- A custom HTML landing page deployed automatically
- Automated firewall configuration for HTTP access

## Setup & Requirements

You will need:
- At least 2 Linux VMs (1 Salt master, 1+ minions)
- Everything will need to be ran as `root` or with `sudo`
- VMs with internet connectivity for downloading the packages
- SSH daemon running on all VMs (for easy copy/paste and file transfer)
- **Tip:** When creating the root password, select "Allow root SSH" if available

---

## Step 1: Spin Up VMs and Open Ports

1. **Install RHEL OS** using your favorite hypervisor
   - **Note:** If using non-RHEL distributions (Debian/Ubuntu), you'll need to edit the `init.sls` file and change the Apache service from `httpd` to `apache2`

2. **Set machine names**
   - One will be `salt-master`
   - Others will be `salt-minion(s)`

3. **Optional: Set hostnames**
   ```bash
   hostnamectl set-hostname salt-master
   # Or on minions:
   hostnamectl set-hostname salt-minion1
   ```

4. **On the master, open required ports**
   ```bash
   firewall-cmd --permanent --zone=public --add-port=4505/tcp
   firewall-cmd --permanent --zone=public --add-port=4506/tcp
   firewall-cmd --reload
   ```

---

## Step 2: Installing Salt and Enabling Services

### On Both VMs

**Note: view the updated repo documentation if using DEB packages https://saltproject.io/blog/salt-project-package-repo-migration-and-guidance/ <<< Link for info
1. **Install the Salt repository**
   ```bash
   curl -fsSL https://github.com/saltstack/salt-install-guide/releases/latest/download/salt.repo | sudo tee /etc/yum.repos.d/salt.repo && sudo dnf clean expire-cache
   ```

2. **Optional: Configure repository to use latest release**
   ```bash
   dnf config-manager --set-disable salt-repo-*
   dnf config-manager --set-enabled salt-repo-latest
   ```

### On the Master

1. **Install salt-master**
   ```bash
   dnf install salt-master -y
   ```

2. **Edit the master configuration**
   ```bash
   vi /etc/salt/master
   ```
   
   **Master Configuration Example:**
   ```yaml
   # Uncomment and configure the following lines:
   interface: 0.0.0.0
   
   # Optional but recommended settings:
   user: salt
   auto_accept: True
   file_roots:
     base:
       - /srv/salt
   ```
3. **Give salt permissions**
   ```bash
   chown -R salt:salt /etc/salt/
   ```

4. **Enable and start the service**
   ```bash
   systemctl enable salt-master
   systemctl start salt-master
   ```

5. **Verify the service is running**
   ```bash
   systemctl status salt-master
   ```

### On the Minion(s)

1. **Install salt-minion**
   ```bash
   dnf install salt-minion -y
   ```

2. **Edit the minion configuration**
   ```bash
   vi /etc/salt/minion
   ```
   
   **Minion Configuration Example:**
   ```yaml
   # Change the master line to point to your salt-master IP:
   master: <your-salt-master-IP>
   ```

3. **Give salt permissions**
   ```bash
   chown -R salt:salt /etc/salt/ 
   ```

4. **Enable and start the service**
   ```bash
   systemctl enable salt-minion
   systemctl start salt-minion
   ```

5. **Verify the service is running**
   ```bash
   systemctl status salt-minion
   ```

---

## Step 3: Accept the Salt Key

1. **On the salt-master, check for unaccepted keys**
   ```bash
   salt-key -L
   ```
   
   You should see your minion(s) under "Unaccepted Keys"
   - If you don't see your minion, check firewall rules and logs

2. **Accept the salt key**
   ```bash
   salt-key -A
   ```
   
   Enter `Y` to accept the key(s)

---

## Step 4: Test the Connection

**From the master, run:**
```bash
salt '*' test.ping
```

**Expected output:**
```
salt-minion1:
    True
```

---

## Step 5: Get the Salt State Files

1. **Ensure the Salt directory exists on the master**
   ```bash
   mkdir -p /srv/salt
   ```

2. **Transfer files from your local machine**
   ```bash
   scp -r /path/to/local/file root@your-master-vm-ip:/srv/salt
   ```
   
   Example:
   ```bash
   scp init.sls root@192.168.1.100:/srv/salt/
   scp index.html root@192.168.1.100:/srv/salt/
   ```

3. **SSH into the master and set permissions**
   ```bash
   ssh master-vm-username@your-master-vm-ip
   chown -R salt:salt /srv/salt
   ```

---

## Step 6: Applying the Salt State

1. **Test the state application (dry run)**
   ```bash
   salt '*' state.apply init test=True
   ```
   
   Verify you get **"Failed: 0"**

2. **Apply the state for real**
   ```bash
   salt '*' state.apply init
   ```

---

## Step 7: View Webpage on Local Machine

Open your browser and navigate to:
```
http://<minion-IP>
```

## Troubleshooting
I had issues with permissions, and connecting the master and minion. Make sure the versions are the same on the master and minion(s). Salt repo has moved to <packages.broadcom.com> and old packages have been decomissioned
## Update
You can use virt-manager GUI but I found it easier to use virsh. Once the OS is installed I cloned the VM inside virt-manager and set the hostnames. Then I got the mac addresses using 
```bash
sudo virsh domifaddr 'your-vm-name'
```
Then you can set the static ip's using
```bash
sudo virsh net-edit 'your-network-name'
```
Here is a sample network xml file
```xml
<network>
  <name>default</name>
  <uuid>9a05da11-e96b-47f3-8253-a3a482e445f5</uuid>
  <forward mode='nat'/>
  <bridge name='virbr0' stp='on' delay='0'/>
  <mac address='52:54:00:0a:cd:21'/>
  <ip address='192.168.122.1' netmask='255.255.255.0'>
    <dhcp>
      <range start='192.168.122.2' end='192.168.122.254'/>
      <host mac='52:54:00:f1:ca:d8' name='master' ip='192.168.122.80'/>
      <host mac='52:54:00:c1:36:f3' name='minion' ip='192.168.122.81'/>
    </dhcp>
  </ip>
</network>
```
Lastly you want to make sure the vm's are powered off and reinitialize the network by destroying and restarting the network
```bash
sudo virsh net-destroy 'your-network-name'
sudo virsh net-start 'your-network-name'
```
Now you should be able to ssh into each vm with the creds you made and the static ip's you have set
**Example**
```bash
ssh root@192.168.122.80
```
## Modified to use pillar
In /srv your file system should look like this
```bash
.
├── pillar
│   ├── top.sls
│   └── webserver
│       └── init.sls
└── salt
    ├── firewall.sls
    ├── index.html.jinja
    ├── init.sls
    └── top.sls
```
