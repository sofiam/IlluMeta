
#!/bin/bash
#$ -S /bin/bash

date ##to measure the duration





export PERL5LIB=${PERL5LIB}:/ugi/data/sofia/IlluMeta/exec/bioperl-live

perl /ugi/data/sofia/IlluMeta/scripts/extract_largeContigs.pl  results/velvet/output_k19/contigs.fa results k19 150



export PERL5LIB=${PERL5LIB}:/ugi/data/sofia/IlluMeta/exec/bioperl-live

perl /ugi/data/sofia/IlluMeta/scripts/extract_largeContigs.pl  results/velvet/output_k17/contigs.fa results k17 150



export PERL5LIB=${PERL5LIB}:/ugi/data/sofia/IlluMeta/exec/bioperl-live

perl /ugi/data/sofia/IlluMeta/scripts/extract_largeContigs.pl  results/velvet/output_k15/contigs.fa results k15 150

