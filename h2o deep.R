rm(list=ls(all=TRUE))

library(h2o)
library(readr)
library(dplyr)
library(tidyr)
library(ggplot2)

options(mc.cores = parallel::detectCores(),
        stringsAsFactors = FALSE,
        scipen = 10) 

localH2O <- h2o.init(ip = 'localhost', nthreads=10, max_mem_size = '64g')
#h2o.clusterInfo()

#train <- h2o.importFile("train_new.csv.gz")
#test <- h2o.importFile("test_new.csv.gz")
#summary(train)

train <- read_csv("train_new.csv.gz")
test <- read_csv("test_new.csv.gz")

set.seed(2016)

######
#Deep
######

data.train <- train %>%
  filter(validation==0) %>%
  select(-ID, -validation) %>%
  #select(-ID, -validation, target, contains("C_"), -contains("prod"), -contains("sq")) %>%
  mutate(target=as.factor(target)) %>%
  as.h2o
data.validate <- train %>%
  filter(validation==1) %>%
  select(-ID, -validation) %>%
  #select(-ID, -validation, target, contains("C_"), -contains("prod"), -contains("sq")) %>%
  mutate(target=as.factor(target)) %>%
  as.h2o

x <- setdiff(names(data.train), 'target')
y <- 'target'

model <- h2o.deeplearning(
  x = x, 
  y = y, 
  training_frame = data.train,
  validation_frame = data.validate,   
  distribution = "bernoulli",
  activation = "RectifierWithDropout", 
  hidden = c(32,32,32),
  input_dropout_ratio = 0.2, 
  sparse = TRUE,
  l1 = 1e-5, 
  variable_importances = TRUE,
  epochs = 10)

# View specified parameters of the deep learning model
model@parameters
# display all performance metrics
model

h2o.performance(model, train = TRUE)
h2o.performance(model, valid = TRUE)

# Retrieve the variable importance
h2o.varimp(model)
h2o.auc(model, valid = TRUE)

# Classify the test set (predict class labels)
# This also returns the probability for each class
pred <- h2o.predict(model, newdata = data.validate)

# Take a look at the predictions
head(pred)

model <- h2o.deeplearning(
  x = x, 
  y = y, 
  training_frame = data.train,
  validation_frame = data.validate,
 	activation="RectifierWithDropout", 
 	hidden=c(1024,1024,2048), 
  epochs=1000, 
 	input_dropout_ratio=0.1,     ##Specifies the fraction of the features for each training row to omit from training to improve generalization. 
                               ##The defaultis 0, which always uses all features
  #hidden_dropout_ratios=c(.01, .05, .1),   ##amount of hidden dropout per hidden layer; .5 default
  hidden_dropout_ratios=c(.25, .05, .1),   ##amount of hidden dropout per hidden layer; .5 default
  nesterov_accelerated_gradient=TRUE,
  #l1=1e-5,                     ##The default is 0, for no L1 regularization
  #max_w2=10,                   ## Specifies the maximum for the sum of the squared incoming weights for a neuron. This tuning parameter is especially useful for
                               ##unbound activation functions such as Maxout or Rectifier. The default, which is positive infinity, leaves this maximum unbounded
 	score_validation_samples=0,
  train_samples_per_iteration=-1, 
 	classification_stop=-1,      ##When the error is at or below this threshold, training stops
                               ## The default is 0. To disable, specify -1.
  #stopping_rounds=0,
  stopping_rounds=5, 
  stopping_metric="AUC",
  stopping_tolerance=0.001
  )

##AUC 0.5251899
h2o.auc(model, valid = TRUE)

model <- h2o.deeplearning(
  x = x, 
  y = y, 
  training_frame = data.train,
  validation_frame = data.validate,
 	activation="RectifierWithDropout", 
 	hidden=c(1000,1000,2000), 
  epochs=100, 
 	input_dropout_ratio=0.1,     ##Specifies the fraction of the features for each training row to omit from training to improve generalization. 
                               ##The defaultis 0, which always uses all features
  hidden_dropout_ratios=c(.2, .5, .5),   ##amount of hidden dropout per hidden layer; .5 default
  nesterov_accelerated_gradient=TRUE,
  l1=1e-5,                     ##The default is 0, for no L1 regularization
 	score_validation_samples=0,
  train_samples_per_iteration=-1, 
 	classification_stop=-1,
  stopping_rounds=5, 
  stopping_metric="AUC",
  stopping_tolerance=0.001
  )

##AUC 0.5372571
h2o.auc(model, valid = TRUE)

