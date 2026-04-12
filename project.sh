#!/bin/bash

#PATH VARIABLES
R1_C="Data/Data_QC/P14.C_R1.fastq.gz" #path to control sample R1
R2_C="Data/Data_QC/P14.C_R2.fastq.gz" #path to control sample R2
R1_T="Data/Data_QC/P14.T_R1.fastq.gz" #path to tumor sample R1
R2_T="Data/Data_QC/P14.T_R2.fastq.gz" #path to tumor sample R2

R1_CO="Data/Data_QC/C_R1_output.fastq.gz" #path to pre-processed control sample R1
R2_CO="Data/Data_QC/C_R2_output.fastq.gz" #path to pre-processed control sample R2
R1_TO="Data/Data_QC/T_R1_output.fastq.gz" #path to pre-processed tumor sample R1
R2_TO="Data/Data_QC/T_R2_output.fastq.gz" #path to pre-processed tumor sample R2

HG_38="Data/Read_Alignment/hg_38.fa" #path to human reference genome



#In case of script running from the very scratch which is determined by -sm flag, all necessary preparations would be done for the user
#Note: All initial data samples must be located in the "Data" directory for starting from scratch, which must be located in the directory where this script resides

if [ %1 -eq "-sm"]; then

	#DEPENDENCY INSTALLATIONS
	conda install bioconda::fastp
	conda install bioconda::minimap
	


	#STRUCTURE PREREQUISITES

	#Create all necessary direcotries
	mkdir Quality_Assessment/   Data/   Data/Data_QC/   Data/Read_Alignment/   Data/Post-processing/   Data/Post_Alignment/   Data        /Variant_Calling/   Data/Post-Processing/   Data/Report/

	#Move all files where needed
	mv $R1_C $R2_C  $R1_T $R2_T Data/Data_QC
	mv hg_38.fa Data/Read_Alignment/

else

	echo "Structure is present omitting structure management."

fi



echo "Project №2"
echo "The Comprehensive Analysis of Provided Regular and Cancerous RNA Samples of Patient №14"
echo "Authors: Andrii Popovych and Mykhailo Chepara"

#INFO FOR PRESENTATION AND PDF

Per base sequence quality graph in all 4 samples reveals that at the very beginning of the read as well as at the very end, quality of the read is low compared to the middle of it. That is okay, since at the very start the sequencer needs to calibrate itself to recognize equilaterall all 4 bases, based off of their colors and to determine position of the DNA sequence on the cell.
At the end the quality drops due to reader noise and dephasing, i.e. parallel reads get unsynchronized and eventually the noise becomes very high, effectively blocking the factually correct sequence of bases.
This pattern is recognized in all 4 samples of RNA.

Control sample R1. An average score of the sample stays above phred score of 30 at all times.

Control sample R2 has an average that stays strictly above phred score of 30 at all times, but at the end of the read the median of the last couple of bases is approximately at quality score of 30. 
This indicates poor quality of reads, which must be dealt with, in order to not leave misleading bases for the alignment algorithms to work with. Since alignment algorithms would align incorrectly read bases, producing a segment or segments that appear to be tumorous, but in reality were just sequencer's inaccuracy.

Tumor sample R1. It has an average phred score that stays above 32 throughout the whole reading procedure, which indicates moderately high quality of the reads.

Tumor sample R2. It wields an average phred score that stays above 32 as well, signifying pretty decent quality of reads.






Control sample R1. Per tile quality heatmap shows, that only some minute parts of the sequencing had problems. Major part of the heatmap area is colored in blue, signalling that everything was read mostly correct. Those small vertical lines are only caused by either small vibrations of the tiles or some air particles getting into the tiles reflecting some part of light off of the sequencer's lenses.

Control sample R2. Per tile quality heatmap demonstrates that a couple of tiles were having problems with sequencing in particular tiles 1101, 1201 and 1301. But the problem can be solved by trimming sequences by each bases quality.

Tumor sample R1.It is mostly clean, almost no problems with tile sequencing.

Tumor sample R2. The current sample manifests similar problems as control sample R2, since the same tiles 1101, 1201, 1301 are indulged in problematic possibly incorrect sequencing of RNA segments. Again trimming by quality of each base can help resolve the issue.






Control sample R1. Per sequence quality score graph shows negatively skewed distribution, that is in our case a positive sign, additionally on the left side of the distribution no summits can be observed at all, which is a good sign too.

Control sample R2. On the other hand this sample has a small peak to the foremost left of the graph, that has approximately 500000 reads posessing average phred score of 2 which is a bit concerning. But since the biggest peak is on the right side of the graph approximates to the amount of 3500000, as was mentioned earlier, we can trim everything by the base quality of each base.

Tumor sample R1. The examined sample has an average highest quality per read falling into the category of Q = 38 by the phred measurement system.

