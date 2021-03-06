set profiling = 1;
SHOW PROFILES;

use employees;
drop table if exists stg_salaries;
drop table if exists prd_salaries;

-- Create a Staging and Production table
create table stg_salaries (
	pk_id int not null auto_increment primary key
	, emp_no int not null
  , salary int not null
  , from_date date not null
	, to_date date not null
);

create table prd_salaries (
	pk_id int not null auto_increment primary key
	, emp_no int not null
	, salary int not null
	, from_date date not null
	, to_date date not null
);

-- Insert all the datums into staging
insert into stg_salaries (
	emp_no
    , salary
    , from_date
    , to_date
) (
	select
		emp_no
		, salary
        , from_date
        , to_date
	from salaries
);

-- Insert the first 50% into Production, a total of 1422024 rows
insert into prd_salaries (
	emp_no
    , salary
    , from_date
    , to_date
) (
	select
		emp_no
		, salary
        , from_date
        , to_date
	from stg_salaries
		where stg_salaries.pk_id <= round((select max(pk_id) / 2 from stg_salaries))
);

-- and now amend 33% of the first 50% in staging so there's a whole buncha updates to run too.

set @breakpoint = (select round(max(pk_id) / 2) from stg_salaries);

update stg_salaries
	set salary = (salary * 1.33)
where pk_id <= (@breakpoint / 3)
;

-- and now set up sprocs to flush'n'fill or incrementally insert, update, delete
drop procedure if exists pFlushAndFill;
drop procedure if exists pInsertOnDuplicateKeyUpdate;

DELIMITER //
create procedure pFlushAndFill()
	begin
		delete from prd_salaries;
		insert into prd_salaries
				select * from stg_salaries
		;
	end //

create procedure pInsertOnDuplicateKeyUpdate()
	begin
		insert into prd_salaries (emp_no, salary, from_date, to_date)
			select
				emp_no
				, salary
				, from_date
				, to_date
			from stg_salaries s
		on duplicate key update
			prd_salaries.emp_no = s.emp_no
			, prd_salaries.salary = s.salary
			, prd_salaries.from_date = s.from_date
			, prd_salaries.to_date = s.to_date
		;
	end //
DELIMITER ;

call pInsertOnDuplicateKeyUpdate;
call pFlushAndFill;
