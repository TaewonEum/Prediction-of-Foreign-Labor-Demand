rm(list = ls())
# 분석 환경 설정
getwd() # 현재 디렉토리 확인
setwd("C:/Users/user/Desktop/법무부 분석코드 최종/활용데이터") # 데이터가 존재하는 디렉토리로 변경
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
Regit_Info <- read.xlsx('6)농업경영체 등록정보1.xlsx', sheet = 1, startRow = 1) #농업경영체 등록정보
Regit_Info
file = file_list[5] # 허용작물별 품목분류
cultiv <- read.xlsx(file, sheet = 1, startRow = 1) %>% select(1,2) #법무부 허용 작물만 추출
cultiv <- cultiv[1:127,]

# 데이터 전처리
### 등록된 농지 필터링
P_Regit_Info <- Regit_Info %>%filter(grepl('\\(등록\\)', 번호)) ### 143,585건(등록된 경영체만 필터링)
nrow(P_Regit_Info)

### 중복 제거
P_Regit_Info <- P_Regit_Info %>% distinct(농업경영체, 번호, .keep_all = T) #모든행이 똑같을 경우 제거해줌
nrow(P_Regit_Info)

### 시도, 시군구명 추출
P_Regit_Info <- 
  P_Regit_Info %>%
  mutate(
    주소_분리 = strsplit(농지.등.소재지, " "),
    지자체명_시도 = sapply(주소_분리, "[[", 1), #시도 추출
    지자체명_시군구 = sapply(주소_분리, "[[", 2) #지자체명 추출
  ) %>%
  select(-주소_분리)

# 예제 데이터프레임 생성
df1 <- data.frame(ID = c(1, 2, 3, 4),
                  Name = c("Alice", "Bob", "Charlie", "David"))

df2 <- data.frame(ID = c(2, 4, 5),
                  Score = c(85, 92, 78))

# df1과 df2를 ID 열을 기준으로 semi-join
result <- semi_join(df1, df2, by = "ID") %>% left_join(df2,df1,by='ID')
result

# 법무부 분류체계 결합
cultiv
P_P_Regit_Info <- 
  P_Regit_Info %>% 
  semi_join(cultiv, by = c("재배품목" = "적용작물(법무부)")) %>% #적용작물이 있는 행만 선택
  left_join(cultiv, by = c("재배품목" = "적용작물(법무부)")) %>% #
  select(c(17,18,1,8,11,13,19))


# 중복 작물 처리 빈도가 1이상인 재배작물들
### 특정 작물의 경우 온실에서 재배하면 시설원예에 포함되며
### 온실 재배가 아닐 경우 일반채소로 분류됨
dup_list <- 
  cultiv %>% 
  group_by(`적용작물(법무부)`) %>% 
  filter(n()>1) %>% data.frame()

#중복 재배작물 법무부 재배품목 종류로 바꿔주기
P_P_Regit_Info <- 
  P_P_Regit_Info %>% 
  mutate(`허용작물(법무부)` = case_when(
    재배품목 %in% unique(dup_list$적용작물.법무부.) & is.na(시설종류) ~ "④ 인삼, 일반채소",
    재배품목 %in% unique(dup_list$적용작물.법무부.) & !is.na(시설종류) ~ "① 시설원예·특작",
    재배품목 == "무화과" & is.na(시설종류) ~ "④ 인삼, 일반채소",
    재배품목 == "무화과" & !is.na(시설종류) ~ "③ 과수",
    TRUE ~ `허용작물(법무부)`))

#컬럼명 바꿔주기
colnames(P_P_Regit_Info) <- 
  c("지자체명_시도", "지자체명_시군구", "농업경영체", "농지면적", "재배품목(농림부)", "시설종류", "재배품목")

P_P_Regit_Info$cul_area <- P_P_Regit_Info$농지면적 / 1000
max(P_P_Regit_Info$cul_area)