Tumor sample R2. This sample has as usual, accodring to the preceding 3 samples, highest peak located to the right side of the graph. Albeit, it has a very sharp summit to the right it also posesses a small spike by the left side of the graph which has value of 2 representing pretty low read quality and the amount of reads rougly less than 500000 with that quality, still it can be fixed by trimming the entire sequence.






Control sample R1. Per base sequence content of this sample is unstable at the beginnnig since the machine in order to read the DNA needs to start somewhere. And because we don't predominantly know from which sequence DNA would start hexamer priming is used. That technique uses a random succession of 6 different bases to "catch" any possible DNA sequence to itself, and since it's utterly random the very beginning of reads consists of uneven amount of bases. The current sample demonstrates rough equality in quantity of bases per position in a read.

Control sample R2. The sample shows roughly the same number of bases after 15 position of read, though some small spikes can be  seen as well as small parallel deviations from the main standard of 25%, they are caused by erroneous base reads and can be eliminated by base quality trimming.

Tumor sample R1. Per base sequence content is roughly fine. And as can be seen amount of base pairs per each position in each read stays appproximately on the same level, though different ratio of bases can be seen, i.e not each base has the average amount of 25% but a some have a couple of percent below, some have a few above, it is normal since there are no abonrmal spikes and quantity of each base per position eventually tallied up with other bases' quantities evens out to 100%.

Tumor sample R2. Sequence content per base is similar in principle to how bases at each position are divided in previous sample's read, not even by a ruler but no major spikes, so it's perfectly normal.






All 4 samples have per base N content being flat 0 across all 4 graphs, indicating that none of the bases where lost during sequencing.





Each sample from 4 provided consists of a certain amount of sequences, where each sequence has the precise value of 101 base per read. Thus sequence distribution looks like a triangle, since the reads weren't processed yet. It's perfectly fine in this case.






Control sample R1. The inspected sample has percentage of duplication equating to 17.64%, which is above the anticipated level of 5-15%. The problem would be solved in post-processing stage by marking the duplicates.

Control sample R2. The examined sample has the lowest amount of duplicates among all samples. The duplicate quantity is 12.43%, which is normal considering that its value falls into the abovementioned interval of 5-15%.

Tumor sample R1. The investigated sample has amount of duplicates that is the largest among all samples, equalling to 18.49%. That is fairly a lot, and can be explained by the fact that tumorous samples have on average bigger amount of duplicates than healthy samples.

Tumor sample R2. The specimen has number of duplicates equating to 14.73%, which still falls into the expected interval, though is at the edge of it.






None of the examined samples appear to have any adapter content attached to them, meaning we have clean samples of RNA and telomeres, centromeres and exons with introns only.






Each and every supplied sample doesn't contain any overepresented sequences throughout each sample's reads. That means there are no visible contaminants in the sequence in neither of the samples.






Neither of all samples have a bell curve resembling Gaussian Distribution, additionally it wasn't shifted neither to right nor to left from that we can conclude that we don't have any depletion nor enrichment in bias of library preparation. In other words there weren' many duplicates introduced during preparation of the libary of segments.

Control sample R1. GC content per sequence distribution is shifted to the left by 15% which is normal, since almost all illumina libraries introduce a bit of bias, on top of that PCR amplification also helps in increasing number of copies of each segment, therefore the shift of 15% is plausable. However, there is a problem with GC content distribution itself, it's bimodal. That itself suggests that not only there are samples of human DNA but samples of another creature, in other words signs of possible contamination.

Control sample R2. GC content per sequence distribution is shifted to the left by 9%. The shift is even more acceptable since it deviates from the norm by only 9%. But as with the control sample R1, current sample has a problem with the distribution itself, which appears to be bimodal, again signs of probable contamination.

Tumor sample R1. Unlike previous 2 samples this sample has only one mode, but the problem arises from the fact that it doesn't resemble Gaussian Distribution and has bumps over its curve. This suggests either about contamination or some unordinary change in DNA which can happen to be tumorous. If after trimming tumorous samples GC content wouldn't be on a sustained level, that means it's not a contamination and is indeed possibly a tumor.

Tumor sample R2. Again unordinary modification in DNA nucleotides which can be possibly tumorous. If after trimming tumorous samples GC content wouldn't be on a sustained level, that means it's not a contamination and is indeed possibly a tumor.






After examining output after trimming of probable tumor samples it turns out that GC content hasn't changed and the conjecture about those samples being tumorous really was vindicated. Whereas control samples became clean and base quality graphs for all 4 samples are now at decent quality level.






