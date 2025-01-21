# artic-grex-setup

## Prerequisites

```
git clone https://github.com/phac-nml/ncov2019-artic-nf
```

to your desired project location. Clone this repo too lol.


## 1. Build Singularity containers

This repository contains a script, `make-sif.sh`, designed to automate the creation of Singularity containers from `base-conda.def` and environment files.

Build containers for all environments .yml, for nanopore build artic env using [artic-network/fieldbioinformatics v1.2.4 environment.yml](https://github.com/artic-network/fieldbioinformatics/blob/v1.2.4/environment.yml) or the artic.yml in this repo.

Make the following additional modifications to copied env files:
- add "name: " at the head of each env file such that conda envs can be created with a name inside singularity containers
- add "pdflatex" to ncovtools environment
- *if runninbg make-sif,sh, create a file named environment.yml 

Create overlay image file for "writable" ncovtools container:

```
dd if=/dev/zero of=overlay.img bs=1M count=500 && \
    mkfs.ext3 overlay.img
```


## 2. Modify covid pipeline env

- add singularity.config to /conf & change the path
- add singularity modification to nextflow.config

```
    singularity {
        singularity.enabled    = true
        singularity.autoMounts = true
        includeConfig 'conf/singularity.config'
        docker.enabled         = false
        podman.enabled         = false
        shifter.enabled        = false
        charliecloud.enabled   = false
    }
```

- add ncov-config/ and config file for running report generation

## 3. Run covid pipeline modified job script

See `covid-job.sh`, modify paths: PROJECT_DIR and DATA_DIR. Singularity cache use work/singularity in pipeline project dir, place containers there too.
