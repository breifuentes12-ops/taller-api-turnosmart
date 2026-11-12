SET NAMES utf8mb4;
USE turnosmart_campus;


-- Tablas

CREATE TABLE rol (
    id_rol INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(50) NOT NULL UNIQUE
) ENGINE=InnoDB;

CREATE TABLE servicio (
    id_servicio INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL UNIQUE,
    descripcion VARCHAR(255),
    tiempo_estimado_min DECIMAL(5,2) NOT NULL DEFAULT 10.00,
    estado BOOLEAN NOT NULL DEFAULT TRUE
) ENGINE=InnoDB;

CREATE TABLE ventanilla (
    id_ventanilla INT AUTO_INCREMENT PRIMARY KEY,
    numero INT NOT NULL UNIQUE,
    ubicacion VARCHAR(100),
    estado BOOLEAN NOT NULL DEFAULT TRUE
) ENGINE=InnoDB;

CREATE TABLE usuario (
    id_usuario INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(50) NOT NULL,
    apellido VARCHAR(50) NOT NULL,
    correo VARCHAR(100) NOT NULL UNIQUE,
    contrasena VARCHAR(255) NOT NULL,
    id_rol INT NOT NULL,
    CONSTRAINT fk_usuario_rol FOREIGN KEY (id_rol) REFERENCES rol(id_rol)
) ENGINE=InnoDB;

CREATE TABLE horario (
    id_horario INT AUTO_INCREMENT PRIMARY KEY,
    dia VARCHAR(20) NOT NULL,
    hora_inicio TIME NOT NULL,
    hora_fin TIME NOT NULL,
    id_servicio INT NOT NULL,
    CONSTRAINT fk_horario_servicio FOREIGN KEY (id_servicio) REFERENCES servicio(id_servicio)
) ENGINE=InnoDB;

CREATE TABLE empleado (
    id_empleado INT AUTO_INCREMENT PRIMARY KEY,
    id_usuario INT NOT NULL,
    id_servicio INT NOT NULL,
    estado BOOLEAN NOT NULL DEFAULT TRUE,
    CONSTRAINT fk_empleado_usuario FOREIGN KEY (id_usuario) REFERENCES usuario(id_usuario),
    CONSTRAINT fk_empleado_servicio FOREIGN KEY (id_servicio) REFERENCES servicio(id_servicio),
    CONSTRAINT uq_empleado_usuario UNIQUE (id_usuario)
) ENGINE=InnoDB;

CREATE TABLE turno (
    id_turno INT AUTO_INCREMENT PRIMARY KEY,
    numero_turno VARCHAR(10) NOT NULL,
    fecha DATE NOT NULL,
    hora_solicitud TIME NOT NULL,
    prioridad ENUM('Normal','Prioritario') NOT NULL DEFAULT 'Normal',
    estado ENUM('Esperando','Atendiendo','Atendido','Cancelado','No asistio') NOT NULL DEFAULT 'Esperando',
    id_usuario INT NOT NULL,
    id_servicio INT NOT NULL,
    CONSTRAINT fk_turno_usuario FOREIGN KEY (id_usuario) REFERENCES usuario(id_usuario),
    CONSTRAINT fk_turno_servicio FOREIGN KEY (id_servicio) REFERENCES servicio(id_servicio),
    CONSTRAINT uq_turno_numero_fecha UNIQUE (numero_turno, fecha)
) ENGINE=InnoDB;

CREATE TABLE atencion (
    id_atencion INT AUTO_INCREMENT PRIMARY KEY,
    hora_inicio TIME,
    hora_fin TIME,
    observacion VARCHAR(255),
    id_turno INT NOT NULL,
    id_empleado INT NOT NULL,
    id_ventanilla INT NOT NULL,
    CONSTRAINT fk_atencion_turno FOREIGN KEY (id_turno) REFERENCES turno(id_turno),
    CONSTRAINT fk_atencion_empleado FOREIGN KEY (id_empleado) REFERENCES empleado(id_empleado),
    CONSTRAINT fk_atencion_ventanilla FOREIGN KEY (id_ventanilla) REFERENCES ventanilla(id_ventanilla),
    CONSTRAINT uq_atencion_turno UNIQUE (id_turno)
) ENGINE=InnoDB;

CREATE TABLE historial_auditoria (
    id_auditoria INT AUTO_INCREMENT PRIMARY KEY,
    tabla_afectada VARCHAR(64) NOT NULL,
    id_registro INT NOT NULL,
    fecha_accion DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    accion VARCHAR(20) NOT NULL
) ENGINE=InnoDB;

CREATE TABLE proyeccion_atencion (
    id_turno INT PRIMARY KEY,
    duracion_estimada_min DECIMAL(7,2) NOT NULL,
    hora_fin_estimada TIME,
    fecha_calculo DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_proyeccion_turno FOREIGN KEY (id_turno) REFERENCES turno(id_turno)
) ENGINE=InnoDB;


-- Datos

INSERT INTO rol (id_rol, nombre) VALUES
    (1, 'Administrador'),
    (2, 'Empleado'),
    (3, 'Estudiante de pregrado'),
    (4, 'Estudiante de posgrado'),
    (5, 'Docente de planta'),
    (6, 'Docente catedrático'),
    (7, 'Docente ocasional'),
    (8, 'Egresado'),
    (9, 'Personal administrativo'),
    (10, 'Investigador'),
    (11, 'Visitante'),
    (12, 'Monitor académico'),
    (13, 'Estudiante de intercambio'),
    (14, 'Contratista'),
    (15, 'Jubilado');

