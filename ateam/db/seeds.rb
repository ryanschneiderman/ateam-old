# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: "Star Wars" }, { name: "Lord of the Rings" }])
#   Character.create(name: "Luke", movie: movies.first)

StatList.create(
    stat_id: 1,
    stat: "Field Goals",
    default_stat: true,
    collectable: true,
    team_stat: false,
    display_priority: 1,
    advanced: false,
    rankable: true,
    is_percent: false,
    stat_kind: 1,
    hidden: false,
    abbr: "FG"
)
##  t            | t           | f         |                1 | f        | f        | f          |         1
StatList.create(
    stat_id: 2,
    stat: "Field Goal Misses",
    default_stat: true,
    collectable: true,
    team_stat: false,
    display_priority: 1,
    advanced: false,
    rankable: false,
    is_percent: false,
    stat_kind: 1,
    hidden: false,
)
## f            | t           | f         |                9 | f        | t        | f          |         1
StatList.create(
    stat_id: 3,
    stat: "Assists",
    default_stat: false,
    collectable: true,
    team_stat: false,
    display_priority: 9,
    advanced: false,
    rankable: true,
    is_percent: false,
    stat_kind: 1,
    hidden: false,
    abbr: "AST"
)
## f            | t           | f         |               10 | f        | t        | f          |         2
StatList.create(
    stat_id: 4,
    stat: "Offensive Rebounds",
    default_stat: false,
    collectable: true,
    team_stat: false,
    display_priority: 10,
    advanced: false,
    rankable: true,
    is_percent: false,
    stat_kind: 2,
    hidden: false,
    abbr: "OReb"
)
## f            | t           | f         |               11 | f        | t        | f          |         2
StatList.create(
    stat_id: 5,
    stat: "Defensive Rebounds",
    default_stat: false,
    collectable: true,
    team_stat: false,
    display_priority: 11,
    advanced: false,
    rankable: true,
    is_percent: false,
    stat_kind: 2,
    hidden: false,
    abbr: "DReb"
)
## f            | t           | f         |               12 | f        | t        | f          |         2
StatList.create(
    stat_id: 6,
    stat: "Steals",
    default_stat: false,
    collectable: true,
    team_stat: false,
    display_priority: 12,
    advanced: false,
    rankable: true,
    is_percent: false,
    stat_kind: 2,
    hidden: false,
    abbr: "STL"
)
## f            | t           | f         |               14 | f        | t        | f          |         1
StatList.create(
    stat_id: 7,
    stat: "Turnovers",
    default_stat: false,
    collectable: true,
    team_stat: false,
    display_priority: 14,
    advanced: false,
    rankable: true,
    is_percent: false,
    stat_kind: 1,
    hidden: false,
    abbr: "TOV"
)
## Blocks                              | f            | t           | f         |               13 | f        | t        | f          |         2
StatList.create(
    stat_id: 8,
    stat: "Blocks",
    default_stat: false,
    collectable: true,
    team_stat: false,
    display_priority: 13,
    advanced: false,
    rankable: true,
    is_percent: false,
    stat_kind: 2,
    hidden: false,
    abbr: "BLK"
)
## 2 Point Field Goals                 | t            | f           | f         |                  | f        | f        | f          |         1
StatList.create(
    stat_id: 9,
    stat: "2 Point Field Goals",
    default_stat: true,
    collectable: false,
    team_stat: false,
    advanced: false,
    rankable: false,
    is_percent: false,
    stat_kind: 1,
    hidden: false,
)
## 2 Point Misses                      | t            | f           | f         |                  | f        | f        | f          |         1
StatList.create(
    stat_id: 10,
    stat: "2 Point Misses",
    default_stat: true,
    collectable: false,
    team_stat: false,
    advanced: false,
    rankable: false,
    is_percent: false,
    stat_kind: 1,
    hidden: false,
)
## 3 Point Field Goals                 | t            | f           | f         |                5 | f        | t        | f          |         1
StatList.create(
    stat_id: 11,
    stat: "3 Point Field Goals",
    default_stat: true,
    collectable: false,
    team_stat: false,
    display_priority: 5,
    advanced: false,
    rankable: true,
    is_percent: false,
    stat_kind: 1,
    hidden: false,
    abbr: "3PtFG"
)
## | t            | f           | f         |                5 | f        | f        | f          |         1
StatList.create(
    stat_id: 12,
    stat: "3 Point Misses",
    default_stat: true,
    collectable: false,
    team_stat: false,
    display_priority: 5,
    advanced: false,
    rankable: false,
    is_percent: false,
    stat_kind: 1,
    hidden: false,
)

