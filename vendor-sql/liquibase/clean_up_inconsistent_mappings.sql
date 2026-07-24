drop temporary table if exists tmp_mappings_to_cleanup;
            create temporary table tmp_mappings_to_cleanup
            as
select map.concept_map_id
from
    concept_reference_source source
        inner join concept_reference_term term on source.concept_source_id = term.concept_source_id
        inner join concept_reference_map map on term.concept_reference_term_id = map.concept_reference_term_id
        inner join concept concept on map.concept_id = concept.concept_id
where source.name = 'ICD-10-WHO'
  and concept.uuid in ('123841AAAAAAAAAAAAAAAAAAAAAAAAAAAAAA','136784AAAAAAAAAAAAAAAAAAAAAAAAAAAAAA',
                       '157460AAAAAAAAAAAAAAAAAAAAAAAAAAAAAA','165866AAAAAAAAAAAAAAAAAAAAAAAAAAAAAA','121317AAAAAAAAAAAAAAAAAAAAAAAAAAAAAA',
                       '112603AAAAAAAAAAAAAAAAAAAAAAAAAAAAAA','3cde693a-26fe-102b-80cb-0017a47871b2','119399AAAAAAAAAAAAAAAAAAAAAAAAAAAAAA',
                        '3cd4e7e8-26fe-102b-80cb-0017a47871b2','3ccfb3b8-26fe-102b-80cb-0017a47871b2');
delete from concept_reference_map where concept_map_id in (select * from tmp_mappings_to_cleanup);


drop temporary table if exists tmp_mappings_to_cleanup;
            create temporary table tmp_mappings_to_cleanup
            as
select map.concept_map_id
from
    concept_reference_source source
        inner join concept_reference_term term on source.concept_source_id = term.concept_source_id
        inner join concept_reference_map map on term.concept_reference_term_id = map.concept_reference_term_id
        inner join concept concept on map.concept_id = concept.concept_id
where source.name = 'SNOMED CT'
  and concept.uuid in ('157460AAAAAAAAAAAAAAAAAAAAAAAAAAAAAA');
delete from concept_reference_map where concept_map_id in (select * from tmp_mappings_to_cleanup);