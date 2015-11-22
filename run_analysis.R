#
# Tidy the UCI HAR Dataset
#
# This is kind of a mess. Due the structure of the getdata course and the
# assignment deadlines you need to do most of the assignment before you 
# learn the tools to do with with.
#

library(dplyr, warn.conflicts=FALSE)
library(tidyr)

fetch.dataset <- function () {
    
    downloadDir <- "data"
    UCIHARMirrorURL <- 'https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip'
    
    cat("Fetching and unpacking the dataset files.\n")
    
    destPath <- file.path(downloadDir, basename(URLdecode(UCIHARMirrorURL)))
    fetchDateFile <- file.path(downloadDir, "fetchDate.txt")
    
    if (!file.exists(downloadDir)) {
        cat(paste("  * Creating download directory '", downloadDir, "'\n", sep=""))
        dir.create(downloadDir, showWarnings=FALSE)
    } else {
        cat(paste("  * Download directory '", downloadDir, "' already exists, not creating.\n", sep=""))
    }
    
    if (!file.exists(destPath)) {
        cat("  * Downloading UCI HAR Dataset ZIP file from mirror.\n")
        download.file(UCIHARMirrorURL, destPath, quiet=TRUE)
        fetchDateConn <- file(fetchDateFile, open="w+")
        writeLines(format(Sys.time(), "%c %z"), con=fetchDateConn)
        close(fetchDateConn)
    } else {
        cat("  * UCI HAR Dataset ZIP file aready exists, using existing copy.\n")
    }
    
    cat("  * Unzipping UCI HAR Dataset ZIP file: ", destPath, "\n", sep="")
    suppressWarnings(unzip(destPath, overwrite=FALSE))
}

assemble.dataset <- function () {
    oldDir <- setwd("UCI HAR Dataset")
    
    cat("Assembling the dataset into a single frame.\n")
    
    cat("  * Reading activity labels.\n")
    activity_labels <- read.table("activity_labels.txt", col.names=c("id", "label"), stringsAsFactors=FALSE)
    
    cat("  * Reading feature labels.\n")
    feature_labels <- read.table("features.txt", col.names=c("id", "label"), stringsAsFactors=FALSE)
    wanted_features <- grep("-(mean|std)\\(\\)", feature_labels$label)
    
    #nicer_feature_labels <- gsub("Body", "Body.", feature_labels$label, fixed=TRUE)
    #nicer_feature_labels <- gsub("Gravity", "Gravity.", nicer_feature_labels, fixed=TRUE)
    #nicer_feature_labels <- gsub("Acc", "Accelerometer.", nicer_feature_labels, fixed=TRUE)
    #nicer_feature_labels <- gsub("Gyro", "Gyroscope.", nicer_feature_labels, fixed=TRUE)
    #nicer_feature_labels <- gsub("Mag", "Magnitude.", nicer_feature_labels, fixed=TRUE)
    #nicer_feature_labels <- gsub("Jerk", "Jerk.", nicer_feature_labels, fixed=TRUE)
    #nicer_feature_labels <- gsub("-(mean|std)", "\\1", nicer_feature_labels)
    #nicer_feature_labels <- gsub("()", "", nicer_feature_labels, fixed=TRUE)

    cat("  * Reading the training set files:\n")    
    
    cat("    * subjects\n")
    train_subject <- read.table(file.path("train", "subject_train.txt"), col.names="subject")
    
    cat("    * activities\n")
    train_activity_ids <- read.table(file.path("train", "y_train.txt"), col.names="id")
    train_activity_labels <- activity_labels[train_activity_ids$id, 'label']

    cat("    * set data\n")
    train_set <- read.table(file.path("train", "X_train.txt"), colClasses="numeric", comment.char="")
    #colnames(train_set) <- make.names(feature_labels$label, unique=FALSE)
    colnames(train_set) <- feature_labels$label
    
    cat("  * Assembling the training set frame.\n")
    train <- cbind(train_subject, train_activity_labels, train_set[,wanted_features])
    colnames(train)[2] <- "activity"
    
    cat("  * Reading the test set files:\n")
    
    cat("    * subjects\n")
    test_subject <- read.table(file.path("test", "subject_test.txt"), col.names="subject")

    cat("    * activities\n")
    test_activity_ids <- read.table(file.path("test", "y_test.txt"), col.names="id")
    test_activity_labels <- activity_labels[test_activity_ids$id, 'label']
    
    cat("    * set data\n")
    test_set <- read.table(file.path("test", "X_test.txt"), colClasses="numeric", comment.char="")
    #colnames(test_set) <- make.names(feature_labels$label, unique=TRUE)
    colnames(test_set) <- feature_labels$label
    
    cat("  * Assembling the test set frame.\n")
    test <- cbind(test_subject, test_activity_labels, test_set[,wanted_features])
    colnames(test)[2] <- "activity"
    
    cat("  * Merging the test and training datasets\n")
    merged <- rbind(train, test)
    
    cat("  * Ordering the merged dataset by subject, activity\n")
    assembled <- arrange(merged, subject, activity)
    
    setwd(oldDir)
    
    return(assembled)
}

create.averaged.dataset <- function(dataset) {
    cat("  * Creating averaged dataset over (subject, activity).\n")
    
    dataset %>%
        group_by(subject, activity) %>%
        summarize_each(funs(mean)) %>%
        gather(reading, mean, -subject, -activity)
}

run_analysis <- function () {
    fetch.dataset()
    UCI.HAR.tidy <<- assemble.dataset()
    UCI.HAR.averaged <<- create.averaged.dataset(UCI.HAR.tidy)
}

run_analysis()
rm(fetch.dataset, assemble.dataset, create.averaged.dataset, run_analysis)