INSERT INTO servicio (id_servicio, nombre, descripcion, tiempo_estimado_min, estado) VALUES
    (1, 'Registro académico', 'Matrículas, certificados y notas', 12.00, TRUE),
    (2, 'Biblioteca', 'Préstamo y devolución de material bibliográfico', 6.00, TRUE),
    (3, 'Bienestar universitario', 'Apoyos, becas y actividades de bienestar', 15.00, TRUE),
    (4, 'Soporte tecnológico', 'Correo institucional, redes y equipos', 20.00, TRUE),
    (5, 'Tesorería', 'Pagos, recibos y devoluciones', 8.00, TRUE),
    (6, 'Admisiones', 'Inscripciones y orientación a aspirantes', 15.00, TRUE),
    (7, 'Servicio médico', 'Atención médica básica para la comunidad', 20.00, TRUE),
    (8, 'Egresados', 'Carnet, bolsa de empleo y actualización de datos', 10.00, TRUE),
    (9, 'Centro de idiomas', 'Inscripción y pruebas de clasificación', 12.00, TRUE),
    (10, 'Deportes y recreación', 'Inscripción a selecciones y préstamo de escenarios', 8.00, TRUE),
    (11, 'Carnetización', 'Expedición y reposición de carnet', 5.00, TRUE),
    (12, 'Secretaría general', 'Certificaciones y trámites de grado', 18.00, TRUE),
    (13, 'Laboratorios', 'Reserva de laboratorios y equipos (en remodelación)', 10.00, FALSE),
    (14, 'Asesoría psicológica', 'Orientación y acompañamiento psicológico', 30.00, TRUE),
    (15, 'Financiación estudiantil', 'Créditos y convenios de pago', 25.00, TRUE);

INSERT INTO ventanilla (id_ventanilla, numero, ubicacion, estado) VALUES
    (1, 1, 'Edificio Administrativo - Piso 1', TRUE),
    (2, 2, 'Biblioteca Central - Piso 1', TRUE),
    (3, 3, 'Edificio de Bienestar - Piso 1', TRUE),
    (4, 4, 'Edificio de Sistemas - Piso 2', TRUE),
    (5, 5, 'Edificio Administrativo - Piso 1', TRUE),
    (6, 6, 'Edificio Administrativo - Piso 2', TRUE),
    (7, 7, 'Centro de Salud - Piso 1', TRUE),
    (8, 8, 'Edificio Administrativo - Piso 3', TRUE),
    (9, 9, 'Edificio de Idiomas - Piso 1', TRUE),
    (10, 10, 'Coliseo Deportivo - Entrada principal', TRUE),
    (11, 11, 'Edificio Administrativo - Piso 1', TRUE),
    (12, 12, 'Edificio Administrativo - Piso 3', TRUE),
    (13, 13, 'Edificio de Laboratorios - Piso 1 (en mantenimiento)', FALSE),
    (14, 14, 'Edificio de Bienestar - Piso 2', TRUE),
    (15, 15, 'Edificio Administrativo - Piso 2', TRUE);

INSERT INTO usuario (id_usuario, nombre, apellido, correo, contrasena, id_rol) VALUES
    (1, 'Carlos', 'Mendoza', 'carlos.mendoza@unicordoba.edu.co', SHA2('Admin2026*', 256), 1),
    (2, 'Marta', 'Hoyos', 'marta.hoyos@unicordoba.edu.co', SHA2('Admin2026*', 256), 1),
    (3, 'Laura', 'Pérez', 'laura.perez@unicordoba.edu.co', SHA2('Emp2026*', 256), 2),
    (4, 'Juan', 'Martínez', 'juan.martinez@unicordoba.edu.co', SHA2('Emp2026*', 256), 2),
    (5, 'Sofía', 'Ramos', 'sofia.ramos@unicordoba.edu.co', SHA2('Emp2026*', 256), 2),
    (6, 'Andrés', 'Vergara', 'andres.vergara@unicordoba.edu.co', SHA2('Emp2026*', 256), 2),
    (7, 'Paola', 'Castillo', 'paola.castillo@unicordoba.edu.co', SHA2('Emp2026*', 256), 2),
    (8, 'Camilo', 'Ortega', 'camilo.ortega@unicordoba.edu.co', SHA2('Emp2026*', 256), 2),
    (9, 'Diana', 'Barrios', 'diana.barrios@unicordoba.edu.co', SHA2('Emp2026*', 256), 2),
    (10, 'Felipe', 'Zuluaga', 'felipe.zuluaga@unicordoba.edu.co', SHA2('Emp2026*', 256), 2),
    (11, 'Natalia', 'Arrieta', 'natalia.arrieta@unicordoba.edu.co', SHA2('Emp2026*', 256), 2),
    (12, 'Hernán', 'Guerra', 'hernan.guerra@unicordoba.edu.co', SHA2('Emp2026*', 256), 2),
    (13, 'Luisa', 'Bello', 'luisa.bello@unicordoba.edu.co', SHA2('Emp2026*', 256), 2),
    (14, 'Ricardo', 'Pastrana', 'ricardo.pastrana@unicordoba.edu.co', SHA2('Emp2026*', 256), 2),
    (15, 'Yesenia', 'Contreras', 'yesenia.contreras@unicordoba.edu.co', SHA2('Emp2026*', 256), 2),
    (16, 'Mauricio', 'Salgado', 'mauricio.salgado@unicordoba.edu.co', SHA2('Emp2026*', 256), 2),
    (17, 'Daniela', 'Petro', 'daniela.petro@unicordoba.edu.co', SHA2('Emp2026*', 256), 2),
    (18, 'Esteban', 'Doria', 'esteban.doria@unicordoba.edu.co', SHA2('Emp2026*', 256), 2),
    (19, 'Valentina', 'Mercado', 'valentina.mercado@unicordoba.edu.co', SHA2('Emp2026*', 256), 2),
    (20, 'Jorge', 'Hernández', 'jorge.hernandez@unicordoba.edu.co', SHA2('Emp2026*', 256), 2),
    (21, 'Isabel', 'Támara', 'isabel.tamara@unicordoba.edu.co', SHA2('Emp2026*', 256), 2),
    (22, 'Sebastián', 'Oviedo', 'sebastian.oviedo@unicordoba.edu.co', SHA2('Emp2026*', 256), 2),
    (23, 'Breiner', 'Fuentes', 'breiner.fuentes@correo.unicordoba.edu.co', SHA2('User2026*', 256), 3),
    (24, 'María', 'Torres', 'maria.torres@correo.unicordoba.edu.co', SHA2('User2026*', 256), 3),
    (25, 'Pedro', 'Salas', 'pedro.salas@correo.unicordoba.edu.co', SHA2('User2026*', 256), 3),
    (26, 'Ana', 'Ruiz', 'ana.ruiz@correo.unicordoba.edu.co', SHA2('User2026*', 256), 3),
    (27, 'Luis', 'Cabrera', 'luis.cabrera@correo.unicordoba.edu.co', SHA2('User2026*', 256), 3),
    (28, 'Karen', 'Padilla', 'karen.padilla@correo.unicordoba.edu.co', SHA2('User2026*', 256), 4),
    (29, 'Jhon', 'Álvarez', 'jhon.alvarez@correo.unicordoba.edu.co', SHA2('User2026*', 256), 4),
    (30, 'Mónica', 'Suárez', 'monica.suarez@correo.unicordoba.edu.co', SHA2('User2026*', 256), 5),
    (31, 'Santiago', 'Peña', 'santiago.pena@correo.unicordoba.edu.co', SHA2('User2026*', 256), 5),
    (32, 'Tatiana', 'Gómez', 'tatiana.gomez@correo.unicordoba.edu.co', SHA2('User2026*', 256), 6),
    (33, 'Óscar', 'Villadiego', 'oscar.villadiego@correo.unicordoba.edu.co', SHA2('User2026*', 256), 7),
    (34, 'Lorena', 'Banda', 'lorena.banda@correo.unicordoba.edu.co', SHA2('User2026*', 256), 8),
    (35, 'Wilmer', 'Montes', 'wilmer.montes@correo.unicordoba.edu.co', SHA2('User2026*', 256), 8),
    (36, 'Claudia', 'Navarro', 'claudia.navarro@correo.unicordoba.edu.co', SHA2('User2026*', 256), 9),
    (37, 'Alexander', 'Berrío', 'alexander.berrio@correo.unicordoba.edu.co', SHA2('User2026*', 256), 10),
    (38, 'Gisela', 'Montalvo', 'gisela.montalvo@correo.unicordoba.edu.co', SHA2('User2026*', 256), 11),
    (39, 'Dairo', 'Herazo', 'dairo.herazo@correo.unicordoba.edu.co', SHA2('User2026*', 256), 12),
    (40, 'Yurany', 'Lozano', 'yurany.lozano@correo.unicordoba.edu.co', SHA2('User2026*', 256), 13),
    (41, 'Manuel', 'Cogollo', 'manuel.cogollo@correo.unicordoba.edu.co', SHA2('User2026*', 256), 14),
    (42, 'Estefanía', 'Cárdenas', 'estefania.cardenas@correo.unicordoba.edu.co', SHA2('User2026*', 256), 15);

