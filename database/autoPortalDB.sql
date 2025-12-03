-- Tworzenie bazy danych
CREATE DATABASE AutoPortalDB;
GO
USE AutoPortalDB;
GO

-- Tabela uzytkownikow
CREATE TABLE Users (
    UserID INT PRIMARY KEY IDENTITY,
    FirstName NVARCHAR(50),
    LastName NVARCHAR(50),
    Email NVARCHAR(100) UNIQUE,
    Phone NVARCHAR(20),
    UserType NVARCHAR(20),
    PasswordHash NVARCHAR(255)
);
GO

-- Tabela lokalizacji
CREATE TABLE Locations (
    LocationID INT PRIMARY KEY IDENTITY,
    City NVARCHAR(100),
    Region NVARCHAR(100),
    PostalCode NVARCHAR(10)
);
GO

-- Tabela samochodow
CREATE TABLE Cars (
    CarID INT PRIMARY KEY IDENTITY,
    Make NVARCHAR(50),
    Model NVARCHAR(50),
    Year INT,
    FuelType NVARCHAR(30),
    Transmission NVARCHAR(30),
    Mileage INT,
    Price DECIMAL(10,2)
);
GO

-- Tabela ogloszen
CREATE TABLE Listings (
    ListingID INT PRIMARY KEY IDENTITY,
    Title NVARCHAR(100),
    Description NVARCHAR(MAX),
    DatePosted DATE,
    Status NVARCHAR(20),
    CarID INT FOREIGN KEY REFERENCES Cars(CarID),
    UserID INT FOREIGN KEY REFERENCES Users(UserID),
    LocationID INT FOREIGN KEY REFERENCES Locations(LocationID)
);
GO

-- Tabela zdjec
CREATE TABLE Photos (
    PhotoID INT PRIMARY KEY IDENTITY,
    ListingID INT FOREIGN KEY REFERENCES Listings(ListingID),
    PhotoURL NVARCHAR(255)
);
GO

-- Tabela zapytan od kupujacych
CREATE TABLE Inquiries (
    InquiryID INT PRIMARY KEY IDENTITY,
    ListingID INT FOREIGN KEY REFERENCES Listings(ListingID),
    Name NVARCHAR(100),
    Email NVARCHAR(100),
    Message NVARCHAR(MAX),
    InquiryDate DATE
);
GO

-- Przykladowe dane
INSERT INTO Users (FirstName, LastName, Email, Phone, UserType, PasswordHash) VALUES
('Jan', 'Kowalski', 'jan@example.com', '123456789', 'Private', 'hash123'),
('Anna', 'Nowak', 'anna@example.com', '987654321', 'Business', 'hash456'),
('Piotr', 'Zielinski', 'piotr@example.com', '555444333', 'Private', 'hash789');

INSERT INTO Locations (City, Region, PostalCode) VALUES
('Warsaw', 'Mazowieckie', '00-001'),
('Krakow', 'Malopolskie', '30-002'),
('Gdansk', 'Pomorskie', '80-003');

INSERT INTO Cars (Make, Model, Year, FuelType, Transmission, Mileage, Price) VALUES
('Toyota', 'Yaris', 2020, 'Petrol', 'Manual', 35000, 42000),
('Ford', 'Focus', 2018, 'Diesel', 'Automatic', 78000, 36000),
('BMW', '320i', 2019, 'Petrol', 'Automatic', 42000, 89000),
('Skoda', 'Octavia', 2021, 'Diesel', 'Manual', 27000, 75000);

INSERT INTO Listings (Title, Description, DatePosted, Status, CarID, UserID, LocationID) VALUES
('Toyota Yaris for sale', 'Great condition, one owner', GETDATE(), 'Active', 1, 1, 1),
('Ford Focus 2018', 'Diesel, very economic, low mileage', GETDATE(), 'Active', 2, 2, 2),
('BMW 320i Sport', 'Fast and reliable, automatic gearbox', GETDATE(), 'Active', 3, 1, 3),
('Skoda Octavia combi', 'Family car, low mileage', GETDATE(), 'Inactive', 4, 3, 2);

INSERT INTO Photos (ListingID, PhotoURL) VALUES
(1, 'photos/yaris1.jpg'),
(1, 'photos/yaris2.jpg'),
(2, 'photos/focus1.jpg'),
(3, 'photos/bmw1.jpg'),
(3, 'photos/bmw2.jpg');

INSERT INTO Inquiries (ListingID, Name, Email, Message, InquiryDate) VALUES
(1, 'Tomasz Wojcik', 'tomek@example.com', 'Is the car still available?', GETDATE()),
(2, 'Karolina Maj', 'karolina@example.com', 'Can I test drive the car?', GETDATE()),
(3, 'Marek Lis', 'marek@example.com', 'Can you send more photos?', GETDATE());
GO

