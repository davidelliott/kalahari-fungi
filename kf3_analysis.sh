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
cat data/*.fastq > data/kf.fq
python ~/drive5_py/fastq_strip_barcode_relabel2.py data/kf.fq CTTGGTCATTTAGAGGAAGTAA kf3_barcodes_with_tcag.fa F > data/kf_stripped.fq

usearch -fastq_stats data/kf_stripped.fq -log stats.log

# The fastq_eestats command reports statistics on quality scores and expected errors.
usearch -fastq_eestats data/kf_stripped.fq -output eestats.txt

# Quality filter, length truncate, covert to FASTA
# the aim here is to try and obtain long sequences for best phylogenetic resolution

# trunclen 350 maxee 1: 66.3 % seqs kept
# usearch -fastq_filter kf_stripped.fq -fastq_maxee 1 -fastq_trunclen 350 -fastaout reads_ee1_tl350.fa

# trunclen 400 maxee 1: 53.9 % seqs kept
usearch -fastq_filter data/kf_stripped.fq -fastq_maxee 1 -fastq_trunclen 400 -fastaout reads.fa

# Dereplication
usearch -derep_fulllength reads.fa -fastaout derep.fa -sizeout

# Abundance sort and discard singletons
usearch -sortbysize derep.fa -fastaout sorted.fa -minsize 2

# ITSx
ITSx -i sorted.fa -o sorted.itsx.fa

# OTU clustering
usearch -cluster_otus sorted.fa -otus otus1.fa -relabel OTU_ -sizeout -uparseout cluster_results.txt

# Chimera filtering using reference database
# UNITE=~/taxonomy/unite_15.01.2014/sh_refs_qiime_ver6_97_s_15.01.2014.fasta

usearch -uchime_ref otus1.fa -db taxonomy/unite_its2.fa -strand plus -nonchimeras otus2.fa

# Label OTU sequences OTU_1, OTU_2...
python ~/drive5_py/fasta_number.py otus2.fa OTU_ > otus.fa

# Map reads (including singletons) back to OTUs
usearch -usearch_global reads.fa -db otus.fa -strand plus -id 0.97 -uc map.uc

# Assign taxonomy to the OTUs using utax (currently unpublished method)
# usearch -utax otus.fa -db ../taxonomy/unite_its2.fa -taxconfs ../taxonomy/its2.tc -tt ../taxonomy/unite.tt -utaxout tax.txt

# assign taxonomy by BLAST using the UNITE database
/usr/lib/qiime/bin/assign_taxonomy.py -i otus.fa -o assigned_taxonomy -m blast -t taxonomy/unite_02.03.2015/sh_taxonomy_qiime_ver7_97_02.03.2015.txt -r taxonomy/unite_02.03.2015/sh_refs_qiime_ver7_97_02.03.2015.fasta

/usr/lib/qiime/bin/assign_taxonomy.py -i otus.fa -o assigned_taxonomy_filtered -m blast -t taxonomy/unite_02.03.2015/sh_taxonomy_qiime_ver7_97_02.03.2015.txt -r taxonomy/unite_02.03.2015/sh_refs_qiime_ver7_97_02.03.2015_phylum_unidentified_removed.fasta

# record which OTU tax assignments were changed by filtering p__unidentified out of the UNITE database
diff assigned_taxonomy/otus_tax_assignments.txt assigned_taxonomy_filtered/otus_tax_assignments.txt > assigned_taxonomy_filtered/otus_tax_diff_filtered_unfiltered.txt

# adjust taxonomy file format
sed -i.original 's/;/\t/g' assigned_taxonomy/otus_tax_assignments.txt
cut -f 1-8 assigned_taxonomy/otus_tax_assignments.txt > assigned_taxonomy/otus_tax_assignments_mod.txt

sed -i.original 's/;/\t/g' assigned_taxonomy_filtered/otus_tax_assignments.txt
cut -f 1-8 assigned_taxonomy_filtered/otus_tax_assignments.txt > assigned_taxonomy_filtered/otus_tax_assignments_mod.txt

# Create OTU table
python ~/drive5_py/uc2otutab.py map.uc > otu_table.txt

# convert OTU table
biom convert -i otu_table.txt -o otu_table.biom --table-type="OTU table" --to-json



