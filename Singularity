BootStrap: docker
From: python:3.5.1

#
# singularity create runjob.img
# sudo singularity bootstrap runjob.img Singularity
#

%help

This is an example for a container that on generation, calculates the runtime
for the runscript, and then writes a job file fitting to it. We assume that
the build environment resources are comparable to the running environment. 
Each SCI-F app serves as a different entrypoint to run the container. Here
is how you can use the container after you build it:

# List all apps
singularity apps <container>

# Run a specific app
singularity run --app <app> <container>

# Loop over all apps
for app in $(singularity apps metrics.img); do
    singularity run --app $app metrics.img
done


%runscript
    for i in {1..500}
    do
       /usr/bin/pokemon --catch
    done
    
%post    
    apt-get update && apt-get install -y git
    git clone https://www.github.com/vsoch/pokemon && cd pokemon
    python setup.py install


%labels
CONTAINERSFTW_TEMPLATE scif-apps
CONTAINERSFTW_HOST containersftw
CONTAINERSFTW_NAME jobmaker-ftw
MAINTAINER Vanessasaur

%environment
# Global variables
DEBIAN_FRONTEND=noninteractive
export DEBIAN_FRONTEND
