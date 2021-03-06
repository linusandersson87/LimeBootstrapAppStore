
GO
/****** Object:  StoredProcedure [dbo].[csp_AnonymizeSelected]    Script Date: 2017-05-10 14:01:07 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Rasmus Alestig Thunborg (RTH)
-- Create date: 2017-02-22
-- Description:	A procedure to anonymize a customers or coworkers data as according to the PUL-law. 
-- =============================================
ALTER PROCEDURE [dbo].[csp_AnonymizeSelected]
	-- Add the parameters for the stored procedure here
	@@idrecord INT
	, @@iscustomer NVARCHAR(20)
	, @@activeuser INT
AS
BEGIN
	-- FLAG_EXTERNALACCESS --

	SET NOCOUNT ON;
	IF @@iscustomer = 'customer'

	-- Include any other fields that should be emptied in the update statements below. 

		BEGIN

			UPDATE company 
			SET name = 'Anonymous-contact',
				phone = '',
				fullpostaladdress = '',
				postaladdress1 = '',
				postaladdress2 = '',
				postalzipcode = '',
				postalcity = '', 
				visitingzipcode = '',
				visitingcity = '',
				country = ''
			FROM company
			WHERE company.idcompany = @@idrecord


			DELETE p 
			FROM person p
			INNER JOIN company c ON c.idcompany = p.company
			WHERE c.idcompany = @@idrecord

			DELETE d
			FROM document d
			INNER JOIN company c ON c.idcompany = d.company
			WHERE c.idcompany = @@idrecord

			DELETE h					 -- Add the four commented lines below and configure if only history notes that have a certain type should be emptied. 
			FROM history h
			INNER JOIN company c ON c.idcompany = h.company
		--	INNER JOIN [string] s ON s.idstring = h.[type]
			WHERE c.idcompany = @@idrecord
			-- AND ( s.[key] = 'customercomment' OR s.[key] = 'fromcustomer')

			DELETE h 
			FROM history h
			INNER JOIN helpdesk d ON d.idhelpdesk = h.helpdesk
			INNER JOIN company c ON c.idcompany = d.company
		--	INNER JOIN [string] s ON s.idstring = h.[type]
			WHERE c.idcompany = @@idrecord
			-- AND ( s.[key] = 'customercomment' OR s.[key] = 'fromcustomer')

			UPDATE history 
			SET company = ''
			FROM history
			INNER JOIN company ON company.idcompany = history.company
			WHERE company.idcompany = @@idrecord

			UPDATE helpdesk
			SET person = '',
			email = '',
			[description] = ''
			FROM helpdesk
			INNER JOIN company ON company.idcompany = helpdesk.company
			WHERE company.idcompany = @@idrecord

		END

	ELSE 

		BEGIN

			UPDATE coworker
				SET name = 'Anonymous-employee', 
				firstname = 'Anonymous-',
				lastname = 'employee',
				phone = '',
				cellphone = '',
				email = '',
				office = '',
				username = ''
			where idcoworker = @@idrecord
		END

	BEGIN

	INSERT INTO gdprlog ([status], createduser, [timestamp], updateduser, createdtime, [type], [datetime], responsible, company)
	VALUES(0, 1, GETDATE(), 1, GETDATE(), dbo.cfn_lc_getidstringbykey('gdprlog', 'type', 'request'), GETDATE(), @@activeuser, @@idrecord)

	END

END

