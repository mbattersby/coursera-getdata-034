#
# Fetch down the project data and unpack it
#

fetch.dataset <- function() {
    
    dataSource <- 'https://d396qusza40orc.cloudfront.net/getdata/projectfiles/UCI%20HAR%20Dataset.zip'
    destDir <- "projectfiles"
    destFile <- basename(URLdecode(dataSource))
    destPath <- file.path(destDir, destFile)
    fetchRecordPath <- file.path(destDir, "fetchDate.txt")
    
    if (!file.exists(destDir)) {
        dir.create(destDir)
    }
    
    if (!file.exists(destPath)) {
        print("Downloading dataset ZIP file.")
        download.file(dataSource, destPath, quiet=TRUE)
        fetchDateConn <- file(fetchRecordPath, open="w+")
        writeLines(format(Sys.time(), "%c %z"), con=fetchDateConn)
        close(fetchDateConn)
    } else {
        print("Found existing dataset ZIP file, not re-downloading.")
    }
    
    print("Unzipping dataset ZIP file.")
    unzip(destPath)
}
