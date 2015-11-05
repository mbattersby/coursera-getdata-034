#
# Fetch down the project data and unpack it
#

fetch.dataset <- function() {
    
    dataSource <- 'https://d396qusza40orc.cloudfront.net/getdata/projectfiles/UCI%20HAR%20Dataset.zip'
    destDir <- "projectfiles"
    destFile <- "UCI HAR Dataset.zip"
    destPath <- file.path(destDir, destFile)
    
    dir.create(destDir, showWarnings=FALSE)
    
    if (!file.exists(destPath)) {
        print("Downloading dataset ZIP file.")
        download.file(dataSource, destPath, quiet=TRUE)
    } else {
        print("Found existing dataset ZIP file, not re-downloading.")
    }
    
    print("Unzipping dataset ZIP file.")
    unzip(destPath)
}
