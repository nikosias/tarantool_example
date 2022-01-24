import threading
import datetime
import argparse
import uuid
import requests
import time

parser = argparse.ArgumentParser(description='multy tread testing')
parser.add_argument("--treadcount", default=4, help="tread count")
parser.add_argument("--url", default='http://localhost:80', help="tread count")

args = parser.parse_args()
treadcount = int(args.treadcount)
url = args.url

print('Run tread: '    + str(treadcount)
    + '. Server url: ' + url
    + '.')

key = str(uuid.uuid4())
r=requests.post(url+'/kv',data = {"key":key, "value":"\"value\""})
if(r.status_code != 200 and r.text != "\"value\""):
    print('Error create simple data' ,r,r.text )
    exit(1)

treads = []
result = {}
second = time.time()*10//1 % 10
lock = threading.Lock()

class myThread (threading.Thread):
   def __init__(self, name):
       threading.Thread.__init__(self)
       self.name     = name

   def run(self):
        global second,result,lock
        while(True):
            curSecond= time.time()*10//1 % 10
            lock.acquire(blocking=True, timeout=2)
            if(curSecond != second):
                second = curSecond
                print(result.get('second'),result.get('200'),result.get('429'))
                result = {'second': time.time()%10//1}
            lock.release()
            r=requests.get(url+'/randomtime/'+key)
            status = str(r.status_code)
            sec = r.elapsed.total_seconds()*1000//1

            if(not result.get(status)):
                result[status] = {
                    "count": 0,
                    "time":  0,
                    "min" : sec,
                    "max" :sec,
                }
            cur = result[status] 
            cur['count'] = cur['count'] + 1
            cur['time']  = cur['time']  + sec
            cur['min']   = cur['min'] if cur['min']<sec else sec
            cur['max']   = cur['max'] if cur['max']>sec else sec
            cur['awg']   = cur['time']// cur['count']
            
for treadCount in range(treadcount):
    print('Create and run tread: '+str(treadCount))
    treads.append( myThread("Thread_"+str(treadCount)))

for tread in treads:
    tread.start()

for tread in treads:
    tread.join()

print(result)