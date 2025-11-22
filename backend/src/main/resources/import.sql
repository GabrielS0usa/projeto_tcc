-- 1. USUÁRIOS
INSERT INTO tb_user (name, email, phone, password, birth_date) VALUES ('Gabriel', 'gabriel@gmail.com', '988888888', '$2a$10$DNMN2HxApLukaumJkRXYH.X4V5bXrvL8wg020TH27LcripPIzVPgi', '2003-06-05');

-- 2. ROLES
INSERT INTO tb_role (authority) VALUES ('ROLE_CLIENT');
INSERT INTO tb_role (authority) VALUES ('ROLE_ADMIN');
INSERT INTO tb_role (authority) VALUES ('ROLE_CAREGIVER');

-- 3. VÍNCULOS DE USER_ROLE (Gabriel=1=CLIENT, Maria=2=CAREGIVER)
INSERT INTO tb_user_role (user_id, role_id) VALUES (1, 1);
INSERT INTO tb_user_role (user_id, role_id) VALUES (2, 3);

-- 4. CUIDADOR (Depende do User Maria existir)
INSERT INTO tb_caregiver (user_id, name, email) VALUES (1, 'Gabriel_Cuidador', 'gabrielsist.inf@gmail.com');

-- 5. CONSENTIMENTO (Depende de Gabriel e Maria existirem)
INSERT INTO tb_consent (user_id, caregiver_id, active, analytics, data_sharing, notifications, last_updated) VALUES (1, 1, true, true, true, true, '2025-11-16 10:00:00');

-- 6. MEDICAMENTOS
INSERT INTO tb_medicine (user_id, name, dose, start_date, start_time, duration_days, interval_hours) VALUES (1, 'Dipirona', '500mg', '2025-11-01', '08:00:00', 30, 8);
INSERT INTO tb_medicine (user_id, name, dose, start_date, start_time, duration_days, interval_hours) VALUES (1, 'Vitamina C', '1g', '2025-11-01', '09:00:00', 60, 24);

-- 7. TASKS DE MEDICAÇÃO (Depende dos Medicamentos 1 e 2 existirem)
INSERT INTO tb_medication_task (medicine_id, scheduled_time, taken) VALUES (1, '2025-11-16 08:00:00', true);
INSERT INTO tb_medication_task (medicine_id, scheduled_time, taken) VALUES (1, '2025-11-16 16:00:00', false);
INSERT INTO tb_medication_task (medicine_id, scheduled_time, taken) VALUES (2, '2025-11-16 09:00:00', true);

-- 8. ATIVIDADES (Atenção aos IDs manuais ou ordem de inserção)
-- ID 1: Nutrição
INSERT INTO tb_activity (user_id, type, timestamp, metric_value, unit, secondary_value, quality_score, duration, description, details) VALUES (1, 'NUTRITION', '2025-11-16 12:30:00', 650, 'kcal', null, 8, 30, 'Almoço Saudável', 'Arroz integral, feijão, frango grelhado e salada');

-- ID 2: Exercício (Este é o que estava dando erro de FK antes, ele precisa ser criado antes dos metadados)
INSERT INTO tb_activity (user_id, type, timestamp, metric_value, unit, secondary_value, quality_score, duration, description, details) VALUES (1, 'EXERCISE_DONE', '2025-11-16 07:00:00', 300, 'kcal', 4.5, 9, 45, 'Caminhada no Parque', 'Ritmo moderado, sol fraco');

-- ID 3: Sono
INSERT INTO tb_activity (user_id, type, timestamp, metric_value, unit, secondary_value, quality_score, duration, description, details) VALUES (1, 'SLEEP', '2025-11-16 06:30:00', 7.5, 'hours', null, 7, 450, 'Sono Reparador', 'Acordou uma vez durante a noite');

-- ID 4: Humor
INSERT INTO tb_activity (user_id, type, timestamp, metric_value, unit, secondary_value, quality_score, description, details) VALUES (1, 'WELLNESS_LOGGED', '2025-11-16 20:00:00', 8, 'scale_1_10', null, null, 'Sentindo-se Motivado', 'Dia produtivo, boa energia');

-- ID 5: Medicação Tomada (Vinculada à Task 1)
INSERT INTO tb_activity (user_id, type, timestamp, metric_value, unit, description, medication_task_id) VALUES (1, 'MEDICATION_TAKEN', '2025-11-16 08:05:00', 1, 'dose', 'Tomou Dipirona no horário', 1);

-- 9. METADADOS (Dependem das Atividades 1 e 2 existirem)
-- Metadados da Nutrição (ID 1)
INSERT INTO activity_metadata (activity_id, meta_key, meta_value) VALUES (1, 'protein', '45g');
INSERT INTO activity_metadata (activity_id, meta_key, meta_value) VALUES (1, 'carbs', '60g');
INSERT INTO activity_metadata (activity_id, meta_key, meta_value) VALUES (1, 'fat', '15g');

-- Metadados do Exercício (ID 2) - O ERRO OCORRIA AQUI POIS O ID 2 NÃO EXISTIA
INSERT INTO activity_metadata (activity_id, meta_key, meta_value) VALUES (2, 'steps', '5500');
INSERT INTO activity_metadata (activity_id, meta_key, meta_value) VALUES (2, 'avg_heart_rate', '110bpm');

-- ============================================================
-- 10. ENTRADAS NUTRICIONAIS (Tudo em uma linha por comando)
-- ============================================================

INSERT INTO NUTRITIONAL_ENTRIES (user_id, date, food_name, meal_type, calories, protein, carbs, fat, created_at, updated_at) VALUES (1, '2025-11-16', 'Pão Integral com Ovo', 'BREAKFAST', 250, 12.0, 20.0, 10.0, '2025-11-16 08:00:00', '2025-11-16 08:00:00');

INSERT INTO NUTRITIONAL_ENTRIES (user_id, date, food_name, meal_type, calories, protein, carbs, fat, created_at, updated_at) VALUES (1, '2025-11-16', 'Arroz, Feijão e Frango Grelhado', 'LUNCH', 650, 45.0, 60.0, 15.0, '2025-11-16 12:30:00', '2025-11-16 12:30:00');

INSERT INTO NUTRITIONAL_ENTRIES (user_id, date, food_name, meal_type, calories, protein, carbs, fat, created_at, updated_at) VALUES (1, '2025-11-16', 'Maçã', 'SNACK', 52, 0.5, 14.0, 0.2, '2025-11-16 16:00:00', '2025-11-16 16:00:00');

INSERT INTO NUTRITIONAL_ENTRIES (user_id, date, food_name, meal_type, calories, protein, carbs, fat, created_at, updated_at) VALUES (1, '2025-11-16', 'Sopa de Legumes', 'DINNER', 180, 4.0, 25.0, 5.0, '2025-11-16 19:30:00', '2025-11-16 19:30:00');