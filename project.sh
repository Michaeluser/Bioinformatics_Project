#!/bin/bash

#PATH VARIABLES
CR1="Data/Data_QC/P14.C_R1.fastq.gz" #control sample R1
CR2="Data/Data_QC/P14.C_R2.fastq.gz" #control sample R2
TR1="Data/Data_QC/P14.T_R1.fastq.gz" #tumor sample R1
TR2="Data/Data_QC/P14.T_R2.fastq.gz" #tumor sample R2

CR1_CL="Data/Data_QC/C_R1_output.fastq.gz" #CLeaned control sample R1
CR2_CL="Data/Data_QC/C_R2_output.fastq.gz" #CLeaned control sample R2
TR1_CL="Data/Data_QC/T_R1_output.fastq.gz" #CLeaned tumor sample R1
TR2_CL="Data/Data_QC/T_R2_output.fastq.gz" #CLeaned tumor sample R2

CS_A="Data/Read_Alignment/CA.bam" #aligned control sample
TS_A="Data/Read_Alignment/TA.bam" #aligned tumor sample

CS_I="Data/Post_Processing/CA.bam" #control sample in Post_Processing stage
TS_I="Data/Post_Processing/TA.bam" #tumor sample in Post_Processing stage

CS_M="Data/Post_Processing/CA_marked.bam"
TS_M="Data/Post_Processing/TA_marked.bam"

HG_38="Data/Read_Alignment/hg_38.fa" #human reference genome
HG_38_GZ="Data/Read_Alignment/hg_38.fa.gz"

DBSNP="Data/Post_Processing/dbsnp.vcf" #dbsnp variant calling data
DBSNP_IDX="Data/Post_Processing/dbsnp.vcf.idx" #dbsnp index table

HGV="Data/Post_Processing/small_exac_common_3.hg38.vcf.gz" #human genome variants data
HGV_IDX="Data/Post_Processing/small_exac_common_3.hg38.vcf.gz.tbi" #human genome variants data

#In case of script running from the very scratch which is determined by -s flag, all necessary preparations would be done for the user
#Note: All initial data samples must be located in the "Data" directory for starting from scratch, which must be located in the directory where this script resides


if [ "$1" == "-s" ] && [ "$2" == "1" ]; then
	#make sure that Utils directory exists
	mkdir -p "$HOME/Utils"

	#setup Miniforge
	if [ ! -d "$HOME/Utils/miniforge3" ]; then
	    echo "Installing Miniforge..."
	    curl -L -O "https://github.com/conda-forge/miniforge/releases/latest/download/Miniforge3-Linux-x86_64.sh"
	    bash Miniforge3-Linux-x86_64.sh -b -p "$HOME/Utils/miniforge3"
	    rm Miniforge3-Linux-x86_64.sh
	fi

	#activate Conda for this session
	source "$HOME/Utils/miniforge3/etc/profile.d/conda.sh"

	#installation function
	install_tool() {
	    if ! command -v "$1" &> /dev/null; then
	        echo "[INSTALLING] $1"
	        conda install -y bioconda::"$1"
	    else
	        echo "[SKIP] $1 is already installed."
	    fi
	}

	#install tools
	for tool in seqtk seqkit samtools fastqc bwa fastp qualimap gatk4 manta cnvkit; do
	    install_tool "$tool"
	done

	#create directories
	mkdir -p Data/Data_QC/Reports/ Data/Read_Alignment/Reports/ Data/Post_Processing/Reports/ Data/Post_Alignment_QC/Reports/ Data/Variant_Calling/CNV_Results/ Data/Variant_Calling/Manta_Output/ Data/Resources/

	#move files to destines directories
	if [ -f "P14.C_R1.fastq.gz" ]; then
	    mv P14.C_R1.fastq.gz P14.C_R2.fastq.gz P14.T_R1.fastq.gz P14.T_R2.fastq.gz Data/Data_QC/
	fi


	if [ ! -f "$HG_38" ]; then
	    echo "[INFO] Downloading hg38 reference genome..."
	    curl -L "https://hgdownload.soe.ucsc.edu/goldenPath/hg38/bigZips/hg38.fa.gz" -o $HG_38_GZ
	    gunzip $HG_38_GZ
	fi

	echo "[SUCCESS] Setup complete."
fi

echo "Project №2"
echo "The Comprehensive Analysis of Provided Regular and Cancerous RNA Samples of Patient №14"
echo "Authors: Andrii Popovych and Mykhailo Chepara"

echo "Raw Data Quality Control Stage"

