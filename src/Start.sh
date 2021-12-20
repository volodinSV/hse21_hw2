#!/bin/bash

wget https://raw.githubusercontent.com/volodinSV/hse21_hw1/master/data/scaffolds.fasta

wget http://topaz.gatech.edu/GeneMark/tmp/GMtool_T4YSR/gms2_linux_64.tar.gz
wget http://topaz.gatech.edu/GeneMark/tmp/GMtool_T4YSR/gm_key_64.gz
gzip -d gm_key_64.gz
tar -xzvf gms2_linux_64.tar.gz
cp  -v  gm_key_64   ~/.gmhmmp2_key

sh -c "$(curl -fsSL ftp://ftp.ncbi.nlm.nih.gov/entrez/entrezdirect/install-edirect.sh)"
$HOME/edirect/efetch -db nuccore -id HF680312 -format gb  >  T_oleivorans_MIL_1.gbk
$HOME/edirect/efetch -db nuccore -id HF680312 -format gene_fasta  >  T_oleivorans_MIL_1.genes.fasta
$HOME/edirect/efetch -db nuccore -id HF680312 -format fasta_cds_aa  >  T_oleivorans_MIL_1.proteins.fasta

wget https://ftp.uniprot.org/pub/databases/uniprot/current_release/knowledgebase/complete/uniprot_sprot.fasta.gz
gzip -d uniprot_sprot.fasta.gz

wget https://github.com/shenwei356/seqkit/releases/download/v2.1.0/seqkit_linux_amd64.tar.gz
tar -xzvf seqkit_linux_amd64.tar.gz
chmod a+x seqkit

./gms2_linux_64/gms2.pl  --seq scaffolds.fasta  --genome-type bacteria  --fnn genes.fasta  --faa proteins.fasta

makeblastdb  -dbtype prot  -in T_oleivorans_MIL_1.proteins.fasta  -out T_oleivorans_MIL_1.proteins
blastp  -query proteins.fasta  -db T_oleivorans_MIL_1.proteins  -evalue 1e-10  -outfmt 6  >  scaffolds.hits_from_MIL_1.txt
