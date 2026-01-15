from airflow import DAG
from operators.maple_api_operator import MapleApiOperator
import pendulum
from airflow.providers.odbc.hooks.odbc import OdbcHook
from airflow.providers.standard.operators.python import PythonOperator
from airflow.decorators import task
from airflow.sdk import Variable, Asset,AssetAlias

maple_character_asset =AssetAlias('maple_character_dataset')

with DAG(
    dag_id ='DAG_Maple_Character_Popularity_API',
    schedule= [maple_character_asset],
    start_date=pendulum.datetime(2025,12,1,tz="Asia/Seoul"),
    tags= ['Maple','인기도','Popularity'],
    description="캐릭터 인기도 정보",
    catchup=False,
    default_args={
        'pool':'maple_pool' #개발 API의 경우 초당 최대 호출 수가 5건이기 때문에 slot이 5개인 pool을 별도로 지정하여 이용 
    }
) as dag:
    @task(task_id='inlet_from_asset',
          inlets=[maple_character_asset])
    def inlet_from_asset(**kwargs):
        inlet_events = kwargs.get('inlet_events')
        events=inlet_events[maple_character_asset]
        return {
        'date' : events[-1].extra['view_date'],
        'ocid' : events[-1].extra['ocid']
        }

    asset_event=inlet_from_asset()


    Maple_Popularity_ETL_task = MapleApiOperator(
        task_id='Maple_Popularity_ETL_task',
        data_nm='character/popularity',
        date =asset_event['date'],
        ocid =asset_event['ocid']
        )

    










