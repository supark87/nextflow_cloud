#!/bin/bash -ue
java -Xmx8g -jar /tmp/snpEff/snpEff.jar build -c data/snpEff.config -v -gff3 6genes2
#java -Xmx8g -jar /tmp/snpEff/snpEff.jar build -c data/snpEff.config -v -gff3 6genes2
#java -Xmx8g -jar /tmp/snpEff/snpEff.jar build -c data/snpEff.config -v -gff3 6genes2

java -Xmx8g -jar /tmp/snpEff/snpEff.jar -c data/snpEff.config 6genes2 19ANBe00D0009PfFxxx0_S1_L001-1.vcf > 19ANBe00D0009PfFxxx0_S1_L001-1.ann.vcf
java -Xmx8g -jar /tmp/snpEff/snpEff.jar -c data/snpEff.config 6genes2 19ANBe00D0009PfFxxx0_S1_L001-1.vcf > 19ANBe00D0009PfFxxx0_S1_L001-2.ann.vcf
java -Xmx8g -jar /tmp/snpEff/snpEff.jar -c data/snpEff.config 6genes2  19ANBe00D0009PfFxxx0_S1_L001-1.vcf > 19ANBe00D0009PfFxxx0_S1_L001-3.ann.vcf
