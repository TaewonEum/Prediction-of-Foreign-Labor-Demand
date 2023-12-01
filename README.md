# Prediction-of-Foreign-Labor-Demand
- 프로젝트 기간: 2023.09~12(4개월)
- 활용 도구: Rstudio 기반 분석 진행, 프로젝트 마감 후 동일한 분석 프로세스를 Python 코드로 추가 제공 예정임
## Project Summary

프로젝트 기관: 출입국 외국인정책본부 외국인정보빅데이터과

### 추진 배경

- 농촌 외국인 계절근로자 도입 수요 급증
- 일손이 부족한 농가에 적절한 계절근로자 배치 필요

### 목표

- 농촌 외국인 계절근로자의 지역별 미래 인력수요 예측
- 재배품목, 재배면적별 계절 근로자 배정 허용 인원을 도출하는 알고리즘 구축
 
## Data for Analysis

- 2021~2023년 계절 근로 신청 현황
- 허용작물 분류 체계 코드
- 전국 농업경영체 등록정보
- 15~23년 계절 근로 참여자 현황
- 15~22년 농촌 농업경영체 현황
- 21년 농업경영체현황_지역별 농업인 현황
- 22년 농업경영체현황_지역별 농업인 현황

## Process

- Data cleaning
- Build Final analysis Data Set
- EDA
- build regression Model

## Data cleaning

- 중복 컬럼명 변환

[원본 데이터 셋 컬럼명]  
![image](https://github.com/eumtaewon/Prediction-of-Foreign-Labor-Demand/assets/104436260/ddb51e01-bc60-4853-948e-7a6bdd137c80)
[변경 후 데이터 셋 컬럼명]
![image](https://github.com/eumtaewon/Prediction-of-Foreign-Labor-Demand/assets/104436260/f7ef78e6-3957-461d-8799-05f3a679e3a4)


  
- 시도, 시군구명 표기 오류 변환

지자체명_시군구 컬럼에서 "담양군", "담양" 지역명이 표준화 되어 있지 않음
![image](https://github.com/eumtaewon/Prediction-of-Foreign-Labor-Demand/assets/104436260/56bc17c1-c2ac-4f0c-b3b4-9d94225bafbe)
지자체명 "담양" => "담양군"으로 일괄 변경
![image](https://github.com/eumtaewon/Prediction-of-Foreign-Labor-Demand/assets/104436260/bad44fe0-d7b6-4f92-926c-f7087694772c)
지자체명_시군구가 "청양군" 이면서 지자체명_시군구가 "충청북도"인 경우 충청남도로 일괄 변경
![image](https://github.com/eumtaewon/Prediction-of-Foreign-Labor-Demand/assets/104436260/c56afec4-3b4d-4756-a14b-ab4a523015f4)
"청양군" 시도명 "충청남도"로 일괄 변경
![image](https://github.com/eumtaewon/Prediction-of-Foreign-Labor-Demand/assets/104436260/0478d983-efd4-44de-b6d3-f09883543a85)

- 농업경영체 컬럼 표준화 작업

원본 농업경영체 컬럼에는 10자리 표준에 맞지 않고, 다양한 특수문자가 기입된 경우가 많아 정제 필요함
![image](https://github.com/eumtaewon/Prediction-of-Foreign-Labor-Demand/assets/104436260/0dcbabaa-ee32-4278-94f1-6fa637b5ba87)
정제후 농업경영체 컬럼
![image](https://github.com/eumtaewon/Prediction-of-Foreign-Labor-Demand/assets/104436260/801ce47c-0584-4da5-a27f-fde0be979e52)

- 계절근로 허용 작물 분류 체계 표준화

표준화 되어 있지 않은 허용작물 종류
![image](https://github.com/eumtaewon/Prediction-of-Foreign-Labor-Demand/assets/104436260/f294cc52-77e1-4bc6-95d5-5811156c732c)

표준화 이후 허용작물 종류(법무부 계절근로 허용작물 9종류로 표준화)
![image](https://github.com/eumtaewon/Prediction-of-Foreign-Labor-Demand/assets/104436260/5f9c593d-43da-4e77-9dd7-54aa3c6c1f5a)

- 분석 시 불필요한 특수문자 및 결측치 대치

구분, 배정신청인원, 지자체추가배정인원, 합계 등 컬럼 결측치 및 특수문자 제거

정제 완료 후 데이터 셋 예시

![image](https://github.com/eumtaewon/Prediction-of-Foreign-Labor-Demand/assets/104436260/41579d44-2c36-462b-885c-694bc49051cc)

### 데이터 셋 구축

- 농업경영체 등록 번호와 재배품목을 Primary Key로 신청현황, 참여자현황, 농업경영체 등록 등 테이블 Join 
- 각 시군구별 고령 농업인, 청년 농업인 등 파생변수 생성
- 최종 데이터 셋 R SQL DB에 저장
- 최종 데이터 셋 레코드 12,617건, 컬럼 14개의 데이터 셋 구축

- 최종 데이터 셋 테이블 정의서

![image](https://github.com/TaewonEum/Prediction-of-Foreign-Labor-Demand/assets/104436260/66016d2d-5782-4f60-bd48-ecaf8f10086d)


### EDA 및 통계적 검증

- Barplot, Pieplot, Boxplot, histogram을 활용하여 이상치 및 컬럼별 분포 확인
- T-test, Kruskal-Wallis 검정을 통한 그룹간 배정신청인원에 통계적 차이 검증

