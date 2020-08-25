/*Data Management For Data Science 2020 Homework 2 Script
Authors: Francesco Pezone 1913202 & Sabriye Ela Esme 1912580
Data Source: https://github.com/JeffSackmann/tennis_atp
***********************************************************/

####1ST OPTIMIZED QUERY: 

#QUERY 1: WHO HAS WON THE MOST GAMES IN TOTAL FOR THESE TWO YEARS? RETURN ALL ATTRIBUTES OF THESE TOP 
#3 PLAYERS FROM ATP_PLAYERS TABLE.

#OLDER VERSION:
select p.*
from atp_matches_18_19 a, atp_players p
where a.winner_id = p.player_id
group by a.winner_id
order by count(*) desc
limit 3;

#OPTIMIZED VERSION 
#OPTIMIZATION METHOD: CREATING INDEX
CREATE INDEX idx_player_id ON atp_players(player_id);

select p.*
from atp_matches_18_19 a, atp_players p
where a.winner_id = p.player_id
group by a.winner_id
order by count(*) desc
limit 3;

#normal speed
DROP INDEX idx_player_id ON atp_players;


####2ND OPTIMIZED QUERY:

#QUERY 4: WHAT ARE THE NAMES, BIRTHDAYS AND NATIONS OF THE TOP 10 LEFT-HANDED PLAYERS WHO HAVE 
#WON THE MOST IN THESE TWO YEARS?

#OLDER VERSION:
select a.winner_name, p.birth_date, p.country_code, count(*)
from atp_matches_18_19 a, atp_players p
where a.winner_id = p.player_id
and a.winner_hand = 'L'
group by p.player_id
order by count(*) desc
limit 10;

#OPTIMIZED VERSION:
#OPTIMIZATION METHOD: ADDING INTEGRITY CONSTRAINTS(PRIMARY KEY)

# add a constraint
alter table atp_players add primary key(player_id);

select a.winner_name, p.birth_date, p.country_code, count(*)
from atp_matches_18_19 a, atp_players p
where a.winner_id = p.player_id
and a.winner_hand = 'L'
group by p.player_id
order by count(*) desc
limit 10;

# remove the constraint
alter table atp_players drop primary key;

####3RD OPTIMIZED QUERY:

#QUERY 3: RETURN THE NAME, ID AND AGE OF PLAYER(S) WHO ARE 25 OR OLDER AND HAD LOST LESS THAN 20 MATCHES
#IN TOTAL AT MATCHES 2019 AND MATCHES QUALL CHALL 2019 AND PLAYED CONSIDERABLE NUMBER OF MINUTES AT BOTH MATCHES.
#NOTES: A TENNIS MATCH TOOKS 150 MINUTES ON AVERAGE, SO WE CONSIDERED 5 MATCHES AS 750 MINUTES*/

#OLDER VERSION
select a.loser_name, a.loser_id, a.loser_age
from atp_matches_2019 as a
where a.loser_age>=25
group by a.loser_id having (count(a.loser_id)+count(loser_id)<20) 
and a.loser_name IN (select loser_name
from atp_matches_qual_chall_2019 
where loser_age>=25
group by loser_id having sum(minutes)>750) and sum(a.minutes)>750;


#OPTIMIZED VERSION:
#OPTIMIZATION METHOD: REWRITING THE QUERY. INSTEAD OF SELECTING loser_name ON INNER QUERY SELECT loser_id.

Select a.loser_name, a.loser_id, a.loser_age
from atp_matches_2019 as a
where a.loser_age>=25
group by a.loser_id having (count(a.loser_id)+count(loser_id)<20) 
and a.loser_id IN (select loser_id
from atp_matches_qual_chall_2019 
where loser_age>=25
group by loser_id having sum(minutes)>750) and sum(a.minutes)>750;


####4TH OPTIMIZED QUERY:
#QUERY 7: RETURN THE RANKING AND NAME OF LEFT HANDED ITALIAN PLAYERS WHO RANK IN THE
#FIRST 500 PLAYERS IN CURRENT RANKINGS*/

#OLDER VERSION
select first_name, last_name, min(ranking) as bestCurrentRanking, a.player_id
from atp_rankings_current a join atp_players b on a.player_id=b.player_id
where ranking<500 and hand='L' and country_code='ITA'
group by player_id having min(ranking);

#OPTIMIZED VERSION
#OPTIMIZATION METHOD: MATERIALIZED VIEW WITH INDEX ON player_id

CREATE TABLE atp_players_ita AS 
	select *
    from atp_players
    where country_code = 'ITA' and hand='L';
    
create index id_index on atp_players_ita(player_id);

select first_name, last_name, min(ranking) as bestCurrentRanking, a.player_id
from (	select player_id, ranking 
		from atp_rankings_current 
        where ranking<500) a join atp_players_ita b on a.player_id=b.player_id
group by player_id having min(ranking);

drop table atp_players_ita;


####5TH OPTIMIZED QUERY:

#QUERY 10: WHICH COUNTRY HAS THE MOST WINS AND WHICH ARE THE TOP 3 PLAYERS BY THAT NATION'S NUMBER OF WINS? 
#RETURN NAME, BIRTHDAY, NATION AND THE NUMBER OF WINS OF THESE PLAYERS.*/

#OLDER VERSION
select winner_name, p.birth_date, p.country_code,count(*)
from atp_matches_18_19 join (select *
from atp_players
where country_code = (select winner_ioc
from atp_matches_18_19
group by winner_ioc
order by count(*) desc
limit 1)) as p on winner_id = p.player_id
group by winner_id
order by count(*) desc
limit 3;

#OPTIMIZED VERSION
#OPTIMIZATION METHOD: MATERIALIZED VIEW WITH DIFFERENT DOMAIN AND INDEX ON winner_ioc

CREATE TABLE atp_matches_18_19_materialized AS 
	select *
    from atp_matches_2018
    union
    select * 
    from atp_matches_2019;

# we need to change the type ot the column winner_ioc
ALTER TABLE atp_matches_18_19_materialized modify winner_ioc char(3);
# now we can build the index
create index winner_ioc_index on atp_matches_18_19_materialized(winner_ioc);

select winner_name, p.birth_date, p.country_code,count(*)
from atp_matches_18_19 join (
	select *
	from atp_players
	where country_code = (
		select winner_ioc
		from atp_matches_18_19_materialized
		group by winner_ioc
		order by count(*) desc
		limit 1)) as p on winner_id = p.player_id
group by winner_id
order by count(*) desc
limit 3;

DROP TABLE atp_matches_18_19_materialized;