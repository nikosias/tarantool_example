import requests
import pytest

def test_start():
    assert(True)

@pytest.mark.parametrize("id,answ", [(1,'test1'),(2,'test3'),])
def test_request(id,answ):
    r=requests.get('http://localhost:8080/?id='+str(id))
    body = r.json()['answer']
    assert ( body[0] == id and body[1]== answ)
