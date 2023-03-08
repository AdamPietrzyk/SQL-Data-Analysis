######## DATABASE AND TABLES CREATION SECTION

CREATE DATABASE IF NOT EXISTS Krwiodawstwo;

USE Krwiodawstwo;

CREATE TABLE BloodType (
	ID_BloodType INT AUTO_INCREMENT NOT NULL,
	BloodType ENUM('0', 'A', 'B', 'AB'),
    	PRIMARY KEY(ID_BloodType)
);

CREATE TABLE RhFactor (
	ID_RhFactor INT AUTO_INCREMENT NOT NULL,
    	RhFactor ENUM('+', '-'),
    	PRIMARY KEY(ID_RhFactor)
);

CREATE TABLE Inventory (
    ID_BloodType INT NOT NULL,
    ID_RhFactor INT NOT NULL,
    Quantity INT,
    PRIMARY KEY (ID_BloodType, ID_RhFactor),
    FOREIGN KEY (ID_BloodType) REFERENCES BloodType(ID_BloodType),
    FOREIGN KEY (ID_RhFactor) REFERENCES RhFactor(ID_RhFactor)
);

CREATE TABLE Donator_Level (
	ID_Donator_Level INT NOT NULL AUTO_INCREMENT,
    	Donator_Level ENUM(
	'Brak',
	'Meritorious Honorable Blood Donor 1 st',
	'Meritorious Honorable Blood Donor 2 st',
	'Meritorious Honorable Blood Donor 3 st'),
	PRIMARY KEY (ID_Donator_Level)
    );

CREATE TABLE Patients(
	ID_Patient INT AUTO_INCREMENT NOT NULL,
    	first_name varchar(50),
   	last_name varchar(50),
   	gender ENUM('M', 'F'),
   	phone_number varchar(20),
    	email varchar(50),
	address_street varchar(50),
	address_zipcode varchar(50),
	address_city varchar(50),
    	ID_BloodType INT,
   	ID_RhFactor INT,
   	DonatedAmount INT,
   	ID_Donator_Level INT,
	PRIMARY KEY (ID_Patient),
   	FOREIGN KEY (ID_BloodType) REFERENCES BloodType(ID_BloodType),
	FOREIGN KEY (ID_RhFactor) REFERENCES RhFactor(ID_RhFactor),
   	FOREIGN KEY (ID_Donator_Level) REFERENCES Donator_Level(ID_Donator_Level)
    );
        
CREATE TABLE Staff (
	ID_Staff INT NOT NULL AUTO_INCREMENT,
	first_name varchar(50),
    	last_name varchar(50),
   	phone_number varchar(20),
	email varchar(20),
    	phlebotomist ENUM('Doctor', 'Nurse', 'Paramedic'),
    	PRIMARY KEY (ID_Staff)
);

CREATE TABLE Institution (
	ID_Institution INT NOT NULL AUTO_INCREMENT,
    	i_name varchar(50),
	phone_number varchar(20),
    	email varchar(50),
	address_street varchar(20),
	address_zipcode varchar(20),
	address_city varchar(20),
    	PRIMARY KEY (ID_Institution)
);

CREATE TABLE Donations (
	ID_Donation INT NOT NULL AUTO_INCREMENT,
	Donation_Date DATETIME,
	Next_Possible_Donation DATETIME,
	DonationQuantity INT,
	ID_Patient INT,
	ID_Staff INT,
	ID_Institution INT,
	PRIMARY KEY (ID_Donation),
	FOREIGN KEY (ID_Patient) REFERENCES Patients(ID_Patient),
	FOREIGN KEY (ID_Staff) REFERENCES Staff(ID_Staff),
	FOREIGN KEY (ID_Institution) REFERENCES Institution(ID_Institution)
);



######## TRIGGERS CREATION SECTION