#these following 2 commands make reports on all 4 samples and save them into Quality_Assesment directory.
#the reports are saved into .html files so you can later view them visually in browser
fastqc $CR1 $CR2 -o Data/Data_QC/Reports/
fastqc $TR1 $TR2 -o Data/Data_QC/Reports/

#these commands are used to trim sample files
#-i flag denotes forward read input file
#-I flag denotes reversed read input file
#-o flag denotes forward read output file
#-O flag denotes forward read output file
#-w number_of_threads_value
#-l minimum_length_of_a_read_value
#-j path_for_json_summary
#-h path_for_html_summary

fastp -i $CR1 -I $CR2 \
	-o $CR1_CL -O $CR2_CL \
	-w 4 \
	-3 -5 \
	-W 4 -M 15 \
	-l 36 \
	-j /dev/null \
	-h /dev/null

fastp -i $TR1 -I $TR2 \
	-o $TR1_CL -O $TR2_CL\
	-w 4 \
	-3 -5 \
	-W 4 -M 15 \
     	-l 36 \
     	-j /dev/null \
      	-h /dev/null

#these following 2 commands make reports on all 4 samples and save them into Quality_Assesment directory.
#the reports are saved into .html files so you can later view them visually in browser
fastqc $CR1_CL $CR2_CL -o Data/Data_QC/Reports/
fastqc $TR1_CL $TR2_CL -o Data/Data_QC/Reports/

#at this stage we synchronize all files so they have the same length
echo "Mini-Synchronization Stage"

mkdir -p Data/Data_QC/temp_sync


seqkit pair -1 $TR1_CL \
	    -2 $TR2_CL \
	    -O Data/Data_QC/temp_sync

seqkit pair -1 $CR1_CL \
	    -2 $CR2_CL \
	    -O Data/Data_QC/temp_sync

