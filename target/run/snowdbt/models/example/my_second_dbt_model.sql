
  create or replace   view DBT_TEST.dbo.my_second_dbt_model
  
   as (
    -- Use the `ref` function to select from other models

select *
from DBT_TEST.dbo.my_first_dbt_model
where id = 1
  );

