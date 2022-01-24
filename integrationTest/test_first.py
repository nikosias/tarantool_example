import requests
import pytest
import uuid
class Test_Request():
    _url =False
    @pytest.fixture(autouse=True)
    def _pass_fixture_value(self, url):
        self._url = url
        
    def test_keyNotFound(self):
        r=requests.post(self._url+'/kv',data = {})
        assert(r.status_code == 400)

    def test_POST(self):
        key = str(uuid.uuid4())
        r=requests.post(self._url+'/kv',data = {"key":key, "value":"\"value\""})
        assert(r.status_code == 200)
        assert(r.text == '"value"')

        r=requests.post(self._url+'/kv',data = {"key":key, "value":"\"value\""})
        assert(r.status_code == 409)
        
        r=requests.post(self._url+'/kv',data = {"key": str(uuid.uuid4()), "value":"value\""})
        assert(r.status_code == 400)

    def test_GET(self):
        key = str(uuid.uuid4())
        r=requests.post(self._url+'/kv',data = {"key":key, "value":"\"value\""})
        assert(r.status_code == 200)
        assert(r.text == '"value"')

        r=requests.get(self._url+'/kv/'+key)
        assert(r.status_code == 200)
        assert(r.text == '"value"')

        r=requests.get(self._url+'/kv/'+str(uuid.uuid4()))
        assert(r.status_code == 404)

    def test_PUT(self):
        key = str(uuid.uuid4())
        r=requests.post(self._url+'/kv',data = {"key":key, "value":"\"value\""})
        assert(r.status_code == 200)
        assert(r.text == '"value"')

        r=requests.put(self._url+'/kv/'+key,data = {"key":key, "value":"\"value1\""})
        assert(r.status_code == 200)
        assert(r.text == '"value1"')

        r=requests.put(self._url+'/kv/'+str(uuid.uuid4()))
        assert(r.status_code == 404)

        r=requests.put(self._url+'/kv/'+key,data = {"key":key, "value":"value1\""})
        assert(r.status_code == 400)

    def test_DELETE(self):
        key = str(uuid.uuid4())
        r=requests.post(self._url+'/kv',data = {"key":key, "value":"\"value\""})
        assert(r.status_code == 200)
        assert(r.text == '"value"')

        r=requests.delete(self._url+'/kv/'+key)
        assert(r.status_code == 200)
        assert(r.text == '"value"')

        r=requests.put(self._url+'/kv/'+key)
        assert(r.status_code == 404)
