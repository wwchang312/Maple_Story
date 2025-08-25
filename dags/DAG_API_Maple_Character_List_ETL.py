from airflow import DAG
from operators import MapleApiOperator
import pendulum

with DAG(
    dag_id ='DAG_API_Maple_Character_List_ETL',
    schedule= None,
    start_date=pendulum.datetime(2025,8,1,tz="Asia/Seoul"),
    tags= ['maple','character list'],
    description="메이플스토리 계정별 캐릭터 목록 추출",
    catchup=False
) as dag:
    
    Maple_character_list_ETL_Task = MapleApiOperator(
        task_id='Maple_character_list_ETL_Task',
        data_nm='character/list'
    )


    Maple_character_list_ETL_Task


    