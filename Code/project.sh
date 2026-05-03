#!/bin/bash


#-------------------------------SCRIPT-MANUAL-------------------------------

#Note: All initial data samples must be located in the directory where this script resides for starting from scratch

#In case of script running from the very scratch which is determined by -s flag, all necessary preparations can be done for the user
#Script perparation flags:
#m - directory management
#d - dependency installation
#c - assets collection
#e - environment initialization
#a - flag to install everything altogether

#Each phase of the project can be executed by itself as a separate mini-pipeline, in case you want to run a part of the pipeline at a time. For it to run -p flag is used.
#Pipeline execution flags:
#1 - raw data quality control
#2 - read alignment
#3 - data cleaning (post-processing)
#4 - post-alignment quality control
#5 - variant calling
#6 - gleaning and annotation
#7 - do a report

#0 - run all stages successively


#Example of usage:

#this command would run everything from scratch
#bash project.sh -s a -p 0

#-------------------------------SCRIPT-MANUAL-------------------------------



set -e  #exit on first error

#PATH VARIABLES

#Intermediate computation paths
SV_P="$HOME/Data/Variant_Calling/SV_Results" #structural variants results
CNV_P="$HOME/Data/Variant_Calling/CNV_Results/" #copy number variations results
SNP_P="$HOME/Data/Variant_Calling/SNP_Results/" #single nucleotide polymorphism results


#Primary files
CR1="$HOME/Data/Data_QC/P14.C_R1.fastq.gz" #control sample R1
CR2="$HOME/Data/Data_QC/P14.C_R2.fastq.gz" #control sample R2
TR1="$HOME/Data/Data_QC/P14.T_R1.fastq.gz" #tumor sample R1
TR2="$HOME/Data/Data_QC/P14.T_R2.fastq.gz" #tumor sample R2

CR1_CL="$HOME/Data/Data_QC/C_R1_output.fastq.gz" #CLeaned control sample R1
CR2_CL="$HOME/Data/Data_QC/C_R2_output.fastq.gz" #CLeaned control sample R2
TR1_CL="$HOME/Data/Data_QC/T_R1_output.fastq.gz" #CLeaned tumor sample R1
TR2_CL="$HOME/Data/Data_QC/T_R2_output.fastq.gz" #CLeaned tumor sample R2

CS_A="$HOME/Data/Read_Alignment/CA.bam" #aligned control sample
TS_A="$HOME/Data/Read_Alignment/TA.bam" #aligned tumor sample

CS_I="$HOME/Data/Post_Processing/CA.bam" #control sample in Post_Processing stage
TS_I="$HOME/Data/Post_Processing/TA.bam" #tumor sample in Post_Processing stage

CS_M="$HOME/Data/Post_Processing/CA_marked.bam" #duplicate marked control sample (BAM file)
TS_M="$HOME/Data/Post_Processing/TA_marked.bam" #duplicate marked tumor sample (BAM file)




#Intermediate computation files
CT_F="$HOME/Data/Variant_Calling/SNP_Results/contamination.table" #tumor sample contamination table 
RO_M="$HOME/Data/Variant_Calling/SNP_Results/read_orientation_model.tar.gz" #(read orientation) error read direction model of both samples 




#Mutect2 output files
P_DVC="$HOME/Data/Variant_Calling/SNP_Results/P_DVC.vcf" #primary derived variant calls
SNP_VC="$HOME/Data/Variant_Calling/SNP_Results/filtered_somatic.vcf" # filtered variant calls



#CNVkit output files
CNV_VCF="$HOME/Data/Variant_Calling/CNV_Results/cnv_occurences.vcf" #CNVkit VCF format
CVR="$HOME/Data/Variant_Calling/CNV_Results/cnv_reheaded.vcf" #CNVkit VCF file Reheaded, with header changed to proper one (the file has been reheaded, meaning contig lines were added)
CNV_VC="$HOME/Data/Variant_Calling/CNV_Results/cnvo_sorted.vcf" #Sorted CNV VCF file, final one

CNV_CNS="$HOME/Data/Variant_Calling/CNV_Results/TA.call.cns" #CNVkit segmented calls for tumor, final one



