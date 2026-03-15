INSERT INTO criteria (type, category, title, active, sort_order, created_at, updated_at)
SELECT 'competency', 'Perform root pass', '1.1 Root pass is performed in accordance with WPS and/or client specifications.', 1, 1, NOW(), NOW()
WHERE NOT EXISTS (
  SELECT 1 FROM criteria WHERE type = 'competency' AND category = 'Perform root pass' AND title = '1.1 Root pass is performed in accordance with WPS and/or client specifications.'
);

INSERT INTO criteria (type, category, title, active, sort_order, created_at, updated_at)
SELECT 'competency', 'Perform root pass', '1.2 Task is performed in accordance with company or industry requirement and safety procedure.', 1, 2, NOW(), NOW()
WHERE NOT EXISTS (
  SELECT 1 FROM criteria WHERE type = 'competency' AND category = 'Perform root pass' AND title = '1.2 Task is performed in accordance with company or industry requirement and safety procedure.'
);

INSERT INTO criteria (type, category, title, active, sort_order, created_at, updated_at)
SELECT 'competency', 'Perform root pass', '1.3 Weld is visually checked for defects and repaired, as required.', 1, 3, NOW(), NOW()
WHERE NOT EXISTS (
  SELECT 1 FROM criteria WHERE type = 'competency' AND category = 'Perform root pass' AND title = '1.3 Weld is visually checked for defects and repaired, as required.'
);

INSERT INTO criteria (type, category, title, active, sort_order, created_at, updated_at)
SELECT 'competency', 'Perform root pass', '1.4 Weld is visually acceptable in accordance with applicable codes and standards.', 1, 4, NOW(), NOW()
WHERE NOT EXISTS (
  SELECT 1 FROM criteria WHERE type = 'competency' AND category = 'Perform root pass' AND title = '1.4 Weld is visually acceptable in accordance with applicable codes and standards.'
);

INSERT INTO criteria (type, category, title, active, sort_order, created_at, updated_at)
SELECT 'competency', 'Clean root pass', '2.1 Root pass is cleaned and free from defects and discontinuities.', 1, 1, NOW(), NOW()
WHERE NOT EXISTS (
  SELECT 1 FROM criteria WHERE type = 'competency' AND category = 'Clean root pass' AND title = '2.1 Root pass is cleaned and free from defects and discontinuities.'
);

INSERT INTO criteria (type, category, title, active, sort_order, created_at, updated_at)
SELECT 'competency', 'Clean root pass', '2.2 Task is performed in accordance with approved WPS.', 1, 2, NOW(), NOW()
WHERE NOT EXISTS (
  SELECT 1 FROM criteria WHERE type = 'competency' AND category = 'Clean root pass' AND title = '2.2 Task is performed in accordance with approved WPS.'
);

INSERT INTO criteria (type, category, title, active, sort_order, created_at, updated_at)
SELECT 'competency', 'Weld subsequent/filling passes', '3.1 Subsequent/ filling passes is performed in accordance with approved WPS.', 1, 1, NOW(), NOW()
WHERE NOT EXISTS (
  SELECT 1 FROM criteria WHERE type = 'competency' AND category = 'Weld subsequent/filling passes' AND title = '3.1 Subsequent/ filling passes is performed in accordance with approved WPS.'
);

INSERT INTO criteria (type, category, title, active, sort_order, created_at, updated_at)
SELECT 'competency', 'Weld subsequent/filling passes', '3.2 Weld visually is checked for defects and repaired, as required.', 1, 2, NOW(), NOW()
WHERE NOT EXISTS (
  SELECT 1 FROM criteria WHERE type = 'competency' AND category = 'Weld subsequent/filling passes' AND title = '3.2 Weld visually is checked for defects and repaired, as required.'
);

INSERT INTO criteria (type, category, title, active, sort_order, created_at, updated_at)
SELECT 'competency', 'Weld subsequent/filling passes', '3.3 Weld is visually acceptable in accordance with applicable codes and standards.', 1, 3, NOW(), NOW()
WHERE NOT EXISTS (
  SELECT 1 FROM criteria WHERE type = 'competency' AND category = 'Weld subsequent/filling passes' AND title = '3.3 Weld is visually acceptable in accordance with applicable codes and standards.'
);

