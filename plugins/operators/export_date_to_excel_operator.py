from airflow.sdk.bases.operator import BaseOperator
from airflow.providers.odbc.hooks.odbc import OdbcHook




class export_date_to_excel_operator(BaseOperator):

    template_fields= ('schema_nm')

    def __init__(self,schema_nm:str,**kwargs):

        super().__init__(**kwargs)
        self.schema_nm = schema_nm

    def execute(self, context):

        #Mssql Server connect
        hook = OdbcHook(odbc_conn_id='conn-db-mssql-maple',driver="ODBC Driver 18 for SQL Server")  #Airflow connection정보
        sql = "SELECT v.name FROM sys.schemas s INNER JOIN sys.views v ON s.schema_id = v.schema_id WHERE s.name= ? "
        schema_nm = self.schema_nm
        
        print(hook.run(sql, parameters=(schema_nm)))