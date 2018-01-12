SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author: Fredrik Danielsson, Lundalogik AB
-- Created: 2013-10-31
-- Description:	Called from VBA to make a full-text search on documents.

-- Modified: 2018-01-10, Fredrik Eriksson, Lundalogik AB
--			Updated according to requirements on Community Add-ons.
-- =============================================
CREATE PROCEDURE [dbo].[csp_addon_fulltextsearch_finddocuments]
	@@searchstring NVARCHAR(4000)
AS
BEGIN
	-- FLAG_EXTERNALACCESS --
	SET NOCOUNT ON;
	SET @@searchstring = [dbo].[cfn_addon_fulltextsearch_preparesearchstring](@@searchstring)

    SELECT TOP 1001 d.iddocument AS [id]
	FROM [dbo].[document] d
	INNER JOIN [dbo].[file] f
		ON d.document = f.idfile
	WHERE CONTAINS(f.[data], @@searchstring)
	FOR XML AUTO, ROOT('documents'), ELEMENTS
END

GO

-- Make procedure available in VBA
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'lsp_refreshldc')
BEGIN
	EXEC lsp_refreshldc
END
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'lsp_setdatabasetimestamp')
BEGIN
	EXEC lsp_setdatabasetimestamp
END
GO