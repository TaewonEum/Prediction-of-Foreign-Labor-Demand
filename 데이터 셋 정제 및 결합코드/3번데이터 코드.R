rm(list = ls())
# 분석 환경 설정
getwd() # 현재 디렉토리 확인
#setwd("../../02. 데이터/20230831") # 데이터가 존재하는 디렉토리로 변경
options(scipen = 999, digits = 15) # 숫자 표시 형식 지정

# 패키지 로드
library(openxlsx)
library(dplyr)
library(data.table)
library(stringr)

# 현재 디렉토리에 존재하는 파일명을 출력합니다.
file_list <- list.files()
print(file_list)

data <- read.xlsx(file_list[7], sheet=1, startRow=1)
head(data)

# 전체 레코드 수 확인
nrow(data) # 32,192건
unique(data$년도)
length(unique(data$시도))
length(unique(data$시군구))

# 농업 데이터 추출
data <- data %>% filter(업종 == '농업') # 29,262건
nrow(data)


# 계절근로자(MOU, 결혼이민자가족) 추출
data <- data %>% 
  filter(구분 %in% c('MOU', '결혼이민자가족')) # 26,637건
nrow(data)

# 성실재입국자 컬럼 정제
unique(data$성실재입국자)
data <- data %>% mutate(성실재입국자 = ifelse(is.na(성실재입국자), 0, 1))


data_1=data %>% 
  group_by(년도, 시도, 시군구) %>% 
  summarise(성실재입국자수 = sum(성실재입국자, na.rm = T)) 


#write.csv(data_1, "성실재입국자_3번테이블.csv", fileEncoding = "EUC-KR")
