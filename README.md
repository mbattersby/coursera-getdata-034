# Tidying the UCI HAR Dataset

This is an R script to process the UCI HAR Dataset into a [tidy data](http://vita.had.co.nz/papers/tidy-data.pdf) format.

## How to use

The code to download and process the dataset is in the [run_analyis.R](run_analysis.R) file.

To do the processing source the file into your R environment.

```R
source('run_analysis.R')
```

This will export two derived data.frames into your global environment:
* UCI.HAR.tidy
* UCI.HAR.averaged


## Data Source

The UCI HAR Dataset is described in detail [here](http://archive.ics.uci.edu/ml/datasets/Human+Activity+Recognition+Using+Smartphones) and can be fetched from a mirror [here](https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip).


## Code Book

A [codebook](CodeBook.md) describes the UCI.HAR.tidy and UCI.HAR.averaged data frames, their variables, and the data transformations used to derive them.
