# Get train and test datasets from my personal dropbox for convenience. This way,
# you do not need to create a Kaggle account if you do not have one. This also
# tends to be better for reproducibility and portability.

# Create directories and subdirectories for this example
dir.create("./data", showWarnings = TRUE)

# Create an additional folder in 'data' called 'Titanic'
dir.create("./data/Titanic", showWarnings = TRUE)

# URLs for download links
train.url <- "https://www.dropbox.com/s/6rtvlldqvyc9ibk/train.csv?dl=1"
test.url  <- "https://www.dropbox.com/s/kfrlc3pk701tz97/test.csv?dl=1"

# Download the two files
download.file(url = train.url, destfile = "./data/Titanic/train.csv")
download.file(url = test.url, destfile = "./data/Titanic/test.csv")


# Read the files in
data.train <- read.csv("./data/Titanic/train.csv", header = TRUE, sep = ",")  
# data frame; 891 obs, 12 variables
data.test  <- read.csv("./data//Titanic/test.csv", header = TRUE, sep = ",")   
# data frame; 418 obs, 11 variables


