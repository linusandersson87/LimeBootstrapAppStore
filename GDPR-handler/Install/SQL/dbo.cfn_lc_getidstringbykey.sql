
GO
/****** Object:  UserDefinedFunction [dbo].[cfn_lc_getidstringbykey]    Script Date: 2017-05-10 09:46:35 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- Written by: Fredrik Eriksson
-- Created: 2015-03-17

-- ##########
-- DISCLAIMER:
-- This procedure is a built in procedure in Lime Core.
-- Modifying it could have consequences beyond your imagination.
-- Or not.
-- Seriously though, you should always make sure that no other built in functionality breaks if you must modify this procedure.
-- ##########

-- Returns the idstring corresponding to the key for the specified field.

ALTER FUNCTION [dbo].[cfn_lc_getidstringbykey]
(
	@@tablename NVARCHAR(64)
	, @@fieldname NVARCHAR(64)
	, @@key NVARCHAR(256)
)
RETURNS INT
AS
BEGIN

	RETURN
	(
		SELECT s.idstring
		FROM string s
		INNER JOIN attributedata ad
			ON ad.[owner] = N'field'
				AND ad.name = N'idcategory'
				AND ad.value = s.idcategory
		INNER JOIN field f
			ON f.idfield = ad.idrecord
		INNER JOIN [table] t
			ON t.idtable = f.idtable
		WHERE t.name = @@tablename
			AND f.name = @@fieldname
			AND s.[key] = @@key
	)
END