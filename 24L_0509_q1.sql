-- Question 01 - CREATING THE TABLE WITH THE RESPECTIVE TABLE STRUCTURE AND DATA PROVIDED 
--use master
--GO
--drop database lab4f;
--GO
create database lab4f;
GO
use lab4f;
GO
-- 🚗 Driver Table (Stores Player Information)
CREATE TABLE Driver (
    driver_id INT PRIMARY KEY IDENTITY(1,1),
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    country VARCHAR(50),
    date_of_birth DATE,
    license_number VARCHAR(20) UNIQUE NOT NULL
);

-- 🚘 Car Table (Car Details)
CREATE TABLE Car (
    car_id INT PRIMARY KEY IDENTITY(1,1),
    model VARCHAR(50) NOT NULL,
    brand VARCHAR(50) NOT NULL,
    horsepower INT CHECK (horsepower > 0),
    top_speed INT CHECK (top_speed > 0),
    year_manufactured INT CHECK (year_manufactured >= 1980),
    price DECIMAL(10,2) CHECK (price > 0)
);

-- 🚦 Driver_Car (M:N Relationship - A Driver Can Own Multiple Cars)
CREATE TABLE Driver_Car (
    driver_id INT,
    car_id INT,
    purchase_date DATE DEFAULT GETDATE(),
    PRIMARY KEY (driver_id, car_id),
    FOREIGN KEY (driver_id) REFERENCES Driver(driver_id) ON DELETE CASCADE,
    FOREIGN KEY (car_id) REFERENCES Car(car_id) ON DELETE CASCADE
);

-- ⚙️ Upgrade Table (Car Modifications)
CREATE TABLE Upgrade (
    upgrade_id INT PRIMARY KEY IDENTITY(1,1),
    upgrade_name VARCHAR(50) NOT NULL UNIQUE,
    upgrade_type VARCHAR(50) CHECK (upgrade_type IN ('Engine', 'Tires', 'Nitrous', 'Brakes', 'Aerodynamics')),
    performance_boost INT CHECK (performance_boost > 0),
    price DECIMAL(10,2) CHECK (price > 0)
);

-- 🛠️ Car_Upgrade (M:N Relationship - A Car Can Have Multiple Upgrades)
CREATE TABLE Car_Upgrade (
    car_id INT,
    upgrade_id INT,
    install_date DATE DEFAULT GETDATE(),
    PRIMARY KEY (car_id, upgrade_id),
    FOREIGN KEY (car_id) REFERENCES Car(car_id) ON DELETE CASCADE,
    FOREIGN KEY (upgrade_id) REFERENCES Upgrade(upgrade_id) ON DELETE CASCADE
);

-- 🏁 Race Table (Details of Each Race)
CREATE TABLE Race (
    race_id INT PRIMARY KEY IDENTITY(1,1),
    race_name VARCHAR(50) NOT NULL,
    location VARCHAR(100),
    race_date DATETIME DEFAULT GETDATE(),
    track_length DECIMAL(5,2) CHECK (track_length > 0), -- in KM
    max_participants INT CHECK (max_participants > 0)
);

-- 🚗 Race_Participant (M:N Relationship - Drivers Participating in Races)
CREATE TABLE Race_Participant (
    race_id INT,
    driver_id INT,
    car_id INT,
    PRIMARY KEY (race_id, driver_id, car_id),
    FOREIGN KEY (race_id) REFERENCES Race(race_id) ON DELETE CASCADE,
    FOREIGN KEY (driver_id) REFERENCES Driver(driver_id) ON DELETE CASCADE,
    FOREIGN KEY (car_id) REFERENCES Car(car_id) ON DELETE CASCADE
);

-- 🏆 Race_Result (Tracks Finishing Order and Time)
CREATE TABLE Race_Result (
    race_id INT,
    driver_id INT,
    finishing_position INT CHECK (finishing_position > 0),
    completion_time DECIMAL(6,2) CHECK (completion_time > 0), -- in seconds
    PRIMARY KEY (race_id, driver_id),
    FOREIGN KEY (race_id) REFERENCES Race(race_id) ON DELETE CASCADE,
    FOREIGN KEY (driver_id) REFERENCES Driver(driver_id) ON DELETE CASCADE
);

