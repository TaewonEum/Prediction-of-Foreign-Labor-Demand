# 분석 환경 구축
rm(list = ls()) # 디렉토리 초기화
getwd() # 현재 디렉토리 확인
setwd("C:/Users/user/Desktop/세분류/법무부허용작물/예측용데이터셋") # 데이터가 존재하는 디렉토리로 변경
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
############################# 2022년 외국인 계절근로자 신청현황 (전처리한 데이터 로드) ###########################
apply <- 
  read.csv('./신청현황_최종.csv', fileEncoding = "EUC-KR") %>% 
  subset(비고 != '2021') %>% 
  select(-c(7, 8, 11:14)) %>% # 배정신청인원, 지자체추가배정인원 등 불필요 컬럼 제거
  distinct(, .keep_all = T)

################################ 농업경영체 등록정보 ##############################
Regit_Inf <- 
  read.xlsx('./6) 농업경영체 등록정보1.xlsx', sheet = 1, startRow = 1) %>%  # 시트 번호 또는 이름을 설정할 수 있습니다.
  distinct(, .keep_all = T) %>% # 중복 제거
  filter(grepl('\\(등록\\)', 번호)) # 등록 상태의 데이터만 추출

################################## 허용작물별 품목 분류 ##############################
file <- file_list[4]
category <- 
  read.xlsx(file, sheet = 1, startRow = 1) %>%  # 시트 번호 또는 이름을 설정할 수 있습니다.
  select(c(1,4,3)) %>% # 불필요컬럼 제거
  filter(!apply(., 1, function(row) all(is.na(row)))) %>% # 불필요행 제거
  mutate(`소분류명(농림부)` = ifelse(`중분류명(농림부)` == '고추', "풋고추", `소분류명(농림부)`)) %>% # 분류오류 재설정
  select(-c(2)) %>% 
  filter(!is.na(`소분류명(농림부)`))

# 파생변수 생성 (재배면적)
### 재배품목 결합
##### 재배품목이 매칭되는 경우, 매칭되는 재배품목의 면적을 가져오며,
##### 매칭되지 않는 경우, 대표 품목(면적이 가장 큰 품목)과 해당 면적을 가져옴.
P_Regit_Inf <- 
  rbind(Regit_Inf %>% subset(!is.na(시설종류)) %>% 
          left_join(category %>% distinct(`소분류명(농림부)`, .keep_all = T), 
                    by = c("재배품목" = "소분류명(농림부)")), # 시설 재배 작물
        Regit_Inf %>% subset(is.na(시설종류)) %>% 
          left_join(category %>% group_by(`소분류명(농림부)`) %>% slice(n()) %>% ungroup(), 
                    by = c("재배품목" = "소분류명(농림부)")) # 노지 재배 작물
  ) %>% 
  subset(!is.na(`허용작물(법무부)`)) %>% 
  # group_by(농업경영체) %>%
  # ungroup() %>% 
  arrange(농업경영체)
P_Regit_Inf$농업경영체 <- as.numeric(P_Regit_Inf$농업경영체) # 데이터타입 변환


### 재배면적 추출
##### 신청현황의 재배품목이 등록정보의 재배품목과 매칭되는 경우
merged_data <- 
  apply %>% 
  left_join(P_Regit_Inf[, c(1, 17, 8)], by = c("농업경영체" = "농업경영체", "작물.종류" = "허용작물(법무부)")) %>% 
  group_by(비고, 지자체명_시도, 지자체명_시군구, 구분, 주소지..조합..법인.소재지., 농업경영체, 합계, 작물.종류) %>% 
  mutate(row_number = row_number(desc(`농지면적(실제경작)`))) %>% 
  filter(is.na(`농지면적(실제경작)`) | row_number == 1) %>% 
  ungroup() %>% 
  arrange(농업경영체) %>% 
  select(-row_number)

table(is.na(merged_data$`농지면적(실제경작)`))


##### 신청현황의 재배품목이 등록정보의 재배품목과 매칭되지 않는 경우
##### 농업경영체 별 대표 품목(재배면적이 가장 큰 품목)으로 대체
not_merged_data <- 
  merged_data %>% 
  filter(is.na(`농지면적(실제경작)`)) %>% 
  select(-9) %>% 
  left_join(P_Regit_Inf[, c(1, 17, 8)], by = "농업경영체") %>% 
  group_by(비고, 지자체명_시도, 지자체명_시군구, 구분, 주소지..조합..법인.소재지., 농업경영체, 합계, 작물.종류) %>%
  slice(which.max(`농지면적(실제경작)`)) %>%
  ungroup() %>% 
  arrange(농업경영체) %>% 
  select(-8)