INSERT INTO criteria (type, category, title, active, sort_order, created_at, updated_at)
SELECT 'competency', 'Perform capping', '4.1 Capping is performed in accordance with approved WPS and/or client specifications.', 1, 1, NOW(), NOW()
WHERE NOT EXISTS (
  SELECT 1 FROM criteria WHERE type = 'competency' AND category = 'Perform capping' AND title = '4.1 Capping is performed in accordance with approved WPS and/or client specifications.'
);

INSERT INTO criteria (type, category, title, active, sort_order, created_at, updated_at)
SELECT 'competency', 'Perform capping', '4.2 Weld is visually checked for defects and repaired, as required.', 1, 2, NOW(), NOW()
WHERE NOT EXISTS (
  SELECT 1 FROM criteria WHERE type = 'competency' AND category = 'Perform capping' AND title = '4.2 Weld is visually checked for defects and repaired, as required.'
);

INSERT INTO criteria (type, category, title, active, sort_order, created_at, updated_at)
SELECT 'competency', 'Perform capping', '4.3 Weld is visually acceptable in accordance with applicable codes and standards.', 1, 3, NOW(), NOW()
WHERE NOT EXISTS (
  SELECT 1 FROM criteria WHERE type = 'competency' AND category = 'Perform capping' AND title = '4.3 Weld is visually acceptable in accordance with applicable codes and standards.'
);

INSERT INTO criteria (type, category, title, active, sort_order, created_at, updated_at)
SELECT 'competency', 'Defects (Surface Level)', '2.1 Porosity', 1, 1, NOW(), NOW()
WHERE NOT EXISTS (
  SELECT 1 FROM criteria WHERE type = 'competency' AND category = 'Defects (Surface Level)' AND title = '2.1 Porosity'
);

INSERT INTO criteria (type, category, title, active, sort_order, created_at, updated_at)
SELECT 'competency', 'Defects (Surface Level)', '2.2 Undercut', 1, 2, NOW(), NOW()
WHERE NOT EXISTS (
  SELECT 1 FROM criteria WHERE type = 'competency' AND category = 'Defects (Surface Level)' AND title = '2.2 Undercut'
);

INSERT INTO criteria (type, category, title, active, sort_order, created_at, updated_at)
SELECT 'competency', 'Defects (Surface Level)', '2.3 Arc Strike', 1, 3, NOW(), NOW()
WHERE NOT EXISTS (
  SELECT 1 FROM criteria WHERE type = 'competency' AND category = 'Defects (Surface Level)' AND title = '2.3 Arc Strike'
);

INSERT INTO criteria (type, category, title, active, sort_order, created_at, updated_at)
SELECT 'competency', 'Defects (Surface Level)', '2.4 Spatters', 1, 4, NOW(), NOW()
WHERE NOT EXISTS (
  SELECT 1 FROM criteria WHERE type = 'competency' AND category = 'Defects (Surface Level)' AND title = '2.4 Spatters'
);

INSERT INTO criteria (type, category, title, active, sort_order, created_at, updated_at)
SELECT 'competency', 'Defects (Surface Level)', '2.5 Burn Through', 1, 5, NOW(), NOW()
WHERE NOT EXISTS (
  SELECT 1 FROM criteria WHERE type = 'competency' AND category = 'Defects (Surface Level)' AND title = '2.5 Burn Through'
);

INSERT INTO criteria (type, category, title, active, sort_order, created_at, updated_at)
SELECT 'competency', 'Defects (Surface Level)', '2.6 Crater cracks', 1, 6, NOW(), NOW()
WHERE NOT EXISTS (
  SELECT 1 FROM criteria WHERE type = 'competency' AND category = 'Defects (Surface Level)' AND title = '2.6 Crater cracks'
);

INSERT INTO criteria (type, category, title, active, sort_order, created_at, updated_at)
SELECT 'competency', 'Defects (Surface Level)', '2.7 Cracks', 1, 7, NOW(), NOW()
WHERE NOT EXISTS (
  SELECT 1 FROM criteria WHERE type = 'competency' AND category = 'Defects (Surface Level)' AND title = '2.7 Cracks'
);

INSERT INTO criteria (type, category, title, active, sort_order, created_at, updated_at)
SELECT 'competency', 'Defects (Surface Level)', '2.8 Pinholes/Blowholes', 1, 8, NOW(), NOW()
WHERE NOT EXISTS (
  SELECT 1 FROM criteria WHERE type = 'competency' AND category = 'Defects (Surface Level)' AND title = '2.8 Pinholes/Blowholes'
);

