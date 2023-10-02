---Before Data cleaning we need to have a look in datasets
---Removing duplicates if it is present in the datasets

SELECT DISTINCT* FROM HR_Employee
ORDER BY EmployeeNumber ASC;

---Now we are deleting useless columns after having discussion with team

ALTER TABLE HR_Employee DROP COLUMN StockOptionLevel,Education,YearsSinceLastPromotion;
ALTER TABLE HR_Employee DROP COLUMN TrainingTimesLastYear;

---In BusinessTravel, Over18 columns the values are not in format. so we need to change the values into understandable format

UPDATE HR_Employee
SET BusinessTravel = CASE WHEN BusinessTravel = 'Travel_Rarely' THEN 'Rarely'
                      WHEN BusinessTravel = 'Travel_Frequently' THEN 'Frequently'
                     ELSE BusinessTravel END;
UPDATE HR_Employee
SET Over18 = CASE WHEN Over18 = 'Y' THEN 'Yes'
                  ELSE Over18 END;

SELECT DISTINCT* FROM HR_Employee
ORDER BY EmployeeNumber ASC;	

---Renaming the columns name for clear understanding
USE MeriSkill;

SELECT DISTINCT* FROM HR_Employee;


EXEC sp_RENAME 'dbo.HR_Employee.PercentSalaryHike','Salary_Hike_%','COLUMN'
EXEC sp_RENAME 'dbo.HR_Employee.StandardHours', 'Standard_Hours','COLUMN'
EXEC sp_RENAME 'dbo.HR_Employee.TotalWorkingYears','Total_No_Of_Years_Worked','COLUMN'
EXEC sp_RENAME 'dbo.HR_Employee.YearsAtCompany','Years_With_Company','COLUMN'
EXEC sp_RENAME 'dbo.HR_Employee.YearsInCurrentRole','Years_In_Current_Job','COLUMN'
EXEC sp_RENAME 'dbo.HR_Employee.YearsWithCurrManager','Years_With_Current_Manager','COLUMN'
EXEC sp_RENAME 'dbo.HR_Employee.NumCompaniesWorked','No_Of_Companies_Worked','COLUMN'
EXEC sp_RENAME 'dbo.HR_Employee.EmployeeNumber','Employee_Id','COLUMN'
EXEC sp_RENAME 'dbo.HR_Employee.DistanceFromHome','DistanceFromHome_In_KMs','COLUMN'


---We need check whether all column names are correctly changed

SELECT DISTINCT* FROM HR_Employee;