#########################################
# SciF Base
#
# docker build -t vanessa/jobmaker.scif .
# docker run vanessa/jobmaker.scif
#
#########################################

FROM continuumio/miniconda3

#########################################
# SciF Install

RUN mkdir /code
ADD . /code
RUN /opt/conda/bin/pip install scif

# Install the filesystem from the recipe
RUN scif install /code/jobmaker.scif

# SciF Entrypoint

ENTRYPOINT ["scif"]