model <- h2o.deeplearning(
  x = x, 
  y = y, 
  training_frame = data.train,
  validation_frame = data.validate,
 	activation="RectifierWithDropout", 
 	hidden=c(200,200,2000), 
  epochs=.1, 
 	input_dropout_ratio=0.1,     ##Specifies the fraction of the features for each training row to omit from training to improve generalization. 
                               ##The defaultis 0, which always uses all features
  hidden_dropout_ratios=c(.2, .5, .5),   ##amount of hidden dropout per hidden layer; .5 default
  nesterov_accelerated_gradient=TRUE,
  l1=1e-5,                     ##The default is 0, for no L1 regularization
 	score_validation_samples=0,
  train_samples_per_iteration=-1, 
 	classification_stop=-1,
  stopping_rounds=5, 
  stopping_metric="AUC",
  stopping_tolerance=0.001
  )

##AUC 0.4896065
h2o.auc(model, valid = TRUE)

model <- h2o.deeplearning(
  x = x, 
  y = y, 
  training_frame = data.train,
  validation_frame = data.validate,
 	activation="RectifierWithDropout", 
 	hidden=c(200,200,2000), 
  epochs=.1, 
 	input_dropout_ratio=0.1,     ##Specifies the fraction of the features for each training row to omit from training to improve generalization. 
                               ##The defaultis 0, which always uses all features
  hidden_dropout_ratios=c(.2, .5, .5),   ##amount of hidden dropout per hidden layer; .5 default
  nesterov_accelerated_gradient=TRUE,
  l1=1e-5,                     ##The default is 0, for no L1 regularization
 	score_validation_samples=0,
  train_samples_per_iteration=-1, 
  stopping_rounds=5, 
  stopping_metric="AUC",
  stopping_tolerance=0.001
  )

##AUC 0.5132323
h2o.auc(model, valid = TRUE)

model <- h2o.deeplearning(
  x = x, 
  y = y, 
  training_frame = data.train,
  validation_frame = data.validate,
 	activation="RectifierWithDropout", 
 	hidden=c(200,200,2000), 
  epochs=.1, 
 	input_dropout_ratio=0.1,     ##Specifies the fraction of the features for each training row to omit from training to improve generalization. 
                               ##The defaultis 0, which always uses all features
  hidden_dropout_ratios=c(.2, .5, .5),   ##amount of hidden dropout per hidden layer; .5 default
  nesterov_accelerated_gradient=TRUE,
  l1=1e-5,                     ##The default is 0, for no L1 regularization
 	score_validation_samples=0,
  stopping_rounds=5, 
  stopping_metric="AUC",
  stopping_tolerance=0.001
  )

##AUC 0.5241154
h2o.auc(model, valid = TRUE)

model <- h2o.deeplearning(
  x = x, 
  y = y, 
  training_frame = data.train,
  validation_frame = data.validate,
 	activation="RectifierWithDropout", 
 	hidden=c(1000,1000,2000), 
  epochs=100, 
 	input_dropout_ratio=0.1,     ##Specifies the fraction of the features for each training row to omit from training to improve generalization. 
                               ##The defaultis 0, which always uses all features
  hidden_dropout_ratios=c(.2, .5, .5),   ##amount of hidden dropout per hidden layer; .5 default
  nesterov_accelerated_gradient=TRUE,
  l1=1e-5,                     ##The default is 0, for no L1 regularization
 	score_validation_samples=0,
  stopping_rounds=5, 
  stopping_metric="AUC",
  stopping_tolerance=0.001
  )

##AUC 0.5350169
h2o.auc(model, valid = TRUE)

model <- h2o.deeplearning(
  x = x, 
  y = y, 
  training_frame = data.train,
  validation_frame = data.validate,
 	activation="RectifierWithDropout", 
 	hidden=c(200,200,2000), 
  epochs=100, 
 	input_dropout_ratio=0.1,     ##Specifies the fraction of the features for each training row to omit from training to improve generalization. 
                               ##The defaultis 0, which always uses all features
  hidden_dropout_ratios=c(.2, .5, .5),   ##amount of hidden dropout per hidden layer; .5 default
  nesterov_accelerated_gradient=TRUE,
  l1=1e-5,                     ##The default is 0, for no L1 regularization
 	score_validation_samples=0,
  stopping_rounds=5, 
  stopping_metric="AUC",
  stopping_tolerance=0.001
  )

##AUC 0.5360882
h2o.auc(model, valid = TRUE)

