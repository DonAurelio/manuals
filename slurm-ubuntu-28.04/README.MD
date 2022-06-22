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

To add GPU support, we first create a file gres.conf in `/etc/slurm-llnl/`

```sh
Name=gpu File=/dev/nvidia0
Name=gpu File=/dev/nvidia1
Name=gpu File=/dev/nvidia2
```

Then, we add GresTypes=gpu into `/etc/slurm-llnl/slurm.conf`. Next, we add the GPU information to slurm.conf

```sh
NodeName=node1 Gres=gpu:3 State=UNKNOWN
```

# Install JupytherHub in the cluster headnode

```sh
apt install python3-pip
```

```sh
python3 -m pip install jupyterhub
```

```sh
npm install -g configurable-http-proxy
```

```sh
jupyterhub -h
```

```sh
configurable-http-proxy -h
```

```sh
jupyterhub --generate-config
```

```sh
nano jupyterhub_config.py
```

```sh
jupyterhub --ip=10.0.0.2
```

## References 

1. [How to quickly set up Slurm on Ubuntu 20.04 for single node workload scheduling.](https://drtailor.medium.com/how-to-setup-slurm-on-ubuntu-20-04-for-single-node-work-scheduling-6cc909574365)
2. [Set up Slurm across Multiple Machines](https://www.bodunhu.com/blog/posts/set-up-slurm-across-multiple-machines/)

3. [Running Jupyter on Slurm GPU Nodes
](https://nero-docs.stanford.edu/jupyter-slurm.html)

4. [Using Jupyter Notebooks to manage SLURM jobs](https://www.kth.se/blogs/pdc/2019/01/using-jupyter-notebooks-to-manage-slurm-jobs/)

5. [JupyterHub](https://jupyterhub.readthedocs.io/en/stable/quickstart.html)

6. [Configure the Hub if the Proxy or Spawners are remote or isolated](https://jupyterhub.readthedocs.io/en/stable/getting-started/networking-basics.html#configure-the-hub-if-the-proxy-or-spawners-are-remote-or-isolated)