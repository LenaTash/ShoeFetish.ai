# Part 4. Scoring new image against model (or, "how to actually get some recommendations")
# Script should be run in R (/Rstudio)


### ASSIGN PATHS TO YOUR OWN DIRECTORIES ###
test_pic_path <- "~/Documents/ShoeFetish/data/jimmychoo/image/141portmanccl_navy_side.jpg"
working_data_dir <- "~/Documents/ShoeFetish/shoefetish01/shoefetish010/"
nconvert_dir <- "~/Documents/ShoeFetish/shoefetish01/shoefetish011/nconvert"

# reload model and comparing set, if necessary
library(h2o)
localH2O <- h2o.init(nthreads = -1)
model_main <-  h2o.loadModel(localH2O, path=paste(working_data_dir, "model_main", sep=""))
load(paste(working_data_dir,"model_main/ptrain_main.RData",sep=""))
load(paste(working_data_dir,'checkpoint2.Rdata', sep=""))


### CLEAN TEST DIR, CONVERT TEST IMAGE, SAVE TO TEST DIR ###
system(paste('rm ',working_data_dir,'testdata/current.jpg', sep=""))
system(paste('rm ',working_data_dir,'testdata/current_small.jpg', sep=""))
system(paste(nconvert_dir,' -out jpeg -o ',working_data_dir,'testdata/current.jpg -resize 100 100 -edgedetect light -grey 128 ', test_pic_path, sep=""))
system(paste(nconvert_dir,' -out jpeg -o ',working_data_dir,'testdata/current_small.jpg -resize 100 100 ', test_pic_path, sep=""))


### LOAD IMAGE AND CONVERT TO 10K VECTOR ###
library(jpeg)
x <- readJPEG(paste(working_data_dir,'testdata/current.jpg', sep=""))
vec <- c(x[,])
vec3 <- as.data.frame(t(vec))
remove(x,vec)

### LOAD VECTOR TO H2O AS TEST SET ###
test_h2o <- as.h2o(localH2O, vec3, key="test")


### RUN VECTOR AGAINST MODEL AND EXTRACT FEATURES ###
ptest <- as.matrix(h2o.deepfeatures(test_h2o,model_main,layer=-1))


### CALCULATE DISTANCE BETWEEN EXTRACTED FEATURE VECTOR AND TRAINING SET ###
library(pdist)
a1 <- pdist(ptest,ptrain_main)

# find 5 images with minimum distance to test pic
a1_dist <- a1@dist
a1_n <- a1@n
a1_p <- a1@p
b1 <- matrix(a1_dist, nrow=a1_n, ncol=a1_p)
scores1 <- b1[1,]
q1 <- as.data.frame(scores1)
q1$files <- directory
q1$goodfiles <- directory_show
q1 <- q1[order(q1$scores),]
remove(a1_dist,a1_n,a1_p)
remove(a1, b1, scores1)

c(q1$goodfiles[1],q1$goodfiles[2],q1$goodfiles[3],q1$goodfiles[4],q1$goodfiles[5])



