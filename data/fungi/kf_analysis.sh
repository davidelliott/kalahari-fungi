#
# Preparation of source files
# these commands run in the raw_data folder
#
# rename sff files to something shorter
# (this was run in folder "raw_data")
# rename 's/454Reads\.//' *.sff
# rename 's/-ITS//' *.sff
#
# extract sff to fastq.
# The min_frequency arg is to suppress a warning about all of the sequences being similar - which is nothing to worry about in an amplicon experiment
#
# for file in *
# do
#   sff_extract --min_frequency 100 $file
# done
# 
# deal with a duplicated barcode shared by SG2cM and GF3sM: ACTATGGA
# replace the barcode with CGTCGATA for sample GF3sM:
# sed -i.original 's/tcagactatggaCT/tcagcgtcgataCT/g' SG2_D0-1273.fastq
# See setup.txt for information on obtaining UPARSE program and scripts

# strip barcodes and relabel fastq
cat fastq/*.fastq > fastq/kf.fq
python ~/drive5_py/fastq_strip_barcode_relabel2.py fastq/kf.fq CTTGGTCATTTAGAGGAAGTAA kf_barcodes_with_tcag.fa F > fastq/kf_stripped.fq

# fastq stats and eestats. The fastq_eestats command reports statistics on quality scores and expected errors.
usearch -fastq_stats fastq/kf_stripped.fq -log stats.log
usearch -fastq_eestats fastq/kf_stripped.fq -output eestats.txt

# Quality filter, length truncate, covert to FASTA
# Truncation length was determined by examining output of ITSx after running this pipeline without much truncation.
# Truncation was set to a minimum value (340) that ensures the ITS1 region is kept for all sequences
usearch -fastq_filter fastq/kf_stripped.fq -fastq_maxee 1 -fastq_trunclen 340 -fastaout reads.fa

# To run the commands above this point it would be necessary to obtain the raw sequence data from NCBI SRA BioProject PRJNA305652
# For the commands below this point, needed input files and some key outputs are provided in the repository.

# Dereplication
usearch -derep_fulllength reads.fa -fastaout derep.fa -sizeout

# Abundance sort and discard singletons
usearch -sortbysize derep.fa -fastaout sorted.fa -minsize 2

# Use ITSx to extract the ITS1 region of interest, keeping only fungi
# http://drive5.com/usearch/manual/pipe_readprep_trim.html
# It is ok for reads of different biological sequences to have different lengths because of natural variation in the length of the gene or region. See trimming for fungal ITS.
#  ITS amplicons have large variations in length due to the biology of the region -- some of the sequence evolves neutrally, and long indels are common.
# The goal of global trimming is to ensure that reads from the same species, or closely related species, have few or no terminal gaps when aligned to each other
ITSx -i sorted.fa -o sorted.itsx.fa --preserve T -t F --cpu 3


####                    Updates for usearch v10.0.240_i86linux32
# clustering OTUs and ZOTUs
# OTU clustering (using ITS1 only. Not trimmed further because length heterogeneity is biological)
# http://www.drive5.com/usearch/manual10/pipe_otus.html
# http://drive5.com/usearch/manual/cmd_cluster_otus.html
# The cluster_otus command performs 97% OTU clustering using the UPARSE-OTU algorithm.
# Chimeras are filtered by this command. This chimera filtering is much better than using UCHIME so I do not recommend using reference-based chimera filtering as a post-processing step, except as a manual check, because false positives are common.

usearch -fastx_uniques sorted.itsx.fa.ITS1.fasta -fastaout uniques.fa -sizeout -relabel Uniq
usearch -cluster_otus sorted.itsx.fa.ITS1.fasta -otus otus.fa -relabel OTU_ -uparseout cluster_results.txt

# make otu tables
# http://www.drive5.com/usearch/manual10/pipe_otutab.html
usearch -otutab reads.fa -otus otus.fa -otutabout otutab.txt -mapout otumap.txt

# convert otu table
biom convert -i otutab.txt -o otutab.biom --table-type="OTU table" --to-json






