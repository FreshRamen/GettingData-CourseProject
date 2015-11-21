#### run_analysis.R
# Script performs the data cleaning as demanded by the project
# description. It doesn't necessary follow the steps in order, 
# but rather performs similar tasks at the same time, so it's
# structured for readability rather than order of execution.
# It should also be quite efficient. Since it's entirely based
# on the data.table package.

## Packages
library(data.table) # Requires 1.9.6, check packageVersion("data.table")

## Directories
path.root <- "~/Dropbox/PhD/Coursera Data Science/3 Getting and Cleaning Data/Course Project"
path.data <- file.path(path.root,"UCI HAR Dataset")

setwd(path.data)


#############################
### Read data into memory ###
#############################

## Get vector of files to be read
# I simply read all the .txt files in the data directory, then 
# exclude the ones I don't need.
files <- list.files( # Get the vector
	path.data, 
	pattern = "*.txt", 
	recursive = T,
	full.names = T
)
files <- files[ # Exclude some files
	!files %like% "features_info.txt" & 
	!files %like% "README.txt"
]


## Create a vector of object names
# files contains paths (full.names=T) and the file ending. 
# The code below cleans that up. 
DT.names <- strsplit(files, "/") # Split path at "/"
DT.names <- unlist(lapply(DT.names, tail, 1)) # Extract last element
DT.names <- gsub(".txt","",DT.names) # Remove ".txt"


## Get data
# The for loop reads the data in and shows a progress bar, since
# it is a bit slow. fread() in the data.table package does not
# work with files of the type provided. 
for (i in 1:length(files)){
	setTxtProgressBar(txtProgressBar(1,length(files),style=3),i)
	DT <- read.table(files[i])
	DT <- as.data.table(DT)
	assign(DT.names[i],DT)
	rm(DT)
}	

##################
### Clean data ###
##################
# This is mulitple ways to get to the result. I chose to combine
# everything and then to narrow down from there.

## Inspect data in memory
tables(order.col = "NROW")

### Create combined data table

## Add activity to y_test and y_train
# This steo is essentially task (3)
test <- merge(y_test, activity_labels, by = "V1")
train <- merge(y_train, activity_labels, by = "V1")

## Bind X and Y
test <- cbind(subject_test, test[, V2], X_test)
train <- cbind(subject_train, train[, V2], X_train)

## Add column names
setnames(test, c("Subject", "Activity", features[, as.character(V2)]))
setnames(train, c("Subject", "Activity", features[, as.character(V2)]))

## Add a dataset ID 
test[, Dataset := "Test"]
train[, Dataset := "Train"]

## Bind training and test data together
# This is essentially task (1)
DT <- rbindlist(list(test,train), use.names = TRUE)

## Create a tidy panel dataset
# I'd rather have only values in one column, and another column to
# idenfity the Feature. I call this column "FeatureOrig" because 
# I will split it up for readability in the next step.
DT <- melt(
	DT, 
	id.vars = c("Subject", "Activity", "Dataset"), 
#	variable.factor = FALSE,
	variable.name = "FeatureOrig", 
	value.name = "Value"
)

### Cleaning up Features
# Features appears to be several expressions, pasted together with 
# "-". For easy reading and access, I split them up. 
# For cleanliness, I also remove the original Feature
DT[, FeatureOrig := as.character(FeatureOrig)]
DT[, c("FeatureExpr1", "FeatureExpr2", "FeatureExpr3") := tstrsplit(FeatureOrig, "-", fixed = TRUE)]
DT[, FeatureOrig := NULL]

## Reorder columns
setcolorder(DT, c(colnames(DT)[c(1:4, 6:8)], "Value") )

## Descriptive names for Features
# The first expression appears to be the actual Feature (i.e. which 
# feature use on which body part. The second expression is the method
# with which the statistic was computed. The third expression appears
# to be the dimension. This is essentially task (4)
setnames(
	DT, 
	c("FeatureExpr1", "FeatureExpr2", "FeatureExpr3"),
	c("Feature", "Method", "Dimension")
)


### Extract mean() and std() 
# This refers to taks (2)
DT <- DT[Method %chin% "mean()" | Method %chin% "std()", ]


### Averages by FeatureOrig, Subject and Activity
# Task (5) from hereon out.
DT.mean <- DT[
	, 
	mean(Value), 
	keyby = list(Subject, Activity, Dataset, Feature, Dimension, Method)
]

## Reshape mean and str in own column
# This seems tidier to me.
DT.mean <- dcast.data.table(
	DT.mean, 
	Subject + Activity + Dataset + Feature + Dimension ~ Method,
	value.var = "V1"
)

############################
### Export tidy data set ###
############################

write.table(DT.mean, file = "Tidy Dataset.txt")


