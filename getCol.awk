#!/usr/bin/awk -f

#Reads muscle result and conservation score from stdin separated by \">separator\" line and prints scores for a particular columns to stdout.

BEGIN {
    # Input should begin with muscle file
    readingMuscle=1
    FS=">"
    colsLen = 0
}

# Remember the number(index) of query sequences (all chains).
/>query_sekvence/ {
    if (readingMuscle) {
        num = $1
        name = $2
        sub("query_sekvence[|]", "", name)
        sub("[,]", "_", name)

        # remember each chain position and name
        names[++colsLen] = name
        cols[colsLen] = num
        next
    }
}


# When the separator line is read, switch readingMuscle variable
/^>separator/ {
    readingMuscle=0
    FS=" "
    scores = "Score"
    for (i = 1; i <= colsLen; i++) {
        seqs[i] = names[i]
    }
    next
}

#ignore comments and empty lines
/^[^#]/ {
    if (!readingMuscle) { 
        col_num = $1
        score = $2
        seq = $3

        allEmpty = 1
        for (i = 1; i <= colsLen; i++) {
            val[i] = substr($3, cols[i], 1)
            if (allEmpty && val[i] != "-") { 
                allEmpty = 0
            }
        }

        if (!allEmpty) {
            scores = scores "," score
            for (i=1; i<=colsLen; i++) {
               seqs[i] = seqs[i] "," val[i] 
            }
        }
    }
}

END {
    print scores
    for (i=1; i<= colsLen; i++) {
        print seqs[i]
    }
}