######################################

##  t            | t           | f         |                7 | f        | t        | f          |         1
StatList.create(
    stat_id: 13,
    stat: "Free Throw Makes",
    default_stat: true,
    collectable: true,
    team_stat: false,
    display_priority: 7,
    advanced: false,
    rankable: true,
    is_percent: false,
    stat_kind: 1,
    hidden: false,
    abbr: "FT"
)
## t            | t           | f         |                7 | f        | f        | f          |         1
StatList.create(
    stat_id: 14,
    stat: "Free Throw Misses",
    default_stat: true,
    collectable: true,
    team_stat: false,
    display_priority: 5,
    advanced: false,
    rankable: false,
    is_percent: false,
    stat_kind: 1,
    hidden: false,
)

##  t            | f           | f         |               15 | f        | t        | f          |         1
StatList.create(
    stat_id: 15,
    stat: "Points",
    default_stat: true,
    collectable: false,
    team_stat: false,
    display_priority: 15,
    advanced: false,
    rankable: true,
    is_percent: false,
    stat_kind: 1,
    hidden: false,
    abbr: "PTS"
)
##  t            | f           | f         |               17 | f        | f        | f          |         3
StatList.create(
    stat_id: 16,
    stat: "Minutes",
    default_stat: true,
    collectable: false,
    team_stat: false,
    display_priority: 17,
    advanced: false,
    rankable: false,
    is_percent: false,
    stat_kind: 3,
    hidden: false,
    abbr: "MIN"
)

##  t            | t           | f         |               16 | f        | t        | f          |         2
StatList.create(
    stat_id: 17,
    stat: "Fouls",
    default_stat: true,
    collectable: true,
    team_stat: false,
    display_priority: 16,
    advanced: false,
    rankable: true,
    is_percent: false,
    stat_kind: 2,
    hidden: false,
    abbr: "Fouls"
)
# **********************************************************************
# **************************** DESCRIPTIONS!!!!!! **********************
# **********************************************************************

##  t            | f           | f         |                1 | t        | t        | t          |         1
StatList.create(
    stat_id: 18,
    stat: "Effective field goal %",
    default_stat: true,
    collectable: false,
    team_stat: false,
    display_priority: 1,
    advanced: true,
    rankable: true,
    is_percent: true,
    stat_kind: 1,
    hidden: false,
    abbr: "EFG%"
)

##True shooting %                     | t            | f           | f         |                2 | t        | t        | t          |         1

StatList.create(
    stat_id: 19,
    stat: "True shooting %",
    default_stat: true,
    collectable: false,
    team_stat: false,
    display_priority: 2,
    advanced: true,
    rankable: true,
    is_percent: true,
    stat_kind: 1,
    hidden: false,
    abbr: "TS%"
)

## 3 point attempt rate                | t            | f           | f         |                3 | t        | t        | t          |         1
StatList.create(
    stat_id: 20,
    stat: "3 point attempt rate",
    default_stat: true,
    collectable: false,
    team_stat: false,
    display_priority: 3,
    advanced: true,
    rankable: true,
    is_percent: true,
    stat_kind: 1,
    hidden: false,
    abbr: "3PAr"
)

