<?php
require_once __DIR__ . "/db.php";

$data = read_json();
$first = trim($data["first_name"] ?? "");
$middle = trim($data["middle_name"] ?? "");
$last = trim($data["last_name"] ?? "");
$email = strtolower(trim($data["email"] ?? ""));
$password = $data["password"] ?? "";
$role = trim($data["role"] ?? "trainee");

if ($first === "" || $last === "" || $email === "" || $password === "") {
  respond("error", "Missing required fields.");
}

if (!str_ends_with($email, "@gmail.com")) {
  respond("error", "Only Gmail accounts allowed.");
}

$username = trim($data["username"] ?? "");
if ($username === "") {
  $username = explode("@", $email)[0];
}
$passwordHash = password_hash($password, PASSWORD_DEFAULT);
$otp = generate_otp();

try {
  $pdo = db();

  $check = $pdo->prepare("SELECT trainers_id FROM users WHERE email = ? OR username = ?");
  $check->execute([$email, $username]);
  if ($check->fetch()) {
    respond("error", "Account already exists.");
  }

  $stmt = $pdo->prepare("
    INSERT INTO users
      (firstname, middlename, lastname, username, password, email, role,
       status, verification_code, is_verified, password_change, created_at)
    VALUES
      (?, ?, ?, ?, ?, ?, ?, ?, ?, 0, 0, NOW())
  ");
  $stmt->execute([
    $first, $middle, $last, $username, $passwordHash, $email, $role,
    "active", $otp
  ]);

  $sent = send_otp_email($email, $otp);
  if (!$sent) {
    respond("error", "Failed to send OTP email.");
  }

  respond("success", "Registration successful. OTP sent.");
} catch (Throwable $e) {
  respond("error", "Server error: " . $e->getMessage());
}
