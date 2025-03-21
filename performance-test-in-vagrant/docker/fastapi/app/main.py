from fastapi import FastAPI, status
from pydantic import BaseModel

app = FastAPI()


class HealthCheck(BaseModel):
    """Response model to validate and return when performing a health check."""

    status: str = "OK"

@app.get("/health")
def get_health() -> HealthCheck:
    return HealthCheck(status="OK")

@app.get("/")
def get_main():
    result = {
        "app_name": "fastapi"
    }
    return result