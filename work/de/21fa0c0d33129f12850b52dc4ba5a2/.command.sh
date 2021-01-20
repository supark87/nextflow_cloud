#!/bin/bash -ue
bowtie2 --very-sensitive  --dovetail --met-file 19ANBe21D0094PfFxxx0_S43_L001_bmet.txt -p 1 \
-x /Users/subinpark/Downloads/nextflow_cloud/local/Mars_test6genes2/Bowtie2Index/genome.index \
-1 19ANBe21D0094PfFxxx0_S43_L001_trimmed_R1.fastq -2 19ANBe21D0094PfFxxx0_S43_L001_trimmed_R2.fastq -p 4 -S 19ANBe21D0094PfFxxx0_S43_L001.sam
