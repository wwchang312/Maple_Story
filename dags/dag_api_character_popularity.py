from airflow import DAG
from operators.maple_api_operator import MapleApiOperator
import pendulum
from airflow.providers.odbc.hooks.odbc import OdbcHook
from airflow.providers.standard.operators.python import PythonOperator
from airflow.sdk import Variable, Asset

maple_character_dataset =Asset('maple_character_dataset')

with DAG(
    dag_id ='DAG_Maple_Character_Popularity_API',
    schedule= [maple_character_dataset],
    start_date=pendulum.datetime(2025,8,1,tz="Asia/Seoul"),
    tags= ['Maple','인기도','Popularity'],
    description="캐릭터 인기도 정보",
    catchup=False,
    default_args={
        'pool':'maple_pool' #개발 API의 경우 초당 최대 호출 수가 5건이기 때문에 slot이 5개인 pool을 별도로 지정하여 이용 
    }
) as dag:

    def ocid_list(**kwargs):
        hook = OdbcHook(odbc_conn_id='conn-db-mssql-maple',driver="ODBC Driver 18 for SQL Server")  #Airflow connection정보
        sql = "SELECT ocid FROM character_list where world_name='챌린저스4' ;" #일일 호출 제한이 있기 때문에 현재 지속적으로 정보 변경이 있는 캐릭터를 대상으로 변경
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

        










