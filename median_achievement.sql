# Median Achievement
# author: swerner
# date: 4/14/2020

select 
  period,
  AVG(metric1_ach)mean_metric1_ach,
  MAX(median_metric1_ach)median_metric1_ach,
  AVG(metric2_ach)mean_metric2_ach,
  MAX(median_metric2_ach)median_metric2_ach
FROM 

(
select 
  "1H18" as period, 
  farm_fingerprint(rep_ldap)rep_hash,
  safe_divide(sum(metric1_attainment),sum(metric1_quota))metric1_ach,
  PERCENTILE_CONT(safe_divide(sum(metric1_attainment),sum(metric1_quota)),.5) OVER() AS median_metric1_ach,
  safe_divide(sum(metric2_attainment),sum(metric2_quota))metric2_ach,
  PERCENTILE_CONT(safe_divide(sum(metric2_attainment),sum(metric2_quota)),.5) OVER() AS median_metric2_ach
  from 
    REP_BY_ROLE_ATTAINMENT_VIEW.newest 
    where quarter_id = 73
  and rep_ldap not in (select rep_ldap from pass_list where semester_id = 36 and pass_payment = TRUE)
  and rep_ldap in (select rep_ldap from pass_list where semester_id = 36 and pass_payment = FALSE)
  group by 1,2

UNION ALL 
select 
  "2H18" as period, 
  farm_fingerprint(rep_ldap)rep_hash,
  safe_divide(sum(metric1_attainment),sum(metric1_quota))metric1_ach,
  PERCENTILE_CONT(safe_divide(sum(metric1_attainment),sum(metric1_quota)),.5) OVER() AS median_metric1_ach,
  safe_divide(sum(metric2_attainment),sum(metric2_quota))metric2_ach,
  PERCENTILE_CONT(safe_divide(sum(metric2_attainment),sum(metric2_quota)),.5) OVER() AS median_metric2_ach
  from 
    REP_BY_ROLE_ATTAINMENT_VIEW.newest 
  where quarter_id = 75
  and rep_ldap not in (select rep_ldap from pass_list where semester_id = 37 and pass_payment = TRUE)
  and rep_ldap in (select rep_ldap from pass_list where semester_id = 37 and pass_payment = FALSE)
  group by 1,2

UNION ALL 
select 
  "1H19" as period, 
  farm_fingerprint(rep_ldap)rep_hash,
  safe_divide(sum(metric1_attainment),sum(metric1_quota))metric1_ach,
  PERCENTILE_CONT(safe_divide(sum(metric1_attainment),sum(metric1_quota)),.5) OVER() AS median_metric1_ach,
  safe_divide(sum(metric2_attainment),sum(metric2_quota))metric2_ach,
  PERCENTILE_CONT(safe_divide(sum(metric2_attainment),sum(metric2_quota)),.5) OVER() AS median_metric2_ach
  from 
    REP_BY_ROLE_ATTAINMENT_VIEW.newest 
  where quarter_id = 77
  and rep_ldap not in (select rep_ldap from pass_list where semester_id = 38 and pass_payment = TRUE)
  and rep_ldap in (select rep_ldap from pass_list where semester_id = 38 and pass_payment = FALSE)
  group by 1,2
  having metric2_ach > 0 
)
group by 1

  
