<?php
require_once __DIR__ . "/db.php";

$data = read_json();
$idToken = trim($data["id_token"] ?? "");

if ($idToken === "") {
  respond("error", "Missing Google ID token.");
}

// Verify token with Google
$verifyUrl = "https://oauth2.googleapis.com/tokeninfo?id_token=" . urlencode($idToken);
$verifyResponse = @file_get_contents($verifyUrl);
if ($verifyResponse === false) {
  respond("error", "Failed to verify Google token.");
}

$tokenInfo = json_decode($verifyResponse, true);
if (!is_array($tokenInfo) || empty($tokenInfo["email"])) {
  respond("error", "Invalid Google token.");
}

$email = strtolower(trim($tokenInfo["email"]));
$firstName = trim($data["first_name"] ?? "");
$lastName = trim($data["last_name"] ?? "");

// Fallback to Google profile names if not provided
if ($firstName === "" && !empty($tokenInfo["given_name"])) {
  $firstName = $tokenInfo["given_name"];
}
if ($lastName === "" && !empty($tokenInfo["family_name"])) {
  $lastName = $tokenInfo["family_name"];
}

$username = trim($data["username"] ?? "");
if ($username === "") {
  $username = explode("@", $email)[0];
}

try {
  $pdo = db();

  $stmt = $pdo->prepare("
    SELECT id, role
    FROM users
    WHERE email = ? OR username = ?
    LIMIT 1
  ");
  $stmt->execute([$email, $username]);
  $row = $stmt->fetch(PDO::FETCH_ASSOC);

  if (!$row) {
    $insert = $pdo->prepare("
      INSERT INTO users
        (firstname, middlename, lastname, username, password, email, role,
         status, is_verified, password_change, created_at)
      VALUES
        (?, ?, ?, ?, ?, ?, ?, ?, 1, 0, NOW())
    ");
    // Store a random password hash since Google auth is used.
    $randomPass = bin2hex(random_bytes(16));
    $insert->execute([
      $firstName,
      "",
      $lastName,
      $username,
      password_hash($randomPass, PASSWORD_DEFAULT),
      $email,
      "trainee",
      "active",
    ]);
  }

  respond("success", "Google sign-in ok.");
} catch (Throwable $e) {
  respond("error", "Server error: " . $e->getMessage());
}
