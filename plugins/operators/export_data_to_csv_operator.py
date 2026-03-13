from airflow.sdk.bases.operator import BaseOperator
from airflow.providers.odbc.hooks.odbc import OdbcHook
import csv

class export_data_to_csv_operator(BaseOperator):

    template_fields= ('schema_nm')

    def __init__(self,schema_nm:str,**kwargs):

        super().__init__(**kwargs)
        self.schema_nm = schema_nm

    def execute(self, context):

        #Mssql Server connect
        hook = OdbcHook(odbc_conn_id='conn-db-mssql-maple',driver="ODBC Driver 18 for SQL Server")  #Airflow connection정보
        sql = "SELECT v.name FROM sys.schemas s INNER JOIN sys.views v ON s.schema_id = v.schema_id WHERE s.name= ? "
        schema_nm = self.schema_nm
        
        #반출을 위한 VIEW 목록 조회

        rows=hook.get_records(sql,parameters=(schema_nm))
        
        lis=[]
        
        for row in rows:
            lis.append(row[0])

        print(f'다음의 뷰를 csv로 반출합니다. {lis}')

        # 뷰별 csv 반출



        for i in lis:
            sql = f"SELECT * FROM {self.schema_nm}.{i}"
            conn = hook.get_conn()
            cursor = conn.cursor()
            cursor.execute(sql)
            
            columns = [columns[0] for columns in cursor.description]

            with open(f'/opt/airflow/output/{i}.csv','w',newline='',encoding='utf-8') as f:
                writer = csv.writer(f)
                writer.writerow(columns)
                rows = cursor.fetchall()
                if not rows:
                    break
                writer.writerows(rows)
            cursor.close()
            conn.close()


        