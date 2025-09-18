
def make_json_for_db(obj,data_nm=None,ocid=None,account_id=None):
    import json
    table_data = {}
    
    def make_json_list(table_nm,lis):
        nonlocal table_data
        
        if table_nm not in table_data:
            table_data[table_nm]=[]
        
        for i in lis:
            row={}
            for k,v in i.items():
                if ocid:
                    row['ocid']=ocid
                #preset의 경우 key의 preset 숫자 부분을 이용하여 preset_no 컬럼과 그 값을 추가함
                if 'preset' in table_nm:
                    row['preset_no'] = table_nm[-1]
                    
                if isinstance(v,list):
                    make_json_list(k,v)
                    
                else:
                    row[k]=v
            if row:
                table_data[table_nm].append(row)
                

        
    # 상위 단일 값들을 모아 하나의 row로
    single_row={}
    
    for k,v in obj.items():
        if ocid:
            single_row['ocid'] = ocid        
        
        #obj가 list인 경우 
        if isinstance(v,list):
            make_json_list(k,v)
    
        else:
            single_row[k] = v
    
    #상위 단일 row는 data_nm을 테이블 명으로
    
    if single_row:
        target = data_nm.replace('-','_') or "main_table"
        
        # 테이블 명으로 사용하는 data_nm과 list를 value로 사용하는 key값이 중복된 경우, data_nm에 _basic을 붙여서 이를 구분한다.
        if table_data.get(target):
            target=data_nm +"_common"
        
        table_data[target] = [single_row]
            
    
    for d in list(table_data.keys()):
        if table_data[d] ==[]:
            del table_data[d]
    
    for t in table_data:
        table_data[t] = json.dumps(table_data[t],ensure_ascii=False)
        
    # single_row table이 나머지 테이블의 부모 테이블이 되므로, 먼저 돌기 위한 dic 순서 재조정
    last_key, last_value = list(table_data.items())[-1]
    table_data = {last_key: last_value, **{k: v for k, v in list(table_data.items())[:-1]}}

        
    return table_data
            