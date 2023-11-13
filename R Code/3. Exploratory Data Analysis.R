# EDA (Exploratory Data Analysis)

# Setting Analysis Environment
rm(list = ls()) # Reset Directory
getwd() # Check Current Directory
source("C:/Users/user/Desktop/법무부 코드시연관련/역량강화 컨설팅/function.R")
setwd("C:/Users/user/Desktop/법무부 코드시연관련/시연관련데이터")
options(scipen = 999, digits = 15) # Specifies Display of the number format

# Load Packages
library(openxlsx)
library(dplyr)
library(data.table)
library(stringr)
library(tidyr)
library(ggplot2)
library(caret)
library(agricolae)

# Print File Name of Current Directory
file_list <- list.files()
print(file_list)

# Load Dataset
### Final Dataset for Analysis
file <- 'dataset_1026.csv'
final_data <-  read.csv(file, fileEncoding = "EUC-KR") %>% 
  filter(합계 != 0)

### Explore Data Objects
str(final_data)

# 1. 기초통계량 분석
### 1.1 연속형 변수 평균, 중앙값, 표준편차, 범위, 사분위수
##### 연속형변수: 농지면적, 전년대비 농경체 증감률, 고령농경체비율, 전년도이탈인원, 배정신청인원, 지자체추가배정인원, 합계
##### 연속형변수에 대한 요약 통계 계산
columns_to_summarize <- c("농지면적.ha단위.", "전년대비농경체증감률", "고령농경체비율", 
                          "전년도이탈인원", "배정신청.인원", "지자체추가배정인원", "합계")
summary <- calculate_summary(final_data, columns_to_summarize) #calculate_summary(데이터셋, 연속형변수리스트)
summary #평균, 중앙값,표준편차, 최대값, 최소값, 1사분위수, 3사분위수 계산

rm(summary) # 작업환경 최적화

# 2. 개별 변수 탐색
### 2.1 외국인 계절 근로자 프로그램 신청 경영체 현황
##### 2.1.1 연도 별 신청현황
num_of_apply <- final_data %>% 
  group_by(비고 = as.character(비고)) %>% 
  summarise(합계 = n())

plot_bar(data=num_of_apply, x_var=비고, y_var=합계, title="시도 별 외국인 계절 근로 프로그램 신청 경영체 수",
         x_label="시도", y_label="경영체수", reorder = F)

##### 2.1.2 시도 별 신청 현황 (전체연도)
table(final_data$지자체명_시도)
plot_bar(data=data.frame(table(final_data$지자체명_시도)), x_var=Var1, y_var=Freq, 
         title="시도 별 외국인 계절 근로 프로그램 신청 경영체 수", x_label="시도", y_label="경영체수", reorder = T)

##### 2.1.3 시도 별 신청 현황 (2022년)
data_2022 <- subset(final_data, 비고 == 2022)

plot_bar(data=data.frame(table(data_2022$지자체명_시도)), x_var=Var1, y_var=Freq, 
         title="2022년 시도 별 외국인 계절 근로 프로그램 신청 경영체 수", x_label="시도", y_label="경영체수", reorder = T)

##### 2.1.4 시도 별 신청 현황 (2023년)
data_2023 <- subset(final_data, 비고 == 2023)

plot_bar(data.frame(table(data_2023$지자체명_시도)), Var1, Freq, 
         "2023년 시도 별 외국인 계절 근로 프로그램 신청 경영체 수", "시도", "경영체수", reorder = T)

##### 2.1.5 경상북도 현황(2022년)
data_2022_gb <- 
  data_2022 %>% subset(지자체명_시도 == "경상북도")

plot_bar(data.frame(table(data_2022_gb$지자체명_시군구)), Var1, Freq, 
         "2022년 경상북도 외국인 계절 근로 프로그램 신청 경영체 수", "시도", "경영체수", reorder = T)

##### 2.1.6 경상북도 현황(2023년)
data_2023_gb <- 
  data_2023 %>% subset(지자체명_시도 == "경상북도")

plot_bar(data.frame(table(data_2023_gb$지자체명_시군구)), Var1, Freq, 
         "2023년 경상북도 외국인 계절 근로 프로그램 신청 경영체 수", "시도", "경영체수", reorder = T)

rm(num_of_apply, data_2022, data_2023, data_2022_gb, data_2023_gb) # 작업환경 최적화

### 2.2 외국인 계절 근로자 배정 신청 현황
##### 2.2.1 연도 별 배정 현황
sum_of_apply <- final_data %>% 
  group_by(비고 = as.character(비고)) %>% 
  summarise(합계 = sum(합계))

