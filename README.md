# JobMaker FTW

This is an example container to provide an executable (in this case, a fun
printing of 500 pokemon) to be run in different contexts:

 - on a slurm cluster
 - on an sge cluster
 - locally
 - run with custom variables (fortune)
 - run in a different context (eg, a color filter)

The general idea is that a main function can be provided in different contexts, or with
different (optional) modular contexts for the user. For each context or helper, there
is a custom set of environment, or labels, along with commands and metadata.


[![asciicast](https://asciinema.org/a/137743.png)](https://asciinema.org/a/137743?speed=3)

For an interactive example, watch the asciinema above.

## Building the image
Let's first build the container. You can use the Makefile to build the image:

```
make

# Does make clean followed by make build
```

or manually:

```
singularity create pokemon.img
sudo singularity bootstrap pokemon.img Singularity
```

## Running the Image

And now run it. This should perform the container's main function, calling it's runscript:

```
singularity run pokemon.img 
```

Works great! But then what if we wanted to know what tools (SCI-F apps) come with the
container? That's easy to do:

```
singularity apps pokemon.img
catch
colors
fortune
pokemon
sge
slurm
```

or ask the container for help:

```
singularity help pokemon.img

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
```

### Running an application
First you might want to ask for help

```
singularity help --app slurm pokemon.img 
This will print (to the console) a slurm submission script
singularity run --app slurm pokemon.img
# add your email
singularity run --app slurm pokemon.img vsochat@stanford.edu
# save to file:
singularity run --app slurm pokemon.img >> pokemon.job
# and then submit
sbatch pokemon.job
```

and then run it!

```
#!/bin/bash
#SBATCH --nodes=1
#SBATCH -p normal
#SBATCH --qos=normal
#SBATCH --mem=21
#SBATCH --job-name=pokemon.job
#SBATCH --error=%j.err
#SBATCH --output=%j.out
#SBATCH --mail-type=ALL
#SBATCH --time=0:01.10
module load singularity
singularity run /home/vanessa/Desktop/jobmaker-ftw/pokemon.img
# example: run the job script command line:
# sbatch pokemon.job
```


## Advanced
What variables are exposed to each app at runtime?

```
singularity exec --app fortune  pokemon.img env | grep SINGULARITY
SINGULARITY_APPOUTPUT=/scif/data/fortune/output
SINGULARITY_APPDATA=/scif/data/fortune
SINGULARITY_APPBASE=/scif/apps/fortune
SINGULARITY_APPINPUT=/scif/data/fortune/input
SINGULARITY_APPROOT=/scif/apps/fortune
SINGULARITY_APPNAME=fortune
SINGULARITY_CONTAINER=pokemon.img
SINGULARITY_APPMETA=/scif/apps/fortune/scif
SINGULARITY_NAME=pokemon.img
```

What about the entire container (not just for singularity)

```
singularity exec --containall --app slurm  pokemon.img env

SINGULARITY_APPOUTPUT=/scif/data/slurm/output
PYTHON_PIP_VERSION=8.1.2
LD_LIBRARY_PATH=/scif/apps/slurm/lib::/.singularity.d/libs
HOME=/home/vanessa
PS1=Singularity> 
TERM=xterm-256color
SINGULARITY_APPDATA=/scif/data/slurm
PATH=/scif/apps/slurm/bin:/scif/apps/slurm:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
SINGULARITY_APPBASE=/scif/apps/slurm
SINGULARITY_APPINPUT=/scif/data/slurm/input
SINGULARITY_APPROOT=/scif/apps/slurm
LANG=C.UTF-8
TIME_HMS=0:01.10
DEBIAN_FRONTEND=noninteractive
SINGULARITY_APPNAME=slurm
PYTHON_VERSION=3.5.1
MEMORY_KB=21668
SINGULARITY_CONTAINER=pokemon.img
PWD=/home/vanessa
SINGULARITY_APPMETA=/scif/apps/slurm/scif
SINGULARITY_NAME=pokemon.img
```
