rm(list = ls())
# 분석 환경 설정
getwd() # 현재 디렉토리 확인

options(scipen = 999, digits = 15) # 숫자 표시 형식 지정

# 패키지 로드
library(openxlsx)
library(dplyr)
library(data.table)
library(stringr)

# 현재 디렉토리에 존재하는 파일명을 출력합니다.
file_list <- list.files()
print(file_list)


# 데이터 불러오기
file = file_list[3] # 내외국인 현황
file
Status_of_For <- read.xlsx(file, sheet = 1, startRow = 1)

P_Status_of_For <- 
  Status_of_For %>% 
  mutate(`내외국인.비율` = paste0(round(내외국인.비율, 3)*100, "%"))

str(P_Status_of_For)

data2015=P_Status_of_For %>% subset(연 == 2015) 
sum(table(data2015$시군구))
freq_table=table(data2015$시군구)
duplic_sigu=names(freq_table[freq_table>=2])
duplic_sigu


# 중복되는 시군구 뽑아내기
result <- P_Status_of_For %>%
  group_by(your_column) %>%
  filter(n() >= 1) %>%
  ungroup()
