params.reads = params.input.fastq_path+'*{R1,R2}*.fastq.gz'
fastq_path = Channel.fromFilePairs(params.reads, size: -1)
fasta_path = Channel.fromPath(params.input.fasta_path)
out_path = Channel.fromPath(params.output.folder)
bed_path = Channel.fromPath(params.input.bed_path)
variant_path = Channel.fromPath(params.input.variant_path)
bbduk_path = "$params.input.bbduk_def"
params.genome = "$baseDir/ref/pfalciparum/6genes2.fa"
params.bed = "$baseDir/ref⁩/pfalciparum⁩/6genes2.bed"
params.fas = "$baseDir/ref/pfalciparum/adapters.fa"
params.gatk= "$baseDir/gatk-4.1.9.0/gatk"
configfiles="$baseDir/data"
pyscripts="$baseDir/pyscripts"
ct_table="$baseDir/ct_table"
mode = "$params.input.mode"
vcfmode = "$params.input.vcfmode"



process combineFastq {
    container 'tools:latest'

    publishDir "$params.output.folder/trimFastq/${pair_id}", pattern: "*.fastq.gz", mode : "copy"
    input:
        set val(pair_id), path(fastq_group) from fastq_path

    
    output:
        tuple val(pair_id), path("${pair_id}_R1.fastq.gz"), path("${pair_id}_R2.fastq.gz") into comb_out

    script:
        """
        cat *R1_001.fastq.gz > ${pair_id}_R1.fastq.gz
        cat *R2_001.fastq.gz > ${pair_id}_R2.fastq.gz
        """

}

comb_out.into{preqc_path; trim_path}

process preFastQC {
    container 'tools:latest'

    publishDir "$params.output.folder/preFastqQC/${sample}", mode : "copy"
    input:
        set val(sample), path(read_one), path(read_two) from preqc_path
    
    output:
        tuple val(sample), path("*") into preqc_out
    
    script:
        """
        fastqc --extract -f fastq -o ./ -t $task.cpus ${read_one} ${read_two}
        """
}

process trimFastq {
    container 'tools:latest'

    publishDir "$params.output.folder/trimFastq/${sample}", pattern: "*.fastq", mode : "copy"
    publishDir "$params.output.folder/trimFastq/${sample}/Stats", pattern: "*.txt", mode : "copy"
    input:
        set val(sample), path(read_one), path(read_two) from trim_path
        path fas from params.fas
    
    output:
        tuple val(sample), path("${sample}_trimmed_R1.fastq"), path("${sample}_trimmed_R2.fastq"), path("${sample}_*.txt") into trim_out

    script:
        """
        bbduk.sh -Xmx1g k=27 hdist=1 edist=1 ktrim=l in=${read_one} in2=${read_two} \\
        out=${sample}_trimmed_R1.fastq ref=${fas} \\
        qtrim=rl minlength=100 \\
        out2=${sample}_trimmed_R2.fastq stats=${sample}_stats.txt 
        """
}

trim_out.into{align_path; postqc_path}

process postFastQC {

    container 'tools:latest'

    publishDir "$params.output.folder/postFastqQC/${sample}", mode : "copy"
    input:
        set val(sample), path(read_one), path(read_two), path(stats_path) from postqc_path
    
    output:
        tuple val(sample), path("*") into postqc_out
    
    script:
        """
        fastqc --extract -f fastq -o ./ -t $task.cpus ${read_one} ${read_two}
        """
}

process buildIndex {
    container 'tools:latest'
   
    tag "$genome.baseName"
    publishDir "$params.output.folder/Bowtie2Index", mode : "copy"

    input:
    path genome from params.genome

    output:
    file 'genome.index*' into index_ch

    script:
    if( mode == 'Bowtie')
    """
    bowtie2-build ${genome} genome.index
    """
}



