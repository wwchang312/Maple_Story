from airflow.decorators import task
from airflow.sdk import TaskGroup

def data_from_meta(*, group_id = 'date_from_meta'):
    with TaskGroup(group_id=group_id) as meta:
        @task(task_id='ocid_from_mata',
                inlets=[maple_character_info])
        def ocid_from_meta(**kwargs):
            inlet_events = kwargs.get('inlet_events')
            events = inlet_events[Asset('maple_character_info')]
            ocid = events[-1].extra['ocid']
            return ocid
            
        @task(task_id = 'view_date_from_meta',
            inlets=[maple_character_info])
        def view_date_from_meta(**kwargs):
            inlet_events = kwargs.get('inlet_events')
            events = inlet_events[Asset('maple_character_info')]
            view_date = events[-1].extra['view_date']
            return view_date