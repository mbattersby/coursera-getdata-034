library(readr)

q1 <- function () {
    sourceURL <- URLdecode('https://d396qusza40orc.cloudfront.net/getdata%2Fdata%2Fss06hid.csv')

    d <- read_csv(sourceURL)
    n <- strsplit(names(d), "wgtp")
    print(n[123])
}

q2 <- function () {
    sourceURL <- URLdecode('https://d396qusza40orc.cloudfront.net/getdata%2Fdata%2FGDP.csv')
    d <- read_csv(sourceURL)
    d <- d[5:194, c(1,3,4,5)]
    colnames(d) <- c('countrycode', 'ranking', 'countryname', 'gdp')
    gdpNumeric <- as.numeric(gsub(',', '', d$gdp))
    print(mean(gdpNumeric))
}

q3 <- function () {
    sourceURL <- URLdecode('https://d396qusza40orc.cloudfront.net/getdata%2Fdata%2FGDP.csv')
    d <- read_csv(sourceURL)
    d <- d[5:194, c(1,3,4,5)]
    colnames(d) <- c('countrycode', 'ranking', 'countryname', 'gdp')
    length(grep("^United", d$countryname, value=TRUE))
}

q4 <- function () {
    gdpURL <-URLdecode('https://d396qusza40orc.cloudfront.net/getdata%2Fdata%2FGDP.csv')
    g <- read_csv(gdpURL)
    g <- g[5:194, c(1,3,4,5)]
    colnames(g) <- c('countrycode', 'ranking', 'countryname', 'gdp')
    
    eduURL <- URLdecode('https://d396qusza40orc.cloudfront.net/getdata%2Fdata%2FEDSTATS_Country.csv')
    e <- read_csv(eduURL)
    m <- merge(g, e, by.x='countrycode', by.y='CountryCode')
    mYE <- m[grep('^Fiscal year end: June', m[['Special Notes']]),]
    print(nrow(mYE))
}

q5 <- function () {
    library(quantmod)
    amzn <- getSymbols("AMZN",auto.assign=FALSE)
    sampleTimes <- index(amzn)
    samples2012 <- grep('^2012-', sampleTimes, value=TRUE)
    print(length(samples2012))
    print(sum(weekdays(as.Date(samples2012)) == 'Monday'))
}
