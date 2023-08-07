#### Machine Learning Test ####

library("dplyr")
library("caret")
library("caretEnsemble")

gardasil_read = read.csv("gardasil.csv")

gardasil_loaded = gardasil_read%>%
  select(-Shots) %>%
  mutate_at(vars(-Age), as.factor)

dmy <- dummyVars("~ .", data = gardasil_loaded, fullRank = T)
gardasil <- data.frame(predict(dmy, newdata = gardasil_loaded))
gardasil = gardasil %>%
  mutate(Completed = Completed.1)%>%
  select(-Completed.1)%>%
  mutate_at(vars(-Age), as.factor)
skimr::skim(gardasil)

#### Splitting Dataset ####
set.seed(101) 

intrain = createDataPartition(y=gardasil$Completed, p=0.75, list=FALSE)
traindf = gardasil[intrain,]; traindf$Completed = as.factor(traindf$Completed)
testdf = gardasil[-intrain,]; testdf$Completed = as.factor(testdf$Completed)

#### Building and Applying Models ####

# Naive Bayes
nb_model <- train(Completed ~ ., data = traindf, 
                  method = 'naive_bayes', 
                  na.action = na.pass,  
                  trControl = trainControl(method = "cv", number = 5),
                  preProcess = "pca")

# Logistic Regression
lr_model <- train(Completed ~ ., data = traindf, method = 'glm', family = 'binomial', 
                  na.action = na.pass,  
                  trControl = trainControl(method = "cv", number = 5),
                  preProcess = "pca")

# Bayesian GLM
bayenesian_model <- train(Completed ~ ., data = traindf, method = 'bayesglm', 
                          na.action = na.pass,  
                          trControl = trainControl(method = "cv", number = 5),
                          preProcess = "pca")

# Boosted Logistc Regression
boosted_lr_model <- train(Completed ~ ., data = traindf, method = 'LogitBoost',
                          na.action = na.pass,  
                          trControl = trainControl(method = "cv", number = 5),
                          preProcess = "pca")

# Random Forest
library(randomForest) # to build a random forest model
rf_model = train(Completed ~ ., data = traindf, method = 'rf', 
                 ntree = 15, maxdepth = 3,  
                 na.action = na.pass,  
                 trControl = trainControl(method = "cv", number = 5),
                 preProcess = "pca")
detach('package:randomForest', unload=TRUE) #conflicts with margin in ggplot

# Extreme Gradient Boost

xgb_model <-train(Completed ~., data = traindf, 
                  method = 'xgbTree',  
                  trControl = trainControl(method = "repeatedcv", number = 5), 
                  verbose = T, 
                  nthread = 2, 
                  na.action = na.pass,
                  preProcess = "pca")


##### Tabulating Accuracy ####
Truth = ifelse(testdf$Completed == 0, "Not Complete", "Complete")

# Naive Bayes 
nb_predictions_test = predict(nb_model, newdata = testdf, type = 'raw')
nb_predictions_test = ifelse(nb_predictions_test == 0, "Not Complete", "Complete")
confusionNaiveBayes = caret::confusionMatrix(data= as.factor(nb_predictions_test), reference = as.factor(Truth))

NaiveBayesTable = table(Truth = Truth, Prediction = nb_predictions_test)

# Bayesian GLM
bayenesian_predictions_test = predict(bayenesian_model, newdata = testdf, type = 'raw')
bayenesian_predictions_test = ifelse(bayenesian_predictions_test == 0, "Not Complete", "Complete")
confusionBayes = caret::confusionMatrix(data= as.factor(bayenesian_predictions_test), reference = as.factor(Truth))

BayesianGLMTable = table(Truth = Truth, Prediction = bayenesian_predictions_test)

# Logistic Regression
lr_predictions_test = predict(lr_model, newdata = testdf, type = 'raw')
lr_predictions_test = ifelse(lr_predictions_test == 0, "Not Complete", "Complete")
confusionLR = caret::confusionMatrix(data= as.factor(lr_predictions_test), reference = as.factor(Truth))

lr_predictions_testTable = table(Truth = Truth, Prediction = lr_predictions_test)


# Boosted Logistic Regression
boosted_lr_predictions_test = predict(boosted_lr_model, newdata = testdf, type = 'raw')
boosted_lr_predictions_test = ifelse(boosted_lr_predictions_test == 0, "Not Complete", "Complete")
confusionboostedLogistic = caret::confusionMatrix(data= as.factor(boosted_lr_predictions_test), reference = as.factor(Truth))

boosted_lr_predictions_testTable = table(Truth = Truth, Prediction = boosted_lr_predictions_test)