## Free throw attempt rate             | t            | f           | f         |                4 | t        | t        | t          |         1
StatList.create(
    stat_id: 21,
    stat: "Free throw attempt rate",
    default_stat: true,
    collectable: false,
    team_stat: false,
    display_priority: 4,
    advanced: true,
    rankable: true,
    is_percent: true,
    stat_kind: 1,
    hidden: false,
    abbr: "FTAr"
)

## Usage rate                          | f            | f           | f         |               12 | t        | t        | t          |         1
StatList.create(
    stat_id: 22,
    stat: "Usage rate",
    default_stat: false,
    collectable: false,
    team_stat: false,
    display_priority: 12,
    advanced: true,
    rankable: true,
    is_percent: true,
    stat_kind: 1,
    hidden: false,
    abbr: "USG%"
)

## Offensive rating                    | f            | f           | f         |               13 | t        | t        | t          |         1
StatList.create(
    stat_id: 23,
    stat: "Offensive rating",
    default_stat: false,
    collectable: false,
    team_stat: false,
    display_priority: 13,
    advanced: true,
    rankable: true,
    is_percent: true,
    stat_kind: 1,
    hidden: false,
    abbr: "ORtg"
)

## Defensive rating                    | f            | f           | f         |               14 | t        | t        | t          |         2
StatList.create(
    stat_id: 24,
    stat: "Defensive rating",
    default_stat: false,
    collectable: false,
    team_stat: false,
    display_priority: 14,
    advanced: true,
    rankable: true,
    is_percent: true,
    stat_kind: 2,
    hidden: false,
    abbr: "DRtg"
)

## Net rating                          | f            | f           | f         |               15 | t        | t        | t          |         3
StatList.create(
    stat_id: 25,
    stat: "Net rating",
    default_stat: false,
    collectable: false,
    team_stat: false,
    display_priority: 15,
    advanced: true,
    rankable: true,
    is_percent: true,
    stat_kind: 3,
    hidden: false,
    abbr: "NetRtg"
)

## Field goal %                        | t            | f           | f         |                2 | f        | t        | t          |         1
StatList.create(
    stat_id: 26,
    stat: "Field goal %",
    default_stat: true,
    collectable: false,
    team_stat: false,
    display_priority: 2,
    advanced: false,
    rankable: true,
    is_percent: true,
    stat_kind: 1,
    hidden: false,
    abbr: "FG%"
)

## 3 point %                           | t            | f           | f         |                6 | f        | t        | t          |         1
StatList.create(
    stat_id: 27,
    stat: "3 point %",
    default_stat: true,
    collectable: false,
    team_stat: false,
    display_priority: 6,
    advanced: false,
    rankable: true,
    is_percent: true,
    stat_kind: 1,
    hidden: false,
    abbr: "3PT%"
)

## Free throw %                        | t            | f           | f         |                8 | f        | t        | t          |         1
StatList.create(
    stat_id: 28,
    stat: "Free throw %",
    default_stat: true,
    collectable: false,
    team_stat: false,
    display_priority: 8,
    advanced: false,
    rankable: true,
    is_percent: true,
    stat_kind: 1,
    hidden: false,
    abbr: "FT%"
)

######################################

##  Offensive efficiency                | f            | f           | t         |                  | t        |          |            |         1
StatList.create(
    stat_id: 29,
    stat: "Offensive efficiency",
    default_stat: false,
    collectable: false,
    team_stat: true,
    advanced: true,
    stat_kind: 1,
    hidden: false,
    abbr: "OEff"
)

## Defensive efficiency                | f            | f           | t         |                  | t        |          |            |         2
StatList.create(
    stat_id: 30,
    stat: "Defensive efficiency",
    default_stat: false,
    collectable: false,
    team_stat: true,
    advanced: true,
    stat_kind: 2,
    hidden: false,
    abbr: "DEff"
)

## 2 point %                           | t            | f           | f         |                4 |          |          |            |         1
StatList.create(
    stat_id: 31,
    stat: "2 point %",
    default_stat: true,
    collectable: false,
    team_stat: false,
    display_priority: 4,
    stat_kind: 1,
    advanced: false,
    hidden: false
)

