from flask import Flask, render_template_string
import os

app = Flask(__name__)

# Configurable items via Environment Variables
VERSION = os.getenv("APP_VERSION", "1.0")
THEME_COLOR = os.getenv("THEME_COLOR", "#3498db") # Default Blue
THEME_NAME = os.getenv("THEME_NAME", "Blue Theme")

HTML_TEMPLATE = """
<!DOCTYPE html>
<html>
<head>
    <title>GitOps Demo</title>
    <style>
        body {
            background-color: {{ color }};
            color: white;
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            display: flex;
            flex-direction: column;
            justify-content: center;
            align-items: center;
            height: 100vh;
            margin: 0;
            text-shadow: 2px 2px 4px rgba(0,0,0,0.5);
        }
        h1 { font-size: 4rem; margin-bottom: 0; }
        h2 { font-size: 2rem; font-weight: 300; }
        .footer { position: absolute; bottom: 20px; font-size: 0.8rem; }
    </style>
</head>
<body>
    <h1>Versiyon {{ version }}</h1>
    <div class="footer">ArgoCD & GitOps Demo - Powered by Kubernetes</div>
</body>
</html>
"""

@app.route('/')
def index():
    return render_template_string(HTML_TEMPLATE, version=VERSION, color=THEME_COLOR, theme_name=THEME_NAME)

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)