# This trigger automatically calculates the sum value of the amount of blood donated by a given donor.
# The trigger checks all the new records that are INSERTed in Donations table, and then sums quantity of each donor donations.
DELIMITER //
CREATE TRIGGER update_donated_amount
AFTER INSERT ON Donations
FOR EACH ROW
BEGIN
    UPDATE Patients
    SET DonatedAmount = (
        SELECT SUM(DonationQuantity) 
        FROM Donations 
        WHERE Donations.ID_Patient = Patients.ID_Patient
    )
    WHERE Patients.ID_Patient = NEW.ID_Patient;
END; //
DELIMITER ;



# This trigger that automatically changes the status of a donor/patient once he/she reaches a certain level of blood donations sum.
# The trigger includes different value threshold levels for each gender separately. 
# In order to properly assign these statuses, I first used IF statement to determine the gender of the donor.
# Then I used the CASE clause, which checks the current, newest sum of DonatedAmount.
# This sum of DonatedAmount is calculated automatically based on the previus trigger called "update_donated_amount".
# So these two triggers complement each other.
DELIMITER //
CREATE TRIGGER update_donator_level
BEFORE UPDATE ON Patients
FOR EACH ROW
BEGIN
  IF NEW.gender = 'M' THEN
    CASE
      WHEN NEW.DonatedAmount >= 0 AND NEW.DonatedAmount < 6000 THEN
        SET NEW.ID_Donator_Level = 1;
      WHEN NEW.DonatedAmount >= 6000 AND NEW.DonatedAmount < 12000 THEN
        SET NEW.ID_Donator_Level = 2;
      WHEN NEW.DonatedAmount >= 12000 AND NEW.DonatedAmount < 18000 THEN
        SET NEW.ID_Donator_Level = 3;
      ELSE
        SET NEW.ID_Donator_Level = 4;
    END CASE;
  ELSEIF NEW.gender = 'F' THEN
    CASE
      WHEN NEW.DonatedAmount >= 0 AND NEW.DonatedAmount < 5000 THEN
        SET NEW.ID_Donator_Level = 1;
      WHEN NEW.DonatedAmount >= 5000 AND NEW.DonatedAmount < 10000 THEN
        SET NEW.ID_Donator_Level = 2;
      WHEN NEW.DonatedAmount >= 10000 AND NEW.DonatedAmount < 15000 THEN
        SET NEW.ID_Donator_Level = 3;
      ELSE
        SET NEW.ID_Donator_Level = 4;
    END CASE;
  END IF;
END; //
DELIMITER ;




# This trigger automatically calculates the date of the next fastest possible donation for each donor.
# The trigger adds 56 days to the donation date, and then sets the date of the next possible donation.
DELIMITER //
CREATE TRIGGER set_next_possible_donation
BEFORE INSERT ON Donations
FOR EACH ROW
BEGIN
    SET NEW.Next_Possible_Donation = NEW.Donation_Date + INTERVAL 56 DAY;
END; //
DELIMITER ;




# This trigger automatically sums all the blood that is donated and takes into account all the combinations of Blood Types and Rh Factors.
# So this triggers automatically puts data into Inventory. The Inventory table holds data of total quantity of each combination of Blood Type and Rh Factor.
DELIMITER //
CREATE TRIGGER update_inventory_quantity
AFTER INSERT ON Donations
FOR EACH ROW
BEGIN
    UPDATE Inventory
    SET Quantity = (
        SELECT SUM(DonationQuantity) 
        FROM Donations 
        JOIN Patients ON Donations.ID_Patient = Patients.ID_Patient
        WHERE Patients.ID_BloodType = Inventory.ID_BloodType 
        AND Patients.ID_RhFactor = Inventory.ID_RhFactor
    )
    WHERE Inventory.ID_BloodType = (
        SELECT Patients.ID_BloodType
        FROM Patients
        WHERE Patients.ID_Patient = NEW.ID_Patient
    ) AND Inventory.ID_RhFactor = (
        SELECT Patients.ID_RhFactor
        FROM Patients
        WHERE Patients.ID_Patient = NEW.ID_Patient
    );
END; //
DELIMITER ;
