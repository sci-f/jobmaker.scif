run: clean build

clean:
	rm -f pokemon.img

build: clean
	singularity create --size 2000 pokemon.img
	sudo singularity bootstrap pokemon.img Singularity
