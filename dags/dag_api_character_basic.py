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
    catchup=False,
    default_args={
        'pool':'maple_pool' #개발 API의 경우 초당 최대 호출 수가 5건이기 때문에 slot이 5개인 pool을 별도로 지정하여 이용 
    }
) as dag:
    '''
    api 호출시, 2023년 12월21일 데이터부터 조회가 가능함. 단, 계정 정보 조회 API는 기간과 무관하게 조회가된다.
    캐릭터 정보를 조회할 때, ocid를 파라미터로 입력해야하는데, 현재 len(ocid)가 32인 값과 64인 값 두 종류가 있다.
    이때, 파라미터로 len(ocid) =64인 파라미터를 던지면, Invalid ID 오류가 발생한다.
    이는 len(ocid)=32 인 캐릭터들이 데이터 조회 기준이 되는 2023년 12월21일 이후 생성된 캐릭터임을 짐작할 수 있다.
    따라서 ocid_list에서 len(ocid)=64인 데이터는 대상에서 제외한다.
    '''
    def ocid_list(**kwargs):
        hook = OdbcHook(odbc_conn_id='conn-db-mssql-maple',driver="ODBC Driver 18 for SQL Server")  #Airflow connection정보
        sql = "SELECT ocid FROM character_list WHERE ocid NOT IN (SELECT ocid FROM character_basic ) AND LEN(ocid)=32;" #이 경우, 1회성에 그치게 되지만, API 호출 제한이 있으므로, 우선 ocid가 DB에 없는 경우만 불러오기 위함
        rows= hook.get_records(sql)
        
        return [r[0] for r in rows] #ocid 리스트 형태로 적재
    

    def generate_param_list(ocids):
        return [f'ocid={x}'for x in ocids]
 

    ocid_list_task=PythonOperator(
        task_id='ocid_list',
        python_callable=ocid_list
    )

    generate_param_task = PythonOperator(
        task_id='generate_param_task',
        python_callable=generate_param_list,
        op_args=[ocid_list_task.output]
    )


    Maple_Character_Basic_ETL_task = MapleApiOperator.partial(
        task_id='Maple_Character_Basic_ETL_Task',
        data_nm='character/basic'
        ).expand(param1=generate_param_task.output)

        










