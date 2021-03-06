USE []
GO
/****** Object:  StoredProcedure [dbo].[csp_getActivities]    Script Date: 8.9.2014 17:25:40 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		<ILE>
-- Create date: <2014-09-05>
-- Description:	<Used to return activities for a coworker>
-- =============================================
CREATE PROCEDURE [dbo].[csp_getActivities]
		@@lang nvarchar(5),
		@@iduser INT
AS
BEGIN
	-- FLAG_EXTERNALACCESS --
	
	DECLARE @lang nvarchar(5)
	set @lang = @@lang
	--CORRECT LANGUAGE BUG
	IF @lang = N'en-us'
		SET @lang = N'en_us'
	
	
	SELECT	
	(select dbo.lfn_getstring2(h.[type],@lang) as [activitytype],
	COUNT(h.idhistory) as [amount] 
	from history h
	inner join string s on s.idstring = h.[type]
	where coworker = @@iduser
	group by h.[type]
	FOR XML RAW ('value'), TYPE, ROOT ('activities')),

	(select dbo.lfn_getstring2(h.[type],@lang) as [activitytype],
	COUNT(h.idhistory) as [amount] 
	from history h
	inner join string s on s.idstring = h.[type]
	group by h.[type]
	FOR XML RAW ('value'), TYPE, ROOT ('activitiesall'))
	FOR XML PATH(''), TYPE, ROOT ('activityweb');
	
	
END