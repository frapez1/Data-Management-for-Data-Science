////// DM HW2 MONGODB SCRIPT
////// PART 1 REWRITING OF THE QUERIES:
///1)
use hw2;
db.getCollection("atp_matches_2018").aggregate(
    [
        { 
            "$group" : { 
                _id : "$winner_id", 
                count : {$sum:1},
                winner_name: {$first:"$winner_name" }
            }
        },
        {
            "$lookup" : {
                from : "atp_players",
                localField : "_id",
                foreignField : "player_id",
                as : "player_infos"
            }
        }, 
        { 
            "$project" : { 
                player_infos : 1,
                winner_name : 1, 
                count : 1
            }
        },
        {
            $sort: {count: -1}
        }, 
        { 
            $limit : 3 
        }
            
]);

//2)

db.getCollection("atp_matches_2018").aggregate(
    [
        { 
            "$match" : { 
                "winner_hand" : "L"
            }
        }, 
        { 
            "$group" : { 
                _id : "$winner_id",
                winner_name: {$first:"$winner_name" },
                winner_age: {$first:"$winner_age" }, 
                winner_ioc: {$first:"$winner_ioc" },
                count : { 
                    "$sum" : NumberInt(1)
                }
            }
        }, 
        { 
            "$project" : { 
                _id : 1, 
                winner_name : 1, 
                winner_ioc : 1, 
                winner_age : 1,
                count : 1
            }
        }, 
        { 
            "$sort" : { 
                count : NumberInt(-1)
            }
        }, 
        { 
            "$limit" : NumberInt(10)
        }
    ]
);

//3)
db.getCollection("atp_matches_futures_2019").find(
    { 
        "$and" : [
            {
                "$expr": { 
                    "$lt": [ "$winner_age" , "$loser_age" ] 
                } 
            },
            { 
                "winner_age" : { 
                    "$lt" : NumberLong(24)
                }
            }
        ]
    }, 
    { 
        "winner_id" : "$winner_id",
        "winner_name" : "$winner_name", 
        "loser_name" : "$loser_name", 
        "_id" : NumberInt(0)
    }
).sort(
    { 
        "winner_name" : NumberInt(1)
    }
);



///4)

db.getCollection("atp_matches_2019").aggregate(
    [
        { 
            "$group" : { 
                "_id" : { 
                    "winner_id" : {"$max" : ["$winner_id", "$loser_id"]},
                    "loser_id" : {"$min" : ["$winner_id", "$loser_id"]}
                }, 
                "COUNT(*)" : { 
                    "$sum" : NumberInt(1)
                }
            }
        }, 
        { 
            "$project" : { 
                "winner_id" : "$_id.winner_id", 
                "loser_id" : "$_id.loser_id", 
                "COUNT(*)" : "$COUNT(*)", 
                "_id" : NumberInt(0)
            }
        }, 
        { 
            "$match" : { 
                "COUNT(*)" : { 
                    "$gte" : NumberLong(3)
                }
            }
        }, 
        { 
            "$sort" : { 
                "COUNT(*)" : NumberInt(-1)
            }
        }, 
        { 
            "$limit" : NumberInt(10)
        }
    ]
);

//////////PART 2: NEW QUERIES:

///1)TO SHOW THE 'STRUCTURED' AND 'UNSTRUCTURED' DIFFERENCE:


db.atp_matches_2018.insert( { tourney_name: 'Roma Finals',
winner_name: "Francesco Pezone", 
winner_id: 101010,
loser_name: "Rafael Nadal", 
loser_hand: 'L', 
winner_age: 24 })

db.atp_matches_2018.find({winner_name: "Francesco Pezone"})

db.atp_matches_2018.remove( { winner_name: "Francesco Pezone" } );

///2) MAPREDUCE

db.atp_matches_futures_2019.aggregate(
    [
        { 
            "$match" : { 
                "winner_ioc" : "ESP"
            }
        }, 
        {
            "$group" : { 
                _id : "$winner_id", 
                count : {$sum:1}
            }
        }, 
        { 
            "$match" : 
                { 
                    count : { 
                        "$gt" : NumberLong(10)
                }
            }
        }, 
        { 
            "$project" : { 
                winner_id : 1,
                count : 1
            }
        },
        { 
            "$sort" : { 
                count : NumberInt(-1)
            }
        }
]);

//MAPREDUCE:

db.atp_matches_futures_2019.mapReduce( function() { emit(this.winner_id,1); },
        function(key, values) {return Array.sum(values)}, 
        { query:{winner_ioc:"ESP"}, out:"new_collection"}).find()
       
       
db.new_collection.find({"value" : { 
                    "$gt" : NumberLong(10)}}).sort({"value": -1})

///3)USING SKIP:

db.atp_matches_qual_chall_2018.aggregate(
   [
     {
       "$group":
         {
           "_id": null,
           "avgMin": { "$avg": "$minutes" }
         }
     },
     {
         "$project": 
         { "avgMin":1}
     }
   ]
);

db.atp_matches_qual_chall_2018.aggregate(
    [
     {
          "$skip" : 4214 
     },
     {
       "$group":
         {
           "_id": null,
           "avgMin": { "$avg": "$minutes" }
         }
     },
     {
         "$project": 
         { "avgMin":1}
     }
   ]
);

///4)HISTOGRAM OF WIINER AGE DISTRIBUTION

db.atp_matches_2019.aggregate( [
   {
     $bucketAuto: {
         groupBy: "$minutes",
         buckets: 20
     }
   }
]);

