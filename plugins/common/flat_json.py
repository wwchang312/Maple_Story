def flat_json(content=None):

    if content is None:
        content = {}
 
    import json
    result=[]
    '''
    json 형식의 데이터가 중첩 및 서로 다른 깊이로 되어 있을 때, 이를 각각 1레벨의 json 형식으로 변경하는 함수
    '''
    def flat_dict(con = None, context=None):
        if context is None:
            context={}
            
            
        local_context=context.copy() #부모 context유지
        
        for k,v in con.items():
            if isinstance(v,list): #list 순회
                for i in v:
                    if isinstance(i,dict):
                        flat_dict(i,local_context)
            elif isinstance(v,dict):
                flat_dict(v,local_context)
            else:
                local_context[k] = v
 
        if all(not isinstance(v,(dict,list)) for v in con.values()):
            result.append(local_context)
    
    
    
    flat_dict(content)
    
    result = json.dumps(result,ensure_ascii=False)
    
    return result

