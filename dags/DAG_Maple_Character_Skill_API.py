from operators.maple_api_operator import MapleApiOperator
from airflow.sdk import Asset,DAG
from common.data_from_meta import data_from_meta
import pendulum

maple_character_info = Asset('maple_character_info')

with DAG(
    dag_id= 'DAG_Maple_Character_Skill_API',
    schedule= [maple_character_info],
    start_date= pendulum.datetime(2026,1,1,tz="Asia/Seoul"),
    tags= ['Maple','Character Skill Info','Skill'],
    description= "캐릭터 스킬 정보 조회",
    catchup= False,
    default_args= {
        'pool' : 'maple_pool' #개발 API의 경우 초당 최대 호출 수가 5건이기 때문에 slot이 5개인 pool을 별도로 지정하여 이용
    }
)as dag:

    ocid, view_date = data_from_meta(Asset_inlet=maple_character_info,Asset_inlet_nm ='maple_character_info')

    maple_character_skill_ETL_task = MapleApiOperator.partial(
        task_id='maple_character_skill_ETL_task',
        data_nm='character/skill').expand(
            ocid=ocid,
            date= view_date,
            character_skill_grade= [0,1,1.5,2,2.5,3,4,'hyperpassive','hyperactive',5,6]
            )
