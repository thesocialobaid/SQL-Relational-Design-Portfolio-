-- Create Database
CREATE DATABASE PowerPuffDB;
GO
USE PowerPuffDB;
GO

-- Table: Creature
CREATE TABLE Creature (
    CreatureID INT IDENTITY(1,1) PRIMARY KEY,
    Name VARCHAR(100) NOT NULL,
    Type VARCHAR(10) CHECK (Type IN ('Hero', 'Villain')) NOT NULL,
    SpecificPowerID INT, -- A creature has one specific power
    Status VARCHAR(10) CHECK (Status IN ('Alive', 'Dead')) NOT NULL DEFAULT 'Alive'
);
GO

-- Table: Ingredient
CREATE TABLE Ingredient (
    IngredientID INT IDENTITY(1,1) PRIMARY KEY,
    Name VARCHAR(100) NOT NULL,
    Description TEXT
);
GO

-- Table: Creature_Ingredient (4NF - Resolving multi-valued dependency)
CREATE TABLE Creature_Ingredient (
    CreatureID INT,
    IngredientID INT,
    PRIMARY KEY (CreatureID, IngredientID),
    FOREIGN KEY (CreatureID) REFERENCES Creature(CreatureID) ON DELETE CASCADE,
    FOREIGN KEY (IngredientID) REFERENCES Ingredient(IngredientID) ON DELETE CASCADE
);
GO

-- Table: Power
CREATE TABLE Power (
    PowerID INT IDENTITY(1,1) PRIMARY KEY,
    Name VARCHAR(100) NOT NULL,
    Description TEXT
);
GO

-- Table: Creature_Power (A creature can have multiple powers)
CREATE TABLE Creature_Power (
    CreatureID INT,
    PowerID INT,
    PRIMARY KEY (CreatureID, PowerID),
    FOREIGN KEY (CreatureID) REFERENCES Creature(CreatureID) ON DELETE CASCADE,
    FOREIGN KEY (PowerID) REFERENCES Power(PowerID) ON DELETE CASCADE
);
GO

-- Table: FamilyRelation (4NF - Resolving multi-valued dependency)
CREATE TABLE FamilyRelation (
    RelationID INT IDENTITY(1,1) PRIMARY KEY,
    Creature1ID INT,
    Creature2ID INT,
    RelationType VARCHAR(20) CHECK (RelationType IN ('Sibling', 'Parent-Child', 'Cousin', 'Other')),
    FOREIGN KEY (Creature1ID) REFERENCES Creature(CreatureID) ON DELETE NO ACTION,
    FOREIGN KEY (Creature2ID) REFERENCES Creature(CreatureID) ON DELETE NO ACTION
);
GO

-- Table: Fight (Tracking battles)
CREATE TABLE Fight (
    FightID INT IDENTITY(1,1) PRIMARY KEY,
    Creature1ID INT,
    Creature2ID INT,
    WinnerID INT NULL,
    Date DATETIME DEFAULT GETDATE(),
    FOREIGN KEY (Creature1ID) REFERENCES Creature(CreatureID) ON DELETE NO ACTION,
    FOREIGN KEY (Creature2ID) REFERENCES Creature(CreatureID) ON DELETE NO ACTION,
    FOREIGN KEY (WinnerID) REFERENCES Creature(CreatureID) ON DELETE SET NULL
);
GO

-- Table: DeathLog (Tracking creature deaths)
CREATE TABLE DeathLog (
    DeathID INT IDENTITY(1,1) PRIMARY KEY,
    CreatureID INT,
    DeathDate DATETIME DEFAULT GETDATE(),
    Cause TEXT,
    FOREIGN KEY (CreatureID) REFERENCES Creature(CreatureID) ON DELETE CASCADE
);
GO

-- Table: Rank (Tracking ranks of creatures)
CREATE TABLE Rank (
    RankID INT IDENTITY(1,1) PRIMARY KEY,
    CreatureID INT,
    Level INT CHECK (Level >= 1),
    FOREIGN KEY (CreatureID) REFERENCES Creature(CreatureID) ON DELETE CASCADE
);
GO

-- Insert Ingredients
INSERT INTO Ingredient (Name, Description) VALUES
('Sugar', 'Sweetness essence'),
('Spice', 'Adds courage'),
('Everything Nice', 'Perfect balance'),
('Chemical X', 'Superpower catalyst');
GO

-- Insert Powers
INSERT INTO Power (Name, Description) VALUES
('Super Strength', 'Can lift heavy objects'),
('Flight', 'Ability to fly'),
('Laser Eyes', 'Shoots energy beams'),
('Invisibility', 'Can disappear at will');
GO

-- Insert Creatures
INSERT INTO Creature (Name, Type, SpecificPowerID, Status) VALUES
('Blossom', 'Hero', 1, 'Alive'),
('Bubbles', 'Hero', 2, 'Alive'),
('Buttercup', 'Hero', 3, 'Alive'),
('Mojo Jojo', 'Villain', 4, 'Alive'),
('Him', 'Villain', 3, 'Alive'),
('Fuzzy Lumpkins', 'Villain', 1, 'Alive');
GO

