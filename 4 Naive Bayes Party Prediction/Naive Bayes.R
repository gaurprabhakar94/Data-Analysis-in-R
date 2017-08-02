#load mlbench library
library(mlbench)

#set working directory if needed (modify path as needed)
setwd("C:/Users/PG/Desktop/sharma links copy/4 Naive Bayes Party Prediction/")

#load HouseVotes84 dataset
data("HouseVotes84")

#barplots for specific issue
plot(as.factor(HouseVotes84[,2]))
title(main="Votes cast for issue", xlab="vote", ylab= "# reps")

#by party
plot(as.factor(HouseVotes84[HouseVotes84$Class=="republican",2]))
title(main="Republican votes cast for issue 1", xlab="vote", ylab="# reps")

plot(as.factor(HouseVotes84[HouseVotes84$Class=="democrat",2]))
title(main='Democrat votes cast for issue 1', xlab="vote", ylab="# reps")

#Functions needed for imputation
#function to return number of NAs by vote and class (democrat or republican)
na_by_col_class <- function (col,cls){
  return(sum(is.na(HouseVotes84[,col]) & HouseVotes84$Class==cls))}

#function to compute the conditional probability that a member of a party will cast a 'yes' vote for
#a particular issue. The probability is based on all members of the party who #actually cast a vote on the issue (ignores NAs).
p_y_col_class <- function(col,cls){
  sum_y<-sum(HouseVotes84[,col]=="y" & HouseVotes84$Class==cls,na.rm = TRUE)
  sum_n<-sum(HouseVotes84[,col]=="n" & HouseVotes84$Class==cls,na.rm = TRUE)
  return(sum_y/(sum_y+sum_n))}

#Check that functions work!
p_y_col_class(2,"democrat")

p_y_col_class(2,"republican")

na_by_col_class(2,"democrat")

na_by_col_class(2,"republican")


#divide into test and training sets
#create new col "train" and assign 1 or 0 in 80/20 proportion via random uniform dist
HouseVotes84[,"train"] <- ifelse(runif(nrow(HouseVotes84))<0.80,1,0)

#get col number of train / test indicator column (needed later)
trainColNum <- grep("train",names(HouseVotes84))

#separate training and test sets and remove training column before modeling
trainHouseVotes84 <- HouseVotes84[HouseVotes84$train==1,-trainColNum]
testHouseVotes84 <- HouseVotes84[HouseVotes84$train==0,-trainColNum]

#load e1071 library and invoke naiveBayes method
library(e1071)
nb_model <- naiveBayes(Class~.,data = trainHouseVotes84)




#function to create, run and record model results
nb_multiple_runs <- function(train_fraction,n){
  fraction_correct <- rep(NA,n)
  for (i in 1:n){
    HouseVotes84[,"train"] <- ifelse(runif(nrow(HouseVotes84))<train_fraction,1,0)
    trainColNum <- grep("train",names(HouseVotes84))
    trainHouseVotes84 <- HouseVotes84[HouseVotes84$train==1,-trainColNum]
    testHouseVotes84 <- HouseVotes84[HouseVotes84$train==0,-trainColNum]
    nb_model <- naiveBayes(Class~.,data = trainHouseVotes84)
    nb_test_predict <- predict(nb_model,testHouseVotes84[,-1])
    fraction_correct[i] <- mean(nb_test_predict==testHouseVotes84$Class)
    
    
  }
  return(fraction_correct)
}

#20 runs, 80% of data randomly selected for training set in each run
fraction_correct_predictions <- nb_multiple_runs(0.8,20)

fraction_correct_predictions

#summary of results
summary(fraction_correct_predictions)


#standard deviation
sd(fraction_correct_predictions)

nb_model
summary(nb_model)
str(nb_model)





