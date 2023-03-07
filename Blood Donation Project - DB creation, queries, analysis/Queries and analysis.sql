# 1. Ile krwi oddały kobiety, a ile mężczyźni? Łącznie, bez znaczenia grupa i czynnik Rh.
SELECT p.gender, SUM(d.DonationQuantity)
FROM Patients p
	JOIN Donations d
		ON p.ID_Patient = d.ID_Patient
GROUP BY p.gender;

# 2. Ilu dawców to kobiety, a ilu dawców to mężczyźni?
SELECT COUNT(ID_Patient), gender
FROM Patients
GROUP BY gender;

# 3. Ilu dawców ma na nazwisko "Kowalski"?
SELECT COUNT(*), last_name
FROM Patients
WHERE last_name LIKE "Kowalski"
GROUP BY last_name;

# 4. Ilu dawców ma jaką grupę krwi?
SELECT COUNT(*), bt.BloodType
FROM Patients p
	JOIN BloodType bt
		ON p.ID_BloodType = bt.ID_BloodType
GROUP BY bt.BloodType;

#5. Ilu dawców ma jaką grupę krwi oraz czynnik Rh?
SELECT bt.BloodType, rf.RhFactor, COUNT(*)
FROM Patients p
	JOIN BloodType bt
		ON p.ID_BloodType = bt.ID_BloodType
	JOIN RhFactor rf
		ON p.ID_RhFactor = rf.ID_RhFactor
GROUP BY bt.BloodType, rf.RhFactor
ORDER BY bt.BloodType;

#5. Jaki jest udział procentowy osób z daną grupą krwi oraz czynnikiem Rh w ogólnej liczbie osób?
SELECT
	bt.BloodType,
    rf.RhFactor,
    COUNT(*),
    ROUND(count(*) * 100.0 / sum(count(*)) Over(), 2) AS Percentage
FROM Patients p
	JOIN BloodType bt
		ON p.ID_BloodType = bt.ID_BloodType
	JOIN RhFactor rf
		ON p.ID_RhFactor = rf.ID_RhFactor
GROUP BY bt.BloodType, rf.RhFactor
ORDER BY BloodType;

#6. Jaki jest udział procentowy ilości danej grupy krwi oraz danego czynnika Rh w ogólnej liczbie krwi?
SELECT
	bt.BloodType,
    rf.RhFactor,
    SUM(d.DonationQuantity) AS 'Sum of donated quantity',
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (),2) AS Percentage
FROM Patients p
	JOIN Donations d
		ON p.ID_Patient = d.ID_Patient
	JOIN BloodType bt
		ON p.ID_BloodType = bt.ID_BloodType
	JOIN RhFactor rf
		ON p.ID_RhFactor = rf.ID_RhFactor
GROUP BY bt.BloodType, rf.RhFactor
ORDER BY BloodType;

#7. Ile osób jest z którego miasta?
SELECT COUNT(*), address_city
FROM Patients
GROUP BY address_city
ORDER BY COUNT(*) DESC;

#8. Ile pobrań w której placówce i jaka to grupa krwi oraz jaki czynnik Rh oraz jaka płeć?
SELECT
	COUNT(*),
    bt.BloodType,
    rf.RhFactor,
    i.ID_Institution,
    p.gender
FROM Patients p
	JOIN Donations d
		ON p.ID_Patient = d.ID_Patient
	JOIN RhFactor rf
		ON p.ID_RhFactor = rf.ID_RhFactor
	JOIN BloodType bt
		ON p.ID_BloodType = bt.ID_BloodType
	JOIN Institution i
		ON d.ID_Institution = i.ID_Institution
GROUP BY bt.BloodType, rf.RhFactor, i.ID_Institution, p.gender
ORDER BY i.ID_Institution, bt.BloodType, rf.RhFactor;

#9. W którym miesiącu ile krwi i jaka grupa?
SELECT
	MONTH(d.Donation_Date) as Months,
    bt.BloodType,
    rf.RhFactor,
    SUM(d.DonationQuantity),
	GROUPING(bt.BloodType),
	GROUPING(rf.RhFactor)
