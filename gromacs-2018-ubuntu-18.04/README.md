# Install Gromacs 2018 with GPU Support

Gromacs is a Molecular Dynamics framework which allow perform simulations in share and distributed memory systems using MPI library.

**Requirements**:

* CUDA Toolkit 10.0
* OpenMPI

### Compile and Install Gromacs

```sh
sudo apt-get install libfftw3-dev
sudo apt-get install cmake
wget http://ftp.gromacs.org/pub/gromacs/gromacs-2018.tar.gz
tar xfz gromacs-2018.tar.gz
cd gromacs-2018
mkdir build
cd build
cmake .. 
	-DGMX_GPU=ON 
	-DGMX_MPI=ON 
	-DCUDA_TOOLKIT_ROOT_DIR=/usr/local/cuda 
	-DCMAKE_CXX_COMPILER=mpic++ 
	-DCMAKE_C_COMPILER=mpicc 
	-DGMX_BUILD_OWN_FFTW=ON
make
make check
sudo make install
source /usr/local/gromacs/bin/GMXRC
```

Create a symlink to use gmx command on behalf of gmx_mpi

```sh
sudo ln -s /usr/local/gromacs/bin/gmx_mpi /usr/bin/gmx_mpi
```

To remove the symlink you can perform

```sh
sudo unlink /usr/bin/gmx
```

### Uninstall Gromacs

```sh
sudo apt-get remove gromacs
```

Installation folders 

```sh
/usr/local/gromacs/bin/gmx_mpi
/usr/local/gromacs/bin
/usr/local/gromacs/bin/gmx-completion.bash
/usr/local/gromacs/bin/gmx-completion-gmx_mpi.bash
```

Remove /usr/local/gromacs this will remove all instation folders.

```sh 
rm -rf /usr/local/gromacs
```

# References

- [Manual Gromacs](http://manual.gromacs.org/documentation/2018/install-guide/index.html)
- [GPU acceleration](http://www.gromacs.org/GPU_acceleration)
- [Compiled GPU-ACCELERATED GROMACS](https://www.nvidia.com/en-us/data-center/gpu-accelerated-applications/gromacs/)
- [Acceleration and parallelization](http://www.gromacs.org/Documentation/Acceleration_and_parallelization#GPU_acceleration)
- [nvidia-smi: Control Your GPUs](https://www.microway.com/hpc-tech-tips/nvidia-smi_control-your-gpus/)
- [Compile Gromacs to detect GPU](https://www.researchgate.net/post/Gromacs_514_installation_errors)




