# 02) gscramble simulations

As described in the manuscript, we iterated through GSPs for F1, F2, F1BC1, and F1BC2, for all combinations of the 3 populations, as well as simulated founder individuals directly from the 3 populations, for 1000 replicates each (total of 21,000). We did not do this by hand, but rather with a slurm job array on HPC. Scripts are found in the `./scripts/` directory and we provide the data used as well to replicate these analyses.

### Scripts

The scripts are:

- `get-gscramble-admix.sh`: This was the main slurm script used to run admixture and the following R scripts.

- `run-gscramble-missouri-example.R`: This R script reads in a GSP and simulates the specified pedigree and individuals.

- `run-gscramble-admixture-summary.R`: This script summarizes the admixture output for the gscrambled individual

### Out

The `./out/` directory provides the summarized data of the simulations in `full-summary-LONG.txt`. The column names of the file are as follows:

- "Individual" =  Individual ID
- "GSP" = GSP used to simulate the individual
- "GSP_iter" = Iteration
- "GSP_id" = Full iteration ID
- "Ind_iter" = Individual iteration
- "PopA" = First pop in GSP (If a backcross pop, this is what the individual was backcrossed to)
- "PopB" = Second pop in a GSP
- "Pop1" = Qvalues for Pop1
- "Pop2" = Qvalues for Pop2 
- "Pop3" = Qvalues for Pop3 (or we had also called this Pop14 in the data)

Note: the above `out` file is what is used in the visualizing/results summary section.
                   
### Data

The `./data/` directory has all the data to be used for running the scripts

- `fesw.plink.Rds` = This is the empirical pig data in the `gscramble` format as an R file
- `fesw.recrates.csv` = These are the recombination rates used in the gscrambling process
- `gsp-iter-array-LONG.txt` = This is the big input file to specify the paramters of the Slurm job array
- `gsp.*.csv` = These are the 4 GSPs we used for specifying F1, F2, F1BC1, F1BC2

Now to [Step 3: Summarizing results](https://github.com/mgdesaix/gscramble-paper-pigs/blob/main/scripts/03_results_summary/README.md)


                   
                   