Since the reads were done by ILLUMINA sequencer and their length is in-between range of 100-250 bp we will use Burrows-Wheeler Aligner - Maximal Exact MActhes (BWA-MEM) sequence alignment tool to align sequences to the reference human genome. Another reason why are we going to use this tool is the fact that it's robust and accurate for human or model-organism sequence alignment and is considered to be a standard in this sort of work. Successively, we would pipe down results of our BWA-MEM into samtools in order to convert enormous Sequence Alignment Map (SAM) files into their compact version, Binary Alignment Map (BAM). Later on the resulting BAM file would be sorted using samtools sorting tool, followed by  indexing of the sorted BAM file so we can access any chromosome with any gene in it instantenously using indexing file compiled from the sorted BAM file, Binary Alignment Indexed (BAI).






echo "Raw Data Quality Control Stage"

#these following 2 commands make reports on all 4 samples and save them into Quality_Assesment directory.
#the reports are saved into .html files so you can later view them visually in browser
fastqc $R1_C $R2_C -o Quality_Assessment/
fastqc $R1_T $R2_T -o Quality_Assessment/






#these commands are used to trim sample files
# -i flag denotes forward read input file
# -I flag denotes reversed read input file
# -o flag denotes forward read output file
# -O flag denotes forward read output file
# -w number_of_threads_value
# -l minimum_length_of_a_read_value
# -j path_for_json_summary
# -h path_for_html_summary

fastp -i $R1_C -I $R2_C \
      -o $R1_CO -O $R2_CO \
      -w 4 \
      -3 -5 \
      -W 4 -M 15 \
      -l 36 \
      -j /dev/null \
      -h /dev/null

fastp -i $R1_T -I $R2_T \
      -o $R1_TO -O $R2_TO\
      -w 4 \
      -3 -5 \
      -W 4 -M 15 \
      -l 36 \
      -j /dev/null \
      -h /dev/null






#these following 2 commands make reports on all 4 samples and save them into Quality_Assesment directory.
#the reports are saved into .html files so you can later view them visually in browser
fastqc $R1_CO $R2_CO -o Quality_Assessment/
fastqc $R1_TO $R2_TO -o Quality_Assessment/





echo "Read Alignment Stage"

#following command is used to index the reference genome so later on the reference database can be used for alignment of both fasta files
bwa index $HG_38






#command for aligning R1 and R2 control sequences using reference genome
#followed by samtools conversion command SAM -> BAM
#followed by samtools sort command to sort BAM file

# -M flag notifies older versions of variant calling tools about secondary reads instead of supplementary reads
# -R acts as a header and is used for variant calling, sometimes is very useful in correcting errors
# -view command tells samtools to convert from SAM to BAM
# -Sb flags shows samtools between which file formats conversion is required
# -sort command tells samtools to sort BAM file so each sequence appears in the order it is found in reference genome
# -@ number_of_threads this flag specifies number of threads that must be used to sort the BAM file
# -o flag tells where and under which name to save the output file
bwa mem -t 4 \
	-M \
	-R "@RG\tID:P14_C\tSM:P14\tLB:P14_C_LB\tPL:ILLUMINA" \
	$HG_38 \
	$R1_CO $R2_CO > \
	samtools view -Sb -o CA.bam






#command for aligning R1 and R2 control sequences using reference genome
#followed by samtools conversion command SAM -> BAM
#followed by samtools sort command to sort BAM file

# -M flag notifies older versions of variant calling tools about secondary reads instead of supplementary reads
# -R acts as a header and is used for variant calling, sometimes is very useful in correcting errors
# -view command tells samtools to convert from SAM to BAM
# -Sb flags shows samtools between which file formats conversion is required
# -sort command tells samtools to sort BAM file so each sequence appears in the order it is found in reference genome
# -@ number_of_threads this flag specifies number of threads that must be used to sort the BAM file
# -o flag tells where and under which name to save the output file
bwa mem -t 4 \
	-M \
	-R "@RG\tID:P14_T\tSM:P14\tLB:P14_T_LB\tPL:ILLUMINA" \
	$HG_38 \
	$R1_TO $R2_TO > \
	samtools view -Sb -o TA.bam






#generate statistics for indexing verification
samtools flagstat Data/CA.bam
samtools flagstat Data/TA.bam





echo "Data Cleaning Stage"

#following command sorts bam file in 4 threads
samtools sort -@ 4 -o Data/Read_Alignment/CA.bam
#following command indexes output bam file creating BAI file with indices
samtools index Data/Read_Alignment/CA.bam



#following command sorts bam file in 4 threads
samtools sort -@ 4 -o Data/Read_Alignment/TA.bam
#following command indexes output bam file creating BAI file with indices
samtools index Data/Read_Alignment/TA.bam




echo "Post-Alignment Quality Control Stage"

echo "Variant Calling Stage"

echo "Post-Processing and Annotation Stage"

echo "Reporting Stage"
