#
# Tidy the UCI HAR Dataset for Getting and Cleaning Data
#

library(reshape2)
library(dplyr, warn.conflicts=FALSE)
library(tidyr)

# fread is hugely faster than read.table, but data.table is quite different from data.frame
library(data.table, warn.conflicts=FALSE)
options(datatable.fread.datatable=FALSE)


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
    features <- fread("features.txt")
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

    # Read the activity labels and use them for factor levels.
    
    activity_labels <- fread("activity_labels.txt", col.names=c("id", "label"))
    data$activity <- as.factor(data$activity)
    levels(data$activity) <- activity_labels[,2]
    
    return(data %>% arrange(subject))
}

create.averaged.dataset <- function(dataset, type='dplyr') {
    if (type == 'dplyr') {
        dataset %>%
            group_by(subject, activity) %>%
            summarize_each(funs(mean)) %>%
            gather(reading, mean, -subject, -activity)
    } else if (type == 'reshape2') {
        dataset %>%
            melt(c('subject', 'activity')) %>%
            dcast(subject + activity ~ variable, fun.aggregate=mean, value=) %>%
            melt(c('subject', 'activity'))
    }
}

fetch.dataset()
oldDir <- setwd("UCI HAR Dataset")
tryCatch(
    {
        UCI.HAR.tidy <<- assemble.dataset()
        UCI.HAR.averaged <<- create.averaged.dataset(UCI.HAR.tidy, type='reshape2')
    },
    finally = {
        setwd(oldDir)
    }
)
