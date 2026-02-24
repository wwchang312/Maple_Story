from airflow import DAG
from operators.maple_api_operator import MapleApiOperator
import pendulum
from airflow.providers.odbc.hooks.odbc import OdbcHook
from airflow.providers.standard.operators.python import PythonOperator
from airflow.sdk import Variable, Asset
from common.data_from_meta import data_from_meta


maple_character_info = Asset('maple_character_info')

with DAG(
    dag_id ='DAG_Mape_Character_Propensity_API',
    schedule= [maple_character_info],
    start_date=pendulum.datetime(2025,8,1,tz="Asia/Seoul"),
    tags= ['Maple','Character Stat Info', '캐릭터 성향'],
    description="캐릭터 성향 정보 조회",
    catchup=False,
    default_args={
        'pool':'maple_pool' #개발 API의 경우 초당 최대 호출 수가 5건이기 때문에 slot이 5개인 pool을 별도로 지정하여 이용 
    }
) as dag:

    ocid, view_date = data_from_meta(Asset_inlet=maple_character_info)

    Maple_Propensity_ETL_task = MapleApiOperator.partial(
        task_id='Maple_Propensity_ETL_task',
        data_nm='character/propensity').expand(
            ocid=ocid,
            date=view_date
            )

        










