<?php
require_once __DIR__ . "/db.php";

$data = read_json();
$email = strtolower(trim($data["email"] ?? ""));

if ($email === "") {
  respond("error", "Email is required.");
}

try {
  $pdo = db();
  $stmt = $pdo->prepare("
    SELECT trainers_id, is_verified
    FROM users
    WHERE email = ?
    LIMIT 1
  ");
  $stmt->execute([$email]);
  $row = $stmt->fetch(PDO::FETCH_ASSOC);

  if (!$row) {
    respond("error", "Account not found.");
  }

  if ((int)$row["is_verified"] === 1) {
    respond("success", "Account already verified.");
  }

  $otp = generate_otp();
  $update = $pdo->prepare("
    UPDATE users
    SET verification_code = ?
    WHERE trainers_id = ?
  ");
  $update->execute([$otp, $row["trainers_id"]]);

  $sent = send_otp_email($email, $otp);
  if (!$sent) {
    respond("error", "Failed to send OTP email.");
  }

  respond("success", "OTP resent.");
} catch (Throwable $e) {
  respond("error", "Server error: " . $e->getMessage());
}
