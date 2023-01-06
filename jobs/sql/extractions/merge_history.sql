set @partition = '${partitionNum}';

DROP TEMPORARY TABLE IF EXISTS temp_merge;
CREATE TEMPORARY TABLE temp_merge (
merge_log_id       int(11),		
winner_person_id   int(11),
loser_person_id    int(11),
winner_person_uuid char(38),
loser_person_uuid  char(38)
);

insert into temp_merge (merge_log_id, winner_person_id, loser_person_id)
select person_merge_log_id, winner_person_id, loser_person_id 
from person_merge_log pml
where voided = 0;

update temp_merge t
inner join person p on p.person_id  = t.winner_person_id
set t.winner_person_uuid = p.uuid;

update temp_merge t
inner join person p on p.person_id  = t.loser_person_id
set t.loser_person_uuid = p.uuid;


select 
CONCAT(@partition,'-',merge_log_id) "merge_log_id",
winner_person_uuid,
loser_person_uuid
from temp_merge;
