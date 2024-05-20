# 01) Initial admixture of empirical pig data


```sh
cd ./out
for K in {1..5}; do ../software/admixture --cv ../data/gscramble-pigs-keep.bed $K -j8 | tee log${K}.out; done
```


```sh
cd ./out
grep -h CV log*.out | cut -f2 -d: | sed 's/ //g' > cv.tmp
grep -h CV log*.out | cut -f1 -d")" | cut -f2 -d"=" > k.tmp
paste k.tmp cv.tmp > cv.sum.txt
head cv.sum.txt
```

```r
library(tidyverse)
cv.df <- read_table("./out/cv.sum.txt",
                    col_names = c("K", "CV"),
                    show_col_types = F)
p.cv <- ggplot(cv.df) +
  geom_point(aes(x = K, y = CV),
             size = 2) +
  geom_line(aes(x = K, y = CV)) +
  theme_bw()
p.cv
```

<img src="images/bcrf.sex.k2.barplot.pdf" alt="ancestry" width="600"/>


