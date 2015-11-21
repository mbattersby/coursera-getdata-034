#
# Tidy the UCI HAR Dataset
#

library(dplyr, warn.conflicts=FALSE)

fetch.dataset <- function (downloadDir="data") {
    
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

    cat("  * Reading the training set files:\n")    
    
    cat("    * subjects\n")
    train_subject <- read.table(file.path("train", "subject_train.txt"), col.names="subject")
    
    cat("    * activities\n")
    train_activity_ids <- read.table(file.path("train", "y_train.txt"), col.names="id")
    train_activity_labels <- activity_labels[train_activity_ids$id, 'label']
    
    cat("    * set data\n")
    train_set <- read.table(file.path("train", "X_train.txt"), colClasses="numeric", comment.char="")
    
    cat("  * Assembling the training set frame.\n")
    train <- cbind(train_subject, train_activity_labels, train_set)
    colnames(train) <- c('subject', 'activity', make.names(feature_labels$label, unique=TRUE))
    
    cat("  * Reading the test set files:\n")
    
    cat("    * subjects\n")
    test_subject <- read.table(file.path("test", "subject_test.txt"), col.names="subject")

    cat("    * activities\n")
    test_activity_ids <- read.table(file.path("test", "y_test.txt"), col.names="id")
    test_activity_labels <- activity_labels[test_activity_ids$id, 'label']
    
    cat("    * set data\n")
    test_set <- read.table(file.path("test", "X_test.txt"), colClasses="numeric", comment.char="")
    
    cat("  * Assembling the test set frame.\n")
    test <- cbind(test_subject, test_activity_labels, test_set)
    colnames(test) <- c('subject', 'activity', make.names(feature_labels$label, unique=TRUE))

    cat("  * Merging the test and training datasets\n")
    merged <- rbind(train, test)
    
    cat("  * Ordering the merged dataset by subject, activity\n")
    assembled <- arrange(merged, subject, activity)
    
    setwd(oldDir)
    
    return(merged)
}

tidy.dataset <- function (dataset) {
    cat("Creating tidy dataset.\n")
    select(dataset, subject, activity)
}

run_analysis <- function () {
    fetch.dataset()
    assembledDataset <- assemble.dataset()
    tidyDataset <- tidy.dataset(assembledDataset)
    return(tidyDataset)
}
