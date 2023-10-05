# Prediction-of-Foreign-Labor-Demand
- 프로젝트 기간: 2023.09~
- 활용 도구: Rstudio 기반 분석 진행, 프로젝트 마감 후 동일한 분석 프로세스를 Python 코드로 추가 제공 예정임
## Project Summary

프로젝트 기관: 출입국 외국인정책본부 외국인정보빅데이터과

### 추진 배경

- 농어촌 외국인 계절근로자 도입 수요 급증
- 농업 및 어업 사업의 계절성을 고려한 예측 모델 개발 필요

### 목표

- 농어촌 외국인 계절근로자의 지역별, 시기별 미래 인력수요 예측
 
## Data for Analysis

- 지역별 계절 근로자 신청현황, 지역별 농업경영체 현황 등(11개의 Dataset)
- 분석에 활용할 연구 자료(계절근로자제도 실태분석, 농산물 소득자료집) 제공 받음

## Data Analysis Process

- Data cleaning & Data Set Construction
- Derivation of key variables
- Apply prediction model
- Result interpretation

## Data cleaning & Data Set Construction

제공 받은 데이터를 연도, 시군구, 지자체별로 결합하여 최종 예측 모델에 활용할 수 있는 형태로 구축하는 작업 진행

### 1번 데이터 정제

![image](https://github.com/eumtaewon/Prediction-of-Foreign-Labor-Demand/assets/104436260/10614b9f-ba0e-40d1-8a89-c10b6bbb33ff)

- 배정신청인원 특수문자, 결측값=> 0으로 대체 후 컬럼 타입 numeric 변경

- 작물종류 컬럼 56개에서 9개의 카테고리로 값 변경

- 이력여부 컬럼 26개의 카테고리에서 "있음", "없음" 두 가지로 값 변경


![image](https://github.com/eumtaewon/Prediction-of-Foreign-Labor-Demand/assets/104436260/6016b552-0e11-402f-9ed2-3dc59a266016)

최종 분석용 데이터 셋은 위와 같이 연도, 시도, 시군구, 신청 경영체 수, 배정 신청 인원, 작년 신청 이력 비율 6개의 컬럼을 가진 데이터프레임 구축

### 2번 데이터 정제

![image](https://github.com/eumtaewon/Prediction-of-Foreign-Labor-Demand/assets/104436260/824601bc-3e97-49fc-af5c-7f8e70c1b79d)

- 연도별 배정, 운영, 이탈 정보를 컬럼명으로 변경

- 데이터 셋 내에 있는 결측값 0으로 모두 대체

- 농업 분야의 데이터 셋만 추출하여 분석 데이터 셋 구축

![image](https://github.com/eumtaewon/Prediction-of-Foreign-Labor-Demand/assets/104436260/8a250db4-8c20-40bd-ad6b-d44013dd3e6c)

### 3번 데이터 정제

![image](https://github.com/eumtaewon/Prediction-of-Foreign-Labor-Demand/assets/104436260/e7016208-2327-43b2-992e-a94fcfdaa838)

- 농업경영체에 참여한 인원들만 추출
- 계절근로자에 해당하는 MOU, 결혼이민자 참여자 추출
- 연도, 시도, 시군구별 성실재입국자 합계 컬럼 생성
- 추가적으로 지자체별 근로자 중 결혼이민자 비율, MOU 근로자 비율 추가 예정임

### 6번 데이터 & 12번 데이터 정제

- 6번 데이터(농업경영체 테이블)
![image](https://github.com/eumtaewon/Prediction-of-Foreign-Labor-Demand/assets/104436260/391dbb2b-1b44-4455-bbe2-e75f7fe4887a)

- 12번 데이터(법무부 허용작물 리스트)
![image](https://github.com/eumtaewon/Prediction-of-Foreign-Labor-Demand/assets/104436260/2d83dfe2-505f-437b-adc4-23ff2132dcff)

- 농업경영체 테이블에서 번호 컬럼에서 (등록)인 업체들만 추출
- 농업경영체 테이블에서 한 컬럼에 쓰여진 주소 텍스트를 시도와 시군구 두개로 나누어 줌
- 농업경영체 테이블의 재배품목과 법무부의 적용작물 컬럼을 맵핑하여 허용작물에 해당하는 컬럼들 생성해줌, 컬럼 값들은 경영체 수를 의미
- 허용 작물별로 재배 면적에 따라 허용 인원 기준이 정해져 있음, 지자체별로 허용 작물 면적당 허용 인원을 구하고 최종적으로 지자체별로 합쳐줌
  
### 10번 데이터

![image](https://github.com/eumtaewon/Prediction-of-Foreign-Labor-Demand/assets/104436260/680d8ac1-fabf-469c-bfa4-662030dae071)

- 2015~2023년 4월까지의 지자체별 내국인 인구와 외국인 인구를 통해 외국인 비율을 산출하여 새로운 컬럼을 생성함
- 지자체명 중 강서구, 고성군, 남구, 동구, 북구, 서구, 중구 해당 지자체들은 지역명이 중복되기 때문에 구분자가 필요함
