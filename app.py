from flask import Flask

app = Flask("new_application")


@app.route("/")
def index():
    return "Hello World"


@app.route("/health")
def health():
    return {
        "status": "healthy"
    }


@app.route("/version")
def version():
    import os
    return {
        "app_version": os.getenv("APPLICATION_VERSION")
    }


if __name__ == "__main__":
    app.run("0.0.0.0", 80)