#Manta output files
SV_VC="$HOME/Data/Variant_Calling/SV_Results/results/variants/somaticSV.vcf" #Manta somatic SV output, final one



#FINAL ANNOTATED OUTPUT
SNP_MAF="$HOME/Data/Gleaning_Annotation/Annotations/snp_annotated.maf" #Final annotated MAF file
SV_MAF="$HOME/Data/Gleaning_Annotation/Annotations/sv_annotated.maf" #Final annotated MAF file
CNV_MAF="$HOME/Data/Gleaning_Annotation/Annotations/cnv_annotated.maf" #Final annotated MAF file





#Auxiliary downloaded files
HG_38="$HOME/Data/Read_Alignment/hg_38.fa" #human reference genome
HG_38_GZ="$HOME/Data/Read_Alignment/hg_38.fa.gz" #compressed reference genome
HG_38_IDX="$HOME/Data/Read_Alignment/hg_38.fa.fai" #indexed reference genome
HG_38_RD="$HOME/Data/Read_Alignment/hg_38.dict" #reference genome dictionary

DBSNP="$HOME/Data/Post_Processing/dbsnp.vcf" #dbsnp variant calling data
DBSNP_IDX="$HOME/Data/Post_Processing/dbsnp.vcf.idx" #dbsnp index table

HGV="$HOME/Data/Post_Processing/small_exac_common_3.hg38.vcf.gz" #human genome variants data
HGV_IDX="$HOME/Data/Post_Processing/small_exac_common_3.hg38.vcf.gz.tbi" #human genome variants data

FUNC_DB="$HOME/Data/Gleaning_Annotation/funcotator_dataSources.v1.8.hg38.20230908s" #Funcotator database path

