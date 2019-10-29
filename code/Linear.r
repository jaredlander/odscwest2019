# this file should be ran after TheData.r

### Linear Models ####

names(train)

# output: response, target, label
# input: predictor, feature, covariate, data

# y ~ x

sal1 <- lm(SalaryCY ~ Region + Title + Sector + 
               Years + Reports + Level + Career + Floor,
           data=train)
sal1
summary(sal1)
library(coefplot)

coefplot(sal1, sort='magnitude')

sal2 <- lm(SalaryCY ~ Region + Title + Sector + 
               Years + Reports + Level + Career + Floor,
           data=train, subset=Title != 'MD')
coefplot(sal2, sort='magnitude')

# y ~ x1 + x2+ x3
# log(y) ~ scale(x1) + scale(x2) + ...

library(recipes)

sal_recipe <- recipe(SalaryCY ~ ., 
                     data=train
) %>%
    step_rm(SalaryPY, BonusPY, BonusCY, ID) %>% 
    step_log(SalaryCY, base=10) %>% 
    step_zv(all_predictors()) %>% 
    step_knnimpute(all_predictors()) %>% 
    step_normalize(all_numeric(), -SalaryCY) %>% 
    step_other(all_nominal()) %>% 
    step_dummy(all_nominal(), one_hot=TRUE)
sal_recipe

sal_prepped <- sal_recipe %>% prep(data=train)
sal_prepped

sal_prepped %>% bake(new_data=train)

train_x <- sal_prepped %>% bake(all_predictors(), new_data=train, 
                                composition='matrix')
head(train_x)
train_y <- sal_prepped %>% bake(all_outcomes(), new_data=train,
                                composition='matrix')
head(train_y)

library(glmnet)

sal3 <- glmnet(x=train_x, y=train_y, family='gaussian', standardize=FALSE)
sal3
head(coef(sal3))
plot(sal3, xvar='lambda')
plot(sal3, xvar='lambda', label=TRUE)
coefpath(sal3)

sal4 <- cv.glmnet(x=train_x, y=train_y, family='gaussian',
                  standardize=FALSE, nfolds=5)
plot(sal4)
sal4$lambda
coefpath(sal4)
sal4$lambda.min
sal4$lambda.1se

coefplot(sal4, sort='magnitude', lambda=.8736)
coefplot(sal4, sort='magnitude', lambda=.008736)
coefplot(sal4, sort='magnitude', lambda=.08736)
coefplot(sal4, sort='magnitude', lambda=.0008736, intercept=FALSE)
coefplot(sal4, sort='magnitude', lambda='lambda.min', intercept=FALSE)
coefplot(sal4, sort='magnitude', lambda='lambda.1se', intercept=FALSE)
coefplot(sal4, sort='magnitude', lambda='lambda.1se', intercept=FALSE, 
         plot=FALSE) %>% nrow

sal5 <- cv.glmnet(x=train_x, y=train_y, family='gaussian', 
                  nfolds=5, standardize=FALSE, alpha=0)
coefpath(sal5)
sal6 <- cv.glmnet(x=train_x, y=train_y, family='gaussian', 
                  nfolds=5, standardize=FALSE, alpha=0.7)
coefpath(sal6)

test_x <- sal_prepped %>% bake(all_predictors(), new_data=test, 
                               composition='matrix')
test_y <- sal_prepped %>% bake(all_outcomes(), new_data=test,
                               composition='matrix')

sal_preds6 <- predict(sal6, newx=test_x, s='lambda.1se')
head(sal_preds6)
head(10^sal_preds6)

test %>% 
    mutate(Predicted_Salary=as.vector(10^sal_preds6)) %>% 
    select(SalaryCY, Predicted_Salary)

sqrt(mean((test_y - sal_preds6)^2))