### 최종 결합
merged_data <- 
  merged_data %>% 
  subset(!is.na(`농지면적(실제경작)`)) %>% 
  bind_rows(not_merged_data) %>% 
  mutate(작물.종류 = ifelse(is.na(작물.종류), `허용작물(법무부)`, 작물.종류)) %>% 
  select(-`허용작물(법무부)`) %>% 
  arrange(농업경영체)

# 파생변수 생성 (농가구분을 소농, 중농, 대농으로 변환)
merged_data <- 
  merged_data %>% 
  mutate(구분 = case_when(
    구분 == "농가" & `농지면적(실제경작)` <= 10000 ~ "소농",
    구분 == "농가" & `농지면적(실제경작)` <= 30000 ~ "중농",
    구분 == "농가" & `농지면적(실제경작)` > 30000 ~ "대농",
    TRUE ~ "법인"
  ))

# 파생변수 생성 (기초지자체 별 내외국인 비율 생성)
### 데이터 불러오기
print(file_list)
file <- 
  file_list[2] # 내외국인 현황
Status_of_For <- 
  read.xlsx(file, sheet = 1, startRow = 1) %>% 
  filter(연 %in% c('2022', '2023'))

### 내외국인 비율 생성
P_Status_of_For <- 
  Status_of_For %>% 
  mutate(시군구 = ifelse(str_detect(시군구, "\\s"), str_extract(시군구, "^.{1,3}"), 시군구),
         시군구 = ifelse(시도 == "세종특별자치시", "세종특별자치시", 시군구),
         내외국인.비율 = round(내외국인.비율, 3))

### 중복되는 경우 인구수를 합산하여 비율 재계산
##### 고양시 덕양구, 고양시 일산동구, 고양시 일산서구 → 고양시로 결합
P_Status_of_For <- 
  P_Status_of_For %>% 
  group_by(연, 시도, 시군구) %>% 
  summarise(내국인.수 = sum(내국인.수),
            외국인.수 = sum(외국인.수),
            내외국인.비율 = round(외국인.수/내국인.수, 3))


### 데이터 결합
merged_data <- 
  merged_data %>% 
  left_join(P_Status_of_For[, c(1,2,3,6)], by = c("지자체명_시도" = "시도", "지자체명_시군구" = "시군구", '비고' = '연'))


# 파생변수 생성 (전년대비 농경체 증감률)
getwd()
Regist <- read.xlsx('./8)15~22년 농촌 농업경영체 현황현황 (지역)_(농림부).xlsx',sheet=1,startRow = 1)


# Regist 데이터프레임에서 2021년과 2022년 데이터 추출
regist_2021 <- Regist %>% filter(연도 == 2021)
regist_2022 <- Regist %>% filter(연도 == 2022)
#2023년도꺼 들어오면 여기에 추가하기

# 시도, 시군별로 2021년과 2022년의 경영체수 합치기
P_Regist <- 
  inner_join(regist_2021, regist_2022, by = c("시도", "시군")) 

colnames(P_Regist)
P_Regist=P_Regist %>% select(-c(1,5))
colnames(P_Regist)=c('시도','시군','경영체수_2021','경영체수_2022')         
str(P_Regist)

R_Regist=P_Regist %>% mutate(전년대비농경체증감률_2022=round((경영체수_2022-경영체수_2021)/경영체수_2021,3))
R_Regist=R_Regist %>% select(c(1,2,5))

merged_data <- 
  merged_data %>% 
  left_join(R_Regist, by = c( "지자체명_시도" = "시도", "지자체명_시군구" = "시군"))

# 파생변수 생성 (전년도 이력)
### 데이터 불러오기
file_list
file <- file_list[5] # 2021년 외국인 계절근로 참여자 현황
Particip <- read.xlsx(file, sheet = 1, startRow = 1)

P_Particip <- 
  Particip %>% 
  filter(구분 %in% c("결혼이민자가족", "MOU") & 업종 == '농업') %>% 
  subset(년도 %in% c('2021', '2022')) %>% 
  group_by(농업경영체, 년도) %>% 
  summarise(입국인원 = n(),
            전년도이탈인원 = sum(!is.na(소재불명발생일자))) %>% 
  mutate(비고 = as.numeric(년도)+1)
P_Particip$농업경영체 <- as.numeric(P_Particip$농업경영체)


### 전년도이력 (외국인 활용 여부, 이탈인원) 생성
final_dataset <- 
  merged_data %>% 
  left_join(P_Particip, by = c("농업경영체", "비고")) %>% 
  mutate(전년도활용여부 = ifelse(!is.na(입국인원), "Y", "N"),
         전년도이탈인원 = ifelse(!is.na(전년도이탈인원), 전년도이탈인원, 0)) %>% 
  select(-c("입국인원")) %>% 
  select(c(1,6,2,3,4,8,9,10,11,14,13,7))

