ALTER TABLE trainee_progress
  ADD COLUMN demo_image_url VARCHAR(255) NULL,
  ADD COLUMN demo_annotated_image_url VARCHAR(255) NULL;

ALTER TABLE trainee_progress
  ADD COLUMN performance_criteria_json LONGTEXT NULL;
