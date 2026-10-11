-- Nexus — PostgreSQL schema and seed data
-- Create the database first (run as superuser):
--   CREATE DATABASE agencia_viajes ENCODING 'UTF8';
-- Then:
--   psql -U postgres -d agencia_viajes -f BDD/postgresql.sql

BEGIN;

CREATE TABLE IF NOT EXISTS clientes (
    id_cliente BIGSERIAL PRIMARY KEY,
    nombre VARCHAR(255),
    apellido VARCHAR(255),
    tipo_documento VARCHAR(255),
    numero_documento VARCHAR(255),
    fecha_nacimiento DATE,
    correo_electronico VARCHAR(255),
    telefono VARCHAR(255),
    direccion VARCHAR(255),
    fecha_registro DATE,
    UNIQUE (tipo_documento, numero_documento)
);

CREATE TABLE IF NOT EXISTS viajes (
    id_viaje BIGSERIAL PRIMARY KEY,
    numero_vuelo VARCHAR(50),
    origen VARCHAR(100) NOT NULL,
    destino VARCHAR(100) NOT NULL,
    descripcion TEXT,
    fecha_inicio DATE NOT NULL,
    fecha_fin DATE NOT NULL,
    duracion_dias INTEGER,
    precio_adulto NUMERIC(10, 2) NOT NULL,
    precio_nino NUMERIC(10, 2),
    disponibilidad INTEGER NOT NULL DEFAULT 0,
    itinerario TEXT,
    imagen_principal VARCHAR(255),
    fecha_creacion TIMESTAMP,
    fecha_actualizacion TIMESTAMP
);

CREATE TABLE IF NOT EXISTS vuelo (
    id_vuelo BIGSERIAL PRIMARY KEY,
    numero_vuelo VARCHAR(50) NOT NULL,
    origen VARCHAR(100) NOT NULL,
    destino VARCHAR(100) NOT NULL,
    fecha_salida DATE NOT NULL,
    hora_salida TIME NOT NULL,
    precio NUMERIC(10, 2)
);

CREATE TABLE IF NOT EXISTS itinerarios (
    id_itinerario SERIAL PRIMARY KEY,
    id_viaje BIGINT NOT NULL REFERENCES viajes (id_viaje),
    dia INTEGER NOT NULL,
    descripcion TEXT NOT NULL
);

CREATE TABLE IF NOT EXISTS reservas (
    id_reserva BIGSERIAL PRIMARY KEY,
    id_cliente BIGINT NOT NULL REFERENCES clientes (id_cliente),
    id_viaje BIGINT REFERENCES viajes (id_viaje),
    id_vuelo BIGINT REFERENCES vuelo (id_vuelo),
    fecha_reserva TIMESTAMP,
    fecha_inicio DATE NOT NULL,
    fecha_fin DATE,
    cantidad_adultos INTEGER NOT NULL DEFAULT 1,
    cantidad_ninos INTEGER NOT NULL DEFAULT 0,
    precio_total NUMERIC(10, 2) NOT NULL,
    estado_reserva VARCHAR(50) NOT NULL DEFAULT 'Pendiente',
    observaciones TEXT
);

CREATE TABLE IF NOT EXISTS pagos (
    id_pago BIGSERIAL PRIMARY KEY,
    id_reserva BIGINT NOT NULL REFERENCES reservas (id_reserva),
    fecha_pago TIMESTAMP,
    monto NUMERIC(10, 2) NOT NULL,
    tipo_pago VARCHAR(50) NOT NULL DEFAULT 'Efectivo',
    referencia VARCHAR(100),
    estado_pago VARCHAR(50) NOT NULL DEFAULT 'Pendiente',
    observaciones TEXT
);

CREATE TABLE IF NOT EXISTS piloto (
    id_piloto BIGSERIAL PRIMARY KEY,
    apellido VARCHAR(100) NOT NULL,
    nombre VARCHAR(100) NOT NULL,
    id_vuelo BIGINT UNIQUE REFERENCES vuelo (id_vuelo),
    id_viaje BIGINT REFERENCES viajes (id_viaje) ON DELETE SET NULL
);

