param(
  [string]$DatasetDir = ".\\YOLO DATASET\\welding2026C.v1i.yolo26",
  [string]$Model = "yolov8n-seg.pt",
  [int]$Epochs = 100,
  [int]$Img = 640,
  [string]$Project = ".\\runs\\yolo_runs",
  [string]$Name = "welding2026C-seg"
)

$ErrorActionPreference = "Stop"

$datasetPath = Resolve-Path $DatasetDir
$dataYaml = Join-Path $datasetPath "data.yaml"

if (-not (Test-Path $dataYaml)) {
  throw "data.yaml not found at $dataYaml"
}

python -m pip install --upgrade ultralytics

yolo task=segment mode=train `
  model=$Model `
  data="$dataYaml" `
  epochs=$Epochs `
  imgsz=$Img `
  project="$Project" `
  name="$Name"
