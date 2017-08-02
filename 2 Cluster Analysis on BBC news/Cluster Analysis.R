setwd("C:/Users/PG/Desktop/Data Analysis in R/2 Cluster Analysis on BBC news")
getwd()
library(tm)

#Create Corpus with all documents in the directory
docs <- Corpus (DirSource ("C:/Users/PG/Desktop/Data Analysis in R/2 Cluster Analysis on BBC news/10combined/."))
docs

getTransformations()

#Transform to lower case
docs <- tm_map(docs,content_transformer(tolower))

#remove potentiallyy problematic symbols
toSpace <- content_transformer(function(x, pattern) { return (gsub(pattern, " ", x))})

docs <- tm_map(docs, toSpace, "-")
docs <- tm_map(docs, toSpace, ":")
docs <- tm_map(docs, toSpace, "'")
docs <- tm_map(docs, toSpace, " -")
docs <- tm_map(docs, toSpace, '"')

#remove punctuation
docs <- tm_map(docs, removePunctuation)
#Strip digits
docs <- tm_map(docs, removeNumbers)
#remove stopwords
docs <- tm_map(docs, removeWords, stopwords("english"))
#remove whitespace
docs <- tm_map(docs, stripWhitespace)
writeLines(as.character(docs[[20]]))

docs <- tm_map(docs,stemDocument)

docs <- tm_map(docs, content_transformer(gsub),pattern = "organiz", replacement = "organ")
docs <- tm_map(docs, content_transformer(gsub), pattern = "organis", replacement = "organ")
docs <- tm_map(docs, content_transformer(gsub), pattern = "andgovern", replacement = "govern")
docs <- tm_map(docs, content_transformer(gsub), pattern = "inenterpris", replacement = "enterpris")
docs <- tm_map(docs, content_transformer(gsub), pattern = "team-", replacement = "team")


myStopwords <- c("can", "say","one","way","use",
                 "also","howev","tell","will",
                 "much","need","take","tend","even",
                 "like","particular","rather","said",
                 "get","well","make","ask","come","end",
                 "first","two","help","often","may",
                 "might","see","someth","thing","point",
                 "post","look","right","now","think","'ve ",
                 "'re ")
#remove custom stopwords
docs <- tm_map(docs, removeWords, myStopwords)

dtm <- DocumentTermMatrix(docs)
#print a summary
dtm

#convert dtm to matrix
m <- as.matrix(dtm)
#write as csv file (optional)
write.csv(m,file="Clusters.csv")
#shorten rownames for display purposes
#rownames(m) <- paste(substring(rownames(m),1,3),rep("..",nrow(m)),
#                     substring(rownames(m), 
#                     nchar(rownames(m))-12,nchar(rownames(m))-4))
#compute distance between document vectors
d <- dist(m)

#run hierarchical clustering using Ward's method
groups <- hclust(d,method="ward.D")
#plot dendogram, use hang to ensure that labels fall below tree
plot(groups, hang=-1)


#cut into 2 subtrees - try 3 and 5
rect.hclust(groups,3)


#k means algorithm, 2 clusters, 100 starting configurations
kfit <- kmeans(d, 2, nstart=100)
#plot - need library cluster
library(cluster)
clusplot(m, kfit$cluster, color=T, shade=T, labels=2, lines=0)

#kmeans - determine the optimum number of clusters (elbow method)
#look for "elbow" in plot of summed intra-cluster distances (withinss) as fn of k
wss <- 2:29
for (i in 2:29) wss[i] <- sum(kmeans(d,centers=i,nstart=25)$withinss)
plot(2:29, wss[2:29], type="b", xlab="Number of Clusters",ylab="Within groups sum of squares")

