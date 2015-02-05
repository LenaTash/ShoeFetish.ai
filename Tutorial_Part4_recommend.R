# Part 4. Scoring new image against model (or, "how to actually get some recommendations")


### TEST A NEW IMAGE AGAINST PRE-LOADED MODEL ###
a <- input$newpic[1,]
listtestfiles <- a$name

system('rm ~/Documents/ShoeFetish/shoefetish01/shoefetish010/testdata/current.jpg')
system('rm ~/Documents/ShoeFetish/shoefetish01/shoefetish010/testdata/current_small.jpg')
system(paste('~/Documents/ShoeFetish/shoefetish01/shoefetish010/nconvert -out jpeg -o ~/Documents/ShoeFetish/shoefetish01/shoefetish010/testdata/current.jpg -resize 100 100 -edgedetect light -grey 128 ', a$datapath, sep=""))
system(paste('~/Documents/ShoeFetish/shoefetish01/shoefetish010/nconvert -out jpeg -o ~/Documents/ShoeFetish/shoefetish01/shoefetish010/testdata/current_small.jpg -resize 100 100 ', a$datapath, sep=""))

library(jpeg)
x <- readJPEG('~/Documents/ShoeFetish/shoefetish01/shoefetish010/testdata/current.jpg')
vec <- c(x[,])
vec3 <- as.data.frame(t(vec))
remove(x,vec)

test_h2o <- as.h2o(localH2O, vec3, key="test")

ptest <- as.matrix(h2o.deepfeatures(test_h2o,model_main,layer=-1))
a1 <- pdist(ptest,ptrain_main)

a1_dist <- a1@dist
a1_n <- a1@n
a1_p <- a1@p
b1 <- matrix(a1_dist, nrow=a1_n, ncol=a1_p)
scores1 <- b1[1,]
q1 <- as.data.frame(scores1)
q1$files <- directory
q1$goodfiles <- directory_show
q1 <- q1[order(q1$scores),]

c(q1$goodfiles[1],q1$goodfiles[2],q1$goodfiles[3],q1$goodfiles[4],q1$goodfiles[5])