plot_bar(sum_of_apply, 비고, 합계,
         "시도 별 외국인 계절 근로자 배정 신청 현황", "연도", "배정신청인원", reorder = F)

##### 2.2.2 시도 별 신청 현황 (전체연도)
sum_of_apply <- final_data %>% 
  group_by(지자체명_시도) %>% 
  summarise(합계 = sum(합계))

plot_bar(sum_of_apply, 지자체명_시도, 합계,
         "시도 별 외국인 계절 근로자 배정 신청자 수", "시도", "배정신청인원", reorder = T)

##### 2.1.3 시도 별 배정 신청 현황 (2022년)
sum_of_apply <- final_data %>% 
  group_by(비고, 지자체명_시도) %>% 
  summarise(합계 = sum(합계))

plot_bar(sum_of_apply %>% subset(비고 == 2022), 지자체명_시도, 합계,
         "2022년 시도 별 외국인 계절 근로자 배정 신청 인원 수", "시도", "경영체수", reorder = T)

##### 2.2.4 시도 별 배정 신청 현황 (2023년)
plot_bar(sum_of_apply %>% subset(비고 == 2023), 지자체명_시도, 합계,
         "2023년 시도 별 외국인 계절 근로자 배정 신청 인원 수", "시도", "경영체수", reorder = T)

rm(sum_of_apply) # 작업환경 최적화

### 2.3 외국인 계절근로자 프로그램 신청 농가 구성비
##### 2.3.1 전체 신청 농가 구성비
df <- final_data %>% 
  group_by(구분) %>% 
  summarise(빈도 = n()) %>% 
  mutate(비율 = round(빈도 / sum(빈도), 2))

plot_pie_chart(df, 비율, 구분, "계절근로자 신청 농가 구성비")

##### 2.3.2 2022년 신청 농가 구성비
df <- final_data %>% 
  group_by(비고, 구분) %>% 
  summarise(빈도 = n()) %>% 
  mutate(비율 = round(빈도 / sum(빈도), 2))

plot_pie_chart(df %>% subset(비고 == 2022), 비율, 구분, "2022년 계절근로자 신청 농가 구성비")

##### 2.3.2 2023년 신청 농가 구성비
plot_pie_chart(df %>% subset(비고 == 2023), 비율, 구분, "2023년 계절근로자 신청 농가 구성비")

##### 2.3.4 경기도 2022년 신청 농가 구성비
df <- final_data %>% 
  subset(지자체명_시도 == '경기도') %>% 
  group_by(비고, 구분) %>% 
  summarise(빈도 = n()) %>% 
  mutate(비율 = round(빈도 / sum(빈도), 2))

plot_pie_chart(df %>% subset(비고 == 2022), 비율, 구분, "2022년 경기도 계절근로자 신청 농가 구성비")

##### 2.3.5 2023년 경기도 신청 농가 구성비
plot_pie_chart(df %>% subset(비고 == 2023), 비율, 구분, "2023년 경기도 계절근로자 신청 농가 구성비")

##### 2.3.6 2022년 전라남도 신청 농가 구성비
df <- final_data %>% 
  subset(지자체명_시도 == '전라남도') %>% 
  group_by(비고, 구분) %>% 
  summarise(빈도 = n()) %>% 
  mutate(비율 = round(빈도 / sum(빈도), 2))

plot_pie_chart(df %>% subset(비고 == 2022), 비율, 구분, "2022년 전라남도 계절근로자 신청 농가 구성비")

##### 2.3.7 2023년 전라남도 신청 농가 구성비
plot_pie_chart(df %>% subset(비고 == 2023), 비율, 구분, "2023년 전라남도 계절근로자 신청 농가 구성비")

rm(df) # 작업환경 최적화

### 2.4 재배 작물 별 신청 현황
##### 2.4.1 신청 농가 재배 작물 구성비
df <- final_data %>% 
  group_by(작물.종류) %>% 
  summarise(빈도 = n()) %>% 
  mutate(비율 = round(빈도 / sum(빈도), 2))

plot_pie_chart(df, 비율, 작물.종류, "계절근로자 신청 재배 작물 구성비")

##### 2.4.2 재배작물 별 신청현황
# ① 시설원예·특작
df <- final_data %>% subset(작물.종류 == "① 시설원예·특작")

