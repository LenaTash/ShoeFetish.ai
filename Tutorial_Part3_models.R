# Part 3. Building models in H2O
# Script should be run in R (/Rstudio)


### ASSIGN PATHS TO YOUR OWN DIRECTORIES ###
working_data_dir <- "~/Documents/ShoeFetish/shoefetish01/shoefetish010/"

# use path to load dataset from checkpoint 1
load(paste(working_data_dir,'checkpoint1.Rdata', sep=""))

# save column names for later use
predictors <- colnames(vec2)



### LOAD H2O AND LOAD INITIAL DATA INTO H2O ###
library(h2o)
localH2O <- h2o.init(nthreads = -1)
initial_h2o <- as.h2o(localH2O, vec2, key="initial")



### K-MEANS CLUSTERING ###
model_cluster <- h2o.kmeans(data=initial_h2o, centers=42, init="furthest")
vec2$label <- paste("a_", as.character( as.data.frame( h2o.predict( object=model_cluster, newdata=initial_h2o))$predict),sep="")

# re-upload dataset to H2O with cluster labels included 
train_h2o <- as.h2o(localH2O, vec2, key="train")
  

### TRAIN AUTOENCODER ###
model_main <- h2o.deeplearning(x=predictors, y="label",data=train_h2o, activation="Tanh",hidden=c(250,50,10), epochs=8, autoencoder=TRUE)



### SAVE MODEL ###
print(h2o.saveModel(model_main, dir=working_data_dir, name="model_main", save_cv=TRUE, force=TRUE))
  
### SAVE TRANSFORMED INITIAL SET ###
ptrain_main <- as.matrix(h2o.deepfeatures(train_h2o,model_main,layer=-1))
save(ptrain_main, file=paste(working_data_dir,"model_main/ptrain_main.RData",sep=""))


### REMOVE UNNECESSARY OBJECTS AND SAVE CHECKPOINT ###
h2o.rm(localH2O, c("initial", "model_cluster", "train"))
remove(vec2, initial_h2o, model_cluster, train_h2o)

save(ptrain_main, directory_show, predictors, file=paste(working_data_dir,'checkpoint2.Rdata', sep=""))
