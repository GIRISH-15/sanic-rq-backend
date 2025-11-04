from rq import Queue, Connection, Worker
from redis import Redis
import os

# Import task from app.py
from app import background_task

redis_host = os.getenv("REDIS_HOST", "localhost")

if __name__ == "__main__":
    with Connection(Redis(host=redis_host, port=6379)):
        q = Queue()
        print("RQ Worker started. Waiting for jobs...")
        worker = Worker([q])
        worker.work()
