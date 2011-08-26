
#!/bin/bash
#$ -S /bin/bash

export PATH=${PATH}:/ugi/data/sofia/Illumeta/exec/blast-2.2.24/bin
export PERL5LIB=${PERL5LIB}:/ugi/data/sofia/Illumeta/exec/bioperl-live

perl /ugi/data/sofia/Illumeta/scripts/NM_blastx.pl  results/blastn/NM_paired_example_nonOverlapping_filtered.txt results NM_paired_example_nonOverlapping_filtered  0 10000 /ugi/data/vincent/sequence_database/viral/viral.protein.faa


