getwd()
setwd("C:/Users/PG/Desktop/Data Analysis in R/1 Text Mining of Business News/")
getwd()
library(tm)

#Create Corpus with all documents in the directory
docs <- Corpus (DirSource ("C:/Users/PG/Desktop/Data Analysis in R/1 Text Mining of Business News/business/."))
docs

getTransformations()

#create the toSpace content transformer
toSpace <- content_transformer(function(x, pattern) {return (gsub(pattern, "", x))})

docs <- tm_map(docs, toSpace, "-")
docs <- tm_map(docs, toSpace, ":")
docs <- tm_map(docs, toSpace, "'")
docs <- tm_map(docs, toSpace, "'")
docs <- tm_map(docs, toSpace, " -")
docs <- tm_map(docs, toSpace, '"')

#Remove punctuation - replace punctuation marks with " "
docs <- tm_map(docs, removePunctuation)

#Transform to lower case (need to wrap in content_transformer)
docs <- tm_map(docs,content_transformer(tolower))

#Strip digits (std transformation, so no need for content_transformer)
docs <- tm_map(docs, removeNumbers)

#remove stopwords using the standard list in tm
docs <- tm_map(docs, removeWords, stopwords("english"))

#Strip whitespace (cosmetic?)
docs <- tm_map(docs, stripWhitespace)

#Checking if the above method was succesful or not
writeLines(as.character(docs[1]))

dtm <- DocumentTermMatrix(docs)
docs
dtm

#Viewing a small amount of processed work in the console
#This displays terms 1000 through 1005 in the first two rows of the DTM
inspect(dtm[1:510,1000:1005])

# to get the frequency of occurrence of each word in the corpus
freq <- colSums(as.matrix(dtm))

#length should be total number of terms
length(freq)

#create sort order (descending)
ord <- order(freq,decreasing=TRUE)

#inspect most frequently occurring terms
freq[head(ord)]

#inspect least frequently occurring terms
freq[tail(ord)]

#Words like "can" and "one"  give us no information about the subject matter 
#of the documents in which they occur. They can therefore be eliminated without loss.
dtmr <-DocumentTermMatrix(docs, control=list(wordLengths=c(4, 20),bounds = list(global = c(3,27))))

dtmr


freqr <- colSums(as.matrix(dtmr))
#length should be total number of terms
length(freqr)

#create sort order (asc)
ordr <- order(freqr,decreasing=TRUE)
#inspect most frequently occurring terms
freqr[head(ordr)]

#inspect least frequently occurring terms
freqr[tail(ordr)]

#frequency of words greater than 50 arranged alphabetically
findFreqTerms(dtmr,lowfreq=50)

findAssocs(dtmr,"chinese",0.6)
findAssocs(dtmr,"rosneft",0.6)
findAssocs(dtmr,"yukos",0.6)
findAssocs(dtmr,"club",0.6)
findAssocs(dtmr,"airlines",0.6)
findAssocs(dtmr,"insurance",0.6)

#The first line creates a data frame - a list of columns of equal length.
#A data frame also contains the name of the columns - in this case these are term 
#and occurrence respectively.  We then invoke ggplot(), telling it to 
#consider plot only those terms that occur more than 80 times.
#The aes option in ggplot describes plot aesthetics - in this case, 
#we use it to specify the x and y axis labels. The stat="identity" 
#option in geom_bar () ensures  that the height of each bar is proportional 
#to the data value that is mapped to the y-axis  (i.e occurrences). 
#The last line specifies that the x-axis labels should be at a 45 degree angle
#and should be horizontally justified. 

wf=data.frame(term=names(freqr),occurrences=freqr)
library(ggplot2)
p <- ggplot(subset(wf, freqr>50), aes(term, occurrences))
p <- p + geom_bar(stat="identity")
p <- p + theme(axis.text.x=element_text(angle=90, hjust=1))
p

#Load the wordcloud package which is not loaded by default. 
#Setting a seed number ensures that you get the same look each time 
#(try running it without setting a seed). The arguments of the wordcloud() 
#function are straightforward enough.
#Note that one can specify the maximum number of words to be included 
#instead of the minimum frequency
library(wordcloud)
set.seed(52)
wordcloud(names(freqr),freqr, min.freq=50)
#.add color
wordcloud(names(freqr),freqr,min.freq=50,colors=brewer.pal(6,'Dark2'))

