CREATE DATABASE IF NOT EXISTS bangladesh_air_quality;
USE bangladesh_air_quality;

SET FOREIGN_KEY_CHECKS = 0;
DROP TABLE IF EXISTS maintenance;
DROP TABLE IF EXISTS alerts;
DROP TABLE IF EXISTS entropy_analysis;
DROP TABLE IF EXISTS air_quality;
DROP TABLE IF EXISTS stations;
DROP TABLE IF EXISTS districts;
DROP TABLE IF EXISTS divisions;
DROP TABLE IF EXISTS users;
SET FOREIGN_KEY_CHECKS = 1;

CREATE TABLE IF NOT EXISTS divisions (
  id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(25) NOT NULL UNIQUE,
  capital VARCHAR(25) NOT NULL
);

CREATE TABLE IF NOT EXISTS districts (
  id INT AUTO_INCREMENT PRIMARY KEY,
  division_id INT NOT NULL,
  name VARCHAR(25) NOT NULL,
  UNIQUE KEY (division_id, name),
  FOREIGN KEY (division_id) REFERENCES divisions(id)
);

CREATE TABLE IF NOT EXISTS stations (
  id INT AUTO_INCREMENT PRIMARY KEY,
  district_id INT NOT NULL,
  name VARCHAR(50) NOT NULL,
  latitude DECIMAL(8,6) NOT NULL,
  longitude DECIMAL(9,6) NOT NULL,
  establishment_year YEAR,
  FOREIGN KEY (district_id) REFERENCES districts(id)
);

CREATE TABLE IF NOT EXISTS air_quality (
  id BIGINT AUTO_INCREMENT PRIMARY KEY,
  station_id INT NOT NULL,
  pm25 DECIMAL(5,2) NOT NULL,
  pm10 DECIMAL(5,2) NOT NULL,
  co DECIMAL(5,2) NOT NULL,
  no2 DECIMAL(5,2) NOT NULL,
  so2 DECIMAL(5,2) NOT NULL,
  o3 DECIMAL(5,2) NOT NULL,
  temperature DECIMAL(4,2) NOT NULL,
  humidity DECIMAL(5,2) NOT NULL,
  pressure DECIMAL(7,2) NOT NULL,
  wind_speed DECIMAL(4,2),
  aqi DECIMAL(5,2) NOT NULL,
  reading_time DATETIME NOT NULL,
  FOREIGN KEY (station_id) REFERENCES stations(id)
);

CREATE TABLE IF NOT EXISTS entropy_analysis (
  id INT AUTO_INCREMENT PRIMARY KEY,
  station_id INT NOT NULL,
  entropy_value DECIMAL(10,6) NOT NULL,
  temperature DECIMAL(4,2) NOT NULL,
  humidity DECIMAL(5,2) NOT NULL,
  wind_speed DECIMAL(4,2),
  analysis_time DATETIME NOT NULL,
  parameters VARCHAR(100) NOT NULL,
  FOREIGN KEY (station_id) REFERENCES stations(id)
);

