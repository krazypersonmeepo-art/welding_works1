CREATE TABLE users (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  firstname VARCHAR(80) NOT NULL,
  middlename VARCHAR(80) NULL,
  lastname VARCHAR(80) NOT NULL,
  username VARCHAR(50) NOT NULL,
  password VARCHAR(255) NOT NULL,
  email VARCHAR(120) NOT NULL,
  role VARCHAR(30) NOT NULL DEFAULT 'trainee',
  status VARCHAR(30) NOT NULL DEFAULT 'active',
  is_verified TINYINT NOT NULL DEFAULT 0,
  password_change TINYINT NOT NULL DEFAULT 0,
  verification_code VARCHAR(120) NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  last_activity_at TIMESTAMP NULL DEFAULT NULL,
  PRIMARY KEY (id),
  UNIQUE KEY uq_users_username (username),
  UNIQUE KEY uq_users_email (email)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