INSERT INTO empleado (id_empleado, id_usuario, id_servicio, estado) VALUES
    (1, 3, 1, TRUE),
    (2, 4, 2, TRUE),
    (3, 5, 3, TRUE),
    (4, 6, 4, TRUE),
    (5, 7, 5, TRUE),
    (6, 8, 6, TRUE),
    (7, 9, 7, TRUE),
    (8, 10, 8, TRUE),
    (9, 11, 9, TRUE),
    (10, 12, 10, TRUE),
    (11, 13, 11, TRUE),
    (12, 14, 12, TRUE),
    (13, 15, 13, FALSE),
    (14, 16, 14, TRUE),
    (15, 17, 15, TRUE),
    (16, 18, 1, TRUE),
    (17, 19, 2, TRUE),
    (18, 20, 3, TRUE),
    (19, 21, 4, TRUE),
    (20, 22, 5, FALSE);

INSERT INTO horario (id_horario, dia, hora_inicio, hora_fin, id_servicio) VALUES
    (1, 'Lunes a Viernes', '08:00:00', '12:00:00', 1),
    (2, 'Lunes a Viernes', '14:00:00', '18:00:00', 1),
    (3, 'Lunes a Viernes', '08:00:00', '12:00:00', 2),
    (4, 'Lunes a Viernes', '14:00:00', '18:00:00', 2),
    (5, 'Lunes a Viernes', '08:00:00', '12:00:00', 3),
    (6, 'Lunes a Viernes', '14:00:00', '18:00:00', 3),
    (7, 'Lunes a Viernes', '08:00:00', '12:00:00', 4),
    (8, 'Lunes a Viernes', '14:00:00', '18:00:00', 4),
    (9, 'Lunes a Viernes', '08:00:00', '12:00:00', 5),
    (10, 'Lunes a Viernes', '14:00:00', '18:00:00', 5),
    (11, 'Lunes a Viernes', '08:00:00', '12:00:00', 6),
    (12, 'Lunes a Viernes', '14:00:00', '18:00:00', 6),
    (13, 'Lunes a Viernes', '07:00:00', '12:00:00', 7),
    (14, 'Lunes a Viernes', '14:00:00', '17:00:00', 7),
    (15, 'Lunes a Viernes', '08:00:00', '12:00:00', 8),
    (16, 'Lunes a Viernes', '14:00:00', '18:00:00', 8),
    (17, 'Lunes a Viernes', '08:00:00', '12:00:00', 9),
    (18, 'Lunes a Viernes', '14:00:00', '18:00:00', 9),
    (19, 'Lunes a Viernes', '08:00:00', '12:00:00', 10),
    (20, 'Lunes a Viernes', '14:00:00', '18:00:00', 10),
    (21, 'Lunes a Viernes', '08:00:00', '12:00:00', 11),
    (22, 'Lunes a Viernes', '14:00:00', '18:00:00', 11),
    (23, 'Lunes a Viernes', '08:00:00', '12:00:00', 12),
    (24, 'Lunes a Viernes', '14:00:00', '18:00:00', 12),
    (25, 'Lunes a Viernes', '08:00:00', '12:00:00', 13),
    (26, 'Lunes a Viernes', '14:00:00', '18:00:00', 13),
    (27, 'Lunes a Viernes', '08:00:00', '12:00:00', 14),
    (28, 'Lunes a Viernes', '14:00:00', '17:00:00', 14),
    (29, 'Lunes a Viernes', '08:00:00', '12:00:00', 15),
    (30, 'Lunes a Viernes', '14:00:00', '18:00:00', 15),
    (31, 'Sábado', '08:00:00', '12:00:00', 2),
    (32, 'Sábado', '08:00:00', '12:00:00', 6),
    (33, 'Sábado', '08:00:00', '12:00:00', 10);