plot_bar(data.frame(table(df$지자체명_시도)), Var1, Freq,
         "① 시설원예·특작 재배 농가 신청 현황", "시도", "경영체수", reorder = T)

df <- final_data %>% subset(지자체명_시도 == "강원도" & 작물.종류 == "① 시설원예·특작")

plot_bar(data.frame(table(df$지자체명_시군구)), Var1, Freq,
         "① 시설원예·특작 재배 농가 신청 현황", "시도", "경영체수", reorder = T)

# ③ 과수
df <- final_data %>% subset(작물.종류 == "③ 과수")

plot_bar(data.frame(table(df$지자체명_시도)), Var1, Freq,
         "③ 과수 재배 농가 신청 현황", "시도", "경영체수", reorder = T)

df <- final_data %>% subset(지자체명_시도 == "경상북도" & 작물.종류 == "③ 과수")

plot_bar(data.frame(table(df$지자체명_시군구)), Var1, Freq,
         "③ 과수 재배 농가 신청 현황", "시도", "경영체수", reorder = T)

rm(df) # 작업환경 최적화

### 2.5 이탈인원
##### 2.5.1 연도 별 이탈인원
df <- final_data %>% subset(전년도이탈인원 > 0)

plot_bar(data.frame(table(df$비고)), Var1, Freq,
         "연도 별 외국인 계절근로자 이탈인원", "연도", "이탈인원", reorder = F)

##### 2.5.2 지역 별 이탈인원
plot_bar(data.frame(table(df$지자체명_시도)), Var1, Freq,
         "지역 별 외국인 계절근로자 이탈인원", "시도", "이탈인원", reorder = T)

##### 2.5.3 재배작물 별 이탈인원
plot_bar(data.frame(table(df$작물.종류)), Var1, Freq,
         "재배작물 별 외국인 계절근로자 이탈인원", "작물종류", "이탈인원", reorder = T)

rm(df) # 작업환경 최적화

# 3. 통계적 검정
### 3.1 '농가 구분'
##### 3.1.1 기초통계량 산출
summary_stats <- final_data %>%
  group_by(구분) %>%
  summarise(
    평균 = round(mean(합계),2),
    표준편차 = round(sd(합계),2),
    중앙값 = median(합계),
    최소값 = min(합계),
    최대값 = max(합계)
  )

##### 3.1.2 Box-Plot 시각화
ggplot(final_data,aes(x=구분,y=합계))+
  geom_boxplot(fill='blue',color='black')+
  labs(title='농가별 배정신청인원') +
  theme_minimal()

##### 3.1.3 통계적 검정 (그룹간 차이가 유의미한지 검정)
# kruskal Wallis 검정
kw_test <- kruskal.test(합계~구분,data=final_data)
kw_test

# anova 검정(그룹 간 평균 비교)
anova_test <- aov(합계~구분,data=final_data)
summary(anova_test) # 그룹간 차이 유의함

# 사후검정
duncan_test <- duncan.test(anova_test, '구분')
duncan_test

### 3.2 작물종류별
##### 3.2.1 기초통계량 산출
summary_stats <- final_data %>%
  group_by(작물.종류) %>%
  summarise(
    평균 = round(mean(합계),2),
    표준편차 = round(sd(합계),2),
    중앙값 = median(합계),
    최소값 = min(합계),
    최대값 = max(합계)
  )

##### 3.2.2 Box-Plot 시각화
ggplot(final_data,aes(x=작물.종류,y=합계))+
  geom_boxplot(fill='blue',color='black')+
  labs(title='작물종류별 배정신청인원') +
  theme_minimal()

##### 3.2.3 통계적 검정
# kruskal Wallis 검정
kw_test <- kruskal.test(합계~작물.종류,data = final_data)
kw_test

# anova 검정 (그룹 간 평균 비교)
anova_test <- aov(합계~작물.종류,data = final_data)
summary(anova_test) #그룹간 차이 유의함

# 사후검정
duncan_test <- duncan.test(anova_test,'작물.종류')
duncan_test

### 3.3 신청이력
##### 3.3.1 Box-Plot 시각화
ggplot(final_data,aes(x=전년도활용여부,y=합계))+
  geom_boxplot(fill='blue',color='black')+
  labs(title='전년도활용여부') +
  theme_minimal()

##### 3.3.2 통계적 검정
# t-test 검정
t_test <- t.test(subset(final_data, 전년도활용여부 == 'N')$합계,
                 subset(final_data, 전년도활용여부 == 'Y')$합계)
t_test

