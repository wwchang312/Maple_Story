from airflow import DAG
from operators.maple_api_operator import MapleApiOperator
import pendulum

with DAG(
    dag_id ='DAG_Maple_User_Achievement_API',
    schedule= '0 0 * * 4', #매주 목요일 수행
    start_date=pendulum.datetime(2025,8,1,tz="Asia/Seoul"),
    tags= ['Maple','User Achievement','업적'],
    description="메이플스토리 업적 정보",
    catchup=False
) as dag:
    
    Maple_User_Achievement_ETL_Task = MapleApiOperator(
        task_id='Maple_User_Achievement_ETL_Task',
        data_nm='user/achievement'
    )




