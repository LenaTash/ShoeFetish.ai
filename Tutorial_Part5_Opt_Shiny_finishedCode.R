# Optional Part 5. Implementing model as a Shiny app.

# to run app, run following line:
# print(source('Tutorial_Part5_Opt_Shiny_finishedCode.R'))


### PLEASE MAKE SURE PATHS ARE INITIALIZED CORRECTLY ###
initial_data_dir <- "~/Documents/ShoeFetish/data/dsw/image/"
working_data_dir <- "~/Documents/ShoeFetish/shoefetish01/shoefetish010/"
nconvert_dir <- "~/Documents/ShoeFetish/shoefetish01/shoefetish011/nconvert"




### NOTHING AFTER THIS POINT NEEDS TO BE CHANGED ###

library(h2o)
localH2O <- h2o.init(nthreads = -1)

directory <- paste(working_data_dir,'converteddata/',system(paste('ls ',working_data_dir,'converteddata/', sep=""), intern=TRUE),sep="")
if(length(directory)==0) {
	system(paste(nconvert_dir, ' -out jpeg -o ',working_data_dir, 'converteddata/%.jpg -resize 100 100 -edgedetect light -grey 128 ', initial_data_dir, '*.jpg', sep=""))
	directory <- paste(working_data_dir,'converteddata/',system(paste('ls ',working_data_dir,'converteddata/', sep=""), intern=TRUE),sep="")
}

directory_show <- paste(working_data_dir,'www/',system(paste('ls ',working_data_dir,'www/', sep=""),intern=TRUE),sep="")
if(length(directory_show)==0) {
	system(paste(nconvert_dir, ' -out jpeg -o ',working_data_dir,'www/%.jpg -resize 100 100 ',initial_data_dir,'*.jpg', sep=""))
	directory_show <- paste(working_data_dir,'www/',system(paste('ls ',working_data_dir,'www/', sep=""),intern=TRUE),sep="")
}


if(length(list.files(path=paste(getwd(),"/model_main", sep=""))) == 0 ){
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

		predictors <- colnames(vec2)

		initial_h2o <- as.h2o(localH2O, vec2, key="initial")
		
		model_cluster <- h2o.kmeans(data=initial_h2o, centers=42, init="furthest")
		vec2$label <- paste("a_",as.character(as.data.frame(h2o.predict(object=model_cluster, newdata=initial_h2o))$predict),sep="")

		train_h2o <- as.h2o(localH2O, vec2, key="train")
	
		model_main <- h2o.deeplearning(x=predictors, y="label",data=train_h2o, activation="Tanh",hidden=c(250,50,10), epochs=8, autoencoder=TRUE)
	
		print(h2o.saveModel(model_main, dir=working_data_dir, name="model_main", save_cv=TRUE, force=TRUE))
	
		ptrain_main <- as.matrix(h2o.deepfeatures(train_h2o,model_main,layer=-1))
		save(ptrain_main, file=paste(working_data_dir,"model_main/ptrain_main.RData",sep=""))
	
		print("(Done rebuilding model, btw)")
  
} else {
	model_main <-  h2o.loadModel(localH2O, path=paste(working_data_dir, "model_main", sep=""))
	load(paste(working_data_dir,"model_main/ptrain_main.RData",sep=""))
}





library(shiny)
server <- function(input, output) {
  
  findFiles <- reactive({
    if(length(input$newpic)>0) {
      a <- input$newpic[1,]
      listtestfiles <- a$name
      
			system(paste('rm ',working_data_dir,'testdata/current.jpg', sep=""))
			system(paste('rm ',working_data_dir,'testdata/current_small.jpg', sep=""))
			system(paste(nconvert_dir,' -out jpeg -o ',working_data_dir,'testdata/current.jpg -resize 100 100 -edgedetect light -grey 128 ', test_pic_path, sep=""))
			system(paste(nconvert_dir,' -out jpeg -o ',working_data_dir,'testdata/current_small.jpg -resize 100 100 ', test_pic_path, sep=""))
      
      library(jpeg)
			x <- readJPEG(paste(working_data_dir,'testdata/current.jpg', sep=""))
      vec <- c(x[,])
      vec3 <- as.data.frame(t(vec))
      remove(x,vec)
      
      test_h2o <- as.h2o(localH2O, vec3, key="test")
      
      ptest <- as.matrix(h2o.deepfeatures(test_h2o,model_main,layer=-1))
      
      library(pdist)
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
			remove(a1_dist,a1_n,a1_p)
			remove(a1, b1, scores1)

      c(q1$goodfiles[1],q1$goodfiles[2],q1$goodfiles[3],q1$goodfiles[4],q1$goodfiles[5])
      
    } 
    
  })
  
  output$testingImage <- renderImage({
    if(length(input$newpic)>0) {
      p <- findFiles()
      list(src = paste(working_data_dir,"testdata/current_small.jpg",sep=""))
    } else {list(src = paste(working_data_dir,"blanksquare.jpg",sep=""))}
  }, deleteFile = FALSE)
  
  output$resultImage1 <- renderImage({
    if(length(input$newpic)>0) {
      p <- findFiles()
      list(src = p[1])
    } else {list(src = paste(working_data_dir,"blanksquare.jpg",sep=""))}
  }, deleteFile = FALSE)
  
  output$resultImage2 <- renderImage({
    if(length(input$newpic)>0) {
      p <- findFiles()
      list(src = p[2])
    } else {list(src = paste(working_data_dir,"blanksquare.jpg",sep=""))}
  }, deleteFile = FALSE)
  
  output$resultImage3 <- renderImage({
    if(length(input$newpic)>0) {
      p <- findFiles()
      list(src = p[3])
    } else {list(src = paste(working_data_dir,"blanksquare.jpg",sep=""))}
  }, deleteFile = FALSE)
  
  output$resultImage4 <- renderImage({
    if(length(input$newpic)>0) {
      p <- findFiles()
      list(src = p[4])
    } else {list(src = paste(working_data_dir,"blanksquare.jpg",sep=""))}
  }, deleteFile = FALSE)
  
  output$resultImage5 <- renderImage({
    if(length(input$newpic)>0) {
      p <- findFiles()
      list(src = p[5])
    } else {list(src = paste(working_data_dir,"blanksquare.jpg",sep=""))}
  }, deleteFile = FALSE)

}




ui <- shinyUI(fluidPage(
  
  titlePanel("ShoeFetish 0.1.1"),
  
  sidebarLayout(
    sidebarPanel(fileInput("newpic", label = "Upload a picture to be tested", accept = '.jpg')),
    mainPanel()
  ),
    
  conditionalPanel("input.newpic.length == 1",
                   h5("Your shoe:"),
                   imageOutput("testingImage", height=100),
                   h5("Similar shoes:"),
                   imageOutput("resultImage1", height=100),
                   imageOutput("resultImage2", height=100),
                   imageOutput("resultImage3", height=100),
                   imageOutput("resultImage4", height=100),
                   imageOutput("resultImage5", height=100)
  )
))


shinyApp(ui = ui, server = server)


### SHUTS DOWN H2O SERVER ON YOUR COMPUTER AND CLEANS UP R WORKSPACE ###
# h2o.shutdown(localH2O)
# rm(list=ls())