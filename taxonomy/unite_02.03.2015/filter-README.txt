Run command:
grep 'k__Fungi;p__unidentified' sh_taxonomy_qiime_ver7_97_02.03.2015.txt > UNITE_phylum_unidentified.txt

This creates a file with all the unknown accessions in, like: 
manager@bl8vbox[unite_02.03.2015] head UNITE_phylum_unidentified.txt                                                        [ 7:35PM]
SH000013.07FU_JX134667_refs	k__Fungi;p__unidentified;c__unidentified;o__unidentified;f__unidentified;g__unidentified;s__Slopeiomyces cylindrosporus
SH000297.07FU_HQ611278_reps	k__Fungi;p__unidentified;c__unidentified;o__unidentified;f__unidentified;g__unidentified;s__Fungi sp
SH000339.07FU_EU687145_reps	k__Fungi;p__unidentified;c__unidentified;o__unidentified;f__unidentified;g__unidentified;s__Fungi sp
SH000496.07FU_AY528998_refs	k__Fungi;p__unidentified;c__unidentified;o__unidentified;f__unidentified;g__unidentified;s__Huntiella moniliformopsis
SH000550.07FU_KC965911_reps	k__Fungi;p__unidentified;c__unidentified;o__unidentified;f__unidentified;g__unidentified;s__Fungi sp
SH000589.07FU_LK052787_reps	k__Fungi;p__unidentified;c__unidentified;o__unidentified;f__unidentified;g__unidentified;s__Fungi sp
SH000598.07FU_EU490148_reps	k__Fungi;p__unidentified;c__unidentified;o__unidentified;f__unidentified;g__unidentified;s__Fungi sp
SH001049.07FU_EF558809_reps	k__Fungi;p__unidentified;c__unidentified;o__unidentified;f__unidentified;g__unidentified;s__Fungi sp
SH001366.07FU_AY598883_reps	k__Fungi;p__unidentified;c__unidentified;o__unidentified;f__unidentified;g__unidentified;s__Fungi sp
SH001438.07FU_EU479748_reps	k__Fungi;p__unidentified;c__unidentified;o__unidentified;f__unidentified;g__unidentified;s__Fungi sp

You need to get all those accessions out into a list without the other text, the following command should do it:
sed 's/\t.*//' UNITE_phylum_unidentified.txt > UNITE_phylum_unidentified_accessions.txt

Now you end up with a simple accesssion list:
manager@bl8vbox[unite_02.03.2015] head UNITE_phylum_unidentified_accessions.txt                                             [ 7:36PM]
SH000013.07FU_JX134667_refs
SH000297.07FU_HQ611278_reps
SH000339.07FU_EU687145_reps
SH000496.07FU_AY528998_refs
SH000550.07FU_KC965911_reps
SH000589.07FU_LK052787_reps
SH000598.07FU_EU490148_reps
SH001049.07FU_EF558809_reps
SH001366.07FU_AY598883_reps
SH001438.07FU_EU479748_reps

Now you can run perl filter.pl
It will take a while. Please check the output before believing it worked right!
You can obviously use this approach for any accesssion list. Be careful, I think it might not work properly if there are any duplicated accession numbers.



