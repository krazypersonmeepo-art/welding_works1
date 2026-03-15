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

// Call external YOLO service
$yoloServiceUrl = getenv("YOLO_SERVICE_URL") ?: "";
if ($yoloServiceUrl === "") {
  respond("error", "YOLO service not configured. Set YOLO_SERVICE_URL.");
}

$ch = curl_init();
$postFields = [
  "image" => new CURLFile($imagePath),
];
curl_setopt_array($ch, [
  CURLOPT_URL => rtrim($yoloServiceUrl, "/") . "/infer",
  CURLOPT_POST => true,
  CURLOPT_POSTFIELDS => $postFields,
  CURLOPT_RETURNTRANSFER => true,
  CURLOPT_TIMEOUT => 60,
]);
$response = curl_exec($ch);
$curlErr = curl_error($ch);
$httpCode = curl_getinfo($ch, CURLINFO_HTTP_CODE);
curl_close($ch);

if ($response === false || $httpCode >= 400) {
  $msg = $curlErr ?: ("YOLO service error (HTTP " . $httpCode . ")");
  respond("error", $msg);
}

$payload = json_decode($response, true);
if (!is_array($payload)) {
  respond("error", "Invalid YOLO service response.");
}

$label = trim($payload["label"] ?? "");
$confidence = trim((string)($payload["confidence"] ?? ""));
$reason = trim($payload["reason"] ?? "");
$isGood = (bool)($payload["is_good"] ?? false);
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

$demoStatus = $isGood ? "competent" : "not_yet_competent";

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