INSERT INTO turno (id_turno, numero_turno, fecha, hora_solicitud, prioridad, estado, id_usuario, id_servicio) VALUES
    (1, 'ST001', '2026-10-05', '08:29:00', 'Normal', 'Atendido', 34, 4),
    (2, 'CI001', '2026-10-05', '09:42:00', 'Normal', 'Atendido', 35, 9),
    (3, 'CA001', '2026-10-05', '09:57:00', 'Normal', 'Atendido', 39, 11),
    (4, 'CA002', '2026-10-05', '09:58:00', 'Normal', 'No asistio', 25, 11),
    (5, 'ST002', '2026-10-05', '10:45:00', 'Prioritario', 'Atendido', 33, 4),
    (6, 'TE001', '2026-10-05', '11:01:00', 'Normal', 'Atendido', 24, 5),
    (7, 'DR001', '2026-10-05', '15:10:00', 'Normal', 'No asistio', 31, 10),
    (8, 'TE002', '2026-10-05', '15:13:00', 'Normal', 'Atendido', 36, 5),
    (9, 'BI001', '2026-10-06', '10:03:00', 'Normal', 'Atendido', 38, 2),
    (10, 'ST001', '2026-10-06', '10:19:00', 'Normal', 'Atendido', 39, 4),
    (11, 'FE001', '2026-10-06', '14:13:00', 'Normal', 'Atendido', 41, 15),
    (12, 'TE001', '2026-10-06', '14:54:00', 'Normal', 'Atendido', 23, 5),
    (13, 'AD001', '2026-10-06', '15:06:00', 'Prioritario', 'Atendido', 30, 6),
    (14, 'SM001', '2026-10-06', '15:20:00', 'Normal', 'Atendido', 35, 7),
    (15, 'CI001', '2026-10-06', '15:26:00', 'Normal', 'Atendido', 25, 9),
    (16, 'ST002', '2026-10-06', '15:48:00', 'Normal', 'Cancelado', 40, 4),
    (17, 'BU001', '2026-10-07', '08:51:00', 'Prioritario', 'Atendido', 29, 3),
    (18, 'ST001', '2026-10-07', '10:04:00', 'Normal', 'Atendido', 32, 4),
    (19, 'DR001', '2026-10-07', '10:05:00', 'Normal', 'Atendido', 31, 10),
    (20, 'ST002', '2026-10-07', '10:49:00', 'Normal', 'Atendido', 23, 4),
    (21, 'EG001', '2026-10-07', '11:16:00', 'Normal', 'Atendido', 24, 8),
    (22, 'AP001', '2026-10-07', '15:42:00', 'Normal', 'Atendido', 25, 14),
    (23, 'BI001', '2026-10-07', '15:43:00', 'Normal', 'Cancelado', 33, 2),
    (24, 'SG001', '2026-10-07', '15:46:00', 'Normal', 'Cancelado', 41, 12),
    (25, 'AP001', '2026-10-08', '08:03:00', 'Normal', 'Atendido', 28, 14),
    (26, 'SM001', '2026-10-08', '08:21:00', 'Prioritario', 'Atendido', 36, 7),
    (27, 'AD001', '2026-10-08', '09:55:00', 'Prioritario', 'Atendido', 38, 6),
    (28, 'BI001', '2026-10-08', '10:19:00', 'Normal', 'No asistio', 25, 2),
    (29, 'BU001', '2026-10-08', '10:38:00', 'Normal', 'Cancelado', 31, 3),
    (30, 'TE001', '2026-10-08', '11:11:00', 'Prioritario', 'Atendido', 37, 5),
    (31, 'CI001', '2026-10-08', '14:18:00', 'Normal', 'Atendido', 30, 9),
    (32, 'SG001', '2026-10-08', '14:25:00', 'Normal', 'Atendido', 42, 12),
    (33, 'RA001', '2026-10-09', '08:15:00', 'Normal', 'Atendido', 38, 1),
    (34, 'ST001', '2026-10-09', '09:40:00', 'Normal', 'Atendiendo', 26, 4),
    (35, 'BI001', '2026-10-09', '10:05:00', 'Normal', 'Atendiendo', 31, 2),
    (36, 'RA002', '2026-10-09', '10:12:00', 'Prioritario', 'Esperando', 23, 1),
    (37, 'BU001', '2026-10-09', '10:20:00', 'Normal', 'Esperando', 28, 3),
    (38, 'BI002', '2026-10-09', '10:28:00', 'Normal', 'Esperando', 42, 2),
    (39, 'TE001', '2026-10-09', '10:33:00', 'Normal', 'Esperando', 39, 5),
    (40, 'RA003', '2026-10-09', '10:41:00', 'Normal', 'Esperando', 33, 1);

