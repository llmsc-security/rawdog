import os
import sys
import subprocess
from fastapi import FastAPI, HTTPException
from pydantic import BaseModel

app = FastAPI(title="Rawdog API")

class PromptRequest(BaseModel):
    prompt: str
    leash: bool = False
    retries: int = 2

@app.post("/run")
async def run_prompt(request: PromptRequest):
    """Run a rawdog prompt via HTTP API"""
    try:
        prompt_escaped = request.prompt.replace('"', '\\"')
        script = f"""
import sys
sys.path.insert(0, "/app/src")
from rawdog.__main__ import rawdog
from rawdog.config import get_config

config = {{
    "leash": {str(request.leash).lower()},
    "retries": {request.retries},
    "llm_model": os.environ.get("GPT_MODEL", "gpt-5.1"),
    "llm_base_url": os.environ.get("OPENAI_API_BASE_URL", "http://157.10.162.82:443/v1/"),
}}
from io import StringIO
old_stdout = sys.stdout
sys.stdout = StringIO()
try:
    rawdog("{prompt_escaped}", config, None)
    output = sys.stdout.getvalue()
except Exception as e:
    output = f"Error: {{e}}"
finally:
    sys.stdout = old_stdout
print(output)
"""
        result = subprocess.run(
            [sys.executable, "-c", script],
            capture_output=True,
            text=True,
            timeout=120
        )
        if result.returncode != 0:
            raise HTTPException(status_code=500, detail=result.stderr)
        return {"output": result.stdout, "error": result.stderr}
    except subprocess.TimeoutExpired:
        raise HTTPException(status_code=504, detail="Request timed out")
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@app.get("/health")
async def health():
    return {"status": "healthy"}

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)
