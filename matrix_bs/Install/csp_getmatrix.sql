USE [wholesale_ie]
GO
/****** Object:  StoredProcedure [dbo].[csp_getmatrix]    Script Date: 2015-06-22 11:03:24 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
ALTER PROCEDURE [dbo].[csp_getmatrix]
	@@idcoworker int
	,@@xml nvarchar(max) output
	,@@startdate date
	,@@enddate date
AS
BEGIN
	
	-- FLAG_EXTERNALACCESS --
	
	declare @xml as xml

	select @xml = (select top 1500 idcompany, c.name, sg.sv as potential, sc.sv as classification, sc.sv + '-' + sg.sv  as id		
		from company c
		left join history hi
		on hi.company = c.idcompany
		left join [string] sg
		on c.potential = sg.idstring
		left join [string] sc
		on c.classification = sc.idstring
		where hi.coworker = @@idcoworker
		and hi.[type] = 168301
		and hi.[date] >= @@startdate 
		and hi.[date] <= @@enddate
	for xml path('company'), ROOT('companies'))

	set @@xml = case when @xml is null then '' else cast(@xml as nvarchar(max))	end 
END
