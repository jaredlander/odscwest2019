# depends on xgboost.r

# caret

# tidymodels
library(recipes)
library(rsample)
library(dials)
library(yardstick)
library(parsnip)

library(remotes)
# install_github('tidymodels/tune')
library(tune)

# rsmaple
sal_rs <- vfold_cv(data=train, v=3, repeats=2, strata='SalaryCY')
sal_rs

# yardstick
sal_metrics <- metric_set(rmse, mae)
sal_metrics

# parsnip
# sal17 <- 
boost_tree(mode='regression')
linear_reg()
rand_forest(mode='regression')

linear_reg() %>% 
    set_engine('lm')
linear_reg() %>% 
    set_engine('glmnet')

# lm(y ~ x, data=...)
# glmnet(x=x, y=y)

linear_reg() %>% 
    set_engine('lm') %>% 
    fit_xy(train_x, train_y)

linear_reg(mixture=0.5) %>% 
    set_engine('glmnet') %>% 
    fit_xy(train_x, train_y)

boost_tree(mode='regression') %>% 
    set_engine('xgboost')

boost_tree(mode='regression', trees=50, tree_depth=4) %>% 
    set_engine('xgboost')

sal17 <- boost_tree(mode='regression', trees=50, tree_depth=4) %>% 
    set_engine('xgboost') %>% 
    fit_xy(tree_x, tree_y)

xg_mod <- boost_tree(
    mode='regression',
    learn_rate=0.3,
    tree_depth=tune(),
    trees=tune(id='num_trees')
) %>% 
    set_engine('xgboost')
xg_mod

# dials
trees()
tree_depth()
learn_rate()
penalty()
mixture()

xg_mod %>% parameters()

xg_params <- xg_mod %>% 
    parameters() %>% 
    update(
        tree_depth=tree_depth(range=c(2, 6)),
        num_trees=trees(range=c(25, 100))
    )
xg_params

xg_grid <- grid_random(xg_params, size=6)
xg_grid

library(tictoc)

tic()
7*8
toc()

# tune
tic()
xg_results <- tune_grid(
    tree_recipe,
    model=xg_mod,
    resamples=sal_rs,
    grid=xg_grid,
    metrics=sal_metrics,
    control=ctrl_grid(verbose=TRUE)
)
toc()

xg_results
xg_results$.metrics[[1]]

xg_results %>% 
    collect_metrics() %>% 
    filter(.metric=='rmse') %>% 
    arrange(mean)
