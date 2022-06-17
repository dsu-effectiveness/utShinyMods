/* SQL to pull the following information:
- student_id
- term_id
- course_section_id
- student_has_scholarship
- student_team
- student_college
- student_program
- student_full_name
- course_section_grade_points
- course_section_description

With the following filter:
WHERE is_student_athlete

This filter will reduce the amount of data pulled, greatly.
*/
SELECT a.student_id AS student_id,
       c.last_name || ', ' || c.first_name AS student_full_name,
       a.term_id AS term_id,
       a.term_desc AS term,
       b.course_id AS course_section_id,
       COALESCE(d.course_desc, 'Unavailable') AS course,

       -- student information
       a.overall_cumulative_gpa AS student_overall_cumulative_gpa,
       (a.institutional_cumulative_credits_earned + a.transfer_cumulative_credits_earned) AS student_overall_cumulative_credits_earned,
       COALESCE(a.primary_major_college_desc, 'Unavailable') AS student_college,
       COALESCE(a.primary_program_desc, 'Unavailable') AS student_program,
       COALESCE(f.has_accepted_scholarship, FALSE) AS student_has_accepted_scholarship,
       f.scholarship_amount_accepted AS student_scholarship_amount_accepted,
       e.activity_desc AS student_team,
       COALESCE(g.has_ever_applied_for_graduation, FALSE) AS student_has_ever_applied_for_graduation,

       -- course section information
       b.grade_points AS course_section_grade_points,
       b.final_grade AS course_section_grade

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

-- only pull information for student athletes
WHERE a.is_athlete;