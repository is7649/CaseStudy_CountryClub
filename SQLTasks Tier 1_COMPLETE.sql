/* Welcome to the SQL mini project. You will carry out this project partly in
the PHPMyAdmin interface, and partly in Jupyter via a Python connection.

This is Tier 1 of the case study, which means that there'll be more guidance for you about how to 
setup your local SQLite connection in PART 2 of the case study. 

The questions in the case study are exactly the same as with Tier 2. 

PART 1: PHPMyAdmin
You will complete questions 1-9 below in the PHPMyAdmin interface. 
Log in by pasting the following URL into your browser, and
using the following Username and Password:

URL: https://sql.springboard.com/
Username: student
Password: learn_sql@springboard

The data you need is in the "country_club" database. This database
contains 3 tables:
    i) the "Bookings" table,
    ii) the "Facilities" table, and
    iii) the "Members" table.

In this case study, you'll be asked a series of questions. You can
solve them using the platform, but for the final deliverable,
paste the code for each solution into this script, and upload it
to your GitHub.

Before starting with the questions, feel free to take your time,
exploring the data, and getting acquainted with the 3 tables. */


/* QUESTIONS 
/* Q1: Some of the facilities charge a fee to members, but some do not.
Write a SQL query to produce a list of the names of the facilities that do. */
SELECT * FROM `Facilities` WHERE `membercost` =0;
/*The facilities that do not charge a fee to members are Badminton Court, Table Tennis, Snooker Table, and Pool Table.  */


/* Q2: How many facilities do not charge a fee to members? */
SELECT COUNT(*) FROM `Facilities` WHERE `membercost` =0;
/*There are 4 facilities that do not charge a fee to member. */


/* Q3: Write an SQL query to show a list of facilities that charge a fee to members,
where the fee is less than 20% of the facility's monthly maintenance cost.
Return the facid, facility name, member cost, and monthly maintenance of the
facilities in question. */
SELECT facid, name, membercost, monthlymaintenance FROM `Facilities` WHERE membercost/monthlymaintenance < 0.2;


/* Q4: Write an SQL query to retrieve the details of facilities with ID 1 and 5.
Try writing the query without using the OR operator. */
SELECT * FROM `Facilities` WHERE facid IN (1,5);


/* Q5: Produce a list of facilities, with each labelled as
'cheap' or 'expensive', depending on if their monthly maintenance cost is
more than $100. Return the name and monthly maintenance of the facilities
in question. */
SELECT * FROM `Facilities` WHERE expense_label IN ('expensive','cheap') AND monthlymaintenance >100;


/* Q6: You'd like to get the first and last name of the last member(s)
who signed up. Try not to use the LIMIT clause for your solution. */
SELECT * FROM `Members` WHERE joindate = (SELECT MAX(joindate) FROM Members);


/* Q7: Produce a list of all members who have used a tennis court.
Include in your output the name of the court, and the name of the member
formatted as a single column. Ensure no duplicate data, and order by
the member name. */
SELECT concat(firstname, ' ',surname) AS 'Name', facid AS 'Tennis Court' FROM `Members` LEFT JOIN `Bookings` ON Members.memid = Bookings.memid WHERE facid IN (1,2) GROUP BY Name ORDER BY Name;


/* Q8: Produce a list of bookings on the day of 2012-09-14 which
will cost the member (or guest) more than $30. Remember that guests have
different costs to members (the listed costs are per half-hour 'slot'), and
the guest user's ID is always 0. Include in your output the name of the
facility, the name of the member formatted as a single column, and the cost.
Order by descending cost, and do not use any subqueries. */

SELECT concat(firstname, ' ',surname) AS 'Name', Facilities.name AS 'Facility Name', CASE Bookings.memid WHEN '0' THEN slots * guestcost ELSE slots * membercost END Cost
FROM Bookings
INNER JOIN Members ON Bookings.memid = Members.memid 
INNER JOIN Facilities ON Bookings.facid = Facilities.facid
WHERE starttime LIKE '2012-09-1%' AND (((slots *membercost) >30 AND Bookings.memid >0) OR ((slots*guestcost)>30 AND Bookings.memid =0))
ORDER BY Cost DESC;


/* Q9: This time, produce the same result as in Q8, but using a subquery. */
SELECT (SELECT concat(firstname, ' ',surname) FROM Members WHERE Bookings.memid = Members.memid) AS 'Name', (SELECT Facilities.name FROM Facilities WHERE Bookings.facid = Facilities.facid) AS 'Facility Name', CASE Bookings.memid WHEN '0' THEN slots * guestcost ELSE slots * membercost END Cost
FROM Bookings
LEFT JOIN Facilities
ON Bookings.facid = Facilities.facid
WHERE starttime LIKE '2012-09-1%' AND (((slots *membercost) >30 AND Bookings.memid >0) OR ((slots*guestcost)>30 AND Bookings.memid =0))
ORDER BY Cost DESC;

