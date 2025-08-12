-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: Aug 12, 2025 at 06:06 PM
-- Server version: 10.4.32-MariaDB
-- PHP Version: 8.2.12

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `bangladesh_air_quality`
--

DELIMITER $$
--
-- Procedures
--
CREATE DEFINER=`root`@`localhost` PROCEDURE `compute_monthly_patterns` ()   BEGIN
  INSERT INTO pollution_patterns (post_id, month_year, avg_pm25, avg_pm10, avg_aqi)
  SELECT 
    post_id,
    DATE_FORMAT(reading_time, '%Y-%m') AS month_year,
    AVG(pm25) AS avg_pm25,
    AVG(pm10) AS avg_pm10,
    AVG(aqi) AS avg_aqi
  FROM pollution_readings
  GROUP BY post_id, DATE_FORMAT(reading_time, '%Y-%m')
  ON DUPLICATE KEY UPDATE
    avg_pm25 = VALUES(avg_pm25),
    avg_pm10 = VALUES(avg_pm10),
    avg_aqi = VALUES(avg_aqi);
END$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `air_quality`
--

CREATE TABLE `air_quality` (
  `id` bigint(20) NOT NULL,
  `station_id` int(11) NOT NULL,
  `pm25` decimal(5,2) NOT NULL,
  `pm10` decimal(5,2) NOT NULL,
  `co` decimal(5,2) NOT NULL,
  `no2` decimal(5,2) NOT NULL,
  `so2` decimal(5,2) NOT NULL,
  `o3` decimal(5,2) NOT NULL,
  `temperature` decimal(4,2) NOT NULL,
  `humidity` decimal(5,2) NOT NULL,
  `pressure` decimal(7,2) NOT NULL,
  `wind_speed` decimal(4,2) DEFAULT NULL,
  `aqi` decimal(5,2) NOT NULL,
  `reading_time` datetime NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `air_quality`
--

INSERT INTO `air_quality` (`id`, `station_id`, `pm25`, `pm10`, `co`, `no2`, `so2`, `o3`, `temperature`, `humidity`, `pressure`, `wind_speed`, `aqi`, `reading_time`) VALUES
(1, 1, 45.23, 60.12, 2.34, 12.56, 5.67, 23.45, 28.50, 65.20, 1013.25, 5.20, 125.70, '2023-06-15 08:00:00'),
(2, 2, 38.90, 55.67, 1.89, 10.23, 4.56, 20.12, 27.80, 68.50, 1012.80, 4.50, 110.30, '2023-06-15 08:00:00'),
(3, 3, 52.11, 70.45, 3.12, 15.78, 6.89, 25.67, 30.10, 70.30, 1011.50, 6.80, 158.90, '2023-06-15 08:00:00'),
(4, 4, 28.75, 45.89, 1.23, 8.45, 3.12, 18.90, 26.20, 72.10, 1013.75, 3.20, 95.60, '2023-06-15 08:00:00'),
(5, 5, 35.67, 50.23, 1.78, 9.67, 4.23, 19.56, 29.30, 63.80, 1012.30, 5.50, 105.20, '2023-06-15 08:00:00'),
(6, 6, 42.35, 58.90, 2.56, 11.34, 5.12, 22.34, 27.50, 67.20, 1013.60, 4.80, 120.50, '2023-06-15 08:00:00'),
(7, 7, 31.45, 48.67, 1.45, 7.89, 3.45, 17.78, 28.70, 69.50, 1011.90, 5.00, 98.70, '2023-06-15 08:00:00'),
(8, 8, 47.80, 65.34, 2.89, 14.56, 6.34, 24.12, 31.20, 64.70, 1010.45, 7.20, 145.30, '2023-06-15 08:00:00'),
(9, 9, 39.12, 56.78, 2.01, 10.45, 4.78, 20.67, 26.80, 71.20, 1013.20, 4.20, 112.80, '2023-06-15 08:00:00'),
(10, 10, 33.56, 49.12, 1.67, 8.90, 3.89, 18.34, 27.10, 73.50, 1014.10, 3.50, 102.10, '2023-06-15 08:00:00'),
(11, 11, 50.23, 68.90, 3.45, 16.78, 7.12, 26.45, 32.50, 62.80, 1009.75, 8.00, 165.20, '2023-06-15 08:00:00'),
(12, 12, 36.78, 53.45, 1.92, 9.78, 4.34, 19.89, 28.20, 66.70, 1012.90, 5.30, 108.90, '2023-06-15 08:00:00'),
(13, 13, 29.90, 46.78, 1.34, 7.56, 3.01, 16.78, 25.60, 74.20, 1013.85, 2.80, 92.30, '2023-06-15 08:00:00'),
(14, 14, 44.56, 62.34, 2.78, 13.45, 5.89, 23.12, 30.50, 65.90, 1011.20, 6.50, 138.70, '2023-06-15 08:00:00'),
(15, 15, 40.12, 57.89, 2.23, 11.12, 5.01, 21.45, 29.70, 68.90, 1012.50, 5.80, 118.60, '2023-06-15 08:00:00'),
(16, 16, 34.78, 51.23, 1.78, 9.12, 4.12, 19.23, 27.30, 70.50, 1013.40, 4.00, 104.50, '2023-06-15 08:00:00');

-- --------------------------------------------------------

--
-- Table structure for table `alerts`
--

CREATE TABLE `alerts` (
  `id` int(11) NOT NULL,
  `station_id` int(11) NOT NULL,
  `alert_type` varchar(20) NOT NULL,
  `severity` varchar(10) NOT NULL,
  `message` varchar(255) NOT NULL,
  `created_at` datetime NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `alerts`
--

INSERT INTO `alerts` (`id`, `station_id`, `alert_type`, `severity`, `message`, `created_at`) VALUES
(1, 3, 'pollution', 'high', 'AQI exceeded threshold: 158.9', '2023-06-15 08:05:00'),
(2, 8, 'pollution', 'high', 'AQI exceeded threshold: 145.3', '2023-06-15 08:05:00'),
(3, 11, 'pollution', 'critical', 'AQI exceeded threshold: 165.2', '2023-06-15 08:05:00'),
(4, 14, 'pollution', 'high', 'AQI exceeded threshold: 138.7', '2023-06-15 08:05:00');

-- --------------------------------------------------------

--
-- Table structure for table `area_zones`
--

CREATE TABLE `area_zones` (
  `id` int(11) NOT NULL,
  `region_id` int(11) NOT NULL,
  `name` varchar(25) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `complexity_alerts`
--

CREATE TABLE `complexity_alerts` (
  `id` int(11) NOT NULL,
  `post_id` int(11) NOT NULL,
  `complexity_score` decimal(10,6) NOT NULL,
  `threshold_type` varchar(20) NOT NULL,
  `message` varchar(255) NOT NULL,
  `created_at` datetime DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `data_complexity`
--

CREATE TABLE `data_complexity` (
  `id` int(11) NOT NULL,
  `post_id` int(11) NOT NULL,
  `complexity_score` decimal(10,6) NOT NULL,
  `temperature` decimal(4,2) NOT NULL,
  `humidity` decimal(5,2) NOT NULL,
  `wind_speed` decimal(4,2) DEFAULT NULL,
  `analysis_time` datetime NOT NULL,
  `parameters` varchar(100) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Triggers `data_complexity`
--
DELIMITER $$
CREATE TRIGGER `monitor_complexity` AFTER INSERT ON `data_complexity` FOR EACH ROW BEGIN
  IF NEW.complexity_score > 2.7 THEN
    INSERT INTO complexity_alerts (post_id, complexity_score, threshold_type, message)
    VALUES (NEW.post_id, NEW.complexity_score, 'high', CONCAT('High complexity detected: ', NEW.complexity_score));
  ELSEIF NEW.complexity_score < 1.8 THEN
    INSERT INTO complexity_alerts (post_id, complexity_score, threshold_type, message)
    VALUES (NEW.post_id, NEW.complexity_score, 'low', CONCAT('Low complexity detected: ', NEW.complexity_score));
  END IF;
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `data_exports`
--

CREATE TABLE `data_exports` (
  `id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `export_type` varchar(50) NOT NULL,
  `parameters` text DEFAULT NULL,
  `record_count` int(11) NOT NULL,
  `exported_at` datetime DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `districts`
--

CREATE TABLE `districts` (
  `id` int(11) NOT NULL,
  `division_id` int(11) NOT NULL,
  `name` varchar(25) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `districts`
--

INSERT INTO `districts` (`id`, `division_id`, `name`) VALUES
(1, 1, 'Dhaka'),
(2, 1, 'Gazipur'),
(3, 2, 'Chittagong'),
(4, 2, 'Coxs Bazar'),
(6, 3, 'Natore'),
(5, 3, 'Rajshahi'),
(7, 4, 'Khulna'),
(8, 4, 'Satkhira'),
(9, 5, 'Barisal'),
(10, 5, 'Patuakhali'),
(12, 6, 'Moulvibazar'),
(11, 6, 'Sylhet'),
(14, 7, 'Dinajpur'),
(13, 7, 'Rangpur'),
(15, 8, 'Mymensingh'),
(16, 8, 'Netrokona');

-- --------------------------------------------------------

--
-- Table structure for table `divisions`
--

CREATE TABLE `divisions` (
  `id` int(11) NOT NULL,
  `name` varchar(25) NOT NULL,
  `capital` varchar(25) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `divisions`
--

INSERT INTO `divisions` (`id`, `name`, `capital`) VALUES
(1, 'Dhaka', 'Dhaka'),
(2, 'Chittagong', 'Chittagong'),
(3, 'Rajshahi', 'Rajshahi'),
(4, 'Khulna', 'Khulna'),
(5, 'Barisal', 'Barisal'),
(6, 'Sylhet', 'Sylhet'),
(7, 'Rangpur', 'Rangpur'),
(8, 'Mymensingh', 'Mymensingh');

-- --------------------------------------------------------

--
-- Table structure for table `entropy_analysis`
--

CREATE TABLE `entropy_analysis` (
  `id` int(11) NOT NULL,
  `station_id` int(11) NOT NULL,
  `entropy_value` decimal(10,6) NOT NULL,
  `temperature` decimal(4,2) NOT NULL,
  `humidity` decimal(5,2) NOT NULL,
  `wind_speed` decimal(4,2) DEFAULT NULL,
  `analysis_time` datetime NOT NULL,
  `parameters` varchar(100) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `entropy_analysis`
--

INSERT INTO `entropy_analysis` (`id`, `station_id`, `entropy_value`, `temperature`, `humidity`, `wind_speed`, `analysis_time`, `parameters`) VALUES
(1, 1, 2.456000, 28.50, 65.20, 5.20, '2023-06-15 08:00:00', 'basic'),
(2, 2, 2.312000, 27.80, 68.50, 4.50, '2023-06-15 08:00:00', 'basic'),
(3, 3, 2.678000, 30.10, 70.30, 6.80, '2023-06-15 08:00:00', 'basic'),
(4, 4, 2.123000, 26.20, 72.10, 3.20, '2023-06-15 08:00:00', 'basic'),
(5, 5, 2.345000, 29.30, 63.80, 5.50, '2023-06-15 08:00:00', 'basic'),
(6, 6, 2.521000, 27.50, 67.20, 4.80, '2023-06-15 08:00:00', 'basic'),
(7, 7, 2.189000, 28.70, 69.50, 5.00, '2023-06-15 08:00:00', 'basic'),
(8, 8, 2.734000, 31.20, 64.70, 7.20, '2023-06-15 08:00:00', 'basic'),
(9, 9, 2.412000, 26.80, 71.20, 4.20, '2023-06-15 08:00:00', 'basic'),
(10, 10, 2.256000, 27.10, 73.50, 3.50, '2023-06-15 08:00:00', 'basic'),
(11, 11, 2.845000, 32.50, 62.80, 8.00, '2023-06-15 08:00:00', 'basic'),
(12, 12, 2.367000, 28.20, 66.70, 5.30, '2023-06-15 08:00:00', 'basic'),
(13, 13, 2.078000, 25.60, 74.20, 2.80, '2023-06-15 08:00:00', 'basic'),
(14, 14, 2.612000, 30.50, 65.90, 6.50, '2023-06-15 08:00:00', 'basic'),
(15, 15, 2.489000, 29.70, 68.90, 5.80, '2023-06-15 08:00:00', 'basic'),
(16, 16, 2.301000, 27.30, 70.50, 4.00, '2023-06-15 08:00:00', 'basic');

-- --------------------------------------------------------

--
-- Table structure for table `equipment_upkeep`
--

CREATE TABLE `equipment_upkeep` (
  `id` int(11) NOT NULL,
  `post_id` int(11) NOT NULL,
  `upkeep_type` varchar(30) NOT NULL,
  `description` text DEFAULT NULL,
  `performed_at` datetime NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `maintenance`
--

CREATE TABLE `maintenance` (
  `id` int(11) NOT NULL,
  `station_id` int(11) NOT NULL,
  `maintenance_type` varchar(30) NOT NULL,
  `description` text DEFAULT NULL,
  `performed_at` datetime NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `maintenance`
--

INSERT INTO `maintenance` (`id`, `station_id`, `maintenance_type`, `description`, `performed_at`) VALUES
(1, 1, 'sensor calibration', 'PM2.5 sensor calibration', '2023-06-01 10:00:00'),
(2, 5, 'equipment replacement', 'Replaced humidity sensor', '2023-05-15 00:00:00');

-- --------------------------------------------------------

--
-- Table structure for table `monitoring_posts`
--

CREATE TABLE `monitoring_posts` (
  `id` int(11) NOT NULL,
  `zone_id` int(11) NOT NULL,
  `name` varchar(50) NOT NULL,
  `latitude` decimal(8,6) NOT NULL,
  `longitude` decimal(9,6) NOT NULL,
  `establishment_year` year(4) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `pollution_patterns`
--

CREATE TABLE `pollution_patterns` (
  `id` int(11) NOT NULL,
  `post_id` int(11) NOT NULL,
  `month_year` varchar(7) NOT NULL,
  `avg_pm25` decimal(5,2) NOT NULL,
  `avg_pm10` decimal(5,2) NOT NULL,
  `avg_aqi` decimal(5,2) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `pollution_readings`
--

CREATE TABLE `pollution_readings` (
  `id` bigint(20) NOT NULL,
  `post_id` int(11) NOT NULL,
  `pm25` decimal(5,2) NOT NULL,
  `pm10` decimal(5,2) NOT NULL,
  `co` decimal(5,2) NOT NULL,
  `no2` decimal(5,2) NOT NULL,
  `so2` decimal(5,2) NOT NULL,
  `o3` decimal(5,2) NOT NULL,
  `temperature` decimal(4,2) NOT NULL,
  `humidity` decimal(5,2) NOT NULL,
  `pressure` decimal(7,2) NOT NULL,
  `wind_speed` decimal(4,2) DEFAULT NULL,
  `aqi` decimal(5,2) NOT NULL,
  `reading_time` datetime NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `post_conditions`
--

CREATE TABLE `post_conditions` (
  `id` int(11) NOT NULL,
  `post_id` int(11) NOT NULL,
  `last_maintenance` date DEFAULT NULL,
  `sensor_status` varchar(20) DEFAULT 'active',
  `data_quality_score` int(11) DEFAULT 100,
  `last_updated` datetime DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Stand-in structure for view `post_health_overview`
-- (See below for the actual view)
--
CREATE TABLE `post_health_overview` (
`post_id` int(11)
,`post_name` varchar(50)
,`zone` varchar(25)
,`region` varchar(25)
,`sensor_status` varchar(20)
,`data_quality_score` int(11)
,`last_maintenance` date
,`readings_count` bigint(21)
,`last_reading` datetime
);

-- --------------------------------------------------------

--
-- Table structure for table `region_info`
--

CREATE TABLE `region_info` (
  `id` int(11) NOT NULL,
  `name` varchar(25) NOT NULL,
  `capital` varchar(25) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `stations`
--

CREATE TABLE `stations` (
  `id` int(11) NOT NULL,
  `district_id` int(11) NOT NULL,
  `name` varchar(50) NOT NULL,
  `latitude` decimal(8,6) NOT NULL,
  `longitude` decimal(9,6) NOT NULL,
  `establishment_year` year(4) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `stations`
--

INSERT INTO `stations` (`id`, `district_id`, `name`, `latitude`, `longitude`, `establishment_year`) VALUES
(1, 1, 'Dhaka Central', 23.810300, 90.412500, '2020'),
(2, 2, 'Gazipur Town', 24.002500, 90.428400, '2019'),
(3, 3, 'Chittagong Port', 22.356900, 91.783200, '2018'),
(4, 4, 'Coxs Bazar Beach', 21.427200, 92.005800, '2021'),
(5, 5, 'Rajshahi City', 24.374500, 88.604400, '2017'),
(6, 6, 'Natore Town', 24.413700, 89.077200, '2020'),
(7, 7, 'Khulna Shipyard', 22.845600, 89.540300, '2019'),
(8, 8, 'Satkhira South', 22.718500, 89.070200, '2021'),
(9, 9, 'Barisal City', 22.701000, 90.353400, '2018'),
(10, 10, 'Patuakhali Coast', 22.359200, 90.329800, '2022'),
(11, 11, 'Sylhet Tea Garden', 24.904200, 91.860100, '2019'),
(12, 12, 'Moulvibazar Town', 24.483000, 91.777400, '2020'),
(13, 13, 'Rangpur City', 25.743900, 89.275200, '2018'),
(14, 14, 'Dinajpur North', 25.634700, 88.647800, '2021'),
(15, 15, 'Mymensingh City', 24.747100, 90.420300, '2019'),
(16, 16, 'Netrokona Town', 24.882600, 90.728000, '2020');

-- --------------------------------------------------------

--
-- Table structure for table `system_users`
--

CREATE TABLE `system_users` (
  `id` int(11) NOT NULL,
  `username` varchar(20) NOT NULL,
  `password` varchar(255) NOT NULL,
  `email` varchar(50) NOT NULL,
  `role` varchar(10) NOT NULL DEFAULT 'viewer',
  `created_at` datetime NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `users`
--

CREATE TABLE `users` (
  `id` int(11) NOT NULL,
  `username` varchar(20) NOT NULL,
  `password` varchar(255) NOT NULL,
  `email` varchar(50) NOT NULL,
  `role` varchar(10) NOT NULL DEFAULT 'viewer',
  `created_at` datetime NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `users`
--

INSERT INTO `users` (`id`, `username`, `password`, `email`, `role`, `created_at`) VALUES
(1, 'admin', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'admin@airquality.com', 'admin', '2025-08-12 16:26:58'),
(2, 'user', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'user@airquality.com', 'viewer', '2025-08-12 16:26:58');

-- --------------------------------------------------------

--
-- Table structure for table `user_preferences`
--

CREATE TABLE `user_preferences` (
  `id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `post_id` int(11) NOT NULL,
  `created_at` datetime DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `warning_notices`
--

CREATE TABLE `warning_notices` (
  `id` int(11) NOT NULL,
  `post_id` int(11) NOT NULL,
  `notice_type` varchar(20) NOT NULL,
  `severity` varchar(10) NOT NULL,
  `message` varchar(255) NOT NULL,
  `created_at` datetime NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Structure for view `post_health_overview`
--
DROP TABLE IF EXISTS `post_health_overview`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `post_health_overview`  AS SELECT `mp`.`id` AS `post_id`, `mp`.`name` AS `post_name`, `az`.`name` AS `zone`, `ri`.`name` AS `region`, `pc`.`sensor_status` AS `sensor_status`, `pc`.`data_quality_score` AS `data_quality_score`, `pc`.`last_maintenance` AS `last_maintenance`, count(distinct `pr`.`id`) AS `readings_count`, max(`pr`.`reading_time`) AS `last_reading` FROM ((((`monitoring_posts` `mp` join `area_zones` `az` on(`mp`.`zone_id` = `az`.`id`)) join `region_info` `ri` on(`az`.`region_id` = `ri`.`id`)) left join `post_conditions` `pc` on(`mp`.`id` = `pc`.`post_id`)) left join `pollution_readings` `pr` on(`mp`.`id` = `pr`.`post_id`)) GROUP BY `mp`.`id`, `mp`.`name`, `az`.`name`, `ri`.`name`, `pc`.`sensor_status`, `pc`.`data_quality_score`, `pc`.`last_maintenance` ;

--
-- Indexes for dumped tables
--

--
-- Indexes for table `air_quality`
--
ALTER TABLE `air_quality`
  ADD PRIMARY KEY (`id`),
  ADD KEY `station_id` (`station_id`);

--
-- Indexes for table `alerts`
--
ALTER TABLE `alerts`
  ADD PRIMARY KEY (`id`),
  ADD KEY `station_id` (`station_id`);

--
-- Indexes for table `area_zones`
--
ALTER TABLE `area_zones`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `region_id` (`region_id`,`name`);

--
-- Indexes for table `complexity_alerts`
--
ALTER TABLE `complexity_alerts`
  ADD PRIMARY KEY (`id`),
  ADD KEY `post_id` (`post_id`);

--
-- Indexes for table `data_complexity`
--
ALTER TABLE `data_complexity`
  ADD PRIMARY KEY (`id`),
  ADD KEY `post_id` (`post_id`);

--
-- Indexes for table `data_exports`
--
ALTER TABLE `data_exports`
  ADD PRIMARY KEY (`id`),
  ADD KEY `user_id` (`user_id`);

--
-- Indexes for table `districts`
--
ALTER TABLE `districts`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `division_id` (`division_id`,`name`);

--
-- Indexes for table `divisions`
--
ALTER TABLE `divisions`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `name` (`name`);

--
-- Indexes for table `entropy_analysis`
--
ALTER TABLE `entropy_analysis`
  ADD PRIMARY KEY (`id`),
  ADD KEY `station_id` (`station_id`);

--
-- Indexes for table `equipment_upkeep`
--
ALTER TABLE `equipment_upkeep`
  ADD PRIMARY KEY (`id`),
  ADD KEY `post_id` (`post_id`);

--
-- Indexes for table `maintenance`
--
ALTER TABLE `maintenance`
  ADD PRIMARY KEY (`id`),
  ADD KEY `station_id` (`station_id`);

--
-- Indexes for table `monitoring_posts`
--
ALTER TABLE `monitoring_posts`
  ADD PRIMARY KEY (`id`),
  ADD KEY `zone_id` (`zone_id`);

--
-- Indexes for table `pollution_patterns`
--
ALTER TABLE `pollution_patterns`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `post_id` (`post_id`,`month_year`);

--
-- Indexes for table `pollution_readings`
--
ALTER TABLE `pollution_readings`
  ADD PRIMARY KEY (`id`),
  ADD KEY `post_id` (`post_id`);

--
-- Indexes for table `post_conditions`
--
ALTER TABLE `post_conditions`
  ADD PRIMARY KEY (`id`),
  ADD KEY `post_id` (`post_id`);

--
-- Indexes for table `region_info`
--
ALTER TABLE `region_info`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `name` (`name`);

--
-- Indexes for table `stations`
--
ALTER TABLE `stations`
  ADD PRIMARY KEY (`id`),
  ADD KEY `district_id` (`district_id`);

--
-- Indexes for table `system_users`
--
ALTER TABLE `system_users`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `username` (`username`),
  ADD UNIQUE KEY `email` (`email`);

--
-- Indexes for table `users`
--
ALTER TABLE `users`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `username` (`username`),
  ADD UNIQUE KEY `email` (`email`);

--
-- Indexes for table `user_preferences`
--
ALTER TABLE `user_preferences`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `user_id` (`user_id`,`post_id`),
  ADD KEY `post_id` (`post_id`);

--
-- Indexes for table `warning_notices`
--
ALTER TABLE `warning_notices`
  ADD PRIMARY KEY (`id`),
  ADD KEY `post_id` (`post_id`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `air_quality`
--
ALTER TABLE `air_quality`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=17;

--
-- AUTO_INCREMENT for table `alerts`
--
ALTER TABLE `alerts`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT for table `area_zones`
--
ALTER TABLE `area_zones`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `complexity_alerts`
--
ALTER TABLE `complexity_alerts`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `data_complexity`
--
ALTER TABLE `data_complexity`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `data_exports`
--
ALTER TABLE `data_exports`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `districts`
--
ALTER TABLE `districts`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=17;

--
-- AUTO_INCREMENT for table `divisions`
--
ALTER TABLE `divisions`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=9;

--
-- AUTO_INCREMENT for table `entropy_analysis`
--
ALTER TABLE `entropy_analysis`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=17;

--
-- AUTO_INCREMENT for table `equipment_upkeep`
--
ALTER TABLE `equipment_upkeep`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `maintenance`
--
ALTER TABLE `maintenance`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT for table `monitoring_posts`
--
ALTER TABLE `monitoring_posts`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `pollution_patterns`
--
ALTER TABLE `pollution_patterns`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `pollution_readings`
--
ALTER TABLE `pollution_readings`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `post_conditions`
--
ALTER TABLE `post_conditions`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `region_info`
--
ALTER TABLE `region_info`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `stations`
--
ALTER TABLE `stations`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=17;

--
-- AUTO_INCREMENT for table `system_users`
--
ALTER TABLE `system_users`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `users`
--
ALTER TABLE `users`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT for table `user_preferences`
--
ALTER TABLE `user_preferences`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `warning_notices`
--
ALTER TABLE `warning_notices`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `air_quality`
--
ALTER TABLE `air_quality`
  ADD CONSTRAINT `air_quality_ibfk_1` FOREIGN KEY (`station_id`) REFERENCES `stations` (`id`);

--
-- Constraints for table `alerts`
--
ALTER TABLE `alerts`
  ADD CONSTRAINT `alerts_ibfk_1` FOREIGN KEY (`station_id`) REFERENCES `stations` (`id`);

--
-- Constraints for table `area_zones`
--
ALTER TABLE `area_zones`
  ADD CONSTRAINT `area_zones_ibfk_1` FOREIGN KEY (`region_id`) REFERENCES `region_info` (`id`);

--
-- Constraints for table `complexity_alerts`
--
ALTER TABLE `complexity_alerts`
  ADD CONSTRAINT `complexity_alerts_ibfk_1` FOREIGN KEY (`post_id`) REFERENCES `monitoring_posts` (`id`);

--
-- Constraints for table `data_complexity`
--
ALTER TABLE `data_complexity`
  ADD CONSTRAINT `data_complexity_ibfk_1` FOREIGN KEY (`post_id`) REFERENCES `monitoring_posts` (`id`);

--
-- Constraints for table `data_exports`
--
ALTER TABLE `data_exports`
  ADD CONSTRAINT `data_exports_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `system_users` (`id`);

--
-- Constraints for table `districts`
--
ALTER TABLE `districts`
  ADD CONSTRAINT `districts_ibfk_1` FOREIGN KEY (`division_id`) REFERENCES `divisions` (`id`);

--
-- Constraints for table `entropy_analysis`
--
ALTER TABLE `entropy_analysis`
  ADD CONSTRAINT `entropy_analysis_ibfk_1` FOREIGN KEY (`station_id`) REFERENCES `stations` (`id`);

--
-- Constraints for table `equipment_upkeep`
--
ALTER TABLE `equipment_upkeep`
  ADD CONSTRAINT `equipment_upkeep_ibfk_1` FOREIGN KEY (`post_id`) REFERENCES `monitoring_posts` (`id`);

--
-- Constraints for table `maintenance`
--
ALTER TABLE `maintenance`
  ADD CONSTRAINT `maintenance_ibfk_1` FOREIGN KEY (`station_id`) REFERENCES `stations` (`id`);

--
-- Constraints for table `monitoring_posts`
--
ALTER TABLE `monitoring_posts`
  ADD CONSTRAINT `monitoring_posts_ibfk_1` FOREIGN KEY (`zone_id`) REFERENCES `area_zones` (`id`);

--
-- Constraints for table `pollution_patterns`
--
ALTER TABLE `pollution_patterns`
  ADD CONSTRAINT `pollution_patterns_ibfk_1` FOREIGN KEY (`post_id`) REFERENCES `monitoring_posts` (`id`);

--
-- Constraints for table `pollution_readings`
--
ALTER TABLE `pollution_readings`
  ADD CONSTRAINT `pollution_readings_ibfk_1` FOREIGN KEY (`post_id`) REFERENCES `monitoring_posts` (`id`);

--
-- Constraints for table `post_conditions`
--
ALTER TABLE `post_conditions`
  ADD CONSTRAINT `post_conditions_ibfk_1` FOREIGN KEY (`post_id`) REFERENCES `monitoring_posts` (`id`);

--
-- Constraints for table `stations`
--
ALTER TABLE `stations`
  ADD CONSTRAINT `stations_ibfk_1` FOREIGN KEY (`district_id`) REFERENCES `districts` (`id`);

--
-- Constraints for table `user_preferences`
--
ALTER TABLE `user_preferences`
  ADD CONSTRAINT `user_preferences_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `system_users` (`id`),
  ADD CONSTRAINT `user_preferences_ibfk_2` FOREIGN KEY (`post_id`) REFERENCES `monitoring_posts` (`id`);

--
-- Constraints for table `warning_notices`
--
ALTER TABLE `warning_notices`
  ADD CONSTRAINT `warning_notices_ibfk_1` FOREIGN KEY (`post_id`) REFERENCES `monitoring_posts` (`id`);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