-- 🎖️ Driver_Reward (M:N Relationship - Drivers Can Win Multiple Rewards)
CREATE TABLE Driver_Reward (
    driver_id INT,
    reward_name VARCHAR(50),
    reward_amount DECIMAL(10,2) CHECK (reward_amount >= 0),
    reward_date DATE DEFAULT GETDATE(),
    PRIMARY KEY (driver_id, reward_name, reward_date),
    FOREIGN KEY (driver_id) REFERENCES Driver(driver_id) ON DELETE CASCADE
);
GO
-- 🚗 Insert Drivers
INSERT INTO Driver (first_name, last_name, country, date_of_birth, license_number)
VALUES 
('Dominic', 'Toretto', 'USA', '1999-08-29', 'DOM12345'),
('Brian', 'O’Conner', 'USA', '1998-07-14', 'BRIAN5678');
GO
-- 🚘 Insert Cars
INSERT INTO Car (model, brand, horsepower, top_speed, year_manufactured, price)
VALUES 
('Charger R/T', 'Dodge', 900, 320, 1990, 75000.00),
('Supra MK4', 'Toyota', 800, 290, 1995, 60000.00);
GO
-- 🚦 Assign Cars to Drivers
INSERT INTO Driver_Car (driver_id, car_id)
VALUES 
(1, 1), -- Dominic owns Charger
(2, 2); -- Brian owns Supra
GO
-- ⚙️ Insert Upgrades
INSERT INTO Upgrade (upgrade_name, upgrade_type, performance_boost, price)
VALUES 
('Twin Turbo Kit', 'Engine', 150, 10000),
('Nitrous System', 'Nitrous', 100, 5000);
GO
-- 🛠️ Assign Upgrades to Cars
INSERT INTO Car_Upgrade (car_id, upgrade_id)
VALUES 
(1, 1), -- Charger gets Twin Turbo
(2, 2); -- Supra gets Nitrous
GO
-- 🏁 Insert Races
INSERT INTO Race (race_name, location, race_date, track_length, max_participants)
VALUES 
('Underground Madness', 'Los Angeles', '2025-03-10 20:00:00', 5.5, 6);
GO
-- 🚗 Register Participants in Race
INSERT INTO Race_Participant (race_id, driver_id, car_id)
VALUES 
(1, 1, 1), -- Dominic enters Charger
(1, 2, 2); -- Brian enters Supra
GO
-- 🏆 Record Race Results
INSERT INTO Race_Result (race_id, driver_id, finishing_position, completion_time)
VALUES 
(1, 2, 1, 180.50), -- Brian finishes first
(1, 1, 2, 182.75); -- Dominic finishes second
GO
-- 🎖️ Reward Winners
INSERT INTO Driver_Reward (driver_id, reward_name, reward_amount)
VALUES 
(2, 'Fastest Lap', 10000), -- Brian gets reward
(1, 'Runner-Up', 5000); -- Dominic gets reward
GO


--- Question 01 --> Writing down all the relevant Queries For the table 

-- 1. Listing all the drivers and their cars 
-- Since there is a many to many relationship between drivers and cars we are going to be using another class called as driver class. 
-- and this helps me to set up the connection between the two tables and I draw up the connection between these two applications itself. 

SELECT 
    Driver.first_name, 
    Driver.last_name, 
    Car.brand, 
    Car.model 
FROM Driver 
INNER JOIN Driver_Car ON Driver.driver_id = Driver_Car.driver_id 
INNER JOIN Car ON Driver_Car.car_id = Car.car_id 

--2. Show all race names and the number of participants 
SELECT 
    R.race_name, 
    COUNT(RP.driver_id) AS Actual_Participants, 
    R.max_participants AS Track_Capacity 
FROM Race R 
INNER JOIN Race_Participant RP ON R.race_id = RP.race_id 
GROUP BY R.race_name, R.max_participants


-- 3. Displaying the fastest driver in each race 
SELECT 
    R.race_name, 
    D.first_name, 
    D.last_name, 
    RR.completion_time 