/* PART 2: SQLite
/* We now want you to jump over to a local instance of the database on your machine. 

Copy and paste the LocalSQLConnection.py script into an empty Jupyter notebook, and run it. 

Make sure that the SQLFiles folder containing thes files is in your working directory, and
that you haven't changed the name of the .db file from 'sqlite\db\pythonsqlite'.

You should see the output from the initial query 'SELECT * FROM FACILITIES'.

Complete the remaining tasks in the Jupyter interface. If you struggle, feel free to go back
to the PHPMyAdmin interface as and when you need to. 

You'll need to paste your query into value of the 'query1' variable and run the code block again to get an output.
 
QUESTIONS:
/* Q10: Produce a list of facilities with a total revenue less than 1000.
The output of facility name and total revenue, sorted by revenue. Remember
that there's a different cost for guests and members! */
SELECT * FROM
(SELECT name, membercost, guestcost, slots, memid, SUM(CASE WHEN Bookings.memid ='0' THEN slots * guestcost ELSE slots * membercost END) AS 'TotalRevenue'
FROM Facilities
INNER JOIN Bookings
ON Facilities.facid = Bookings.facid
GROUP BY name) AS x
WHERE TotalRevenue < 1000;


/* Q11: Produce a report of members and who recommended them in alphabetic surname,firstname order */
SELECT
    concat(Members.surname, ' ',
        Members.firstname) AS Name,
        CASE WHEN manager.firstname = 'GUEST' THEN '' ELSE concat(manager.firstname, ' ', manager.surname) END as RecommendedBy
FROM Members 
JOIN Members manager
ON Members.recommendedby = manager.memid
ORDER BY Name;

/* Q12: Find the facilities with their usage by member, but not guests */
SELECT concat(Members.surname, ' ',
        Members.firstname) AS Name, Facilities.name AS Facility, SUM(slots) AS Bookings 
FROM Bookings
INNER JOIN Facilities
ON Bookings.facid = Facilities.facid
INNER JOIN Members
ON Bookings.memid = Members.memid
WHERE Bookings.memid <> 0 
GROUP BY Bookings.memid
ORDER BY Bookings DESC;

/* Q12 A: number of rows bookid - (9)
SELECT COUNT(*) AS RowCount FROM (
SELECT Facilities.name AS Facility, SUM(slots) AS Bookings
FROM Bookings
INNER JOIN Facilities
ON Bookings.facid = Facilities.facid
INNER JOIN Members
ON Bookings.memid = Members.memid
WHERE Bookings.memid <> 0
GROUP BY Facility
ORDER BY Bookings DESC
) t */

/* Q12 B: number of rows for NO MEMID (9) */
SELECT COUNT(*) AS RowCount FROM (
SELECT Facilities.name AS Facility, Bookings.memid AS MemberId, SUM(slots) AS Bookings
FROM Bookings
INNER JOIN Facilities
ON Bookings.facid = Facilities.facid
INNER JOIN Members
ON Bookings.memid = Members.memid
WHERE Bookings.memid <> 0
GROUP BY Facility
ORDER BY Bookings DESC
) t */




/* Q13: Find the facilities usage by month, but not guests */
SELECT Facilities.name AS Facility, SUM(slots) AS Bookings, CASE WHEN SUBSTRING(starttime, 6,2) = '08' THEN 'AUGUST' WHEN SUBSTRING(starttime, 6,2) = '09' THEN 'SEPTEMBER' WHEN SUBSTRING(starttime, 6,2) = '10' THEN 'OCTOBER' WHEN SUBSTRING(starttime, 6,2) = '11' THEN 'NOVEMBER' WHEN SUBSTRING(starttime, 6,2) = '12' THEN 'DECEMBER' WHEN SUBSTRING(starttime, 6,2) = '01' THEN 'JANUARY' WHEN SUBSTRING(starttime, 6,2) = '02' THEN 'FEBRUARY' WHEN SUBSTRING(starttime, 6,2) = '03' THEN 'MARCH'  WHEN SUBSTRING(starttime, 6,2) = '04' THEN 'APRIL' WHEN SUBSTRING(starttime, 6,2) = '05' THEN 'MAY' WHEN SUBSTRING(starttime, 6,2) = '06' THEN 'JUNE' WHEN SUBSTRING(starttime, 6,2) = '07' THEN 'JULY' ELSE SUBSTRING(starttime, 6,2) END AS Month
FROM Bookings
INNER JOIN Facilities
ON Bookings.facid = Facilities.facid
INNER JOIN Members
ON Bookings.memid = Members.memid
WHERE Bookings.memid <> 0 
GROUP BY Month, Facility
ORDER BY Month;
