#
# Tidy the UCI HAR Dataset for Getting and Cleaning Data
#

# fread is hugely faster than read.table
library(data.table, warn.conflicts=FALSE)

library(dplyr, warn.conflicts=FALSE)
library(tidyr)

fetch.dataset <- function () {
    
    downloadDir <- "data"
    UCIHARMirrorURL <- 'https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip'
    
    destPath <- file.path(downloadDir, basename(URLdecode(UCIHARMirrorURL)))
    fetchDateFile <- file.path(downloadDir, "fetchDate.txt")
    
    dir.create(downloadDir, showWarnings=FALSE)

    if (!file.exists(destPath)) {
        download.file(UCIHARMirrorURL, destPath)
        fetchDateConn <- file(fetchDateFile, open="w+")
        writeLines(format(Sys.time(), "%c %z"), con=fetchDateConn)
        close(fetchDateConn)
    }
    
    suppressWarnings(unzip(destPath, overwrite=FALSE))
}

assemble.dataset <- function () {

    # Read the features so we can use the observation names, and pull out the mean/std ones.
    features <- read.table("features.txt", stringsAsFactors=FALSE)
    wanted_features <- grep("-(mean|std)\\(\\)", features[,2])
    wanted_names <- features[wanted_features,2]

    subject_train <- fread(file.path("train", "subject_train.txt"))
    y_train <- fread(file.path("train", "y_train.txt"))
    X_train <- fread(file.path("train", "X_train.txt"), select=wanted_features)

    subject_test <- fread(file.path("test", "subject_test.txt"))
    y_test <- fread(file.path("test", "y_test.txt"))
    X_test <- fread(file.path("test", "X_test.txt"), select=wanted_features)

    data <- rbind(
        cbind(subject_train, y_train, X_train),
        cbind(subject_test, y_test, X_test)
    )
    
    names(data) <- c('subject', 'activity', gsub('()', '', wanted_names, fixed=TRUE))

    # Read the activity labels and replace the ids with the label. It might be better to
    # set activity to be factor and set the levels from the labels.
    
    activity_labels <- read.table("activity_labels.txt", col.names=c("id", "label"), stringsAsFactors=FALSE)
    data$activity <- activity_labels[data$activity, 2]
    
    return(data %>% arrange(subject))
}

create.averaged.dataset <- function(dataset) {
    dataset %>%
        group_by(subject, activity) %>%
        summarize_each(funs(mean)) #%>%
        #gather(reading, mean, -subject, -activity)
}

#fetch.dataset()
oldDir <- setwd("UCI HAR Dataset")
UCI.HAR.tidy <<- assemble.dataset()
UCI.HAR.averaged <<- create.averaged.dataset(UCI.HAR.tidy)
setwd(oldDir)