# 메이플스토리 Open API를 활용한 Pipeline 구축

## 프로젝트 목표

Nexon Open API를 통해 제공하는 Maple Story의 캐릭터 데이터를 수집하여 로컬 PC에 저장하고, 
BI 툴에서 활용할 수 있도록 파이프라인 구축

현재 메이플스토리 캐릭터 정보를 제공하는 여러 웹 사이트가 있지만 직접 원하는 형태로 데이터를 수집하고 가공할 수 있는 환경 구축을 목표로 함.

## 기술 스택


- Lanaguagee: Python, SQL
- Database: MSSQL
- Environment: WSL2


## 시스템 아키텍처


[이미지]


## 주요 기능
- API 호출 및 데이터 수집 (maple_api_operator.py)
- 데이터 저장을 위한 테이블 생성 (SP_CREATE_CHARACTER_TABLE)
- DAG Asset 의존성을 활용한 캐릭터 정보 일괄 호출
- 데이터 적재(SP_INSERT_DATA)

## 데이터 처리 흐름 (Pipeline)


[이미지]


## 주의사항


*Airflow 환경에 odbc provider 설치 필수*

## Demo


### 1. 테이블 생성 (SP_CREATE_CHARACTER_TABLE) 실행

#### 로직
- SP_CREATE_CHARACTER_TABLE.sql

#### 필수 설정사항

- 초기변수
  - @schema_nm : 타겟 테이블 스키마 명
  - @pub_schema_nm : 추출용 View 스키마 명
 
#### 실행 방법

- 프로시저 생성 후, 실행 필요

-------

[이미지]


- 테이블 정의 규칙
  - 최상위 key : 컬럼
  - 최상위 value : 값 

[이미지]


#### 참고 코드
  - *sql/SP_CREATE_CHARACTER_TABLE.sql*



### 2. 데이터 적재 프로시저 생성 (SP_INSERT_DATA)

#### 로직
- SP_INSERT_DATA.sql

#### 필수 설정사항

- 초기변수
  - @schema_nm : 타겟 테이블 스키마 명

#### 실행 방법

- 프로시저 생성 후 DAG 실행
  
#### 참고 코드
  - *sql/SP_INSERT_DATA.sql*


### 3. Airflow 변수설정


- API key 변수 등록 (x-nxopen-api-key)

  
[이미지]


- DB 접속정보 등록 (conn-db-mssql-maple)

  
[이미지]


- pool 설정 (필요시 변경)


[이미지]


### 4. DAG_Maple_Character_List_API DAG 스케줄 및 unpause 상태 확인

- 해당 DAG으로 받아온 Character_list를 이용하여 계정내 존재하는 캐릭터 id를 확인하고 캐릭터 정보를 받아올 수 있음.
  
- 해당 태스크가 선행되어야 후행 캐릭터 정보 수집 DAG 정상 수행 가능


[이미지]


- DAG 정상 실행 시, vw_character_list로 다음과 같이 계정내 캐릭터 List 조회 가능
[이미지]



### 5. DAG 실행 (DAG_Maple_Character_Basic_API)

- "DAG_Maple_Character_Basic_API" DAG 실행시, Asset 의존 관계로 나머지 API 호출 DAG 실행
- 캐릭터명 입력
  - vw_character_list 뷰에서 입력된 캐릭터 명에 해당하는 ocid 반환
  - 없으면 skip
- 조회 시작일/종료일 : default 값은 today()

[이미지]

- DB 정상 적재시,

- Raw 테이블


[이미지]

*챌린저스서버 종료로 인한 캐릭터 ocid 변경으로 중복된 캐릭터 명이 발생함*


- History 테이블


[이미지] 

*'렌'은 정상적으로 들어왔지만 '아크메이지(썬,콜)'의 경우에는 정상적으로 들어오지 못함.*

*이는 챌린저스서버 종료로 캐릭터의 ocid가 변경되면서 발생함*

*DB에 입력되는 값은 character_list에 담긴 최신의 캐릭터명에 해당하는 ocid를 가져와 추가하기 때문*

*이로인해 챌린저스 서버 종료후 리프를 완료한 시점인 4월15일 데이터부터 정상적으로 조회가 됨*


#### 참고 코드
- dags/DAG_Maple_Character_Basic_API.py

### 6. 데이터 가공 (데이터 조회 View 생성)

- Raw테이블의 JSON 컬럼을 파싱하여 View로 조회

- 각 View는 외부 반출용 스키마에 생성 (pub)

- DAG_Data_Export_to_Excel_API DAG 스케줄링을 통해 디렉토리로 추출

#### View 예시

[이미지]

- 위와 같이 Raw 테이블에서 JSON 형태 데이터를 파싱하여, 각각 부위별 장비아이템 조회 가능

- 참고 코드
  - *dags/DAG_Data_Export_to_Excel_API*
  - *plugins/operators/export_data_to_csv_operator.py*

### 7. 데이터 추출

- 다음과 같이 로컬PC의 디렉토리로 추출된 것을 확인할 수 있음

[이미지]
