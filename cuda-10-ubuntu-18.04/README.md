# Install CUDA - Ubuntu 18.04

Compute Unified Device Architecture (CUDA) is a Nvidia GPU architecture and Library to perform general purpose computations in Nvidia GPUs. To install CUDA libraries, the nvidia gpu driver is required. 

On this manual we will:

* Install Nvidia GPU driver compatible with CUDA 10
* Install CUDA 10
* Other method to install Nvidia GPU driver

### Install Nvidia GPU driver nvidia-driver-410

You can install the nvidia recomended drivers as follows:

```sh
sudo apt install aptitude
sudo apt-key adv --fetch-keys  http://developer.download.nvidia.com/compute/cuda/repos/ubuntu1804/x86_64/7fa2af80.pub
sudo bash -c 'echo "deb http://developer.download.nvidia.com/compute/cuda/repos/ubuntu1804/x86_64 /" > /etc/apt/sources.list.d/cuda.list'
sudo apt update
sudo aptitude install nvidia-driver-410
sudo reboot now
```

### Check the driver is working properly

Check if the driver works properly performing the nvidia-smi command

```sh 
nvidia-smi

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

### Install NVIDIA CUDA 10.0

Install CUDA Toolkit

```sh
wget https://developer.nvidia.com/compute/cuda/10.0/Prod/local_installers/cuda_10.0.130_410.48_linux
```

Give permission to the executable and run the installation script

```sh
chmod +x cuda_10.0.130_410.48_linux
```

You can install Cuda 10 in non insterative mode using the following command

```sh 
sudo ./cuda_10.0.130_410.48_linux --silent --toolkit --samples --override
```

Or use the interactive mode  

```sh
sudo ./cuda_10.0.130_410.48_linux.run


Do you accept the previously read EULA?
accept/decline/quit: accept

Install NVIDIA Accelerated Graphics Driver for Linux-x86_64 410.48?
(y)es/(n)o/(q)uit: n

Install the CUDA 10.0 Toolkit?
(y)es/(n)o/(q)uit: y

Enter Toolkit Location
 [ default is /usr/local/cuda-10.0 ]: 

Do you want to install a symbolic link at /usr/local/cuda?
(y)es/(n)o/(q)uit: y

Install the CUDA 10.0 Samples?
(y)es/(n)o/(q)uit: y

Enter CUDA Samples Location
 [ default is /home/mpiuser ]: 

```

Place the CUDA environment variables in the *.bashrc* file of your current user

```sh 
nano ~/.bashrc
```

Paste the env variables at the end of the file 

```sh
export PATH=$PATH:/usr/local/cuda-10.0/bin
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/local/cuda-10.0/lib64
```

Reboot your system

```sh
sudo reboot now
```

### Install Nvidia GPU driver nvidia-driver-390

The nvidia-driver-390 driver is not compatible with CUDA 10.0. If you require CUDA 10. Plese get into the following section. You can install the nvidia recomended drivers as follows:

Check the nvidia available drivers in the Ubuntu Repository.

```sh
ubuntu-drivers devices


== /sys/devices/pci0000:00/0000:00:01.0/0000:01:00.0 ==
modalias : pci:v000010DEd000013BAsv000010DEsd00001097bc03sc00i00
vendor   : NVIDIA Corporation
model	: GM107GL [Quadro K2200]
driver   : nvidia-driver-390 - distro non-free recommended
driver   : nvidia-340 - distro non-free
driver   : xserver-xorg-video-nouveau - distro free builtin

```

The recomended drivers is the **nvidia-driver-390** so you can install the driver using the follwing command

```sh 
sudo apt install nvidia-driver-390
sudo reboot now
```

# References

- [How do I install NVIDIA and CUDA drivers into Ubuntu? - Ask Ubuntu.](https://askubuntu.com/questions/1077061/how-do-i-install-nvidia-and-cuda-drivers-into-ubuntu)
- [Ubuntu 18.04, CUDA 10.0 and NVIDIA 410 drivers](https://askubuntu.com/questions/1077061/how-do-i-install-nvidia-and-cuda-drivers-into-ubuntu)
- [How to install CUDA 9.2 on Ubuntu 18.04](https://www.pugetsystems.com/labs/hpc/How-to-install-CUDA-9-2-on-Ubuntu-18-04-1184/)
- [The Best Way To Install Ubuntu 18.04 with NVIDIA Drivers and any Desktop Flavor](https://www.pugetsystems.com/labs/hpc/The-Best-Way-To-Install-Ubuntu-18-04-with-NVIDIA-Drivers-and-any-Desktop-Flavor-1178/)
