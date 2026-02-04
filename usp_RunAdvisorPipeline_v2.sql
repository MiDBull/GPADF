USE [DataMigration]
GO
/****** Object:  StoredProcedure [staging].[usp_RunAdvisorPipeline_v2]    Script Date: 2/4/2026 4:31:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



ALTER   PROCEDURE [staging].[usp_RunAdvisorPipeline_v2]
    @ForceUpdate BIT = 0
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @Now DATETIME2(7) = SYSDATETIME();

    ---------------------------------------------------------------------
    -- STEP 1: RefreshAdvisorData
    ---------------------------------------------------------------------
    TRUNCATE TABLE staging.Advisor_Staging;
	--TRUNCATE TABLE staging.Advisor_LastSync;

    INSERT INTO staging.Advisor_Staging (
        [Title], [First Name], [Last Name], [Account Name], [SIN Number], [Date of Birth], [Credentials],
        [Business Name], [Company Start Date], [Federal BN], [Start Date], [Sales Rep], [Rep Status],
        [Advisor Code], [Account/Phone], [Ext], [Address 1: Telephone 2], [Address 1: Fax], [E-mail],
        [Web Site], [Provincial BN], [NRD_Number], [Description], [End Date], [Address 1: Street 1],
        [Address 1: City], [Address 1: ZIP/Postal Code], [Address 1: State/Province], [Address 1: Country/Region],
        [Labour Sponsored Fund], [Hedge Fund], [SEG Fund], [Pooled Fund], [Company_E & O], [Policy #_E & O],
        [Premium $_E & O], [Premium Mode_E & O], [Deductible $_E & O], [Coverage $_E & O], [Coverage For_E & O],
        [Starting Date_E & O], [Ending Date_E & O], [Sponsor], [License Level], [License #], [License Start Date],
        [License End Date], [License Type], [Alberta], [Newfoundland and Labrador], [Ontario], [Yukon],
        [British Columbia], [Northwest Territories], [Prince Edward Island], [Manitoba], [Nova Scotia], [Quebec],
        [New Brunswick], [Nunavut], [Saskatchewan], [DateNow], [Last_Modified_Date],
        [CreatedDate], [LastModifiedDate], [SyncStatus], [RetryCount], [LastSyncAttempt], [ErrorMessage],
        [AdvisorCRMGUID], [OwnerCRMGUID]
    )
    SELECT
		REPLACE(S.[Title], '/', '')        AS [Title],
		REPLACE(S.[First Name], '/', '')  AS [First Name],
		REPLACE(S.[Last Name], '/', '')   AS [Last Name],
		REPLACE(S.[Account Name], '/', '') AS [Account Name],
		S.[SIN Number], S.[Date of Birth], S.[Credentials],
        S.[Business Name], S.[Company Start Date], S.[Federal BN], S.[Start Date], REPLACE(S.[Sales Rep], '/', ''), S.[Rep Status],
        S.[Advisor Code], S.[Account/Phone], S.[Ext], S.[Address 1: Telephone 2], S.[Address 1: Fax], S.[E-mail],
        S.[Web Site], S.[Provincial BN], S.[NRD_Number], S.[Description], S.[End Date], S.[Address 1: Street 1],
        S.[Address 1: City], S.[Address 1: ZIP/Postal Code], S.[Address 1: State/Province], S.[Address 1: Country/Region],
        S.[Labour Sponsored Fund], S.[Hedge Fund], S.[SEG Fund], S.[Pooled Fund], S.[Company_E & O], S.[Policy #_E & O],
        S.[Premium $_E & O], S.[Premium Mode_E & O], S.[Deductible $_E & O], S.[Coverage $_E & O], S.[Coverage For_E & O],
        S.[Starting Date_E & O], S.[Ending Date_E & O], S.[Sponsor], S.[License Level], S.[License #], S.[License Start Date],
        S.[License End Date], S.[License Type], S.[Alberta], S.[Newfoundland and Labrador], S.[Ontario], S.[Yukon],
        S.[British Columbia], S.[Northwest Territories], S.[Prince Edward Island], S.[Manitoba], S.[Nova Scotia], S.[Quebec],
        S.[New Brunswick], S.[Nunavut], S.[Saskatchewan], @Now, S.[Last_Modified_Date],
        @Now, @Now, 'Pending', 0, NULL, NULL,
        A.Advisor_GUID, O.Owner_GUID
    FROM [VieFund].dbo.Scribe_Advisors S
    LEFT JOIN staging.CRM_AdvisorMap A ON S.[Advisor Code] = A.[Advisor_Code]
    LEFT JOIN staging.CRM_OwnerMap   O ON S.[Sales Rep] = O.[Owner_Name]
	where [Rep Status] = 0;
    --WHERE S.[Advisor Code] IN ('7597-5500', '3150-5500');
	--WHERE S.[Advisor Code] IN ('7597-9904', '3150-9904');
	

    ---------------------------------------------------------------------
    -- STEP 2: Compare for Changes (unless ForceUpdate)
    ---------------------------------------------------------------------
  ---------------------------------------------------------------------
-- STEP 2: Compare for Changes (unless ForceUpdate)
---------------------------------------------------------------------
		WITH StagingHash AS (
			SELECT
				[Advisor Code],
				HASHBYTES('SHA2_256', CONCAT(
					ISNULL([Title], ''),'|',
					ISNULL([First Name], ''),'|',
					ISNULL([Last Name], ''),'|',
					ISNULL([Account Name], ''),'|',
					ISNULL([SIN Number], ''),'|',
					ISNULL(CONVERT(nvarchar(30), [Date of Birth], 126), ''),'|',
					ISNULL([Credentials], ''),'|',
					ISNULL([Business Name], ''),'|',
					ISNULL(CONVERT(nvarchar(30), [Company Start Date], 126), ''),'|',
					ISNULL([Federal BN], ''),'|',
					ISNULL(CONVERT(nvarchar(30), [Start Date], 126), ''),'|',
					ISNULL([Sales Rep], ''),'|',
					ISNULL(CONVERT(nvarchar(10), [Rep Status]), ''),'|',
					ISNULL([Account/Phone], ''),'|',
					ISNULL([Ext], ''),'|',
					ISNULL([Address 1: Telephone 2], ''),'|',
					ISNULL([Address 1: Fax], ''),'|',
					ISNULL([E-mail], ''),'|',
					ISNULL([Web Site], ''),'|',
					ISNULL([Provincial BN], ''),'|',
					ISNULL([NRD_Number], ''),'|',
					ISNULL([Description], ''),'|',
					ISNULL(CONVERT(nvarchar(30), [End Date], 126), ''),'|',
					ISNULL([Address 1: Street 1], ''),'|',
					ISNULL([Address 1: City], ''),'|',
					ISNULL([Address 1: ZIP/Postal Code], ''),'|',
					ISNULL([Address 1: State/Province], ''),'|',
					ISNULL([Address 1: Country/Region], ''),'|',
					ISNULL(CONVERT(nvarchar(10), [Labour Sponsored Fund]), ''),'|',
					ISNULL(CONVERT(nvarchar(10), [Hedge Fund]), ''),'|',
					ISNULL(CONVERT(nvarchar(10), [SEG Fund]), ''),'|',
					ISNULL(CONVERT(nvarchar(10), [Pooled Fund]), ''),'|',
					ISNULL([Company_E & O], ''),'|',
					ISNULL([Policy #_E & O], ''),'|',
					ISNULL(CONVERT(nvarchar(40), [Premium $_E & O]), ''),'|',
					ISNULL([Premium Mode_E & O], ''),'|',
					ISNULL(CONVERT(nvarchar(40), [Deductible $_E & O]), ''),'|',
					ISNULL(CONVERT(nvarchar(40), [Coverage $_E & O]), ''),'|',
					ISNULL([Coverage For_E & O], ''),'|',
					ISNULL(CONVERT(nvarchar(30), [Starting Date_E & O], 126), ''),'|',
					ISNULL(CONVERT(nvarchar(30), [Ending Date_E & O], 126), ''),'|',
					ISNULL([Sponsor], ''),'|',
					ISNULL([License Level], ''),'|',
					ISNULL([License #], ''),'|',
					ISNULL(CONVERT(nvarchar(30), [License Start Date], 126), ''),'|',
					ISNULL(CONVERT(nvarchar(30), [License End Date], 126), ''),'|',
					ISNULL([License Type], ''),'|',
					ISNULL(CONVERT(nvarchar(100), [AdvisorCRMGUID]), ''),'|',
					ISNULL(CONVERT(nvarchar(100), [OwnerCRMGUID]), '')
				)) AS HashValue
			FROM staging.Advisor_Staging
		),
		LastSyncHash AS (
			SELECT
				[Advisor Code],
				HASHBYTES('SHA2_256', CONCAT(
					ISNULL([Title], ''),'|',
					ISNULL([First Name], ''),'|',
					ISNULL([Last Name], ''),'|',
					ISNULL([Account Name], ''),'|',
					ISNULL([SIN Number], ''),'|',
					ISNULL(CONVERT(nvarchar(30), [Date of Birth], 126), ''),'|',
					ISNULL([Credentials], ''),'|',
					ISNULL([Business Name], ''),'|',
					ISNULL(CONVERT(nvarchar(30), [Company Start Date], 126), ''),'|',
					ISNULL([Federal BN], ''),'|',
					ISNULL(CONVERT(nvarchar(30), [Start Date], 126), ''),'|',
					ISNULL([Sales Rep], ''),'|',
					ISNULL(CONVERT(nvarchar(10), [Rep Status]), ''),'|',
					ISNULL([Account/Phone], ''),'|',
					ISNULL([Ext], ''),'|',
					ISNULL([Address 1: Telephone 2], ''),'|',
					ISNULL([Address 1: Fax], ''),'|',
					ISNULL([E-mail], ''),'|',
					ISNULL([Web Site], ''),'|',
					ISNULL([Provincial BN], ''),'|',
					ISNULL([NRD_Number], ''),'|',
					ISNULL([Description], ''),'|',
					ISNULL(CONVERT(nvarchar(30), [End Date], 126), ''),'|',
					ISNULL([Address 1: Street 1], ''),'|',
					ISNULL([Address 1: City], ''),'|',
					ISNULL([Address 1: ZIP/Postal Code], ''),'|',
					ISNULL([Address 1: State/Province], ''),'|',
					ISNULL([Address 1: Country/Region], ''),'|',
					ISNULL(CONVERT(nvarchar(10), [Labour Sponsored Fund]), ''),'|',
					ISNULL(CONVERT(nvarchar(10), [Hedge Fund]), ''),'|',
					ISNULL(CONVERT(nvarchar(10), [SEG Fund]), ''),'|',
					ISNULL(CONVERT(nvarchar(10), [Pooled Fund]), ''),'|',
					ISNULL([Company_E & O], ''),'|',
					ISNULL([Policy #_E & O], ''),'|',
					ISNULL(CONVERT(nvarchar(40), [Premium $_E & O]), ''),'|',
					ISNULL([Premium Mode_E & O], ''),'|',
					ISNULL(CONVERT(nvarchar(40), [Deductible $_E & O]), ''),'|',
					ISNULL(CONVERT(nvarchar(40), [Coverage $_E & O]), ''),'|',
					ISNULL([Coverage For_E & O], ''),'|',
					ISNULL(CONVERT(nvarchar(30), [Starting Date_E & O], 126), ''),'|',
					ISNULL(CONVERT(nvarchar(30), [Ending Date_E & O], 126), ''),'|',
					ISNULL([Sponsor], ''),'|',
					ISNULL([License Level], ''),'|',
					ISNULL([License #], ''),'|',
					ISNULL(CONVERT(nvarchar(30), [License Start Date], 126), ''),'|',
					ISNULL(CONVERT(nvarchar(30), [License End Date], 126), ''),'|',
					ISNULL([License Type], ''),'|',
					ISNULL(CONVERT(nvarchar(100), [AdvisorCRMGUID]), ''),'|',
					ISNULL(CONVERT(nvarchar(100), [OwnerCRMGUID]), '')
				)) AS HashValue
			FROM staging.Advisor_LastSync
		)
		UPDATE S
		SET
			SyncStatus = CASE
				WHEN @ForceUpdate = 1 THEN 'Pending'
				WHEN L.[Advisor Code] IS NULL THEN 'Pending'               -- new
				WHEN SH.HashValue <> LH.HashValue THEN 'Pending'           -- changed
				ELSE 'Processed'                                           -- unchanged
			END,
			LastModifiedDate = @Now
		FROM staging.Advisor_Staging S
		LEFT JOIN staging.Advisor_LastSync L ON S.[Advisor Code] = L.[Advisor Code]
		LEFT JOIN StagingHash SH ON S.[Advisor Code] = SH.[Advisor Code]
		LEFT JOIN LastSyncHash LH ON S.[Advisor Code] = LH.[Advisor Code];


    ---------------------------------------------------------------------
    -- STEP 3: Override Rep Status
    ---------------------------------------------------------------------
    UPDATE staging.Advisor_Staging
    SET SyncStatus = 'Processed'
    WHERE ISNULL([Rep Status], 0) <> 0;

    ---------------------------------------------------------------------
    -- STEP 4: Mark as Processing + Return to ADF
    ---------------------------------------------------------------------
    UPDATE staging.Advisor_Staging
    SET SyncStatus = 'Processing',
        LastSyncAttempt = @Now,
        ErrorMessage = NULL
    WHERE SyncStatus = 'Pending';

    SELECT *
    FROM staging.Advisor_Staging
    WHERE SyncStatus = 'Processing';
END
