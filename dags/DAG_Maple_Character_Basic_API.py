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
    start_date=pendulum.datetime(2025,12,1,tz="Asia/Seoul"),
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
    #extract character ocid 
    def get_ocid_list(**kwargs):
        """
        DAG Params 입력 여부에 따른 호출 대상 캐릭터 선별
        DAG_Maple_Character_List_API로 호출한 캐릭터 목록이 호출 대상이 된다.
        params에 입력된 캐릭터 이름을 기준으로 vw_character_list에서 해당 캐릭터의 ocid를 가져온다. 
        아무런 이름이 입력되지 않으면, vw_character_list에 있는 전체가 대상이 된다.
        """
        char_nm=kwargs.get('params').get('character_name')

        hook = OdbcHook(odbc_conn_id='conn-db-mssql-maple',driver="ODBC Driver 18 for SQL Server")  #Airflow connection정보
        sql = "SELECT ocid FROM vw_character_list WHERE 1=1" 
        
        if char_nm :
            char_nm=[char_nm]
            char_nm_lis = ",".join(["?"] * len(char_nm))
            sql += f' AND character_name IN ({char_nm_lis})'

        rows= hook.get_records(sql,parameters=char_nm)
        
        return [r[0] for r in rows] #ocid 리스트 형태로 적재
    
    #make ocid list
    def generate_param_list(ocids):
        return [f'{x}'for x in ocids]
    
    #view date
    def task_run_from_to_retriever(data_interval_end=None,**kwargs):
        from_date = kwargs.get('params').get('from_date') or kwargs.get(data_interval_end)
        to_date = kwargs.get('param').get('to_date') or kwargs.get(data_interval_end)

        if isinstance(from_date,str):
            from_date = datetime.strptime(from_date,"%Y-%m-%d")
        if isinstance(to_date,str):
            to_date = datetime.strptime(to_date,"%Y-%m-%d")

        print(f'{from_date}부터 {to_date}까지 정보를 조회합니다.')

        return [(from_date + timedelta(days=i)).strftime("%Y-%m-%d") for i in range((to_date-from_date).days +1)]


    ocid_list_task=PythonOperator(
        task_id='ocid_list',
        python_callable=get_ocid_list
    )

    generate_param_task = PythonOperator(
        task_id='generate_param_task',
        python_callable=generate_param_list,
        op_args=[ocid_list_task.output]
    )

    view_date_task = PythonOperator(
        task_id ='view_date_task',
        python_callable=task_run_from_to_retriever
    )

    Maple_Character_Basic_ETL_task = MapleApiOperator.partial(
        task_id='Maple_Character_Basic_ETL_Task',
        data_nm='character/basic',
        ).expand(
            ocid=generate_param_task.output,
            date=view_date_task.output
            )








