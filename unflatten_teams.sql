#author: swerner
#date: 2020-04-19

define macro semester 39;
with
  unflattened as (
    select
      team_id_l7 as child_team,
      [struct(team_id_l6 as parent_team),
      struct(team_id_l5 as parent_team),
      struct(team_id_l4 as parent_team),
      struct(team_id_l3 as parent_team),
      struct(team_id_l2 as parent_team),
      struct(team_id_l1 as parent_team)] as teams
    from team_HIERARCHY.newest
    where team_id_l7 is not null and semester_id = $semester 
    union all
select
  team_id_l6 as child_team,
  [struct(team_id_l5 as parent_team),
  struct(team_id_l4 as parent_team),
  struct(team_id_l3 as parent_team),
  struct(team_id_l2 as parent_team),
  struct(team_id_l1 as parent_team)] as teams
from team_HIERARCHY.newest
where team_id_l6 is not null and semester_id = $semester
union all
  select
    team_id_l5 as child_team,
    [struct(team_id_l4 as parent_team),
    struct(team_id_l3 as parent_team),
    struct(team_id_l2 as parent_team),
    struct(team_id_l1 as parent_team)] as teams
  from team_HIERARCHY.newest
  where team_id_l5 is not null and semester_id = $semester
union all
  select
    team_id_l4 as child_team,
    [struct(team_id_l3 as parent_team),
    struct(team_id_l2 as parent_team),
    struct(team_id_l1 as parent_team)] as teams
  from team_HIERARCHY.newest
  where team_id_l4 is not null and semester_id = $semester
union all
  select
    team_id_l3 as child_team,
    [struct(team_id_l2 as parent_team),
    struct(team_id_l1 as parent_team)] as teams
  from team_HIERARCHY.newest
  where team_id_l3 is not null and semester_id = $semester
union all
  select team_id_l2 as child_team, [struct(team_id_l1 as parent_team)] as teams
  from team_HIERARCHY.newest
  where team_id_l2 is not null and semester_id = $semester),
unnested
  as (
    select parent_team, child_team
    from unflattened
    join unnest(teams)
    group by 1, 2
  ),
levels
  as (
    select
      a.*,
      b.hierarchy_level as parent_hierarchy_level,
      c.hierarchy_level as child_team_hierarchy_level
    from unnested a
    join
      team_HIERARCHY.newest b
      on a.parent_team = b.team_id and b.semester_id = $semester
    join
      team_HIERARCHY.newest c
      on a.child_team = c.team_id and c.semester_id = $semester
  ) select * from levels
