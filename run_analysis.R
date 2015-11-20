## Packages
library(data.table)
library(reshape2)

## Directory
path.root <- "~/Dropbox/PhD/Coursera Data Science/3 Getting and Cleaning Data/Course Project"
path.data <- file.path(path.root,"UCI HAR Dataset")

setwd(path.root)

## Get vectors of files to be read
# In train folder
files <- list.files(
	path.data, 
	pattern = "*.txt", 
	recur = T,
	full = T
)
files <- files[!files %like% "features_info.txt"]
files <- files[!files %like% "README.txt"]

## Get data
# vector of object names
DT.names <- strsplit(files, "/") # Split path at "/"
DT.names <- unlist(lapply(DT.names, tail, 1)) # Extract last element
DT.names <- gsub(".txt","",DT.names) # Remove ".txt"

for (i in 1:length(files)){
	setTxtProgressBar(txtProgressBar(1,length(files),style=3),i)
	DT <- read.table(files[i])
	DT <- as.data.table(DT)
	assign(DT.names[i],DT)
	rm(DT)
}	

## Inspect data in memory
tables(order.col = "NROW")

## Clean up features list
features[, V2 := as.character(V2)]


## Cleaning test and train
# Add activity to y_test and y_train
test <- merge(y_test, activity_labels, by = "V1")
train <- merge(y_train, activity_labels, by = "V1")

# Add Y and X together
test <- cbind(subject_test, test[, V2], X_test)
train <- cbind(subject_train, train[, V2], X_train)

# Add column names
setnames(test, c("Subject", "Activity", features[, as.character(V2)]))
setnames(train, c("Subject", "Activity", features[, as.character(V2)]))

## combine test and train
# Add a dataset ID 
test[, Dataset := "Test"]
train[, Dataset := "Train"]

# Bind together
DT <- rbindlist(list(test,train), use.names = TRUE)

# Melt the data
DT <- melt(
	DT, 
	id.vars = c("Subject", "Activity", "Dataset"), 
	variable.name = "FeatureOrig", 
	value.name = "Value"
)

# Split the Feature column for easy access
DT[, FeatureOrig := as.character(FeatureOrig)] # Character is better
DT[, c("FeatureExpr1", "FeatureExpr2", "FeatureExpr3") := tstrsplit(FeatureOrig, "-", fixed = TRUE)]

# Reorder columns
setcolorder(DT, c())

DT <- DT[FeatureExpr2 %chin% "mean()" | FeatureExpr2 %chin% "std()", ]




