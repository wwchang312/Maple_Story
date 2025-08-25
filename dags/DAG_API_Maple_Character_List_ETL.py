from airflow import DAG
from airflow.providers.standard.decorators.python import PythonOperator
import pendulum

with DAG(
    dag_id ='dags_Maple_API_ETL',
    schedule= None,
    start_date=pendulum.datetime(2025,8,1,tz="Asia/Seoul"),
    catchup=False
) as dag:
    
    Test_Api = PythonOperator(
        task_id='test_api'
    )


    Test_Api