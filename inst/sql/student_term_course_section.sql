SELECT a.student_id AS student_id,
       c.last_name || ', ' || c.first_name AS student_full_name,
       a.term_id AS term_id,
       a.term_desc AS term,
       b.course_id AS course_section_id,
       COALESCE(d.course_desc, 'Unavailable') AS course,

       -- student team information
       e.activity_desc AS student_team,
       e.eligibility_desc AS student_team_eligibility,
       e.status_desc AS student_team_status,

       -- student demographics
       c.gender_code AS student_gender,
       c.ipeds_race_ethnicity AS student_ipeds_race_ethnicity,

       -- student term based info
       a.overall_cumulative_gpa AS student_overall_cumulative_gpa,
       (a.institutional_cumulative_credits_earned + a.transfer_cumulative_credits_earned) AS student_overall_cumulative_credits_earned,
       (a.institutional_cumulative_attempted_credits + a.transfer_cumulative_credits_attempted) AS student_overall_cumulative_credits_attempted,
       a.is_degree_seeking AS student_is_degree_seeking,
       a.primary_degree_id AS student_primary_degree,
       a.primary_major_desc AS student_primary_major,
       COALESCE(a.primary_program_desc, 'Unavailable') AS student_program,
       COALESCE(a.primary_major_college_desc, 'Unavailable') AS student_college,
       COALESCE(a.primary_major_department_desc, 'Unavailable') AS student_department,
       COALESCE(a.is_graduated_from_primary_degree, FALSE) AS student_has_graduated_with_primary_degree,
       COALESCE( (h.is_exclusion = 'true'), FALSE) AS student_is_exclusion,
       h.exclusions_reason_desc AS student_exclusion_reason,
       COALESCE(f.has_accepted_scholarship, FALSE) AS student_has_accepted_scholarship,
       COALESCE(g.has_ever_applied_for_graduation, FALSE) AS student_has_ever_applied_for_graduation,

       -- student transfer information
       a.transfer_cumulative_credits_earned AS student_cumulative_transfer_credits_earned,
       a.transfer_cumulative_gpa AS student_cumulative_transfer_gpa,

       -- course section information
       b.grade_points AS course_section_grade_points,
       b.final_grade AS course_section_grade

       /*
       TODO: add these data fields
       student_degree_required_hours

       student_total_remedial_credit_hours
       student_has_accepted_athletic_scholarship

       student_first_term_full_time_ever
       student_first_year_full_time_ever
       student_first_term_full_time_at_local_institution
       student_first_year_full_time_at_local_institution

       student_total_transfer_english_credits
       student_total_transfer_math_credits
       student_total_transfer_science_credits
       student_has_transfer_associate_degree
       student_has_transfer_bachelor_degree

       student_transfer_institution_name
       student_transfer_institution_type
       student_transfer_institution_date_attended_to
       */

FROM export.student_term_level a
LEFT JOIN export.student_section b
       ON a.student_id = b.student_id
      AND a.term_id = b.term_id
LEFT JOIN export.student c
       ON a.student_id = c.student_id
LEFT JOIN export.course d
       ON b.course_id = d.course_id

/* BEGIN Athletic Scholarship SQL logic  */
-- TODO: this SQL logic should be in data warehouse
LEFT JOIN (SELECT DISTINCT f1.student_id,
                   f1.term_id,
                   SUM(f1.amount_accepted) AS scholarship_amount_accepted,
                   TRUE AS has_accepted_scholarship
            FROM export.student_financial_aid_year_fund_term_detail f1
            -- Student has accepted the scholarship.
            WHERE f1.amount_accepted > 0
            -- The type of fund is a scholarship.
            AND f1.is_scholarship
            GROUP BY f1.student_id, f1.term_id) f
    ON a.student_id = f.student_id
    AND a.term_id = f.term_id
/* END Athletic Scholarship SQL logic  */

/* BEGIN Applied for Graduation SQL logic  */
-- TODO: this SQL logic should be in data warehouse
LEFT JOIN (SELECT g1.student_id,
                  TRUE AS has_ever_applied_for_graduation
            FROM export.degrees_awarded g1
            -- A status of "Pending" is synonymous with "Applied", in this context.
            WHERE g1.degree_status_desc = 'Pending'
            GROUP BY g1.student_id) g
    ON a.student_id = g.student_id
/* END Applied for Graduation SQL logic SQL logic  */

LEFT JOIN export.student_extracurricular_activity e
       ON a.student_id = e.student_id
      AND a.term_id = e.term_id
      AND e.activity_type_desc = 'Sports'

LEFT JOIN export.student_term_cohort h
       ON h.student_id = a.student_id
      AND h.term_id = a.term_id

LEFT JOIN export.term t
       ON a.term_id = t.term_id

-- only pull information for student athletes
WHERE a.is_athlete
-- only pull information from Fall and Spring terms
AND t.season IN ('Fall', 'Spring');