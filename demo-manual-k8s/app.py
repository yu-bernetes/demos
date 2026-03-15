from flask import Flask, jsonify, render_template
import os
import socket
import math
import sys

app = Flask(__name__)

# Fetch environment variables from K8s ConfigMap
APP_VERSION = os.environ.get("APP_VERSION", "1.0")
THEME_COLOR = "#007bff" if APP_VERSION == "1.0" else "#28a745"

# Global state to simulate a crash
is_healthy = True

@app.route("/")
def home():
    if not is_healthy:
        return "Internal Server Error - Pod is Crashing!", 500
        
    hostname = socket.gethostname()
    return render_template("index.html", pod_name=hostname, version=APP_VERSION, color=THEME_COLOR)

@app.route("/api/info")
def info():
    return jsonify({
        "message": "Hello from Kubernetes & Docker Demo!",
        "version": APP_VERSION,
        "pod_name": socket.gethostname(),
        "status": "Success \u2728"
    })

@app.route("/health")
def healthz():
    """K8s Liveness Probe endpoint. If is_healthy is False, K8s restarts this Pod."""
    if is_healthy:
        return jsonify({"status": "healthy"}), 200
    else:
        return jsonify({"status": "unhealthy"}), 500

@app.route("/crash", methods=['POST'])
def crash():
    """ Endpoint to intentionally 'break' the application to demo Kubernetes Self-Healing. """
    global is_healthy
    is_healthy = False
    return jsonify({"message": "Successfully crashed the application! K8s liveness probe will detect this soon."}), 200

@app.route("/stress")
def stress():
    """ CPU intensive task to trigger Auto-scaling (HPA) """
    if not is_healthy:
        return "Internal Server Error", 500
        
    x = 0.0001
    for i in range(5000000):
        x += math.sqrt(x)
    return jsonify({"status": "stressed", "result": x, "pod_name": socket.gethostname()})


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)
