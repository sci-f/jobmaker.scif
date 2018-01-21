run: clean build

clean:
	rm -f jobmaker

build: clean
	sudo singularity build jobmaker Singularity