INSERT INTO atencion (id_atencion, hora_inicio, hora_fin, observacion, id_turno, id_empleado, id_ventanilla) VALUES
    (1, '08:44:00', '09:07:00', NULL, 1, 4, 4),
    (2, '10:11:00', '10:23:00', 'Se orientó al usuario sobre el procedimiento', 2, 9, 9),
    (3, '10:00:00', '10:04:00', 'Se orientó al usuario sobre el procedimiento', 3, 11, 11),
    (4, '11:03:00', '11:23:00', 'Atención prioritaria', 5, 4, 4),
    (5, '11:08:00', '11:15:00', NULL, 6, 5, 5),
    (6, '15:35:00', '15:42:00', 'Se entregó el documento solicitado', 8, 5, 5),
    (7, '10:07:00', '10:14:00', 'Trámite completado sin novedades', 9, 17, 2),
    (8, '10:49:00', '11:22:00', NULL, 10, 19, 4),
    (9, '14:31:00', '14:52:00', 'Solicitud radicada correctamente', 11, 15, 15),
    (10, '15:02:00', '15:05:00', NULL, 12, 5, 5),
    (11, '15:21:00', '15:35:00', 'Atención prioritaria', 13, 6, 6),
    (12, '15:32:00', '15:59:00', 'El usuario debe volver con un documento adicional', 14, 7, 7),
    (13, '15:43:00', '15:49:00', 'Se actualizaron los datos del usuario', 15, 9, 9),
    (14, '09:04:00', '09:19:00', 'Se actualizaron los datos del usuario', 17, 3, 3),
    (15, '10:23:00', '10:46:00', NULL, 18, 4, 4),
    (16, '10:15:00', '10:19:00', 'Se entregó el documento solicitado', 19, 10, 10),
    (17, '11:12:00', '11:28:00', NULL, 20, 19, 4),
    (18, '11:19:00', '11:32:00', 'El usuario debe volver con un documento adicional', 21, 8, 8),
    (19, '16:02:00', '16:26:00', 'Se resolvió la incidencia reportada', 22, 14, 14),
    (20, '08:24:00', '08:39:00', 'Se resolvió la incidencia reportada', 25, 14, 14),
    (21, '08:27:00', '08:48:00', 'Se entregó el documento solicitado', 26, 7, 7),
    (22, '10:22:00', '10:35:00', 'El usuario debe volver con un documento adicional', 27, 6, 6),
    (23, '11:30:00', '11:37:00', 'Se orientó al usuario sobre el procedimiento', 30, 5, 5),
    (24, '14:29:00', '14:45:00', 'Trámite completado sin novedades', 31, 9, 9),
    (25, '14:55:00', '15:20:00', 'Trámite completado sin novedades', 32, 12, 12),
    (26, '08:21:00', '08:29:00', 'Se resolvió la incidencia reportada', 33, 1, 1),
    (27, '09:46:00', NULL, NULL, 34, 4, 4),
    (28, '10:18:00', NULL, NULL, 35, 17, 2);


-- Procedimientos almacenados

DELIMITER $$

CREATE PROCEDURE sp_guardar_servicio(
    IN p_id_servicio INT, IN p_nombre VARCHAR(100), IN p_descripcion VARCHAR(255),
    IN p_tiempo_estimado DECIMAL(5,2), IN p_estado BOOLEAN)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION BEGIN ROLLBACK; RESIGNAL; END;

    IF p_nombre IS NULL OR TRIM(p_nombre) = '' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El nombre del servicio es obligatorio.';
    END IF;
    IF p_tiempo_estimado IS NULL OR p_tiempo_estimado <= 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El tiempo estimado debe ser mayor que cero.';
    END IF;

    START TRANSACTION;
    IF EXISTS (SELECT 1 FROM servicio WHERE nombre = TRIM(p_nombre)
               AND id_servicio <> IFNULL(p_id_servicio, 0)) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Ya existe un servicio con ese nombre.';
    END IF;

    IF IFNULL(p_id_servicio, 0) = 0 THEN
        INSERT INTO servicio (nombre, descripcion, tiempo_estimado_min, estado)
        VALUES (TRIM(p_nombre), NULLIF(TRIM(p_descripcion), ''), p_tiempo_estimado, p_estado);
        SELECT LAST_INSERT_ID() AS id_servicio, 'INSERT' AS operacion;
    ELSE
        IF NOT EXISTS (SELECT 1 FROM servicio WHERE id_servicio = p_id_servicio) THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El servicio que intentas modificar no existe.';
        END IF;
        UPDATE servicio
        SET nombre = TRIM(p_nombre), descripcion = NULLIF(TRIM(p_descripcion), ''),
            tiempo_estimado_min = p_tiempo_estimado, estado = p_estado
        WHERE id_servicio = p_id_servicio;
        SELECT p_id_servicio AS id_servicio, 'UPDATE' AS operacion;
    END IF;
    COMMIT;
END$$

CREATE PROCEDURE sp_guardar_ventanilla(
    IN p_id_ventanilla INT, IN p_numero INT, IN p_ubicacion VARCHAR(100), IN p_estado BOOLEAN)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION BEGIN ROLLBACK; RESIGNAL; END;

    IF p_numero IS NULL OR p_numero <= 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El número de ventanilla debe ser mayor que cero.';
    END IF;

    START TRANSACTION;
    IF EXISTS (SELECT 1 FROM ventanilla WHERE numero = p_numero
               AND id_ventanilla <> IFNULL(p_id_ventanilla, 0)) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Ya existe una ventanilla con ese número.';
    END IF;

    IF IFNULL(p_id_ventanilla, 0) = 0 THEN
        INSERT INTO ventanilla (numero, ubicacion, estado)
        VALUES (p_numero, NULLIF(TRIM(p_ubicacion), ''), p_estado);
        SELECT LAST_INSERT_ID() AS id_ventanilla, 'INSERT' AS operacion;
    ELSE
        IF NOT EXISTS (SELECT 1 FROM ventanilla WHERE id_ventanilla = p_id_ventanilla) THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'La ventanilla que intentas modificar no existe.';
        END IF;
        UPDATE ventanilla
        SET numero = p_numero, ubicacion = NULLIF(TRIM(p_ubicacion), ''), estado = p_estado
        WHERE id_ventanilla = p_id_ventanilla;
        SELECT p_id_ventanilla AS id_ventanilla, 'UPDATE' AS operacion;
    END IF;
    COMMIT;
END$$

