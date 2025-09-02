from airflow import DAG
from operators.maple_api_operator import MapleApiOperator
import pendulum
from airflow.providers.odbc.hooks.odbc import OdbcHook
from airflow.providers.standard.operators.python import PythonOperator
from airflow.sdk import Variable

with DAG(
    dag_id ='dag_api_character_popularity',
    schedule= None,
    start_date=pendulum.datetime(2025,8,1,tz="Asia/Seoul"),
    tags= ['maple','Character Pupularity Info '],
    description="캐릭터 기본 정보 조회",
    catchup=False,
    default_args={
        'pool':'maple_pool' #개발 API의 경우 초당 최대 호출 수가 5건이기 때문에 slot이 5개인 pool을 별도로 지정하여 이용 
    }
) as dag:

    def ocid_list(**kwargs):
        hook = OdbcHook(odbc_conn_id='conn-db-mssql-maple',driver="ODBC Driver 18 for SQL Server")  #Airflow connection정보
        sql = "SELECT ocid FROM Character_list WHERE ocid NOT IN (SELECT ocid FROM character_popularity );" #이 경우, 1회성에 그치게 되지만, API 호출 제한이 있으므로, 우선 ocid가 DB에 없는 경우만 불러오기 위함
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


    Maple_Popularity_ETL_task = MapleApiOperator.partial(
        task_id='Maple_Popularity_ETL_task',
        data_nm='character/popularity',
        date = Variable.get("maple_date") #기준일인 date 파라미터는 Airflow Variable을 통해 관리 (타 DAG에도 동일한 값을 적용하기 위함)
        ).expand(
            ocid=generate_param_task.output,
            )

        