FROM Race_Result RR 
INNER JOIN Driver D ON RR.driver_id = D.driver_id 
INNER JOIN Race R ON R.race_id = RR.race_id 
WHERE RR.completion_time = ( 
    SELECT Min(completion_time) 
    FROM Race_Result 
    WHERE race_id = RR.race_id
    ) 

-- 4 . Find the total prize money won by each driver 
-- For this we are going to be joining the driver and the driver reward and using the aggregate function 
SELECT 
    D.first_name, 
    D.last_name, 
    SUM(DR.reward_amount) AS total_prize_money 
FROM Driver D 
INNER JOIN Driver_Reward DR ON D.driver_id = DR.driver_id
GROUP BY D.first_name, D.last_name 


-- 5. Listing all the upgrades installed on each car 
-- In order to solve this query we are going to be 
SELECT 
    C.car_id, 
    C.model, 
    C.brand, 
    u.upgrade_id, 
    U.upgrade_type, 
    CU.install_date
FROM Car C 
INNER JOIN Car_Upgrade CU ON C.car_id = CU.car_id
INNER JOIN Upgrade U ON CU.upgrade_id = U.upgrade_id 


--6. Finding the drivers who have participated in at least 2 races. 
SELECT 
D.driver_id,
D.first_name, 
D.last_name 
FROM Driver D 
INNER JOIN Race_Participant RP ON D.driver_id = RP.driver_id 
INNER JOIN Race R ON RP.race_id = Rp.race_id 
GROUP BY D.driver_id, D.first_name, D.last_name 
HAVING COUNT(R.race_id) >=2 


-- 7. Display the average completion time for each race 
SELECT 
race_id,  
AVG(completion_time) AS Avg_completion_time 
FROM Race_Result RR 
GROUP BY race_id

--8. Find the driver who owns the the most expensive car 
SELECT 
D.driver_id, D.first_name, D.last_name, 
MAX(C.Price) AS maximum_money 
FROM Driver D 
INNER JOIN Driver_Car DC ON DC.driver_id = D.driver_id 
INNER JOIN Car C ON DC.car_id = C.car_id 
GROUP BY D.driver_id, d.first_name, D.last_name 


--9. Show the ranking of drivers based on total prize money won 
SELECT 
    D.driver_id, 
    D.first_name, 
    D.last_name, 
    DR.reward_amount
FROM Driver D 
INNER JOIN  Driver_Reward DR ON DR.driver_id = d.driver_id 
ORDER BY reward_amount ASC 


--10. List all the drivers who own at least two different car brands. 
SELECT 
    D.driver_id, 
    D.first_name, 
    D.last_name
FROM Driver D 
INNER JOIN Driver_Car DC ON DC.driver_id = D.driver_id
INNER JOIN Car C ON C.car_id = DC.car_id 
GROUP BY D.driver_id, D.first_name, D.last_name
HAVING COUNT(DISTINCT(C.brand)) >= 2 

--11. Find the drivers who have participated in every race 
SELECT D.first_name, D.last_name 
FROM Driver D 
JOIN Race_Participant RP on D.driver_id = RP.driver_id 
GROUP BY D.driver_id, D.first_name, D.last_name
HAVING COUNT(DISTINCT RP.race_id) = ( SELECT COUNT(*) FROM Race) 


--12. Find the top 3 drivers with the fastest average race completion time 
SELECT TOP 3 
    D.first_name, 
    D.last_name, 
    AVG(RR.completion_time) AS avg_time
FROM Driver D 
JOIN Race_Result RR ON D.driver_id = RR.driver_id 
GROUP BY D.driver_id, D.first_name, D.last_name 
ORDER BY avg_time ASC 

--13. Display drivers who own cars with at least 2 different upgrades. 
SELECT 
    D.first_name, 
    D.last_name
FROM Driver D 
INNER JOIN Driver_Car DC ON DC.driver_id = D.driver_id 
INNER JOIN Car_Upgrade CU ON DC.car_id = CU.car_id 
GROUP BY D.driver_id, D.first_name, D.last_name 
HAVING COUNT (DISTINCT CU.upgrade_id) >= 2 


