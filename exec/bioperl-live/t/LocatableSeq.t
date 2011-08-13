# -*-Perl-*-
## Bioperl Test Harness Script for Modules
## $Id: LocatableSeq.t,v 1.7.2.1 2003/03/31 11:49:51 heikki Exp $
use strict;
use constant NUMTESTS => 33;

BEGIN {
    eval { require Test; };
    if( $@ ) {
	use lib 't';
    }
    use Test;

    plan tests => NUMTESTS;
}
use Bio::LocatableSeq;
ok(1);
use Bio::SimpleAlign;
use Bio::AlignIO;
use Bio::Root::IO;

my ($str, $aln, $seq, $loc);

ok $seq = new Bio::LocatableSeq(
			     -seq => '--atg---gta--',
			     -start => 1,
			     -end => 6,
			     -strand => 1,
			     -alphabet => 'dna'
			     );
ok $seq->alphabet, 'dna';
ok $seq->start, 1;
ok $seq->end, 6;
ok $seq->strand, 1;
ok $seq->no_gaps, 1;
ok $seq->column_from_residue_number(4), 9;

ok $loc = $seq->location_from_column(4);
ok $loc->isa('Bio::Location::Simple');
ok $loc->to_FTstring, 2;

ok $loc = $seq->location_from_column(6);
ok $loc->isa('Bio::Location::Simple');
ok $loc->start, 3;
ok $loc->location_type, 'IN-BETWEEN';
ok $loc->to_FTstring, '3^4';


ok $loc = $seq->location_from_column(2), undef;


$str = Bio::AlignIO->new(-file=> Bio::Root::IO->catfile("t","data","testaln.pfam"));
ok defined($str) && ref($str) && $str->isa('Bio::AlignIO');
$aln = $str->next_aln();
ok $seq = $aln->get_seq_by_pos(1);
ok ref($seq), 'Bio::LocatableSeq';

ok $seq->get_nse, '1433_LYCES/9-246';
ok $seq->id, '1433_LYCES';

# test revcom and trunc

$seq = new Bio::LocatableSeq(
			     -seq => '--atg---gta--',
			     -start => 1,
			     -end => 6,
			     -strand => 1,
			     -alphabet => 'dna'
			     );

my $seq2 = $seq->trunc(1,9);
ok $seq2->seq, '--atg---g';
ok $seq2->start, 1;
ok $seq2->end, 4;
ok $seq2->strand, $seq->strand;

$seq2 = $seq->trunc(3,8);
ok $seq2->seq, 'atg---';
ok $seq2->start, 1;
ok $seq2->end, 3;


$seq2 = $seq->revcom();
ok $seq2->seq, '--tac---cat--';
ok $seq2->start, $seq->start;
ok $seq2->end, $seq->end;
ok $seq2->strand, $seq->strand * -1;