CREATE PROCEDURE sp_guardar_horario(
    IN p_id_horario INT, IN p_dia VARCHAR(20), IN p_hora_inicio TIME,
    IN p_hora_fin TIME, IN p_id_servicio INT)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION BEGIN ROLLBACK; RESIGNAL; END;

    IF p_dia IS NULL OR TRIM(p_dia) = '' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Debes seleccionar un día.';
    END IF;
    IF p_hora_inicio IS NULL OR p_hora_fin IS NULL OR p_hora_inicio >= p_hora_fin THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'La hora inicial debe ser anterior a la hora final.';
    END IF;

    START TRANSACTION;
    IF NOT EXISTS (SELECT 1 FROM servicio WHERE id_servicio = p_id_servicio AND estado = TRUE) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El servicio no existe o está inactivo.';
    END IF;
    IF EXISTS (SELECT 1 FROM horario
               WHERE id_servicio = p_id_servicio AND dia = TRIM(p_dia)
                 AND id_horario <> IFNULL(p_id_horario, 0)
                 AND p_hora_inicio < hora_fin AND p_hora_fin > hora_inicio) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El horario se cruza con otro horario del servicio.';
    END IF;

    IF IFNULL(p_id_horario, 0) = 0 THEN
        INSERT INTO horario (dia, hora_inicio, hora_fin, id_servicio)
        VALUES (TRIM(p_dia), p_hora_inicio, p_hora_fin, p_id_servicio);
        SELECT LAST_INSERT_ID() AS id_horario, 'INSERT' AS operacion;
    ELSE
        IF NOT EXISTS (SELECT 1 FROM horario WHERE id_horario = p_id_horario) THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El horario que intentas modificar no existe.';
        END IF;
        UPDATE horario
        SET dia = TRIM(p_dia), hora_inicio = p_hora_inicio,
            hora_fin = p_hora_fin, id_servicio = p_id_servicio
        WHERE id_horario = p_id_horario;
        SELECT p_id_horario AS id_horario, 'UPDATE' AS operacion;
    END IF;
    COMMIT;
END$$

CREATE PROCEDURE sp_guardar_usuario(
    IN p_id_usuario INT, IN p_nombre VARCHAR(50), IN p_apellido VARCHAR(50),
    IN p_correo VARCHAR(100), IN p_contrasena VARCHAR(255), IN p_id_rol INT)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION BEGIN ROLLBACK; RESIGNAL; END;

    IF TRIM(IFNULL(p_nombre,'')) = '' OR TRIM(IFNULL(p_apellido,'')) = ''
       OR TRIM(IFNULL(p_correo,'')) = '' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Nombre, apellido y correo son obligatorios.';
    END IF;
    IF NOT EXISTS (SELECT 1 FROM rol WHERE id_rol = p_id_rol) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El rol indicado no existe.';
    END IF;
    IF p_id_rol = 2 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Los empleados se registran desde la gestión de empleados.';
    END IF;

    START TRANSACTION;
    IF EXISTS (SELECT 1 FROM usuario WHERE correo = TRIM(p_correo)
               AND id_usuario <> IFNULL(p_id_usuario, 0)) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Ya existe una cuenta con ese correo.';
    END IF;

    IF IFNULL(p_id_usuario, 0) = 0 THEN
        IF TRIM(IFNULL(p_contrasena,'')) = '' THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'La contraseña es obligatoria.';
        END IF;
        INSERT INTO usuario (nombre, apellido, correo, contrasena, id_rol)
        VALUES (TRIM(p_nombre), TRIM(p_apellido), TRIM(p_correo), SHA2(p_contrasena, 256), p_id_rol);
        SELECT LAST_INSERT_ID() AS id_usuario, 'INSERT' AS operacion;
    ELSE
        IF NOT EXISTS (SELECT 1 FROM usuario WHERE id_usuario = p_id_usuario) THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El usuario que intentas modificar no existe.';
        END IF;
        UPDATE usuario
        SET nombre = TRIM(p_nombre), apellido = TRIM(p_apellido), correo = TRIM(p_correo),
            contrasena = IF(TRIM(IFNULL(p_contrasena,'')) = '', contrasena, SHA2(p_contrasena, 256)),
            id_rol = p_id_rol
        WHERE id_usuario = p_id_usuario;
        SELECT p_id_usuario AS id_usuario, 'UPDATE' AS operacion;
    END IF;
    COMMIT;
END$$

CREATE PROCEDURE sp_guardar_empleado(
    IN p_id_empleado INT, IN p_nombre VARCHAR(50), IN p_apellido VARCHAR(50),
    IN p_correo VARCHAR(100), IN p_contrasena VARCHAR(255),
    IN p_id_servicio INT, IN p_estado BOOLEAN)
BEGIN
    DECLARE v_id_usuario INT DEFAULT NULL;
    DECLARE EXIT HANDLER FOR SQLEXCEPTION BEGIN ROLLBACK; RESIGNAL; END;

    IF TRIM(IFNULL(p_nombre,'')) = '' OR TRIM(IFNULL(p_apellido,'')) = ''
       OR TRIM(IFNULL(p_correo,'')) = '' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Nombre, apellido y correo son obligatorios.';
    END IF;

    START TRANSACTION;
    IF NOT EXISTS (SELECT 1 FROM servicio WHERE id_servicio = p_id_servicio AND estado = TRUE) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El servicio no existe o está inactivo.';
    END IF;

    IF IFNULL(p_id_empleado, 0) = 0 THEN
        IF TRIM(IFNULL(p_contrasena,'')) = '' THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'La contraseña es obligatoria.';
        END IF;
        IF EXISTS (SELECT 1 FROM usuario WHERE correo = TRIM(p_correo)) THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Ya existe una cuenta con ese correo.';
        END IF;

        INSERT INTO usuario (nombre, apellido, correo, contrasena, id_rol)
        VALUES (TRIM(p_nombre), TRIM(p_apellido), TRIM(p_correo), SHA2(p_contrasena, 256), 2);
        SET v_id_usuario = LAST_INSERT_ID();

        INSERT INTO empleado (id_usuario, id_servicio, estado)
        VALUES (v_id_usuario, p_id_servicio, p_estado);

        SELECT LAST_INSERT_ID() AS id_empleado, 'INSERT' AS operacion;
    ELSE
        SELECT id_usuario INTO v_id_usuario FROM empleado WHERE id_empleado = p_id_empleado;
        IF v_id_usuario IS NULL THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El empleado que intentas modificar no existe.';
        END IF;
        IF EXISTS (SELECT 1 FROM usuario WHERE correo = TRIM(p_correo) AND id_usuario <> v_id_usuario) THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Ya existe una cuenta con ese correo.';
        END IF;

        UPDATE usuario
        SET nombre = TRIM(p_nombre), apellido = TRIM(p_apellido), correo = TRIM(p_correo),
            contrasena = IF(TRIM(IFNULL(p_contrasena,'')) = '', contrasena, SHA2(p_contrasena, 256))
        WHERE id_usuario = v_id_usuario;

        UPDATE empleado
        SET id_servicio = p_id_servicio, estado = p_estado
        WHERE id_empleado = p_id_empleado;

        SELECT p_id_empleado AS id_empleado, 'UPDATE' AS operacion;
    END IF;
    COMMIT;
