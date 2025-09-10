def make_json_for_db(obj,data_nm=None,ocid=None):
    import json
    # table_list = []
    table_data = {}
    
    def make_dict_json(table_nm,lis):
        nonlocal table_data #,table_list
        
        # if table_nm not in table_list:
            # table_list.append(table_nm)
        if table_nm not in table_data:
            table_data[table_nm]=[]
        
        for i in lis:
            row={}
            for k,v in i.items():
                if ocid:
                    row['ocid']=ocid
                if 'preset' in table_nm:
                    row['preset_no'] = table_nm[-1:]
                if isinstance(v,list):
                    make_dict_json(k,v)
                else:
                    row[k]=v
            if row:
                table_data[table_nm].append(row)
    
    # 상위 단일 값들을 모아 하나의 row로
    single_row={}

    
    for k,v in obj.items():
        if ocid:
            single_row['ocid'] = ocid
        
        if isinstance(v,list):
            make_dict_json(k,v)
        
        else:
            single_row[k] = v
    
    #상위 단일 row는 data_nm을 테이블 명으로
    
    if single_row:
        target = data_nm or "main_table"
        # if target not in table_list:
            # table_list.append(target)
        table_data[target] = [single_row]
            
    
    for t in table_data:
        table_data[t] = json.dumps(table_data[t],ensure_ascii=False)
    
    # if data_nm and data_nm in table_list:
        # table_list = [data_nm] +[t for t in table_list if t != data_nm]
        
    return table_data #,table_list 
            
    
        