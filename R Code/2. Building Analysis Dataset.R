# 분석 환경 구축
rm(list = ls()) # 디렉토리 초기화
getwd() # 현재 디렉토리 확인
setwd("C:/Users/user/Desktop/법무부 코드시연관련/시연관련데이터") # 데이터가 존재하는 디렉토리로 변경
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
### 21~23년 신청현황_ver2
file <- file_list[2]
apply <-  read.csv(file, fileEncoding = "EUC-KR") %>% 
  subset(비고 != '2021') %>% # 타겟연도 추출
  select(-c(11:14)) # 불필요 컬럼 제거 (재배면적,이력여부, 배정인원, X14 제거)

### 농업경영체 등록정보
Regit_Inf <- read.xlsx('6) 농업경영체 등록정보1.xlsx', sheet = 1, startRow = 1) %>% 
  distinct(, .keep_all = T) %>% # 중복 제거
  filter(grepl('\\(등록\\)', 번호)) # 등록 상태의 데이터만 추출

### 허용작물별 품목 분류
file <- file_list[3]
category <- read.xlsx(file, sheet = 1, startRow = 1) %>% 
  select(c(1,4,3)) %>% # 불필요컬럼 제거
  filter(!apply(., 1, function(row) all(is.na(row)))) %>% # 결측치 제거
  mutate(`소분류명(농림부)` = ifelse(`중분류명(농림부)` == '고추', "풋고추", `소분류명(농림부)`)) %>% # 분류오류 재설정
  select(-c(2)) %>% # 불필요 컬럼 제거
  filter(!is.na(`소분류명(농림부)`)) # 결측치 제거

# 1.파생변수 생성 (농경체별 재배면적)
### 재배품목 결합 (신청현황의 재배작물과 등록현황의 재배작물 매칭)
##### 재배작물이 매칭되는 경우, 매칭되는 재배작물의 면적을 가져오며,
##### 매칭되지 않는 경우, 대표 품목(면적이 가장 큰 품목)과 해당 면적을 가져옴.
P_Regit_Inf <- rbind(Regit_Inf %>% subset(!is.na(시설종류)) %>% 
                       left_join(category %>% distinct(`소분류명(농림부)`, .keep_all = T), 
                                 by = c("재배품목" = "소분류명(농림부)")), # 시설 재배 작물
                     Regit_Inf %>% subset(is.na(시설종류)) %>% 
                       left_join(category %>% group_by(`소분류명(농림부)`) %>% slice(n()) %>% ungroup(), 
                                 by = c("재배품목" = "소분류명(농림부)")) # 노지 재배 작물
) %>% 
  subset(!is.na(`허용작물(법무부)`)) %>% 
  arrange(농업경영체)
P_Regit_Inf$농업경영체 <- as.numeric(P_Regit_Inf$농업경영체) # 데이터타입 변환

### 재배면적 추출
##### 신청현황의 재배품목이 등록정보의 재배품목과 매칭되는 경우
merged_data <- apply %>% 
  left_join(P_Regit_Inf[, c(1, 17, 8)], by = c("농업경영체" = "농업경영체", "작물.종류" = "허용작물(법무부)")) %>% 
  group_by(비고, 지자체명_시도, 지자체명_시군구, 구분, 주소지..조합..법인.소재지., 농업경영체, 합계, 작물.종류) %>% 
  mutate(row_number = row_number(desc(`농지면적(실제경작)`))) %>% 
  filter(is.na(`농지면적(실제경작)`) | row_number == 1) %>% 
  ungroup() %>% 
  arrange(농업경영체) %>% 
  select(-row_number)

##### 신청현황의 재배품목이 등록정보의 재배품목과 매칭되지 않는 경우
##### 농업경영체 별 대표 품목(재배면적이 가장 큰 품목)으로 대체
not_merged_data <- merged_data %>% 
  filter(is.na(`농지면적(실제경작)`)) %>% 
  select(-11) %>% # 농지면적(실제경작)
  left_join(P_Regit_Inf[, c(1, 17, 8)], by = "농업경영체") %>% 
  group_by(비고, 지자체명_시도, 지자체명_시군구, 구분, 주소지..조합..법인.소재지., 농업경영체, 배정신청.인원, 지자체추가배정인원, 합계, 작물.종류) %>%
  slice(which.max(`농지면적(실제경작)`)) %>%
  ungroup() %>% 
  arrange(농업경영체) %>% 
  select(-10)

