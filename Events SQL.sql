with t1 as
   (select count(distinct games) as total_summer_games
    from dbo.athlete_events
    where season = 'Summer'),
t2 as
   (select distinct sport, games
   from dbo.athlete_events
   where season = 'Summer'),
t3 as
  (select sport, count(games) as no_of_games
   from t2
   group by sport)
select *
from t3
join t1 on t1.total_summer_games = t3.no_of_games;

question: identify the sport/s which was played in all summer events
Steps: 
1. find total number of summer games
2. find each sport and how many games they played
3. compare 1 & 2

