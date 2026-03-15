import os
import urllib.request
from fastapi import FastAPI, File, UploadFile
from fastapi.responses import JSONResponse
from ultralytics import YOLO

app = FastAPI()

MODEL_PATH = os.getenv("YOLO_MODEL_PATH", "/app/models/best.pt")
MODEL_URL = os.getenv("YOLO_MODEL_URL", "")
# Comma-separated labels considered "good" (case-insensitive)
GOOD_LABELS = [x.strip().lower() for x in os.getenv("YOLO_GOOD_LABELS", "good welding,good,ok").split(",") if x.strip()]

_model = None


def ensure_model():
    global _model
    if _model is not None:
        return _model

    if not os.path.exists(MODEL_PATH):
        if not MODEL_URL:
            raise RuntimeError("Model not found and YOLO_MODEL_URL not set")
        os.makedirs(os.path.dirname(MODEL_PATH), exist_ok=True)
        urllib.request.urlretrieve(MODEL_URL, MODEL_PATH)

    _model = YOLO(MODEL_PATH)
    return _model


@app.get("/health")
def health():
    return {"status": "ok"}


@app.post("/infer")
async def infer(image: UploadFile = File(...)):
    try:
        model = ensure_model()
    except Exception as e:
        return JSONResponse(status_code=500, content={"status": "error", "message": str(e)})

    # Save to temp file
    tmp_path = f"/tmp/{image.filename}"
    with open(tmp_path, "wb") as f:
        f.write(await image.read())

    try:
        results = model.predict(source=tmp_path, save=False, verbose=False)
        if not results:
            return {"status": "success", "label": "", "confidence": 0, "reason": "no detections", "is_good": False}

        r = results[0]
        if r.boxes is None or len(r.boxes) == 0:
            return {"status": "success", "label": "", "confidence": 0, "reason": "no detections", "is_good": False}

        # pick best box by confidence
        confs = r.boxes.conf.tolist()
        best_idx = confs.index(max(confs))
        cls_id = int(r.boxes.cls.tolist()[best_idx])
        label = r.names.get(cls_id, str(cls_id))
        confidence = float(confs[best_idx])

        is_good = label.strip().lower() in GOOD_LABELS

        return {
            "status": "success",
            "label": label,
            "confidence": confidence,
            "reason": "ok",
            "is_good": is_good,
        }
    except Exception as e:
        return JSONResponse(status_code=500, content={"status": "error", "message": str(e)})
    finally:
        try:
            os.remove(tmp_path)
        except Exception:
            pass
