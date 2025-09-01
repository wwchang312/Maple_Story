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
        
        return [r[0] for r in rows] #ocid 리스트 형태로 적재
    

    def generate_param_list(ocids):
        return [{'data_nm':f'character/basic?ocid={x}'}for x in ocids]
 

    ocid_list_task=PythonOperator(
        task_id='ocid_list',
        python_callable=ocid_list
    )

    generate_param_task = PythonOperator(
        task_id='generate_param_task',
        python_callable=generate_param_list,
        op_args=[ocid_list_task.output]
    )

    Maple_Character_Basic_ETL_task = MapleApiOperator(
        task_id='Maple_Character_Basic_ETL_Task',
        data_nm=generate_param_task.output
        )

        










