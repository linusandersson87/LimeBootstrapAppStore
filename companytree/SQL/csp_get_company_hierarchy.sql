
/****** Object:  StoredProcedure [dbo].[csp_get_company_hierarchy]    Script Date: 2015-02-16 14:54:36 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[csp_get_company_hierarchy]
	-- Add the parameters for the stored procedure here
	@@idcompany AS INTEGER,
	@@includeperson AS BIT,
	@@retval AS NVARCHAR(MAX) = N'' OUTPUT
AS
BEGIN
-- FLAG_EXTERNALACCESS --
	DECLARE @idparent INTEGER
	DECLARE @topcompany INTEGER
	DECLARE @maxlevel INTEGER = 10
	DECLARE @includeperson INTEGER = -1
	
	DECLARE @i INTEGER = 1


	SELECT @idparent = [parentcompany], @topcompany = [idcompany] FROM [company] WHERE [idcompany] = @@idcompany AND [status] = 0
	WHILE @idparent IS NOT NULL AND @i < @maxlevel
	BEGIN
		SELECT @topcompany = [idcompany], @idparent = [parentcompany] FROM [company] WHERE [status] = 0 AND [idcompany] = @idparent
		SELECT @i = @i + 1
	END

	IF @@includeperson = 1
		SET @includeperson = @topcompany

	;WITH cte AS (
			SELECT	
					[name] AS 'name',
					[idcompany] AS 'idrecord',
					'company' AS 'type',
					CASE WHEN [postaladdress1] <> '' THEN [postaladdress1] + ', ' ELSE '' END + [postalcity] AS 'info',
					ISNULL([dbo].[cfn_get_company_children]([idcompany],0,@@includeperson),N'') AS 'children'
			FROM [company]
			WHERE [idcompany]= @topcompany AND [status] = 0
	) 
	SELECT @@retval = CAST((SELECT [name], [idrecord], [type],[info], [children] FROM cte FOR XML PATH(''), TYPE) AS NVARCHAR(MAX))
	PRINT LEN(@@retval)
	-- PARSE XML TO WEIRD ASS D3 JSON FORMAT 
	SELECT @@retval = REPLACE(@@retval,'<children/>','<children></children>')
	SELECT @@retval = REPLACE(@@retval,'<info/>','<info></info>')
	SELECT @@retval = REPLACE(@@retval,'<children>','"children" : [')
	SELECT @@retval = REPLACE(@@retval,'</children>',']},')
	SELECT @@retval = REPLACE(@@retval,'<name>','{"name" : "')
	SELECT @@retval = REPLACE(@@retval,'</name>','", ')
	SELECT @@retval = REPLACE(@@retval,'<idrecord>',' "idrecord" : "')
	SELECT @@retval = REPLACE(@@retval,'</idrecord>','", ')
	SELECT @@retval = REPLACE(@@retval,'<type>',' "type" : "')
	SELECT @@retval = REPLACE(@@retval,'</type>','", ')
	SELECT @@retval = REPLACE(@@retval,'<info>',' "info" : "')
	SELECT @@retval = REPLACE(@@retval,'</info>','", ')
	SELECT @@retval = REPLACE(@@retval,',]',']')
	SELECT @@retval = SUBSTRING(@@retval,0,LEN(@@retval))
END
