library(readr)
library(tidyverse)
library(caret)
library(ggplot2)

dat <- read_csv("ML/dat.csv")
dat$Type <- as.factor(dat$Type)
test_index <- createDataPartition(dat$Type, times=1, p=0.5, list = FALSE)
test_set <- dat[test_index, ]
train_set <- dat[-test_index, ]
#draw plot
test_set %>%
  ggplot(aes(Real, image, color = Type)) + geom_point() +
  ggtitle("Battery Impedance Test Plot") + ylab("Image Part") + xlab("Real Part")

#using the train function and get the best k
train_knn <- train(Type ~ ., method = "knn", data = train_set)
y_hat_knn <- predict(train_knn, test_set, type = "raw")
confusionMatrix(y_hat_knn, test_set$Type)
confusionMatrix(y_hat_knn, train_set$Type) # to see if overfits

#glm
logistic <-  train(Type ~ ., method = "glm", data = train_set)
log_y_hat <- predict(logistic, test_set)
confusionMatrix(log_y_hat, test_set$Type)
confusionMatrix(log_y_hat, train_set$Type)

#random forest
library(randomForest)
train_rf <- randomForest(Type ~ ., data=train_set)
y_hat_rf <- predict(train_rf, test_set)
confusionMatrix(y_hat_rf, test_set$Type)
confusionMatrix(y_hat_rf, train_set$Type)

#test
test <- read_csv("test.csv")
test$Type <- as.factor(test$Type)
confusionMatrix(predict(train_rf, test), test$Type)
predict(train_rf, test)
predict(logistic, test)
predict(train_knn, test)
