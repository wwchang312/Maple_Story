from airflow import DAG
from operators.maple_api_operator import MapleApiOperator
import pendulum
from airflow.providers.odbc.hooks.odbc import OdbcHook
from airflow.providers.standard.operators.python import PythonOperator
import logging

with DAG(
    dag_id ='dag_api_character_basic',
    schedule= None,
    start_date=pendulum.datetime(2025,8,1,tz="Asia/Seoul"),
    tags= ['maple','Character Basic Info '],
    description="캐릭터 기본 정보 조회",
    catchup=False
) as dag:
    def ocid_list(**kwargs):
        hook = OdbcHook(odbc_conn_id='conn-db-mssql-maple',driver="ODBC Driver 18 for SQL Server")  #Airflow connection정보
        sql = "SELECT ocid FROM character_list WHERE ocid NOT IN (SELECT ocid FROM character_basic );" #이 경우, 1회성에 그치게 되지만, API 호출 제한이 있으므로, 우선 ocid가 DB에 없는 경우만 불러오기 위함
        rows= hook.get_records(sql)
        
        return rows
    
    def generate_param(param):
        data_nm=f'character/basic?ocid={param}'
        return data_nm

    ocid_list=PythonOperator(
        task_id='ocid_list',
        python_callable=ocid_list
    )

    Maple_Character_Basic_ETL_Task = MapleApiOperator.partial(
        task_id='Maple_Character_Basic_ETL_Task',
        data_nm=generate_param
    ).expand(op_kwargs=ocid_list.output)



    ocid_list >> Maple_Character_Basic_ETL_Task







