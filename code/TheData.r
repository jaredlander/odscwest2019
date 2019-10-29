library(dplyr)
library(purrr)
library(ggplot2)

comps <- list.files('data', pattern='^Comp_', full.names=TRUE) %>% 
    map_df(readr::read_csv)
comps

set.seed(2861)

library(rsample)

the_split <- initial_split(data=comps, prop=0.8, strata='SalaryCY')
the_split

train <- training(the_split)
test <- testing(the_split)

ggplot(train, aes(x=SalaryCY)) + geom_histogram()
ggplot(train, aes(x=SalaryCY, fill=Title)) + 
    geom_histogram()  + 
    facet_wrap(~ Title, ncol=1) + 
    theme(legend.position='none')
