# author: swerner@google.com
# updated: 2020-06-03

CREATE OR REPLACE TABLE aging_update
as
with
  case_data as (
    select
      milestone_status,
      case
        when booking_year__c in ('2017', '2018', '2019', '2020', '2021', '2022')
          then booking_year__c
        else 'Rep to Update in Case'
      end as booking_year,
      case
        when booking_quarter__c in ('Q1', 'Q2', 'Q3', 'Q4')
          then booking_quarter__c
        else "Rep to Update in Case"
      end as booking_quarter,
      case_number,
      date(timestamp_millis(sfdc_created_date)) as case_opened,
      round(
        safe_divide(total_resolution_time__c, 1440), 2
      ) as active_resolution_time_days,
      round(
        date_diff(
          CURRENT_DATE(), date(timestamp_millis(sfdc_created_date)), DAY
        )
        - date_diff(
          CURRENT_DATE(),
          date(timestamp_millis(sfdc_created_date)),
          WEEK(SATURDAY)
        )
        - date_diff(
          CURRENT_DATE(),
          date(timestamp_millis(sfdc_created_date)),
          WEEK(SUNDAY)
        ),
        2
      ) as aging_days,
      subject as subject,
      issue_category__c as reported_issue_category,
      id,
      sfdc_created_by_id,
      owner_id
    from Cases.newest
    where status != 'Closed' and issue_type__c = 'Finance Help'
  ),
  reason_codes_data as (select * from reason_codes),
  case_creator_data as (
    select sfdc_created_by_id, creator_region, creator_sub_region
    from case_creators
  ),
  ca_rep_data as (
    select ca_ldap, owner_id, region as ca_region from reps
  )
select
  cd.milestone_status as `Milestone Status`,
  cd.booking_year `Booking Year`,
  cd.booking_quarter as `Booking Quarter`,
  cd.case_number as `Case Number`,
  cd.case_opened as `Case Opened`,
  cd.aging_days as Aging,
  ifnull(crd.ca_ldap, "* New TBA") as `Case Owner`,
  cd.subject as Subject,
  cd.reported_issue_category as `Reported Issue Category`,
  cd.id,
  case
    when(rcd.category is null and rcd.new_category is null)
      then
        case
            when cd.reported_issue_category = 'Attainment'
              then 'Attainment Issue / Question'
            when cd.reported_issue_category = 'SPIFF - New Client'
              then 'Coverage Bonus \nGPS'
            when cd.reported_issue_category = 'GPS Coverage Bonus'
              then 'Coverage Bonus\nEnterprise'
            when cd.reported_issue_category = 'Deal Splits' then 'Deal Split'
            else cd.reported_issue_category
          end
          when rcd.new_category = rcd.category or rcd.new_category is null
            then rcd.category
          else rcd.new_category
        end as `Category`,
  case
    when(rcd.new_reason is null and rcd.reason is null) then 'In Progress'
    when rcd.reason = rcd.new_reason or rcd.new_reason is null then rcd.reason
    else rcd.new_reason
  end as `Reason`,
  ifnull(crd.ca_region, "* New TBA") as `Case Owner Region`,
  ccd.creator_region as `Case Creator Region`,
  ccd.creator_sub_region as `Case Creator Sub Region`
from case_data cd
left join reason_codes_data rcd using (id)
left join case_creator_data ccd using (sfdc_created_by_id)
left join ca_rep_data crd using (owner_id)
