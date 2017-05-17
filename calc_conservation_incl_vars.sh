#!/bin/sh

dir=$HOME

if [ -z $(which psiblast) ]; then
    export PATH=$PATH:$dir/blast/ncbi-blast-2.6.0+/bin 
fi
export BLASTDB=$dir/blast/db
if [ -z $(which muscle) ]; then
    export PATH=$PATH:$dir/muscle
fi
export CONSERVATION_HOME=$dir/conservation_code
if [ -z $(which cd-hit) ]; then 
    export PATH=$PATH:$dir/cd-hit
fi

sh calc_conservation.sh $@