END$$

CREATE PROCEDURE sp_solicitar_turno(
    IN p_id_usuario INT, IN p_id_servicio INT, IN p_prioridad VARCHAR(20))
BEGIN
    DECLARE v_rol INT DEFAULT NULL;
    DECLARE v_consecutivo INT DEFAULT 0;
    DECLARE v_numero_turno VARCHAR(10);
    DECLARE EXIT HANDLER FOR SQLEXCEPTION BEGIN ROLLBACK; RESIGNAL; END;

    IF p_prioridad IS NULL OR p_prioridad NOT IN ('Normal', 'Prioritario') THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'La prioridad seleccionada no es válida.';
    END IF;

    START TRANSACTION;
    SELECT id_rol INTO v_rol FROM usuario WHERE id_usuario = p_id_usuario;
    IF v_rol IS NULL OR v_rol IN (1, 2) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Solo los usuarios del campus pueden solicitar turnos.';
    END IF;
    IF NOT EXISTS (SELECT 1 FROM servicio WHERE id_servicio = p_id_servicio
                   AND estado = TRUE FOR UPDATE) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El servicio no existe o está inactivo.';
    END IF;
    IF EXISTS (SELECT 1 FROM turno WHERE id_usuario = p_id_usuario AND id_servicio = p_id_servicio
               AND fecha = CURDATE() AND estado IN ('Esperando', 'Atendiendo')) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Ya tienes un turno activo para este servicio hoy.';
    END IF;

    SELECT COUNT(*) + 1 INTO v_consecutivo FROM turno
    WHERE id_servicio = p_id_servicio AND fecha = CURDATE();
    SET v_numero_turno = CONCAT('S', LPAD(p_id_servicio, 2, '0'), LPAD(v_consecutivo, 4, '0'));

    INSERT INTO turno (numero_turno, fecha, hora_solicitud, prioridad, estado, id_usuario, id_servicio)
    VALUES (v_numero_turno, CURDATE(), CURTIME(), p_prioridad, 'Esperando', p_id_usuario, p_id_servicio);
    COMMIT;

    SELECT LAST_INSERT_ID() AS id_turno, v_numero_turno AS numero_turno;
END$$

CREATE PROCEDURE sp_cancelar_turno(IN p_id_usuario INT, IN p_id_turno INT)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION BEGIN ROLLBACK; RESIGNAL; END;
    START TRANSACTION;
    IF NOT EXISTS (SELECT 1 FROM turno WHERE id_turno = p_id_turno AND id_usuario = p_id_usuario
                   AND estado = 'Esperando' FOR UPDATE) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El turno no existe o ya no está esperando.';
    END IF;
    UPDATE turno SET estado = 'Cancelado' WHERE id_turno = p_id_turno;
    COMMIT;
END$$

CREATE PROCEDURE sp_llamar_turno(IN p_id_turno INT, IN p_id_empleado INT, IN p_id_ventanilla INT)
BEGIN
    DECLARE v_id_turno INT DEFAULT NULL;
    DECLARE v_id_servicio INT DEFAULT NULL;
    DECLARE EXIT HANDLER FOR SQLEXCEPTION BEGIN ROLLBACK; RESIGNAL; END;

    START TRANSACTION;
    SELECT id_servicio INTO v_id_servicio FROM empleado
    WHERE id_empleado = p_id_empleado AND estado = TRUE;
    IF v_id_servicio IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El empleado no existe o está inactivo.';
    END IF;
    IF NOT EXISTS (SELECT 1 FROM ventanilla WHERE id_ventanilla = p_id_ventanilla AND estado = TRUE) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'La ventanilla no existe o está inactiva.';
    END IF;
    IF EXISTS (SELECT 1 FROM atencion WHERE id_empleado = p_id_empleado AND hora_fin IS NULL) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Finaliza la atención actual antes de llamar otro turno.';
    END IF;

    IF IFNULL(p_id_turno, 0) = 0 THEN
        SELECT id_turno INTO v_id_turno FROM turno
        WHERE id_servicio = v_id_servicio AND estado = 'Esperando'
        ORDER BY prioridad DESC, fecha, hora_solicitud
        LIMIT 1 FOR UPDATE;
        IF v_id_turno IS NULL THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'No hay turnos esperando en tu servicio.';
        END IF;
    ELSE
        SELECT id_turno INTO v_id_turno FROM turno
        WHERE id_turno = p_id_turno AND id_servicio = v_id_servicio AND estado = 'Esperando'
        FOR UPDATE;
        IF v_id_turno IS NULL THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El turno no existe, no es de tu servicio o ya no está esperando.';
        END IF;
    END IF;

    INSERT INTO atencion (hora_inicio, id_turno, id_empleado, id_ventanilla)
    VALUES (CURTIME(), v_id_turno, p_id_empleado, p_id_ventanilla);
    COMMIT;

    SELECT t.id_turno, t.numero_turno, CONCAT(u.nombre, ' ', u.apellido) AS usuario
    FROM turno t INNER JOIN usuario u ON u.id_usuario = t.id_usuario
    WHERE t.id_turno = v_id_turno;
END$$

