#!/bin/bash

### КОД ВЫПОЛНИТСЯ ТОЛЬКО В ТОМ СЛУЧАЕ, ЕСЛИ ВЫПОЛНЯЮЩИЙ ЗАМЕНИТ ЛИЧНЫЕ ДАННЫЕ РАЗРАБОТЧИКА (Володин С. В.) НА СВОИ.
### НАПРИМЕР ССЫЛКИ НА GENEMARKS-2

# Скачивание собранного генома бактерии (всех скаффолдов) из ДЗ 1
wget https://raw.githubusercontent.com/volodinSV/hse21_hw1/master/data/scaffolds.fasta

# Установка GeneMarkS-2
wget http://topaz.gatech.edu/GeneMark/tmp/GMtool_T4YSR/gms2_linux_64.tar.gz
wget http://topaz.gatech.edu/GeneMark/tmp/GMtool_T4YSR/gm_key_64.gz
gzip -d gm_key_64.gz
tar -xzvf gms2_linux_64.tar.gz
cp  -v  gm_key_64   ~/.gmhmmp2_key

# Установка E-utilities для скачивания последовательностей из NCBI
sh -c "$(curl -fsSL ftp://ftp.ncbi.nlm.nih.gov/entrez/entrezdirect/install-edirect.sh)"
export PATH=${PATH}:${HOME}/edirect

# Скачивание данных по близкородственной бактерии T.oleivorans
$HOME/edirect/efetch -db nuccore -id HF680312 -format gb  >  T_oleivorans_MIL_1.gbk
$HOME/edirect/efetch -db nuccore -id HF680312 -format gene_fasta  >  T_oleivorans_MIL_1.genes.fasta
$HOME/edirect/efetch -db nuccore -id HF680312 -format fasta_cds_aa  >  T_oleivorans_MIL_1.proteins.fasta

# Установка BLAST не требуется, т.к. уже установлен на сервере

# Скачивание БД белков SwissProt
wget https://ftp.uniprot.org/pub/databases/uniprot/current_release/knowledgebase/complete/uniprot_sprot.fasta.gz
gzip -d uniprot_sprot.fasta.gz

# Установка пакета seqtk
wget https://github.com/shenwei356/seqkit/releases/download/v2.1.0/seqkit_linux_amd64.tar.gz
tar -xzvf seqkit_linux_amd64.tar.gz
chmod a+x seqkit

# Предсказание расположения белок-кодирующих генов в геноме бактерии
# genes.fasta - гены
# proteins.fasta - белки
time ./gms2_linux_64/gms2.pl  --seq scaffolds.fasta  --genome-type bacteria  --fnn genes.fasta  --faa proteins.fasta --gcode 11

## Определение функции белков бактерии через сравнение с белками из T.oleivorans MIL-1
# T_olevieroans_MIL_1.proteins.fasta - протеом T.olevieroans MIL-1
# Индексация белков T.olevieroans MIL-1
makeblastdb  -dbtype prot  -in T_oleivorans_MIL_1.proteins.fasta  -out T_oleivorans_MIL_1.proteins

# Определение схожих белков у бактерии и T_oleiveroans
blastp  -query proteins.fasta  -db T_oleivorans_MIL_1.proteins  -evalue 1e-10  -outfmt 6  >  scaffolds.hits_from_MIL_1.txt

## Определение функции белков бактерии через поиск по БД SwissProt
# Получение списка уникальных номеров генов бактерии из Баренцева моря, которые имели хотя бы один похожий белок бактерии из Сицилии
cut -f 1 scaffolds.hits_from_MIL_1.txt | sort -n | uniq > proteins.with_hits_from_MIL_1.txt
./seqkit grep --invert-match -f proteins.with_hits_from_MIL_1.txt proteins.fasta -o proteins.without_MIL_1.fasta

#$(grep '>' proteins.fasta | wc -l)
echo "Общее количество белков в бактерии: $(grep '>' proteins.fasta | wc -l)"

#$(wc -l proteins.with_hits_from_MIL_1.txt)
#$(grep '>' proteins.without_MIL_1.fasta | wc -l)
echo "Количество белков, которые имели схожие белки из бактерии MIL-1: $(grep '>' proteins.without_MIL_1.fasta | wc -l)"

## Сравнение всех белков бактерии с аннотированными белками из БД SwissProt
# Индексация белков SwissProt
makeblastdb -dbtype prot -in uniprot_sprot.fasta -out uniprot_sprot

# Определение белков бактерии схожих с белками из БД SwissProt
blastp -query proteins.without_MIL_1.fasta -db uniprot_sprot -evalue 1e-10 -outfmt 6 > scaffolds.hits_from_SwissProt.txt

# Подсчёт аннотированных белков через поиск по SwissProt
echo "Количество аннотированных белков через поиск по SwissProt: $(cut -f 1 scaffolds.hits_from_SwissProt.txt | sort | uniq | wc -l)"

##Загрузка файлов на GitHub
#cp -v scaffolds.fasta gms2.lst proteins.fasta scaffolds.hits_from_MIL_1.txt scaffolds.hits_from_SwissProt.txt ~/github/hse21_hw2/data/

#git add ~/github/hse21_hw2/
#git -m commit 'GeneMarks annotation'
#git push

