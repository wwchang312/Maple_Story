'''
DB에서 호출하고자하는 값이 복수개일 경우, 하나의 문자열을 복수의 파라미터로 변경하기 위한 함수
'''

def normalize_value(v):
    if v is None:
        return []
    if isinstance(v,str):
        v=v.split(',')
        return v
    return list(v)

def build_in_clause(values):
    vals=normalize_value(values)

    if not vals:
        return None , []
    #파라미터 개수
    placeholders = ",".join(["?"] * len(vals))
    return f" ({placeholders})", vals


