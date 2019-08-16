# Install Docker and Docker Nvidia for GPU Support

Docker is a containerization solution which allow containers management. GPU support can be enabled into these containers installing nvidia-docker.

**Requirements**

* Ubuntu 18.04   (installed)  
* Nvidia Drivers (installed)

### Install Docker

We will install the Ubuntu Distribution of Docker [```(docker-ce 18.06.1~ce~3-0~ubuntu)```](https://download.docker.com/linux/ubuntu/dists/bionic/pool/stable/amd64/docker-ce_18.06.1~ce~3-0~ubuntu_amd64.deb). Download the .deb package and install docker.

```sh
wget https://download.docker.com/linux/ubuntu/dists/bionic/pool/stable/amd64/docker-ce_18.06.1~ce~3-0~ubuntu_amd64.deb
sudo dpkg -i docker-ce_18.06.0_ce_3-0_ubuntu_amd64.deb
sudo groupadd docker
sudo usermod -aG docker $USER
sudo service docker restart
sudo reboot now
```

### Install NVIDIA Docker

Add [nvidia-docker2](https://nvidia.github.io/nvidia-docker/) Debian repository

```sh
sudo apt-get install curl
curl -s -L https://nvidia.github.io/nvidia-docker/gpgkey | \
  sudo apt-key add -

distribution=$(. /etc/os-release;echo $ID$VERSION_ID)

curl -s -L https://nvidia.github.io/nvidia-docker/$distribution/nvidia-docker.list | \
  sudo tee /etc/apt/sources.list.d/nvidia-docker.list

sudo apt-get update
```

Install nvidia-docker2

```sh
sudo apt-get install nvidia-docker2
sudo reboot now
```

If nvidia-docker2 install does not work try with the following command: More details here 

```sh
sudo apt-get install -y nvidia-docker2=2.0.3+docker18.06.1-1 nvidia-container-runtime=2.0.0+docker18.06.1-1
sudo reboot now
```

### Tests Docker with the NVIDIA runtime to deploy GPU applications

```sh
docker run --runtime=nvidia --rm nvidia/cuda nvidia-smi

+-----------------------------------------------------------------------------+
| NVIDIA-SMI 390.48             	Driver Version: 390.48                |
|-------------------------------+----------------------+----------------------+
| GPU  Name    	Persistence-M| Bus-Id    	Disp.A | Volatile Uncorr. ECC |
| Fan  Temp  Perf  Pwr:Usage/Cap|     	Memory-Usage | GPU-Util  Compute M.   |
|===============================+======================+======================|
|   0  Quadro K2200    	Off  | 00000000:01:00.0 Off |              	N/A   |
| 42%   43C	P0 	2W /  39W |	175MiB /  4043MiB |  	0%  	Defaul|
+-------------------------------+----------------------+----------------------+
                                                                          	 
+-----------------------------------------------------------------------------+
| Processes:                                                   	GPU Memory    |
|  GPU   	PID   Type   Process name                         	Usage |
|=============================================================================|
|	0  	2682  	G   /usr/lib/xorg/Xorg                       	101MiB|
|	0  	2855  	G   /usr/bin/gnome-shell                      	70MiB |
+-----------------------------------------------------------------------------+
```

# References

- [Nvidia Docker](https://github.com/NVIDIA/nvidia-docker)
- [Nvidia Docker Container Registry](https://ngc.nvidia.com/catalog/landing)
- [Docker Container Registry](https://cloud.docker.com/)