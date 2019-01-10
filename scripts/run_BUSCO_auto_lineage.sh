#!/usr/bin/env bash

: '
This is the BUSCO automated dataset selection helper script.

To get help, ./run_BUSCO_auto_lineage.sh -h.

See the main BUSCO script: run_BUSCO.py

And visit our website <http://busco.ezlab.org/>

Copyright (c) 2016-2017, Evgeny Zdobnov (ez@ezlab.org)
Licensed under the MIT license. See LICENSE.md file.
'

# Read the parameters
while test $# -gt 0; do
        case "$1" in
                -h|--help)
                        echo "This script defines which BUSCO dataset should be used for the given input."
                        echo ""
                        echo "The current version picks either eukaryota, or one of the bacterial set."
                        echo ""
                        echo "It requires biopython, pplacer, and a network connexion, besides the BUSCO install. May use more memory than available on a standard laptop."
                        echo ""
                        echo "Options are read in the BUSCO_CONFIG_FILE ($BUSCO_CONFIG_FILE) or passed manually"
                        echo "Working directory is the out_path in BUSCO_CONFIG_FILE, or the current directory."
                        echo ""
                        echo "Usage:"
                        echo ""
                        echo "./run_BUSCO_auto_lineage.sh [options]"
                        echo " "
                        echo "Options:"
                        echo "-h, --help,    show this help"
                        echo "-i, --input path,   specify the input file"
                        echo "-o, --output name,  specify the output name for the run"
                        echo "-c, --cpus n,   specify the number of cpu to use"
                        echo "-m, --mode geno/tran/prot, specify the BUSCO mode to run"
                        echo "-p, --print-dont-run,  only indicate the lineage to use, without running it"
                        echo "-b, --bacteria,   run only bacteria, ignore eukaryota"
                        echo "-r, --remove-tmp, remove the runs created to select the dataset. Keep only the final run"
                        echo ""
                        exit 0
                        ;;
                -b|--bacteria)
                        shift
                        bacteria=1
                        shift
                        ;;
                -p|--print-dont-run)
                        shift
                        display_only=1
                        shift
                        ;;
                -r|--remove-tmp)
                        shift
                        clean=1
                        shift
                        ;;

                -o|--output)
                        shift
                        if test $# -gt 0; then
                            OUTPUT=$1
                        else
                            echo "no output name specified after -o"
                            exit 1
                        fi
                        shift
                        ;;

                -i|--input)
                        shift
                        if test $# -gt 0; then
                            INPUT=$1
                        else
                            echo "no input path specified after -i"
                            exit 1
                        fi
                        shift
                        ;;

                -c|--cpus)
                        shift
                        if test $# -gt 0; then
                            CPU=$1
                        else
                            echo "no cpu value specified after -c"
                            exit 1
                        fi
                        shift
                        ;;

                -m|--mode)
                        shift
                        if test $# -gt 0; then
                            MODE=$1
                        else
                            echo "no mode specified after -m"
                            exit 1
                        fi
                        shift
                        ;;
                *)
                        break
                        ;;
                    esac
                done

# Deal with missing parameters. 1st in the config.ini file if accessible, or a default value when possible.
# CPU
if [ -z $CPU ];
then
    CPU=$(cat $BUSCO_CONFIG_FILE | grep -v "#" | grep -v ";" | grep "^cpu=\|^cpu =" | head -n 1 | cut -f2 -d "=" | sed 's/ *//g')
    if [ -z $CPU ];
    then
    CPU=$(cat $(which run_BUSCO_auto_lineage.sh | rev | cut -f3-999 -d"/" | rev)/config/config.ini | grep -v "#" | grep -v ";" | grep "^cpu=\|^cpu =" | head -n 1 | cut -f2 -d "=" | sed 's/ *//g')
    fi
    if [ -z $CPU ];
    then
    CPU=1
    fi
fi

# Working directory
if [ -z $WD ];
then
    WD=$(cat $BUSCO_CONFIG_FILE | grep -v "#" | grep -v ";" | grep "^out_path=\|^out_path =" | head -n 1 | cut -f2 -d "=" | sed 's/ *//g')
    if [ -z $WD ];
    then
    WD=$(cat $(which run_BUSCO_auto_lineage.sh | rev | cut -f3-999 -d"/" | rev)/config/config.ini | grep -v "#" | grep -v ";" | grep "^out_path=\|^out_path =" | head -n 1 | cut -f2 -d "=" | sed 's/ *//g')
    fi
    if [ -z $WD ];
    then
    WD=$(pwd)
    fi
