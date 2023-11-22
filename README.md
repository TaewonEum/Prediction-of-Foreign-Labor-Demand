# Prediction-of-Foreign-Labor-Demand
- 프로젝트 기간: 2023.09~
- 활용 도구: Rstudio 기반 분석 진행, 프로젝트 마감 후 동일한 분석 프로세스를 Python 코드로 추가 제공 예정임
## Project Summary

프로젝트 기관: 출입국 외국인정책본부 외국인정보빅데이터과

### 추진 배경

- 농촌 외국인 계절근로자 도입 수요 급증
- 지자체별 작물별, 재배면적에 따른 계절 근로자 배정 필요

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

## Data Analysis Process

- Data cleaning
- Creating Derived Variables
- Build Final analysis Data Set
- EDA
- build regression Model

## Data cleaning & Data Set Construction

- 총 7개의 Data Table 전처리 진행
  
### 주요 전처리 Process

- 시도, 시군구명 표기 오류 변환
- 중복 컬럼명 변환
- 농업경영체 컬럼 표준화 작업
- 계절근로 허용 작물 분류 체계 표준화
- 분석 시 불필요한 특수문자 제거
- 재배작물별 농지면적에 따른 소농, 중농, 대농 구분 컬럼 추가

### 데이터 셋 구축

- 농업경영체 등록 번호와 재배품목을 Primary Key로 신청현황, 참여자현황, 농업경영체 등록 등 테이블 Join 
- 각 시군구별 고령 농업인, 청년 농업인 등 파생변수 생성
- 최종 데이터 셋 R SQL DB에 저장
- 최종 데이터 셋 레코드 12,617건, 컬럼 14개의 데이터 셋 구축

### EDA 및 통계적 검증

- Barplot, Pieplot, Boxplot, histogram을 활용하여 이상치 및 컬럼별 분포 확인
- T-test, Kruskal-Wallis 검정을 통한 그룹간 배정신청인원에 통계적 차이 검증

