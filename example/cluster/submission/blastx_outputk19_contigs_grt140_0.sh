
#!/bin/bash
#$ -S /bin/bash

export PATH=${PATH}:/ugi/data/sofia/Illumeta/exec/blast-2.2.24/bin
export PERL5LIB=${PERL5LIB}:/ugi/data/sofia/Illumeta/exec/bioperl-live

perl /ugi/data/sofia/Illumeta/scripts/blastx_Viralcontigs_nr.pl  results/velvet/outputk19_contigs_grt140.txt results k19  0 2  /ugi/home/shared/sofia/reference_seq/nr/nr.faa


