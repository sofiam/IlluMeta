
#$ENV{'PATH'} = '/bin:/ugi/data/sofia/Illumeta/exec/blast-2.2.24/bin'; 


use warnings;
use strict;



use Bio::SeqIO::fasta;
use Bio::Tools::Run::StandAloneBlast;
use Bio::SearchIO;

my $inputData = $ARGV[0];
my $outputdir = $ARGV[1];
my $type = $ARGV[2];
my $start = $ARGV[3];
my $end = $ARGV[4];
my $dbViral = $ARGV[5];
my $numArgs = $#ARGV + 1;

print $numArgs, " ", $inputData ," ",$outputdir, " ", $type, " ", $start, " ", $end, "\n";


my $count = 0;


open(IN,  "$inputData") or die "cannot open input file\n";


my $resFile = ${outputdir}."/blastx/subsetted/".$type."_".$start."_".$end."_vs_viral.txt";

open (OUT2, " > $resFile") or die "cannot open output file\n";
print "Output in $resFile\n";


########### first blast
my @params = (program  => 'blastx',
	      database => $dbViral);

my $blast_obj = Bio::Tools::Run::StandAloneBlast->new(@params);


while (<IN>){
(my $l1, my $l2) = split("\t");
chomp($l1);
chomp($l2);

      my $reportobj;
      my $resultobj;


      my $skip = 0; 

      $count = $count + 1;
      if ($count < $start) {$skip = 1;}
      if ($count>=$end){last;}
      


      if ($skip == 0) {

	  ############### Now run blastx for viruses
	  my $seq_obj = Bio::Seq->new(-id  => $l1,
				      -seq => $l2);
	  eval {
	    $reportobj = $blast_obj->blastall($seq_obj);
	};
	  if ($@) {
	       print OUT2 $l1, "\t", "Failed_LC\n";
	      $skip = 1;
	  };

	  



##when several positions match within the same protein, only keep the first

	  if ($skip == 0) {
	      while( $resultobj = $reportobj ->next_result ){
		  while( my $hit = $resultobj -> next_hit){
		      while( my $hsp = $hit-> next_hsp){
			  my $nhits = $resultobj->num_hits;
                          my $vscore;
			  my $hit_name;
			  my $hit_description;
			  my $hsp_length;
			  my $percent_id;
			  my $e_value;
                          my $hsp_rank;
			  my $start_query;
			  my $end_query;
			  my $start_hit;
			  my $end_hit;
			  $vscore =  $hsp->score;
			  $hit_name = $hit->name;
			  $hit_description = $hit->description;   
			  $hsp_length = $hsp->length('total');
			  $percent_id = $hsp->percent_identity;
                          $hsp_rank = $hsp -> rank;
			  $e_value=$hsp->evalue;
  			  $start_query = $hsp->start('query');
                          $end_query = $hsp -> end('query');
                          $start_hit = $hsp -> start('hit');
                          $end_hit = $hsp -> end('hit'); 
			  
			  if ($hsp_rank<2){
                        
			  
			  print OUT2 $l1, "\t", $l2, "\t",  $nhits, "\t", $hit_name, "\t", $hit_description, "\t", $vscore, "\t", $hsp_length, "\t", $percent_id, "\t",                                      $e_value, "\t", $hsp_rank, "\t", $start_query, "\t", $end_query, "\t", $start_hit, "\t", $end_hit, "\n";
                           
                       
		          
		      }
		  }
	      }
	  }
      }
  }

}



