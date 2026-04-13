

 -- Creating Tables
 
CREATE TABLE stops ( 
	stop_id TEXT,
	stop_code TEXT,
	stop_name TEXT,
	stop_lat FLOAT,
	stop_lon FLOAT,
	location_type TEXT,
	parent_station TEXT,
	wheelchair_boarding TEXT,
	level_id TEXT,
	platform_code TEXT
);
--route_id,agency_id,route_short_name,route_long_name,route_desc,route_type,route_color,route_text_color,exact_times
DROP TABLE ROUTES;

CREATE TABLE routes (
	route_id TEXT,
	agency_id TEXT,
	route_short_name TEXT,
	route_long_name TEXT,
	route_desc TEXT,
	route_type TEXT,
	route_color TEXT,
	route_text_color TEXT,
	exact_times TEXT
);

CREATE TABLE trips (
	route_id TEXT,
	service_id TEXT,
	trip_id TEXT,
	shape_id TEXT,
	trip_headsign TEXT,
	direction_id TEXT,
	block_id TEXT,
	wheelchair_accessible TEXT,
	route_direction TEXT,
	trip_note TEXT,
	bikes_allowed TEXT
);

CREATE TABLE stop_times (
	trip_id TEXT,
	arrival_time TEXT,
	departure_time TEXT,
	stop_id TEXT,
	stop_sequence INT,
	stop_headsign TEXT,
	pickup_type TEXT,
	drop_off_type TEXT,
	shape_dist_traveled TEXT,
	timepoint TEXT,
	stop_note TEXT
);

-- Import Data

COPY stops FROM 'D:\stops.txt' DELIMITER ',' CSV HEADER;
COPY routes FROM 'D:\routes.txt' DELIMITER ',' CSV HEADER;
COPY trips FROM 'D:\trips.txt' DELIMITER ',' CSV HEADER;
COPY stop_times FROM 'D:\stop_times.txt' DELIMITER ',' CSV HEADER;


-- Convert time into usable format

ALTER TABLE stop_times ADD COLUMN hour INT;

UPDATE stop_times
SET hour = CAST(SPLIT_PART(arrival_time, ":", 1) AS INT);



-- Join Data

SELECT s.stop_name, r.route_short_name, st.arrival_time
FROM stop_times st
JOIN stops s ON s.stop_id = st.stop_id
JOIN trips t ON t.trip_id = st.trip_id
JOIN routes r ON t.route_id = r.route_id
LIMIT 100;

-- 1.Peak Bus Hour

SELECT hour, COUNT(*) AS trips
FROM stop_times
GROUP BY hour
ORDER BY trips DESC;

-- 2. Top 10 Busiest Stops

SELECT s.stop_name, COUNT(*) AS total_trips
FROM stops s
JOIN stop_times st ON s.stop_id = st.stop_id
GROUP BY stop_name
ORDER BY total_trips DESC
LIMIT 10;

-- 3. Most frequent Bus Routes

SELECT r.route_short_name, COUNT(DISTINCT t.trip_id) AS trips
FROM trips t
JOIN routes r ON r.route_id = t.route_id
GROUP BY route_short_name
ORDER BY trips DESC
LIMIT 10;


-- Peak Hour per Route

SELECT r.route_short_name, adj_hour, COUNT(*) AS trips
FROM stop_times st
JOIN trips t ON t.trip_id = st.trip_id
JOIN routes r ON r.route_id = t.route_id
GROUP BY r.route_short_name, adj_hour
ORDER BY trips DESC;













