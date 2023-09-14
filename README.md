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
- 분석에 활용할 연구 자료(계절근로자제도 실태분석, 농산물 소득자료집)
  => 해당 자료를 통해 2020, 2021 코로나로 인한 비정상적인 참여 인원에 대한 분석 진행할 예정
- 수산업종 데이터(생산량 데이터 추가 제공 받으면 분석 진행 가능)

## Definition of analysis scope

- 데이터 정제가 비교적 잘된 농가에 대한 분석 및 모델 구축을 우선적으로 진행
- 어가에 대해서는 비교적 간단한 분석을 주로 수행
- 분석에 활용할 재배 품목, 재배 방법 등에 대한 범위 확정 필요-> 실무에 활용할 수 있도록 적절한 범위 선정이 필요함
- 계절 근로자 참여 인원은 정책에 따른 변화가 큼. 따라서 해당 변수를 중점으로 분석을 진행한다면 왜곡 발생 가능성이 큼(컨설팅 진행하며 협의 필요)

## Analysis Plan

- 주요 분석 내용
  1. 농어촌 종사자의 감소 및 고령화에 따른 외국인 요청 인원 상관관계 분석
  2. 재배작물, 면적에 따른 외국인 계절노동자 요청인원 상관관계 분석
  3. 외국인 배정인원에 유의미한 변수를 도출하여 최종 예측 알고리즘에 적용(Boosting 계열, Tree기반 모델 고려)
  4. 기타 분석 추후 협의

## 전국 농작물 재배 현황

![image](https://github.com/eumtaewon/Prediction-of-Foreign-Labor-Demand/assets/104436260/2a3a74ae-a197-4ed4-8d74-23b1ba34d17e)

전국 농작물 재배 면적은 지속적으로 감소하는 추세를 보이고 있음

![image](https://github.com/eumtaewon/Prediction-of-Foreign-Labor-Demand/assets/104436260/91b6c125-0001-4e5a-944e-314871dcfb9e)

전국 재배면적 현황을 살펴본 결과, 주요 광역시와 이외의 지역간의 차이가 확연하게 나타나고 있음

# 주요 도시 농작물 재배 현황

## 서울 & 부산
![image](https://github.com/eumtaewon/Prediction-of-Foreign-Labor-Demand/assets/104436260/a9f8261d-baa2-44d3-8c0d-afbc2a2a7218)

- 서울은 농지면적과 농업경영체수 모두 감소하는 추세에 있음
- 반면 부산은 재배면적은 감소하지만, 농업경영체수는 증가하는 추세를 보임

![image](https://github.com/eumtaewon/Prediction-of-Foreign-Labor-Demand/assets/104436260/19b8cb07-5571-4e91-bd3d-bfe69daf619b)

서울 부산 두 지역 모두 특정 지역구에 농지 면적이 매우 집중되어 있고, 주요 재배 작물 또한 유사한 부분이 많음

## 대구 & 인천

![image](https://github.com/eumtaewon/Prediction-of-Foreign-Labor-Demand/assets/104436260/b903fd42-9536-4f79-bdf9-8c5e0060e1f0)

- 두 광역시 모두 농업 경지는 감소하는 추세를 보이고 있음
- 대구는 농업 경영체 수는 증가 추세를 보임
- 인천광역시는 2020년부터 농업경영체 증가 추세를 보이고 있음

![image](https://github.com/eumtaewon/Prediction-of-Foreign-Labor-Demand/assets/104436260/125b05f1-2186-4a26-b89c-3d26e114a2b0)

- 대구, 인천 또한 특정 지역구에 농지면적이 집중됨
- 주요 재배 작물도 서울, 부산과 유사한 특성을 보임

## 광주 & 대전

![image](https://github.com/eumtaewon/Prediction-of-Foreign-Labor-Demand/assets/104436260/0567bda5-1c95-4278-a73a-bbd1d94ec344)

- 두 광역시 모두 농지면적은 감소하는 추세임
- 광주광역시의 경우 농업경영체 변동이 다른 주요 도시에 비해 큰 편
- 대전광역시는 20년 이후부터 농업 경영체가 증가하는 추세를 보임