### 최종 결합
merged_data <- merged_data %>% 
  subset(!is.na(`농지면적(실제경작)`)) %>% 
  bind_rows(not_merged_data) %>% 
  mutate(작물.종류 = ifelse(is.na(작물.종류), `허용작물(법무부)`, 작물.종류),
         `농지면적(실제경작)` = round(`농지면적(실제경작)` / 10000, 2)) %>% 
  select(-`허용작물(법무부)`) %>% 
  rename(`농지면적(ha단위)` = `농지면적(실제경작)`) %>% 
  arrange(농업경영체)

rm(P_Regit_Inf, not_merged_data) # 작업환경 최적화

# 파생변수 생성 (농가구분을 소농, 중농, 대농으로 세분화)
### 작물종류 별 분위수 테이블 생성
cut_off <- 
  merged_data %>% 
  group_by(작물.종류) %>% 
  summarise(cut_off_1 = quantile(`농지면적(ha단위)`, 0.33),
            cut_off_2 = quantile(`농지면적(ha단위)`, 0.66))

### 구분코드 세분화 수행
merged_data <- merged_data %>%
  mutate(
    구분 = case_when(
      구분 == "농가" & `농지면적(ha단위)` <= cut_off$cut_off_1[match(작물.종류, cut_off$작물.종류)] ~ "소농",
      구분 == "농가" & `농지면적(ha단위)` <= cut_off$cut_off_2[match(작물.종류, cut_off$작물.종류)] ~ "중농",
      구분 == "농가" ~ "대농",
      TRUE ~ "법인"
    )
  )

rm(cut_off) # 작업환경 최적화

# 파생변수 생성 (전년대비 농경체 증감률)
### 15~22년 농업경영체 등록현황 데이터 불러오기
file_list
Regist <- read.xlsx('8)15~22년 농촌 농업경영체 현황현황 (지역)_(농림부).xlsx', sheet = 1, startRow = 1) %>% 
  mutate(시군 = ifelse(str_detect(시군, "\\s"), 
                     str_extract(시군, "^.{1,3}"), 시군), # 시군이 동단위 까지 표현되어 있을 경우 정리
         시군 = ifelse(시군 == "세종시", "세종특별자치시", 시군)) %>% # 세종시 표기 표준화
  group_by(연도, 시도, 시군) %>% 
  summarise(`경영체수(건)` = sum(`경영체수(건)`))

# 기초지자체별 농경체 등록현황에서 연도 별 데이터 추출
### 연도 별 자료는 매년 말에 수집한 자료이므로 해당 년도의 전년도 데이터 활용
regist_2021 <- Regist %>% filter(연도 == 2020) %>% mutate(연도 = 2021)
regist_2022 <- Regist %>% filter(연도 == 2021) %>% mutate(연도 = 2022)
regist_2023 <- Regist %>% filter(연도 == 2022) %>% mutate(연도 = 2023)

### 시도, 시군별로 2021년과 2022년의 경영체수 합치기
P_Regist <- inner_join(regist_2021, regist_2022, by = c("시도", "시군")) %>% 
  inner_join(regist_2023, by = c("시도", "시군"))

R_Regist <- bind_rows(P_Regist %>%
                        mutate(전년대비농경체증감률 = round((`경영체수(건).y` - `경영체수(건).x`) / `경영체수(건).x` * 100 + 100, digit = 1)) %>% 
                        select(`연도.y`, 시도, 시군, 전년대비농경체증감률) %>% 
                        rename(연도 = `연도.y`), 
                      P_Regist %>% 
                        mutate(전년대비농경체증감률 = round((`경영체수(건).x` - `경영체수(건)`) / `경영체수(건)` * 100 + 100, digit = 1)) %>% 
                        select(연도, 시도, 시군, 전년대비농경체증감률))

merged_data <- merged_data %>% 
  left_join(R_Regist, by = c("비고" = "연도", "지자체명_시도" = "시도", "지자체명_시군구" = "시군"))

rm(regist_2021, regist_2022, regist_2023, P_Regist, R_Regist) # 작업환경 최적화

