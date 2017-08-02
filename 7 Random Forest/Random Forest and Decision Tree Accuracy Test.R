getwd()
setwd("C:/Users/PG/Desktop/sharma links copy/7 Random Forest/")
getwd()

#load required libraries - rpart for classification and regression trees
library(rpart)

#mlbench for Glass dataset
library(mlbench)

#load required library - randomForest
library(randomForest)

#load Glass
data("Glass")
Glass
#set seed to ensure reproducible results
set.seed(42)

#split into training and test sets
Glass[,"train"] <- ifelse(runif(nrow(Glass))<0.8,1,0)

#separate training and test sets
trainGlass <- Glass[Glass$train==1,]
testGlass <- Glass[Glass$train==0,]

#get column index of train flag
trainColNum <- grep("train",names(trainGlass))

#remove train flag column from train and test sets
trainGlass <- trainGlass[,-trainColNum]
testGlass <- testGlass[,-trainColNum]

#get column index of predicted variable in dataset
typeColNum <- grep("Type",names(Glass))

#build DT model
rpart_model <- rpart(Type ~.,data = trainGlass, method="class")

#Testing DT
rpart_predict <- predict(rpart_model,testGlass[,-typeColNum],type="class")

#Accuracy of DT
mean(rpart_predict==testGlass$Type)


#build RF model
Glass.rf <- randomForest(Type ~.,data = trainGlass, importance=TRUE, xtest=testGlass[,-typeColNum],ntree=1000)

#Get summary info
Glass.rf


#accuracy for test set
mean(Glass.rf$test$predicted==testGlass$Type)

#confusion matrix
table(Glass.rf$test$predicted,testGlass$Type)

