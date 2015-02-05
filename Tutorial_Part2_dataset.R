# Part 2. Initial data transformations and building dataset
# Script should be run in R (/Rstudio)


### ASSIGN PATHS TO YOUR OWN DIRECTORIES ###
initial_data_dir <- "~/Documents/ShoeFetish/data/dsw/image/"
working_data_dir <- "~/Documents/ShoeFetish/shoefetish01/shoefetish010/"
nconvert_dir <- "~/Documents/ShoeFetish/shoefetish01/shoefetish011/nconvert"




### INITIAL DATA TRANSFORMATION : NConvert ###
# find edges, grayscale, and resize images for training
system(paste(nconvert_dir, ' -out jpeg -o ',working_data_dir, 'converteddata/%.jpg -resize 100 100 -edgedetect light -grey 128 ', initial_data_dir, '*.jpg', sep=""))
directory <- paste(working_data_dir,'converteddata/',system(paste('ls ',working_data_dir,'converteddata/', sep=""), intern=TRUE),sep="")

# resize images later used in presentation of results
system(paste(nconvert_dir, ' -out jpeg -o ',working_data_dir,'www/%.jpg -resize 100 100 ',initial_data_dir,'*.jpg', sep=""))
directory_show <- paste(working_data_dir,'www/',system(paste('ls ',working_data_dir,'www/', sep=""),intern=TRUE),sep="")

remove(nconvert_dir, initial_data_dir)



### READ IN DATA ###
library(jpeg)
x <- readJPEG(directory[1])
vec <- c(x[,])
if (length(directory) > 1) {
    for (i in 2:length(directory)) {
      x <- readJPEG(directory[i])
      y <- c(x[,])
      vec <- cbind(vec, y)
    }
}
vec2 <- as.data.frame(t(vec))
remove(i,x,vec,y)

write.csv(vec2,file=paste(working_data_dir,'train_matrix.csv', sep=""))
save(vec2, directory, directory_show, file=paste(working_data_dir,'checkpoint1.Rdata', sep=""))