<?php
require_once __DIR__ . "/db.php";
require_once __DIR__ . "/admin_auth.php";

$admin = require_admin();
$data = read_json();
$action = $data["action"] ?? "list";

if ($action === "list") {
  try {
    $pdo = db();
    $stmt = $pdo->query("
      SELECT id, firstname, middlename, lastname, username, email, role, status, is_verified, created_at
      FROM users
      ORDER BY created_at DESC
    ");
    $users = $stmt->fetchAll(PDO::FETCH_ASSOC);
    respond("success", "OK", ["users" => $users]);
  } catch (Throwable $e) {
    respond("error", "Server error: " . $e->getMessage());
  }
}

if ($action === "update") {
  $userId = intval($data["user_id"] ?? 0);
  if ($userId <= 0) {
    respond("error", "User id is required.");
  }

  $role = trim($data["role"] ?? "");
  $status = trim($data["status"] ?? "");
  $isVerified = isset($data["is_verified"]) ? intval($data["is_verified"]) : null;

  $allowedRoles = ["admin", "trainer"];
  $allowedStatus = ["active", "inactive"];

  if ($role !== "" && !in_array($role, $allowedRoles, true)) {
    respond("error", "Invalid role.");
  }
  if ($status !== "" && !in_array($status, $allowedStatus, true)) {
    respond("error", "Invalid status.");
  }

  try {
    $pdo = db();
    $stmt = $pdo->prepare("
      UPDATE users
      SET
        role = COALESCE(NULLIF(?, ''), role),
        status = COALESCE(NULLIF(?, ''), status),
        is_verified = COALESCE(?, is_verified)
      WHERE id = ?
    ");
    $stmt->execute([$role, $status, $isVerified, $userId]);
    audit_log("user_updated", $admin["email"], $admin["role"], "user", $userId, [
      "role" => $role,
      "status" => $status,
      "is_verified" => $isVerified,
    ]);
    respond("success", "User updated.");
  } catch (Throwable $e) {
    respond("error", "Server error: " . $e->getMessage());
  }
}

respond("error", "Invalid action.");