CREATE PROCEDURE sp_finalizar_atencion(IN p_id_empleado INT, IN p_observacion VARCHAR(255))
BEGIN
    DECLARE v_id_atencion INT DEFAULT NULL;
    DECLARE v_id_turno INT DEFAULT NULL;
    DECLARE EXIT HANDLER FOR SQLEXCEPTION BEGIN ROLLBACK; RESIGNAL; END;

    START TRANSACTION;
    SELECT id_atencion, id_turno INTO v_id_atencion, v_id_turno FROM atencion
    WHERE id_empleado = p_id_empleado AND hora_fin IS NULL
    LIMIT 1 FOR UPDATE;
    IF v_id_atencion IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'No tienes una atención en curso.';
    END IF;

    UPDATE atencion SET hora_fin = CURTIME(), observacion = NULLIF(TRIM(p_observacion), '')
    WHERE id_atencion = v_id_atencion;
    UPDATE turno SET estado = 'Atendido' WHERE id_turno = v_id_turno;
    COMMIT;
END$$

CREATE PROCEDURE sp_marcar_no_asistio(IN p_id_turno INT, IN p_id_empleado INT)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION BEGIN ROLLBACK; RESIGNAL; END;
    START TRANSACTION;
    IF NOT EXISTS (SELECT 1 FROM turno t
                   INNER JOIN empleado e ON e.id_servicio = t.id_servicio
                   WHERE t.id_turno = p_id_turno AND t.estado = 'Esperando'
                     AND e.id_empleado = p_id_empleado AND e.estado = TRUE) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El turno no está esperando o no es de tu servicio.';
    END IF;
    UPDATE turno SET estado = 'No asistio' WHERE id_turno = p_id_turno;
    COMMIT;
END$$

CREATE PROCEDURE sp_reporte_atenciones(IN p_fecha_desde DATE, IN p_fecha_hasta DATE)
BEGIN
    IF p_fecha_desde IS NOT NULL AND p_fecha_hasta IS NOT NULL AND p_fecha_desde > p_fecha_hasta THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'La fecha inicial no puede ser posterior a la fecha final.';
    END IF;

    SELECT t.numero_turno, t.fecha,
           CONCAT(uc.nombre, ' ', uc.apellido) AS usuario,
           s.nombre AS servicio,
           CONCAT(ue.nombre, ' ', ue.apellido) AS empleado,
           v.numero AS ventanilla,
           a.hora_inicio, a.hora_fin, t.estado
    FROM atencion a
    INNER JOIN turno t      ON t.id_turno = a.id_turno
    INNER JOIN usuario uc   ON uc.id_usuario = t.id_usuario
    INNER JOIN servicio s   ON s.id_servicio = t.id_servicio
    INNER JOIN empleado e   ON e.id_empleado = a.id_empleado
    INNER JOIN usuario ue   ON ue.id_usuario = e.id_usuario
    INNER JOIN ventanilla v ON v.id_ventanilla = a.id_ventanilla
    WHERE (p_fecha_desde IS NULL OR t.fecha >= p_fecha_desde)
      AND (p_fecha_hasta IS NULL OR t.fecha <= p_fecha_hasta)
    ORDER BY t.fecha, a.hora_inicio;
END$$

CREATE PROCEDURE sp_estado_turno(IN p_id_usuario INT)
BEGIN
    SELECT t.id_turno, t.numero_turno, s.nombre AS servicio, t.estado,
           s.tiempo_estimado_min,
           (SELECT COUNT(*) FROM turno t2
            WHERE t2.id_servicio = t.id_servicio AND t2.estado = 'Esperando'
              AND t.estado = 'Esperando'
              AND (t2.prioridad > t.prioridad
                   OR (t2.prioridad = t.prioridad
                       AND (t2.fecha < t.fecha
                            OR (t2.fecha = t.fecha AND t2.hora_solicitud < t.hora_solicitud))))
           ) AS personas_adelante,
           v.numero AS ventanilla
    FROM turno t
    INNER JOIN servicio s  ON s.id_servicio = t.id_servicio
    LEFT JOIN atencion a   ON a.id_turno = t.id_turno
    LEFT JOIN ventanilla v ON v.id_ventanilla = a.id_ventanilla
    WHERE t.id_usuario = p_id_usuario AND t.fecha = CURDATE()
      AND t.estado IN ('Esperando', 'Atendiendo')
    ORDER BY t.hora_solicitud;
END$$


-- Triggers

CREATE TRIGGER trg_usuario_auditoria_update
AFTER UPDATE ON usuario
FOR EACH ROW
BEGIN
    INSERT INTO historial_auditoria (tabla_afectada, id_registro, fecha_accion, accion)
    VALUES ('usuario', OLD.id_usuario, NOW(), 'UPDATE');
END$$

CREATE TRIGGER trg_atencion_marcar_turno
AFTER INSERT ON atencion
FOR EACH ROW
BEGIN
    DECLARE v_duracion DECIMAL(7,2);

    SELECT s.tiempo_estimado_min INTO v_duracion
    FROM turno t INNER JOIN servicio s ON s.id_servicio = t.id_servicio
    WHERE t.id_turno = NEW.id_turno;

    INSERT INTO proyeccion_atencion (id_turno, duracion_estimada_min, hora_fin_estimada)
    VALUES (NEW.id_turno, v_duracion, ADDTIME(NEW.hora_inicio, SEC_TO_TIME(v_duracion * 60)));

    UPDATE turno SET estado = 'Atendiendo'
    WHERE id_turno = NEW.id_turno AND estado = 'Esperando';
END$$

DELIMITER ;


-- Función UDF

DELIMITER $$

CREATE FUNCTION fn_clasificar_atencion(p_duracion_min INT, p_estimado_min DECIMAL(5,2))
RETURNS VARCHAR(20)
DETERMINISTIC
NO SQL
BEGIN
    IF p_duracion_min IS NULL THEN
        RETURN 'En curso';
    ELSEIF p_duracion_min <= p_estimado_min * 0.8 THEN
        RETURN 'Rápida';
    ELSEIF p_duracion_min <= p_estimado_min THEN
        RETURN 'A tiempo';
    ELSEIF p_duracion_min <= p_estimado_min * 1.5 THEN
        RETURN 'Demorada';
    ELSE
        RETURN 'Crítica';
    END IF;
END$$

DELIMITER ;