CREATE TABLE IF NOT EXISTS users (
  id INT AUTO_INCREMENT PRIMARY KEY,
  username VARCHAR(20) NOT NULL UNIQUE,
  password VARCHAR(255) NOT NULL,
  email VARCHAR(50) NOT NULL UNIQUE,
  role VARCHAR(10) NOT NULL DEFAULT 'viewer',
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS alerts (
  id INT AUTO_INCREMENT PRIMARY KEY,
  station_id INT NOT NULL,
  alert_type VARCHAR(20) NOT NULL,
  severity VARCHAR(10) NOT NULL,
  message VARCHAR(255) NOT NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (station_id) REFERENCES stations(id)
);

CREATE TABLE IF NOT EXISTS maintenance (
  id INT AUTO_INCREMENT PRIMARY KEY,
  station_id INT NOT NULL,
  maintenance_type VARCHAR(30) NOT NULL,
  description TEXT,
  performed_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (station_id) REFERENCES stations(id)
);

INSERT INTO divisions (name, capital) VALUES
('Dhaka', 'Dhaka'),
('Chittagong', 'Chittagong'),
('Rajshahi', 'Rajshahi'),
('Khulna', 'Khulna'),
('Barisal', 'Barisal'),
('Sylhet', 'Sylhet'),
('Rangpur', 'Rangpur'),
('Mymensingh', 'Mymensingh');

INSERT INTO districts (division_id, name) VALUES
(1, 'Dhaka'),
(1, 'Gazipur'),
(2, 'Chittagong'),
(2, 'Coxs Bazar'),
(3, 'Rajshahi'),
(3, 'Natore'),
(4, 'Khulna'),
(4, 'Satkhira'),
(5, 'Barisal'),
(5, 'Patuakhali'),
(6, 'Sylhet'),
(6, 'Moulvibazar'),
(7, 'Rangpur'),
(7, 'Dinajpur'),
(8, 'Mymensingh'),
(8, 'Netrokona');

INSERT INTO stations (district_id, name, latitude, longitude, establishment_year) VALUES
(1, 'Dhaka Central', 23.8103, 90.4125, 2020),
(2, 'Gazipur Town', 24.0025, 90.4284, 2019),
(3, 'Chittagong Port', 22.3569, 91.7832, 2018),
(4, 'Coxs Bazar Beach', 21.4272, 92.0058, 2021),
(5, 'Rajshahi City', 24.3745, 88.6044, 2017),
(6, 'Natore Town', 24.4137, 89.0772, 2020),
(7, 'Khulna Shipyard', 22.8456, 89.5403, 2019),
(8, 'Satkhira South', 22.7185, 89.0702, 2021),
(9, 'Barisal City', 22.7010, 90.3534, 2018),
(10, 'Patuakhali Coast', 22.3592, 90.3298, 2022),
(11, 'Sylhet Tea Garden', 24.9042, 91.8601, 2019),
(12, 'Moulvibazar Town', 24.4830, 91.7774, 2020),
(13, 'Rangpur City', 25.7439, 89.2752, 2018),
(14, 'Dinajpur North', 25.6347, 88.6478, 2021),
(15, 'Mymensingh City', 24.7471, 90.4203, 2019),
(16, 'Netrokona Town', 24.8826, 90.7280, 2020);

INSERT INTO air_quality (station_id, pm25, pm10, co, no2, so2, o3, temperature, humidity, pressure, wind_speed, aqi, reading_time) VALUES
(1, 45.23, 60.12, 2.34, 12.56, 5.67, 23.45, 28.5, 65.2, 1013.25, 5.2, 125.7, '2023-06-15 08:00:00'),
(2, 38.90, 55.67, 1.89, 10.23, 4.56, 20.12, 27.8, 68.5, 1012.80, 4.5, 110.3, '2023-06-15 08:00:00'),
(3, 52.11, 70.45, 3.12, 15.78, 6.89, 25.67, 30.1, 70.3, 1011.50, 6.8, 158.9, '2023-06-15 08:00:00'),
(4, 28.75, 45.89, 1.23, 8.45, 3.12, 18.90, 26.2, 72.1, 1013.75, 3.2, 95.6, '2023-06-15 08:00:00'),
(5, 35.67, 50.23, 1.78, 9.67, 4.23, 19.56, 29.3, 63.8, 1012.30, 5.5, 105.2, '2023-06-15 08:00:00'),
(6, 42.35, 58.90, 2.56, 11.34, 5.12, 22.34, 27.5, 67.2, 1013.60, 4.8, 120.5, '2023-06-15 08:00:00'),
(7, 31.45, 48.67, 1.45, 7.89, 3.45, 17.78, 28.7, 69.5, 1011.90, 5.0, 98.7, '2023-06-15 08:00:00'),
(8, 47.80, 65.34, 2.89, 14.56, 6.34, 24.12, 31.2, 64.7, 1010.45, 7.2, 145.3, '2023-06-15 08:00:00'),
(9, 39.12, 56.78, 2.01, 10.45, 4.78, 20.67, 26.8, 71.2, 1013.20, 4.2, 112.8, '2023-06-15 08:00:00'),
(10, 33.56, 49.12, 1.67, 8.90, 3.89, 18.34, 27.1, 73.5, 1014.10, 3.5, 102.1, '2023-06-15 08:00:00'),
(11, 50.23, 68.90, 3.45, 16.78, 7.12, 26.45, 32.5, 62.8, 1009.75, 8.0, 165.2, '2023-06-15 08:00:00'),
(12, 36.78, 53.45, 1.92, 9.78, 4.34, 19.89, 28.2, 66.7, 1012.90, 5.3, 108.9, '2023-06-15 08:00:00'),
(13, 29.90, 46.78, 1.34, 7.56, 3.01, 16.78, 25.6, 74.2, 1013.85, 2.8, 92.3, '2023-06-15 08:00:00'),
(14, 44.56, 62.34, 2.78, 13.45, 5.89, 23.12, 30.5, 65.9, 1011.20, 6.5, 138.7, '2023-06-15 08:00:00'),
(15, 40.12, 57.89, 2.23, 11.12, 5.01, 21.45, 29.7, 68.9, 1012.50, 5.8, 118.6, '2023-06-15 08:00:00'),
(16, 34.78, 51.23, 1.78, 9.12, 4.12, 19.23, 27.3, 70.5, 1013.40, 4.0, 104.5, '2023-06-15 08:00:00');

INSERT INTO entropy_analysis (station_id, entropy_value, temperature, humidity, wind_speed, analysis_time, parameters) VALUES
(1, 2.456, 28.5, 65.2, 5.2, '2023-06-15 08:00:00', 'basic'),
(2, 2.312, 27.8, 68.5, 4.5, '2023-06-15 08:00:00', 'basic'),
(3, 2.678, 30.1, 70.3, 6.8, '2023-06-15 08:00:00', 'basic'),
(4, 2.123, 26.2, 72.1, 3.2, '2023-06-15 08:00:00', 'basic'),
(5, 2.345, 29.3, 63.8, 5.5, '2023-06-15 08:00:00', 'basic'),
(6, 2.521, 27.5, 67.2, 4.8, '2023-06-15 08:00:00', 'basic'),
(7, 2.189, 28.7, 69.5, 5.0, '2023-06-15 08:00:00', 'basic'),
(8, 2.734, 31.2, 64.7, 7.2, '2023-06-15 08:00:00', 'basic'),
(9, 2.412, 26.8, 71.2, 4.2, '2023-06-15 08:00:00', 'basic'),
(10, 2.256, 27.1, 73.5, 3.5, '2023-06-15 08:00:00', 'basic'),
(11, 2.845, 32.5, 62.8, 8.0, '2023-06-15 08:00:00', 'basic'),
(12, 2.367, 28.2, 66.7, 5.3, '2023-06-15 08:00:00', 'basic'),
(13, 2.078, 25.6, 74.2, 2.8, '2023-06-15 08:00:00', 'basic'),
(14, 2.612, 30.5, 65.9, 6.5, '2023-06-15 08:00:00', 'basic'),
(15, 2.489, 29.7, 68.9, 5.8, '2023-06-15 08:00:00', 'basic'),
(16, 2.301, 27.3, 70.5, 4.0, '2023-06-15 08:00:00', 'basic');

INSERT INTO users (username, password, email, role) VALUES
('admin', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'admin@airquality.com', 'admin'),
('user', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'user@airquality.com', 'viewer');

INSERT INTO alerts (station_id, alert_type, severity, message, created_at) VALUES
(3, 'pollution', 'high', 'AQI exceeded threshold: 158.9', '2023-06-15 08:05:00'),
(8, 'pollution', 'high', 'AQI exceeded threshold: 145.3', '2023-06-15 08:05:00'),
(11, 'pollution', 'critical', 'AQI exceeded threshold: 165.2', '2023-06-15 08:05:00'),
(14, 'pollution', 'high', 'AQI exceeded threshold: 138.7', '2023-06-15 08:05:00');

INSERT INTO maintenance (station_id, maintenance_type, description, performed_at) VALUES
(1, 'sensor calibration', 'PM2.5 sensor calibration', '2023-06-01 10:00:00'),
(5, 'equipment replacement', 'Replaced humidity sensor', '2023-05-15 14:30:00');
