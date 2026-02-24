from plugins.operators.maple_api_operator import MapleApiOperator
import pendulum
from airflow.sdk import Asset,DAG
from common.data_from_meta import data_from_meta

maple_character_info = Asset('maple_character_info')

with DAG(
    dag_id ='DAG_Maple_Character_Cashitem_Equipment_API',
    schedule= [maple_character_info],
    start_date=pendulum.datetime(2026,1,1,tz="Asia/Seoul"),
    tags= ['Maple','Character Cashitem info','Cashitem','장착 캐시아이템 정보'],
    description="캐릭터 장착 캐시아이템 정보",
    catchup=False,
    default_args={
        'pool':'maple_pool' #개발 API의 경우 초당 최대 호출 수가 5건이기 때문에 slot이 5개인 pool을 별도로 지정하여 이용 
    }
) as dag:

    ocid, view_date= data_from_meta(Asset_inlet=maple_character_info,Asset_inlet_nm ='maple_character_info')

    maple_character_cashitem_equipment_ETL_task = MapleApiOperator.partial(
        task_id='maple_character_cashitem_equipment_ETL_task',
        data_nm='character/cashitem-equipment').expand(
            ocid= ocid,
            date= view_date
            )











