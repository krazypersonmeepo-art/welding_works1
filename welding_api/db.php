<?php
// DB config (supports Railway MySQL env vars or manual overrides)
$DB_HOST = getenv("DB_HOST") ?: (getenv("MYSQLHOST") ?: "localhost");
$DB_PORT = getenv("DB_PORT") ?: (getenv("MYSQLPORT") ?: "3306");
$DB_NAME = getenv("DB_NAME") ?: (getenv("MYSQLDATABASE") ?: "welding_works");
$DB_USER = getenv("DB_USER") ?: (getenv("MYSQLUSER") ?: "your_db_user");
$DB_PASS = getenv("DB_PASS") ?: (getenv("MYSQLPASSWORD") ?: "your_db_password");

header("Content-Type: application/json");
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type");

if ($_SERVER["REQUEST_METHOD"] === "OPTIONS") {
  http_response_code(200);
  exit;
}

function db() {
  global $DB_HOST, $DB_PORT, $DB_NAME, $DB_USER, $DB_PASS;
  $dsn = "mysql:host={$DB_HOST};port={$DB_PORT};dbname={$DB_NAME};charset=utf8mb4";
  $pdo = new PDO($dsn, $DB_USER, $DB_PASS, [
    PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
  ]);
  return $pdo;
}

function read_json() {
  $raw = file_get_contents("php://input");
  if (!$raw) return [];
  $data = json_decode($raw, true);
  return is_array($data) ? $data : [];
}

function respond($status, $message, $extra = []) {
  echo json_encode(array_merge([
    "status" => $status,
    "message" => $message,
  ], $extra));
  exit;
}

function generate_otp() {
  return strval(random_int(100000, 999999));
}

function send_otp_email($email, $otp) {
  $subject = "Your Welding Works OTP";
  $body = "Your OTP code is: {$otp}\n\nThis code will expire soon.";
  $headers = "From: no-reply@weldingworks.page.gd\r\n";
  return @mail($email, $subject, $body, $headers);
}
