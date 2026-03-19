--7.3E Write an SQL query that retrieves all pairs of suppliers who supply the same product, along with their product purchase price if applicable.
SELECT S.SUPNR, S.PRODNR, S.PURCHASE_PRICE, S2.SUPNR, S2.PRODNR
FROM SUPPLIES S, SUPPLIES S2
WHERE S.PRODNR = S2.PRODNR
    AND S.SUPNR < S2.SUPNR

--7.7E Write a correlated SQL query to retrieve all cities with more than one supplier.
SELECT DISTINCT R.SUPCITY
FROM SUPPLIER R
WHERE R.SUPCITY IN
    (SELECT R2.SUPCITY
    FROM SUPPLIER R2
    WHERE R.SUPCITY <> R2.SUPCITY)

--7.9E Write an SQL query using EXISTS to retrieve the supplier numbers and names of all suppliers that do not have any outstanding orders.
SELECT SUPNR, SUPNAME
FROM SUPPLIER S
WHERE NOT EXISTS (
    SELECT 1
    FROM ORDERS O
    WHERE O.SUPNR = S.SUPNR AND O.STATUS = 'Outstanding'
    )

--7.16E Write a correlated SQL query to retrieve the three lowest product numbers.
SELECT PRODNR
FROM PRODUCT P1
WHERE 3 > (
    SELECT COUNT(DISTINCT P2.PRODNR)
    FROM PRODUCT P2
    WHERE P2.PRODNR < P1.PRODNR
    )
ORDER BY PRODNR ASC;

--7.18E Write an SQL query using EXISTS to retrieve the supplier name and number of the supplier who has the lowest supplier number.
SELECT R.SUPNR, R.SUPNAME
FROM SUPPLIER R
WHERE NOT EXISTS (
    SELECT R2.SUPNR, R2.SUPNAME
    FROM SUPPLIER R2
    WHERE R.SUPNR < R2.SUPNR
    )

--Problem 2. Answer 2.1-2.3 using university schema below.
--2.1 Write the following queries in SQL, using the university schema.
--a. Find the titles of courses in the Comp. Sci. department that have 3 credits.
SELECT title
FROM course
WHERE dept_name = 'Comp. Sci.' AND credits = 3

--b. Find the IDs of all students who were taught by an instructor named Einstein; make sure there are no duplicates in the result.
SELECT DISTINCT S.ID
FROM takes S, teaches I
WHERE S.COURSE_ID = I.COURSE_ID AND I.name = 'Einstein'

--c. Find the highest salary of any instructor.
SELECT max(salary)
FROM instructor

--d. Find all instructors earning the highest salary (there may be more than one with the same salary).
SELECT *
FROM instructor
WHERE salary = ( 
    SELECT max(salary) FROM instructor 
    )

--e. Find the enrollment of each section that was offered in Autumn 2009.
SELECT T.sec_id. T.course_id, (
    SELECT COUNT(T.ID)
    FROM takes T
    WHERE T.course_id = S.course_id
        AND T.sec_id = S.sec_id
        AND T.semester = S.semester
        AND T.year = S.year
        ) AS enrollment
FROM section S
WHERE S.semester = 'Autumn' AND S.year = '2009'

--f. Find the maximum enrollment, across all sections, in Autumn 2009.
SELECT MAX(enrollment) AS max_enrollment
FROM (
    SELECT COUNT(*) AS enrollment
    FROM takes T, section S
    WHERE T.course_id = S.course_id
        AND T.sec_id = S.sec_id
        AND S.semester = 'Autumn'
        AND S.year = 2009
    GROUP BY S.course_id, S.sec_id
) AS enrollments;

--g. Find the sections that had the maximum enrollment in Autumn 2009.
SELECT S.sec_id, S.course_id
FROM section S
WHERE S.semester = 'Autumn' AND S.year = 2009
GROUP BY S.sec_id, S.course_id
HAVING COUNT(*) = (
    SELECT MAX(enrollment)
    FROM (
        SELECT COUNT(*) AS enrollment
        FROM takes T, section S
        WHERE T.course_id = S.course_id
            AND T.sec_id = S.sec_id
            AND S.semester = 'Autumn'
            AND S.year = 2009
        GROUP BY S.course_id, S.sec_id
    ) AS enrollments
)

