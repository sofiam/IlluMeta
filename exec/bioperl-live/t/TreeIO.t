# -*-Perl-*-
## Bioperl Test Harness Script for Modules
## $Id: TreeIO.t,v 1.14.2.1 2003/09/14 19:00:35 jason Exp $

# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl test.t'

my $error = 0;

use strict;
BEGIN {     
    # to handle systems with no installed Test module
    # we include the t dir (where a copy of Test.pm is located)
    # as a fallback
    eval { require Test; };
    if( $@ ) {
	use lib 't';
    }

    use Test;
    plan tests => 17; 

#    eval { require XML::Parser::PerlSAX; };
#    if( $@ ) {
#	print STDERR "XML::Parser::PerlSAX not loaded. This means TreeIO::phyloxml test cannot be executed. Skipping\n";
#	foreach ( 1..43 ) {
#	    skip(1,1);
#	}
#       $error = 1;
#	
#    } 

}

if( $error == 1 ) {
    exit(0);
}

use vars qw($FILE1 $FILE2);

$FILE1= 'testnewick.phylip';
$FILE2= 'testlarge.phy';

END { 
	unlink $FILE1;
	unlink $FILE2;
}
use Bio::TreeIO;
use Bio::Root::IO;
my $verbose = $ENV{'BIOPERLDEBUG'} || 0;

my $treeio = new Bio::TreeIO(-verbose => $verbose,
			     -format => 'newick',
			     -file   => Bio::Root::IO->catfile('t','data', 
							       'cysprot1b.newick'));

ok($treeio);
my $tree = $treeio->next_tree;

ok(ref($tree) && $tree->isa('Bio::Tree::TreeI'));

my @nodes = $tree->get_nodes;
ok(@nodes, 6);

if($verbose ) { 
    foreach my $node ( $tree->get_root_node()->each_Descendent() ) {
	print "node: ", $node->to_string(), "\n";
	my @ch = $node->each_Descendent();
	if( @ch ) {
	    print "\tchildren are: \n";
	    foreach my $node ( $node->each_Descendent() ) {
		print "\t\t ", $node->to_string(), "\n";
	    }
	}
    }
}
$treeio = new Bio::TreeIO(-verbose => $verbose,
			  -format => 'newick', 
			  -file   => ">$FILE1");
$treeio->write_tree($tree);
undef $treeio;
ok( -s $FILE1 );
$treeio = new Bio::TreeIO(-verbose => $verbose,
			  -format => 'newick',
			  -file   => Bio::Root::IO->catfile('t','data', 
							    'LOAD_Ccd1.dnd'));
ok($treeio);
$tree = $treeio->next_tree;

ok(ref($tree) && $tree->isa('Bio::Tree::TreeI'));

@nodes = $tree->get_nodes;
ok(@nodes, 52);

if($verbose ) { 
    foreach my $node ( @nodes ) {    
	print "node: ", $node->to_string(), "\n";
	my @ch = $node->each_Descendent();
	if( @ch ) { 
	    print "\tchildren are: \n";
	    foreach my $node ( $node->each_Descendent() ) {
		print "\t\t ", $node->to_string(), "\n";
	    }
	}
    }
}

ok($tree->total_branch_length, 7.12148);
$treeio = new Bio::TreeIO(-verbose => $verbose,
			  -format => 'newick', 
			  -file   => ">$FILE2");
$treeio->write_tree($tree);
undef $treeio;
ok(-s $FILE2);
$treeio = new Bio::TreeIO(-verbose => $verbose,
			  -format  => 'newick',
			  -file    => Bio::Root::IO->catfile('t','data','hs_fugu.newick'));
$tree = $treeio->next_tree();
@nodes = $tree->get_nodes();
ok(@nodes, 5);
# no relable order for the bottom nodes because they have no branchlen
my @vals = qw(SINFRUP0000006110);
my $saw = 0;
foreach my $node ( $tree->get_root_node()->each_Descendent() ) {
	foreach my $v ( @vals ) {
	   if( defined $node->id && 
	       $node->id eq $v ){ $saw = 1; last; }
	}
	last if $saw;
}
ok($saw, 1, "Did not see $vals[0] as expected\n");
if( $verbose ) {
    foreach my $node ( @nodes ) {
	print "\t", $node->id, "\n";
    }
}

$treeio = new Bio::TreeIO(-format => 'newick', 
			  -fh => \*DATA);
my $treeout = new Bio::TreeIO(-format => 'tabtree');
my $treeout2 = new Bio::TreeIO(-format => 'newick');

$tree = $treeio->next_tree;

if( $verbose > 0  ) {
    $treeout->write_tree($tree);
    $treeout2->write_tree($tree);
}

$treeio = new Bio::TreeIO(-verbose => $verbose,
			  -file   => Bio::Root::IO->catfile('t','data', 
							    'test.nhx'));

ok($treeio);
$tree = $treeio->next_tree;

ok(ref($tree) && $tree->isa('Bio::Tree::TreeI'));

@nodes = $tree->get_nodes;
ok(@nodes, 13, scalar @nodes);

my $adhy = $tree->find_node('ADHY');
ok($adhy->branch_length, 0.1);
ok(($adhy->get_tag_values('S'))[0], 'nematode');
ok(($adhy->get_tag_values('E'))[0], '1.1.1.1');

__DATA__
(((A:1,B:1):1,(C:1,D:1):1):1,((E:1,F:1):1,(G:1,H:1):1):1);
