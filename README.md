# JobMaker Scientific Filesystem

This is an example container to provide an executable (in this case, a fun
printing of pokemon) to be run in different contexts:

 - run with custom variables (fortune)
 - run in a different context (eg, a color filter)
 - run on a slurm cluster
 - run on an sge cluster
 - run locally

The general idea is that a main function (the pokemon executable) can be 
provided in different contexts, or with different (optional) modular 
contexts for the user. For each context or helper, there
is a custom set of environment, or labels, along with commands and metadata. If
you want to skip the science part and just play with Pokemon, there is a [separate
set of containers](https://vsoch.github.io/2018/pokemon/) (Docker and Singularity) for that.


## Building the image
Let's first build the container. You can use the Makefile to build the image:

```
make
# Does make clean followed by make build
```

or manually:

```
sudo singularity build jobmaker Singularity
```

## Running the Image

And now run it. This should perform the container's main function, calling it's runscript:

```
./jobmaker
```

You will see an army of Pokemon ascii print to the screen. Works great! But now we want to capture metrics about this primary function. First we would want to know what tools (SCIF apps) come with the
container. That's easy to do:

```
./jobmaker apps
     catch
    colors
   fortune
      main
       sge
     slurm
```


We can ask for help for the container, this is Singularity specific.

```
singularity help jobmaker 

This is an example for a container with a Scientific Filesystem
that on generation, calculates the runtime for the runscript, 
and then writes a job file fitting to it. We also provide 
several wrappers (colors, fortune) for customizing the runscript.
Given that metrics for running time and memory are being calculated where
the container is built, we assume that the build environment resources 
are comparable to the running environment. The only requirements for
the running environments are that singularity is installed.
Each SCIF app serves as a different entrypoint to run the container. 

    # Generate on your own
    git clone https://www.github.com/sci-f/jobmaker.scif
    cd jobmaker.scif
    make

    # Here is how you can use the container after you build it:

    # List all apps
    ./jobmaker apps

    # Run a specific app
    ./jobmaker run <app>

    # Loop over all apps
    for app in $(./jobmaker apps); do
      ./jobmaker run $app
    done

```

### Running an application
Remember the list of apps? We don't know what they do. So first you might want to ask for help

```
./jobmaker help
Usage: scif help <hello-world>
```

```
./jobmaker help slurm
This will print (to the console) a slurm submission script
./jobmaker run slurm
./jobmaker run slurm vsochat@stanford.edu
./jobmaker run slurm >> pokemon.job
sbatch pokemon.job
```

You can also look at the metadata in detail with inspect

```
./jobmaker inspect slurm

```

and then run it!

```
./jobmaker run slurm
[slurm] executing /bin/bash /scif/apps/slurm/scif/runscript
#!/bin/bash
#SBATCH --nodes=1
#SBATCH -p normal
#SBATCH --qos=normal
#SBATCH --mem=16
#SBATCH --job-name=pokemon.job
#SBATCH --error=%j.err
#SBATCH --output=%j.out
#SBATCH --mail-type=ALL
#SBATCH --time=0:00.82
module load singularity
singularity run /scif/apps/main/jobmaker
# example: run the job script command line:
# sbatch pokemon.job
```

The reason this works is because the slurm application sources environment variables for memory and time needed that were calculated when the container was built. Since this is a job, we can pipe the output easily into a file, and we will add `--quiet` to suppress the first information line.

```
./jobmaker --quiet run slurm >> myjob.job
```

## Advanced
What variables are exposed to each app at runtime? Let's look at the environment of the active application (e.g., slurm) when it's running. We will split this into two pieces to show the "general active application" environment, followed by the named application environment (that is also defined for apps that aren't active!)

```
./jobmaker exec slurm env | grep slurm
[slurm] executing /usr/bin/env 
SCIF_APPDATA=/scif/data/slurm
SCIF_APPRUN=/scif/apps/slurm/scif/runscript
SCIF_APPRECIPE=/scif/apps/slurm/scif/slurm.scif
SCIF_APPNAME_slurm=slurm
SCIF_APPROOT=/scif/apps/slurm
SCIF_APPNAME=slurm
SCIF_APPLIB=/scif/apps/slurm/lib
SCIF_APPMETA=/scif/apps/slurm/scif
SCIF_APPBIN=/scif/apps/slurm/bin
SCIF_APPHELP=/scif/apps/slurm/scif/runscript.help
SCIF_APPTEST=/scif/apps/slurm/scif/test.sh
SCIF_APPENV=/scif/apps/slurm/scif/environment.sh
```
```
SCIF_APPLIB_slurm=/scif/apps/slurm/lib
SCIF_APPMETA_slurm=/scif/apps/slurm/scif
SCIF_APPBIN_slurm=/scif/apps/slurm/bin
SCIF_APPHELP_slurm=/scif/apps/slurm/scif/runscript.help
SCIF_APPENV_slurm=/scif/apps/slurm/scif/environment.sh
SCIF_APPLABELS_slurm=/scif/apps/slurm/scif/labels.json
SCIF_APPTEST_slurm=/scif/apps/slurm/scif/test.sh
SCIF_APPDATA_slurm=/scif/data/slurm
SCIF_APPRUN_slurm=/scif/apps/slurm/scif/runscript
SCIF_APPLABELS=/scif/apps/slurm/scif/labels.json
SCIF_APPRECIPE_slurm=/scif/apps/slurm/scif/slurm.scif
SCIF_APPROOT_slurm=/scif/apps/slurm
```
Importantly, notice that the bin and lib are added to their respective paths, to be found!

```
LD_LIBRARY_PATH=/scif/apps/slurm/lib:/.singularity.d/libs
PWD=/scif/apps/slurm
PATH=/scif/apps/slurm/bin:/opt/conda/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
```

And guess what? Even when slurm is running (and other apps like sge are sleeping) we can still find the other apps! Let's look for sge (when slurm is running):

```
./jobmaker exec slurm env | grep sge
SCIF_APPHELP_sge=/scif/apps/sge/scif/runscript.help
SCIF_APPENV_sge=/scif/apps/sge/scif/environment.sh
SCIF_APPLABELS_sge=/scif/apps/sge/scif/labels.json
SCIF_APPTEST_sge=/scif/apps/sge/scif/test.sh
SCIF_APPDATA_sge=/scif/data/sge
SCIF_APPRUN_sge=/scif/apps/sge/scif/runscript
SCIF_APPRECIPE_sge=/scif/apps/sge/scif/sge.scif
SCIF_APPROOT_sge=/scif/apps/sge
SCIF_APPNAME_sge=sge
SCIF_APPLIB_sge=/scif/apps/sge/lib
SCIF_APPMETA_sge=/scif/apps/sge/scif
SCIF_APPBIN_sge=/scif/apps/sge/bin
```

This is why I'm able to quickly execute another app runscript:

```
exec SCIF_APPRUN_sge
```

or source an environment

```
source SCIF_APPENV_sge
```

without needing to know the path or details. I can also just target the active app, whatever that may be, doing the same without the specified name. For example, let's say I have a script to perform some machine learning task on the main runscript file. It would be located at `SCIF_APPRUN`.

