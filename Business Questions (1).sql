USE Midterm_Project;



-- Business Question 1
DROP VIEW IF EXISTS UMemberInfo;
GO
CREATE VIEW UMemberInfo AS
	SELECT S.StudentID,
		   CONCAT(FirstName, ' ', LastName) AS FullName,
		   StudentID
	FROM Studnet AS S
	LEFT OUTER JOIN UMember AS UM ON UM.StudentID = S.StudentID

GO 
SELECT * FROM UmemberInfo;


-- Business Question 2
SELECT R.ISBN,
	   Title,
	   S.StudentID,
	   CONCAT(FirstName,' ', LastName) AS FullName
	   FROM Book AS B
	   WHERE ReturnDate  = 'Late'

	   


-- Business Question 3
DROP VIEW IF EXISTS PatronBookHoldings;
GO 
CREATE VIEW StudentBookHoldings AS
	SELECT S.StudentID,
		   CONCAT(FirstName, ' ', LastName) AS FullName,
		   B.ISBN,
		   B.Title
		   FROM Patron AS P
		   INNER JOIN CheckOutBook AS CB ON S.StudentID = StudentID
		   INNER JOIN Book AS B ON B.ISBN = B.ISBN
		   WHERE R.ReturnDate IS NULL
		 
GO
SELECT * FROM PatronBookHoldings;




-- Business Question 4
DROP PROCEDURE IF EXISTS AddEmployee;

GO

CREATE PROCEDURE AddEmployee
	@DepartmentID INT,
	@FirstName VARCHAR(40),
	@LastName VARCHAR(40)
AS
BEGIN
	BEGIN TRANSACTION;

	INSERT INTO Employee (DepartmentID, FirstName, LastName)
	VALUES (@DepartmentID, @FirstName, @LastName)

	COMMIT TRANSACTION;

END

GO

EXECUTE AddEmployee @DepartmentID = 4, @FirstName = 'Tony', @LastName = 'Brandon'
SELECT * FROM Employee;

GO

-- Business Question 5
CREATE PROCEDURE GetOpeningWrittingCenter
  -- Parameters
  @OpeningTime TIME
AS
BEGIN
  -- Variable Declarations
  -- Non-transaction logic
  SELECT R.RoomNumber, R.RoomName, R.Location, WC.OpenTime, WC.CloseTime
  FROM Room AS R INNER JOIN WrittingCenter AS WC ON R.RoomAssetID=WC.WrittingCenterID
  WHERE @OpeningTime>=WC.OpenTime AND @OpeningTime<=WC.CloseTime;
  -- START TRANSACTION;
    -- Transaction logic
  -- COMMIT;
END






-- Data Output Queries

SELECT B.ISBN, B.Title, B.Author, R.StartDate, R.EndDate
FROM Book AS B 
LEFT JOIN ReservationDetail AS RD ON B.BookAssetID=RD.BookAssetID
LEFT JOIN Reservation AS R ON RD.ReservationID=R.ReservationID
WHERE B.Title='Don Mariote';

-- 1
SELECT T1.AssetID, T1.AssetTime, T1.ISBN, T1.Author, T1.Price, T1.TypeName, T2.ReservationCount
FROM 
(
SELECT A.AssetID, A.AssetTime, B.ISBN, B.Author, B.Price, BT.TypeName
FROM Book AS B
INNER JOIN BookType AS BT ON B.BookTypeID=BT.BookTypeID
INNER JOIN Asset AS A ON B.BookAssetID=A.AssetID
WHERE B.BookAssetID NOT IN 
(SELECT BookAssetID 
FROM ReservationDetail AS RD INNER JOIN Reservation AS R ON RD.ReservationID=R.ReservationID 
WHERE StartDate<GETDATE() AND EndDate IS NULL)
) AS T1
LEFT JOIN
(
SELECT RD.BookAssetID, COUNT(RD.ReservationID) AS ReservationCount
FROM ReservationDetail AS RD INNER JOIN Reservation AS R ON RD.ReservationID=R.ReservationID 
WHERE StartDate<GETDATE() AND EndDate <GETDATE()
GROUP BY RD.BookAssetID
) AS T2 ON T1.AssetID=T2.BookAssetID
;

-- 2
SELECT A.AssetID, A.AssetTime, B.ISBN, B.Author, B.Price, BT.TypeName, RD.Discount,
R.StartDate, R.EndDate,
CONCAT(COALESCE(U.FirstName, ''), ' ', COALESCE(U.MiddleName, ''), ' ', COALESCE(U.LastName, '')) AS StudentName,
U.DOB,
CONCAT(COALESCE(E.FirstName, ''), ' ', COALESCE(E.MiddleName, ''), ' ', COALESCE(E.LastName, '')) AS EmployeeName,
D.DepartmentName
FROM Student AS S
LEFT JOIN UMember AS U ON S.StudentID=U.UMemberID
LEFT JOIN Reservation AS R ON R.UMemberID=U.UMemberID
LEFT JOIN ReservationDetail AS RD ON R.ReservationID=RD.ReservationID
LEFT JOIN Book AS B ON RD.BookAssetID=B.BookAssetID
LEFT JOIN BookType AS BT ON B.BookTypeID=BT.BookTypeID
LEFT JOIN Asset AS A ON A.AssetID=B.BookAssetID
LEFT JOIN Employee AS E ON R.EmployeeID= E.EmployeeID
LEFT JOIN Department AS D ON E.DepartmentID=D.DepartmentID;

-- 3
SELECT A.AssetID, A.AssetTime, B.ISBN, B.Author, B.Price, BT.TypeName, RD.Discount,
R.StartDate,
CONCAT(COALESCE(U.FirstName, ''), ' ', COALESCE(U.MiddleName, ''), ' ', COALESCE(U.LastName, '')) AS ResearcherName,
Researcher.EmailAddress
FROM Researcher
LEFT JOIN UMember AS U ON Researcher.ResearcherID=U.UMemberID
LEFT JOIN Reservation AS R ON R.UMemberID=U.UMemberID
LEFT JOIN ReservationDetail AS RD ON R.ReservationID=RD.ReservationID
LEFT JOIN Book AS B ON RD.BookAssetID=B.BookAssetID
LEFT JOIN BookType AS BT ON B.BookTypeID=BT.BookTypeID
LEFT JOIN Asset AS A ON A.AssetID=B.BookAssetID;

-- 4
SELECT R.RoomNumber, R.RoomName, R.Location, WC.OpenTime, WC.CloseTime
FROM Room AS R INNER JOIN WrittingCenter AS WC ON R.RoomAssetID=WC.WrittingCenterID;

-- 5
SELECT 'Room' AS AssetType, COUNT(RoomAssetID) AS AssetCount FROM Room
UNION
SELECT 'Equpiment' AS AssetType, COUNT(EqupimentAssetD) AS AssetCount FROM Equipment
UNION
SELECT 'Book' AS AssetType, COUNT(BookAssetID) AS AssetCount FROM Book;
