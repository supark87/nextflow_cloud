#!/bin/bash -ue
bcftools mpileup -f 6genes2.fa 19ANBe00D0031PfFxxx0_S7_L001_SR.bam > 19ANBe00D0031PfFxxx0_S7_L001.mpileup
bcftools call -vm 19ANBe00D0031PfFxxx0_S7_L001.mpileup > 19ANBe00D0031PfFxxx0_S7_L001-1.vcf
gatk HaplotypeCaller -R /Users/subinpark/Downloads/nextflow_cloud/ref/pfalciparum/6genes2.fa -I 19ANBe00D0031PfFxxx0_S7_L001_SR.bam -O 19ANBe00D0031PfFxxx0_S7_L001-2.vcf
freebayes -f 6genes2.fa 19ANBe00D0031PfFxxx0_S7_L001_SR.bam > 19ANBe00D0031PfFxxx0_S7_L001-3.vcf