if [[ "$*" == *"-s"* ]]; then

	#DIRECTORY MANAGEMENT
	if [[ "$*" == *"m"*  || "$*" == *"a"* ]]; then
		#make sure that Utils directory exists
		mkdir -p "$HOME/Utils"

		#create necessary directories
		# Update Line 101 to this:
		mkdir -p $HOME/Data/Data_QC/ $HOME/Data/Read_Alignment/ $HOME/Data/Post_Processing/ $HOME/Data/Post_Alignment_QC/ $HOME/Data/Variant_Calling/ $HOME/Data/Data_QC/Reports/ $HOME/Data/Read_Alignment/Reports/ $HOME/Data/Post_Processing/Reports/ $HOME/Data/Post_Alignment_QC/Reports/ $HOME/Data/Variant_Calling/CNV_Results/ $HOME/Data/Variant_Calling/SNP_Results/ $HOME/Data/Variant_Calling/Manta_Output/ $HOME/Data/Gleaning_Annotation/ $HOME/Data/Gleaning_Annotation/Annotations/

		#move files to destined directories
		if [ -f "P14.C_R1.fastq.gz" ]; then
			mv P14.C_R1.fastq.gz P14.C_R2.fastq.gz P14.T_R1.fastq.gz P14.T_R2.fastq.gz $HOME/Data/Data_QC/
		fi
	fi


	#DEPENDENCY INSTALLATION
	if [[ "$*" == *"d"* || "$*" == *"a"* ]]; then
		#tool installation function
		install_tool() {
			if [ ! command -v "$1" &> /dev/null ]; then
				echo "[INSTALLING] $1"
				conda install -y bioconda::"$1"
			else
				echo "[SKIP] - $1 is already installed."
			fi
		}

		#setup Miniforge
		if [ ! -d "$HOME/Utils/miniforge3" ]; then
			echo "[INSTALLING] Miniforge"
			curl -L -O "https://github.com/conda-forge/miniforge/releases/latest/download/Miniforge3-Linux-x86_64.sh"
			bash Miniforge3-Linux-x86_64.sh -b -p "$HOME/Utils/miniforge3"
			rm Miniforge3-Linux-x86_64.sh
		fi

		#activate Conda for this session
		source "$HOME/Utils/miniforge3/etc/profile.d/conda.sh"

		#install tools
		for tool in seqtk seqkit samtools bcftools fastqc bwa fastp qualimap gatk4 cnvkit igv survivor tcllib tar; do
			install_tool "$tool"
		done

		conda install -c conda-forge gzip
	fi


	#ASSETS COLLECTION
	if [[ "$*" == *"c"* || "$*" == *"a"* ]]; then
		#retrieve hg_38 reference genome
		if [ ! -f "$HG_38_GZ"]; then
			echo "[INFO] Downloading hg38 reference genome"
			curl -L "https://hgdownload.gi.ucsc.edu/goldenPath/hg38/bigZips/latest/hg38.fa.gz" -o $HG_38_GZ
			gunzip "$HG_38_GZ"
		fi



		#generate necessary index file for reheader bcftools
		if [ ! -f "$HG_38_IDX" ]; then
			samtools faidx "$HG_38"
		fi

		#generate necessary dictionary file for gatk baserecalibrator
		if [ ! -f "$HG_38_RD" ]; then
			samtools dict "$HG_38" > "$HG_38_RD"
		fi



		#load files needed for quality recalibration
		if [ ! -f "$DBSNP" ]; then
			curl -L "https://storage.googleapis.com/gcp-public-data--broad-references/hg38/v0/Homo_sapiens_assembly38.dbsnp138.vcf" -o $DBSNP
		fi
		if [ ! -f "$DBSNP_IDX" ]; then
			curl -L "https://storage.googleapis.com/gcp-public-data--broad-references/hg38/v0/Homo_sapiens_assembly38.dbsnp138.vcf.idx" -o $DBSNP_IDX
		fi
		if [ ! -f "$HGV" ]; then
			curl -L "https://storage.googleapis.com/gcp-public-data--broad-references/hg38/v0/somatic-hg38/small_exac_common_3.hg38.vcf.gz" -o $HGV
		fi
		if [ ! -f "$HGV_IDX" ]; then
			curl -L "https://storage.googleapis.com/gcp-public-data--broad-references/hg38/v0/somatic-hg38/small_exac_common_3.hg38.vcf.gz.tbi" -o $HGV_IDX
		fi

	
		#acquire annotation database directory
		if [ ! -d "$FUNC_DB" ]; then
			gatk FuncotatorDataSourceDownloader --somatic --validate-integrity --hg38 --output $HOME/Data/Gleaning_Annotation/Resources
			tar -xvzf $HOME/Data/Gleaning_Annotation/Resources
			rm $HOME/Data/Gleaning_Annotation/Resources
		fi

	fi


	#ENVIRONMENT INITIALIZATION
	if [[ "$*" == *"e"* || "$*" == *"a"* ]]; then
		#create separate environment for manta specifically and install it there
		conda create -n manta_env -c bioconda -c conda-forge manta python=2.7


		#create separate environment for cnvkit specifically and install it there
		conda create -n cnvkit_env -c bioconda -c conda-forge cnvkit pandas=1.5.3 python=3.10
	fi

	echo "[SUCCESS] Setup complete."
else
	echo "[SKIPPING FOUNDATION INITIALIZATION] Skipping dependency installation, directory management, assets acquisition and environments initialization"
fi





echo "Project №2"
echo "The Comprehensive Analysis Pipeline of Provided Regular and Cancerous RNA Samples of Patient №14"
echo "Authors: Andrii Popovych and Mykhailo Chepara"




