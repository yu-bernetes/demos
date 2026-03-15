import requests
import threading
import time
import sys

# The URL of your local Kubernetes service
URL = "http://localhost:80/stress"
NUM_THREADS = 40
REQUESTS_PER_THREAD = 50

def send_requests(thread_id):
    print(f"Thread {thread_id} starting...")
    for i in range(REQUESTS_PER_THREAD):
        try:
            response = requests.get(URL, timeout=5)
            # Just print a dot to show progress without filling the screen
            print(".", end="", flush=True)
        except Exception as e:
            print("X", end="", flush=True)
    print(f"\nThread {thread_id} finished.")

if __name__ == "__main__":
    print(f"Starting Load Test on {URL}")
    print(f"Spawning {NUM_THREADS} threads, each sending {REQUESTS_PER_THREAD} requests.")
    print("This will artificially spike the CPU usage of the Pods.")
    print("Go to your terminal and watch scaling with 'kubectl get hpa -w'")
    
    threads = []
    
    start_time = time.time()
    
    for i in range(NUM_THREADS):
        t = threading.Thread(target=send_requests, args=(i+1,))
        threads.append(t)
        t.start()
        
    for t in threads:
        t.join()
        
    end_time = time.time()
    print(f"\nLoad test completed in {end_time - start_time:.2f} seconds.")
