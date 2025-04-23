-- Question 1.1

SELECT COUNT(*) AS num_rows, 
		COUNT(CLM_ID) AS num_total_claims,
		COUNT(DISTINCT(CLM_ID)) AS num_unique_claims
FROM DE1_0_2008_to_2010_Inpatient_Claims_Sample_1;

-- Answer
-- 66773	66773	66705

-- Question 1.2

WITH num_claims AS (
	SELECT DESYNPUF_ID,
			COUNT(DISTINCT(CLM_ID)) AS num_claims,
			YEAR(CLM_ADMSN_DT) AS year_claim
	FROM DE1_0_2008_to_2010_Inpatient_Claims_Sample_1
	GROUP BY DESYNPUF_ID, YEAR(CLM_ADMSN_DT)
)
SELECT year_claim,
		AVG(num_claims) AS avg_claims
FROM num_claims
GROUP BY year_claim
ORDER BY year_claim;

-- Answer
-- 2007	1.0463
-- 2008	1.7450
-- 2009	1.3398
-- 2010	1.1585


-- Question 2.1

SELECT COUNT(*) AS mismatch_counts
FROM DE1_0_2008_to_2010_Inpatient_Claims_Sample_1
WHERE CLM_UTLZTN_DAY_CNT <> DATEDIFF(CLM_THRU_DT, CLM_FROM_DT);


-- Answer
-- 3546

-- Question 2.2

SELECT COUNT(*) AS mismatch_counts
FROM DE1_0_2008_to_2010_Inpatient_Claims_Sample_1
WHERE CLM_UTLZTN_DAY_CNT <> DATEDIFF(NCH_BENE_DSCHRG_DT, CLM_ADMSN_DT);

-- Answer
-- 3664

-- Question 3.1

WITH los AS (
    SELECT 
        YEAR(CLM_ADMSN_DT) AS year_claim,
        DATEDIFF(NCH_BENE_DSCHRG_DT, CLM_ADMSN_DT) AS length_of_stay
    FROM DE1_0_2008_to_2010_Inpatient_Claims_Sample_1
)
SELECT 
    year_claim, 
    AVG(length_of_stay) AS avg_los
FROM los
GROUP BY year_claim
ORDER BY year_claim;

-- Answer
-- 2007	11.3451
-- 2008	5.7517
-- 2009	5.7500
-- 2010	5.4824

-- Question 3.2
-- Answer
-- There was a drastic drop in length of stay between 2007 and 2008. The length of stay has been decreasing from 2007 to 2010.

-- Question 4.1

CREATE TEMPORARY TABLE depression AS
SELECT * 
FROM DE1_0_2008_Beneficiary_Summary_File_Sample_1
WHERE SP_DEPRESSN = 1;

SELECT COUNT(*) FROM depression;

-- Answer
-- 24840

-- Question 4.2
SELECT (COUNT(DISTINCT(i.DESYNPUF_ID))) FROM DE1_0_2008_to_2010_Inpatient_Claims_Sample_1 i
JOIN depression d ON d.DESYNPUF_ID = i.DESYNPUF_ID
WHERE i.ADMTNG_ICD9_DGNS_CD IN ('29620', '29621', '29622', '29623', '29624', '29625', '29626', 
                           '29630', '29631', '29632', '29633', '29634', '29635', '29636', 
                           '29651', '29652', '29653', '29654', '29655', '29656', 
                           '29660', '29661', '29662', '29663', '29664', '29665', '29666', 
                           '29689', '2980', '3004', '3091', '311');

-- Answer
-- 478


-- Question 4.3
SELECT YEAR(i.CLM_ADMSN_DT),
		(COUNT(DISTINCT(i.DESYNPUF_ID)))
FROM DE1_0_2008_to_2010_Inpatient_Claims_Sample_1 i
JOIN depression d ON d.DESYNPUF_ID = i.DESYNPUF_ID
WHERE i.ADMTNG_ICD9_DGNS_CD IN ('29620', '29621', '29622', '29623', '29624', '29625', '29626', 
                           '29630', '29631', '29632', '29633', '29634', '29635', '29636', 
                           '29651', '29652', '29653', '29654', '29655', '29656', 
                           '29660', '29661', '29662', '29663', '29664', '29665', '29666', 
                           '29689', '2980', '3004', '3091', '311')
