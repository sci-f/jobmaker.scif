run: clean build

clean:
	rm -f runjob.img

build: clean
	singularity create runjob.img
	sudo singularity bootstrap runjob.img Singularity