process alignReads {
    container 'tools:latest'

    publishDir "$params.output.folder/alignedReads/${sample}", pattern: "*.sam", mode : "copy"
    publishDir "$params.output.folder/alignedReads/${sample}/Stats", pattern: "*.txt", mode : "copy"
    input:
        set val(sample), path(read_one), path(read_two), path(stats_path) from align_path
        file index from index_ch
        path genome from params.genome
    
    output:
        tuple val(sample), path("${sample}.sam"), path("${sample}_bmet.txt") into align_out

    script:
        index_base = index[0].toString() - ~/.rev.\d.bt2?/ - ~/.\d.bt2?/
        if( mode == 'Bowtie')
            """
            bowtie2 --very-sensitive  --dovetail --met-file ${sample}_bmet.txt -p $task.cpus \\
            -x $baseDir/$params.output.folder/Bowtie2Index/$index_base \\
            -1 ${read_one} -2 ${read_two} -p 4 -S ${sample}.sam 
            """
        else if( mode == 'Bwa' )
            """
            bwa mem -t 4 ${genome} ${read_one} ${read_two} > ${sample}.sam 
            """
        else if( mode == 'BBMap' )
            """
            bbmap ref=${genome} in=${read_one} in2=${read_two} out=${sample}.sam 
            """
        else if( mode == 'Snap' )
            """
            snap paired ${genome} ${read_one} ${read_two} -t 4 -o -sam ${sample}.sam $task.cpus \\
            """
}

process processAlignments {
    container 'broadinstitute/picard'

    publishDir "$params.output.folder/alignedReads/${sample}", pattern: "*.ba*", mode : "copy"
    input:
        set val(sample), path(sam_path), path(align_met) from align_out
        path genome from params.genome
    
    output:
        tuple val(sample), path("${sample}_SR.bam") into postal_out
        tuple val(sample), path("${sample}_SR.bam") into postal_out2
        tuple val(sample), path("${sample}_SR.bam") into postal_out3
        tuple val(sample), path("${sample}_SR.bam") into postal_out4
        tuple val(sample), path("${sample}_SR.bam") into postal_out5
	
    script:
        """
        java -jar /usr/picard/picard.jar AddOrReplaceReadGroups -I ${sam_path} -O ${sample}_SR.bam -SORT_ORDER coordinate --CREATE_INDEX true \\
        -LB ExomeSeq -DS ExomeSeq -PL Illumina -CN AtlantaGenomeCenter -DT 2016-08-24 -PI null -ID ${sample} \\
        -PG ${sample} -PM ${sample} -SM ${sample} -PU HiSeq2500
	#java -jar /usr/picard/picard.jar CreateSequenceDictionary R=$baseDir/ref/pfalciparum/6genes.fa O=$baseDir/ref/pfalciparum/6genes.dict
        """
    
}

process GenerateVCF {
    container 'supark87/tools2'
    publishDir "$params.output.folder/GenerateVCFSam/${sample}", pattern: "*.vcf", mode : "copy"
    input:
        set val(sample), path(bam_path) from postal_out
        path genome from params.genome

    output:
        tuple val(sample), path("${sample}-1.vcf"), path("${sample}-2.vcf"), path("${sample}-3.vcf") into vcf_out1

    script:
        """
        bcftools mpileup -f ${genome} ${bam_path} > ${sample}.mpileup
        bcftools call -vm ${sample}.mpileup > ${sample}-1.vcf
        gatk HaplotypeCaller -R $baseDir/ref/pfalciparum/6genes2.fa -I ${bam_path} -O ${sample}-2.vcf
        freebayes -f ${genome} ${bam_path} > ${sample}-3.vcf
        """
}




