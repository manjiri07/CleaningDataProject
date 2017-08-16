## Load the relevant packages
library(dplyr)

## Load features vector
features_data <- read.table("./UCI HAR Dataset/features.txt")

##Convert factor levels in features_data to character vector and store in features vector 
features <- as.character(features_data$V2)

## Load the training data
training_set <- read.table("./UCI HAR Dataset/train/X_train.txt")
training_labels <- read.table("./UCI HAR Dataset/train/y_train.txt")
training_subjects <- read.table("./UCI HAR Dataset/train/subject_train.txt")

## Add column names to the training_set using the features vector data frame
colnames(training_set) <- features

##Rename subject and label columns 
training_subjects <- rename(training_subjects, subject = V1)
training_labels <- rename(training_labels, label = V1)

##Bind the data frames by columns 
training_data <- cbind(training_subjects, training_labels, training_set)

##Load the test data
test_set <- read.table("./UCI HAR Dataset/test/X_test.txt")
test_labels <- read.table("./UCI HAR Dataset/test/y_test.txt")
test_subjects <- read.table("./UCI HAR Dataset/test/subject_test.txt")

##Rename subject and label columns 
test_subjects <- rename(test_subjects, subject = V1)
test_labels <- rename(test_labels, label = V1)

## Add column names to the test_set using the features vector data frame
colnames(test_set) <- features

##Bind the data frames by columns
test_data <- cbind(test_subjects, test_labels, test_set)

##Append the training and test data sets
complete_set_data <- rbind(training_data, test_data)

## Find all columns that have a mean and standard deviation measurement
mean_std_cols <- grep('mean*|std*', names(complete_set_data))

## Create a column vector with the first two columns (subject, label) and columns with mean and std
col <- c(1,2)
col <- append(col, mean_std_cols)

## Create a reduced dataset with the necessary columns 
reduced_set_data <- complete_set_data[,col]

## Reorder the subjects from 1 to 30
reduced_ordered_data  <- reduced_set_data[order(reduced_set_data$subject),]

## Load the activity label table
activity_label <- read.table("./UCI HAR Dataset/activity_labels.txt")
activity_label$V2 <- as.character(activity_label$V2)

##Change the numerical labels to descriptive labels
label_list <- lapply(reduced_ordered_data$label, function(x) x <- activity_label$V2[x])
reduced_ordered_data$label <- unlist(label_list,use.names = FALSE)

## Average of each variable for each subject and activity 
average_data <- summarise_all(group_by(reduced_ordered_data, subject, label),mean)

## Export to text file
write.table(average_data, file = "./average_data.txt", row.name = FALSE)
