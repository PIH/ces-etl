create table visitas (
emrid			varchar(50),
visit_id			int(11),
visit_date_started	datetime,
visit_date_stopped	datetime,
visit_date_entered	datetime,
visit_user_entered	varchar(255),
visit_type			varchar(255),
visit_location		varchar(255),
index_asc			int,
index_desc			int);