#작물별 면적에 따라 계절근로자 배정 허용인원을 알 수 있는 Allowed_number 변수 추가
P_P_Regit_Info <- P_P_Regit_Info %>% 
  mutate(
    Allowed_number = case_when(
      재배품목 == "① 시설원예·특작" & cul_area < 2.6 ~ 5,
      재배품목 == "① 시설원예·특작" & cul_area < 3.9 ~ 6,
      재배품목 == "① 시설원예·특작" & cul_area < 5.2 ~ 7,
      재배품목 == "① 시설원예·특작" & cul_area < 6.5 ~ 8,
      재배품목 == "① 시설원예·특작" & cul_area >= 6.5 ~ 9,
      재배품목 == "② 버섯" & cul_area < 5.2 ~ 5,
      재배품목 == "② 버섯" & cul_area < 7.8 ~ 6,
      재배품목 == "② 버섯" & cul_area < 10.4 ~ 7,
      재배품목 == "② 버섯" & cul_area < 13 ~ 8,
      재배품목 == "② 버섯" & cul_area >= 13 ~ 9,
      재배품목 == "③ 과수" & cul_area < 16 ~ 5,
      재배품목 == "③ 과수" & cul_area < 24 ~ 6,
      재배품목 == "③ 과수" & cul_area < 32 ~ 7,
      재배품목 == "③ 과수" & cul_area < 38 ~ 8,
      재배품목 == "③ 과수" & cul_area >= 38 ~ 9,
      재배품목 == "④ 인삼, 일반채소" & cul_area < 12 ~ 5,
      재배품목 == "④ 인삼, 일반채소" & cul_area < 18 ~ 6,
      재배품목 == "④ 인삼, 일반채소" & cul_area < 24 ~ 7,
      재배품목 == "④ 인삼, 일반채소" & cul_area < 30 ~ 8,
      재배품목 == "④ 인삼, 일반채소" & cul_area >= 30 ~ 9,
      재배품목 == "⑤ 종묘재배" & cul_area < 0.35 ~ 5,
      재배품목 == "⑤ 종묘재배" & cul_area < 0.65 ~ 6,
      재배품목 == "⑤ 종묘재배" & cul_area < 0.95 ~ 7,
      재배품목 == "⑤ 종묘재배" & cul_area < 1.25 ~ 8,
      재배품목 == "⑤ 종묘재배" & cul_area >= 1.25 ~ 9,
      재배품목 == "⑥ 기타원예·특작" & cul_area < 7.8 ~ 5,
      재배품목 == "⑥ 기타원예·특작" & cul_area < 11.7 ~ 6,
      재배품목 == "⑥ 기타원예·특작" & cul_area < 15.6 ~ 7,
      재배품목 == "⑥ 기타원예·특작" & cul_area < 19.5 ~ 8,
      재배품목 == "⑥ 기타원예·특작" & cul_area >= 19.5 ~ 9,
      재배품목 == "⑦ 곡물" & cul_area < 50 ~ 5,
      재배품목 == "⑦ 곡물" & cul_area < 300 ~ 6,
      재배품목 == "⑦ 곡물" & cul_area < 400 ~ 7,
      재배품목 == "⑦ 곡물" & cul_area < 500 ~ 8,
      재배품목 == "⑦ 곡물" & cul_area >= 500 ~ 9,
      재배품목 == "⑧ 기타 식량작물" & cul_area < 7 ~ 5,
      재배품목 == "⑧ 기타 식량작물" & cul_area < 10 ~ 6,
      재배품목 == "⑧ 기타 식량작물" & cul_area < 13 ~ 7,
      재배품목 == "⑧ 기타 식량작물" & cul_area < 16 ~ 8,
      재배품목 == "⑧ 기타 식량작물" & cul_area >= 16 ~ 9,
      재배품목 == "⑨ 곶감가공" & cul_area < 70 ~ 5,
      재배품목 == "⑨ 곶감가공" & cul_area < 80 ~ 6,
      재배품목 == "⑨ 곶감가공" & cul_area < 90 ~ 7,
      재배품목 == "⑨ 곶감가공" & cul_area < 100 ~ 8,
      재배품목 == "⑨ 곶감가공" & cul_area >= 100 ~ 9,
      TRUE ~ 0
    )
  )

t <- P_P_Regit_Info %>% 
  group_by(지자체명_시도, 지자체명_시군구) %>% 
  summarise(`① 시설원예·특작` = sum(재배품목 == "① 시설원예·특작"),
            `② 버섯` = sum(재배품목 == "② 버섯"),
            `③ 과수` = sum(재배품목 == "③ 과수"),
            `④ 인삼, 일반채소` = sum(재배품목 == "④ 인삼, 일반채소"),
            `⑤ 종묘재배` = sum(재배품목 == "⑤ 종묘재배"),
            `⑥ 기타원예·특작` = sum(재배품목 == "⑥ 기타원예·특작"),
            `⑦ 곡물` = sum(재배품목 == "⑦ 곡물"),
            `⑧ 기타 식량작물` = sum(재배품목 == "⑧ 기타 식량작물"),
            `⑨ 곶감가공` = sum(재배품목 == "⑨ 곶감가공"),
            허용작물_재배면적 = sum(농지면적),
            허용작물_농업경영체수 = n_distinct(농업경영체),
            허용인원 = sum(Allowed_number))

colnames(t)
length(unique(t))