process annotate {
    container 'supark87/snpeff'
    publishDir "$params.output.folder/annotate/${sample}", mode : "copy"
    errorStrategy 'ignore'


    input:
        set val(sample), path(vcf_path1), path(vcf_path2), path(vcf_path3) from vcf_out1
        path(configpath) from configfiles
    output:
        tuple val(sample), path("${sample}-1.ann.vcf"), path("${sample}-2.ann.vcf"),path("${sample}-3.ann.vcf") into anno_out1 
       // tuple val(sample), path("${sample}-1.ann.vcf"), path("${sample}-2.ann.vcf"),path("${sample}-3.ann.vcf") into anno_out2 

    script:
        """
        java -Xmx8g -jar /tmp/snpEff/snpEff.jar -c ${configpath}/snpEff.config 6genes2 ${vcf_path1} > ${sample}-1.ann.vcf
        java -Xmx8g -jar /tmp/snpEff/snpEff.jar -c ${configpath}/snpEff.config 6genes2 ${vcf_path2} > ${sample}-2.ann.vcf
        java -Xmx8g -jar /tmp/snpEff/snpEff.jar -c ${configpath}/snpEff.config 6genes2  ${vcf_path3} > ${sample}-3.ann.vcf
  
        """

}

process vartpype {
    container 'supark87/snpeff'
    publishDir "$params.output.folder/vartype/${sample}", mode : "copy"
    //errorStrategy 'ignore'


    input:
        set val(sample), path(vcf_path1), path(vcf_path2), path(vcf_path3) from anno_out1

    output:
        tuple val(sample), path("${sample}_1.vartype.vcf"), path("${sample}_2.vartype.vcf"), path("${sample}_3.vartype.vcf") into vartype_out1

    script:
        """
        java -jar /tmp/snpEff/SnpSift.jar varType ${vcf_path1} > ${sample}_1.vartype.vcf
        java -jar /tmp/snpEff/SnpSift.jar varType ${vcf_path2} > ${sample}_2.vartype.vcf
        java -jar /tmp/snpEff/SnpSift.jar varType ${vcf_path3} > ${sample}_3.vartype.vcf
        
        """
}

process merge {
    container 'supark87/tools2'
    publishDir "$params.output.folder/final_vcf/${sample}", mode : "copy"

    input:
        set val(sample), path(vcf_path1), path(vcf_path2), path(vcf_path3),path(bam_path) from vartype_out1.join(postal_out4)
        path(pyscripts_path) from pyscripts

    output:
        tuple val(sample), path("final_${sample}.vcf") into merge_out
        tuple val(sample), path("final_${sample}.vcf") into merge_out2

    script:
        """
        samtools index ${bam_path}
        python ${pyscripts_path}/annotate.py -r $baseDir/ref/pfalciparum/6genes2.fa -b $baseDir/6genes2.bed -o ${sample} -v1 ${vcf_path1} -v2 ${vcf_path2} -v3 ${vcf_path3} -m ${bam_path} -voi $baseDir/ref/pfalciparum/Reportable_SNPs.csv -name ${sample}
        """
}


process filter {
    container 'supark87/snpeff'                   
    publishDir "$params.output.folder/filter/${sample}", mode : "copy"
    //errorStrategy 'ignore'


    input:
        set val(sample), path(vcf_path1) from merge_out

    output:
        tuple val(sample), path("${sample}_filtered.vcf") into filter_out

    script:
        """
        java -Xmx8g -jar /tmp/snpEff/SnpSift.jar filter -f ${vcf_path1} " ( VARTYPE = 'SNP' ) " > ${sample}_filtered.vcf
        """
}

process extract {
    container 'supark87/snpeff'                   
    publishDir "$params.output.folder/extract/${sample}", mode : "copy"
    //errorStrategy 'ignore'


    input:
        set val(sample), path(vcf_path1) from filter_out

    output:
        tuple val(sample), path("final_${vcf_path1}ext.vcf") into extract_out

    script:
    """
    java -Xmx8g -jar /tmp/snpEff/SnpSift.jar extractFields ${vcf_path1} CHROM POS REF ALT VARTYPE Confidence Sources AF QD FS  MQ "ANN[*].EFFECT" "ANN[*].HGVS_C" "ANN[*].HGVS_P" > final_${vcf_path1}ext.vcf
    """
}

