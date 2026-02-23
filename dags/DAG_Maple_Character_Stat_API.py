from airflow import DAG
from plugins.operators.maple_api_operator import MapleApiOperator
import pendulum
from airflow.providers.odbc.hooks.odbc import OdbcHook
from airflow.providers.standard.operators.python import PythonOperator
from airflow.sdk import Variable, Asset
from airflow.decorators import task

maple_character_info = Asset('maple_character_info')

with DAG(
    dag_id ='DAG_Maple_Character_Stat_API',
    schedule= [maple_character_info],
    start_date=pendulum.datetime(2025,8,1,tz="Asia/Seoul"),
    tags= ['Maple','Character Stat Info','캐릭터 종합 능력치 정보'],
    description="캐릭터 종합 능력치 정보",
    catchup=False,
    default_args={
        'pool':'maple_pool' #개발 API의 경우 초당 최대 호출 수가 5건이기 때문에 slot이 5개인 pool을 별도로 지정하여 이용 
    }
) as dag:
    @task(task_id='ocid_from_mata',
          inlets=[maple_character_info])
    def ocid_from_meta(**kwargs):
        inlet_events = kwargs.get('inlet_events')
        events = inlet_events[Asset('maple_character_info')]
        ocid = events[-1].extra['ocid']
        return ocid
    
    @task(task_id = 'view_date_from_meta',
          inlets=[maple_character_info])
    def view_date_from_meta(**kwargs):
        inlet_events = kwargs.get('inlet_events')
        events = inlet_events[Asset('maple_character_info')]
        view_date = events[-1].extra['view_date']
        return view_date


    Maple_Stat_ETL_task = MapleApiOperator.partial(
        task_id='Maple_Stat_ETL_task',
        data_nm='character/stat').expand(
            ocid = ocid_from_meta(),
            date = view_date_from_meta()
            )

        










