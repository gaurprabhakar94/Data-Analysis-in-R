#set working directory if needed (modify path as needed)
setwd("C:/Users/PG/Desktop/sharma links copy/6 Decision Trees")

#load required libraries - rpart for classification and regression trees
library(rpart)

#mlbench for Ionosphere dataset
library(mlbench)

#load Boston Housing dataset
data("BostonHousing")

#set seed to ensure reproducible results
set.seed(42)
#split into training and test sets
BostonHousing[,"train"] <- ifelse(runif(nrow(BostonHousing))<0.8,1,0)
#separate training and test sets
trainset <- BostonHousing[BostonHousing$train==1,]
testset <- BostonHousing[BostonHousing$train==0,]
#get column index of train flag
trainColNum <- grep("train",names(trainset))
#remove train flag column from train and test sets
trainset <- trainset[,-trainColNum]
testset <- testset[,-trainColNum]

#build model
rpart_model <- rpart(medv~.,data = trainset, method="anova")
#plot tree
plot(rpart_model);text(rpart_model)

#Testing
rpart_test_predict <- predict(rpart_model,testset[,-trainColNum],type = "vector" )
#calculate RMS error
rmsqe <- sqrt(mean((rpart_test_predict-testset$medv)^2))
rmsqe

# get index of CP with lowest xerror
opt <- which.min(rpart_model$cptable[,"xerror"])
#get its value
cp <- rpart_model$cptable[opt, "CP"]
#prune tree
pruned_model <- prune(rpart_model,cp)
#plot tree
plot(pruned_model);text(pruned_model)