CREATE TABLE IF NOT EXISTS tipos_reporte (
    id BIGSERIAL PRIMARY KEY,
    descripcion VARCHAR(255),
    nombre VARCHAR(255)
);

CREATE TABLE IF NOT EXISTS usuarios (
    id_usuario BIGSERIAL PRIMARY KEY,
    usuario VARCHAR(50) NOT NULL UNIQUE,
    contrasena VARCHAR(255) NOT NULL,
    nombre VARCHAR(100),
    rol VARCHAR(50) NOT NULL DEFAULT 'Empleado',
    fecha_registro TIMESTAMP
);

INSERT INTO usuarios (id_usuario, usuario, contrasena, nombre, rol, fecha_registro)
VALUES (1, 'jefe', '123456789', 'ADMIN', 'Administrador', TIMESTAMP '2025-05-05 01:11:29')
ON CONFLICT (id_usuario) DO NOTHING;

INSERT INTO vuelo (id_vuelo, numero_vuelo, origen, destino, fecha_salida, hora_salida, precio)
VALUES
    (1, 'AV-9725', 'Medellín (MDE), Aeropuerto Internacional José María Córdova', 'Santa Marta (SMR), Aeropuerto Internacional Simón Bolívar', DATE '2025-06-15', TIME '14:30:00', 500000.00),
    (2, 'LA-4112', 'Bogotá (BOG), Aeropuerto Internacional El Dorado', 'Cali (CLO), Aeropuerto Internacional Alfonso Bonilla Aragón', DATE '2025-07-20', TIME '09:00:00', 450000.00)
ON CONFLICT (id_vuelo) DO NOTHING;

INSERT INTO viajes (
    id_viaje, numero_vuelo, origen, destino, descripcion, fecha_inicio, fecha_fin,
    duracion_dias, precio_adulto, precio_nino, disponibilidad, itinerario, imagen_principal,
    fecha_creacion, fecha_actualizacion
) VALUES
(1, 'AA101',
 'Medellín (MDE), Aeropuerto Internacional José María Córdova',
 'Cartagena de Indias, Colombia',
 'Descubre la magia de la "Ciudad Amurallada", con sus coloridas calles, historia fascinante, playas caribeñas y una vibrante vida nocturna.',
 DATE '2025-07-15', DATE '2025-07-21', 6, 1250000.00, 950000.00, 25,
 'Día 1: Vuelo desde Medellín a Cartagena.
Día 2: Tour guiado por el centro histórico.
Día 3: Excursión a las Islas del Rosario.
Día 4: Día libre.
Día 5: Clase de cocina caribeña.
Día 6: Traslado al aeropuerto.',
 'vacaciones_cartagena_de_indias.webp',
 TIMESTAMP '2025-05-10 03:28:28', TIMESTAMP '2025-05-21 23:38:29'),
(5, 'CX305',
 'Bogotá, Aeropuerto Internacional El Dorado (BOG)',
 'San Andrés Islas, Colombia',
 'Escápate al paraíso caribeño de San Andrés.',
 DATE '2025-08-10', DATE '2025-07-16', 6, 980000.00, 750000.00, 30,
 'Día 1: Vuelo a San Andrés.
Día 2: Tour a Johnny Cay.
Día 3: Día libre.
Día 4: Cueva de Morgan.
Día 5: Día libre.
Día 6: Regreso a Bogotá.',
 'San_Andres.jpeg',
 TIMESTAMP '2025-05-10 03:21:11', TIMESTAMP '2025-05-21 23:38:34'),
(6, 'AV720',
 'Bogotá, Aeropuerto Internacional El Dorado (BOG)',
 'Leticia y alrededores, Amazonas',
 'Explora la selva amazónica colombiana.',
 DATE '2025-05-16', DATE '2025-05-20', 4, 1350000.00, 1050000.00, 30,
 'Día 1: Vuelo a Leticia.
Día 2: Navegación por el Amazonas.
Día 3: Encuentro con comunidad Ticuna.
Día 4: Avistamiento de aves y regreso.',
 'Departamento-del-Amazonas.webp',
 TIMESTAMP '2025-05-17 13:47:08', TIMESTAMP '2025-05-21 23:38:39'),
