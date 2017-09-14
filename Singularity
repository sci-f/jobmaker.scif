BootStrap: docker
From: python:3.5.1

#
# singularity create pokemon.img
# sudo singularity bootstrap pokemon.img Singularity
#

%help

This is an example for a container that on generation, calculates the runtime
for the runscript, and then writes a job file fitting to it. We also
provide several wrappers (colors, fortune) for customizing the runscript.
Given that metrics for running time and memory are being calculated where
the container is built, we assume that the build environment resources 
are comparable to the  running environment. The only requirements for
the running environments are that singularity is installed.
Each SCI-F app serves as a different entrypoint to run the container. 

# Generate on your own
git clone https://www.github.com/containers-ftw/jobmaker-ftw.git
cd jobmaker-ftw
make

# Here is how you can use the container after you build it:

# List all apps
singularity apps <container>

# Run a specific app
singularity run --app <app> <container>

# Loop over all apps
for app in $(singularity apps pokemon.img); do
    singularity run --app $app pokemon.img
done


%runscript

# This is the main analysis
max=10
for i in `seq 2 $max`
do
    /usr/local/bin/pokemon --catch "$@"
done

%files
catchemall.sh /catchemall.sh

%post    
    apt-get update && apt-get install -y git time lolcat fortune
    /usr/local/bin/pip install setuptools
    git clone https://www.github.com/vsoch/pokemon && cd pokemon
    /usr/local/bin/python setup.py install

    # Here we want to calculate different metrics for runtime, etc.
    TIME="TIME_HMS=%E\nMEMORY_KB=%M"
    export TIME

    chmod u+x /catchemall.sh
    /usr/bin/time -o times.txt /catchemall.sh
    IFS=''
    while read line
    do
    echo $line >> $SINGULARITY_ENVIRONMENT
    done < times.txt
    echo "export TIME_HMS MEMORY_KB" >> $SINGULARITY_ENVIRONMENT
    
%labels
CONTAINERSFTW_TEMPLATE scif-apps
CONTAINERSFTW_HOST containersftw
CONTAINERSFTW_NAME jobmaker-ftw
MAINTAINER Vanessasaur

%environment
# Global variables
DEBIAN_FRONTEND=noninteractive
export DEBIAN_FRONTEND

%apphelp sge

This will produce a submission script for sge.

    singularity run --app sge pokemon.img

# save to file

    singularity run --app sge pokemon.img  >> pokemon.job

# add other arguments

    singularity run --app sge pokemon.img -q normal

# Run

    qsub pokemon.job


%apprun sge
MEMORY_MB=$(echo "$(( ${MEMORY_KB%% *} / 1024))")
echo "#!/bin/bash"
echo "# run_pokemon.sh"
echo "module load singularity"
echo "singularity run $PWD/$SINGULARITY_CONTAINER"
echo "# submission command"
QUEUE="-q normal"
if [ $# -ne 0 ]
  then
    QUEUE=$1
fi
echo "# qsub $QUEUE -w e -N pokemon.job -l h_vmem=${MEMORY_MB}G -l h_rt=$TIME_HMS -o pokemon.out -e pokemon.err run_pokemon.sh"


%apphelp slurm

This will print (to the console) a slurm submission script
    singularity run --app slurm pokemon.img

# add your email
    singularity run --app slurm pokemon.img vsochat@stanford.edu

# save to file:
    singularity run --app slurm pokemon.img >> pokemon.job
    
# and then submit
    sbatch pokemon.job


%apprun slurm
MEMORY_MB=$(echo "$(( ${MEMORY_KB%% *} / 1024))")
echo "#!/bin/bash"
echo "#SBATCH --nodes=1"
echo "#SBATCH -p normal"
echo "#SBATCH --qos=normal"
echo "#SBATCH --mem=$MEMORY_MB"
echo "#SBATCH --job-name=pokemon.job"
echo "#SBATCH --error=%j.err"
echo "#SBATCH --output=%j.out"
if [ $# -ne 0 ]
  then
    echo "#SBATCH --mail-user=$1"
fi
echo "#SBATCH --mail-type=ALL"
echo "#SBATCH --time=$TIME_HMS"
echo "module load singularity"
echo "singularity run $PWD/$SINGULARITY_CONTAINER"
echo "# example: run the job script command line:"
echo "# sbatch pokemon.job"



%apphelp colors

    Generate your pokemon analysis with beautiful colors!
    singularity run --app colors pokemon.img

%apprun colors

    unset SINGULARITY_APPNAME
    exec /.singularity.d/actions/run | /usr/games/lolcat



%apphelp fortune

    Generate your pokemon analysis with a custom fortune for each one!
    singularity run --app fortune pokemon.img


%apprun fortune
    wisdom="$(/usr/games/fortune)"
    exec /usr/local/bin/pokemon --catch --message "$wisdom"
   

%apphelp catch
  
   Catch a pokemon!
   singularity run --app catch pokemon.img

%apprun catch
    exec /usr/local/bin/pokemon --catch


%apprun pokemon 
    /usr/local/bin/pokemon
