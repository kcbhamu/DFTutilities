import queue, time, threading, datetime, sys
  
class Job:    
     def __init__(self, name):    
             self.name = name    
     def do(self):    
             time.sleep(2)    
             print("\t[Info] Job({0}) is done!".format(self.name))  
  
que = queue.Queue()  
for i in range(20):  
        que.put(Job(str(i+1)))  
  
print("\t[Info] Queue size={0}...".format(que.qsize()))  

def doJob(*args):  
     queue = args[0]  
     print('thread running')
     while queue.qsize() > 0:  
          job = queue.get()  
          job.do()  
  
# Open three threads  
thd1 = threading.Thread(target=doJob, name='Thd1', args=(que,))  
thd2 = threading.Thread(target=doJob, name='Thd2', args=(que,))  
thd3 = threading.Thread(target=doJob, name='Thd3', args=(que,))  
thd4 = threading.Thread(target=doJob, name='Thd4', args=(que,))  
  
# Start activity to digest queue.  
st = datetime.datetime.now()  
thd1.start()  
thd2.start()  
thd3.start()  
thd4.start()
  
# Wait for all threads to terminate.  
while thd1.is_alive() or thd2.is_alive() or thd3.is_alive() or thd4.is_alive():  
     time.sleep(1)    
  
td = datetime.datetime.now() - st  
print("\t[Info] Spending time={0}!".format(td))  
