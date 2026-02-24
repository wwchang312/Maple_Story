from airflow.decorators import task
from airflow.sdk import TaskGroup
from airflow.sdk import Asset

def data_from_meta(*, group_id = 'date_from_meta',Asset_inlet :str, Asset_inlet_nm : str):
    with TaskGroup(group_id=group_id) as meta:
        @task(task_id='ocid_from_mata',
                inlets=[Asset_inlet])
        def ocid_from_meta(**kwargs):
            inlet_events = kwargs.get('inlet_events')
            events = inlet_events[Asset(Asset_inlet_nm)]
            ocid = events[-1].extra['ocid']
            return ocid
            
        @task(task_id = 'view_date_from_meta',
            inlets=[Asset_inlet])
        def view_date_from_meta(**kwargs):
            inlet_events = kwargs.get('inlet_events')
            events = inlet_events[Asset(Asset_inlet_nm)]
            view_date = events[-1].extra['view_date']
            return view_date
        
        ocid = ocid_from_meta()
        view_date = view_date_from_meta()
    
    return ocid, view_date