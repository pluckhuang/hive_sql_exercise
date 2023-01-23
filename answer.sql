-- Student(s_id,s_name,s_birth,s_sex) 学生编号, 学生姓名, 出生年月, 学生性别
-- Course(c_id,c_name,t_id) 课程编号, 课程名称, 教师编号
-- Teacher(t_id,t_name) 教师编号, 教师姓名
-- Score(s_id,c_id,s_score) 学生编号, 课程编号, 分数
-- create database if not exists exercise;
-- use exercise;

-- answer:

1.
select
    t.s_id,
    st.s_name,
    t.score1,
    t.score2
from
(SELECT s.s_id,
       sc1.s_score as score1,
       sc2.s_score as score2
FROM student s
inner JOIN
  (SELECT s_id,
          c_id,
          s_score
   FROM score
   WHERE c_id="01") sc1 ON s.s_id=sc1.s_id
inner JOIN
  (SELECT s_id,
          c_id,
          s_score
   FROM score
   WHERE c_id="02") sc2 ON s.s_id=sc2.s_id
WHERE sc1.s_score > sc2.s_score
) t
left join student st on t.s_id=st.s_id;


2.
select
    t.s_id,
    st.s_name,
    t.score1,
    t.score2
from
(SELECT s.s_id,
       sc1.s_score as score1,
       sc2.s_score as score2
FROM student s
inner JOIN
  (SELECT s_id,
          c_id,
          s_score
   FROM score
   WHERE c_id="01") sc1 ON s.s_id=sc1.s_id
inner JOIN
  (SELECT s_id,
          c_id,
          s_score
   FROM score
   WHERE c_id="02") sc2 ON s.s_id=sc2.s_id
WHERE sc1.s_score < sc2.s_score
) t
left join student st on t.s_id=st.s_id;


# !connect jdbc:hive2://bigdata03:10000 hadoop 123456

3.
SELECT t.s_id,
       st.s_name,
       round(t.avg_score, 2) as score
   FROM
     (SELECT s_id, avg(s_score) as avg_score
      FROM score
      GROUP BY s_id
      HAVING avg_score >= 60) t
LEFT JOIN student st
ON t.s_id=st.s_id;



4.
SELECT st.s_id,
       st.s_name,
       round(t.avg_score, 2) AS score
FROM
  (SELECT s_id,
          avg(s_score) AS avg_score
   FROM score
   GROUP BY s_id
   HAVING avg_score < 60)t
LEFT JOIN student st ON t.s_id=st.s_id
UNION
SELECT st.s_id,
       st.s_name,
       0 AS score
FROM student st
WHERE s_id not in
    (SELECT distinct(s_id)
     FROM score);


5.
SELECT st.s_id,
       st.s_name,
       ts.total_score,
       tc.total_course
FROM student AS st
LEFT JOIN
  (SELECT s_id,
          sum(s_score) AS total_score
   FROM score
   GROUP BY s_id) ts ON st.s_id=ts.s_id
LEFT JOIN
  (SELECT s_id,
          count(c_id) AS total_course
   FROM score
   GROUP BY s_id) tc ON st.s_id=tc.s_id;

6
select count(t_id) from `teacher` where t_name like "李%";

7

SELECT ss.s_id,
       s.s_name
FROM
  (SELECT distinct(s_id)
   FROM score AS sc
   LEFT JOIN
     (SELECT c_id
      FROM course AS c
      LEFT JOIN
        (SELECT t_id
         FROM `teacher`
         WHERE t_name = "张三") t ON t.t_id = c.t_id) cc ON sc.c_id=cc.c_id) ss
LEFT JOIN student s ON s.s_id=ss.s_id;


8

select s.s_id, st.s_name from (
select s2.s_id from score as s1 where c_id == "01"
left join
select s_id from score where c_id == "02" as s2
on s1.s_id=s2.s_id
) as s
left join student as st on s.s_id=st.s_id;



9.
SELECT s.s_id,
       st.s_name
FROM
  (SELECT s1.s_id
   FROM
     (SELECT s_id
      FROM score
      WHERE c_id == "01" ) s1
   INNER JOIN
     (SELECT s_id
      FROM score
      WHERE c_id == "02") s2 ON s1.s_id=s2.s_id) AS s
LEFT JOIN student AS st ON s.s_id=st.s_id;

10.
SELECT s.s_id,
       st.s_name
FROM
  (SELECT s1.s_id
   FROM
     (SELECT s_id
      FROM score
      WHERE c_id == "01" ) s1
   LEFT JOIN
     (SELECT s_id
      FROM score
      WHERE c_id == "02") s2 ON s1.s_id=s2.s_id
    Where s2.s_id is NULL
      ) AS s
LEFT JOIN student AS st ON s.s_id=st.s_id;


11.
SELECT s.s_id,
       st.s_name
FROM
  (SELECT s_id
   FROM score
   GROUP BY s_id
   HAVING count(s_id) !=
     (SELECT count(c_id) AS c_count
      FROM course)) AS s
LEFT JOIN student AS st ON s.s_id=st.s_id;


12.
SELECT s.s_id,
       st.s_name
FROM
  (SELECT distinct(s_id)
   FROM score
   WHERE c_id in
       (SELECT c_id
        FROM score
        WHERE s_id == "01")
     AND s_id != "01" ) AS s
LEFT JOIN student AS st ON s.s_id=st.s_id;


13.
SELECT s.s_id,
       st.s_name
FROM
  (SELECT s_id
   FROM
     (SELECT s_id,
             CONCAT_WS(",", COLLECT_SET(c_id)) AS c_all_base
      FROM score
      GROUP BY s_id) t1
   WHERE t1.c_all_base ==
       (SELECT CONCAT_WS(",", COLLECT_SET(c_id)) AS c_01_base
        FROM score
        WHERE s_id == "01")
     AND t1.s_id != "01") AS s
LEFT JOIN student AS st ON s.s_id=st.s_id;


14.
SELECT s.s_id,
       st.s_name
FROM
  (SELECT distinct(s_id)
   FROM score
   WHERE c_id not in
       (SELECT c_id
        FROM course
        WHERE t_id ==
            (SELECT t_id
             FROM `teacher`
             WHERE t_name = "张三"))) AS s
LEFT JOIN student AS st ON s.s_id=st.s_id;

15.
SELECT s.s_id,
       st.s_name,
       s_a.s_avg
FROM
  (SELECT t.s_id AS s_id
   FROM
     (SELECT s_id,
             count(s_id) AS count_sid
      FROM score
      WHERE s_score < 60
      GROUP BY s_id) t
   WHERE t.count_sid >=2) AS s
LEFT JOIN student AS st ON s.s_id=st.s_id
LEFT JOIN
  (SELECT s_id,
          avg(s_score) AS s_avg
   FROM score
   GROUP BY s_id) AS s_a ON s_a.s_id=s.s_id;