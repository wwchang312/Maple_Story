from airflow import DAG
from operators.maple_api_operator import MapleApiOperator
import pendulum

with DAG(
    dag_id ='DAG_API_User_Achievement',
    schedule= None,
    start_date=pendulum.datetime(2025,8,1,tz="Asia/Seoul"),
    tags= ['maple','User Achievement'],
    description="메이플스토리 업적 정보",
    catchup=False
) as dag:
    
    maple_user_achievement_task = MapleApiOperator(
        task_id='maple_user_achievement_task',
        data_nm='user/achievement'
    )




