from sanic import Sanic, text
from sanic.response import json
from rq import Queue
from redis import Redis
import os
import time

app = Sanic("sanic-rq-app")

# Use environment variable or default to localhost
redis_host = os.getenv("REDIS_HOST", "localhost")
redis_conn = Redis(host=redis_host, port=6379, db=0)
q = Queue(connection=redis_conn)

# Sample background task
def background_task(duration):
    time.sleep(duration)
    return f"Task completed after {duration} seconds!"

@app.get("/")
async def root(request):
    return text("Hello from Sanic! Backend is live.")

@app.get("/enqueue")
async def enqueue(request):
    job = q.enqueue(background_task, 5)
    return json({"job_id": job.id, "status": "queued"})

@app.get("/result/<job_id>")
async def result(request, job_id):
    job = q.fetch_job(job_id)
    if not job:
        return json({"error": "Job not found"}, status=404)
    if job.is_finished:
        return json({"result": job.result, "status": "finished"})
    elif job.is_failed:
        return json({"error": str(job.exc_info), "status": "failed"})
    else:
        return json({"status": "running"})

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=8000, debug=True)