INSERT INTO criteria (type, category, title, active, sort_order, created_at, updated_at)
SELECT 'competency', 'Defects (Surface Level)', '2.9 Overlap', 1, 9, NOW(), NOW()
WHERE NOT EXISTS (
  SELECT 1 FROM criteria WHERE type = 'competency' AND category = 'Defects (Surface Level)' AND title = '2.9 Overlap'
);

INSERT INTO criteria (type, category, title, active, sort_order, created_at, updated_at)
SELECT 'competency', 'Defects (Surface Level)', '2.10 Misalignment', 1, 10, NOW(), NOW()
WHERE NOT EXISTS (
  SELECT 1 FROM criteria WHERE type = 'competency' AND category = 'Defects (Surface Level)' AND title = '2.10 Misalignment'
);

INSERT INTO criteria (type, category, title, active, sort_order, created_at, updated_at)
SELECT 'competency', 'Defects (Non-Surface Level)', '2.11 Distortion', 1, 1, NOW(), NOW()
WHERE NOT EXISTS (
  SELECT 1 FROM criteria WHERE type = 'competency' AND category = 'Defects (Non-Surface Level)' AND title = '2.11 Distortion'
);

INSERT INTO criteria (type, category, title, active, sort_order, created_at, updated_at)
SELECT 'competency', 'Defects (Non-Surface Level)', '2.12 Slag inclusion', 1, 2, NOW(), NOW()
WHERE NOT EXISTS (
  SELECT 1 FROM criteria WHERE type = 'competency' AND category = 'Defects (Non-Surface Level)' AND title = '2.12 Slag inclusion'
);

INSERT INTO criteria (type, category, title, active, sort_order, created_at, updated_at)
SELECT 'competency', 'Defects (Non-Surface Level)', '2.13 Concavity/convexity', 1, 3, NOW(), NOW()
WHERE NOT EXISTS (
  SELECT 1 FROM criteria WHERE type = 'competency' AND category = 'Defects (Non-Surface Level)' AND title = '2.13 Concavity/convexity'
);

INSERT INTO criteria (type, category, title, active, sort_order, created_at, updated_at)
SELECT 'competency', 'Defects (Non-Surface Level)', '2.14 Degree of reinforcement', 1, 4, NOW(), NOW()
WHERE NOT EXISTS (
  SELECT 1 FROM criteria WHERE type = 'competency' AND category = 'Defects (Non-Surface Level)' AND title = '2.14 Degree of reinforcement'
);

INSERT INTO criteria (type, category, title, active, sort_order, created_at, updated_at)
SELECT 'competency', 'Defects (Non-Surface Level)', '2.15 Lack of Fusion', 1, 5, NOW(), NOW()
WHERE NOT EXISTS (
  SELECT 1 FROM criteria WHERE type = 'competency' AND category = 'Defects (Non-Surface Level)' AND title = '2.15 Lack of Fusion'
);

INSERT INTO criteria (type, category, title, active, sort_order, created_at, updated_at)
SELECT 'competency', 'Defects (Non-Surface Level)', '2.16 Under Fill', 1, 6, NOW(), NOW()
WHERE NOT EXISTS (
  SELECT 1 FROM criteria WHERE type = 'competency' AND category = 'Defects (Non-Surface Level)' AND title = '2.16 Under Fill'
);

INSERT INTO criteria (type, category, title, active, sort_order, created_at, updated_at)
SELECT 'grading', 'Grading', 'Competency Grade', 1, 1, NOW(), NOW()
WHERE NOT EXISTS (
  SELECT 1 FROM criteria WHERE type = 'grading' AND category = 'Grading' AND title = 'Competency Grade'
);

UPDATE criteria SET weight_percent = 25
WHERE type = 'grading' AND category = 'Grading' AND title = 'Competency Grade' AND (weight_percent IS NULL OR weight_percent = '');

INSERT INTO criteria (type, category, title, active, sort_order, created_at, updated_at)
SELECT 'grading', 'Grading', 'Lecture Units (Total Grade)', 1, 2, NOW(), NOW()
WHERE NOT EXISTS (
  SELECT 1 FROM criteria WHERE type = 'grading' AND category = 'Grading' AND title = 'Lecture Units (Total Grade)'
);

UPDATE criteria SET weight_percent = 25
WHERE type = 'grading' AND category = 'Grading' AND title = 'Lecture Units (Total Grade)' AND (weight_percent IS NULL OR weight_percent = '');