-- Assign Ingredients to Creatures
INSERT INTO Creature_Ingredient (CreatureID, IngredientID) VALUES
(1,1), (1,2), (1,3), (1,4),
(2,1), (2,3), (2,4),
(3,2), (3,3), (3,4),
(4,4),
(5,4),
(6,4);
GO

-- Assign Additional Powers to Creatures
INSERT INTO Creature_Power (CreatureID, PowerID) VALUES
(1,2), (1,3),
(2,3), (2,4),
(3,1), (3,4),
(4,1), (4,3),
(5,2), (5,3),
(6,1), (6,2);
GO

-- Define Family Relations
INSERT INTO FamilyRelation (Creature1ID, Creature2ID, RelationType) VALUES
(1,2,'Sibling'),
(1,3,'Sibling'),
(2,3,'Sibling');
GO

-- Log a Fight
INSERT INTO Fight (Creature1ID, Creature2ID, WinnerID) VALUES
(1,4,1),
(2,5,2),
(3,6,3);
GO

-- Log a Death
INSERT INTO DeathLog (CreatureID, Cause) VALUES
(4, 'Defeated by Blossom'),
(5, 'Defeated by Bubbles');
GO

-- Assign Ranks
INSERT INTO Rank (CreatureID, Level) VALUES
(1,10),
(2,9),
(3,8);
GO

-- Question 2 - Implementation of all the queries 

-- 1. Finding the name of the strongest creature (highest rank) 
SELECT TOP 1 
    C.CreatureID, 
    C.Name, 
    C.Type
FROM Creature C 
INNER JOIN Rank R ON R.CreatureID = C.CreatureID 
GROUP BY C.CreatureID, C.Name, C.Type 


-- 2. Getting the most frequent used ingredient 
SELECT 
    I.Name, 
    COUNT(CI.IngredientID) AS Usage_Count 
FROM Ingredient I 
JOIN Creature_Ingredient CI ON I.IngredientID = CI.IngredientID 
GROUP BY I.IngredientID, I.Name 
ORDER BY Usage_Count DESC 


--3. Retrive the creature that fought the most battles 
-- Combine the columns using UNION ALL to put both the columns in a single list of IDs, count their occurence and join for the name 
SELECT TOP 1 
    C.Name, 
    CountTable.Total_Battles
FROM Creature C
JOIN (
    SELECT CreatureID, COUNT(*) AS Total_Battles
    FROM (
        SELECT Creature1ID AS CreatureID FROM Fight
        UNION ALL
        SELECT Creature2ID AS CreatureID FROM Fight
    ) AS CombinedFights
    GROUP BY CreatureID
) AS CountTable ON C.CreatureID = CountTable.CreatureID
ORDER BY Total_Battles DESC;


--4. Find the creatures with only one power 
SELECT 
    C.CreatureID, 
    C.Name, 
    C.Type 
FROM Creature C 
INNER JOIN Creature_Power CP ON CP.CreatureID = C.CreatureID 
GROUP BY C.CreatureID, c.Name, c.Type 
HAVING COUNT(CP.PowerID) =1; 

--5. Retrieve creatures that have never lost fight 
-- Join the tables for the creature and the fight, and furthermore find for all the values where the value for the winner id is not null 
--Using a LEFT JOIN with a NULL check. 
-- If a creature participated in a fight but their ID is not the WinnerID, they lost 
-- We want creatures who have never been the one who didn't win. 

SELECT C.Name 
FROM Creature C 
WHERE NOT EXISTS ( 
    SELECT 1 
    FROM FIGHT F 
    WHERE (C.CreatureID = F.Creature1ID OR C.CreatureID = F.Creature2ID) 
    AND C.CreatureID <> F.WinnerID
    ) 

--6. Get the youngest siblining (highest Crreature Id) 
SELECT TOP 1 
    C.CreatureID, 
    C.Name 
FROM Creature C 
JOIN( 
    SELECT Creature1ID AS CreatureID FROM FamilyRelation WHERE RelationType = 'Sibling' 
    UNION ALL 
    SELECT Creature2ID AS CreatureID FROM FamilyRelation WHERE RelationType = 'Sibling'
    ) AS SiblingList ON C.CreatureID = SiblingList.CreatureID 
ORDER BY C.CreatureID DESC 

--7. Find the creature with most powers 
SELECT TOP 1 
    C.Name, 
    COUNT(CP.PowerID) AS Power_Count 
FROM Creature C 
JOIN Creature_Power CP ON C.CreatureID = CP.CreatureID 
GROUP BY C.CreatureID, C.Name 
ORDER BY Power_Count DESC 

--8. Get creatures that fought at least twice 
SELECT 
    C.Name, 
    Participation.BattleCount 