## Offensive Rebound %                 | f            | f           | f         |                7 | t        | t        | t          |         2
StatList.create(
    stat_id: 32,
    stat: "Offensive Rebound %",
    default_stat: false,
    collectable: false,
    team_stat: false,
    display_priority: 7,
    advanced: true,
    rankable: true,
    is_percent: true,
    stat_kind: 2,
    hidden: false,
    abbr: "ORB%"
)

## Defensive Rebound %                 | f            | f           | f         |                8 | t        | t        | t          |         2
StatList.create(
    stat_id: 33,
    stat: "Defensive Rebound % ",
    default_stat: false,
    collectable: false,
    team_stat: false,
    display_priority: 8,
    advanced: true,
    rankable: true,
    is_percent: true,
    stat_kind: 2,
    hidden: false,
    abbr: "DRB%"
)

## Total Rebound %                     | f            | f           | f         |                9 | t        | t        | t          |         2
StatList.create(
    stat_id: 34,
    stat: "Total Rebound %",
    default_stat: false,
    collectable: false,
    team_stat: false,
    display_priority: 9,
    advanced: true,
    rankable: true,
    is_percent: true,
    stat_kind: 2,
    hidden: false,
    abbr: "TRB%"
)

## Steal %                             | f            | f           | f         |               10 | t        | t        | t          |         2
StatList.create(
    stat_id: 35,
    stat: "Steal %",
    default_stat: false,
    collectable: false,
    team_stat: false,
    display_priority: 10,
    advanced: true,
    rankable: true,
    is_percent: true,
    stat_kind: 2,
    hidden: false,
    abbr: "STL%"
)

## Block %                             | f            | f           | f         |               11 | t        | t        | t          |         2
StatList.create(
    stat_id: 36,
    stat: "Block %",
    default_stat: false,
    collectable: false,
    team_stat: false,
    display_priority: 11,
    advanced: true,
    rankable: true,
    is_percent: true,
    stat_kind: 2,
    hidden: false,
    abbr: "BLK%"
)

##  Turnover %                          | f            | f           | f         |                6 | t        | t        | t          |         1
StatList.create(
    stat_id: 37,
    stat: "Turnover %",
    default_stat: false,
    collectable: false,
    team_stat: false,
    display_priority: 6,
    advanced: true,
    rankable: true,
    is_percent: true,
    stat_kind: 1,
    hidden: false,
    abbr: "TOV%"
)

## Assist %                            | f            | f           | f         |                5 | t        | t        | t          |         1
StatList.create(
    stat_id: 38,
    stat: "Assist %",
    default_stat: false,
    collectable: false,
    team_stat: false,
    display_priority: 5,
    advanced: true,
    rankable: true,
    is_percent: true,
    stat_kind: 1,
    hidden: false,
    abbr: "AST%"
)

## Offensive Box Plus Minus            | f            | f           | f         |               20 | t        | t        | t          |         1
StatList.create(
    stat_id: 39,
    stat: "Offensive Box Plus Minus",
    default_stat: false,
    collectable: false,
    team_stat: false,
    display_priority: 20,
    advanced: true,
    rankable: true,
    is_percent: true,
    stat_kind: 1,
    hidden: false,
    abbr: "OBPM"
)

## Defensive Box Plus Minus            | f            | f           | f         |               19 | t        | t        | t          |         2
StatList.create(
    stat_id: 40,
    stat: "Defensive Box Plus Minus",
    default_stat: false,
    collectable: false,
    team_stat: false,
    display_priority: 19,
    advanced: true,
    rankable: true,
    is_percent: true,
    stat_kind: 2,
    hidden: false,
    abbr: "DBPM"
)

###########################################

## Box Plus Minus                      | f            | f           | f         |               21 | t        | t        | t          |         3
StatList.create(
    stat_id: 41,
    stat: "Box Plus Minus",
    default_stat: false,
    collectable: false,
    team_stat: false,
    display_priority: 21,
    advanced: true,
    rankable: true,
    is_percent: true,
    stat_kind: 3,
    hidden: false,
    abbr: "BPM"
)

