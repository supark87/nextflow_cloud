#!/bin/bash -ue
java -jar /usr/picard/picard.jar AddOrReplaceReadGroups -I 19ANBe28D0031PfFxxx0_S39_L001.sam -O 19ANBe28D0031PfFxxx0_S39_L001_SR.bam -SORT_ORDER coordinate --CREATE_INDEX true \
       -LB ExomeSeq -DS ExomeSeq -PL Illumina -CN AtlantaGenomeCenter -DT 2016-08-24 -PI null -ID 19ANBe28D0031PfFxxx0_S39_L001 \
       -PG 19ANBe28D0031PfFxxx0_S39_L001 -PM 19ANBe28D0031PfFxxx0_S39_L001 -SM 19ANBe28D0031PfFxxx0_S39_L001 -PU HiSeq2500
#java -jar /usr/picard/picard.jar CreateSequenceDictionary R=/Users/subinpark/Downloads/nextflow_cloud/ref/pfalciparum/6genes.fa O=/Users/subinpark/Downloads/nextflow_cloud/ref/pfalciparum/6genes.dict