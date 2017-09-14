# JobMaker FTW

This is an example container to provide an executable (in this case, a fun
printing of 500 pokemon) to be run in different contexts:

 - on a slurm cluster
 - on an sge cluster
 - locally


## Building the image
Let's first build the container. You can use the Makefile to build the image:

```
make

# Does make clean followed by make build
```

or manually:

```
singularity create runjob.img
sudo singularity bootstrap runjob.img Singularity
```

## Running the Image

And now run it. This should perform the container's main function, calling it's runscript:

```
singularity run runjob.img 
```

Works great! But then what if we wanted to know what tools (SCI-F apps) come with the
container? That's easy to do:

```
 singularity apps metrics.img 

sge
slurm
color
```
