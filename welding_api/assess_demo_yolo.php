<?php
require_once __DIR__ . "/db.php";

if ($_SERVER["REQUEST_METHOD"] !== "POST") {
  respond("error", "Invalid request.");
}

$batchTraineeId = intval($_POST["batch_trainee_id"] ?? 0);
if ($batchTraineeId <= 0) {
  respond("error", "batch_trainee_id is required.");
}

if (!isset($_FILES["demo_image"])) {
  respond("error", "demo_image is required.");
}

$upload = $_FILES["demo_image"];
if ($upload["error"] !== UPLOAD_ERR_OK) {
  respond("error", "Upload failed.");
}

$uploadsDir = __DIR__ . "/yolo_uploads";
$outputsDir = __DIR__ . "/yolo_outputs";
if (!is_dir($uploadsDir)) {
  mkdir($uploadsDir, 0777, true);
}
if (!is_dir($outputsDir)) {
  mkdir($outputsDir, 0777, true);
}

$ext = pathinfo($upload["name"], PATHINFO_EXTENSION);
$filename = "demo_" . $batchTraineeId . "_" . time() . "." . $ext;
$imagePath = $uploadsDir . "/" . $filename;

if (!move_uploaded_file($upload["tmp_name"], $imagePath)) {
  respond("error", "Failed to save image.");
}

$modelPath = getenv("YOLO_MODEL_PATH") ?: (__DIR__ . "/models/best.pt");
$modelUrl = getenv("YOLO_MODEL_URL") ?: "";
if (!file_exists($modelPath)) {
  if ($modelUrl !== "") {
    if (!is_dir(dirname($modelPath))) {
      mkdir(dirname($modelPath), 0777, true);
    }
    $downloaded = @file_put_contents($modelPath, @file_get_contents($modelUrl));
    if (!$downloaded || !file_exists($modelPath)) {
      respond("error", "Model download failed. Check YOLO_MODEL_URL.");
    }
  } else {
    respond("error", "Model not found. Set YOLO_MODEL_PATH or YOLO_MODEL_URL.");
  }
}

$runId = "run_" . time();
$cmd = "python " .
  escapeshellarg(__DIR__ . "/yolo_infer.py") .
  " --model " . escapeshellarg($modelPath) .
  " --source " . escapeshellarg($imagePath) .
  " --project " . escapeshellarg($outputsDir) .
  " --name " . escapeshellarg($runId);

$output = shell_exec($cmd);
if ($output === null) {
  respond("error", "Inference failed to run.");
}

// Some environments still emit logs; try to extract the last JSON object.
$trimmed = trim($output);
$jsonStart = strrpos($trimmed, "{");
$jsonEnd = strrpos($trimmed, "}");
$jsonPayload = $trimmed;
if ($jsonStart !== false && $jsonEnd !== false && $jsonEnd > $jsonStart) {
  $jsonPayload = substr($trimmed, $jsonStart, $jsonEnd - $jsonStart + 1);
}

$payload = json_decode($jsonPayload, true);
if (!is_array($payload)) {
  respond("error", "Invalid inference output.");
}

$label = trim($payload["label"] ?? "");
$confidence = trim($payload["confidence"] ?? "");
$reason = trim($payload["reason"] ?? "");
$outputImage = $payload["output_image"] ?? "";

$annotatedUrl = "";
if ($outputImage && file_exists($outputImage)) {
  $relative = str_replace(__DIR__, "", $outputImage);
  $relative = str_replace("\\", "/", $relative);
  if (strpos($relative, "/") !== 0) {
    $relative = "/" . $relative;
  }
  $annotatedUrl = $relative;
}

$originalRelative = str_replace(__DIR__, "", $imagePath);
$originalRelative = str_replace("\\", "/", $originalRelative);
if (strpos($originalRelative, "/") !== 0) {
  $originalRelative = "/" . $originalRelative;
}

$demoStatus = "not_yet_competent";
if (strtolower($label) === "good welding") {
  $demoStatus = "competent";
}

try {
  $pdo = db();
  $stmt = $pdo->prepare("
    SELECT oral_status, written_status
    FROM trainee_progress
    WHERE batch_trainee_id = ?
  ");
  $stmt->execute([$batchTraineeId]);
  $row = $stmt->fetch(PDO::FETCH_ASSOC);
  $oralStatus = $row["oral_status"] ?? "pending";
  $writtenStatus = $row["written_status"] ?? "pending";

  if (!($oralStatus === "competent" && $writtenStatus === "competent")) {
    respond("error", "Demo is locked. Oral and Written must both be Competent.");
  }

  $demoDate = date("Y-m-d");
  $demoImageUrl = $originalRelative;
  $demoAnnotatedUrl = $annotatedUrl;
  if ($row) {
    $stmt = $pdo->prepare("
      UPDATE trainee_progress
      SET demo_status = ?, demo_date_completed = ?, demo_image_url = ?, demo_annotated_image_url = ?, updated_at = NOW()
      WHERE batch_trainee_id = ?
    ");
    $stmt->execute([$demoStatus, $demoDate, $demoImageUrl, $demoAnnotatedUrl, $batchTraineeId]);
  } else {
    $stmt = $pdo->prepare("
      INSERT INTO trainee_progress
        (batch_trainee_id, oral_status, written_status, demo_status,
         oral_date_completed, written_date_completed, demo_date_completed,
         demo_image_url, demo_annotated_image_url, updated_at)
      VALUES (?, 'pending', 'pending', ?, NULL, NULL, ?, ?, ?, NOW())
    ");
    $stmt->execute([$batchTraineeId, $demoStatus, $demoDate, $demoImageUrl, $demoAnnotatedUrl]);
  }
} catch (Throwable $e) {
  respond("error", "Server error: " . $e->getMessage());
}

  respond("success", "Assessment complete.", [
  "label" => $label,
  "confidence" => $confidence,
  "reason" => $reason,
  "demo_status" => $demoStatus,
  "annotated_image_url" => $annotatedUrl,
  "original_image_url" => $originalRelative,
]);
