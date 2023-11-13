rm(list = ls())
# 1. 분석 환경 설정
getwd() # 현재 디렉토리 확인
setwd("C:/Users/user/Desktop/법무부 코드시연관련/시연관련데이터") # 데이터가 존재하는 디렉토리로 변경
options(scipen = 999, digits = 15) # 숫자 표시 형식 지정


# 2. 패키지 로드
library(openxlsx) #엑셀 파일을 불러오기 위한 라이브러리
library(dplyr) #데이터 필터링, 정렬 및 그룹화
library(data.table) #데이터 프레임 처리를 위한 패키지
library(stringr)#문자열 처리를 위한 함수

# 현재 디렉토리에 존재하는 파일명을 출력
file_list <- list.files()
print(file_list)

# 3. 데이터 불러오기
file = file_list[1] # 21년~23년 신청현황
data <- 
  read.xlsx(file, sheet = 1, startRow = 3)  # 시트 번호 또는 이름을 설정할 수 있습니다.

# 4. 중복 컬럼명 변경
### 시도와 시군구를 나타내는 컬럼명이 모두 "지자체명"이므로 이를 세분화
colnames(data)[2:3] <- c("지자체명_시도", "지자체명_시군구")

# 전체 레코드 수 확인
nrow(data) # 14,365건

# 데이터 전처리

# 5. 지자체명 컬럼 전처리
### 표기 오류 정정
##### 담양 → 담양군
##### 충청북도 청양군 → 충청남도 청양군
##### 불필요한 공백 제거 (가장 앞 혹은 가장 뒤)
apply <- 
  data %>% 
  mutate(지자체명_시군구 = ifelse(지자체명_시군구 == '담양', '담양군', 지자체명_시군구),
         지자체명_시도 = ifelse(지자체명_시군구 == '청양군' & 지자체명_시도 == '충청북도', '충청남도', 지자체명_시도),
         지자체명_시도 = str_trim(지자체명_시도),
         지자체명_시군구 = str_trim(지자체명_시군구))

#6. 농업경영체 컬럼 전처리
### 표기 형식 표준화
##### '-' 제거
apply <- apply %>% 
  mutate(농업경영체 = gsub('-', '', 농업경영체))
##### 공백 및 특수문자 제거
apply <- apply %>% 
  mutate(농업경영체 = gsub('  ', '', 농업경영체)) # 특수문자
apply <- apply %>% 
  mutate(농업경영체 = gsub(' ', '', 농업경영체)) # 특수믄자
apply <- apply %>% 
  mutate(농업경영체 = gsub('\\*', '', 농업경영체)) # *(애스터리스크)
apply <- apply %>% 
  mutate(농업경영체 = gsub(' ', '', 농업경영체)) # 공백
apply <- apply %>% 
  mutate(농업경영체 = gsub('\n', '', 농업경영체)) # 줄바꿈

### 7. 농업경영체 등록번호 자리 수 계산
##### 기본 표준이 되는 농업경영체 등록번호는 10자리
apply <- apply %>%
  mutate(자리수 = nchar(농업경영체))

apply %>%
  group_by(자리수) %>%
  summarize(데이터_개수 = n())

#     자리수     데이터_개수
#       <int>       <int>
# 1      0           2
# 2      2           1
# 3      3           1
# 4      4           5
# 5      8           2
# 6      9         198
# 7     10       14113
# 8     11          17
# 9     13           2
# 10     20           2
# 11     NA          22

### 1. 자리수가 NA인 데이터 (공백) 처리
apply %>% filter(nchar(농업경영체) == 0) # 2건
apply %>% filter(is.na(nchar(농업경영체))) # 22건
##### 제거 
apply <- apply %>% 
  filter(nchar(농업경영체) != 0)

### 2. 자리수가 2인 데이터 ("없음") 처리
apply %>% filter(nchar(농업경영체) == 2) # 1건
##### 제거
apply <- apply %>% 
  filter(nchar(농업경영체) != 2)

### 3. 자리수가 3인 데이터 ("공공형")
apply %>% filter(nchar(농업경영체) == 3) # 1건
##### 제거
apply <- apply %>% 
  filter(nchar(농업경영체) != 3)

### 4. 자리수가 4인 데이터 ("해당없음" 혹은 "(미정)") 처리
apply %>% filter(nchar(농업경영체) == 4) # 5건
##### 제거
apply <- apply %>% 
  filter(nchar(농업경영체) != 4)

### 5. 자리수가 8인 데이터 (불충분자료) 처리
apply %>% filter(nchar(농업경영체) == 8) # 2건
##### 제거
apply <- apply %>% 
  filter(nchar(농업경영체) != 8)

