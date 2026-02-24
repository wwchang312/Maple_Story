from airflow import DAG
from plugins.operators.maple_api_operator import MapleApiOperator
import pendulum
from airflow.providers.odbc.hooks.odbc import OdbcHook
from airflow.providers.standard.operators.python import PythonOperator
from airflow.sdk import Variable, Asset
from common.data_from_meta import data_from_meta

maple_character_info = Asset('maple_character_info')

with DAG(
    dag_id ='DAG_Maple_Character_Ability_API',
    schedule= [maple_character_info],
    start_date=pendulum.datetime(2026,1,1,tz="Asia/Seoul"),
    tags= ['Maple','Character Ability Info','Ability'],
    description="캐릭터 어빌리티 정보",
    catchup=False,
    default_args={
        'pool':'maple_pool' #개발 API의 경우 초당 최대 호출 수가 5건이기 때문에 slot이 5개인 pool을 별도로 지정하여 이용 
    }
) as dag:

    ocid, view_date = data_from_meta(Asset_inlet=maple_character_info,Asset_inlet_nm ='maple_character_info')

    maple_character_ability_ETL_task = MapleApiOperator.partial(
        task_id='maple_character_ability_ETL_task',
        data_nm='character/ability').expand(
            ocid=ocid,
            date = view_date
            )