# Random Forest
rf_predictions_test = predict(rf_model, newdata = testdf, type = 'raw')
rf_predictions_test = ifelse(rf_predictions_test == 0, "Not Complete", "Complete")
confusionRF = caret::confusionMatrix(data= as.factor(rf_predictions_test), reference = as.factor(Truth))

rf_predictions_testTable = table(Truth = Truth, Prediction = rf_predictions_test)

# Extreme Gradient Boost 
xgb_model_predictions_test = predict(xgb_model, newdata = testdf, type = 'raw')
xgb_model_predictions_test = ifelse(xgb_model_predictions_test == 0, "Not Complete", "Complete")
confusionxgb = caret::confusionMatrix(data= as.factor(xgb_model_predictions_test), reference = as.factor(Truth))


xgb_model_predictions_testTable = table(Truth = Truth, Prediction = xgb_model_predictions_test)

#### Comparing Accuracy betweeb models #####

# Accuracy 
confusionNaiveBayes$overall[1]
confusionNaiveBayes$overall[1]
confusionboostedLogistic$overall[1]
confusionLR$overall[1]
confusionRF$overall[1]
confusionxgb$overall[1]


#### Xgb tied with Logistic Regression ####

xgb_model$preProcess

xgb_model$preProcess$rotation


# Confusion Matrix & Var Importance

confusionLR

varImp(lr_model, scale = FALSE)
summary(lr_model$finalModel)

confusionxgb

varImp(xgb_model, scale = FALSE)
summary(xgb_model$finalModel)


### Building a table of accuracies ####


# Models: Naive Bayes, Bayes GLM, Logistic Regression, Boosted Logistic Regression, Random Forest, Extreme Gradient Boost

# True Positive = [1,1]
# False Positive = [2,1]
# True Negative = [2,2]
# False Negative = [1,2]


model_names <- c("Naive Bayes", "Bayes GLM", "Logistic Regression", "Boosted Logistic Regression", "Random Forest", "Extreme Gradient Boost")
True_Positives = c(NaiveBayesTable[1,1], BayesianGLMTable[1,1], lr_predictions_testTable[1,1], 
                   boosted_lr_predictions_testTable[1,1], rf_predictions_testTable[1,1], 
                   xgb_model_predictions_testTable[1,1])
False_Positives = c(NaiveBayesTable[2,1], BayesianGLMTable[2,1], lr_predictions_testTable[2,1], 
                    boosted_lr_predictions_testTable[2,1], rf_predictions_testTable[2,1], 
                    xgb_model_predictions_testTable[2,1])
True_Negatives = c(NaiveBayesTable[2,2], BayesianGLMTable[2,2], lr_predictions_testTable[2,2], 
                   boosted_lr_predictions_testTable[2,2], rf_predictions_testTable[2,2], 
                   xgb_model_predictions_testTable[2,2])
False_Negatives = c(NaiveBayesTable[1,2], BayesianGLMTable[1,2], lr_predictions_testTable[1,2], 
                    boosted_lr_predictions_testTable[1,2], rf_predictions_testTable[1,2], 
                    xgb_model_predictions_testTable[1,2])

model_table <- matrix(c(model_names, True_Positives, False_Positives, True_Negatives, False_Negatives), ncol = 5, byrow = FALSE)

model_df <- data.frame(model_table, stringsAsFactors = FALSE)
names(model_df) <- c("Model", "True Positives", "False Positives", "True Negatives", "False Negatives")

Table_Accuracry = model_df%>%
  mutate_at(vars(-Model), as.numeric) %>%
  mutate(Accurate = `True Positives` + `True Negatives`,
         Inaccurate = `False Positives` + `False Negatives`, 
         Total = `True Positives` + `True Negatives` + `False Positives` + `False Negatives`)

Final_Table = Table_Accuracry %>%
  mutate("Accuracy Percent" = round((Accurate / Total)*100, 2),
         Sensitivity = (`True Positives`) / (`True Positives` + `False Negatives`),
         specificity = (`True Negatives`) / (`True Negatives` + `False Positives`)) %>%
  select(Model, `Accuracy Percent`, Sensitivity, specificity)
View(Final_Table)

#### Variable Importance Across Models ####

# Logistic Regression
summary(lr_model)

varImp(lr_model, scale = FALSE)
varImp(lr_model$finalModel)

caret::confusionMatrix(data= as.factor(lr_predictions_test), reference = as.factor(Truth))


# Extreme Gradient Boosted
summary(xgb_model)
xgbTable = varImp(xgb_model, scale = FALSE)

xgb_model$modelInfo

xgb_model$modelType
xgb_model$metric
final_model = xgb_model$finalModel
final_model$params
final_model$xNames

# Bayesian GLM
summary(bayenesian_model)
varImp(bayenesian_model, scale = FALSE)
varImp(bayenesian_model$finalModel)
