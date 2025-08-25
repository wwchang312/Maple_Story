from airflow.models.baseoperator import BaseOperator
from airflow.hooks.base import BaseHook
from airflow.models import Variable

class MapleApiOperator(BaseOperator):

    def __init__(self,data_nm,**kwargs):
        '''
        data_nm : 호출하고자 하는 데이터의 API 종류  "/"로 구분
        예시: 캐릭터 목록 조회 api 호출시,
        data_nm = "character/list" 
        '''
        super().__init__(**kwargs)
        self.base_url = 'https://open.api.nexon.com/maplestory/v1/'
        self.data_nm = data_nm
        self.headers =  {"x-nxopen-api-key" : Variable.get("x-nxopen-api-key")}
        

    def execute(self, context):
        from plugins.common import flat_json
        from airflow.providers.microsoft.mssql.hooks.mssql import MsSqlHook

        self.log.info(f"[DEBUG] API headers: {self.headers}")

        con = self._call_api(self.base_url,self.data_nm,self.headers)
        data = flat_json(con) #json 형식 데이터 평탄화 함수

        #Mssql Server connect
        hook = MsSqlHook(mssql_conn_id='conn-db-mssql-maple') #Airflow connection정보
        sql = "EXEC SP_UPSERT_TABLE @table_nm = %s , @json =%s"
        table_nm = self.data_nm.replace('/','_')
        params=(table_nm,data)
        hook.run(sql,parameters=params)


        
    

    def _call_api(self,base_url,data_nm,headers):
        import requests
        import json

        request_url=base_url+data_nm

        response=requests.get(request_url,headers=headers)
        
        if response.status_code != 200:
            raise Exception(f"API request failed: {response.status_code}, {response.text}")
        
        contents=json.loads(response.text)

        return contents