### 6. 자리수가 9인 데이터
apply %>% filter(nchar(농업경영체) == 9)
##### 6-1. 첫차리가 0인 경우, 가장 앞에 1을 부착
apply <- apply %>%
  mutate(농업경영체 = ifelse(nchar(농업경영체) == 9 & substr(농업경영체, 1, 1) == "0", 
                        paste0("1", 농업경영체), 농업경영체))
##### 6-2. 이외 데이터 (농업경영체 일부 번호 누락(오기입))
apply %>% filter(nchar(농업경영체) == 9) # 15건
##### 제거
apply <- apply %>% 
  filter(nchar(농업경영체) != 9)

### 7. 자리수가 11자리 이상인 데이터
apply %>% filter(nchar(농업경영체) >= 11) # 21건
##### 7-1. 최초 10자리만 추출
apply <- apply %>% 
  mutate(농업경영체 = ifelse(nchar(농업경영체) >= 11, substr(농업경영체, 1, 10), 농업경영체))

### ＠. 문자형인 경우 제거
apply$농업경영체 <- as.numeric(apply$농업경영체)
apply <- apply %>% 
  filter(!is.na(농업경영체))

### 8. 농업경영체 등록번호 자리 수 다시 계산
apply <- apply %>%
  mutate(자리수 = nchar(농업경영체))

apply %>%
  group_by(자리수) %>%
  summarize(데이터_개수 = n())

### 9. 오류데이터 제거
apply %>% filter(nchar(농업경영체) == 1) # 1건
apply %>% filter(nchar(농업경영체) == 6) # 1건
##### 제거
apply <- apply %>% 
  filter(nchar(농업경영체) == 10)

### 10. 최종 레코드 수 확인 및 불필요 컬럼 제거
nrow(apply) # 14,312건: 총 53개의 레코드 제거 완료

apply <- apply %>% 
  select(-'자리수')

# 11. 배정신청인원 컬럼 전처리
### 0. 데이터 분포 확인
apply %>% 
  group_by(배정신청.인원) %>% 
  summarize(n = n())

### 1. 결측값 및 오류값 처리
apply <- 
  apply %>%
  mutate(배정신청.인원 = ifelse(is.na(배정신청.인원) | 배정신청.인원 == '-', 0, 배정신청.인원))

### 2. 데이터 타입 변환(숫자형)
apply$배정신청.인원 <- as.numeric(apply$배정신청.인원)

# 12. 지자체추가배정인원 컬럼 전처리
### 0. 데이터 분포 확인
apply %>% 
  group_by(지자체추가배정인원) %>% 
  summarize(n = n())

### 1. 결측값 및 오류값 처리
apply <- 
  apply %>%
  mutate(지자체추가배정인원 = ifelse(is.na(지자체추가배정인원) | 지자체추가배정인원 == '-' | 지자체추가배정인원 == '없음', 0, 지자체추가배정인원))

### 2. 데이터 타입 변환(숫자형)
apply$지자체추가배정인원 <- as.numeric(apply$지자체추가배정인원)

# 13. 합계 컬럼 전처리 (배정신청인원 + 지자체추가배정인원)
apply <- 
  apply %>% 
  mutate(합계 = 배정신청.인원 + 지자체추가배정인원)

### 14. 데이터 타입 변환(숫자형)
apply$합계 <- as.numeric(apply$합계)

# 15. 작물종류 컬럼 전처리
### 0. 데이터 분포 확인
apply %>% 
  group_by(작물.종류) %>% 
  summarise(n = n())

### 1. 표준 체계에 맞춰 변환 (cf. 업종품목별허용기준)
apply <- 
  apply %>%
  mutate(
    작물.종류 = case_when(
      grepl('①|1', 작물.종류) ~ '① 시설원예·특작',
      grepl('②|2', 작물.종류) ~ '② 버섯',
      grepl('③|3', 작물.종류) ~ '③ 과수',
      grepl('④|4|인삼', 작물.종류) ~ '④ 인삼, 일반채소',
      grepl('⑤', 작물.종류) ~ '⑤ 종묘재배',
      grepl('⑥|기타원예·특작', 작물.종류) ~ '⑥ 기타원예·특작',
      grepl('⑦|곡물', 작물.종류) ~ '⑦ 곡물',
      grepl('⑧|기타식량작물', 작물.종류) ~ '⑧ 기타 식량작물',
      grepl('⑨', 작물.종류) ~ '⑨ 곶감가공',
      TRUE ~ 작물.종류
    )
  )

# 최종 레코드: 14,312건 (농업경영체번호 오기입 53건 제거)
write.csv(apply, '1) 21~23년 신청현황 (지역, 인원, 작물종류, 면적, 배정인원)_ver2.csv', fileEncoding = "EUC-KR", row.names = F)
