<?php
require_once __DIR__ . "/db.php";

$data = read_json();
$identifier = trim($data["identifier"] ?? "");
$email = strtolower(trim($data["email"] ?? ""));
$username = trim($data["username"] ?? "");
$password = $data["password"] ?? "";

$loginId = $identifier !== "" ? $identifier : ($email !== "" ? $email : $username);

if ($loginId === "" || $password === "") {
  respond("error", "Username/email and password are required.");
}

try {
  $pdo = db();
  $stmt = $pdo->prepare("
    SELECT trainers_id, password, is_verified
    FROM users
    WHERE email = ? OR username = ?
    LIMIT 1
  ");
  $stmt->execute([$loginId, $loginId]);
  $row = $stmt->fetch(PDO::FETCH_ASSOC);

  if (!$row) {
    respond("error", "Account not found.");
  }

  if (!password_verify($password, $row["password"])) {
    respond("error", "Invalid credentials.");
  }

  if ((int)$row["is_verified"] === 0) {
    respond("error", "Account not verified. Please verify OTP.");
  }

  respond("success", "Login successful.");
} catch (Throwable $e) {
  respond("error", "Server error: " . $e->getMessage());
}
