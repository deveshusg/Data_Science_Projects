use db_course_conversions;
## Student Info- Understanding data:-
select * from student_info; ##40979
select * from student_info order by student_id asc; ##40979
select distinct student_id from student_info; ##40979


## First Engagement of each student-Understanding data:-
select * from student_engagement ; ##74246 
select distinct student_id from student_engagement; ## 20778 
select * from (select * ,row_number() over(partition by student_id order by date_watched asc) as row_num from student_engagement) as subquery where row_num = 1; ##20778



## intersection of Student Info and First Engagement of each student:-
select i.student_id, i.date_registered, s.date_watched as first_date_watched, datediff(s.date_watched,i.date_registered) as days_diff_reg_watch from student_info i 
join (select * from (select * ,row_number() over(partition by student_id order by date_watched asc) as row_num from student_engagement) as subquery where row_num = 1) as s on s.student_id=i.student_id;  ##20778



## Student Purchase table:-Understanding data:-
select * from student_purchases;
select distinct student_id from student_purchases;
select * from (select * ,row_number() over(partition by student_id order by date_purchased asc) as row_num from student_purchases) as subquery where row_num = 1;


## Querying result set ##20255
select i.student_id, i.date_registered, s.date_watched as first_date_watched, datediff(s.date_watched,i.date_registered) as days_diff_reg_watch, p.date_purchased as first_date_purchased, datediff(p.date_purchased,s.date_watched) as days_diff_watch_purch 
from student_info i 
join (select * from (select * ,row_number() over(partition by student_id order by date_watched asc) as row_num from student_engagement) as subquery where row_num = 1) as s on s.student_id=i.student_id
left join (select * from (select * ,row_number() over(partition by student_id order by date_purchased asc) as row_num from student_purchases) as subquery2 where row_num = 1) as p on p.student_id=s.student_id
having (first_date_purchased>=first_date_watched) or (first_date_purchased is null);


## Creating Result set Table
drop table if exists result_set;
create table result_set(
student_id int,
date_registered date,
first_date_watched date,
days_diff_reg_watch int,
first_date_purchased date,
days_diff_watch_purch int
);


## Inserting values into result set table
insert into result_set
select i.student_id, i.date_registered, s.date_watched as first_date_watched, datediff(s.date_watched,i.date_registered) as days_diff_reg_watch, p.date_purchased as first_date_purchased, datediff(p.date_purchased,s.date_watched) as days_diff_watch_purch 
from student_info i 
join (select * from (select * ,row_number() over(partition by student_id order by date_watched asc) as row_num from student_engagement) as subquery where row_num = 1) as s on s.student_id=i.student_id
left join (select * from (select * ,row_number() over(partition by student_id order by date_purchased asc) as row_num from student_purchases) as subquery2 where row_num = 1) as p on p.student_id=s.student_id
having (first_date_purchased>=first_date_watched) or (first_date_purchased is null);


## checking result set table
select * from result_set;


##'Free-to-Paid Conversion Rate:'
## The number of students who watched a lecture and purchased a subscription:-
set @subs=(select count(student_id) from result_set where first_date_purchased is not null);
## The total number of students who have watched a lecture
set @lec=(select count(student_id) from result_set where first_date_watched is not null);
##Free-to-Paid Conversion Rate:
set @conversion_rate=(round(100*@subs/@lec,2));
select@conversion_rate;


## Average Duration Between Registration and First-Time Engagement:
##The sum of all such durations
set @sum_reg_eng=(select sum(days_diff_reg_watch) from result_set);
##The total number of students who have watched a lecture
set @count_reg_eng=(select count(days_diff_reg_watch) from result_set where days_diff_reg_watch>=0);
set @av_reg_watch=(round(@sum_reg_eng/@count_reg_eng,2));
select @av_reg_watch;

##Average Duration Between First-Time Engagement and First-Time Purchase:
##The sum of all such durations.
set @sum_watch_purch=(select sum(days_diff_watch_purch) from result_set where days_diff_watch_purch is not null);
##The count of these durations, or alternatively, the number of students who have made a purchase.
set @count_watch_purch=(select count(days_diff_watch_purch) from result_set where days_diff_watch_purch is not null);
## Average
set @av_watch_purch=(round(@sum_watch_purch/@count_watch_purch,2));
select @av_watch_purch;

## View all Metrix
select @conversion_rate, @av_reg_watch,@av_watch_purch;

##Quiz:-
## Question#1:-
## When did a student with ID 268727 first watch a lecture?
## Solution:-
select * from result_set where student_id=268727;

## Question#2:-
##Regarding the same student's first subscription purchase, which statement is accurate?
## Solution:-
select * from result_set where student_id=268727;

## Question#3:-
##What is the approximate free-to-paid conversion rate of students who have watched a lecture on the 365 platform?
## Solution:-
select @conversion_rate;

## Question#4:-
##What is the approximate average duration between the registration date and the date of first-time engagement?
## Solution:-
select @av_reg_watch;

## Question#5:-
##What is the approximate average duration between the date of first-time engagement and the date of first-time purchase?
#### Solution:-
select @av_watch_purch;