FROM Patients p
	JOIN Donations d
		ON p.ID_Patient = d.ID_Patient
	JOIN RhFactor rf
		ON p.ID_RhFactor = rf.ID_RhFactor
	JOIN BloodType bt
		ON p.ID_BloodType = bt.ID_BloodType
GROUP BY Months, bt.BloodType, rf.RhFactor WITH ROLLUP;
# z if grouping
SELECT
	MONTH(d.Donation_Date) as Months,
		IF(GROUPING(bt.BloodType),
        'All Blood Types for this Month', bt.BloodType) BloodType,
		IF(GROUPING(rf.RhFactor),
        'All Rh Factors for this BloodType', rf.RhFactor) RhFactor,
        #IF(GROUPING(months), 'all months', months) months,
	SUM(d.DonationQuantity)
FROM Patients p
	JOIN Donations d
		ON p.ID_Patient = d.ID_Patient
	JOIN RhFactor rf
		ON p.ID_RhFactor = rf.ID_RhFactor
	JOIN BloodType bt
		ON p.ID_BloodType = bt.ID_BloodType
GROUP BY Months, bt.BloodType, rf.RhFactor WITH ROLLUP;

# 10. Ile łącznie krwi oddał pacjent o ID 111?
SELECT CONCAT(p.first_name, ' ', p.last_name), SUM(d.DonationQuantity)
FROM Patients p
	JOIN Donations d
		ON p.ID_Patient = d.ID_Patient
WHERE d.ID_Patient = 111;

# 11. Sprawdzenie czy jest pacjent, który nie oddał krwi w ogóle?
SELECT * FROM Patients
WHERE DonatedAmount IS NULL;
#te 2 osoby nie oddały krwi w ogóle

# 12. Przygotuj dowolne zapytanie wykorzystując case when.
SELECT
	ID_Patient, first_name, last_name,
CASE
	WHEN gender = 'M' THEN 'Male'
    WHEN gender = 'F' THEN 'Female'
END
FROM Patients;

# 13. Napisz zapytanie z podzapytaniem
SELECT
	ID_Patient,
    first_name,
    last_name,
    DonatedAmount
FROM Patients
WHERE DonatedAmount > (SELECT AVG(DonatedAmount) FROM Patients);

# 14. Wykorzystaj derived table
# Jednym z przykładów zapytania z wykorzystaniem derived table może być zapytanie wybierające sumę
# wszystkich donacji z Inventory dla każdej grupy krwi:
SELECT bt.BloodType, rf.RhFactor, sum(inv.Quantity) AS TotalQuantity
FROM BloodType bt
CROSS JOIN RhFactor rf
LEFT JOIN (
    SELECT ID_BloodType, ID_RhFactor, Quantity
    FROM Inventory
) AS inv ON bt.ID_BloodType = inv.ID_BloodType AND rf.ID_RhFactor = inv.ID_RhFactor
GROUP BY bt.BloodType, rf.RhFactor
ORDER BY bt.BloodType, rf.RhFactor;

# 15. Wykorzystaj CTE
# Przykładowe zapytanie z wykorzystaniem Common Table Expression (CTE),
# które znajduje najnowszą datę pobrania krwi dla każdego typu krwi i RhFactor w tabeli Donations:
WITH LatestDonations AS (
	SELECT p.ID_BloodType, p.ID_RhFactor, MAX(d.Donation_Date) AS LatestDate
    FROM Donations d
		JOIN Patients p
			ON d.ID_Patient = p.ID_Patient
	GROUP BY p.ID_BloodType, p.ID_RhFactor
    )
    SELECT bt.BloodType, rf.RhFactor, ld.LatestDate
    FROM Patients p
		JOIN BloodType bt
			ON p.ID_BloodType = bt.ID_BloodType
        JOIN RhFactor rf
			ON p.ID_RhFactor = rf.ID_RhFactor
        JOIN LatestDonations ld
			ON ld.ID_BloodType = bt.ID_BloodType AND ld.ID_RhFactor = rf.ID_RhFactor
	GROUP BY bt.BloodType, rf.RhFactor, ld.LatestDate
    ORDER BY bt.BloodType, rf.RhFactor;