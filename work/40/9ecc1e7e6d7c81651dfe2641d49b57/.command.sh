#!/bin/bash -ue
bowtie2 --very-sensitive  --dovetail --met-file 19ANBe28D0010PfFxxx0_S34_L001_bmet.txt -p 1 \
-x /Users/subinpark/Downloads/from_jehoon/local/Mars_test/Bowtie2Index/genome.index \
-1 19ANBe28D0010PfFxxx0_S34_L001_trimmed_R1.fastq -2 19ANBe28D0010PfFxxx0_S34_L001_trimmed_R2.fastq -p 4 -S 19ANBe28D0010PfFxxx0_S34_L001.sam
