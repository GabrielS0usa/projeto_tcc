INSERT INTO tb_user (name, email, phone, password, birth_date) VALUES ('Gabriel', 'gabriel@gmail.com', '988888888', '$2a$10$DNMN2HxApLukaumJkRXYH.X4V5bXrvL8wg020TH27LcripPIzVPgi', '2003-06-05');

INSERT INTO tb_role (authority) VALUES ('ROLE_CLIENT');
INSERT INTO tb_role (authority) VALUES ('ROLE_ADMIN');

INSERT INTO tb_user_role (user_id, role_id) VALUES (1, 1);
