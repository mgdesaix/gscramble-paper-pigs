#!/projects/mgdesaix@colostate.edu/mambaforge/envs/vcfr/bin/Rscript

############################################################################################################
### Run gscramble simulations for 3 Missouri feral swine populations
### October 25, 2023
### Matt DeSaix
############################################################################################################

myargs <- commandArgs(trailingOnly=TRUE)
gsp <- myargs[1]
iter <- as.numeric(myargs[2])
popA <- myargs[3]
popB <- myargs[4]


library(gscramble)
library(tidyverse)

### Read in data
# GSP
gsp_file <- paste0("./data/hpc-data/gsp.", gsp, ".csv")
fesw.gsp.tmp <- read_csv(gsp_file, show_col_types = F)

# Recombination rates
fesw.recrates <- read_csv("./data/hpc-data/fesw.recrates.csv", show_col_types = F)

# plink2gscramble() object with reference genotypes of 3 populations
fesw.plink <- readRDS("./data/hpc-data/fesw.plink.Rds")

### 
 RepPop_hybrids <- tibble(
    index = as.integer(c(1,1)),
    pop = c("p1", "p2"),
    group = c(popA, popB)
  )
  
  Input_tibble <- tibble(
    gpp = list(fesw.gsp.tmp),
    reppop = list(RepPop_hybrids)
  )
  
  Segments <- segregate(
  request = Input_tibble,
  RR = fesw.recrates,
  MM = fesw.plink$M_meta
)
  
  Markers <- segments2markers(
    Segs = Segments,
    Im = fesw.plink$I_meta,
    Mm = fesw.plink$M_meta,
    G = fesw.plink$Geno
    )
  
  outname <- paste0("./out/genotypes/", gsp, ".", popA, ".", popB, ".iter.", iter)
  gscramble2plink(I_meta = Markers$ret_ids,
                M_meta = fesw.plink$M_meta,
                Geno = Markers$ret_geno,
                prefix = outname)