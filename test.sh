#!/bin/bash
#SBATCH --job-name=nest_test
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH --mem=3G
#SBATCH -o nn_o
#SBATCH -e nn_e



#TOWER_ACCESS_TOKEN=eyJ0aWQiOiAzMjE0fS5mNGUwODAxYzZkNTYyZGQ4YjE4OTMxZTBkYmU4NTZmMjYwYTM2MzVj
docker run -v /var/run/docker.sock:/var/run/docker.sock -v $PWD:$PWD -w $PWD --rm -i nextflow/nextflow nextflow run trim1testVCF_SP_untilannotate.nf -c nextflow.config -with-docker container -with-tower
#docker run -v /var/run/docker.sock:/var/run/docker.sock -v $(pwd):/data1/  -t nextflow/nextflow nextflow run /data1/trim1testVCF_SP_untilannotate.nf -c /data1/nextflow.config -with-docker container
#nextflow run trim1testVCF_SP_untilannotate.nf -with-docker container
#docker run -v /var/run/docker.sock:/var/run/docker.sock -v $(pwd):/data/ -i nextflow/nextflow nextflow run /data/trim1testVCF_SP_untilannotate.nf -c /data/nextflow.config -with-docker container
