# Install Open MPI with Fortran Support

Install Fortran 

```sh 
sudo apt install gfortran 
```

```sh 
gfortran --version 
```

Install OpenMPI

```sh
wget https://download.open-mpi.org/release/open-mpi/v3.1/openmpi-3.1.2.tar.gz
tar -xzvf openmpi-3.1.2.tar.gz 
cd openmpi-3.1.2/
./configure --enable-mpi-fortran --prefix=/opt/openmpi-3.1.2
make 
sudo make install 
```

Check MPI instalation

```sh 
mpicc 
mpifort 
```