#rewrite all files in the main directory with files from temp_sync directory
mv Data/Data_QC/temp_sync/* Data/Data_QC/

#get rid of the redundant direcotry
rmdir Data/Data_QC/temp_sync

echo "Read Alignment Stage"

#samtools dict and faidx are required by gatk, getting them
if [ ! -f "${HG_38}.fai" ]; then
    samtools faidx $HG_38
fi
if [ ! -f "${HG_38%.fa}.dict" ]; then
    gatk CreateSequenceDictionary -R $HG_38
fi

#following command is used to index the reference genome so later on the reference database can be used for alignment of both fasta files
bwa index $HG_38

#command for aligning R1 and R2 control sequences using reference genome
#followed by samtools conversion command SAM -> BAM
#followed by samtools sort command to sort BAM file
bwa mem -t 4 \
	-M \
	-R "@RG\tID:P14_C\tSM:P14_C\tLB:P14_C_LB\tPL:ILLUMINA" \
	$HG_38 \
	$CR1_CL $CR2_CL | \
	samtools sort -@ 4 -o $CS_A -

#command for aligning R1 and R2 control sequences using reference genome
#followed by samtools conversion command SAM -> BAM
#followed by samtools sort command to sort BAM file
bwa mem -t 4 \
	-M \
	-R "@RG\tID:P14_T\tSM:P14_T\tLB:P14_T_LB\tPL:ILLUMINA" \
	$HG_38 \
	$TR1_CL $TR2_CL | \
	samtools sort -@ 4 -o $TS_A -

#generate statistics for indexing verification
samtools flagstat $CS_A > Data/Read_Alignment/Reports/CS_alignment_report.txt #CS - control sample
samtools flagstat $TS_A > Data/Read_Alignment/Reports/TS_alignment_report.txt #TS - tumor sample

echo "Data Cleaning Stage (Post-Processing)"

#curl files needed for quality recalibration
if [ ! -f "$DBSNP" ]; then
    curl -L "https://storage.googleapis.com/genomics-public-data/resources/broad/hg38/v0/Homo_sapiens_assembly38.dbsnp138.vcf" -o $DBSNP
fi
if [ ! -f "$DBSNP_IDX" ]; then
    curl -L "https://storage.googleapis.com/genomics-public-data/resources/broad/hg38/v0/Homo_sapiens_assembly38.dbsnp138.vcf.idx" -o $DBSNP_IDX
fi
if [ ! -f "$HGV" ]; then
    curl -L "https://storage.googleapis.com/gatk-best-practices/somatic-hg38/small_exac_common_3.hg38.vcf.gz" -o $HGV
fi
if [ ! -f "$HGV_IDX" ]; then
    curl -L "https://storage.googleapis.com/gatk-best-practices/somatic-hg38/small_exac_common_3.hg38.vcf.gz.tbi" -o $HGV_IDX
fi

#raw duplicates
#I - aligned input
#O - output marked
#M - report on alignment
gatk MarkDuplicatesSpark -I $CS_A -O $CS_M -M Data/Post_Processing/Reports/CA_duplicates_report.txt

#base quality score recablibration (BQSR)
#I - marked input
#R - reference
#--known-sites - VCF for looking at known VCs
#O - recalibration table
gatk BaseRecalibrator -I $CS_M -R $HG_38 \
		      --known-sites $DBSNP \
		      -O Data/Post_Processing/CA_recalib_data.table

#apply recalibration table and correct quality scores
#I - marked input
#R - reference
#--bqsr-recal-file - recalibration table used to recalibrate scores
#O - recalibrated file
gatk ApplyBQSR -I $CS_M -R $HG_38 \
	       --bqsr-recal-file Data/Post_Processing/CA_recalib_data.table \
	       -O $CS_I

#following command indexes output BAM file creating BAI file with indices
samtools index $CS_I

gatk GetPileupSummaries \
	 -I $CS_I \
	 -V $HGV \
	 -L $HGV \
	 -O Data/Post_Processing/C_pileups.table

#raw duplicates
#I - aligned input
#O - output marked
#M - report on alignment
gatk MarkDuplicatesSpark -I $TS_A -O $TS_M -M Data/Post_Processing/Reports/TA_duplicates_report.txt

#base quality score recablibration (BQSR)
#I - marked input
#R - reference
#--known-sites - VCF for looking at known VCs
#O - recalibration table
gatk BaseRecalibrator -I $TS_M -R $HG_38 \
		      --known-sites $DBSNP \
		      -O Data/Post_Processing/TA_recalib_data.table

#apply recalibration table and correct quality scores
#I - marked input
#R - reference
#--bqsr-recal-file - recalibration table used to recalibrate scores
#O - recalibrated file
gatk ApplyBQSR -I $TS_M -R $HG_38 \
	       --bqsr-recal-file Data/Post_Processing/TA_recalib_data.table \
	       -O $TS_I

#following command indexes output BAM file creating BAI file with indices
samtools index $TS_I

gatk GetPileupSummaries \
	 -I $TS_I \
	 -V $HGV \
	 -L $HGV \
	 -O Data/Post_Processing/T_pileups.table

#calculate contamination for every position in tumorous sample and compare it with healthy one
gatk CalculateContamination \
   -I Data/Post_Processing/T_pileups.table \
   -matched Data/Post_Processing/C_pileups.table \
   -O Data/Variant_Calling/contamination.table

echo "Post-Alignment Quality Control Stage"

samtools flagstat $CS_I > Data/Post_Alignment_QC/Reports/CS_alignment_report.txt #CS - control sample
samtools flagstat $TS_I > Data/Post_Alignment_QC/Reports/TS_alignment_report.txt #TS - tumor sample

qualimap bamqc \
	-bam $CS_I \
	-outdir Data/Post_Alignment_QC/Reports \
	-outformat HTML \
	--java-mem-size=4G

qualimap bamqc \
	-bam $TS_I \
	-outdir Data/Post_Alignment_QC/Reports \
	-outformat HTML \
	--java-mem-size=4G





echo "Variant Calling Stage"

gatk Mutect2 \
	-R $HG_38 \
	-I $TS_I \
	-I $CS_I \
	-normal P14_C \
	--f1r2-tar-gz Data/Variant_Calling/f1r2.tar.gz \
	-O Data/Variant_Calling/raw_somatic.vcf.gz

gatk LearnReadOrientationModel \
	-I Data/Variant_Calling/f1r2.tar.gz \
	-O Data/Variant_Calling/read_orientation_model.tar.gz

gatk FilterMutectCalls \
	-R $HG_38 \
	-V Data/Variant_Calling/raw_somatic.vcf.gz \
	--contamination-table Data/Variant_Calling/contamination.table \
	--ob-priors Data/Variant_Calling/read_orientation_model.tar.gz \
	-O Data/Variant_Calling/filtered_somatic.vcf.gz






configManta.py \
	--tumorBam $TS_I \
	--normalBam $CS_I \
	--referenceFasta $HG_38 \
	--runDir Data/Variant_Calling/Manta_Output

#execute run the analysis
Data/Variant_Calling/Manta_Output/runWorkflow.py -m local -j 4






cnvkit.py batch $TS_I \
	--normal $CS_I \
	--method wgs \
	--fasta $HG_38 \
	--output-dir Data/Variant_Calling/CNV_Results/ \
	--diagram --scatter





echo "Gleaning and Annotation Stage"

echo "Reporting Stage"
