#set working directory if needed (modify path as needed)
setwd("C:/Users/PG/Desktop/sharma links copy/6 Decision Trees")

#load required libraries - rpart for classification and regression trees
library(rpart)

#mlbench for Ionosphere dataset
library(mlbench)

#load Ionosphere
data("Ionosphere")


#function to do multiple runs
multiple_runs_classification <- function(train_fraction,n,dataset,prune_tree=FALSE){
  fraction_correct <- rep(NA,n)
  set.seed(42)
  for (i in 1:n){
    dataset[,"train"] <- ifelse(runif(nrow(dataset))<0.8,1,0)
    trainColNum <- grep("train",names(dataset))
    typeColNum <- grep("Class",names(dataset))
    trainset <- dataset[dataset$train==1,-trainColNum]
    testset <- dataset[dataset$train==0,-trainColNum]
    rpart_model <- rpart(Class~.,data = trainset, method="class")
    if(prune_tree==FALSE) {
      rpart_test_predict <- predict(rpart_model,testset[,-typeColNum],type="class")
      fraction_correct[i] <- mean(rpart_test_predict==testset$Class)
    }else{
      opt <- which.min(rpart_model$cptable[,"xerror"])
      cp <- rpart_model$cptable[opt, "CP"]
      pruned_model <- prune(rpart_model,cp)
      rpart_pruned_predict <- predict(pruned_model,testset[,-typeColNum],type="class")
      fraction_correct[i] <- mean(rpart_pruned_predict==testset$Class)
    }
  }
return(fraction_correct)
}

#50 runs, no pruning
unpruned_set <- multiple_runs_classification(0.8,50,Ionosphere)
mean(unpruned_set)

sd(unpruned_set)


#50 runs, with pruning
pruned_set <- multiple_runs_classification(0.8,50,Ionosphere,prune_tree=TRUE)
mean(pruned_set)

sd(pruned_set)

