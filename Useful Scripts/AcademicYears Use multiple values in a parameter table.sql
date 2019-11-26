--Use this code in the main query with a in (SELECT AcademicYr from @AcademicYears)
DECLARE @AcademicYears table
(
	AcademicYr varchar(5)
)

Insert into @AcademicYears values (right(convert(VARCHAR, CASE 
				WHEN month(getdate()) - 8 < 0
					THEN year(getdate()) - 1
				ELSE year(getdate())
				END), 2) + '/' + right(convert(VARCHAR, CASE 
				WHEN month(getdate()) - 8 < 0
					THEN year(getdate()) - 1
				ELSE year(getdate())
				END + 1), 2))
Insert into @AcademicYears values (right(convert(VARCHAR, CASE 
				WHEN month(getdate()) - 8 < 0
					THEN year(getdate()) - 2
				ELSE year(getdate())
				END), 2) + '/' + right(convert(VARCHAR, CASE 
				WHEN month(getdate()) - 8 < 0
					THEN year(getdate()) - 2
				ELSE year(getdate())
				END + 1), 2))
Insert into @AcademicYears values (right(convert(VARCHAR, CASE 
				WHEN month(getdate()) - 8 < 0
					THEN year(getdate()) - 3
				ELSE year(getdate())
				END), 2) + '/' + right(convert(VARCHAR, CASE 
				WHEN month(getdate()) - 8 < 0
					THEN year(getdate()) - 3
				ELSE year(getdate())
				END + 1), 2))

SELECT AcademicYr from @AcademicYears