# depends on TheData.r and Linear.r

train_x %>% head

tree_recipe <- recipe(SalaryCY ~ ., data=train) %>% 
    step_rm(SalaryPY, BonusPY, BonusCY, ID) %>% 
    step_zv(all_predictors()) %>% 
    step_dummy(all_nominal(), one_hot=TRUE)
tree_recipe

tree_prepped <- tree_recipe %>% prep()
tree_prepped

tree_x <- tree_prepped %>% 
    bake(all_predictors(), new_data=train, composition='matrix')
tree_y <- tree_prepped %>% 
    bake(all_outcomes(), new_data=train, composition='matrix')

val_split <- initial_split(data=test, prop=0.5, strata='SalaryCY')
val <- training(val_split)
test_small <- testing(val_split)

val_x <- tree_prepped %>% 
    bake(new_data=val, all_predictors(), composition='matrix')
val_y <- tree_prepped %>% 
    bake(all_outcomes(), new_data=val, composition='matrix')

new_x <- tree_prepped %>% 
    bake(all_predictors(), new_data=test_small, composition='matrix')
new_y <- tree_prepped %>% 
    bake(all_outcomes(), new_data=test_small, composition='matrix')


# rpart
library(xgboost)
library(DiagrammeR)
train_xg <- xgb.DMatrix(data=tree_x, label=tree_y)
train_xg
val_xg <- xgb.DMatrix(data=val_x, label=val_y)

sal7 <- xgb.train(
    data=train_xg,
    objective="reg:squarederror",
    nrounds=1
)
sal7
sal7 %>% 
    xgb.plot.multi.trees()

sal8 <- xgb.train(
    data=train_xg,
    objective="reg:squarederror",
    nrounds=100,
    print_every_n=1,
    watchlist=list(train=train_xg),
    eval_metric='rmse'
)

sal9 <- xgb.train(
    data=train_xg,
    objective="reg:squarederror",
    nrounds=300,
    print_every_n=1,
    watchlist=list(train=train_xg),
    eval_metric='rmse'
)

sal10 <- xgb.train(
    data=train_xg,
    objective="reg:squarederror",
    nrounds=500,
    print_every_n=1,
    watchlist=list(train=train_xg),
    eval_metric='rmse'
)

sal11 <- xgb.train(
    data=train_xg,
    objective="reg:squarederror",
    nrounds=500,
    print_every_n=1,
    watchlist=list(train=train_xg, validate=val_xg),
    eval_metric='rmse'
)

sal11$evaluation_log %>% dygraphs::dygraph()
which.min(sal11$evaluation_log$validate_rmse)

sal11_preds <- predict(sal11, newdata=new_x, ntreelimit=25)
head(sal11_preds)
sqrt(mean((new_y - sal11_preds)^2))

sal11 %>% 
    xgb.plot.multi.trees()

sal11 %>% 
    xgb.importance(model=.) %>% 
    .[1:0, ] %>% 
    xgb.plot.importance()

sal12 <- xgb.train(
    data=train_xg,
    objective="reg:squarederror",
    nrounds=100,
    print_every_n=1,
    watchlist=list(train=train_xg, validate=val_xg),
    eval_metric='rmse',
    max_depth=3
)

sal13 <- xgb.train(
    data=train_xg,
    objective="reg:squarederror",
    nrounds=100,
    print_every_n=1,
    watchlist=list(train=train_xg, validate=val_xg),
    eval_metric='rmse',
    max_depth=3,
    subsample=0.5
)

sal14 <- xgb.train(
    data=train_xg,
    objective="reg:squarederror",
    nrounds=100,
    print_every_n=1,
    watchlist=list(train=train_xg, validate=val_xg),
    eval_metric='rmse',
    max_depth=3,
    subsample=0.5,
    colsample_bytree=0.5
)

sal15 <- xgb.train(
    data=train_xg,
    objective="reg:squarederror",
    nrounds=1,
    print_every_n=1,
    watchlist=list(train=train_xg, validate=val_xg),
    eval_metric='rmse',
    max_depth=3,
    subsample=0.5,
    colsample_bytree=0.5,
    num_parallel_tree=50
)

sal16 <- xgb.train(
    data=train_xg,
    objective="reg:squarederror",
    nrounds=20,
    print_every_n=1,
    watchlist=list(train=train_xg, validate=val_xg),
    eval_metric='rmse',
    max_depth=3,
    subsample=0.5,
    colsample_bytree=0.5,
    num_parallel_tree=50
)
