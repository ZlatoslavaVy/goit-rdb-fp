DROP SCHEMA IF EXISTS pandemic;
CREATE SCHEMA pandemic;
USE pandemic;


-- 1. Создаем таблицу-справочник
CREATE TABLE IF NOT EXISTS entities (
    entity_id INT AUTO_INCREMENT PRIMARY KEY,
    entity VARCHAR(255) NOT NULL,
    code VARCHAR(255)
);

-- 2. Заполняем уникальными значениями
INSERT INTO entities (entity, code)
SELECT DISTINCT Entity, Code
FROM infectious_cases;

-- 3. Добавляем колонку entity_id
ALTER TABLE infectious_cases
ADD COLUMN entity_id INT;

SET SQL_SAFE_UPDATES = 0;

-- 4. Заполняем entity_id (используем NULL-safe сравнение <=>)
UPDATE infectious_cases ic
JOIN entities e 
  ON ic.Entity = e.entity 
 AND (ic.Code <=> e.code)
SET ic.entity_id = e.entity_id;

-- 5. Проверяем, что NULL больше нет (должно вернуть 0)
SELECT COUNT(*) FROM infectious_cases WHERE entity_id IS NULL;

-- 6. Добавляем внешний ключ
ALTER TABLE infectious_cases
ADD CONSTRAINT fk_infectious_cases_entity
FOREIGN KEY (entity_id) REFERENCES entities(entity_id);

-- 7. Только ПОСЛЕ успешного UPDATE и проверки удаляем старые колонки
ALTER TABLE infectious_cases
DROP COLUMN Entity,
DROP COLUMN Code;