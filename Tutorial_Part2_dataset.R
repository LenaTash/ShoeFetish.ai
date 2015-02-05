# Part 2. Initial data transformations and building dataset


### ASSIGN PATHS TO YOUR DIRECTORIES ###
initial_data_dir <- "~/Documents/ShoeFetish/shoefetish01/shoefetish010/"
working_data_dir <- "~/Documents/ShoeFetish/shoefetish01/shoefetish010/"


### INITIAL DATA TRANSFORMATION ###
# ADD: read "pre-directory"
# ADD: convert data in pre-directory to correct format and write into directory
# ADD: read "directory"


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
