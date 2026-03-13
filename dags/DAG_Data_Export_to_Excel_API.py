from operators.export_data_to_excel_operator import export_data_to_excel_operator
import pendulum
from airflow.sdk import DAG

with DAG(
    dag_id= 'DAG_Data_Export_to_Excel_API',
    schedule= None, #'0 0 * * *', #매일 자정 실행
    start_date= pendulum.datetime(2026,3,1,tz="Asia/Seoul"),
    tags= ['Maple','Excel','Export'],
    description= "데이터 엑셀 및 외부 방출 DAG",
    catchup= False
)as dag:

    exoprt_data_to_excel_task = export_data_to_excel_operator(
        task_id ='exoprt_data_to_excel_task',
        schema_nm='pub'
    )