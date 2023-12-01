# Prediction-of-Foreign-Labor-Demand
- 프로젝트 기간: 2023.09~12(4개월)
- 활용 도구: Rstudio, Python 
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

- Build Final analysis Data Set
- EDA
- build regression Model

## Build Final Analysis Data Set

- 외국인 계절 근로자의 수요 예측을 위한 통합 데이터 셋 구축 과정

1) 데이터 전처리

- 2021~2023년 계절 근로 신청 현황 Dataset
1-1) 주요 컬럼 결측치, 특수문자, 이상치 등 처리

![image](https://github.com/TaewonEum/Prediction-of-Foreign-Labor-Demand/assets/104436260/80d03445-9dd5-4ef2-8dd7-3e85811ec459)

1-2) 주요 컬럼 데이터 타입 오류 처리

![image](https://github.com/TaewonEum/Prediction-of-Foreign-Labor-Demand/assets/104436260/2da62f5b-4445-4a9d-8e31-baf6b3463751)

1-3) 주요 컬럼 단위 표준화

![image](https://github.com/TaewonEum/Prediction-of-Foreign-Labor-Demand/assets/104436260/0b13886d-6668-4073-80da-43dcb4788ed2)

1-4) 표기 오류 정정

![image](https://github.com/TaewonEum/Prediction-of-Foreign-Labor-Demand/assets/104436260/4d7beb6c-926c-46b6-b98e-e794c609c0ba)

- 분석 데이터 셋 구축

1-1) 데이터 셋 결합

농업경영체 등록번호를 기준으로 신청현황 데이터와 농업경영체 등록정보 데이터 결합하여 신청한 농가가 재배하는 작물 종류의 실제 경작 농지 면적 정보 결합

![image](https://github.com/TaewonEum/Prediction-of-Foreign-Labor-Demand/assets/104436260/72b555e4-532e-4229-b8ad-bd31ed6529d8)

1-2) 파생변수 생성

- 업종 구분 세분화

농지 면적 정보를 활용하여 이진화 되어 있는 레코드(농가, 법인) => 작물 종류별 소농, 중농, 대농, 법인으로 세분화

- 전년도 이력 변수 생성

참여자현황 데이터 활용, 농업경영체별 계절근로 외국인 신청 이력이 있는 지 없는 지 구분하는 신규 변수 생성

- 이탈인원

참여자현황 데이터에서 소재불명 발생일자가 존재한다면 이는 외국인 계절근로자가 이탈한것으로 간주. 농업경영체별 소재불명 발생일자 레코드 수 합산하여 신규변수 생성

- 전년대비 농업경영체 증감률 변수 생성

15~22년 농촌 농업경영체 현황 데이터를 통해 기준년도(2022,2023) 농업경영체 수의 전년대비 증감률 도출

- 지역별 고령 농업인구

2021~2022 농업경영체현황_지역별 농업인현황 데이터를 통해 2022, 2023년도 지역별 고령 농업인 비율 도출하여 고령농경체비율 변수 생성

- 최종 분석 데이터 셋

![image](https://github.com/TaewonEum/Prediction-of-Foreign-Labor-Demand/assets/104436260/ccb4d1e7-3299-4f16-a43a-bdadb8db7a81)


## EDA

- 최종 분석 데이터 셋 활용 EDA(탐색적 자료 분석) 진행하여 새로운 Insight 도출

1) 배정신청인원에 따른 지역별 차이_1

평균 배정 신청 인원이 5명 이상인 지자체의 경우 대농의 비중이 53%이고, 계절 근로 신청 재배작물의 경우 평균 배정 신청 인원이 적은 지자체 보다 편차가 상대적으로 적음

![image](https://github.com/TaewonEum/Prediction-of-Foreign-Labor-Demand/assets/104436260/57833ce1-d578-4671-a2a4-cb99b25724e8)

2) 배정신청인원에 따른 지역별 차이_2

평균 배정 신청 인원이 2명 이하인 지자체의 경우 소농의 비중이 45%로 높으며, 주로 시설원예특작, 과수를 주로 재배함

![image](https://github.com/TaewonEum/Prediction-of-Foreign-Labor-Demand/assets/104436260/fabffc70-d0c6-42cb-9a63-eeefaf4905cc)

3) 농촌 고령화 가속

2022년도 계절 근로를 신청한 지자체에서 고령농경체 비율이 40%대인 경우는 전체 28.6% 였지만, 2023년도 11.4%로 큰폭으로 감소함 이는 농업경영체 경영주의 고령화가 상당히 빠른 수준으로 진행되는 것을 시사함.

![image](https://github.com/TaewonEum/Prediction-of-Foreign-Labor-Demand/assets/104436260/c8ffc6f8-d26c-499f-8a3a-b6079e02b835)

4) 배정 신청 인원에 영향을 주는 요인

T-test, Kruskal-Wallis 검정을 통해 배정신청인원에 대한 그룹 변수에 대한 통계적 검정 진행

- 농지면적에 따른 배정신청인원 신청은 유의한 차이가 있음
- 작물 종류별 배정신청인원 신청은 유의한 차이가 있음
- 전년도 계절근로 신청 이력에 따른 배정신청인원에 차이는 유의미 함

## build regression Model

앙상블 모델을 활용하여 배정신청인원에 대한 예측 모델 구축

![image](https://github.com/TaewonEum/Prediction-of-Foreign-Labor-Demand/assets/104436260/77e7c935-4215-4591-93af-27556ae4c896)

해당 기본 모델들에 대해 Random-search, Gridsearch, Baysian Optimizer를 활용하여 파라미터 튜닝 진행

최종 예측 결과

![image](https://github.com/TaewonEum/Prediction-of-Foreign-Labor-Demand/assets/104436260/f76b5e91-6892-4480-ab2b-17b9a43ae21a)

예측 결과를 바탕으로 지자체 별 필요한 외국인 계절근로자 인력 배치 및 활용 방안 등 계획 가능

## 시사점 및 한계점

현재 법무부의 계절 근로 신청 데이터 셋은 각 지자체별 엑셀을 받아 취합하는 방식임

하지만 지자체별로 데이터 적재 방식이 표준화 되지 않아 활용될 수 없는 데이터가 많은 상황임

또한 데이터의 절대적인 양이 부족하기 때문에 정확한 분석이 실질적으로 어려운 상황임

따라서, 데이터를 통하여 지역별 계절 근로 신청자를 예측하기 위해선 지자체별 적재 방식 표준화가 필요하며

배정신청 인원 예측에 설명력이 높은 농가 소득, 좀 더 자세한 농가별 정보(재배작물, 재배면적 등)에 대한 변수에 대한 수집이 필요함
