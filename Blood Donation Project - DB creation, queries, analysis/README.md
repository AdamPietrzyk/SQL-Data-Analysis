# Blood Donation Project description

### The "Blood Donation Project" is a project entirely created by me. All the data preseted in this project is fictional.

### The project is a simple database which acts as a mini blood donation system.

_________________________________________________________________________


#### The database contains several tables that are linked with relations. These are:

- Patients - this table contains data about donors such as names, genders, addresses
- Donations - this table contains data about all the donations, so it allows to identify which donor donated a specific amount of blood etc.
- Inventory - this table monitors the sum of blood donated (for each combination of BloodType and RhFactor separetely)
- Staff - this table contains data about medical staff
- BloodType - this table contains data about possible blood types
- RhFactor - this table contains data about possible Rh-Factors
- DonorLevel - this table contains data about possible donors level based on a donated amount

So, here are tables with relations between them:

<img width="706" alt="Table relations - Reverse Engineer" src="https://user-images.githubusercontent.com/127242593/223764289-19fe3b4c-d9c2-4f94-98ee-abf3ba8e7f22.png">


Moreover the code that I prepared contains some TRIGGERS, so some ations are taken automaticcaly, such as changing DonorLevel. Trigger automatically sums donated amount for each Patient separetely and changes donor level once it reaches a certain value.
