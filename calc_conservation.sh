#!/bin/sh

# reads fasta file with only one sequence from file $1.

file=$1

# Create bunch of temp files.
blastResFile=$(tempfile)
blastSeq=$(tempfile)
modifiedInputFile=$(tempfile)

# change this if you don't want to create extra file with MSA.
muscleResultFile=${file}.muscle.fasta
conservationExtractorInput=$(tempfile)

# Function that searches a database and filters the results $1 - database name for psiblast
search () {
    db=$1

    # Run PSI-BLAST to find ids all similar sequences.
    psiblast < $file -db $db -outfmt '6 sallseqid qcovs pident' -evalue 1e-5 | ./filter.awk > $blastResFile

    # Get full sequences.
    blastdbcmd -db $db -entry_batch $blastResFile > $blastSeq

    # Filter using CD-HIT.
    cd-hit -i $blastSeq -o $blastResFile >&2
}

# Search for similar sequences in SwissProt db.
search swissprot
# Get number of sequences found.
numSeq=$(grep < $blastResFile '^>' | wc -l)

# If less than 50 seqs found, fallback to search in UniRef90.
[ $((numSeq >= 50)) = 0 ] && search uniref90

# Change the description from the file to find it later.
sed < $file 's/^>/>query_sekvence|/' > $modifiedInputFile

# Run muscle. Note we need to concat the query sequence in order to get its conservation later.
cat $blastResFile $modifiedInputFile | muscle > $muscleResultFile

# conservationExtractorInput should look somewhat like this:
# number: >Sequence header 
# .
# query sequence has query_sekvence prefix that will be removed later in awk script.
# .
grep < $muscleResultFile '^>' | nl > $conservationExtractorInput
# >separator for awk to know that this is EOF
echo ">separator" >> $conservationExtractorInput

# Run conservation script (Jensen-Shannon divergence: http://compbio.cs.princeton.edu/conservation/)
# Remove | head -n 1 | sed ... if you have more than chain in the fasta file
python score_conservation.py $muscleResultFile  | cat $conservationExtractorInput - | ./getCol.awk | gzip

#rm $muscleResultFile
rm $modifiedInputFile
rm $blastSeq
rm $blastResFile
rm $conservationExtractorInput
