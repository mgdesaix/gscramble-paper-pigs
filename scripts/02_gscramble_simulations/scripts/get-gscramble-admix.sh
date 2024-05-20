#!/bin/bash
#set a job name
#SBATCH --job-name=gscramble-admix
#SBATCH --output=./err-out/gscramble-admix.%A_%a.out
#SBATCH --error=./err-out/gscramble-admix.%A_%a.err
################
#SBATCH --time=1:00:00
#################
# Note: 3.74G/core or task
#################
#SBATCH --ntasks=8
#SBATCH --array=401-690
#################

source ~/.bashrc

conda activate vcfr
plink=/projects/mgdesaix@colostate.edu/programs/plink/plink
admixture=/projects/mgdesaix@colostate.edu/programs/admixture_linux-1.3.0/admixture

gsp=$(awk -v N=$SLURM_ARRAY_TASK_ID 'NR == N {print $1}' ./data/gsp-iter-array-LONG.txt)
iter=$(awk -v N=$SLURM_ARRAY_TASK_ID 'NR == N {print $2}' ./data/gsp-iter-array-LONG.txt)


for i in {1..6}
do
    popA=$(awk -v i=$i 'NR == i {print $1}' ./data/pop-combinations.txt)
    popB=$(awk -v i=$i 'NR == i {print $2}' ./data/pop-combinations.txt)

    # gscramble
    Rscript run-gscramble-missouri-example.R ${gsp} ${iter} ${popA} ${popB}
    
    # plink produce binary files
    filename=${gsp}.${popA}.${popB}.iter.${iter}
    ${plink} --file ./out/genotypes/${filename} --make-bed --out ./out/genotypes/${filename} --noweb
    
    # run admixture on gscrambled output
    cd ./out/admixture/
    ${admixture} --cv ../genotypes/${filename}.bed 3 -j8
    cd ../../

    # summarize data
    Rscript run-gscramble-admixture-summary.R ${gsp} ${iter} ${popA} ${popB}

    # delete intermediary files
    rm ./out/genotypes/${filename}.*
    rm ./out/admixture/${filename}.*
    
done

cat ./out/summary/${gsp}.*.iter.${iter}.txt > ./out/summary/${gsp}.iter.${iter}.summary.txt
rm ./out/summary/${gsp}.*.iter.${iter}.txt

if [[ ${gsp} == F1 ]]; then cat ./out/summary/core.*.iter.${iter}.txt > ./out/summary/core.iter.${iter}.summary.txt; rm ./out/summary/core.*.iter.${iter}.txt; fi
