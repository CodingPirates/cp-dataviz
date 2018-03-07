-- TODO
--   - Create table of parents of current members (including number of kids and "is volunteer" flag)
--   - Create table of volunteers (but are non-active volunteers ever removed?)


-- All months where there have been CP activities
CREATE VIEW dataviz_months_with_activity AS
WITH RECURSIVE dates(x) AS ( 
            SELECT '2014-03-01' 
                UNION ALL 
            SELECT DATE(x, '+1 MONTHS')
              FROM dates
              WHERE x < date('now'))
    SELECT x as month
    FROM dates;

-- Simplified zipcode/city/region table with only one row per zipcode
-- Selects a random region in zipcodes spanning several regions
CREATE VIEW dataviz_zipcoderegion AS
    SELECT zipcode,
           city,
           region
      FROM members_zipcoderegion
     GROUP BY zipcode,
              city;

-- Child members, with as much information about each kid as possible
CREATE TABLE dataviz_members AS
    SELECT p.id,
           p.birthday,
           p.gender,
           p.zipcode,
           p.added,
           m.member_since,
           zr.city,
           zr.region,
           -- SUM(pay.amount_ore) AS paid_this_year_in_oere,
           d.id AS chapter_id,
           d.name AS chapter_name,
           d.zipcode AS chapter_zipcode,
           d.latitude AS chapter_latitude,
           d.longtitude AS chapter_longitude,
           u.id AS union_id,
           u.name AS union_name,
           MAX(a.end_date) AS last_activity,
           COUNT(DISTINCT a.id) AS num_activities
      FROM members_person AS p
           JOIN dataviz_zipcoderegion AS zr ON zr.zipcode = p.zipcode
           -- JOIN members_payment AS pay ON pay.person_id = p.id
           JOIN members_member AS m ON m.person_id = p.id
           JOIN members_department AS d ON d.id = m.department_id
           JOIN members_union AS u ON u.id = d.union_id
           LEFT JOIN members_activityparticipant AS ap ON ap.member_id = m.id
           LEFT JOIN members_activity AS a ON a.id = ap.activity_id
     WHERE p.membertype = 'CH'
     -- AND pay.refunded_dtm IS NULL
     -- AND pay.added > date('now', 'start of year')
     GROUP BY p.id, d.id;
;
-- Aggregate number of kids of similar age/gender/city/department on a monthly basis
CREATE TABLE dataviz_members_grouped AS
    SELECT COUNT(id) AS antal,
           month as timeperiod,
           CAST ( ( (julianday(month) - julianday(birthday) ) / 365.25) AS INT) AS age,
           city,
           region,
           gender,
           chapter_name,
           chapter_latitude,
           chapter_longitude,
           union_name,
           num_activities
      FROM dataviz_members
           LEFT JOIN dataviz_months_with_activity
     WHERE (member_since < month AND ( (last_activity IS NULL) OR last_activity > month) )
     GROUP BY chapter_name,
              gender,
              month,
              age,
              city,
              num_activities
              ;
  -- ORDER BY month, age;


CREATE TABLE dataviz_waitinglist AS
    SELECT p.id,
           p.birthday,
           p.gender,
           p.zipcode,
           p.added,
           zr.city,
           zr.region,
           d.id AS chapter_id,
           d.name AS chapter_name,
           d.zipcode AS chapter_zipcode,
           d.latitude AS chapter_latitude,
           d.longtitude AS chapter_longitude,
           u.id AS union_id,
           u.name AS union_name
      FROM members_person AS p
           JOIN dataviz_zipcoderegion AS zr ON zr.zipcode = p.zipcode
           JOIN members_waitinglist AS w ON w.person_id = p.id
           JOIN members_department AS d ON d.id = w.department_id
           JOIN members_union AS u ON u.id = d.union_id
     WHERE p.membertype = 'CH'
     GROUP BY p.id, d.id;
