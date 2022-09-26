SELECT
    a.term_id,
    a1.academic_year_code,
-- Student Athlete Last Name
    b.last_name AS student_athlete_last_name,
-- Student Athlete First Name
    b.first_name AS student_athlete_first_name,
-- Student Athlete Middle Initial
    SUBSTR(b.middle_name, 1, 1) AS student_athlete_middle_initial,
-- Student Athlete School ID Number
    b.student_id AS student_athlete_school_id_number,
-- NCAA ID
    b.ncaa_id AS ncaa_id,
-- Student Athlete Gender
    b.gender_code AS student_athlete_gender,
-- Student Athlete Ethnicity
    CASE
        -- 1=American Indian/Alaskan Native
        WHEN b.is_american_indian_alaskan THEN 1
        -- 2=Asian
        WHEN b.is_asian THEN 2
        -- 2.1=Native Hawaiian/Pacific Islander
        WHEN b.is_hawaiian_pacific_islander THEN 2.1
        -- 3=Black/African American
        WHEN b.is_black THEN 3
        -- 4=Hispanic/Latino
        WHEN b.is_hispanic_latino_ethnicity THEN 4
        -- 5=White/Non-Hispanic
        WHEN b.is_white THEN 5
        -- 6=Non-Resident Alien
        WHEN NOT b.is_in_state_resident THEN 6
        -- 7.1=Two or More Races
        WHEN b.is_multi_racial THEN 7.1
        -- 7=Unknown
        ELSE 7
    END AS student_athlete_ethnicity,

-- First Year Your University
    d.academic_year_code AS first_year_your_university,
-- First Term Your University
    -- S1- Fall, S2-Spring
    CASE
        WHEN d.season = 'Fall' THEN 'S1'
        WHEN d.season = 'Spring' THEN 'S2'
    END AS first_term_your_university,
-- Earned Associates Degree
    CASE
        WHEN b.is_awarded_associates_prior_institution THEN 'Y'
        ELSE 'N'
    END AS earned_associates_degree,
-- Summer Bridge Program
    -- TODO: this will have to be a separate query to obtain (see documentation)
-- Degree Code (CIP)
    a.primary_major_cip_code,
-- Cumulative Credit Hours Earned Towards Degree
    -- TODO: This looks like it will need another join? Will need clarification on this data field.
-- Total Hours Required for Degree
    c.required_credits AS total_hours_required_for_degree,
-- AP Credits
    a.total_cumulative_ap_credits_earned AS ap_credits,
-- CLEP Credits
    a.total_cumulative_clep_credits_earned,
-- Credits Earned Prior to Full-Time Enrollment
    -- TODO: This looks like it will need another join? Credits earned prior to high school graduation.
-- This Term Code
    -- S1- Fall, S2-Spring
    CASE
        WHEN a1.season = 'Fall' THEN 'S1'
        WHEN a1.season = 'Spring' THEN 'S2'
    END AS this_term_code,
-- Met Cohort Definition
    -- TODO: what does this mean? Translates to boolean of in a team and received athletic aid.
    -- This is on a team and received athletic aid and the NCAA coordinator will change this if it needs to be changed
-- Hours Attempted
    a.institutional_attempted_credits AS hours_attempted,
-- Hours Earned
    a.institutional_earned_credits AS hours_earned,
-- Remedial Hours
    a.total_remedial_hours AS remedial_hours,
-- GPA
    a.overall_gpa AS gpa,
-- Cumulative GPA
    a.overall_cumulative_gpa AS cumulative_gpa,
-- Sport Code
    -- Conversion of stored sport code to NCAA equivalent sport code.
    CASE
        WHEN a.athlete_activity_code = 'BBL' THEN 'MBA'
        WHEN a.athlete_activity_code = 'FTB' THEN 'MFB'
        WHEN a.athlete_activity_code = 'GLF' THEN 'MGO'
        WHEN a.athlete_activity_code = 'GLFW' THEN 'WGO'
        WHEN a.athlete_activity_code = 'MBK' THEN 'MBB'
        WHEN a.athlete_activity_code = 'SOC' THEN 'WSO'
        WHEN a.athlete_activity_code = 'SFB' THEN 'WSB'
        WHEN a.athlete_activity_code = 'SWI' THEN 'WSW'
        WHEN a.athlete_activity_code = 'TEN' THEN 'WTE'
        WHEN a.athlete_activity_code = 'TRK' THEN 'WTO'
        WHEN a.athlete_activity_code = 'VLB' THEN 'WVB'
        WHEN a.athlete_activity_code = 'WBK' THEN 'WBB'
        WHEN a.athlete_activity_code = 'XCM' THEN 'MCC'
        WHEN a.athlete_activity_code = 'XCW' THEN 'WCC'
        ELSE a.athlete_activity_code
    END AS sport_code,
-- Received Athletics Aid
    CASE WHEN a.is_athletic_aid_awarded THEN 'Y'
        ELSE 'N'
    END AS received_athletics_aid,
-- Exhausted Eligibility
    CASE WHEN a.is_exhausted_eligibility THEN 'Y'
        ELSE 'N'
    END AS exhausted_eligibility

FROM export.student_term_level a
LEFT JOIN export.term a1
       ON a1.term_id = a.term_id
LEFT JOIN export.student b
       ON a.student_id = b.student_id
LEFT JOIN export.academic_programs c
       ON c.program_id = a.primary_program_id
-- More info on first registered term
LEFT JOIN export.term d
       ON d.term_id = a.first_registered_term_id

WHERE a.is_athlete
AND a.is_primary_level
AND a.is_degree_seeking
AND a.is_enrolled
AND a1.academic_year_code::INTEGER = (SELECT (a2.academic_year_code::INTEGER - 1) AS previous_academic_year_code
                                      FROM export.term a2
                                      WHERE a2.is_current_term)
AND a1.season IN ('Fall', 'Spring');