(7, 'CA415',
 'Medellín (MDE), Aeropuerto Internacional José María Córdova',
 'Santa Marta, Parque Nacional Natural Tayrona y alrededores',
 'Descubre la Sierra Nevada y el Parque Tayrona.',
 DATE '2025-06-01', DATE '2025-06-05', 5, 1200000.00, 900000.00, 45,
 'Día 1: Vuelo a Santa Marta.
Día 2: Ingreso al Parque Tayrona.
Día 3: Cabo San Juan.
Día 4: Playas y Pueblito.
Día 5: Regreso a Medellín.',
 'KFSFA7RGZNBMHBUTNYJGWBYULY.avif',
 TIMESTAMP '2025-05-17 13:35:00', TIMESTAMP '2025-05-21 23:38:45'),
(8, 'SW250',
 'Cali, Aeropuerto Internacional Alfonso Bonilla Aragón (CLO)',
 'Bucaramanga, Cañón del Chicamocha y Barichara',
 'Cruzar el Cañón del Chicamocha y visitar Barichara.',
 DATE '2025-06-11', DATE '2025-06-15', 4, 950000.00, 700000.00, 35,
 'Día 1: Vuelo a Bucaramanga.
Día 2: Parque Nacional del Chicamocha.
Día 3: Barichara.
Día 4: San Gil y regreso.',
 'VistaAerea-Barichara.jpg',
 TIMESTAMP '2025-05-17 13:38:47', TIMESTAMP '2025-05-21 23:38:54'),
(9, 'GJ630',
 'Cali, Aeropuerto Internacional Alfonso Bonilla Aragón (CLO)',
 'Riohacha, Cabo de la Vela, Punta Gallinas',
 'Desierto y cultura Wayuu en La Guajira.',
 DATE '2025-06-01', DATE '2025-06-03', 3, 800000.00, 600000.00, 40,
 'Día 1: Traslado al Cabo de la Vela.
Día 2: Playas y comunidad Wayuu.
Día 3: Regreso a Riohacha.',
 'Faro-Punta-Gallinas-la-Guajira-Colombia.jpg',
 TIMESTAMP '2025-05-17 13:40:52', TIMESTAMP '2025-05-21 23:39:00'),
(10, 'OS875',
 'Medellín (MDE), Aeropuerto Internacional José María Córdova',
 'San José del Guaviare y alrededores',
 'Ciudad de Piedra, pinturas rupestres y cascadas.',
 DATE '2025-07-01', DATE '2025-07-04', 4, 1000000.00, 750000.00, 36,
 'Día 1: Vuelo a San José del Guaviare.
Día 2: Ciudad de Piedra.
Día 3: Pinturas rupestres.
Día 4: Cascadas y regreso.',
 'tranquilandia-guaviare.webp',
 TIMESTAMP '2025-05-17 13:43:36', TIMESTAMP '2025-05-21 23:39:08'),
(11, 'cambiar', 'cambiar', 'cambiar', 'cambiar',
 DATE '2025-05-19', DATE '2025-05-30', 11, 4635201.00, 156023.00, 40,
 'cambiar', 'jamaica-gb17204f74_1920.jpg',
 TIMESTAMP '2025-05-22 01:34:32', TIMESTAMP '2025-05-22 01:34:32')
ON CONFLICT (id_viaje) DO NOTHING;

INSERT INTO piloto (id_piloto, apellido, nombre, id_vuelo, id_viaje)
VALUES
    (1, 'Lewis ', 'Hamilton', 1, NULL),
    (2, 'Schumacher', 'Michael ', NULL, 1)
ON CONFLICT (id_piloto) DO NOTHING;

SELECT setval(pg_get_serial_sequence('usuarios', 'id_usuario'), COALESCE((SELECT MAX(id_usuario) FROM usuarios), 1));
SELECT setval(pg_get_serial_sequence('vuelo', 'id_vuelo'), COALESCE((SELECT MAX(id_vuelo) FROM vuelo), 1));
SELECT setval(pg_get_serial_sequence('viajes', 'id_viaje'), COALESCE((SELECT MAX(id_viaje) FROM viajes), 1));
SELECT setval(pg_get_serial_sequence('piloto', 'id_piloto'), COALESCE((SELECT MAX(id_piloto) FROM piloto), 1));

COMMIT;
