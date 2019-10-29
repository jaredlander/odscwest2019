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
