#!/bin/bash -ue
samtools index 19ANBe28D0009PfFxxx0_S33_L001_SR.bam
python /Users/subinpark/Downloads/nextflow_cloud/annotate.py -r /Users/subinpark/Downloads/nextflow_cloud/ref/pfalciparum/6genes2.fa -b /Users/subinpark/Downloads/nextflow_cloud/6genes2.bed -o 19ANBe28D0009PfFxxx0_S33_L001 -v1 19ANBe28D0009PfFxxx0_S33_L001-1.ann.vcf -v2 19ANBe28D0009PfFxxx0_S33_L001-2.ann.vcf -v3 19ANBe28D0009PfFxxx0_S33_L001-3.ann.vcf -m 19ANBe28D0009PfFxxx0_S33_L001_SR.bam -voi /Users/subinpark/Downloads/nextflow_cloud/ref/pfalciparum/Reportable_SNPs.csv -name 19ANBe28D0009PfFxxx0_S33_L001
