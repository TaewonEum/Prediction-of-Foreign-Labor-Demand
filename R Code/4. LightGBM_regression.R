# LightGBM

# Setting Analysis Environment
rm(list = ls()) # Reset Directory
getwd() # Check Current Directory
setwd("3. Build Dataset")
options(scipen = 999, digits = 15) # Specifies Display of the number format

# 패키지 로드
library(openxlsx)
library(dplyr)
library(data.table)
library(stringr)
library(tidyr)
library(lightgbm)
library(caret)

# 현재 디렉토리에 존재하는 파일명을 출력합니다.
file_list <- list.files()
print(file_list)

# 데이터 불러오기
### 최종 분석데이터셋
file <- file_list[2]
data <-  read.csv(file, fileEncoding = "EUC-KR") %>% 
  select(-c(비고, 배정신청.인원, 지자체추가배정인원)) %>% 
  filter(합계 != 0)

set.seed(42)
# sample_index <- sample(1:nrow(data), 0.7*nrow(data)) # 무작위 추출
sample_index <- createDataPartition(data$작물.종류, p = 0.7, list = F) # 층화추출
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
  mutate(농지면적.ha단위. = scale(농지면적.ha단위.),
         전년대비농경체증감률 = scale(전년대비농경체증감률),
         고령농경체비율 = scale(고령농경체비율))

# Machine Learning
### Train-Test Split
set.seed(42)
# sample_index <- sample(1:nrow(data), 0.7*nrow(data))
train_data <- data[sample_index, ]
test_data <- data[-sample_index, ]

### Convert to lgb.Dataset
dtrain <- lgb.Dataset(data = as.matrix(train_data[, -9]), label = train_data$합계)
dtest <- lgb.Dataset(data = as.matrix(test_data[, -9]), label = test_data$합계)

### Basic Model Using LightGBM
params <- list(objective = "regression",
               metric = "rmse",
               boost_from_average = FALSE)

num_round <- 100
lgb_model <- lgb.train(params = params,
                       data = dtrain,
                       nrounds = num_round,
                       valids = list(test = dtest),
                       early_stopping_rounds = 10)

### Predict for Test-Data Set
predictions <- round(predict(lgb_model, as.matrix(test_data[, -9])),0)

### Calculate For Accuracy
rmspe <- function(actual, predicted) {
  rmspe <- sqrt(mean(((actual - predicted) / (actual)) ^ 2)) * 100
  return(rmspe)
}

rmspe_value <- rmspe(test_data$합계, predictions)
print(paste("RMSPE: ", rmspe_value, "%"))

### 기초지자체 단위 Test
actual_test_data$pred <- predictions
result <- 
  actual_test_data %>% 
  group_by(지자체명_시도, 지자체명_시군구) %>% 
  summarise(actual = sum(합계),
            preds = sum(pred))
rmspe(result$actual, result$preds)
# saveRDS(lgb_model, "LightGBM_Model.rds")