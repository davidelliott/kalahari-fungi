#!/usr/bin/perl

open(FILE, "UNITE_phylum_unidentified_accessions.txt") or die("Unable to open file");
@toremove = <FILE>;
close(FILE);

$fas = "sh_refs_qiime_ver7_97_02.03.2015.fasta";
$fas_out = "sh_refs_qiime_ver7_97_02.03.2015_phylum_unidentified_removed.fasta";
open(FILE, $fas) or die("Unable to open file");
@target = <FILE>;
close(FILE);

print "There are ".scalar(@toremove)." items to be searched for, ";

print "In a ".scalar(@target)." item list.\n";

foreach $item (@toremove)
{
	for ($i = 0 ; $i < scalar(@target); $i++) {
		if($target[$i] =~ /$item/) {
			#print "Match for ".$item." on line ".$i."\n";
			delete $target[$i+1];
			delete $target[$i];
			$i--;
		}
	}

}

foreach ( @target )
{
    open FH, ">>$fas_out" or die "can't open '$fas_out': $!";
 
    print FH $_;
 
    close FH;
}

