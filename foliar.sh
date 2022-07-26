#!/bin/bash
#SBATCH --time=48:00:00
#SBATCH --account=def-mstrom
#SBATCH --mail-user=zhe.xie@mail.mcgill.ca
#SBATCH --mail-type=ALL
#SBATCH --cpus-per-task=8
#SBATCH --mem-per-cpu=125G

module load perl/5.30.2
module load gcc/9.3.0

dos2unix list_of_ids.txt

for line in `cat list_of_ids.txt`; do

	COUNTS=${line}.tsv
	FASTQ1=${line}_1.fastq
	FASTQ2=${line}_2.fastq
	TRIMMED_FASTQ1=${line}_1_val_1.fq
	TRIMMED_FASTQ2=${line}_2_val_2.fq
	SAM=${line}.sam
	SORTED_SAM=${line}.sorted.sam
	SORTED_BAM=${line}.sorted.bam
	QUANT=${line}_quant
	
	perl /home/zhexie/projects/def-mstrom/tuber_transcriptome_project/TrimGalore-0.6.7/trim_galore --dont_gzip -o /home/zhexie/projects/def-mstrom/tuber_transcriptome_project/foliar --paired --path_to_cutadapt /home/zhexie/projects/def-mstrom/tuber_transcriptome_project/ENV/bin/cutadapt ${FASTQ1} ${FASTQ2};
	
	/home/zhexie/projects/def-mstrom/tuber_transcriptome_project/hisat2-2.2.1/hisat2 -p 8 -q -x /home/zhexie/projects/def-mstrom/tuber_transcriptome_project/input/ATL_v2.0_index/ATL -1 /home/zhexie/projects/def-mstrom/tuber_transcriptome_project/foliar/${TRIMMED_FASTQ1} -2 /home/zhexie/projects/def-mstrom/tuber_transcriptome_project/foliar/${TRIMMED_FASTQ2} -S ${SAM};
	
	samtools sort ${SAM} -o ${SORTED_SAM};

	samtools view -bS ${SORTED_SAM} > ${SORTED_BAM};
	
	samtools flagstat ${SORTED_BAM};
	
	featureCounts -F ‘GTF’ -p --countReadPairs -a atl.hc.pm.locus_assign.gtf -o ${COUNTS} ${SORTED_BAM};
	
	salmon quant -i /home/zhexie/projects/def-mstrom/tuber_transcriptome_project/foliar/atl.transcriptome.index -l A --gcBias -1 /home/zhexie/projects/def-mstrom/tuber_transcriptome_project/foliar/${TRIMMED_FASTQ1} -2 /home/zhexie/projects/def-mstrom/tuber_transcriptome_project/foliar/${TRIMMED_FASTQ2} -o ${QUANT};

	rm ${line}_1_trimmed.fq;
	rm ${line}_2_trimmed.fq;
	rm ${line}.sorted.sam;
	rm ${line}.sam;
done;
