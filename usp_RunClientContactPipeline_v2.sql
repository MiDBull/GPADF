USE [DataMigration]
GO
/****** Object:  StoredProcedure [staging].[usp_RunClientContactPipeline_v2]    Script Date: 2/4/2026 4:34:56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER   PROCEDURE [staging].[usp_RunClientContactPipeline_v2]
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @Now DATETIME2(7) = SYSDATETIME();

    ---------------------------------------------------------------------
    -- STEP 1: Refresh staging (DO NOT TRUNCATE LastSync)
    ---------------------------------------------------------------------
    TRUNCATE TABLE staging.ClientContact_Staging;
    -- DO NOT TRUNCATE staging.ClientContact_LastSync;  -- <-- FIXED

    INSERT INTO staging.ClientContact_Staging (
        [Contact Type], [Client ID], [Client Status], [Client Type], [fullname_clientid],
        [Client Last Name], [Client First Name], [Company Name], [Federal BN],
        [Other Professional Type], [Client Birthday], [Client SIN Number], [Client Title],
        [Client Gender], [Client Marital Status], [Dependents], [Advisor], [Parent Customer],
        [AdvisorClientCode], [Provincial BN], [Client Home Phone], [Client Business Phone],
        [Client Fax], [Client Cell Phone], [Client Business Phone Extension], [Client E-mail],
        [Spousal Title], [Spousal First Name], [Spousal Occupation], [Spousal  Last Name],
        [Spousal City], [Spousal Postal Code], [Spousal Gender], [Spousal Birthday],
        [Spousal  SIN Number], [Spousal Address], [Spousal Province], [Spousal Country],
        [Employer Name], [Employer Business Type], [Client Occupation], [Employer Postal Code],
        [Employer Address], [Employer City], [Employer Province], [Employer Country],
        [Client Address], [Client City], [Client Province], [Client Postal Code], [Client Country],
        [Returned Mail], [In Person], [By another member of a central cooperative credit],
        [By attestation of an ID document from a commission], [By Agent/Mandatary],
        [By a credit file (with permission)], [By a cleared cheque through a financial entity],
        [By an affiliate to your firm], [By an independant identification product],
        [By confirming that the individual has a deposit ac], [Anniversary], [Childrens Names],
        [Education], [Hobbies & Personal], [Start Date with Advisor], [Age], [No of Children],
        [Gross Annual Income], [Includes Spouse_Gross Annual Income], [Investment Knowledge],
        [Liquid Assets], [Net Worth (a+b+c)], [Fixed Assets], [Includes Spouse_Networth],
        [Liabilities], [Bonds], [Real Estate], [Stocks], [Term Deposits], [Mutual Funds],
        [Mortgages], [KYC on File Date], [User Defined 2_Previous Advisor],
        [Limited Trading Authorisation], [Power Of Attorney], [Citizenship], [Freeze Client],
        [Review Date], [User Defined 1_Free/Matured Form], [User Defined 3_Client Information Form],
        [LTA Date], [POA Date], [Last Client Review Date], [Bank Account Type], [Bank Holder Name],
        [Bank Branch #], [Bank Name], [Bank Account #], [Bank Address], [Bank City],
        [Bank Postal Code], [Bank Province], [Bank Country],
        [Are you a politically exposed foreign person?], [If yes, Office or Position?],
        [Is this company a registered charity?], [Does this client pose a risk as it relates to AML?],
        [Is this company a not-for-profit organization?], [Does this company solicit charitable fin donation],
        [Are you a tax resident of Canada?],[Are you a tax resident of the United States?],[Are you a tax resident of another country?],
        [File ID], [DateNow], [Last_Modified_Date_Client], [SyncStatus], [RetryCount], [LastSyncAttempt], [ErrorMessage],
        [AdvisorClientCRMGUID], [OwnerClientCRMGUID]
    )
    SELECT
        C.[Contact Type], C.[Client ID], C.[Client Status], C.[Client Type], C.[fullname_clientid],
        C.[Client Last Name], C.[Client First Name], C.[Company Name], C.[Federal BN],
        C.[Other Professional Type],
        TRY_CONVERT(DATE, TRY_CAST(C.[Client Birthday] AS VARCHAR(20))),
        C.[Client SIN Number], C.[Client Title],
        C.[Client Gender], C.[Client Marital Status], C.[Dependents], C.[Advisor], C.[Parent Customer],
        C.[AdvisorClientCode], C.[Provincial BN], C.[Client Home Phone], C.[Client Business Phone],
        C.[Client Fax], C.[Client Cell Phone], C.[Client Business Phone Extension], C.[Client E-mail],
        C.[Spousal Title], C.[Spousal First Name], C.[Spousal Occupation], C.[Spousal Last Name],
        C.[Spousal City], C.[Spousal Postal Code], C.[Spousal Gender],
        TRY_CONVERT(DATE, TRY_CAST(C.[Spousal Birthday] AS VARCHAR(20))),
        C.[Spousal SIN Number], C.[Spousal Address], C.[Spousal Province], C.[Spousal Country],
        C.[Employer Name], C.[Employer Business Type], C.[Client Occupation], C.[Employer Postal Code],
        C.[Employer Address], C.[Employer City], C.[Employer Province], C.[Employer Country],
        C.[Client Address], C.[Client City], C.[Client Province], C.[Client Postal Code], C.[Client Country],
        C.[Returned Mail], C.[In Person], C.[By another member of a central cooperative credit],
        C.[By attestation of an ID document from a commission], C.[By Agent/Mandatary],
        C.[By a credit file (with permission)], C.[By a cleared cheque through a financial entity],
        C.[By an affiliate to your firm], C.[By an independant identification product],
        C.[By confirming that the individual has a deposit ac],
        TRY_CONVERT(DATE, TRY_CAST(C.[Anniversary] AS VARCHAR(20))), C.[Childrens Names],
        C.[Education], C.[Hobbies & Personal],
        TRY_CONVERT(DATE, TRY_CAST(C.[Start Date with Advisor] AS VARCHAR(20))),
        C.[Age], C.[No of Children],
        C.[Gross Annual Income], C.[Includes Spouse_Gross Annual Income], C.[Investment Knowledge],
        C.[Liquid Assets], C.[Net Worth (a+b+c)], C.[Fixed Assets], C.[Includes Spouse_Networth],
        C.[Liabilities], C.[Bonds], C.[Real Estate], C.[Stocks], C.[Term Deposits], C.[Mutual Funds],
        C.[Mortgages],
        TRY_CONVERT(DATE, TRY_CAST(C.[KYC on File Date] AS VARCHAR(20))),
        C.[User Defined 2_Previous Advisor],
        C.[Limited Trading Authorisation], C.[Power Of Attorney], C.[Citizenship], C.[Freeze Client],
        TRY_CONVERT(DATE, TRY_CAST(C.[Review Date] AS VARCHAR(20))),
        C.[User Defined 1_Free/Matured Form], C.[User Defined 3_Client Information Form],
        TRY_CONVERT(DATE, TRY_CAST(C.[LTA Date] AS VARCHAR(20))),
        TRY_CONVERT(DATE, TRY_CAST(C.[POA Date] AS VARCHAR(20))),
        TRY_CONVERT(DATE, TRY_CAST(C.[Last Client Review Date] AS VARCHAR(20))),
        C.[Bank Account Type], C.[Bank Holder Name], C.[Bank Branch #], C.[Bank Name], C.[Bank Account #], C.[Bank Address],
        C.[Bank City], C.[Bank Postal Code], C.[Bank Province], C.[Bank Country],
        C.[Are you a politically exposed foreign person?], C.[If yes, Office or Position?],
        C.[Is this company a registered charity?], C.[Does this client pose a risk as it relates to AML?],
        C.[Is this company a not-for-profit organization?], C.[Does this company solicit charitable fin donation],
        C.[Are you a tax resident of Canada?], C.[Are you a tax resident of the United States?], C.[Are you a tax resident of another country?],
        C.[File ID],
        @Now AS [DateNow],
        TRY_CONVERT(DATETIME2(7), C.[Last_Modified_Date_Client]) AS [Last_Modified_Date_Client],
        'Pending' AS SyncStatus,
        0 AS RetryCount,
        NULL AS LastSyncAttempt,
        NULL AS ErrorMessage,
        A.Advisor_GUID AS AdvisorClientCRMGUID,
        O.Owner_GUID   AS OwnerClientCRMGUID
    FROM VieFUND.dbo.Scribe_ClientContact C
    LEFT JOIN staging.CRM_AdvisorMap A ON C.[Parent Customer] = A.[Advisor_Code]
    LEFT JOIN staging.CRM_OwnerMap O   ON C.[Advisor] = O.Owner_Name
    WHERE C.[Parent Customer] IN ('7597-5500', '3150-5500')
      AND C.[Client Status] IN (1);

    ---------------------------------------------------------------------
    -- STEP 2: Change detection (FIXED incremental logic)
    ---------------------------------------------------------------------
    ;WITH StagingHash AS (
        SELECT
            [Client ID],
            HASHBYTES(
                'SHA2_256',
                CONCAT(
                    ISNULL([Client First Name], ''), '|',
                    ISNULL([Client Last Name], ''), '|',
                    ISNULL([Client E-mail], ''), '|',
                    ISNULL([Client Home Phone], ''), '|',
                    ISNULL(CONVERT(NVARCHAR(50), [Client Type]), ''), '|',
                    ISNULL(CONVERT(NVARCHAR(50), [Net Worth (a+b+c)]), ''), '|',
                    ISNULL([Employer Name], ''), '|',
                    ISNULL(CONVERT(NVARCHAR(100), [AdvisorClientCRMGUID]), ''), '|',
                    ISNULL(CONVERT(NVARCHAR(100), [OwnerClientCRMGUID]), '')
                )
            ) AS HashValue
        FROM staging.ClientContact_Staging
    ),
    LastSyncHash AS (
        SELECT
            [Client ID],
            HASHBYTES(
                'SHA2_256',
                CONCAT(
                    ISNULL([Client First Name], ''), '|',
                    ISNULL([Client Last Name], ''), '|',
                    ISNULL([Client E-mail], ''), '|',
                    ISNULL([Client Home Phone], ''), '|',
                    ISNULL(CONVERT(NVARCHAR(50), [Client Type]), ''), '|',
                    ISNULL(CONVERT(NVARCHAR(50), [Net Worth (a+b+c)]), ''), '|',
                    ISNULL([Employer Name], ''), '|',
                    ISNULL(CONVERT(NVARCHAR(100), [AdvisorClientCRMGUID]), ''), '|',
                    ISNULL(CONVERT(NVARCHAR(100), [OwnerClientCRMGUID]), '')
                )
            ) AS HashValue
        FROM staging.ClientContact_LastSync
    )
    UPDATE S
      SET
        SyncStatus =
          CASE
            WHEN L.[Client ID] IS NULL THEN 'Pending'            -- new
            WHEN L.HashValue <> SH.HashValue THEN 'Pending'      -- changed
            ELSE 'Processed'                                     -- unchanged
          END,
        DateNow = @Now
    FROM staging.ClientContact_Staging S
    INNER JOIN StagingHash SH ON S.[Client ID] = SH.[Client ID]
    LEFT  JOIN LastSyncHash L ON S.[Client ID] = L.[Client ID];

    ---------------------------------------------------------------------
    -- STEP 3: Pending -> Processing (only changed rows get sent to CRM)
    ---------------------------------------------------------------------
    UPDATE staging.ClientContact_Staging
      SET SyncStatus = 'Processing',
          LastSyncAttempt = @Now,
          ErrorMessage = NULL
    WHERE SyncStatus = 'Pending';

    ---------------------------------------------------------------------
    -- Output rows for ADF Copy_ToCRM
    ---------------------------------------------------------------------
    SELECT
        LTRIM(RTRIM([Client ID]))             AS new_clientid,
        LTRIM(RTRIM([Client First Name]))     AS firstname,
        LTRIM(RTRIM([Client Last Name]))      AS lastname,
        LTRIM(RTRIM([Client E-mail]))         AS emailaddress1,
        LTRIM(RTRIM([Client Home Phone]))     AS telephone1,
        LTRIM(RTRIM([Client Business Phone])) AS telephone2,
        LTRIM(RTRIM([Client Cell Phone]))     AS mobilephone,
        LTRIM(RTRIM([Client Fax]))            AS fax,
        LTRIM(RTRIM([Client Address]))        AS address1_line1,
        LTRIM(RTRIM([Client City]))           AS address1_city,
        LTRIM(RTRIM([Client Province]))       AS address1_stateorprovince,
        LTRIM(RTRIM([Client Postal Code]))    AS address1_postalcode,
        LTRIM(RTRIM([Client Country]))        AS address1_country,
        CAST([Client Type] AS INT)            AS new_clienttype,
        @Now                                  AS new_datasynctimestamp,
        CASE
          WHEN TRY_CAST([Net Worth (a+b+c)] AS MONEY) < 0 THEN NULL
          ELSE TRY_CAST([Net Worth (a+b+c)] AS MONEY)
        END AS new_networth,
        CAST([Investment Knowledge] AS INT)   AS new_investmentknowledge_optionset,
        LTRIM(RTRIM([Employer Name]))         AS new_employername,
        LTRIM(RTRIM([Advisor]))               AS Advisor,
        LTRIM(RTRIM([Parent Customer]))       AS ParentCustomer,

        CAST([Are you a tax resident of Canada?] AS BIT)             AS new_AreyouataxresidentofCanada,
        CAST([Are you a tax resident of the United States?] AS BIT) AS new_AreyouataxresidentoracitizenoftheUnited,
        CAST([Are you a tax resident of another country?] AS BIT)   AS new_Areyouataxresidentofanotherjurisdiction,

        [AdvisorClientCRMGUID],
        [OwnerClientCRMGUID]
    FROM staging.ClientContact_Staging
    WHERE SyncStatus = 'Processing'
    ORDER BY Last_Modified_Date_Client DESC;
END;
