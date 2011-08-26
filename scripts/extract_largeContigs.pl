
use warnings;
use strict;


use Bio::SeqIO::fasta;
use Bio::SearchIO;

my $inputData=$ARGV[0];
my $outputdir=$ARGV[1];
my $kmer=$ARGV[2];
my $cutoffLength=$ARGV[3];
my $numArgs = $#ARGV + 1;

print "$numArgs,  Output directory is $outputdir, input dataset is $inputData, kmer chosen is $kmer \n";

open(IN,  "$inputData") or die "cannot open input file\n";


my $resFile = ${outputdir}."/velvet/output".$kmer."_contigs_grt150.txt";
open (OUT2, " > $resFile") or die "cannot open output file\n";
print "Output in $resFile\n";



my $resFile2 = ${outputdir}."/velvet/output".$kmer."_contigs_grt150.fa";
open (OUT3, " > $resFile2") or die "cannot open output file\n";
print "FASTA Output in $resFile2\n";




my $seqio = Bio::SeqIO->new(-file=> $inputData,-format => 'Fasta' );
while ( my $seq_obj = $seqio->next_seq()){
    my $read_id=$seq_obj->id;
    my $read_seq=$seq_obj->seq;
     
    
    my $length = (split /\_/, $read_id)[-3];

    my $kvalue = substr($kmer, 1, 2);

    my $realLength = $length+$kvalue-1 ;
    

    if ($realLength>=$cutoffLength){
	print OUT2 $read_id, "\t", $read_seq, "\n";      
	print OUT3 ">",$read_id, "\n", $read_seq, "\n";
    };
	  

}