rm(anova_test, duncan_test, kw_test, summary_stats, t_test) # 작업환경 최적화

# 4. 시각적 데이터 탐색
### 4.1 배정신청인원 기준 그룹화
##### 4.1.1 평균 배정 신청 인원이 5명 이상 (상위 지자체)
# 그룹 구성
top_data <- 
  data.frame(
    final_data %>% 
      group_by(지자체명_시군구) %>% 
      summarise(신청경영체수 = n(), 
                합계 = sum(합계),
                평균배정신청인원 = round(합계/신청경영체수, 2)) %>% 
      subset(평균배정신청인원 >= 5) %>% 
      arrange(desc(평균배정신청인원))
  )

top_df <- final_data %>% subset(지자체명_시군구 %in% top_data$지자체명_시군구)

# 재배작물 현황
plot_bar(data.frame(table(top_df$작물.종류)), Var1, Freq,
         "상위지자체 재배 작물 현황", "작물종류", "신청경영체 수", reorder = T)

# 농가 구성비
top_df <- top_df %>% 
  group_by(구분) %>% 
  summarise(개수 = n()) %>% 
  mutate(비율 = round(개수 / sum(개수), 2))

plot_pie_chart(top_df, 비율, 구분, "상위 지자체 농가 구성비")

##### 4.1.2 평균 배정 신청 인원이 2명 이하 (하위 지자체)
# 그룹 구성
bottom_data <- 
  data.frame(
    final_data %>% 
      group_by(지자체명_시군구) %>% 
      summarise(신청경영체수 = n(), 
                합계 = sum(합계),
                평균배정신청인원 = round(합계/신청경영체수, 2)) %>% 
      subset(평균배정신청인원 < 2) %>% 
      arrange(desc(평균배정신청인원))
  )

bottom_df <- final_data %>% subset(지자체명_시군구 %in% bottom_data$지자체명_시군구)

# 재배작물 현황
plot_bar(data.frame(table(bottom_df$작물.종류)), Var1, Freq,
         "하위지자체 재배 작물 현황", "작물종류", "신청경영체 수", reorder = T)

# 농가 구성비
bottom_df <- bottom_df %>% 
  group_by(구분) %>% 
  summarise(개수 = n()) %>% 
  mutate(비율 = round(개수 / sum(개수), 2))

plot_pie_chart(bottom_df, 비율, 구분, "하위 지자체 농가 구성비")

rm(top_data, top_df, bottom_data, bottom_df) # 작업환경 최적화

### 4.2 고령농경체비율 기준 그룹화
df <- final_data %>% 
  mutate(고령화수준 = 
           case_when(
             고령농경체비율 < 50 ~ "적정",
             고령농경체비율 < 60 ~ "평균",
             TRUE ~ "위험"
           ))

##### 4.2.1 2022년 고령화수준
df_2022 <- 
  df %>% subset(비고 == 2022) %>% 
  group_by(고령화수준) %>% 
  summarise(빈도 = n()) %>% 
  ungroup() %>% 
  mutate(비율 = round(빈도 / sum(빈도), 3))

# 구성비
plot_pie_chart(df_2022, 비율, 고령화수준, "고령화수준 구성비")

##### 4.2.2 2023년 고령화수준
df_2023 <- 
  df %>% subset(비고 == 2023) %>% 
  group_by(고령화수준) %>% 
  summarise(빈도 = n()) %>% 
  ungroup() %>% 
  mutate(비율 = round(빈도 / sum(빈도), 3))

# 구성비
plot_pie_chart(df_2023, 비율, 고령화수준, "고령화수준 구성비")

##### 4.2.3 위험 수준의 농경체 현황
df_worst <- 
  df %>% 
  subset(고령화수준 == "위험")

# 지역 별 농경체 수 (시도)
plot_bar(data.frame(table(df_worst$지자체명_시도)), Var1, Freq,
         "지역별 위험 수준의 농경체 현황", "시도", "신청경영체 수", reorder = T)

# 지역 별 농경체 수 (시군구)
plot_bar(data.frame(table(df_worst$지자체명_시군구)), Var1, Freq,
         "지역별 위험 수준의 농경체 현황", "시군구", "신청경영체 수", reorder = T)

# 재배작물 별 농경체 수
plot_bar(data.frame(table(df_worst$작물.종류)), Var1, Freq,
         "지역별 위험 수준의 재배 작물 현황", "작물종류", "신청경영체 수", reorder = T)

rm(df, df_2022, df_2023, df_worst) # 작업환경 최적화