## Possessions                         | f            | f           | t         |                  | t        |          |            |         1
StatList.create(
    stat_id: 42,
    stat: "Possessions",
    default_stat: false,
    collectable: false,
    team_stat: true,
    advanced: true,
    stat_kind: 1,
    hidden: false,
    abbr: "POSS"
)

##  Unadjusted Box Plus Minus           | f            | f           | f         |               18 | t        | t        | t          |         3
StatList.create(
    stat_id: 43,
    stat: "Unadjusted Box Plus Minus",
    default_stat: false,
    collectable: false,
    team_stat: false,
    display_priority: 18,
    advanced: true,
    rankable: true,
    is_percent: true,
    stat_kind: 3,
    hidden: true
)

## Unadjusted Offensive Box Plus Minus | f            | f           | f         |               17 | t        | t        | t          |         1
StatList.create(
    stat_id: 44,
    stat: "Unadjusted Offensive Box Plus Minus",
    default_stat: false,
    collectable: false,
    team_stat: false,
    display_priority: 17,
    advanced: true,
    rankable: true,
    is_percent: true,
    stat_kind: 1,
    hidden: true
)

## Pace                                | f            | f           | t         |                  | t        |          |            |         3
StatList.create(
    stat_id: 45,
    stat: "Pace",
    default_stat: false,
    collectable: false,
    team_stat: true,
    advanced: true,
    stat_kind: 3,
    hidden: false,
    abbr: "Pace"
)

##FT rate                             | f            | f           | f         |                  | t        | t        | t          |         1
StatList.create(
    stat_id: 46,
    stat: "FT rate",
    default_stat: true,
    collectable: false,
    team_stat: true,
    advanced: true,
    rankable: true,
    is_percent: true,
    stat_kind: 1,
    hidden: false,
    abbr: "FT/FGA"
)

## Field goal attempts                 | t            | f           | f         |                  | f        | t        |            |         1
StatList.create(
    stat_id: 47,
    stat: "Field goal attempts",
    default_stat: true,
    collectable: false,
    team_stat: false,
    advanced: false,
    rankable: true,
    is_percent: false,
    stat_kind: 1,
    hidden: false,
    abbr: "FGA"
)

## 3 point attempts                    | t            | f           | f         |                  | f        | t        |            |         1
StatList.create(
    stat_id: 48,
    stat: "3 point attempts",
    default_stat: true,
    collectable: false,
    team_stat: false,
    advanced: false,
    rankable: true,
    stat_kind: 1,
    hidden: false,
    abbr: "3PA"
)

##  Free throw attempts                 | t            | f           | f         |                  | f        | t        |            |         1
StatList.create(
    stat_id: 49,
    stat: "Free throw attempts",
    default_stat: true,
    collectable: false,
    team_stat: false,
    advanced: false,
    rankable: true,
    stat_kind: 1,
    hidden: false,
    abbr: "FTA"
)

StatList.create(
    stat_id: 50,
    stat: "Assist Ratio",
    default_stat: false,
    collectable: false,
    team_stat: true,
    display_priority: 5,
    advanced: true,
    is_percent: true,
    stat_kind: 1,
    hidden: false,
    abbr: "AST Ratio"
)


StatList.create(
    stat_id: 51,
    stat: "Deflections",
    default_stat: false,
    collectable: true,
    team_stat: false,
    display_priority: 13,
    advanced: false,
    rankable: true,
    is_percent: false,
    stat_kind: 2,
    hidden: false,
    abbr: "DEFL"
)


PlayType.create(
    play_type: "Halfcourt"
)

PlayType.create(
    play_type: "Fullcourt"
)

Role.create(
    name: "Player"
)

Role.create(
    name: "Coach"
)

Role.create(
    name: "Manager"
)

Role.create(
    name: "Owner"
)
Role.create(
    name: "Other"
)

Sport.create(
    name: "Basketball"
)