fi

# Output name
if [ -z $OUTPUT ];
then
    OUTPUT=$(cat $BUSCO_CONFIG_FILE | grep -v "#" | grep -v ";" | grep "^out=\|^out =" | head -n 1 | cut -f2 -d "=" | sed 's/ *//g')
    if [ -z $OUTPUT ];
    then
    OUTPUT=$(cat $(which run_BUSCO_auto_lineage.sh | rev | cut -f3-999 -d"/" | rev)/config/config.ini | grep -v "#" | grep -v ";" | grep "^out=\|^out =" | head -n 1 | cut -f2 -d "=" | sed 's/ *//g')
    fi
    if [ -z $OUTPUT ];
    then
    echo "Please provide a name for the output (-o)"
    exit 1
    fi
fi

# Input path
if [ -z $INPUT ];
then
    INPUT=$(cat $BUSCO_CONFIG_FILE | grep -v "#" | grep -v ";" | grep "^in=\|^in =" | head -n 1 | cut -f2 -d "=" | sed 's/ *//g')
    if [ -z $INPUT ];
    then
    INPUT=$(cat $(which run_BUSCO_auto_lineage.sh | rev | cut -f3-999 -d"/" | rev)/config/config.ini | grep -v "#" | grep -v ";" | grep "^in=\|^in =" | head -n 1 | cut -f2 -d "=" | sed 's/ *//g')
    fi
    if [ -z $INPUT ];
    then
    echo "Please provide an input file (-i)"
    exit 1
    fi
fi

if [ -z $MODE ];
then
    MODE=$(cat $BUSCO_CONFIG_FILE | grep -v "#" | grep -v ";" | grep "^mode=\|^mode =" | head -n 1 | cut -f2 -d "=" | sed 's/ *//g')
    if [ -z $MODE ];
    then
    MODE=$(cat $(which run_BUSCO_auto_lineage.sh | rev | cut -f3-999 -d"/" | rev)/config/config.ini | grep -v "#" | grep -v ";" | grep "^mode=\|^mode ="  | head -n 1 | cut -f2 -d "=" | sed 's/ *//g')
    fi
    if [ -z $MODE ];
    then
echo "Please indicate the mode: -m geno/tran/prot)"
    exit 1
    fi
fi

if [[ -z ${bacteria+x} ]];
then
    eukaryota=1
fi
bacteria=1

echo "Number of CPU is $CPU"
echo "Input file is $INPUT"
echo "Output name is $OUTPUT"
echo "Working directory is $WD"
echo "BUSCO mode is $MODE"

MODE_tmp=$MODE

if [ $MODE == 'tran' ];
then
    MODE_tmp='geno'
    echo '!!! The genome mode is run to define the dataset on transcriptomes. Do not consider the intermediate BUSCO runs as true transcriptome assessment.'
    sleep 3
fi

sleep 5

suffix=$(echo $INPUT | rev | cut -f1 -d"/" | rev)

if [ ! -z ${bacteria+x} ];
then
    # download set in $WD if absent
    if [ ! -d $WD/bacteria_odb9 ]; then
        wget -P $WD http://busco.ezlab.org/v2/datasets/bacteria_odb9.tar.gz
        tar zxvf $WD/bacteria_odb9.tar.gz -C $WD
        rm $WD/bacteria_odb9.tar.gz
    fi
    echo "Run Bacteria set on candidate file, name is bacteria_odb9_$suffix..."
    run_BUSCO.py -i $INPUT -o bacteria_odb9_$suffix -l $WD/bacteria_odb9 -c $CPU -m $MODE_tmp -f
fi

if [ ! -z ${eukaryota+x} ];
then
    # download set in $WD if absent
    if [ ! -d $WD/eukaryota_odb9 ]; then
        wget -P $WD http://busco.ezlab.org/v2/datasets/eukaryota_odb9.tar.gz
        tar zxvf $WD/eukaryota_odb9.tar.gz -C $WD
        rm $WD/eukaryota_odb9.tar.gz
    fi
    echo "Run Eukaryota set on candidate file, name is eukaryota_odb9_$suffix..."
    run_BUSCO.py -i $INPUT -o eukaryota_odb9_$suffix -l $WD/eukaryota_odb9 -c $CPU -m $MODE_tmp -f
fi

