# Part 3. Building models in H2O


predictors <- colnames(vec2)


### LOAD INITIAL DATA TO H2O ###
###       AND KMEANS CLUSTER ###
initial_h2o <- as.h2o(localH2O, vec2, key="initial")
model_cluster <- h2o.kmeans(data=initial_h2o, centers=9, init="furthest")

### USE CLUSTERS AS LABELS ###
###      AND REUPLOAD TO H2O ###
vec2$label <- paste("a_", as.character( as.data.frame( h2o.predict( object=model_cluster, newdata=initial_h2o))$predict),sep="")
train_h2o <- as.h2o(localH2O, vec2, key="train")
  

### TRAIN AUTOENCODER ###
model_main <- h2o.deeplearning(x=predictors, y="label",data=train_h2o, activation="Tanh",hidden=c(250,50,10,50,250), epochs=8, autoencoder=TRUE)

### SAVE MODEL ###
print(h2o.saveModel(model_main, dir=getwd(), name="model_main", save_cv=TRUE, force=TRUE))
  
### SAVE TRANSFORMED INITIAL SET ###
ptrain_main <- as.matrix(h2o.deepfeatures(train_h2o,model_main,layer=3))
save(ptrain_main, file=paste(getwd(),"/model_main/ptrain_main.RData",sep=""))


