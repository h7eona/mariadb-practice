-- 서브쿼리(SUBQUERY) SQL 문제입니다.

-- 단 조회결과는 급여의 내림차순으로 정렬되어 나타나야 합니다. 

-- 문제1.
-- 현재 전체 사원의 평균 급여보다 많은 급여를 받는 사원은 몇 명이나 있습니까?
select count(*) as '평균 급여보다 많은 급여를 받는 사원 수'
from salaries 
where salary > (select avg(salary)
				    from salaries 
				   where to_date = '9999-01-01');

-- 문제2. 
-- 현재, 각 부서별로 최고의 급여를 받는 사원의 사번, 이름, 부서 급여을 조회하세요. 단 조회결과는 급여의 내림차순으로 정렬합니다.
select a.emp_no as '사번',
       concat(a.first_name, ' ', a.last_name) as '이름',
	   c.dept_name as '부서',
	   d.salary as '급여'
from employees a, dept_emp b, departments c, salaries d
where a.emp_no = b.emp_no and b.to_date = '9999-01-01'
  and a.emp_no = d.emp_no and d.to_date = '9999-01-01'
  and b.dept_no = c.dept_no and b.emp_no = d.emp_no
  and (b.dept_no, d.salary) in (select a.dept_no, max(b.salary)
									  from dept_emp a, salaries b
									 where a.emp_no = b.emp_no and a.to_date = '9999-01-01' and b.to_date = '9999-01-01' 
								  group by a.dept_no)
order by d.salary desc;

-- 문제3.
-- 현재, 사원 자신들의 부서의 평균급여보다 급여가 많은 사원들의 사번, 이름 그리고 급여를 조회하세요 
  select a.emp_no as '사번',
         concat(a.first_name, ' ', a.last_name) as '이름',
         b.salary as '급여'
    from employees a, salaries b, dept_emp c, ( select a.dept_no as d_no, avg(b.salary) as avg_salary
											      from dept_emp a, salaries b
											     where a.emp_no = b.emp_no and a.to_date = '9999-01-01' and b.to_date = '9999-01-01'
										      group by a.dept_no ) d
   where a.emp_no = b.emp_no and b.to_date = '9999-01-01'
     and a.emp_no = c.emp_no and c.to_date = '9999-01-01'
     and b.emp_no = c.emp_no
     and c.dept_no = d_no and b.salary > d.avg_salary
order by '급여' desc;
        
-- 문제4.
-- 현재, 사원들의 사번, 이름, 그리고 매니저 이름과 부서 이름을 출력해 보세요.
select a.emp_no as '사번',
       concat(a.first_name, ' ', a.last_name) as '이름',
       d.name as '매니저 이름',
       c.dept_name as '부서 이름'
from employees a, dept_emp b, departments c, 
	(select concat(a.first_name, ' ', a.last_name) as 'name',
		    b.dept_no as 'dept'
	   from employees a, dept_manager b
      where a.emp_no = b.emp_no and b.to_date = '9999-01-01') d
where a.emp_no = b.emp_no and b.to_date = '9999-01-01'
  and b.dept_no = d.dept and c.dept_no=d.dept;
  
-- 문제5.
-- 현재, 평균급여가 가장 높은 부서의 사원들의 사번, 이름, 직책 그리고 급여를 조회하고 급여 순으로 출력하세요.
  select a.dept_no
    from dept_emp a, salaries b
   where a.emp_no = b.emp_no and a.to_date = '9999-01-01' and b.to_date = '9999-01-01'
group by a.dept_no
order by avg(b.salary) desc
   limit 1;

select a.emp_no as '사번', 
	   concat(a.first_name, ' ', a.last_name) as '이름',
       b.title as '직책',
       c.salary as '급여'
from employees a, titles b, salaries c, dept_emp d
where a.emp_no = b.emp_no and a.emp_no = c.emp_no and a.emp_no = d.emp_no and b.emp_no = d.emp_no and c.emp_no = d.emp_no
  and b.to_date = '9999-01-01' and c.to_date = '9999-01-01' and d.to_date = '9999-01-01'
  and d.dept_no = (select a.dept_no
					 from dept_emp a, salaries b
					where a.emp_no = b.emp_no and a.to_date = '9999-01-01' and b.to_date = '9999-01-01'
				 group by a.dept_no
				 order by avg(b.salary) desc
				    limit 1)
order by c.salary desc;

-- 문제6.
-- 현재, 평균 급여가 가장 높은 부서의 이름 그리고 평균급여를 출력하세요.
select c.dept_name, avg(b.salary)
from dept_emp a, salaries b, departments c
where a.dept_no = (select a.dept_no
					from dept_emp a, salaries b
					where a.emp_no = b.emp_no and a.to_date = '9999-01-01' and b.to_date = '9999-01-01'
					group by a.dept_no
					having avg(b.salary)=(  select max(a.avg_salary)
											  from (  select a.dept_no, avg(b.salary) as 'avg_salary'
														from dept_emp a, salaries b
													   where a.emp_no = b.emp_no and a.to_date = '9999-01-01' and b.to_date = '9999-01-01'
													group by a.dept_no) a)
) and a.emp_no = b.emp_no and a.to_date = '9999-01-01' and b.to_date = '9999-01-01'
  and a.dept_no = c.dept_no
group by a.dept_no;


-- 문제7.
-- 현재, 평균 급여가 가장 높은 직책의 타이틀 그리고 평균급여를 출력하세요.
select a.title as '평균 급여가 가장 높은 직책', 
	   avg(b.salary) as '평균 급여'
from titles a, salaries b
where a.emp_no = b.emp_no and a.to_date = '9999-01-01' and b.to_date = '9999-01-01'
group by title
having avg(b.salary) = (select max(avg_salary)
					     from ( select a.title, avg(b.salary) as 'avg_salary'
								from titles a, salaries b
								where a.emp_no = b.emp_no and a.to_date = '9999-01-01' and b.to_date = '9999-01-01'
								group by a.title) a);








