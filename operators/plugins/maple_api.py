from airflow.models.baseoperator import BaseOperator
from airflow.hooks.base import BaseHook
import pandas as pd 

class MapleApiOperator(BaseOperator):
    template_fields=('endpoint','path','file_name','base_dt')