-- Indeksy
CREATE INDEX IDX_Cars_Make_Model ON Cars (Make, Model);
CREATE INDEX IDX_Cars_Price ON Cars (Price);
GO

-- Widok aktywnych ogloszen (poprawiony: Price z Cars)
CREATE VIEW ActiveListingsView AS
SELECT L.ListingID, C.Make, C.Model, C.Price, U.FirstName, U.LastName, Loc.City
FROM Listings L
JOIN Cars C ON L.CarID = C.CarID
JOIN Users U ON L.UserID = U.UserID
JOIN Locations Loc ON L.LocationID = Loc.LocationID
WHERE L.Status = 'Active';
GO

-- Zapytanie agregujace
SELECT UserID, COUNT(*) AS TotalListings
FROM Listings
GROUP BY UserID;
GO

-- Podzapytanie
SELECT FirstName, LastName
FROM Users
WHERE UserID IN (
    SELECT DISTINCT UserID FROM Listings
);
GO

-- Transakcja z obsluga bledow
BEGIN TRANSACTION;
BEGIN TRY
    INSERT INTO Cars (Make, Model, Year, FuelType, Transmission, Mileage, Price)
    VALUES ('Audi', 'A4', 2020, 'Petrol', 'Automatic', 21000, 99000);
    
    DECLARE @CarID INT = SCOPE_IDENTITY();
    INSERT INTO Listings (Title, Description, DatePosted, Status, CarID, UserID, LocationID)
    VALUES ('Audi A4 2020', 'Luxury car with full service history', GETDATE(), 'Active', @CarID, 2, 1);

    COMMIT;
END TRY
BEGIN CATCH
    ROLLBACK;
    PRINT ERROR_MESSAGE();
END CATCH;
GO

-- Uzytkownik i uprawnienia
CREATE LOGIN normal_user WITH PASSWORD = 'Haslo123!';
CREATE USER normal_user FOR LOGIN normal_user;
GRANT SELECT ON Listings TO normal_user;
GRANT INSERT, UPDATE ON Inquiries TO normal_user;
REVOKE UPDATE ON Users FROM normal_user;
GO

-- LEFT JOIN: ogloszenia nawet bez zdjec
SELECT L.Title, C.Make, C.Model, P.PhotoURL
FROM Listings L
JOIN Cars C ON L.CarID = C.CarID
LEFT JOIN Photos P ON L.ListingID = P.ListingID;
GO

-- Liczba zdjec dla kazdego ogloszenia
SELECT L.Title,
       (SELECT COUNT(*) FROM Photos P WHERE P.ListingID = L.ListingID) AS PhotoCount
FROM Listings L;
GO

-- EXISTS: samochody powiazane z ogloszeniami
SELECT * FROM Cars C
WHERE EXISTS (
    SELECT 1 FROM Listings L WHERE L.CarID = C.CarID
);
GO

-- AVG i GROUP BY: srednia cena wg rodzaju paliwa
SELECT FuelType, AVG(Price) AS AveragePrice
FROM Cars
GROUP BY FuelType;
GO

-- HAVING: uzytkownicy z wiecej niz 1 ogloszeniem
SELECT UserID, COUNT(*) AS ListingCount
FROM Listings
GROUP BY UserID
HAVING COUNT(*) > 1;
GO

-- CASE: kategorie cenowe
SELECT L.Title, C.Price,
       CASE
           WHEN C.Price < 40000 THEN 'Cheap'
           WHEN C.Price BETWEEN 40000 AND 80000 THEN 'Average'
           ELSE 'Expensive'
       END AS PriceCategory
FROM Listings L
JOIN Cars C ON L.CarID = C.CarID;
GO

-- LIKE + BETWEEN + ORDER BY
SELECT L.Title, C.Make, C.Model, C.Price
FROM Listings L
JOIN Cars C ON L.CarID = C.CarID
WHERE C.Model LIKE '%a%' AND C.Price BETWEEN 30000 AND 90000
ORDER BY C.Price DESC;
GO

---------TESTOWANIE CZY WSZYSTKO JEST OK!

-- Sprawdzanie czy s¹ dane w uzytkownikach
SELECT * FROM Users;

-- Sprawdzanie ogloszenia i ich powiazania
SELECT * FROM Listings;

-- Sprawdzanie widok aktywnych og³oszen
SELECT * FROM ActiveListingsView;

-- Sprawdzanie liczby zdjec na og³oszenie
SELECT L.ListingID, L.Title, COUNT(P.PhotoID) AS PhotoCount
FROM Listings L
LEFT JOIN Photos P ON L.ListingID = P.ListingID
GROUP BY L.ListingID, L.Title;
