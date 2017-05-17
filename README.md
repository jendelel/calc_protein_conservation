# calc_protein_conservation
This script computes conservation score per aminoacid for a protein.

## Credits
Many thanks to authors of BLAST+ suite, CD-HIT, MUSCLE and Jensen-Shannon divergence method.
This script is based on [ConSurf DB](http://bental.tau.ac.il/new_ConSurfDB/overview.php) and [ConCavity paper](http://journals.plos.org/ploscompbiol/article?id=10.1371/journal.pcbi.1000585#s5)

## Preliminaries
### Installing all necessary tools
1. Download BLAST+ suite from [here](ftp://ftp.ncbi.nlm.nih.gov/blast/executables/blast+/LATEST/).
2. Install/unpack the BLAST+ archive and make sure your directory is PATH.
3. Download CD-HIT from [here](https://github.com/weizhongli/cdhit/releases).
4. Unpack CD-HIT archive, run make command and make sure cd-hit is in PATH.
5. Download MUSCLE from [here](http://www.drive5.com/muscle/downloads.htm).
6. Unpack MUSCLE archive and add the directory to PATH.
7. Download python script for Jensen-Shannon divergence method from [here](http://compbio.cs.princeton.edu/conservation/index.html).
8. Finally, unpack the pipeline archive from this repository.
9. Copy the archive contents to the directory where Python script for Jensen-Shannon divergence (`score_conservation.py`) is located.

### Installing databases

1. Create a directory where you want to store the databases.
2. Add environmental variable `BLASTDB={path to the directory}`
3. Change directory to BLASTDB directory and run these commands. Each command will download and parse one database. We recommend to use SwissProt and UniRef90, but using TrEBML instead of UniRef90 is also possible. Note that it will take a lot of time.

```
curl {UniRef90 URI} | gunzip | makeblastdb -out uniref90 -dbtype prot -title UniRef90 -parse_seqids

curl {SwissProt URI} | gunzip | makeblastdb -out swissprot -dbtype prot -title SwissProt -parse_seqids

curl {TrEMBL URI} | gunzip | makeblastdb -out trembl -dbtype prot -title TrEMBL -parse_seqids
```

# Running the script
1. cd to the directory where you copied `calc_conservation.sh`.
2. Run this command: ```./calc_conservation.sh {path to your fasta file}```

# How it works
PSIBLAST is ran with your fasta input on SwissProt database (1 iteration, eval=1e-5).   
The result is filtered (min 80% coverage and seq identity between 30% and 95%), then clustered with CD-HIT (default parameters).   
If we are left with less then 50 hits, repeat the same for UniRef90 database.  

Run MUSCLE and Jensen-Shannon divergence on the query hits.