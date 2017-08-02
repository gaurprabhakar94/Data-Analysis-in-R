#load text mining library
library(tm)

getwd()
setwd("C:/Users/PG/Desktop/Data Analysis in R/5 Network Graphs/10combined")
getwd()


#load files into corpus
#get listing of .txt files in directory
filenames <- list.files(getwd(),pattern="*.txt")

#read files into a character vector
files <- lapply(filenames,readLines)

#create corpus from vector
docs <- Corpus(VectorSource(files))

#inspect a particular document in corpus
writeLines(as.character(docs[[30]]))

#start preprocessing
#Transform to lower case
docs <-tm_map(docs,content_transformer(tolower))

#remove potentially problematic symbols
toSpace <- content_transformer(function(x, pattern) { return (gsub(pattern, " ", x))})
docs <- tm_map(docs, toSpace, "-")
docs <- tm_map(docs, toSpace, "'")
docs <- tm_map(docs, toSpace, '"')
docs <- tm_map(docs, toSpace, ":")
docs <- tm_map(docs, toSpace, " -")

#remove punctuation
docs <- tm_map(docs, removePunctuation)

#Strip digits
docs <- tm_map(docs, removeNumbers)

#remove stopwords
docs <- tm_map(docs, removeWords, stopwords("english"))

#remove whitespace
docs <- tm_map(docs, stripWhitespace)

#Good practice to check every now and then
writeLines(as.character(docs[[30]]))

#Stem document
docs <- tm_map(docs,stemDocument)


#fix up 1) differences between us and aussie english 2) general errors
docs <- tm_map(docs, content_transformer(gsub),
               pattern = "organiz", replacement = "organ")
docs <- tm_map(docs, content_transformer(gsub),
               pattern = "organis", replacement = "organ")
docs <- tm_map(docs, content_transformer(gsub),
               pattern = "andgovern", replacement = "govern")
docs <- tm_map(docs, content_transformer(gsub),
               pattern = "inenterpris", replacement = "enterpris")
docs <- tm_map(docs, content_transformer(gsub),
               pattern = "team-", replacement = "team")

#define and eliminate all custom stopwords
myStopwords <- c("can", "say","one","way","use",
                 "also","howev","tell","will",
                 "much","need","take","tend","even",
                 "like","particular","rather","said",
                 "get","well","make","ask","come","end",
                 "first","two","help","often","may",
                 "might","see","someth","thing","point",
                 "post","look","right","now","think","'ve ",
                 "'re ","anoth","put","set","new","good",
                 "want","sure","kind","larg","yes,","day","etc",
                 "quit","sinc","attempt","lack","seen","awar",
                 "littl","ever","moreov","though","found","abl",
                 "enough","far","earli","away","achiev","draw",
                 "last","never","brief","bit","entir","brief",
                 "great","lot")

docs <- tm_map(docs, removeWords, myStopwords)

#inspect a document as a check
writeLines(as.character(docs[[30]]))

#Create document-term matrix
dtm <- DocumentTermMatrix(docs)

#The  rows of a DTM are document vectors
#The DTM therefore contains all the information we need to 
#calculate the cosine similarity between every pair of documents in the corpus
#The R code below implements this, after taking care of a few preliminaries.

#convert dtm to matrix
m<-as.matrix(dtm)

#write as csv file
write.csv(m,file="C:/Users/PG/Desktop/Data Analysis in R/5 Network Graphs/DTM.csv")

#Map filenames to matrix row numbers
#these numbers will be used to reference
#files in the network graph
filekey <- cbind(rownames(m),filenames)
write.csv(filekey,"C:/Users/PG/Desktop/Data Analysis in R/5 Network Graphs/FileKey.csv")

#compute cosine similarity between document vectors
#converting to distance matrix sets diagonal elements to 0
cosineSim <- function(x){
  as.dist(x%*%t(x)/(sqrt(rowSums(x^2) %*% t(rowSums(x^2)))))
}

cs <- cosineSim(m)
write.csv(as.matrix(cs),file="C:/Users/PG/Desktop/Data Analysis in R/5 Network Graphs/CosineSimilarity.csv")

#adjacency matrix: set entries below a certain threshold to 0.
#We choose half the magnitude of the largest element of the matrix
#as the cutoff. This is an arbitrary choice
cs[cs < max(cs)/2] <- 0
cs <- round(cs,3)
write.csv(as.matrix(cs),file="C:/Users/PG/Desktop/Data Analysis in R/5 Network Graphs/AdjacencyMatrix.csv")




