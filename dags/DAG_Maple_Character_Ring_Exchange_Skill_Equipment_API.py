from operators.maple_api_operator import MapleApiOperator
from airflow.sdk import Asset,DAG
from common.data_from_meta import data_from_meta
from airflow.providers.standard.operators.branch import BaseBranchOperator
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

    class CheckBranchOperator(BaseBranchOperator):   #특수 스킬 반지 개편으로 인한, 신규 조회 API 추가 반영
        def choose_branch(self, context):
            for v_date in view_date:
                if v_date < '2026-03-19':
                    return 'maple_character_ring_exchange_skill_equipment_ETL_task'
                else:
                    return 'maple_character_ring_reserve_skill_equipment_ETL_task'

    
    maple_character_ring_exchange_skill_equipment_ETL_task = MapleApiOperator.partial(
        task_id='maple_character_ring_exchange_skill_equipment_ETL_task',
        data_nm='character/ring-exchange-skill-equipment').expand(
            ocid=ocid,
            date= view_date
            )

    maple_character_ring_reserve_skill_equipment_ETL_task = MapleApiOperator.partial(
        task_id='maple_character_ring_reserve_skill_equipment_ETL_task', 
        data_nm='character/ring-reserve-skill-equipment').expand(
            ocid=ocid,
            date= view_date
            )
    
    check_branch_task = CheckBranchOperator(task_id='check_branch_task')

    check_branch_task >> [maple_character_ring_exchange_skill_equipment_ETL_task, maple_character_ring_reserve_skill_equipment_ETL_task]
