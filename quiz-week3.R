library(dplyr)
library(readr)

q1 <- function () {
    url <- "https://d396qusza40orc.cloudfront.net/getdata%2Fdata%2Fss06hid.csv"
    agriculture <- read_csv(url)
    agricultureLogical <- agriculture$ACR == 3 & agriculture$AGS == 6
    which(agricultureLogical)
}

q2 <- function () {
    library(jpeg)
    url <- "https://d396qusza40orc.cloudfront.net/getdata%2Fjeff.jpg"
    file <- basename(URLdecode(url))
    if (!file.exists(file)) download.file(url, file)
    pic <- readJPEG(file, native=TRUE)
    quantile(pic, probs=c(0.3, 0.8))
}

q3.4.5 <- function () {
    gdpURL <- URLdecode("https://d396qusza40orc.cloudfront.net/getdata%2Fdata%2FGDP.csv")
    gdpFile <- basename(gdpURL)
    eduURL <- URLdecode("https://d396qusza40orc.cloudfront.net/getdata%2Fdata%2FEDSTATS_Country.csv")
    eduFile <- basename(eduURL)
    
    if (!file.exists(gdpFile)) download.file(gdpURL, gdpFile)
    if (!file.exists(eduFile)) download.file(eduURL, eduFile)
    
    gdp <- read_csv(gdpFile, col_names=FALSE, skip=5, n_max=190) %>% select(1,2,4,5)
    names(gdp) <- c("CountryCode", "Ranking", "Country", "MDollars")
                 
    edu <- read_csv(eduFile)
    
    cc <- merge(gdp, edu, by="CountryCode", all=FALSE)
    
    cc <- arrange(cc, desc(Ranking))
    print(nrow(cc))
    print(cc[13,'Country'])
    
    #print(cc %>% group_by(`Income Group`) %>% summarize(mean(Ranking)))
    
    cc <- mutate(cc, 'Ranking Group' = cut(Ranking, breaks=5))
    
    table(cc$`Income Group`, cc$`Ranking Group`) %>% print
    
}