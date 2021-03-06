#!/bin/bash

SCRIPTS_DIR=$(pwd)

checkMaxProj=$(command -v maximise_projection)
if [ ! -e $checkMaxProj ]
then
    echo "The program maximise_projection is not found."
    echo "Compile it and export its path to use the automatic orientation of the magnetic field."
#    exit
fi

pathToGimic=$(which gimic)
if [ -z $pathToGimic ]
then
    echo "The path to the GIMIC binary is not defined. Please add it to your .bashrc as"
    echo export PATH=\"/path/to/gimic/\":\${PATH}
fi


# Prepare the base structure of the squares profile script for a local machine:
file1="src/squares-profile-header"
file2="src/squares-profile-local-submit"
SCRIPT_OUT="src/squares-profile-local.sh.in"

if [ $SCRIPT_OUT -ot $file1 ] || [ $SCRIPT_OUT -ot $file2 ]  # [ FILE1 -ot FILE2 ]  -> True if FILE1 is older than FILE2, or is FILE2 exists and FILE1 does not.
then 
    cat src/squares-profile-header > $SCRIPT_OUT
    cat src/squares-profile-local-submit >> $SCRIPT_OUT
fi

# Prepare the base structure of the vertical profile script for a local machine:
file1="src/vertical-profile-header"
file2="src/current-profile-local-submit"
SCRIPT_OUT="src/vertical-profile-local.sh.in"

if [ $SCRIPT_OUT -ot $file1 ] || [ $SCRIPT_OUT -ot $file2 ]  
then 
    cat src/vertical-profile-header > $SCRIPT_OUT
    cat src/current-profile-local-submit >> $SCRIPT_OUT
fi


# Prepare the base structure of the current profile script for a local machine:
file1="src/current-profile-header"
file2="src/current-profile-local-submit"
SCRIPT_OUT="src/current-profile-local.sh.in"

if [ $SCRIPT_OUT -ot $file1 ] || [ $SCRIPT_OUT -ot $file2 ]
then 
    cat src/current-profile-header > $SCRIPT_OUT
    cat src/current-profile-local-submit >> $SCRIPT_OUT
fi

# Prepare the base structure  of the squares profile script for cluster

file1="src/squares-profile-header"
file2="src/squares-profile-cluster-submit"
SCRIPT_OUT="src/squares-profile-cluster.sh.in"

if [ $SCRIPT_OUT -ot $file1 ] || [ $SCRIPT_OUT -ot $file2 ] 
then 
    cat src/squares-profile-header > $SCRIPT_OUT
    cat src/squares-profile-cluster-submit >> $SCRIPT_OUT
fi

# Prepare the base structure  of the squares profile script for cluster

file1=squares-profile-header
file2=squares-profile-cluster-submit
file3=functions-def
SCRIPT_OUT="squares-profile-cluster.sh.in"

if [ $SCRIPT_OUT -ot $file1 ] || [ $SCRIPT_OUT -ot $file2 ] || [ $SCRIPT_OUT -ot $file3 ]
then 
    cat squares-profile-header > squares-profile-cluster.sh.in
    cat squares-profile-cluster-submit >> squares-profile-cluster.sh.in
fi

# Prepare the base structure  of the current profile script for cluster

file1="src/current-profile-header"
file2="src/current-profile-cluster-submit"
SCRIPT_OUT="src/current-profile-cluster.sh.in"

if [ $SCRIPT_OUT -ot $file1 ] || [ $SCRIPT_OUT -ot $file2 ] 
then 
    cat src/current-profile-header > $SCRIPT_OUT
    cat src/current-profile-cluster-submit >> $SCRIPT_OUT
fi


# Prepare the base structure  of the vertical profile script for cluster

file1="src/vertical-profile-header"
file2="src/current-profile-cluster-submit"
SCRIPT_OUT="src/vertical-profile-cluster.sh.in"

if [ $SCRIPT_OUT -ot $file1 ] || [ $SCRIPT_OUT -ot $file2 ] 
then 
    cat src/vertical-profile-header > $SCRIPT_OUT
    cat src/current-profile-cluster-submit >> $SCRIPT_OUT
fi


# Prepare the batch job scripts:

file="src/jobscript.IN"
SCRIPT_OUT=jobscript
sedstring="s:@SCRIPTS_DIR@:$SCRIPTS_DIR:"
if [ $SCRIPT_OUT -ot $file ] || [ $SCRIPT_OUT -ot src/jobscript-header ]
then 
    echo; echo "REMEMBER TO CHANGE THE BATCH SCRIPT jobscript-header TO SUIT YOUR CLUSTER BEFORE SETUP"
    cat src/jobscript-header > $SCRIPT_OUT
    sed "$sedstring" $file >> $SCRIPT_OUT
    echo "Created script $SCRIPT_OUT."
    chmod +x $SCRIPT_OUT
fi

# Prepare the batch job script for squares profile:

file="src/jobscript-squares.IN"
SCRIPT_OUT=jobscript-squares
sedstring="s:@SCRIPTS_DIR@:$SCRIPTS_DIR:"
if [ $SCRIPT_OUT -ot $file ] || [ $SCRIPT_OUT -ot src/jobscript-header ]
then 
    cat src/jobscript-header > $SCRIPT_OUT
    sed "$sedstring" $file >> $SCRIPT_OUT
    echo "Created script $SCRIPT_OUT."
    chmod +x $SCRIPT_OUT
fi


# Prepare all other scripts
SCRIPTS_IN=$(ls src/*in)

for file in $SCRIPTS_IN
do
    SCRIPT_OUT=$(echo $file | sed -e s:^src/:: -e s:.in:: )
    sedstring="s:@SCRIPTS_DIR@:$SCRIPTS_DIR:"
    if [ $SCRIPT_OUT -ot $file ] 
    then 
        sed "$sedstring" $file > $SCRIPT_OUT
        echo "Created script $SCRIPT_OUT."
	chmod +x $SCRIPT_OUT
    fi
done

echo; echo "Path to GIMIC:"
echo "export GIMIC_HOME=\"$SCRIPTS_DIR\""
