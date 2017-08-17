import queue, time, threading, datetime, sys

# Paramaters ===========================================================
tot_thread=4
tot_job=20

# Objects ==============================================================  
# this is the to be put in queue
class Job:     
     def __init__(self, job_id):    
             self.job_id = job_id    
     def do(self):    
             time.sleep(2)    
             print('[Info] Job({0}) is done!'.format(self.job_id))  

# this function get the object from queue and run it
# this is to be called by thread  
def doJob(*args):  
     queue = args[0]  
     print('thread running')
     while queue.qsize() > 0:  
          job = queue.get()  
          job.do()  
          
# main =================================================================  
# set up queue  
que = queue.Queue()  
for n in range(0,tot_job):  
        que.put(Job(n+1))  
print('[Info] Queue size={0}...'.format(que.qsize())) 
  
# setup threads  
thd=[]
for n in range(0,tot_thread):
    thd.append(threading.Thread(target=doJob, name='Thd'+str(n), args=(que,))) 
  
# Start activity to digest queue.  
st = datetime.datetime.now()  
for n in range(0,tot_thread):
    thd[n].start()  
  
# Wait for all threads to terminate.  
while True:
    alive=sum([thd_n.is_alive() for thd_n in thd])  
    if alive!=0:
        time.sleep(0.1)
    else: 
        break
# print out running time for check multithreading  
td = datetime.datetime.now() - st  
print('[Info] Spending time={0}!'.format(td))  
