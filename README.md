# Ansible Playbooks for setting up Kubernetes on CentOS 6.6/RHEL 6.6

A modified fork of [eparis' Fedora/RHEL 7 playbooks](https://github.com/eparis/kubernetes-ansible) that supports setting up Kubernetes on CentOS 6.6/RHEL 6.6 , with a [flannel](https://github.com/coreos/flannel)-based overlay network. These playbooks do not use RPMs for Kubernetes/etcd. Instead they download release archives directly from github. Please note that these playbooks are a work in progress and there are several imporvements still to be made.  

## Requirements

### 'Control' host
On a host designated to 'manage' the cluster (could be your laptop): 
1. install git, sshpass and ansible (1.8.2+) 
2. clone this repo 

### 'Managed' hosts
On the cluster where Kubernetes is being setup:

1. All hosts have CentOS 6.6/RHEL 6.6 (linux kernel 2.6.32-504)
2. root access via ssh (either through a root password or a pem file) 
3. iptables/firewalls stopped to begin with. Alternatively, permissive rules need to be in place for access to various Kubernetes components, docker (for host to port forwarding), flanneld and any other ports that may be required for applications being run on the cluster. Currently, these playbooks do not support the automatic addition of such permissive rules.   

## Setup Instructions

### Inventory of hosts
1. Gather the hostnames/IPs of all the hosts you'll be using to run the cluster - and designate a host as the master, a host as the etcd server and the rest as minions/kubernetes nodes.
2. Create an inventory file (a sample inventory file is included in this repo) using this information. Each minion/node will need an assigned range of IPs that can be used to assign to the pods being spun up. Alternatively, you can stick the IPs/hostnames into a file and use the `generate_sample_inventory.sh` script to generate a sample inventory file. 

### Setting up access to hosts

1. Specify the root password in `~/rootpassword` (Alternatively, you can provide a pem file - edit `keys.yml` accordingly) 
2. Host Key Checking : In order to avoid an 'interactive' setup, all the host keys need to already be in the `known_hosts` file. If you have never accessed these hosts before :
   * You can configure ansible to bypass host key checking. See [here](http://docs.ansible.com/intro_getting_started.html#host-key-checking) for more information. 
   * run `ansible-playbook -i inventory ping.yml`. This will look like it fails. See keys.yml for an explanation and other options.  
3. If necessary, generate an RSA key-pair (use `ssh-keygen`) and ensure that the public key file is located in `~/.ssh/id_rsa.pub`. Push your public key to all hosts by running : `ansible-playbook -i inventory keys.yml`

### Setting up Kubernetes

1. edit `group_vars/all.yml` to setup/change default settings. Ensure'fake' IP addresses are specified for use with Kubernetes services. This range of IPs shouldn't conflict with anything already in use in your network infrastructure. 
2. run `ansible-playbook -i inventory flannel.yml setup.yml` . This will install and bring up Kubernetes components (`cadvisor` setup is not in place yet) 

## Interacting with the Kubernetes cluster

1. Download and extract a Kubernetes release archive corresponding to the version installed on the cluster. See [here](https://github.com/GoogleCloudPlatform/kubernetes/releases) for a list of releases. 
2. Use the `kubectl` binary to talk to the API master. Some examples : 

```
$ kubernetes/bin/platforms/darwin/amd64/kubectl get nodes -s 172.22.113.46:8080
NAME                LABELS
192.168.96.98       <none>
192.168.96.95       <none>
192.168.96.96       <none>
192.168.96.97       <none>
$ kubernetes/bin/platforms/darwin/amd64/kubectl get services -s 172.22.113.46:8080
NAME                LABELS                                    SELECTOR            IP                  PORT
kubernetes-ro       component=apiserver,provider=kubernetes   <none>              10.246.192.168      80
kubernetes          component=apiserver,provider=kubernetes   <none>              10.246.90.4         443
$
```