process spread {
    container 'supark87/tools2'
    publishDir "$params.output.folder/spread/${sample}", mode : "copy"
    //errorStrategy 'ignore'

    input:
        set val(sample), path(vcf_path) from extract_out
        path(pyscripts_path) from pyscripts

    output:
        tuple val(sample), path("fixedPOS${vcf_path}") into spread_out

    script:
    """
    python ${pyscripts_path}/vcfcsv3.py -n ${vcf_path}
    """
}

process snpfilter {
    container 'supark87/tools2'

    publishDir "$params.output.folder/snpfilter/${sample}", mode : "copy"

    input:
        set val(sample), path(vcf_path1), path(vcf_path2), path(bam_path1) from spread_out.join(merge_out2).join(postal_out5)
        path(pyscripts_path) from pyscripts

    output:
        tuple val(sample), path("${sample}.csv") into snpfilter_out

    script:
        """
        python ${pyscripts_path}/snpreport1-8.py -v1 ${vcf_path2} -v2 ${vcf_path1} -b1 ${bam_path1} -o1 ${sample}
        """
}

process trackerror {
    container 'biopython/biopython'
    publishDir "$params.output.folder/error_track", mode : "copy"
    //errorStrategy 'ignore'
    input:
    path(ct_table_path) from ct_table
    output:
    file("out.csv")

script:

"""
#!/usr/bin/python3
from os import listdir
import pandas as pd
import csv
import subprocess

def install(name):
    subprocess.call(['pip3', 'install', name])

install('xlrd==1.2.0')
import xlrd
wholelist1=[["samplename","error", "CTvalue"]]
with open("$baseDir/.nextflow.log", "r") as logfile:
    for line in logfile:
        if line.find("error") != -1:
            if line.find("INFO") != -1:
                workdir=(line[line.find("]")+1::])[(line[line.find("]")+1::]).find("["):(line[line.find("]")+1::]).find("]")+1]
                workdir1=workdir[1:workdir.find("/")]
                workdir2=workdir[workdir.find("/")+1:-1]
                for x in listdir("$baseDir/work/"+workdir1):
                    if x.startswith(workdir2):
                        workdir2=x
                with open("$baseDir/work/"+workdir1+"/"+workdir2+"/.command.sh", "r") as commandsh:
                    for line in commandsh:
                        if line.find("samtools index") !=-1:
                            samplename=line[14::]
                            #print(samplename)
                        if line.find("bbduk.sh") !=-1:
                            samplename=line[line.find("in=")+3:line.find("_R1")]
                with open("$baseDir/work/"+workdir1+"/"+workdir2+"/.command.err", "r") as commanderror:
                    for line in commanderror:
                        if line.find("KeyError: 'fields")!=-1:
                            error="noVCF?fields"
                            #print(error)
                            #print(samplename,error)
                        if line.find("KeyError: 'info")!=-1:
                            error="noVCF?info"
                            #print(samplename,error)
                        if line.find("There appear to be different numbers of reads in the paired input files.")!=-1:
                            error="different pair read"
                samplename=samplename[:samplename.find("Fxxx0")+1]+"1230"
                xls=pd.ExcelFile("${ct_table_path}/ANG_2019_TES_master.xlsx")
                df1 = pd.read_excel(xls, 'TES PCR gel results')
                for x in range(len(df1["Date completed"].tolist())):
                    if (df1["Date completed"].tolist())[x]==samplename:
                        CTvalue=(df1["Unnamed: 2"].tolist())[x]
                        wholelist1+=[samplename,error,CTvalue]
                for x in range(len(df1["Date completed.1"].tolist())):
                    if (df1["Date completed.1"].tolist())[x]==samplename:
                      
                        CTvalue=(df1["Unnamed: 15"].tolist())[x]
                        wholelist1+=[[samplename,error,CTvalue]]
with open("out.csv", "w", newline="") as f:
    writer = csv.writer(f)
    writer.writerows(wholelist1)
"""

}