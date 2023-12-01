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