GROUP BY YEAR(i.CLM_ADMSN_DT)
ORDER BY YEAR(i.CLM_ADMSN_DT);

-- Answer
-- 2007	5
-- 2008	267
-- 2009	143
-- 2010	74

-- Question 5.1
WITH depression_beneficiaries AS (
	SELECT b.DESYNPUF_ID,
		SUM(i.CLM_PMT_AMT) AS claim_amt_beneficiary
	FROM DE1_0_2008_Beneficiary_Summary_File_Sample_1 b
	INNER JOIN DE1_0_2008_to_2010_Inpatient_Claims_Sample_1 i ON i.DESYNPUF_ID = b.DESYNPUF_ID
	GROUP BY b.DESYNPUF_ID
)
SELECT CASE
			WHEN b.BENE_RACE_CD = 1 THEN 'White'
			WHEN b.BENE_RACE_CD = 2 THEN 'Black'
			WHEN b.BENE_RACE_CD = 3 THEN 'Others'
			ELSE 'Hispanic'
		END AS Race,
	AVG(db.claim_amt_beneficiary) AS average_claim_amt
FROM DE1_0_2008_Beneficiary_Summary_File_Sample_1 b
INNER JOIN DE1_0_2008_to_2010_Inpatient_Claims_Sample_1 i ON b.DESYNPUF_ID = i.DESYNPUF_ID
INNER JOIN depression_beneficiaries db ON db.DESYNPUF_ID = i.DESYNPUF_ID
WHERE i.ADMTNG_ICD9_DGNS_CD IN ('29620', '29621', '29622', '29623', '29624', '29625', '29626', 
                           '29630', '29631', '29632', '29633', '29634', '29635', '29636', 
                           '29651', '29652', '29653', '29654', '29655', '29656', 
                           '29660', '29661', '29662', '29663', '29664', '29665', '29666', 
                           '29689', '2980', '3004', '3091', '311')
GROUP BY b.BENE_RACE_CD

 -- Answer
-- White	25936.137931034482
-- Hispanic	14000
-- Black	26149.42528735632
-- Others	23170

-- Question 5.2 

-- Answer
-- The Hispanic race has the lowest claim amount compared to the other races. White, Black, and Other have relatively similar claim amounts.

-- Question 5.3       

WITH depression_beneficiaries AS (
	SELECT b.DESYNPUF_ID,
		SUM(DATEDIFF(i.NCH_BENE_DSCHRG_DT, i.CLM_ADMSN_DT)) AS length_of_stay
	FROM DE1_0_2008_Beneficiary_Summary_File_Sample_1 b
	INNER JOIN DE1_0_2008_to_2010_Inpatient_Claims_Sample_1 i ON i.DESYNPUF_ID = b.DESYNPUF_ID
	GROUP BY b.DESYNPUF_ID
)
SELECT CASE
			WHEN b.BENE_RACE_CD = 1 THEN 'White'
			WHEN b.BENE_RACE_CD = 2 THEN 'Black'
			WHEN b.BENE_RACE_CD = 3 THEN 'Others'
			ELSE 'Hispanic'
		END AS Race,
	AVG(db.length_of_stay) AS average_los
FROM DE1_0_2008_Beneficiary_Summary_File_Sample_1 b
INNER JOIN DE1_0_2008_to_2010_Inpatient_Claims_Sample_1 i ON b.DESYNPUF_ID = i.DESYNPUF_ID
INNER JOIN depression_beneficiaries db ON db.DESYNPUF_ID = i.DESYNPUF_ID
WHERE i.ADMTNG_ICD9_DGNS_CD IN ('29620', '29621', '29622', '29623', '29624', '29625', '29626', 
                           '29630', '29631', '29632', '29633', '29634', '29635', '29636', 
                           '29651', '29652', '29653', '29654', '29655', '29656', 
                           '29660', '29661', '29662', '29663', '29664', '29665', '29666', 
                           '29689', '2980', '3004', '3091', '311')
GROUP BY b.BENE_RACE_CD  

-- Answer
-- White	23.5534
-- Hispanic	16.2857
-- Black	24.7816
-- Others	27.8500

-- Question 5.4

-- The hispanic population has the lowest length of stay similar to having the lowest claim amount. Interestingly, while the black population has the highest claim amount, they don't have the highest length of stay. The other race has the highest length of stay. 

-- My hypothesis is that race has an influence on the claim amount and the length of stay.               