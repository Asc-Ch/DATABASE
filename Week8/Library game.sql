-- Board Game Library System
-- This is a simple database for managing a board game rental service

-- 1. Creating the Database

DROP DATABASE IF EXISTS BoardGameLibrary;
CREATE DATABASE BoardGameLibrary;
USE BoardGameLibrary;
SELECT DATABASE();


-- 2. Creating the Tables with Constraints

-- a) Table: Members (People who can borrow games)
CREATE TABLE Members (
    member_id INT AUTO_INCREMENT PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL, -- Ensures no duplicate emails
    phone VARCHAR(20),
    join_date DATE NOT NULL DEFAULT (CURRENT_DATE)
);

-- b) Table: Publishers (Companies that publish the games)
CREATE TABLE Publishers (
    publisher_id INT AUTO_INCREMENT PRIMARY KEY,
    publisher_name VARCHAR(100) UNIQUE NOT NULL -- Ensures publisher names are unique
);

-- c) Table: Games (The board games in the library's collection)
CREATE TABLE Games (
    game_id INT AUTO_INCREMENT PRIMARY KEY,
    title VARCHAR(100) NOT NULL,
    min_players INT NOT NULL CHECK (min_players > 0), 
    max_players INT NOT NULL,
    playtime_minutes INT, -- Average playtime
    publisher_id INT NOT NULL,
    -- A Publisher can have MANY Games.
    FOREIGN KEY (publisher_id)
        REFERENCES Publishers (publisher_id)
        ON DELETE RESTRICT -- Prevents deleting a publisher if games by them exist
);

-- d) Table: Copies (Physical copies of a game. The library might have multiple copies of a popular game.)
CREATE TABLE Copies (
    copy_id INT AUTO_INCREMENT PRIMARY KEY,
    game_id INT NOT NULL,
    purchase_date DATE,
    copy_condition ENUM('New', 'Excellent', 'Good', 'Worn', 'Retired') DEFAULT 'Good',
    -- A Game can have MANY Copies.
    FOREIGN KEY (game_id)
        REFERENCES Games (game_id)
        ON DELETE CASCADE -- If a game is deleted, all its copies are also deleted
);

-- e) Table: Loans (Tracks the borrowing of a specific game copy by a member)
CREATE TABLE Loans (
    loan_id INT AUTO_INCREMENT PRIMARY KEY,
    copy_id INT NOT NULL,
    member_id INT NOT NULL,
    borrow_date DATE NOT NULL DEFAULT (CURRENT_DATE),
    due_date DATE NOT NULL,
    return_date DATE NULL, -- NULL means the game is still checked out
    -- A Copy can have MANY Loans over its lifetime.
    FOREIGN KEY (copy_id)
        REFERENCES Copies (copy_id),
    -- A Member can have MANY Loans (current and historical).
    FOREIGN KEY (member_id)
        REFERENCES Members (member_id)
);


-- 3. Insert some sample data to test the relationships
-- Insert Publishers
INSERT INTO Publishers (publisher_name) VALUES
('Stonemaier Games'),
('Czech Games Edition'),
('Days of Wonder'),
('Repos Production');

-- Insert Games
INSERT INTO Games (title, min_players, max_players, playtime_minutes, publisher_id) VALUES
('Monopoly', 2, 8, 90, 1),
('Catan', 3, 6, 90, 2),
('Ticket to Ride', 2, 5, 45, 3),
('Clue', 3, 6, 60, 4);

-- Insert Members
INSERT INTO Members (first_name, last_name, email, phone) VALUES
('Alice', 'Wanjala', 'alice.wanjala@email.com', '0745879632'),
('Jonte', 'Fresh', 'fresh.jones@email.com', '0721548796');

-- Insert Copies
INSERT INTO Copies (game_id, purchase_date, copy_condition) VALUES
(1, '2025-09-15', 'Excellent'),
(1, '2025-05-20', 'Good'), -- A second copy of Wingspan
(2, '2021-11-30', 'Worn'),
(3, '2025-03-10', 'New');

-- Insert a active Loan and a returned Loan
INSERT INTO Loans (copy_id, member_id, borrow_date, due_date, return_date) VALUES
(1, 1, '2025-9-20', '2025-11-03', NULL), 
(3, 2, '2025-8-15', '2025-9-29', '2025-9-28'); 

-- SOME TEST QUESRIES

-- a) List all members
SELECT * FROM Members;

-- b) List all games with publisher names
SELECT g.title, g.min_players, g.max_players, p.publisher_name
FROM Games g
JOIN Publishers p ON g.publisher_id = p.publisher_id;

-- c) List all copies and their conditions
SELECT c.copy_id, g.title, c.copy_condition, c.purchase_date
FROM Copies c
JOIN Games g ON c.game_id = g.game_id;

-- d) List all active loans (not yet returned)
SELECT l.loan_id, m.first_name, m.last_name, g.title, l.borrow_date, l.due_date
FROM Loans l
JOIN Members m ON l.member_id = m.member_id
JOIN Copies c ON l.copy_id = c.copy_id
JOIN Games g ON c.game_id = g.game_id
WHERE l.return_date IS NULL;

-- e) List all overdue loans (due_date before today and not returned)
SELECT l.loan_id, m.first_name, m.last_name, g.title, l.due_date
FROM Loans l
JOIN Members m ON l.member_id = m.member_id
JOIN Copies c ON l.copy_id = c.copy_id
JOIN Games g ON c.game_id = g.game_id
WHERE l.return_date IS NULL
  AND l.due_date < CURRENT_DATE;

-- f) Show history of loans for each member
SELECT m.first_name, m.last_name, g.title, l.borrow_date, l.return_date
FROM Loans l
JOIN Members m ON l.member_id = m.member_id
JOIN Copies c ON l.copy_id = c.copy_id
JOIN Games g ON c.game_id = g.game_id
ORDER BY m.member_id, l.borrow_date DESC;

