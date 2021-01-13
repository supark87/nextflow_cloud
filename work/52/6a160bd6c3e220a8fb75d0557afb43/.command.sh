#!/bin/bash -ue
java -jar picard.jar AddOrReplaceReadGroups -I 19ANBe21D0094PfFxxx0_S43_L001.sam -O 19ANBe21D0094PfFxxx0_S43_L001_SR.bam -SORT_ORDER coordinate --CREATE_INDEX true \
-LB ExomeSeq -DS ExomeSeq -PL Illumina -CN AtlantaGenomeCenter -DT 2016-08-24 -PI null -ID 19ANBe21D0094PfFxxx0_S43_L001 \
-PG 19ANBe21D0094PfFxxx0_S43_L001 -PM 19ANBe21D0094PfFxxx0_S43_L001 -SM 19ANBe21D0094PfFxxx0_S43_L001 -PU HiSeq2500
