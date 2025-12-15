from airflow.sdk.bases.operator import BaseOperator
from airflow.hooks.base import BaseHook
from airflow.sdk import Variable
import json

class MapleApiOperator(BaseOperator):

    template_fields= ('data_nm','ocid',)

    def __init__(self,data_nm,date:str | None=None,ocid: str | None = None,**kwargs):
        '''
        data_nm : 호출하고자 하는 데이터의 API 종류  "/"로 구분
        예시: 캐릭터 목록 조회 api 호출시,
        data_nm = "character/list" 
        '''
        super().__init__(**kwargs)
        self.base_url = 'https://open.api.nexon.com/maplestory/v1/'
        self.data_nm = data_nm
        self.headers =  {"x-nxopen-api-key" : Variable.get("x-nxopen-api-key")}
        self.ocid = ocid
        self.date = date

    def execute(self, context):
        from airflow.providers.odbc.hooks.odbc import OdbcHook

        con = self._call_api(self.base_url,self.data_nm,self.headers,self.date,self.ocid)
        
        # self.data_nm = self.data_nm.replace('/','_').replace('-','_')
        # self.ocid=self.ocid.replace('ocid=','')
        data=self.json_dumping(con) 

        #Mssql Server connect
        hook = OdbcHook(odbc_conn_id='conn-db-mssql-maple',driver="ODBC Driver 18 for SQL Server")  #Airflow connection정보
        sql = "EXEC SP_INSERT_DATA @table_nm = ? , @json =?"
        
        json=data
        table_nm = self.data_nm.replace('/','_').replace('-','_')
        params=(table_nm,json)
        hook.run(sql,parameters=params)

        
    

    def _call_api(self,base_url,data_nm,headers,date:str | None=None, ocid:str | None = None):
        import requests
        

        request_url=base_url+data_nm

        if ocid is not None and date is not None:
            request_url +='?'+ocid + '&date=' + date
        elif ocid is not None:
            request_url +='?'+ocid
        elif date is not None:
            request_url +='?'+'date='+date

        response=requests.get(request_url,headers=headers)

        
        if response.status_code != 200:
            raise Exception(f"API request failed: {response.status_code}, {response.text}")
        
        contents=json.loads(response.text)
        
        if ocid is not None:
            contents['ocid'] = ocid[5:]  #ocid를 파라미터로 받는 경우 별도로 받는 ocid 컬럼이 없으므로 임의로 추가함.
    
        return contents

    ## json 문자열 dumping
    def json_dumping(contents):

        empty_list=[]

        if len(contents.keys()) == 1:
            for v in contents.values():
                empty_list.extend(v)

        else:
            empty_list = contents

        json_str=json.dumps(empty_list,ensure_ascii=False)
        return json_str

    