import argparse
import json
import os
from contextlib import redirect_stdout, redirect_stderr
from pathlib import Path

try:
    from ultralytics import YOLO
except Exception as exc:  # pragma: no cover
    raise SystemExit(f"Ultralytics not available: {exc}")


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--model", required=True)
    parser.add_argument("--source", required=True)
    parser.add_argument("--project", required=True)
    parser.add_argument("--name", required=True)
    args = parser.parse_args()

    os.environ.setdefault("ULTRALYTICS_VERBOSE", "False")

    model = YOLO(args.model)
    with open(os.devnull, "w") as devnull:
        with redirect_stdout(devnull), redirect_stderr(devnull):
            results = model.predict(
                source=args.source,
                save=False,
                imgsz=640,
                conf=0.25,
                verbose=False,
                retina_masks=True,
            )

    label = ""
    confidence = ""
    masks_present = False
    reason = ""
    if results and len(results) > 0:
        res = results[0]
        if res.boxes is not None and len(res.boxes) > 0:
            best = res.boxes[0]
            if hasattr(best, "conf") and best.conf is not None:
                confidence = f"{float(best.conf):.4f}"
            if hasattr(best, "cls") and best.cls is not None:
                cls_id = int(best.cls)
                names = res.names or {}
                label = names.get(cls_id, str(cls_id))
        masks = getattr(res, "masks", None)
        if masks is not None and masks.data is not None and len(masks.data) > 0:
            masks_present = True

    output_dir = Path(args.project) / args.name
    output_dir.mkdir(parents=True, exist_ok=True)
    output_image = output_dir / "annotated.png"

    # Try to render segmentation overlay directly for mask models.
    try:
        import numpy as np
        from PIL import Image

        img = Image.open(args.source)
        try:
            from PIL import ImageOps
            img = ImageOps.exif_transpose(img)
        except Exception:
            pass
        img = img.convert("RGB")
        img_np = np.array(img)

        masks = getattr(results[0], "masks", None)
        if masks is not None and masks.data is not None and len(masks.data) > 0:
            mask = masks.data[0].cpu().numpy()
            # Resize mask to image size if needed
            if mask.shape[:2] != img_np.shape[:2]:
                mask_img = Image.fromarray((mask * 255).astype(np.uint8))
                mask_img = mask_img.resize((img_np.shape[1], img_np.shape[0]))
                mask = np.array(mask_img) / 255.0

            mask_bool = mask > 0.5
            overlay = img_np.copy()
            color = np.array([0, 191, 189], dtype=np.uint8)  # teal-like
            overlay[mask_bool] = (0.55 * overlay[mask_bool] + 0.45 * color).astype(np.uint8)

            out = Image.fromarray(overlay)
            out.save(output_image)
        else:
            reason = "No segmentation masks found. Retrain with a segmentation model (e.g., yolov8n-seg) and task=segment."
            out = Image.fromarray(img_np)
            out.save(output_image)
    except Exception:
        # Last-resort fallback to raw image.
        try:
            from PIL import Image
            img = Image.open(args.source)
            try:
                from PIL import ImageOps
                img = ImageOps.exif_transpose(img)
            except Exception:
                pass
            img = img.convert("RGB")
            img.save(output_image)
        except Exception:
            pass

    payload = {
        "label": label,
        "confidence": confidence,
        "output_image": str(output_image),
        "masks_present": masks_present,
        "reason": reason,
    }
    print(json.dumps(payload))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
