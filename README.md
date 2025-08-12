Bangladesh Air Quality Monitoring System
Submitted By : Arowa Mahbub Arshi

Youtube video link:    https://youtu.be/uJVOo2D30Fw?si=50aQfI5-DMzeDQAO

Project Overview
A comprehensive database and monitoring system tracking air quality across Bangladesh, developed by Arowa Mahbub Arshi from Metropolitan University. The system collects, analyzes, and visualizes air quality data to support environmental management and public health initiatives.

Key Features
Multi-parameter Monitoring: Tracks PM2.5, PM10, CO, NO2, SO2, O3

Meteorological Integration: Records temperature, humidity, pressure, wind speed

AQI Calculation: Computes real-time Air Quality Index for each station

Advanced Analytics: Entropy analysis for pattern recognition

Alert System: Automatic notifications when thresholds are exceeded

Maintenance Tracking: Complete station maintenance history

Geospatial Analysis: Data organized by divisions and districts

Database Schema
Core Tables
Table	Description
divisions	Administrative divisions of Bangladesh (e.g., Dhaka, Chittagong)
districts	Districts within each division with geospatial data
stations	Monitoring station details (location, installation date, status)
air_quality	Time-series measurements of all parameters
entropy_analysis	Calculated entropy values for pattern detection
Support Tables
Table	Description
users	System users with role-based access control
alerts	Alert history and notification records
maintenance	Station maintenance logs and schedules
Technical Implementation
Backend
Database: MySQL 8.0 with geospatial extensions

API: RESTful services using Node.js/Express

Data Processing: Python scripts for AQI calculation and entropy analysis

Frontend (Optional)
Dashboard: React.js with Chart.js visualizations

Mapping: Leaflet.js for geospatial display of stations

Installation Guide
Prerequisites

MySQL Server 8.0+

Node.js 16.x

Python 3.9+ (for analytics scripts)

Setup

bash
git clone https://github.com/your-repo/bd-air-quality.git
cd bd-air-quality
mysql -u root -p < database/schema.sql
npm install
Configuration
Edit config/db.config.js with your database credentials

Usage Examples
Common Queries
sql
-- Get current AQI by division
SELECT d.name, AVG(aq.aqi_value) 
FROM air_quality aq
JOIN stations s ON aq.station_id = s.id
JOIN districts di ON s.district_id = di.id
JOIN divisions d ON di.division_id = d.id
WHERE aq.timestamp = (SELECT MAX(timestamp) FROM air_quality)
GROUP BY d.name;

-- Find stations needing maintenance
SELECT s.name, s.location, MAX(m.maintenance_date) 
FROM stations s
LEFT JOIN maintenance m ON s.id = m.station_id
GROUP BY s.id
HAVING DATEDIFF(NOW(), MAX(m.maintenance_date)) > 180 
   OR MAX(m.maintenance_date) IS NULL;
aGROUPUP BY division_name;
