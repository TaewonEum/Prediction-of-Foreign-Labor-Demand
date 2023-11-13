# XGBoost

# Setting Analysis Environment
rm(list = ls()) # Reset Directory
getwd() # Check Current Directory
setwd("3. Build Dataset")
options(scipen = 999, digits = 15) # Specifies Display of the number format

# Load Packages
library(openxlsx)
library(dplyr)
library(data.table)
library(stringr)
library(tidyr)
library(xgboost)
library(caret)

# Load Dataset
### Final Dataset for Analysis
file_list <- list.files()
data <-  read.csv(file_list[2], fileEncoding = "EUC-KR") %>% 
  select(-c(비고, 배정신청.인원, 지자체추가배정인원)) %>% 
  filter(합계 != 0)

set.seed(1234)
# sample_index <- sample(1:nrow(data), 0.7*nrow(data)) # Random-Sampling
sample_index <- createDataPartition(c(data$작물.종류), p = 0.7, list = F) # Stratified-Sampling
actual_test_data <- data[-sample_index, ]

data <- data.table(data)
data$구분 <- factor(data$구분)
data[,농업경영체:=NULL]

# Encoding Categorical Column
data <- data %>% 
  # Label-Encoding for Area Columns
  mutate(지자체명_시도 = as.numeric(as.factor(지자체명_시도)),
         지자체명_시군구 = as.numeric(as.factor(지자체명_시군구)),
         전년도활용여부 = as.numeric(as.factor(전년도활용여부)),
         작물.종류 = as.numeric(as.factor(작물.종류))) %>% 
  
  # # Dummy-Transform for '구분' Column
  transform(구분_소농 = ifelse(구분 == "소농", 1, 0), 
            구분_중농 = ifelse(구분 == "중농", 1, 0), 
            구분_대농 = ifelse(구분 == "대농", 1, 0), 
            구분_법인 = ifelse(구분 == "법인", 1, 0)
  ) %>% 
  select(-구분)

data <- data %>% 
  mutate(across(c(농지면적.ha단위., 전년대비농경체증감률, 고령농경체비율, 전년도이탈인원), scale))

# Machine Learning
### Train-Test Split
set.seed(1234)
# sample_index <- sample(1:nrow(data), 0.7*nrow(data))
train_data <- data[sample_index, ]
test_data <- data[-sample_index, ]

### Basic Model Using XGBoost
xgb_model <- xgboost(data = as.matrix(train_data[, -9]), 
                     label = train_data$합계, 
                     nrounds = 100, 
                     objective = "reg:squarederror")

### Predict for Test-Data Set
predictions <- round(predict(xgb_model, as.matrix(test_data[, -9])),0)

### Calculate For Accuracy
rmspe <- function(actual, predicted) {
  rmspe <- sqrt(mean(((actual - predicted) / (actual)) ^ 2)) * 100
  return(rmspe)
}

rmspe_value <- rmspe(test_data$합계, predictions)
print(paste("RMSPE: ", rmspe_value, "%"))

### Test for Basic Unit Of Local Government
actual_test_data$pred <- predictions
result <- 
  actual_test_data %>% 
  group_by(지자체명_시도, 지자체명_시군구) %>% 
  summarise(actual = sum(합계),
            preds = sum(pred))

result_2 <- 
  result %>% 
  filter(actual > 10)

rmspe(result$actual, result$preds)
rmspe(result_2$actual, result_2$preds)
##############################################################################################################################
# Model Develop
### Hyper-Parameter Tuning
### Define Grid
##### Grid-Search to xgbTree
# param_grid <- expand.grid(
#   nrounds = c(50, 100, 150),
#   max_depth = c(3, 6, 9),
#   eta = c(0.01, 0.1, 0.3),
#   gamma = c(0, 1, 5),
#   colsample_bytree = c(0.5, 0.7, 1),
#   min_child_weight = c(1, 5, 10),
#   subsample = c(0.5, 0.7, 1)
# )

##### Random-Search to xgbTree
# param_grid <- expand.grid(
#   nrounds = sample(50:150, 1),
#   max_depth = sample(3:9, 1),
#   eta = runif(1, 0.01, 0.3),
#   gamma = sample(c(0, 1, 5), 1),
#   colsample_bytree = runif(1, 0.5, 1),
#   min_child_weight = sample(c(1, 5, 10), 1),
#   subsample = runif(1, 0.5, 1)
# )

##### Random-Search to xgbLinear
set.seed(1234)
param_grid <- expand.grid(
  nrounds = sample(100:300, 3),
  lambda = runif(3, 0, 10),
  alpha = runif(3, 0, 1),
  eta = runif(3, 0.01, 1)
)

### Setting Tuning Control
ctrl <- trainControl(method = "cv", number = 5)

start_time <- Sys.time()

### Train XGBoost model for tuning
set.seed(1234)
xgb_tune <- train(
  x = as.matrix(train_data[, -9]),
  y = train_data$합계,
  trControl = ctrl,
  tuneGrid = param_grid,
  method = "xgbLinear",  # XGBoost 사용
  # method = "xgbTree",  # XGBoost 사용
  metric = "RMSE",      # RMSE를 최소화하는 모델 찾기
  verbose = F
)

end_time <- Sys.time()
### Optimal Model
print(xgb_tune$bestTune)

### Predict for Test-Data Set
tuned_predictions <- round(predict(xgb_tune, as.matrix(test_data[, -9])),0)

### Calculate For Accuracy
rmspe <- function(actual, predicted) {
  rmspe <- sqrt(mean(((actual - predicted) / (actual)) ^ 2)) * 100
  return(rmspe)
}

tuned_rmspe_value <- rmspe(test_data$합계, tuned_predictions)
print(paste("RMSPE: ", tuned_rmspe_value, "%"))

actual_test_data$pred <- tuned_predictions

result <- data.frame(actual_test_data) %>% 
  group_by(지자체명_시도, 지자체명_시군구) %>% 
  summarise(actual = sum(합계),
            preds = sum(pred))

result_2 <- 
  result %>% 
  filter(actual > 10)

rmspe(result$actual, result$preds)
rmspe(result_2$actual, result_2$preds)

time_taken <- end_time - start_time
print(paste("Start Time:", start_time))
print(paste("End Time:", end_time))
print(paste("Time Taken:", time_taken))
# saveRDS(xgb_tune, "XGBoost_Tuning_Model.rds")