/* 2.2 Suppose you are given a relation grade.points (grade, points), which provides a conversion from letter grades in the takes relation to numeric scores; for example an “A”
grade could be specified to correspond to 4 points, an “A−” to 3.7 points, a “B+” to 3.3 points, a “B” to 3 points, and so on. The grade points earned by a student for a course offering
(section) is defined as the number of credits for the course multiplied by the numeric points for the grade that the student received. Given the above relation, and our university schema,
write each of the following queries in SQL. You can assume for simplicity that no takes tuple has the null value for grade. */
--a. Find the total grade-points earned by the student with ID 12345, across all courses taken by the student.
SELECT SUM(c.credits * g.points) AS total_grade_points
FROM takes t
JOIN course c ON t.course_id = c.course_id
JOIN grade_points g ON t.grade = g.grade
WHERE t.ID = 12345;

--b. Find the grade-point average (GPA) for the above student, that is, the total grade-points divided by the total credits for the associated courses.
SELECT SUM (c.credits * g.points) / SUM(c.credits) AS GPA
FROM takes t
JOIN course c ON t.course_id = c.course_id
JOIN grade_points g ON t.grade = g.grade
WHERE t.ID = 12345;

--c. Find the ID and the grade-point average of every student.
SELECT t.ID, SUM(c.credits * g.points) / SUM(c.credits) AS GPA
FROM takes t
JOIN course c ON t.course_id = c.course_id
JOIN grade_points g ON t.grade = g.grade
GROUP BY t.ID;

--2.3 Write the following inserts, deletes or updates in SQL, using the university schema.
--a. Increase the salary of each instructor in the Comp. Sci. department by 10%.
UPDATE instructor
SET salary = salary * 1.10
WHERE dept_name = 'Comp. Sci.';

--b. Delete all courses that have never been offered (that is, do not occur in the section relation).
DELETE FROM course
WHERE course_id NOT IN (SELECT course_id FROM section);

--c. Insert every student whose tot_cred attribute is greater than 100 as an instructor in the same department, with a salary of $10,000.
INSERT INTO instructor (ID, name, dept_name, salary)
SELECT ID, name, dept_name, 10000
FROM student
WHERE tot_cred > 100;

/* Problem 3. Suppose that we have a relation marks(ID, score) and we wish to assign grades to students based on the score as follows: 
grade F if score < 40, grade C if 40 ≤ score < 60, grade B if 60 ≤ score < 80, and grade A if 80 ≤ score. Write SQL queries to do the following: */
--a. Display the grade for each student, based on the marks relation. (use case statement)
SELECT ID,
case
    when score < 40 then 'F'
    when score < 60 then 'C'
    when score < 80 then 'B'
    else 'A'
end
FROM marks

--b. Find the number of students with each grade.
SELECT (
case
    when score < 40 then 'F'
    when score < 60 then 'C'
    when score < 80 then 'B'
    else 'A'
end as grade), COUNT(ID)
FROM marks
GROUP BY grade

/*bProblem 4. Consider the insurance database of Figure 4, where the primary keys are
underlined. Construct the following SQL queries for this relational database. */
--a. Find the total number of people who owned cars that were involved in accidents in 1989.
SELECT COUNT(DISTINCT p.driver_id)
FROM person P, accident A, participated PAR
WHERE A.report_number = PAR.report_number
    AND P.driver_id = PAR.driver_id
    AND A.date BETWEEN DATE '1989-01-01' AND DATE '1989-12-31'

--b. Add a new accident to the database, considering all relative tables; assume any values for required attributes.
INSERT INTO accident
VALUES ('A734342', '2024-07-29', '8th St and 14th Ave, San Francisco')

--c. Delete the Mazda belonging to “John Smith.”
DELETE car
WHERE model = 'Mazda' AND license IN ( 
    SELECT P.license
    FROM person P, owns O
    WHERE P.driver_id = O.driver_id AND P.name = 'John Smith'
    )

