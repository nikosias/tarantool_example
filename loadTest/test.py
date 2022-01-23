import threading
import datetime
import argparse
parser = argparse.ArgumentParser(description='multy tread testing')
parser.add_argument("--treadcount", default=4, help="tread count")
parser.add_argument("--url", default='http://localhost:80', help="tread count")
parser.add_argument("--rps", default=10, help="max request per seconds")
parser.add_argument("--testcount", default=100, help="test count.")

args = parser.parse_args()
treadcount = int(args.treadcount)
url = args.url
rps = int(args.rps)
testcount = int(args.testcount)
examples = {
    'post' = {
        'url' = '/kv',
        'type' = 'post',
        'count' = testcount,
        'randomPrioryty' = 100*testcount*4,
        'answers' = {}
    },
    'get' = {
        'url' = '/kv',
        'type' = 'get',
        'count' = testcount,
        'randomPrioryty' = 0,
        'answers' = {}
    },
    'put' = {
        'url' = '/kv',
        'type' = 'put',
        'count' = testcount,
        'randomPrioryty' = 0,
        'answers' = {}
    },
    'delete' = {
        'url' = '/kv',
        'type' = 'delete',
        'count' = testcount,
        'randomPrioryty' = 0,
        'answers' = {}
    }

}
print('Run tread: '    + str(treadcount)
    + '. Server url: ' + url
    + '. RPS: '        + str(rps)
    + '.Test count: ' + str(testcount)
    + '.')
treads = []

class myThread (threading.Thread):
   def __init__(self, name, counter):
       threading.Thread.__init__(self)
       self.threadID = counter
       self.name = name
       self.counter = counter

   def run(self):
       for i  in range(10):
            print("Starting " + self.name+': '+str(i))
            print_date(self.name, self.counter)
            print("Exiting " + self.name)

def print_date(threadName, counter):
   datefields = []
   today = datetime.date.today()
   datefields.append(today)
   print(
      "%s[%d]: %s" % ( threadName, counter, datefields[0] )
   )

for treadCount in range(treadcount):
    print('Create and run tread: '+str(treadCount))
    treads.append( myThread("Thread_"+str(treadCount), treadCount))
    treads[treadCount].start()

for tread in treads:
    tread.join()
