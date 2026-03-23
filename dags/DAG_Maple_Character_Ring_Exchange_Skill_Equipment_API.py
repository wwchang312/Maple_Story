from operators.maple_api_operator import MapleApiOperator
from airflow.sdk import Asset,DAG
from common.data_from_meta import data_from_meta
from airflow.decorators import task
import pendulum


maple_character_info = Asset('maple_character_info')

with DAG(
    dag_id= 'DAG_Maple_Character_Ring_Exchange_Skill_Equipment_API',
    schedule= [maple_character_info],
    start_date= pendulum.datetime(2026,1,1,tz="Asia/Seoul"),
    tags= ['Maple','Ring Exchgange'],
    description= "링 익스체인지 스킬 등록 정보 조회",
    catchup= False,
    default_args= {
        'pool' : 'maple_pool' #개발 API의 경우 초당 최대 호출 수가 5건이기 때문에 slot이 5개인 pool을 별도로 지정하여 이용
    }
)as dag:

    ocid, view_date = data_from_meta(Asset_inlet=maple_character_info,Asset_inlet_nm ='maple_character_info')

    @task
    def sep_date(view_date):
        return {
            'exchange_date' : [v_date for v_date in view_date if v_date < '2026-03-19'],
            'reserved_date' : [v_date for v_date in view_date if v_date >= '2026-03-19']
        }

    split_date = sep_date(view_date)
    
    maple_character_ring_exchange_skill_equipment_ETL_task = MapleApiOperator.partial(
        task_id='maple_character_ring_exchange_skill_equipment_ETL_task',
        data_nm='character/ring-exchange-skill-equipment').expand(
            ocid=ocid,
            date=split_date['exchange_date']
            )

    maple_character_ring_reserve_skill_equipment_ETL_task = MapleApiOperator.partial(
        task_id='maple_character_ring_reserve_skill_equipment_ETL_task', 
        data_nm='character/ring-reserve-skill-equipment').expand(
            ocid=ocid,
            date= split_date['reserved_date']
            )
    
