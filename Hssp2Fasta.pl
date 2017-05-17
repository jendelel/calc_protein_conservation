#!/usr/bin/perl
#################################################
#                                               #
# Name       : HsspToFasta.pl                   #
#                                               #
# Description: This file translates HSSP File   #
#              To Fasta Format                  #
#                                               #
# Created By : Yossi Rosenberg & Fabian Glaser  #
#                                               #
# Date       : 11.12.2002                       #
#                                               #
#################################################


my $hssp_file = $ARGV[0]; 
my $hssp_files_dir = $ARGV[1];
my $fasta_files_dir = $ARGV[2];

die " Please enter the hssp file \n For example : \n HsspToFasta.pl xxxx.hssp \n" unless $hssp_file;



#=========================================================================
my $query_ID = $hssp_file;
   $query_ID =~ s/\.hssp//;
my $query_sequence_pos;  
my $alignment_sequence_first_pos;
my $chain_pos;
my @chains;
my $chain_no_declared='';
my $number_of_chains='';
my $chain_str='';
my $number_of_alignments;
my $alignment_no;
my $alignment_ID;
my $sequence_alignment;
my $from_sequence;
my $to_sequence;
my %msa = ();# msa{homolog_no} (1)  {homolog_ID} (2) {sequence_alignment}
my %proteins = ();# The key is protein ID and the value is protein number
my %proteinsIdx = (); # The key is protein number and the value is protein ID  
my $b_alignment=0;
my $counter=0;
my $m=0;
my $k=0;
#===========================================================================

if ($hssp_files_dir) {
$hssp_files_dir =~ s/\/$//;
$hssp_files_dir =~ s/(.*)/$1\//;
}

if ($fasta_files_dir) {
$fasta_files_dir =~ s/\/$//;
$fasta_files_dir =~ s/(.*)/$1\//;
}


$hssp_file = $hssp_files_dir . $query_ID . ".hssp";


open (HSSPFILE, "$hssp_file") or die  "cant open file : $hssp_file $!"; 


print "HsspToFasta - RUNNING ...\n";