/* Problem 5. Consider the bank database of Figure 5, where the primary keys are underlined. Construct the following SQL queries for this relational database. */
--a. Find all customers of the bank who have an account but not a loan. (use except statement)
SELECT customer_name
FROM depositor
EXCEPT
SELECT customer_name
FROM borrower

--b. Find the names of all customers who live on the same street and in the same city as “Smith”.
SELECT customer_name
FROM customer
WHERE customer_street = (
    SELECT customer_street
    FROM customer
    WHERE customer_name = 'Smith'
)
AND customer_city = (
    SELECT customer_city
    FROM customer
    WHERE customer_name = 'Smith'
)

--c. Find the names of all branches with customers who have an account in the bank and who live in “Harrison”.
SELECT DISTINCT A.branch_name
FROM account A, depositor D, customer C
WHERE A.account_number = D.account_number
    AND D.customer_name =C.customer_name
    AND C.customer_city = 'Harrison'

--Problem 6. Answer 6.1-6.2 using Employee database
--6.1 Consider the employee database of Figure 6, where the primary keys are underlined. Give an expression in SQL for each of the following queries.
--a. Find the names and cities of residence of all employees who work for First Bank Corporation.
SELECT e.employee_name, e.city
FROM employee
JOIN works w ON e.employee_name = w.employee_name
WHERE w.company_name = 'First Bank Corporation';

--b. Find the names, street addresses, and cities of residence of all employees who work for First Bank Corporation and earn more than $10,000.
SELECT e.employee_name, e.street, e.city
FROM employee e
JOIN works w ON e.employee_name = w.employee_name
WHERE w.company_name = 'First Bank Corporation'
    AND w.salary > 10000;

--c. Find all employees in the database who do not work for First Bank Corporation. d. Find all employees in the database who earn more than each employee of Small Bank Corporation.
SELECT e.employee_name
FROM employee e
WHERE e.employee_name NOT IN (
    SELECT w.employee_name
    FROM works w
    WHERE w.company_name = 'First Bank Corporation'
);

--d. Find all employees in the database who earn more than each employee of Small Bank Corporation.
SELECT e.employee_name
FROM employee e
WHERE e.employee_name IN (
    SELECT w1.employee_name
    FROM works w1
    WHERE w1.salary > ALL (
        SELECT w2.salary
        FROM works w2
        WHERE w2.company_name = 'Small Bank Corporation'
    )
);

--e. Assume that the companies may be located in several cities. Find all companies located in every city in which Small Bank Corporation is located.
SELECT DISTINCT c1.company_name
FROM company c1
WHERE NOT EXISTS (
    SELECT c2.city
    FROM company c2
    WHERE c2.company_name = 'Small Bank Corporation'
        AND NOT EXISTS (
            SELECT c3.city
            FROM company c3
            WHERE c3.company_name = c1.company_name
                AND c3.city = c2.city
        )
);

--f. Find the company that has the most employees.
SELECT w.company_name
FROM works w
GROUP BY w.company_name
ORDER BY COUNT(w.employee_name) DESC
LIMIT 1;

--g. Find those companies whose employees earn a higher salary, on average, than the average salary at First Bank Corporation.
SELECT w.company_name
FROM works w
GROUP BY w.company_name
HAVING AVG(w.salary) > (
    SELECT AVG(w2.salary)
    FROM works w2
    WHERE w2.company_name = 'First Bank Corporation'
);

--6.2 Consider the relational database of Figure 6. Give an expression in SQL for each of the following queries.
--a. Modify the database so that Jones now lives in Newtown.
UPDATE employee
SET city = 'Newtown'
WHERE employee_name = 'Jones';

--b. Give all managers of First Bank Corporation a 10 percent raise unless the salary becomes greater than $100,000; in such cases, give only a 3 percent raise. (use case statement)
UPDATE works
SET salary = CASE
    WHEN salary * 1.10 > 100000 THEN salary * 1.03
    ELSE salary * 1.10
END
WHERE company_name = 'First Bank Corporation'
    AND employee_name IN (
        SELECT manager_name
        FROM manages
    );