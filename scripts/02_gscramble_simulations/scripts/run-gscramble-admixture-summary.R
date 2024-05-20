#!/projects/mgdesaix@colostate.edu/mambaforge/envs/vcfr/bin/Rscript

############################################################################################################
### Summarize admixture output from gscrambled individuals
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
# filename=${gsp}.${popA}.${popB}.iter.${iter}
filename <- paste0(gsp,".", popA, ".", popB, ".iter.", iter)
fam_name <- paste0("./out/genotypes/", filename, ".fam")

tmp.fam <- read_table(fam_name,
                       c("Group", "Individual", "a", "b", "c", "d"),
                       show_col_types = F) %>%
  select(Group, Individual)

admix_name <- paste0("./out/admixture/", filename, ".3.Q")
tmp.admix <- read_table(admix_name,
                         col_names = c("x", "y", "z"),
                         show_col_types = F)

# determine the respective population IDs for the admix file columns (which are unlabeled)
pop_groups <- cbind(tmp.fam, tmp.admix) %>%
  filter(Group != "ped_hybs") %>%
  select(Group, x, y, z) %>%
  pivot_longer(x:z, names_to = "Pop", values_to = "Q") %>%
  group_by(Group, Pop) %>%
  summarize(Q = sum(Q),
            .groups = "drop") %>%
  group_by(Group) %>%
  slice_max(Q) %>%
  ungroup()

col1 <- pop_groups$Group[which(pop_groups$Pop == "x")]
col2 <- pop_groups$Group[which(pop_groups$Pop == "y")]
col3 <- pop_groups$Group[which(pop_groups$Pop == "z")]

colnames(tmp.admix) <- c(col1, col2, col3)

hybrid_qs <- cbind(tmp.fam, tmp.admix) %>%
  filter(Group == "ped_hybs")

n_ind <- nrow(hybrid_qs)

hybrid_qs <- hybrid_qs %>%
  mutate(new_id = as.integer(str_extract(Individual, "[^-]+$"))) %>%
  mutate(Ind_iter = (iter - 1)*n_ind + new_id) %>%
  add_column("PopA" = popA,
             "PopB" = popB,
             "GSP" = gsp,
             "GSP_iter" = iter,
             "GSP_id" = paste0(gsp, "-", popA, "-", popB, "-", iter)) %>%
  select(Individual, GSP, GSP_iter, GSP_id, Ind_iter, PopA, PopB, Pop1, Pop2, Pop14)

if(gsp == "F1"){
  n_ind <- 2
  unsampled_pop <- setdiff(c(col1, col2, col3), c(popA, popB))
  unsampled_qs <- cbind(tmp.fam, tmp.admix) %>%
    filter(!Group %in% c("ped_hybs", popA, popB)) %>%
    slice_sample(n=2) %>%
    mutate(Individual = gsub(pattern = "permed_", "", x = Individual),
           new_id = as.integer(c(1,2))) %>%
    mutate(Ind_iter = (iter - 1)*n_ind + new_id) %>%
    add_column("GSP" = "Unsampled",
               "GSP_iter" = iter,
               "PopA" = unsampled_pop,
               "PopB" = unsampled_pop,
               "GSP_id" = paste0(gsp, "-", popA, "-", popB, "-", iter)) %>%
    select(Individual, GSP, GSP_iter, GSP_id, Ind_iter, PopA, PopB, Pop1, Pop2, Pop14)
  hybrid_qs <- rbind(hybrid_qs, unsampled_qs)
}


write_delim(hybrid_qs, file = paste0("./out/summary/", filename, ".txt"), delim = "\t", col_names = F)