# 파생변수 생성 (전체 농업 종사자 대비 노령 종사자 비율)
### 데이터 불러오기
### 2021년 농업경영체 현황
file <- '2021년농업경영체현황(농업인)_지역별농업인현황_20231024143749.xlsx'

worker_2022 <- read.xlsx(file, sheet = 1, startRow = 2) %>% 
  select(c(1,2,6:18)) %>% 
  rename("지자체명_시도" = "X1", "지자체명_시군구" = "X2") %>% 
  subset(지자체명_시군구 != "소계") %>% 
  mutate(비고 = 2022)

### 2022년 농업경영체 현황
file <- '2022년농업경영체현황(농업인)_지역별농업인현황_20231024143721.xlsx'

worker_2023 <- read.xlsx(file, sheet = 1, startRow = 2) %>% 
  select(c(1,2,6:18)) %>% 
  rename("지자체명_시도" = "X1", "지자체명_시군구" = "X2") %>% 
  subset(지자체명_시군구 != "소계") %>% 
  mutate(비고 = 2023)

### 데이터 결합
worker <- bind_rows(worker_2022, worker_2023)

### 연도 별 고령농경체비율 추출
P_worker <- worker %>% 
  mutate(지자체명_시군구 = ifelse(str_detect(지자체명_시군구, "\\s"), str_extract(지자체명_시군구, "^.{1,3}"), 지자체명_시군구),
         지자체명_시군구 = ifelse(지자체명_시군구 == "세종시", "세종특별자치시", 지자체명_시군구)) %>% # 세종시 표기 표준화) %>% 
  group_by(비고, 지자체명_시도, 지자체명_시군구) %>% 
  summarise(청년인구수 = sum(`25세.미만`, `25~29세`, `30~34세`, `35~39세`, `40~44세`, `45~49세`, `50~54세`, `55~59세`, `60~64세`),
            노년인구수 = sum(`65~69세`, `70~74세`, `75~79세`, `80세.이상`),
            고령농경체비율 = round(노년인구수 / (청년인구수+노년인구수) * 100,2))

### 분석 데이터셋에 반영
merged_data <- merged_data %>% 
  left_join(P_worker[,c(1,2,3,6)], # 연도, 시도, 시군구, 고령비율
            by = c("비고", "지자체명_시도", "지자체명_시군구"))

rm(worker_2022, worker_2023, P_worker) # 작업환경 최적화

setwd("../") # 작업환경 전환

# 파생변수 생성 (전년도 이력)
### 데이터 불러오기
file <- '3)5)21~23년 참여자 현황 (지역, 유형, 국적, 체류자격, 성별, MOU, 출국, 이탈)1.xlsx' # 2021년 외국인 계절근로 참여자 현황
Particip <- read.xlsx(file, sheet = 1, startRow = 1)

P_Particip <- Particip %>% 
  filter(구분 %in% c("결혼이민자가족", "MOU") & 업종 == '농업') %>% 
  subset(년도 %in% c('2021', '2022')) %>% 
  group_by(농업경영체, 년도) %>% 
  summarise(입국인원 = n(),
            전년도이탈인원 = sum(!is.na(소재불명발생일자))) %>% 
  mutate(비고 = as.numeric(년도)+1)
P_Particip$농업경영체 <- as.numeric(P_Particip$농업경영체)

### 전년도이력 (외국인 활용 여부, 이탈인원) 생성
final_dataset <- merged_data %>% 
  left_join(P_Particip, by = c("농업경영체", "비고")) %>% 
  mutate(전년도활용여부 = ifelse(!is.na(입국인원), "Y", "N"),
         전년도이탈인원 = ifelse(!is.na(전년도이탈인원), 전년도이탈인원, 0)) %>% 
  select(-c("입국인원")) %>% 
  select(c(1,6,2,3,4,10,11,12,13,16,15,7,8,9)) %>% 
  distinct(, .keep_all = T) # 중복 제거

rm(P_Particip) # 작업환경 최적화

### 어떤 기준으로 중복제거할지 고려해봐야 함.
### 구분: 농가를 소농 중농 대농 등으로 나눌 수 있는 근거 자료 확보 필요
### 전년도 참여 인원 국가
# setwd("../../03. 데이터 분석/3. Build Dataset")
write.csv(final_dataset, "dataset_1026.csv", fileEncoding = "EUC-KR", row.names = F)