INSERT INTO criteria (type, category, title, active, sort_order, created_at, updated_at)
SELECT 'grading', 'Grading', 'Written Final Exam', 1, 3, NOW(), NOW()
WHERE NOT EXISTS (
  SELECT 1 FROM criteria WHERE type = 'grading' AND category = 'Grading' AND title = 'Written Final Exam'
);

UPDATE criteria SET weight_percent = 10
WHERE type = 'grading' AND category = 'Grading' AND title = 'Written Final Exam' AND (weight_percent IS NULL OR weight_percent = '');

INSERT INTO criteria (type, category, title, active, sort_order, created_at, updated_at)
SELECT 'grading', 'Grading', 'Skills / Demonstration', 1, 4, NOW(), NOW()
WHERE NOT EXISTS (
  SELECT 1 FROM criteria WHERE type = 'grading' AND category = 'Grading' AND title = 'Skills / Demonstration'
);

UPDATE criteria SET weight_percent = 50
WHERE type = 'grading' AND category = 'Grading' AND title = 'Skills / Demonstration' AND (weight_percent IS NULL OR weight_percent = '');

INSERT INTO criteria (type, category, title, active, sort_order, created_at, updated_at)
SELECT 'grading', 'Grading', 'Class Participation', 1, 5, NOW(), NOW()
WHERE NOT EXISTS (
  SELECT 1 FROM criteria WHERE type = 'grading' AND category = 'Grading' AND title = 'Class Participation'
);

UPDATE criteria SET weight_percent = 20
WHERE type = 'grading' AND category = 'Grading' AND title = 'Class Participation' AND (weight_percent IS NULL OR weight_percent = '');

INSERT INTO criteria (type, category, title, active, sort_order, created_at, updated_at)
SELECT 'grading', 'Grading', 'Seat Work', 1, 6, NOW(), NOW()
WHERE NOT EXISTS (
  SELECT 1 FROM criteria WHERE type = 'grading' AND category = 'Grading' AND title = 'Seat Work'
);

UPDATE criteria SET weight_percent = 10
WHERE type = 'grading' AND category = 'Grading' AND title = 'Seat Work' AND (weight_percent IS NULL OR weight_percent = '');

INSERT INTO criteria (type, category, title, active, sort_order, created_at, updated_at)
SELECT 'grading', 'Grading', 'Quiz', 1, 7, NOW(), NOW()
WHERE NOT EXISTS (
  SELECT 1 FROM criteria WHERE type = 'grading' AND category = 'Grading' AND title = 'Quiz'
);

UPDATE criteria SET weight_percent = 10
WHERE type = 'grading' AND category = 'Grading' AND title = 'Quiz' AND (weight_percent IS NULL OR weight_percent = '');

INSERT INTO criteria (type, category, title, active, sort_order, created_at, updated_at)
SELECT 'grading', 'Grading', 'Oral Questioning', 1, 8, NOW(), NOW()
WHERE NOT EXISTS (
  SELECT 1 FROM criteria WHERE type = 'grading' AND category = 'Grading' AND title = 'Oral Questioning'
);

UPDATE criteria SET weight_percent = 25
WHERE type = 'grading' AND category = 'Grading' AND title = 'Oral Questioning' AND (weight_percent IS NULL OR weight_percent = '');

INSERT INTO criteria (type, category, title, active, sort_order, created_at, updated_at)
SELECT 'grading', 'Grading', 'Task Performance', 1, 9, NOW(), NOW()
WHERE NOT EXISTS (
  SELECT 1 FROM criteria WHERE type = 'grading' AND category = 'Grading' AND title = 'Task Performance'
);

INSERT INTO criteria (type, category, title, active, sort_order, created_at, updated_at)
SELECT 'grading', 'Grading', 'Skill Demo (Total Grade)', 1, 10, NOW(), NOW()
WHERE NOT EXISTS (
  SELECT 1 FROM criteria WHERE type = 'grading' AND category = 'Grading' AND title = 'Skill Demo (Total Grade)'
);

UPDATE criteria SET weight_percent = 50
WHERE type = 'grading' AND category = 'Grading' AND title = 'Skill Demo (Total Grade)' AND (weight_percent IS NULL OR weight_percent = '');

INSERT INTO criteria (type, category, title, active, sort_order, created_at, updated_at)
SELECT 'grading', 'Grading', 'Demo', 1, 11, NOW(), NOW()
WHERE NOT EXISTS (
  SELECT 1 FROM criteria WHERE type = 'grading' AND category = 'Grading' AND title = 'Demo'
);

