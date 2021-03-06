setwd("I:/Capstone/en_US/Project")
stop<-readLines(file("curse.txt","r"),skipNul=TRUE, encoding="UTF-8")

library(dplyr)
library(stringi)
library(stringr)
library(readr)
library(NLP)
library(RWeka)
library(tm)
library(ngram)
library(openNLP)
library(rJava)
library(wordcloud)
library(qdap)
library(quanteda)
library(qdapDictionaries)


blogs<-readLines("en_US.blogs.txt", encoding="UTF-8")
twitter<-readLines(file("en_US.twitter.txt","r"),skipNul=TRUE, encoding="UTF-8")
n<-file("en_US.news.txt", open="rb")
news<-readLines(n, encoding="UTF-8")

corp1<-sapply(blogs, function(x) iconv(x, "latin1", "ASCII", sub=""))
corp2<-sapply(twitter, function(x) iconv(x, "latin1", "ASCII", sub=""))
corp3<-sapply(news, function(x) iconv(x, "latin1", "ASCII", sub=""))

document<-c(corp1,corp2,corp3)
rm(blogs,twitter,n,news,corp1,corp2,corp3)

set.seed(12)
blogs_sample<-document[sample(1:length(document),1000000,replace=FALSE)]



funcs<-list(removePunctuation,removeNumbers,stripWhitespace)
token2<-function(x) NGramTokenizer(x,Weka_control(min=2,max=2))
token3<-function(x) NGramTokenizer(x,Weka_control(min=3,max=3))
token4<-function(x) NGramTokenizer(x,Weka_control(min=4,max=4))
token5<-function(x) NGramTokenizer(x,Weka_control(min=5,max=5))

setwd("I:/Capstone/en_US/Project/files")


#####FIVE WORDS N-GRAMS

doc<-document[1:2000]
corp<-Corpus(VectorSource(doc))
blogs_data<-tm_map(corp, FUN=tm_reduce, tmFuns=funcs)
blogs_data<-tm_map(blogs_data, content_transformer(tolower))
blogs_data<-tm_map(blogs_data, removeWords, stop)

b_data1<-TermDocumentMatrix(blogs_data,control=list(tokenize=token5))
blogs_matrix1<-as.matrix(b_data1)
blog_v1<-sort(rowSums(blogs_matrix1),decreasing=TRUE)
blog_name1<-names(blog_v1)
data1<-data.frame(words=blog_name1, freq=blog_v1)

for (i in (2001:4269679)){
    j<-i+2000
    d<-document[i:j]
    c<-Corpus(VectorSource(d))
    b<-tm_map(c, FUN=tm_reduce, tmFuns=funcs)
    b<-tm_map(b, content_transformer(tolower))
    b<-tm_map(b, removeWords, stop)
    
    b_d1<-TermDocumentMatrix(b, control=list(tokenize=token5))
    blogs_matrix1<-as.matrix(b_d1)
    blog_v1<-sort(rowSums(blogs_matrix1),decreasing=TRUE)
    blog_name1<-names(blog_v1)
    data_1<-data.frame(words=blog_name1, freq=blog_v1)
    
    data1<-merge(data1,data_1,by.x="words",by.y="words",all=TRUE)
    data1[is.na(data1)] <- 0
    data1<-mutate(data1,freq=freq.x+freq.y)
    data1<-subset(data1,select=-c(freq.x,freq.y))
    
    i<-i+2000
}
write.csv(data1,"Four Words.csv")