while( <HSSPFILE> ) {

   if (/^\s*\#.*SEQUENCE\s+PROFILE\s+AND\s+ENTROPY\s*/){
    last;
   }

     
       



   if (/^\s*NALIGN\s+(\d+)/){ # matching no. of aligments
       $number_of_alignments = $1;
   }
   
   if (/^\s*(\d+)\s\:\s([A-Z|0-9|_]+)/){ # matching sequence no. and ID
  
	 $proteinsIdx{$1}=$2;

	 if ($proteins{$2}){
        	 $proteins{$2} .=',' . $1;
	     } else {
                 $proteins{$2} = $1; 
	       }

} 
   
   if (/\s*\#\#\s*ALIGNMENTS\s*([0-9]+)\s*\-\s*([0-9]+)\s*/){
       $b_alignment=1;
       $from_alignment=$1;
       $to_alignment=$2;
       $msa{query}{sequence_alignment}='';#this done to prevent repetition of the query_sequence
	   foreach  $chain (@chains) {
	       $msa{query}{$chain}{sequence_alignment} = '';
           }
   }
   
   if (/(^\s*SeqNo\s*PDBNo\s*AA.*)/){ # find the  positions of query and aligments sequences
       @line=split(//,$1);
       for ($i=0;$i<length($1);$i++) {
         $query_sequence_pos=$i if ($line[$i] eq 'A' && $line[$i+1] eq 'A');
         $alignment_sequence_first_pos = $i if ($line[$i] eq '.' && $line[$i-1] eq ' ');
         $chain_pos=$i if ($line[$i] eq 'o' && $line[$i-2] eq 'B');
       }   
   }
  
  
   if ( $b_alignment && !/SeqNo.*PDBNo/  && !/\s*\#\#\s*ALIGNMENTS.*/ && !/^\s*\d+\s*\!\s*\!/ && /^(\s*)(\d+)(.*)/){ # matching all sequence parameters
     $counter++;
     $line=$1 . $2 . $3;
    ## Cleaning the tags of HTML file 
       $line =~ s/&lt;/ /g;
       $line =~ s/&gt;/ /g;

    ## converting string to array
       @lines=split(//,$line);
        
       $sequential_no=$2;
       $query_sequence=$lines[$query_sequence_pos];
       $chain=$lines[$chain_pos];
       $chain_str .= $chain if $chain_str !~ /$chain/;

       if ($chain && $chain =~ /[^\s]/){
#	   $m++;
           $msa{query}{$chain}{sequence_alignment} .=   $query_sequence; 
       }
       else{
          
          $msa{query}{sequence_alignment} .=   $query_sequence;  
       }           

 #    $k=$k-($to_alignment-$from_alignment+2);
       for ($i=$from_alignment;$i<=$to_alignment;$i++){
           $sequence_position=$i-$from_alignment;
      
#in Hssp file there are several entries of the same protein 
#This pattern matching finds those entries 
	   my $entries=$proteins{$proteinsIdx{$i}};
           my $entry=$i;  
           

	   $lines[$alignment_sequence_first_pos+$sequence_position] =~ s/\s|\t|\./\-/;
           $lines[$alignment_sequence_first_pos+$sequence_position] = '-' unless $lines[$alignment_sequence_first_pos+$sequence_position];
           $sequence_char=$lines[$alignment_sequence_first_pos+$sequence_position];
               if ($chain && $chain =~ /[^\s]/){

                
                 if ($entries =~ /\,$entry/){
        #             print "msa{$proteinsIdx{$i}}{$chain}{sequence_alignment} = " . $msa{$proteinsIdx{$i}}{$chain}{sequence_alignment} . "\n";  
		     $msa{$proteinsIdx{$i}}{$chain}{sequence_alignment} =~ s/\-$/$sequence_char/;
 #                $k++; 
                 }else 
                  {             
                  
                  $k++; 
                         $msa{$proteinsIdx{$i}}{$chain}{sequence_alignment} = $msa{$proteinsIdx{$i}}{$chain}{sequence_alignment} . $sequence_char;
                  } 
              }else             
                 { 
                    if ($entries =~ /\,$entry/){
		       $msa{$proteinsIdx{$i}}{sequence_alignment} =~ s/\-$/$sequence_char/;
                    }else {              
	                $msa{$proteinsIdx{$i}}{sequence_alignment} = $msa{$proteinsIdx{$i}}{sequence_alignment} . $sequence_char;
		    }
                 }
       }

       
   } 
@chains = split('',$chain_str);
}




#close (HSSPFILE);
#print "chain_str = $chain_str \n";
#@chains = split('',$chain_str);

if ($chain_str && $chain_str =~ /[A-Za-z0-9]/){ 

   foreach $chain (@chains){

     $fasta_file = $fasta_files_dir . $query_ID . $chain . ".hssp.fasta";
     
      open (FASTAFILE, ">$fasta_file") || print "can't open $fasta_file";
   
     print FASTAFILE ">" . $query_ID . $chain . "\n";
     print FASTAFILE $msa{query}{$chain}{sequence_alignment} . "\n";
     
     foreach $protein_ID( %proteins) {
        
        if ($msa{$protein_ID}{$chain}{sequence_alignment} && $msa{$protein_ID}{$chain}{sequence_alignment} !~ /^\-+$/ ) {
	      print FASTAFILE   ">" . $protein_ID . "\n";
              $msa{$protein_ID}{$chain}{sequence_alignment} =~ s/\./\-/g; 
              print FASTAFILE  $msa{$protein_ID}{$chain}{sequence_alignment} . "\n"; 
        } 
     }
     close (FASTAFILE);
   }
}
 
else {
             $fasta_file = $fasta_files_dir . $query_ID . '_' . ".hssp.fasta";
            # print "fasta file : $fasta_file \n";
             open (FASTAFILE, ">$fasta_file") || print "can't open $fasta_file";
             print FASTAFILE ">" . $query_ID . "_" . "\n";
             print FASTAFILE $msa{query}{sequence_alignment} . "\n";
             foreach $protein_ID(%proteins){
               if ($msa{$protein_ID}{sequence_alignment} && $msa{$protein_ID}{sequence_alignment} !~ /^\-+$/ ) {
	           print FASTAFILE   ">" . $protein_ID . "\n";
                   $msa{$protein_ID}{sequence_alignment} =~ s/\./\-/g;
                   print FASTAFILE  $msa{$protein_ID}{sequence_alignment} . "\n"; 
               } 
             }
            close (FASTAFILE);   
         }

system   "chmod oug+w  $fasta_file";

$i=0;
#foreach $protein ( %proteins){
 #   print " $protein : $proteins{$protein} \n "; 
#    $i++;


#}
#foreach $protein (keys %proteinsIdx){
 #   print "idx -  $protein : $proteinsIdx{$protein} \n "; 
#    $i++;


#}

#print "number of homologs $i \n";

#print "query_ID : $query_ID \n";
print "The file : $hssp_file was translated to fasta format file :$fasta_file\nSUCCESSFULLY! \n";