UPDATE criteria SET weight_percent = 80
WHERE type = 'grading' AND category = 'Grading' AND title = 'Demo' AND (weight_percent IS NULL OR weight_percent = '');

INSERT INTO criteria (type, category, title, active, sort_order, created_at, updated_at)
SELECT 'grading', 'Grading', 'Case of studies/projects', 1, 12, NOW(), NOW()
WHERE NOT EXISTS (
  SELECT 1 FROM criteria WHERE type = 'grading' AND category = 'Grading' AND title = 'Case of studies/projects'
);

UPDATE criteria SET weight_percent = 20
WHERE type = 'grading' AND category = 'Grading' AND title = 'Case of studies/projects' AND (weight_percent IS NULL OR weight_percent = '');

INSERT INTO criteria (type, category, title, active, sort_order, created_at, updated_at)
SELECT 'grading', 'Grading', 'Total', 1, 13, NOW(), NOW()
WHERE NOT EXISTS (
  SELECT 1 FROM criteria WHERE type = 'grading' AND category = 'Grading' AND title = 'Total'
);

UPDATE criteria SET weight_percent = 100
WHERE type = 'grading' AND category = 'Grading' AND title = 'Total' AND (weight_percent IS NULL OR weight_percent = '');

INSERT INTO criteria (type, category, title, active, sort_order, created_at, updated_at)
SELECT 'grading', 'Scale', 'Outstanding (A) - 90-100', 1, 20, NOW(), NOW()
WHERE NOT EXISTS (
  SELECT 1 FROM criteria WHERE type = 'grading' AND category = 'Scale' AND title = 'Outstanding (A) - 90-100'
);

UPDATE criteria SET scale_range = '90-100', remark = 'Competent'
WHERE type = 'grading' AND category = 'Scale' AND title LIKE 'Outstanding (A)%' AND (scale_range IS NULL OR scale_range = '');

INSERT INTO criteria (type, category, title, active, sort_order, created_at, updated_at)
SELECT 'grading', 'Scale', 'Very satisfactory (B) - 85-89', 1, 21, NOW(), NOW()
WHERE NOT EXISTS (
  SELECT 1 FROM criteria WHERE type = 'grading' AND category = 'Scale' AND title = 'Very satisfactory (B) - 85-89'
);

UPDATE criteria SET scale_range = '85-89', remark = 'Competent'
WHERE type = 'grading' AND category = 'Scale' AND title LIKE 'Very satisfactory (B)%' AND (scale_range IS NULL OR scale_range = '');

INSERT INTO criteria (type, category, title, active, sort_order, created_at, updated_at)
SELECT 'grading', 'Scale', 'Satisfactory (C) - 80-84', 1, 22, NOW(), NOW()
WHERE NOT EXISTS (
  SELECT 1 FROM criteria WHERE type = 'grading' AND category = 'Scale' AND title = 'Satisfactory (C) - 80-84'
);

UPDATE criteria SET scale_range = '80-84', remark = 'Competent'
WHERE type = 'grading' AND category = 'Scale' AND title LIKE 'Satisfactory (C)%' AND (scale_range IS NULL OR scale_range = '');

INSERT INTO criteria (type, category, title, active, sort_order, created_at, updated_at)
SELECT 'grading', 'Scale', 'Fair Satisfactory (D) - 75-79', 1, 23, NOW(), NOW()
WHERE NOT EXISTS (
  SELECT 1 FROM criteria WHERE type = 'grading' AND category = 'Scale' AND title = 'Fair Satisfactory (D) - 75-79'
);

UPDATE criteria SET scale_range = '75-79', remark = 'Competent'
WHERE type = 'grading' AND category = 'Scale' AND title LIKE 'Fair Satisfactory (D)%' AND (scale_range IS NULL OR scale_range = '');

INSERT INTO criteria (type, category, title, active, sort_order, created_at, updated_at)
SELECT 'grading', 'Scale', 'Did not meet expectations - Below 75', 1, 24, NOW(), NOW()
WHERE NOT EXISTS (
  SELECT 1 FROM criteria WHERE type = 'grading' AND category = 'Scale' AND title = 'Did not meet expectations - Below 75'
);

UPDATE criteria SET scale_range = 'Below 75', remark = 'Not yet Competent'
WHERE type = 'grading' AND category = 'Scale' AND title LIKE 'Did not meet expectations%' AND (scale_range IS NULL OR scale_range = '');
