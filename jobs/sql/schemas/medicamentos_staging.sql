CREATE TABLE #medicamentos_staging
(
 person_uuid          char(38),      
 emr_id               varchar(50),  
 encuentro_id         int,   
 emr_instancia        varchar(255),
 medication           varchar(255), 
 duration             float,       
 duration_units       varchar(255), 
 admin_inxs           text,         
 dose1_dose           float,       
 dose1_dose_units     varchar(255), 
 dose1_morning        bit,      
 dose1_morning_text   varchar(255), 
 dose1_noon           bit,      
 dose1_noon_text      varchar(255), 
 dose1_afternoon      bit,      
 dose1_afternoon_text varchar(255),  
 dose1_evening        bit,      
 dose1_evening_text   varchar(255), 
 dose2_dose           float,       
 dose2_dose_units     varchar(255), 
 dose2_morning        bit,      
 dose2_morning_text   varchar(255), 
 dose2_noon           bit,      
 dose2_noon_text      varchar(255), 
 dose2_afternoon      bit,      
 dose2_afternoon_text varchar(255),  
 dose2_evening        bit,      
 dose2_evening_text   varchar(255)  
  );
