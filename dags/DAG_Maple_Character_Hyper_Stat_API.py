from airflow import DAG
from operators.maple_api_operator import MapleApiOperator
import pendulum
from airflow.providers.odbc.hooks.odbc import OdbcHook
from airflow.providers.standard.operators.python import PythonOperator
from airflow.sdk import Variable, Asset,task_group,task

# from common.data_from_meta import data_from_meta 태스크 데코레이터 공통화 함수화 로직 연구중

maple_character_info = Asset('maple_character_info')

with DAG(
    dag_id ='DAG_Maple_Character_Hyper_Stat_API',
    schedule= [maple_character_info],
    start_date=pendulum.datetime(2025,8,1,tz="Asia/Seoul"),
    tags= ['Maple','Character Stat Info', '하이퍼 스탯'],
    description="캐릭터 하이퍼스탯 정보 조회",
    catchup=False,
    default_args={
        'pool':'maple_pool' #개발 API의 경우 초당 최대 호출 수가 5건이기 때문에 slot이 5개인 pool을 별도로 지정하여 이용 
    }
) as dag:
    @task_group(group_id ='get_meta')
    def get_meta():
        # get ocid data from meta
        @task(task_id='ocid_from_mata',
            inlets=[maple_character_info])
        def ocid_from_meta(**kwargs):
            inlet_events = kwargs.get('inlet_events')
            events = inlet_events[Asset('maple_character_info')]
            ocid = events[-1].extra['ocid']
            return ocid
        
        # get view_date data from meta
        @task(task_id = 'view_date_from_meta',
            inlets=[maple_character_info])
        def view_date_from_meta(**kwargs):
            inlet_events = kwargs.get('inlet_events')
            events = inlet_events[Asset('maple_character_info')]
            view_date = events[-1].extra['view_date']
            return view_date

        ocid = ocid_from_meta()
        view_date = view_date_from_meta()
        
        return ocid, view_date


    ocid, view_date =get_meta()

    maple_hyper_stat_ETL_task = MapleApiOperator.partial(
        task_id='maple_hyper_stat_ETL_task',
        data_nm='character/hyper-stat').expand(
            ocid=ocid,
            date=view_date
            )











