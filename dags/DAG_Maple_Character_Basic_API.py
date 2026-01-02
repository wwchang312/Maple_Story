from airflow import DAG
from operators.maple_api_operator import MapleApiOperator
import pendulum
from airflow.providers.odbc.hooks.odbc import OdbcHook
from airflow.providers.standard.operators.python import PythonOperator
from airflow.sdk import Variable, Param
from datetime import datetime, timedelta

with DAG(
    dag_id ='DAG_Maple_Character_Basic_API',
    schedule= None,
    start_date=pendulum.datetime(2025,8,1,tz="Asia/Seoul"),
    catchup=False,
    tags= ['Maple','Character Basic Info','캐릭터 기본 정보'],
    description="캐릭터 기본 정보 조회",
    default_args={
        'pool':'maple_pool' #개발 API의 경우 초당 최대 호출 수가 5건이기 때문에 slot이 5개인 pool을 별도로 지정하여 이용 
    },
    params={"character_name":Param(
                    type = ["null","string"],
                    title = "호출 대상 캐릭터명",
                    description = "캐릭터 이름 입력"
            ),
            "from_date" : Param(
                    type = ["null","string"],
                    format = "date",
                    title = "조회 시작일",
                    description= "조회 기준일 시작일자"
            ),
            "to_date" : Param(
                    type = ["null","string"],
                    format = "date",
                    title = "조회 종료일",
                    description= "조회 기준일 마지막일자"
            )
    }
) as dag:

    def ocid_list(**kwargs):
        """
        DAG Params 입력 여부에 따른 호출 대상 캐릭터 선별
        DAG_Maple_Character_List_API로 호출한 캐릭터 목록이 호출 대상이 된다.
        params에 입력된 캐릭터 이름을 기준으로 vw_character_list에서 해당 캐릭터의 ocid를 가져온다. 
        아무런 이름이 입력되지 않으면, vw_character_list에 있는 전체가 대상이 된다.
        """
        hook = OdbcHook(odbc_conn_id='conn-db-mssql-maple',driver="ODBC Driver 18 for SQL Server")  #Airflow connection정보
        sql = "SELECT ocid FROM vw_character_list where 1=1;" 
        rows= hook.get_records(sql)
        
        return [r[0] for r in rows] #ocid 리스트 형태로 적재
    

    def generate_param_list(ocids):
        return [f'ocid={x}'for x in ocids]
 

    ocid_list_task=PythonOperator(
        task_id='ocid_list',
        python_callable=ocid_list
    )

    generate_param_task = PythonOperator(
        task_id='generate_param_task',
        python_callable=generate_param_list,
        op_args=[ocid_list_task.output]
    )


    Maple_Character_Basic_ETL_task = MapleApiOperator.partial(
        task_id='Maple_Character_Basic_ETL_Task',
        data_nm='character/basic',
        date = "{{ds}}"
        ).expand(
            ocid=generate_param_task.output,
            )








