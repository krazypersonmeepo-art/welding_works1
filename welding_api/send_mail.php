<?php

// Load local .env if present (for XAMPP/local dev).
if (!function_exists("load_local_env")) {
  function load_local_env() {
    static $loaded = false;
    if ($loaded) return;
    $loaded = true;

    $envPath = __DIR__ . "/.env";
    if (!file_exists($envPath)) return;

    $lines = file($envPath, FILE_IGNORE_NEW_LINES | FILE_SKIP_EMPTY_LINES);
    if (!is_array($lines)) return;

    foreach ($lines as $line) {
      $line = trim($line);
      if ($line === "" || str_starts_with($line, "#")) continue;
      $parts = explode("=", $line, 2);
      if (count($parts) !== 2) continue;
      $key = trim($parts[0]);
      $value = trim($parts[1]);
      if ($key === "" || getenv($key) !== false) continue;
      putenv("{$key}={$value}");
      $_ENV[$key] = $value;
    }
  }
}
load_local_env();

function send_mail($toEmail, $subject, $bodyText) {
  $GLOBALS["MAIL_LAST_ERROR"] = null;
  $smtpUser = getenv("SMTP_USER") ?: "";
  $smtpPass = getenv("SMTP_PASS") ?: "";
  $from = getenv("SMTP_FROM") ?: ($smtpUser !== "" ? $smtpUser : "tesdaweldingworksservice@gmail.com");
  $fromName = getenv("SMTP_FROM_NAME") ?: "Welding Works";

  $autoload = __DIR__ . "/vendor/autoload.php";
  $legacyAutoload = __DIR__ . "/PHPMailer/src/PHPMailer.php";

  if (file_exists($autoload) || file_exists($legacyAutoload)) {
    if (file_exists($autoload)) {
      require_once $autoload;
    } else {
      require_once __DIR__ . "/PHPMailer/src/PHPMailer.php";
      require_once __DIR__ . "/PHPMailer/src/SMTP.php";
      require_once __DIR__ . "/PHPMailer/src/Exception.php";
    }

    try {
      if ($smtpUser === "" || $smtpPass === "") {
        $GLOBALS["MAIL_LAST_ERROR"] = "Missing SMTP_USER or SMTP_PASS in .env/environment.";
        return false;
      }
      $mail = new \PHPMailer\PHPMailer\PHPMailer(true);
      $smtpDebug = getenv("SMTP_DEBUG") ?: "";
      if ($smtpDebug !== "") {
        $mail->SMTPDebug = intval($smtpDebug);
        $mail->Debugoutput = function ($str, $level) {
          error_log("SMTP[$level] " . $str);
        };
      }
      $mail->isSMTP();
      $mail->Host = getenv("SMTP_HOST") ?: "smtp.gmail.com";
      $mail->SMTPAuth = true;
      $mail->Username = $smtpUser;
      $mail->Password = $smtpPass;
      $mail->Port = intval(getenv("SMTP_PORT") ?: 587);
      $secure = getenv("SMTP_SECURE") ?: "tls";
      if ($secure !== "") {
        $mail->SMTPSecure = $secure;
      }
      // Gmail is strict about sender; default to SMTP user to avoid mismatch.
      if ($smtpUser !== "" && $from !== $smtpUser) {
        $from = $smtpUser;
      }
      $mail->setFrom($from, $fromName);
      $mail->addAddress($toEmail);
      $mail->Subject = $subject;
      $mail->Body = $bodyText;
      $mail->AltBody = $bodyText;
      return $mail->send();
    } catch (Throwable $e) {
      $GLOBALS["MAIL_LAST_ERROR"] = $e->getMessage();
      return false;
    }
  }

  $headers = "From: {$from}\r\n";
  $sent = @mail($toEmail, $subject, $bodyText, $headers);
  if (!$sent) {
    $GLOBALS["MAIL_LAST_ERROR"] = "php mail() failed";
  }
  return $sent;
}
