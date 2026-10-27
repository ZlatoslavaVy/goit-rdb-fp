CREATE SCHEMA pandemic;
USE pandemic;
SELECT COUNT(*) FROM infectious_cases;

CREATE TABLE IF NOT EXISTS entities (
entity_id INT AUTO_INCREMENT PRIMARY KEY,
entity VARCHAR(255) NOT NULL, 
code VARCHAR(255)
);

INSERT INTO entities (entity, code)
SELECT DISTINCT Entity, Code
FROM infectious_cases;

ALTER TABLE infectious_cases
ADD COLUMN entity_id INT;

UPDATE infectious_cases ic
JOIN entities e ON ic.Entity = e.entity 
    AND (ic.Code = e.code OR (ic.Code IS NULL AND e.code IS NULL))
SET ic.entity_id = e.entity_id;

ALTER TABLE infectious_cases
ADD CONSTRAINT fk_infectious_cases_entity
FOREIGN KEY (entity_id) REFERENCES entities(entity_id);

ALTER TABLE infectious_cases
DROP COLUMN Entity,
DROP COLUMN Code;

SELECT 
e.entity_id,
e.entity,
e.code,
	AVG(CAST(ic.Number_rabies AS DOUBLE)) AS avg_rabies,
	MIN(CAST(ic.Number_rabies AS DOUBLE)) AS min_rabies,
	MAX(CAST(ic.Number_rabies AS DOUBLE)) AS max_rabies,
	SUM(CAST(ic.Number_rabies AS DOUBLE)) AS sum_rabies
FROM entities e
INNER JOIN infectious_cases ic ON e.entity_id = ic.entity_id
WHERE ic.Number_rabies IS NOT NULL 
	AND ic.Number_rabies != ''
GROUP BY e.entity_id, e.entity, e.code 
ORDER BY avg_rabies DESC 
LIMIT 10;

SELECT 
	ic.Year, 
	MAKEDATE(ic.Year, 1) AS first_january,
	CURDATE() AS now_date,
    TIMESTAMPDIFF(YEAR, MAKEDATE(ic.Year, 1), CURDATE()) AS year_difference
FROM infectious_cases ic;

USE pandemic;
DELIMITER //
CREATE FUNCTION CalculateYearDifference(input_year INT)
RETURNS INT
DETERMINISTIC
BEGIN
	DECLARE year_diff INT;
    SET year_diff = TIMESTAMPDIFF(YEAR, MAKEDATE(input_year, 1), CURDATE());
    RETURN year_diff;
END //
DELIMITER ;

SELECT 
    ic.Year,
    CalculateYearDifference(ic.Year) AS year_difference
FROM infectious_cases ic;