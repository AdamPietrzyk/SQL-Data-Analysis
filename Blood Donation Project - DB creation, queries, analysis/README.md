# Blood Donation Project description

### The "Blood Donation Project" is a project entirely created by me. All the data preseted in this project is fictional.

### The project is a simple database which acts as a mini blood donation system. It was created using mySQL.

_________________________________________________________________________


### Q: How to run it?
A: So in order to use this code you need to run SQL files in an order as below:
1. "DB and tables creation.sql" - this file builds the whole database with tables
2. "Inserting data.sql" - this file contains values that need to be inserted
3. "Queries and analysis.sql" - this file contains some queries that allow to analyze data
<br> </br>
_________________________________________________________________________
### Q: How does the structure look like?
#### A: The database itself contains several tables that are linked with relations. These are:

- Patients - this table contains data about donors such as names, genders, addresses
- Donations - this table contains data about all the donations, so it allows to identify which donor donated a specific amount of blood etc.
- Inventory - this table monitors the sum of blood donated (for each combination of BloodType and RhFactor separetely)
- Staff - this table contains data about medical staff
- BloodType - this table contains data about possible blood types
- RhFactor - this table contains data about possible Rh-Factors
- Donator_Level - this table contains data about possible donors level based on a donated amount

So, here are tables with relations between them:

<img width="706" alt="Table relations - Reverse Engineer" src="https://user-images.githubusercontent.com/127242593/223764289-19fe3b4c-d9c2-4f94-98ee-abf3ba8e7f22.png">


Moreover the code that I prepared contains some TRIGGERS, so some ations are taken automatically, such as changing Donator_Level. The trigger automatically sums donated amount for each Patient separetely and changes donor level once it reaches a certain value.
<br> </br>
_________________________________________________________________________
### Q: How does it look like as a dashboard?
#### A: In order to make it a dashboard, I used PowerBI Desktop.
I loaded data as a mySQL source, cleaned it and then created a simple dashboard.

Here you can see two screenshots. The first screenshot takes into account all the data.

<img width="1393" alt="dashboard1" src="https://user-images.githubusercontent.com/127242593/223771861-f84e0a07-69d7-4238-a3a3-01fb0e2e238e.png">

The second screenshot takes into account filtered data. Filters that are active:
* Gender: M
* BloodType: 0
* RhFactor: +
<img width="1393" alt="dashboard2" src="https://user-images.githubusercontent.com/127242593/223771990-3bd2b54b-f7a9-44e7-bddc-8f592497ffc7.png">

