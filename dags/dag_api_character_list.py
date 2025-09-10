from airflow import DAG
from operators.maple_api_operator import MapleApiOperator
import pendulum

with DAG(
    dag_id ='dag_api__character_list',
    schedule= None,
    start_date=pendulum.datetime(2025,8,1,tz="Asia/Seoul"),
    tags= ['maple','character list'],
    description="메이플스토리 계정별 캐릭터 목록 추출",
    catchup=False
) as dag:
    
    maple_character_list_ETL_task = MapleApiOperator(
        task_id='maple_character_list_ETL_task',
        data_nm='character/list'
    )


    