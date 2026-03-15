<?php
require_once __DIR__ . "/db.php";

$data = read_json();
$batchTraineeId = intval($data["batch_trainee_id"] ?? 0);
$assessmentType = strtolower(trim($data["assessment_type"] ?? ""));
$status = strtolower(trim($data["status"] ?? ""));

if ($batchTraineeId <= 0) {
  respond("error", "batch_trainee_id is required.");
}

$allowedTypes = ["oral", "written", "demo"];
$allowedStatus = ["competent", "not_yet_competent", "pending"];
if (!in_array($assessmentType, $allowedTypes, true)) {
  respond("error", "Invalid assessment_type.");
}
if (!in_array($status, $allowedStatus, true)) {
  respond("error", "Invalid status.");
}

try {
  $pdo = db();

  $stmt = $pdo->prepare("
    SELECT oral_status, written_status, demo_status
    FROM trainee_progress
    WHERE batch_trainee_id = ?
  ");
  $stmt->execute([$batchTraineeId]);
  $row = $stmt->fetch(PDO::FETCH_ASSOC);

  $oralStatus = $row["oral_status"] ?? "pending";
  $writtenStatus = $row["written_status"] ?? "pending";
  $demoStatus = $row["demo_status"] ?? "pending";

  if ($assessmentType === "demo") {
    if (!($oralStatus === "competent" && $writtenStatus === "competent")) {
      respond("error", "Demo is locked. Oral and Written must both be Competent.");
    }
  }

  $dateField = $assessmentType . "_date_completed";
  $dateValue = ($assessmentType === "demo")
    ? date("Y-m-d")
    : (($status === "competent") ? date("Y-m-d") : null);

  if ($row) {
    $stmt = $pdo->prepare("
      UPDATE trainee_progress
      SET {$assessmentType}_status = ?,
          {$dateField} = ?,
          updated_at = NOW()
      WHERE batch_trainee_id = ?
    ");
    $stmt->execute([$status, $dateValue, $batchTraineeId]);
  } else {
    $stmt = $pdo->prepare("
      INSERT INTO trainee_progress
        (batch_trainee_id, oral_status, written_status, demo_status,
         oral_date_completed, written_date_completed, demo_date_completed, updated_at)
      VALUES (?, ?, ?, ?, ?, ?, ?, NOW())
    ");
    $oralInsert = $assessmentType === "oral" ? $status : "pending";
    $writtenInsert = $assessmentType === "written" ? $status : "pending";
    $demoInsert = $assessmentType === "demo" ? $status : "pending";
    $oralDate = $assessmentType === "oral" ? $dateValue : null;
    $writtenDate = $assessmentType === "written" ? $dateValue : null;
    $demoDate = $assessmentType === "demo" ? $dateValue : null;
    $stmt->execute([
      $batchTraineeId,
      $oralInsert,
      $writtenInsert,
      $demoInsert,
      $oralDate,
      $writtenDate,
      $demoDate,
    ]);
  }

  respond("success", "Progress updated.");
} catch (Throwable $e) {
  respond("error", "Server error: " . $e->getMessage());
}
