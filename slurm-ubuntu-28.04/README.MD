# Install Slurm Cluster (Ubuntu 20.04)

We need to configure first computing nodes hostnames and add these names to the /etc/hosts file.

```sh
nano /etc/hostname
```

Hosts hostnames must be added to the /etc/hosts file on evevry node.

```sh
nano /etc/hosts
```

Update the master and slave installation scripts. Add the information of all the nodes in the computing nodes section. 

```sh
# COMPUTE NODES
NodeName=galaxy-1 CPUs=1 RealMemory=500 State=UNKNOWN
PartitionName=local Nodes=ALL Default=YES MaxTime=INFINITE State=UP
```

Once you have executed the `master.sh` and `slave.sh` scripts you will need to copy the munge key `/etc/munge/munge.key` from the master node to every slave computing node and gratt the appropriate permissions.

```sh
chown -R munge:munge /etc/munge/munge.key
chmod 0600 /etc/munge/munge.key
```

At the end you will need to restart the services

```sh 
systemctl restart munge
systemctl restart slurmctld 
systemctl restart slurmd
```