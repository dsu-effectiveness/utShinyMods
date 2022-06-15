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
       a.term_id AS term_id,
       b.course_id AS course_section_id,

       -- student information
       COALESCE(a.primary_major_college_desc, 'Unavailable') AS student_college,
       COALESCE(a.primary_program_desc, 'Unavailable') AS student_program,
       c.last_name || ', ' || c.first_name AS student_full_name,
       COALESCE(f.has_accepted_scholarship, FALSE) AS student_has_accepted_scholarship,
       f.scholarship_amount_accepted AS student_scholarship_amount_accepted,
       -- TODO: Need student_team HERE
       -- TODO: Data for this should be in data warehouse.

       -- course section information
       b.grade_points AS course_section_grade_points,
       COALESCE(d.course_desc, 'Unavailable') AS course_section_description

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

-- only pull information for student athletes
WHERE a.is_athlete
AND CAST(a.term_id AS INTEGER) >= 201740;