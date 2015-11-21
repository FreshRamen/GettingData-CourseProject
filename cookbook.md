Cookbook for tidy dataset
=========================

The dataset represents a tidy version of the *Human Activity Recognition Using Smartphones Dataset V1*, available via [cloudfront]. Additional details regarding the dataset are provided by [UCL Irvine]. 

## Overview of dataset

30 subjects participated in the experiment (identified by variable **Subject**). 30% of whom were sorted into a *test* sample and 70% into a *training* sample, which is captured by the variable **Dataset**. Each subject performed an activity while wearing the smartphone device, which is identified by the variable **Activity**.

The original dataset moreover provided various measures and aggregations. These are provided in the variables. **Feature**, **Method**, and **Dimension**. **Dimension** takes on the values X, Y or Z, reflecting the dimensions in which data was recorded. . The **Feature** is an identifier placed by the authors, identifying the type of sensor used, among other things. 

**Method** is the aggregation method chosen by the authors of the dataset, for example `mean()` or `str()`. It only exists in the non-tidy dataset created for steps 1-4.

Values in the tidy dataset created for step 5 (`DT.mean` in memory, or `"Tidy Dataset.txt"` after exporting), are presented in two columns: **mean()** and **std()**, representing the average means and standard deviations of the orignal dataset, by Subject, Activity, Feature, and Dimension. Both are normalized, please see the original dataset manuals provided above for additional info on measurement. 

## Alterations compared to source
* The original **Feature** had (at most) three expressions pasted together, separated by "-". For readability, it was split up into three columns, at the "-":

 ** **Feature** representing the first argument
 ** **Method** representing the second argument
 ** **Dimension** representing the third argument

* A column **Dataset** was added, identifying subjects who were in either the *test* or *train* sample.

## Reproducability
The code `run_analysis.R` creates two data tables: 

1. `DT`
Contains all the data without further aggregation. It is not necessarily tidy and the records are not unique. Note that the question did not specify for it to be tidy. 
2. `DT.mean`
Contains average observations for each Subject-Activity-Feature-Dimension combination, recording the mean (**mean()**) and standard deviation (**std()**) in separate columns. This dataset is tidy, as the task specifies. 

`run_analysis.R` requires the package `data.table` to be installed in version `1.9.6`.

[cloudfront]: https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip

[UCL Irvine]: http://archive.ics.uci.edu/ml/datasets/Human+Activity+Recognition+Using+Smartphones