# compare the score and keep the larger, rounded, percentrage of complete BUSCO
euk=$(head -n 8 $WD/run_eukaryota_odb9_$suffix/short_summary_eukaryota_odb9_$suffix.txt | tail -n 1 | cut -f1 -d"%" | cut -f2 -d":" | cut -f1 -d".") 2>/dev/null
bact=$(head -n 8 $WD/run_bacteria_odb9_$suffix/short_summary_bacteria_odb9_$suffix.txt | tail -n 1 | cut -f1 -d"%" | cut -f2 -d":" | cut -f1 -d".")

folder="run_bacteria_odb9_$suffix"
clade="bacteria"
if [[ $euk -gt $bact ]];then folder="run_eukaryota_odb9_$suffix";clade="eukaryota";fi 2>/dev/null

if [ $clade == 'bacteria' ];
then

mkdir -p $clade

# extract BUSCO single copy to be used by pplacer
if [ $MODE == 'prot' ];
then
    echo 'Extracting single copy sequences...'
    $(python -c "from busco.BuscoPlacer import BuscoPlacer;\
        BuscoPlacer.extract_single_copy_sequences('"$WD/$folder/"','"$INPUT"')")
fi

# obtain the tree and alignment
if [ ! -f $WD/$clade/refseqs.hmm ]; then
    wget -P $WD/$clade https://gitlab.com/ezlab/busco_auto/raw/master/$clade/refseqs.hmm
fi

if [ ! -f $WD/$clade/supermatrix.aln.faa ]; then
    wget -P $WD/$clade https://gitlab.com/ezlab/busco_auto/raw/master/$clade/supermatrix.aln.faa
fi

if [ ! -f $WD/$clade/tree.nwk ]; then
    wget -P $WD/$clade https://gitlab.com/ezlab/busco_auto/raw/master/$clade/tree.nwk
fi

if [ ! -f $WD/$clade/tree_metadata.txt ]; then
    wget -P $WD/$clade https://gitlab.com/ezlab/busco_auto/raw/master/$clade/tree_metadata.txt
fi

if [ ! -f $WD/$clade/list_of_reference_markers.txt ]; then
    wget -P $WD/$clade https://gitlab.com/ezlab/busco_auto/raw/master/$clade/list_of_reference_markers.txt
fi

if [ ! -f $WD/$clade/mapping.tsv ]; then
    wget -P $WD/$clade https://gitlab.com/ezlab/busco_auto/raw/master/$clade/mapping.tsv
fi

rm $WD/$folder/marker_genes.fasta 2>/dev/null

for marker in $(cat $WD/$clade/list_of_reference_markers.txt);
do
    cat $WD/$folder/single_copy_busco_sequences/$marker.faa >> $WD/$folder/marker_genes.fasta 2>/dev/null
done

# run hmmalign
hmmalign -o $WD/$folder/place_input.sto --mapali $WD/$clade/supermatrix.aln.faa $WD/$clade/refseqs.hmm $WD/$folder/marker_genes.fasta

# run pplacer
pplacer --out-dir $WD/$folder/ -t $WD/$clade/tree.nwk -s $WD/$clade/tree_metadata.txt $WD/$folder/place_input.sto

# run guppy
guppy fat --out-dir $WD/$folder/ $WD/$folder/place_input.jplace

# get the best node from guppy
echo "Define the best dataset to use..."
dataset_to_use=$(python -c "from busco.BuscoPlacer import BuscoPlacer;print(\
    BuscoPlacer.define_dataset('"$WD/$folder/place_input.xml"','"$WD/$clade/mapping.tsv"',1.5))")_odb9

echo "Use the dataset $dataset_to_use"

else

echo "Use the dataset eukaryota"

dataset_to_use="eukaryota_odb9"

if [ $MODE != 'tran' ];
then
    exit 0
fi

fi

# download set in $WD if absent
if [ ! -d $WD/$dataset_to_use ]; then
    wget -P $WD http://busco.ezlab.org/v2/datasets/$dataset_to_use.tar.gz
    tar zxvf $WD/$dataset_to_use.tar.gz -C $WD
    rm $WD/$dataset_to_use.tar.gz
fi

if [ -z ${display_only+x} ];
then
echo "Run BUSCO with the recommended dataset..."
sleep 5
run_BUSCO.py -i $INPUT -o $suffix"_"$dataset_to_use"_"busco_auto -l $WD/$dataset_to_use -c $CPU -m $MODE -f
fi

if [ ! -z ${clean+x} ];
then
    echo "Cleaning temporary runs: run_bacteria_odb9_$suffix, run_eukaryota_odb9_$suffix"
    rm -r run_eukaryota_odb9_$suffix > /dev/null
    rm -r run_bacteria_odb9_$suffix > /dev/null
fi
