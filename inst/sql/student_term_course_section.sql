SELECT a.student_id AS student_id,
       c.last_name || ', ' || c.first_name AS student_full_name,
       a.term_id AS term_id,
       a.term_desc AS term,
       b.course_id AS course_section_id,
       COALESCE(d.course_desc, 'Unavailable') AS course,

       a.athlete_activity_desc AS student_team,

       COALESCE(c.has_ever_applied_for_graduation, FALSE) AS student_has_ever_applied_for_graduation,
       a.overall_cumulative_gpa AS student_overall_cumulative_gpa,
       (a.institutional_cumulative_credits_earned + a.transfer_cumulative_credits_earned) AS student_overall_cumulative_credits_earned,
       (a.institutional_cumulative_attempted_credits + a.transfer_cumulative_credits_attempted) AS student_overall_cumulative_credits_attempted,
       a.is_degree_seeking AS student_is_degree_seeking,
       p.degree_id AS student_primary_degree,
       p.major_desc AS student_primary_major,
       COALESCE(p.program_desc, 'Unavailable') AS student_program,
       p.required_credits AS student_program_required_credits,
       COALESCE(p.college_abbrv, 'Unavailable') AS student_college,
       COALESCE(p.department_desc, 'Unavailable') AS student_department,
       COALESCE(a.is_graduated_from_primary_degree, FALSE) AS student_has_graduated_with_primary_degree,
       COALESCE(a.is_athletic_aid_awarded, FALSE) AS student_is_athletic_aid_awarded,

       -- student transfer information
       a.transfer_cumulative_credits_earned AS student_cumulative_transfer_credits_earned,
       a.transfer_cumulative_gpa AS student_cumulative_transfer_gpa,

       -- course section information
       b.grade_points AS course_section_grade_points,
       b.final_grade AS course_section_grade,

       -- retention information
       a.is_returned_next_fall,
       a.is_returned_next_spring,

       'All' AS population

FROM export.student_term_level a
LEFT JOIN export.student_section b
       ON a.student_id = b.student_id
      AND a.term_id = b.term_id
LEFT JOIN export.student c
       ON a.student_id = c.student_id
LEFT JOIN export.course d
       ON b.course_id = d.course_id
LEFT JOIN export.student_term_cohort h
       ON h.student_id = a.student_id
      AND h.cohort_start_term_id = a.term_id
LEFT JOIN export.academic_programs p
       ON p.program_id = a.primary_program_id
LEFT JOIN export.term t
       ON a.term_id = t.term_id
-- only pull information for student athletes
WHERE a.is_athlete
-- only pull information from Fall and Spring terms
AND t.season IN ('Fall', 'Spring')
AND a.is_enrolled
AND a.is_primary_level;