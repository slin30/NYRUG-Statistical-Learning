# Required packages
library(randomForest)
library(caret)

# Read in train dataset
digits <- read.csv('train.csv') # we know the default parameters are OK, but generally you want to validate

# Make a copy of digits without the label column
target.name <- 'label'
digits.1    <- digits[, -which(names(digits) %in% target.name), drop = FALSE]

# Remove near zero var features
lowVar    <- nearZeroVar(digits.1)
digits.1v <- digits.1[, -lowVar]

# Preprocess
ppCS       <- preProcess(digits.1v, method = c("center", "scale"))
digits.1vp <- predict(ppCS, newdata = digits.1v)

# Add label column back to preprocessed train data
digits.1vp$label <- as.factor(digits$label)

# Partition processed train data into two pieces for initial model evaluation
set.seed(1234)  # for reproducibility
trainPart <- createDataPartition(digits.1vp$label, p = 0.7, list = FALSE)  # Stratified sampling
train     <- digits.1vp[trainPart, ]
test      <- digits.1vp[-trainPart, ]

# Run an initial RF with train portion
set.seed(1001)
rfModel.1 <- randomForest(label ~ .,
                          data = train,
                          ntree = 100,
                          do.trace = TRUE,
                          importance = TRUE)

# Evaluate variable importance
varImpPlot(rfModel.1, sort = TRUE)

# Use the initial RF on test slice
rfPred.1 <- predict(rfModel.1, newdata = test)
confusionMatrix(rfPred.1, test$label)  # View a detailed confusion matrix
rfTable.1 <- table(test$label, rfPred.1)
sum(diag(rfTable.1))/nrow(test)  # an alternate way to view the overall Accuracy

# Run a second RF with all of the train data
set.seed(1001)
rfModel.2 <- randomForest(label ~ .,
                          data = digits.1vp,
                          ntree = 100, 
                          do.trace = TRUE,
                          importance = TRUE)

# Evaluate variable importance
varImpPlot(rfModel.2, sort = TRUE)
# view the model confusion matrix; there is no untouched labeled data to predict
rfModel.2$confusion

# Read in the real test data
realTest <- read.csv('test.csv')

# Preprocess the real test data using the same preprocessing criteria as test set
realTest.v  <- realTest[, -lowVar]
realTest.vp <- predict(ppCS, newdata = realTest.v)

# Use the RF trained with full dataset for test prediction
rfPred.test <- predict(rfModel.2, newdata = realTest.vp)

# Prepare data for output and write out
out        <- levels(rfPred.test)[rfPred.test]
out.labels <- c(1:length(out))
out.final  <- cbind(ImageID = out.labels, Label = out)

write.csv(out.final, './prediction03.csv', row.names = FALSE)

# Run a third RF with all of the train data, this time with 500 trees
set.seed(1001)
rfModel.3 <- randomForest(label ~ .,
                          data = digits.1vp,
                          ntree = 500,
                          do.trace = TRUE,
                          importance = TRUE)

# compare class errors
# write a function that extracts the confusion matrices from models and binds them



rfPred.test.1 <- predict(rfModel.3, newdata = realTest.vp)
out.1         <- levels(rfPred.test.1)[rfPred.test.1]
out.1.final   <- cbind(ImageID = out.labels, Label = out.1)

write.csv(out.1.final, './prediction04.csv', row.names = FALSE)

# 0.96471 score; rank 400, up 35 positions, 0.00243 improvement absolute; clearly there is some benefit to increasing
#  the total number of trees by 5x, although runtimes are appreciable
# 0.93514 is the score for the public RF benchmark for this competition

