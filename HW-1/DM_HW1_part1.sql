/*Data Management For Data Science 2020 Homework 1 Script
Authors: Francesco Pezone 1913202 & Sabriye Ela Esme 1912580
Data Source: https://github.com/JeffSackmann/tennis_atp
***********************************************************/

/*CREATING VIEWS TO GET THE UNION OF 2018 AND 2019 MATCHES TO USE IN THE FUTURE QUERIES*/

#view for the union of atp_matches
create view atp_matches_18_19 as
	select *
    from atp_matches_2018
    union
    select * 
    from atp_matches_2019;
    
    
#view for the union of atp_matches_doubles
create view atp_matches_doubles_18_19 as
	select *
    from atp_matches_doubles_2018
    union
    select * 
    from atp_matches_doubles_2019;
    
/*QUERY 1:

WHO HAS WON THE MOST GAMES IN TOTAL FOR THESE TWO YEARS? RETURN ALL ATTRIBUTES OF THESE TOP 
3 PLAYERS FROM ATP_PLAYERS TABLE.*/

select p.*
from atp_matches_18_19 a, atp_players p
where a.winner_id = p.player_id
group by a.winner_id
order by count(*) desc
limit 3;


/*QUERY 2: 

WHO ARE THE TWO PLAYERS WHO CLASHED SEVERAL TIMES İN 2019?*/

select winner_name as player1, loser_name as player2, count(*) as number_of_matches
from atp_matches_2019
group by least(winner_id, loser_id), greatest(winner_id, loser_id)
having count(*) >= 3
order by count(*) desc
limit 10;

#An example to explain the use of least and greatest:
#111 and 222 are two player_id for two fake players
# we are counting each event of the type (111 win, 222 lose) or (222 win, 111 lose)
# at this point these two events are different, to take into account these two events as one,
# we used 'least' and 'greatest' since they are integers and we can order them. 


/*QUERY 3: 

RETURN THE NAME, ID AND AGE OF PLAYER(S) WHO ARE 25 OR OLDER AND HAD LOST LESS THAN 20 MATCHES
IN TOTAL AT MATCHES 2019 AND MATCHES QUALL CHALL 2019 AND PLAYED CONSIDERABLE NUMBER OF MINUTES AT BOTH MATCHES.
NOTES: A TENNIS MATCH TOOKS 150 MINUTES ON AVERAGE, SO WE CONSIDERED 5 MATCHES AS 750 MINUTES*/

select a.loser_name, a.loser_id, a.loser_age
from atp_matches_2019 as a
where a.loser_age>=25
group by a.loser_id having (count(a.loser_id)+count(loser_id)<20) 
and a.loser_name IN (select loser_name
from atp_matches_qual_chall_2019 
where loser_age>=25
group by loser_id having sum(minutes)>750) and sum(a.minutes)>750;

#We kept 2 age constraints because of the different days of matches and the possibility of a player 
#getting 25 after one of the matches. We require them to be 25 or older during the matches at both tournements.


/*QUERY 4: 

WHAT ARE THE NAMES, BIRTHDAYS AND NATIONS OF THE TOP 10 LEFT-HANDED PLAYERS WHO HAVE 
WON THE MOST IN THESE TWO YEARS?*/

select a.winner_name, p.birth_date, p.country_code, count(*)
from atp_matches_18_19 a, atp_players p
where a.winner_id = p.player_id
and a.winner_hand = 'L'
group by p.player_id
order by count(*) desc
limit 10;


/*QUERY 5: 

RETURN THE NAME AND 2019 RANK POINTS OF (COUPLE) PLAYERS WHO PLAYED AND WON TOGETHER 
AT ROMA MASTERS IN 2018 DOUBLES AND AT TOUR FINALS IN 2019 DOUBLES*/

select distinct winner1_name, winner2_name, winner1_rank_points,
winner2_rank_points
from atp_matches_doubles_2019
where tourney_name='Tour Finals'
and (least(winner1_id, winner2_id), greatest(winner1_id, winner2_id)) =any (select least(winner1_id, winner2_id), greatest(winner1_id, winner2_id)
							  from atp_matches_doubles_2018
                              where tourney_name='Rome Masters');
             
#select distinct because they played more than 1 match during the tour finals and 
#their ranking point of the tournmanent does not change so there will be same rows without distinct.

/*QUERY 6: 

IN THE TOURNEY WITH THE HIGHEST NUMBER OF MINUTES PLAYED, IN 2018 AND 2019, 
WHO WERE THE 5 PLAYERS TO WIN THE MOST? HOW MANY MINUTES DID THEY PLAY?*/

select winner_name, count(*) as number_of_wins, sum(minutes) as total_minutes
FROM atp_matches_18_19
where tourney_name = (	select tourney_name 
						from atp_matches_18_19
                        group by tourney_name 
                        order by sum(minutes) desc
                        limit 1)
group by winner_id
order by count(*) desc
limit 5;


/*QUERY 7: 

RETURN THE RANKING AND NAME OF LEFT HANDED ITALIAN PLAYERS WHO RANK IN THE
FIRST 500 PLAYERS IN CURRENT RANKINGS*/


select first_name, last_name, min(ranking) as bestCurrentRanking, a.player_id
from atp_rankings_current a join atp_players b on a.player_id=b.player_id
where ranking<500 and hand='L' and country_code='ITA'
group by player_id having min(ranking);

#In rankings file, there are more than one ranking for every player because this file includes
#updated rankings of players in different times of the year, that's why we returned the best(min) ranking.
#to see this, one can check the query below:
#select * from  atp_rankings_current where player_id= '105561'


/*QUERY 8: 

WHAT ARE THE NAMES OF THE PLAYERS WHO CLASHED IN 1VS1 AND WON TOGETHER İN 2VS2 (IN 2019)?*/

select doub.winner1_name as player_1, doub.winner2_name as player_2
from atp_matches_doubles_2019 as doub
where (least(doub.winner1_id, doub.winner2_id), greatest(doub.winner1_id, doub.winner2_id)) in (
	select least(winner_id, loser_id), greatest(winner_id, loser_id)
	from atp_matches_2019
	group by least(winner_id, loser_id), greatest(winner_id, loser_id))
group by least(doub.winner1_id, doub.winner2_id), greatest(doub.winner1_id, doub.winner2_id)
order by count(*) desc;

/*QUERY 9: 

WHO ARE THE PLAYERS WHO WERE BORN ON 22ND OF APRİL 1996 AND WON A MATCH WHILE PLAYING WITH 
SOMEONE OLDER THAN THEM AT FUTURES MATCHES 2019? RETURN THEIR ID, NAME AND THEIR OPPONENT'S NAME.*/

select winner_id, winner_name, loser_name
from atp_matches_futures_2019 
where winner_age<loser_age and winner_id =any(
			select player_id
            from atp_players as b
            where b.birth_date='19960422')
order by winner_name;
	

/*QUERY 10: 

WHICH COUNTRY HAS THE MOST WINS AND WHICH ARE THE TOP 3 PLAYERS BY THAT NATION'S NUMBER OF WINS? 
RETURN NAME, BIRTHDAY, NATION AND THE NUMBER OF WINS OF THESE PLAYERS.*/

select winner_name, p.birth_date, p.country_code,count(*)
from atp_matches_18_19 join (
	select *
	from atp_players
	where country_code = (	
		select winner_ioc
		from atp_matches_18_19
		group by winner_ioc
		order by count(*) desc
		limit 1)) as p on winner_id = p.player_id
group by winner_id
order by count(*) desc
limit 3;












