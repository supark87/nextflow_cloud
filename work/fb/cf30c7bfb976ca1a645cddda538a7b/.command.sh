#!/bin/bash -ue
bbduk.sh -Xmx1g k=27 hdist=1 edist=1 ktrim=l in=19ANBe21D0017PfFxxx0_S36_L001_R1.fastq.gz in2=19ANBe21D0017PfFxxx0_S36_L001_R2.fastq.gz \
out=19ANBe21D0017PfFxxx0_S36_L001_trimmed_R1.fastq ref=adapters.fa \
qtrim=rl minlength=100 \
out2=19ANBe21D0017PfFxxx0_S36_L001_trimmed_R2.fastq stats=19ANBe21D0017PfFxxx0_S36_L001_stats.txt