if [[ "$*" == *"-p"* ]]; then
	echo "This is executed"
	if [[ "$*" == *"1"* ||  "$*" == *"0"* ]]; then
		echo "Raw Data Quality Control Stage"

		#Make reports on control samples and save them into Reports directory
		#o - output directory
		#The reports are saved into .html files so you can later view them visually in browser
		fastqc "$CR1" "$CR2" -o $HOME/Data/Data_QC/Reports/
		fastqc "$TR1" "$TR2" -o $HOME/Data/Data_QC/Reports/




		#Trim sample files
		#i - flag denotes forward read input file
		#I - flag denotes reversed read input file
		#o - flag denotes forward read output file
		#O - flag denotes forward read output file
		#w - number_of_threads_value
		#l - minimum_length_of_a_read_value
		#j - path_for_json_summary
		#h - path_for_html_summary
		fastp -i "$CR1" -I "$CR2" \
			-o "$CR1_CL" -O "$CR2_CL" \
			-w 4 \
			-3 -5 \
			-W 4 -M 15 \
			-l 36 \
			-j /dev/null \
			-h /dev/null

		fastp -i "$TR1" -I "$TR2" \
			-o "$TR1_CL" -O $TR2_CL\
			-w 4 \
			-3 -5 \
			-W 4 -M 15 \
				-l 36 \
				-j /dev/null \
				-h /dev/null



		#Synchronize both sample pairs
		#Meaning get rid of all reads that don't have a pair in the coherent sample
		echo "Mini-Synchronization Stage"

		#create temp_sync dir if non-existent
		mkdir -p $HOME/Data/Data_QC/temp_sync

		#Pair the samples
		#1 - first sample RNA
		#2 - second sample RNA
		#O - output directory
		seqkit pair -1 "$TR1_CL" \
				-2 "$TR2_CL" \
				-O $HOME/Data/Data_QC/temp_sync

		seqkit pair -1 "$CR1_CL" \
				-2 "$CR2_CL" \
				-O $HOME/Data/Data_QC/temp_sync

		#rewrite all files in the main directory with files from temp_sync directory
		mv $HOME/Data/Data_QC/temp_sync/* $HOME/Data/Data_QC/

		#et rid of the redundant direcotry
		rmdir $HOME/Data/Data_QC/temp_sync




		#Report on trimmed samples
		#o - output directory
		#the reports are saved into .html files so you can later view them visually in browser
		fastqc "$CR1_CL" "$CR2_CL" -o $HOME/Data/Data_QC/Reports/
		fastqc "$TR1_CL" "$TR2_CL" -o $HOME/Data/Data_QC/Reports/

	fi


	if [[ "$*" == *"2"* ||  "$*" == *"0"* ]]; then
		echo "Read Alignment Stage"

		#Index the reference genome 
		bwa index $HG_38

		#Aligning R1 and R2 control sequences
		#done so by using reference genome and its index file

		#samtools sort command to sort BAM file
		#@ - determine number of threads for the samtools
		#"-" - take input from the pipe

		#samtools conversion "view" command SAM -> BAM
		#hbS - h - (include header); conversion from S - (SAM) to b - (BAM)
		#o - output directory

		#t - used for determining amount of working threads on the process
		#M - adjust output for older versions of Picard, for backward compatibility
		#R - header that is used for heading aligned files

		#"@RG\tID:P14_C\tSM:P14_C\tLB:P14_C_LB\tPL:ILLUMINA" - header for the file, where
		#@RG - read group
		#ID - sample id
		#LB - library used for RNA prep
		#PL - platform a.k.a sequencer platform, in this case its ILLUMINA

		bwa mem -t 4 \
			-M \
			-R "@RG\tID:P14_C\tSM:P14_C\tLB:P14_C_LB\tPL:ILLUMINA" \
			$HG_38 \
			$CR1_CL "$CR2_CL" | \
			samtools sort -@ 4 - | \
			samtools view -hbS -o "$CS_A"


		bwa mem -t 4 \
			-M \
			-R "@RG\tID:P14_T\tSM:P14_T\tLB:P14_T_LB\tPL:ILLUMINA" \
			$HG_38 \
			$TR1_CL "$TR2_CL" | \
			samtools sort -@ 4 - | \
			samtools view -hbS -o "$TS_A"

		#Generate statistics for indexing verification
		samtools flagstat "$CS_A" > $HOME/Data/Read_Alignment/Reports/CS_alignment_report.txt #CS - control sample
		samtools flagstat "$TS_A" > $HOME/Data/Read_Alignment/Reports/TS_alignment_report.txt #TS - tumor sample
		qualimap bamqc -bam "$CS_A" -outdir $HOME/Data/Read_Alignment/Reports/ #CS - control sample
		qualimap bamqc -bam "$TS_A" -outdir $HOME/Data/Read_Alignment/Reports/ #TS - tumor sample
	fi






	if [[ "$*" == *"3"* ||  "$*" == *"0"* ]]; then

		echo "Data Cleaning Stage (Post-Processing)"

		#Mark all duplicates
		#I - aligned input
		#O - output marked
		#M - report on alignment
		gatk MarkDuplicatesSpark -I "$CS_A" -O "$CS_M" -M $HOME/Data/Post_Processing/Reports/CA_duplicates_report.txt
		gatk MarkDuplicatesSpark -I "$TS_A" -O "$TS_M" -M $HOME/Data/Post_Processing/Reports/TA_duplicates_report.txt




		#Perform base quality score recablibration (BQSR)
		#I - marked input
		#R - reference
		#--known-sites - VCF for looking at known VCs
		#O - recalibration table
		gatk BaseRecalibrator -I "$CS_M" -R "$HG_38" \
			--known-sites "$DBSNP" \
			-O $HOME/Data/Post_Processing/CA_recalib_data.table

		gatk BaseRecalibrator -I "$TS_M" -R "$HG_38" \
			--known-sites "$DBSNP" \
			-O $HOME/Data/Post_Processing/TA_recalib_data.table




		#Apply recalibration table and correct quality scores
		#I - marked input
		#R - reference
		#--bqsr-recal-file - recalibration table used to recalibrate scores
		#O - recalibrated file
		gatk ApplyBQSR -I "$CS_M" -R "$HG_38" \
			--bqsr-recal-file $HOME/Data/Post_Processing/CA_recalib_data.table \
			-O "$CS_I"

		gatk ApplyBQSR -I "$TS_M" -R "$HG_38" \
			--bqsr-recal-file $HOME/Data/Post_Processing/TA_recalib_data.table \
			-O "$TS_I"




		#Index BAM file creating BAI file with indices
		samtools index "$CS_I"
		samtools index "$TS_I"




		#Reveal all possible contamination sites in the sample
		#I - input BAM file
		#V - variants for comparison
		#L - file with intervals to process, the same VCF file is provided since we want to skip all invariant regions
		#O - output pileups table of possible contamination
		gatk GetPileupSummaries \
			-I "$CS_I" \
			-V $HGV \
			-L $HGV \
			-O $HOME/Data/Post_Processing/C_pileups.table

		gatk GetPileupSummaries \
			-I "$TS_I" \
			-V $HGV \
			-L $HGV \
			-O $HOME/Data/Post_Processing/T_pileups.table




		#Calculate contamination for every position in tumorous sample and compare it with healthy one
		#I - input tumorous sample contamination table file
		#matched - normal sample contamination table
		#O - output contamination table of the tumorous sample
		gatk CalculateContamination \
		-I $HOME/Data/Post_Processing/T_pileups.table \
		-matched $HOME/Data/Post_Processing/C_pileups.table \
		-O "$CT_F"
	fi



	if [[ "$*" == *"4"* ||  "$*" == *"0"* ]]; then

		echo "Post-Alignment Quality Control Stage"

		#Generate alignment report data using flagstat
		samtools flagstat "$CS_I" > $HOME/Data/Post_Alignment_QC/Reports/CS_alignment_report.txt #CS - control sample
		samtools flagstat "$TS_I" > $HOME/Data/Post_Alignment_QC/Reports/TS_alignment_report.txt #TS - tumor sample

		#Generate alignment report data using bamqc
		#bam - bam extension input file
		#outdir - output directory
		#outformat - output format of the report
		#--java-mem-size - limit qualimap bamqc to 4GB of RAM usage
		qualimap bamqc \
			-bam "$CS_I" \
			-outdir $HOME/Data/Post_Alignment_QC/Reports \
			-outformat HTML \
			--java-mem-size=4G

		qualimap bamqc \
			-bam "$TS_I" \
			-outdir $HOME/Data/Post_Alignment_QC/Reports \
			-outformat HTML \
			--java-mem-size=4G
	fi



	if [[ "$*" == *"5"* ||  "$*" == *"0"* ]]; then
		echo "Variant Calling Stage"

		#Collect SNVs/SNPs of tumorous sample
		#R - reference genome
		#I - tumor/normal bam file
		#normal - name of the normal sample inside of the bam file(previously it was set to P14_C)
		#--f1r2-tar-gz - file that contains forward and reverse reads statistics to deduce artifacts introduced by sequencer(this tool generates it)
		gatk Mutect2 \
			-R "$HG_38" \
			-I "$TS_I" \
			-I "$CS_I" \
			-normal P14_C \
			--f1r2-tar-gz $HOME/Data/Variant_Calling/f1r2.tar.gz \
			-O "$P_DVC"




		#Generate priority model to tell whether artifact is a chemical damage during reading process or a real mutation
		#I - input stats to identify patterns of errors, the f1r2.tar.gz file
		#O - a model that tells where and what is considered to be an artifact rather than a mutation in the context of sequences
		gatk LearnReadOrientationModel \
			-I $HOME/Data/Variant_Calling/f1r2.tar.gz \
			-O "$RO_M"




		#Make sure that all of the changes are either marked as somatic or not(FILTER column is added)
		#if FILTER = PASS then change is a somatic mutation
		#R - reference genome
		#V - variant input
		#--contamination-table - contamination table file
		#--ob-prios - Orientation Bias Priors file, a.k.a model of read orientation errors
		#O - output file
		gatk FilterMutectCalls \
			-R "$HG_38" \
			-V "$P_DVC" \
			--contamination-table "$CT_F" \
			--ob-priors "$RO_M" \
			-O "$SNP_VC"




		#Find large SV
		#--tumorBam - recalibrated BAM tumor sample
		#--normalBam - recalibrated BAM normal sample
		#--referenceFasta - reference genome
		#--runDir - directory to save results to and work in
		conda run -n manta_env configManta.py \
			--tumorBam "$TS_I" \
			--normalBam "$CS_I" \
			--referenceFasta "$HG_38" \
			--runDir $SV_P

		#execute the analysis
		conda run -n manta_env $SV_P/runWorkflow.py -m local -j 4


		#unzip vcf file for funcotator
		gunzip -f $SV_P/results/variants/somaticSV.vcf.gz


		#Find copy number variations
		#batch - run the bundle of commands for CNV analysis
		#first argument ($TS_I) must be tumor BAM sample
		#--normal - normal BAM sample
		#--method - flag that determines whether data comes from Whole Genome Sequencing (WGS) or other
		#--fasta - reference genome
		#--output-dir - directory to save results
		#--diagram - make a visualization diagram
		#--scatter - scatterplot for each chromosome
		conda run -n cnvkit_env cnvkit.py batch "$TS_I" \
			--normal "$CS_I" \
			--method wgs \
			--fasta "$HG_38" \
			--output-dir $CNV_P \
			--diagram --scatter




		#convert from cns into vcf file format
		#export - tell cnvkit that there will be conversion
		#y - gender specific handling(X/Y)
		#o - output file
		conda run -n cnvkit_env cnvkit.py export vcf "$CNV_CNS" -y -o "$CNV_VCF"





		#--fai - indexed reference genome file
		#CNV_VCF - vcf input file
		#o - output file
		bcftools reheader --fai $HG_38_IDX "$CNV_VCF" -o "$CVR"

		#sort vcf file
		#Oz - output compressed bgzf format
		#o - output file name
		#--fai - index tile of reference genome
		bcftools sort "$CVR" -Ov -o "$CNV_VC"

		#index vcf file
		#I - create a TBI index
		gatk IndexFeatureFile -I "$CNV_VC"

	fi

	if [[ "$*" == *"6"* ||  "$*" == *"0"* ]]; then
		echo "Gleaning and Annotation Stage"
		echo "The stage is also done using Web Tool Variant Effect Predictor"

		#annotate the merged variant calls using funcotator to add biological meaning
		#R - reference genome
		#V - input variant file to be annotated
		#O - output annotated file
		#--data-sources-path - path to funcotator database containing clinical/biological context
		#--ref-version - reference genome version (hg38 or hg19)
		#--output-file-format - format of the output file (MAF for Mutation Annotation Format)
		gatk Funcotator \
			-R "$HG_38" \
			-V "$SNP_VC" \
			-O "$SNP_MAF" \
			--data-sources-path "$FUNC_DB" \
			--ref-version hg38 \
			--output-file-format MAF


		gatk Funcotator \
			-R "$HG_38" \
			-V "$SV_VC" \
			-O "$SV_MAF" \
			--data-sources-path "$FUNC_DB" \
			--ref-version hg38 \
			--output-file-format MAF


	fi


	if [[ "$*" == *"7"* ||  "$*" == *"0"* ]]; then
		echo "Reporting Stage"
		echo "The stage is conducted by analyzing annotated files and preserving actual information into txt files. Later on the final analysis report file is made from existing reports rendered from previous stages."
	fi

fi