FROM Creature C 
JOIN ( 
    -- This inner part creates the 'stack' and counts them 
    SELECT 
        CreatureID, 
        COUNT(*) AS BattleCount 
    FROM ( 
        SELECT Creature1ID AS CreatureID FROM Fight 
        UNION ALL 
        SELECT Creature2ID AS CreatureID FROM Fight
    ) AS AllParticipants 
    GROUP BY CreatureID 
    HAVING COUNT(*) >= 2 -- This filters for 'at least twice' 
    ) AS Participation ON C.CreatureID = Participation.CreatureID 
    
--9. Find creatures that died and had a rank 
--For this we need to do an inner join on the creatureid, death and the rank. 
-- The deathlog must include the values for which the death date is not null and and same case for the rank but with the rank id 
SELECT 
    C.Name, 
    D.DeathDate, 
    D.Cause, 
    R.Level AS Rank_Level
FROM Creature C
INNER JOIN DeathLog D ON C.CreatureID = D.CreatureID
INNER JOIN Rank R ON C.CreatureID = R.CreatureID
WHERE D.DeathDate IS NOT NULL 
  AND R.RankID IS NOT NULL;

--10. Find creatures that used 'Chemical X' in their creation 
SELECT 
    C.Name, 
    C.Type, 
    C.Status 
FROM Creature C 
INNER JOIN Creature_Ingredient CI ON CI.CreatureID = C.CreatureID 
INNER JOIN Ingredient I ON I.IngredientID = CI.IngredientID 
WHERE I.Name = 'Chemical X'
GROUP BY C.Name, c.Type, c.Status 

--11. Find the creatures that fought against the most different opponents. 
SELECT TOP 1 
    C.Name, 
    OpponentCounts.Unique_Opponents
FROM Creature C
JOIN (
    -- Step 1: Create a distinct list of every unique matchup
    SELECT CreatureID, COUNT(DISTINCT OpponentID) AS Unique_Opponents
    FROM (
        -- If the creature is listed as Creature1, the opponent is Creature2
        SELECT Creature1ID AS CreatureID, Creature2ID AS OpponentID FROM Fight
        UNION ALL
        -- If the creature is listed as Creature2, the opponent is Creature1
        SELECT Creature2ID AS CreatureID, Creature1ID AS OpponentID FROM Fight
    ) AS Matchups
    GROUP BY CreatureID
) AS OpponentCounts ON C.CreatureID = OpponentCounts.CreatureID
ORDER BY Unique_Opponents DESC;


--12. Find pairs of creatures that are siblings and have fought each other at least once. 
--Establish a relationship between creature, fight and the family relation
-- Ensure that the family relation type is for the sibling and for the fight the fight id count is at least for once. 
SELECT 
    C1.Name AS Sibling1, 
    C2.Name AS Sibling2, 
    COUNT(F.FightID) AS Number_of_Fights
FROM FamilyRelation FR
-- Join the Fight table to see if these two IDs ever fought
JOIN Fight F ON (
    (FR.Creature1ID = F.Creature1ID AND FR.Creature2ID = F.Creature2ID) 
    OR 
    (FR.Creature1ID = F.Creature2ID AND FR.Creature2ID = F.Creature1ID)
)
-- Join Creature twice to get both names
JOIN Creature C1 ON FR.Creature1ID = C1.CreatureID
JOIN Creature C2 ON FR.Creature2ID = C2.CreatureID
-- Filter for siblings
WHERE FR.RelationType = 'Sibling'
GROUP BY C1.Name, C2.Name
HAVING COUNT(F.FightID) >= 1;

--13. List creatures with their powers, ranks, and number of battles, ordered by a combined "strenght score" 
-- Requires you to pull data from four different tables and create a calculated columns for the "strenght score" 
SELECT 
    C.Name,
    R.Level AS Rank_Level,
    COUNT(DISTINCT CP.PowerID) AS Power_Count,
    ISNULL(Participation.Total_Battles, 0) AS Battle_Count,
    -- Combined Strength Score Calculation
    (R.Level + COUNT(DISTINCT CP.PowerID) + ISNULL(Participation.Total_Battles, 0)) AS Strength_Score
FROM Creature C
LEFT JOIN Rank R ON C.CreatureID = R.CreatureID
LEFT JOIN Creature_Power CP ON C.CreatureID = CP.CreatureID
LEFT JOIN (
    -- Subquery to get total battles (treating as both C1 and C2)
    SELECT CreatureID, COUNT(*) AS Total_Battles
    FROM (
        SELECT Creature1ID AS CreatureID FROM Fight
        UNION ALL
        SELECT Creature2ID AS CreatureID FROM Fight
    ) AS AllFights
    GROUP BY CreatureID
) AS Participation ON C.CreatureID = Participation.CreatureID
GROUP BY C.CreatureID, C.Name, R.Level, Participation.Total_Battles
ORDER BY Strength_Score DESC;