pred <- h2o.predict(model, newdata = data.validate)
ggplot(as.data.frame(pred)) + geom_histogram(aes(p1), binwidth = .001)
summary(as.data.frame(pred)$p1)

##GRID
hidden_opt <- list(c(300,300,2000), c(300,200,2000), c(300,2000,200))
#hidden_opt <- list(c(3000,3000,3000), c(3000,2000,2000), c(3000,2000,1000))
act_opt <- c("TanhWithDropout","MaxoutWithDropout","RectifierWithDropout")
input_dropout_opt=c(0.1,0.2)
l1_opt <- c(1e-4, 1e-5)

hyper_params_1 <- list(hidden = hidden_opt, l1 = l1_opt)

model_grid_1 <- h2o.grid(
  algorithm = "deeplearning",
  grid_id = 'grid_1',
  hyper_params = hyper_params_1,
  activation="RectifierWithDropout",
  x = x,
  y = y,
  distribution = "bernoulli", 
  training_frame = data.train,
  validation_frame = data.validate, 
  score_validation_samples = 0,
  epochs = 200,
  #stopping_tolerance=1e-2,        ## stop when logloss does not improve by >=1% for 3 scoring events
  stopping_tolerance=1e-3,
  #stopping_tolerance=1e-4,
  stopping_rounds = 3,
  stopping_metric = 'AUC')

# print out all prediction errors and run times of the models
model_grid_1

# print out the Test MSE for all of the models
for (model_id in model_grid_1@model_ids) {
  auc <- h2o.auc(h2o.getModel(model_id), valid = TRUE)
  print(sprintf("Test set AUC: %f", auc))
}

#hidden_opt <- list(c(300,300,3000), c(300,200,2000), c(300,2000,1000))
hidden_opt <- list(c(300,300,3000), c(200,200,2000), c(500,500,500), c(500,500,1000))
hyper_params_2 <- list(hidden = hidden_opt, l1 = l1_opt,
                       activation=act_opt)

model_grid_2 <- h2o.grid(
  algorithm = "deeplearning",
  grid_id = 'grid_2',
  hyper_params = hyper_params_2, 
  x = x,
  y = y,
  distribution = "bernoulli", 
  training_frame = data.train,
  validation_frame = data.validate, 
  score_interval = 2,
  epochs = 100,
  #stopping_tolerance=1e-2,        ## stop when logloss does not improve by >=1% for 3 scoring events
  #stopping_tolerance=1e-3,
  stopping_tolerance=1e-4,
  stopping_rounds = 3,
  stopping_metric = 'AUC')

# print out all prediction errors and run times of the models
model_grid_2

# print out the Test MSE for all of the models
for (model_id in model_grid_2@model_ids) {
  auc <- h2o.auc(h2o.getModel(model_id), valid = TRUE)
  print(sprintf("Test set AUC: %f ID:%s", auc, model_id))
}


act_opt <- c("Tanh","Maxout","Rectifier","TanhWithDropout","MaxoutWithDropout","RectifierWithDropout")
hyper_params_3 <- list(activation=act_opt)

model_grid_3 <- h2o.grid(
  algorithm = "deeplearning",
  grid_id = 'grid_3',
  hyper_params = hyper_params_3, 
  x = x,
  y = y,
  distribution = "bernoulli", 
  training_frame = data.train,
  validation_frame = data.validate, 
  score_interval = 2,
  epochs = 500,
  hidden = c(100,500,1000),
  input_dropout_ratio=0.1,
  #stopping_tolerance=1e-2,        ## stop when logloss does not improve by >=1% for 3 scoring events
  #stopping_tolerance=1e-3,
  stopping_tolerance=1e-4,
  stopping_rounds = 3,
  stopping_metric = 'AUC')

# print out all prediction errors and run times of the models
model_grid_3

# print out the Test MSE for all of the models
for (model_id in model_grid_3@model_ids) {
  auc <- h2o.auc(h2o.getModel(model_id), valid = TRUE)
  print(sprintf("Test set AUC: %f ID:%s", auc, model_id))
}


save(model_grid_1, model_grid_2, model_grid_3, 
     file='deep.1.RData')

m <- h2o.getModel(model_grid_1@model_ids[[1]])
pred <- h2o.predict(m, newdata = data.validate)
ggplot(as.data.frame(pred)) + geom_histogram(aes(p1), binwidth = .001)
summary(as.data.frame(pred)$p1)
h2o.auc(m, valid = TRUE)

h2o.shutdown(prompt = FALSE)

