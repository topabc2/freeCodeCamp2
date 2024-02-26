#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.

echo "$($PSQL "TRUNCATE teams, games;")"

cat games.csv | while IFS="," read YEAR ROUND WINNER OPPONENT WINNER_GOALS OPPONENT_GOALS
do

  if [[ $YEAR != year ]]
  then

    QUERY_COUNT="$($PSQL "SELECT COUNT(team_id) FROM teams;")"

    T_1=false
    T_2=false
    for (( I = 0; I < $QUERY_COUNT; I++))
    do
      QUERY_1="$($PSQL "SELECT name FROM teams WHERE name ILIKE '%$WINNER%';")"
      QUERY_2="$($PSQL "SELECT name FROM teams WHERE name ILIKE '%$OPPONENT%';")"
      if [[ $QUERY_1 == $WINNER ]]
      then
        T_1=true
      fi
      if [[ $QUERY_2 == $OPPONENT ]]
      then
        T_2=true
      fi
    done

    if [[ $T_1 == false ]]
    then
      echo "$($PSQL "INSERT INTO teams(name) VALUES('$WINNER');")"
    fi

    if [[ $T_2 == false ]]
    then
      echo "$($PSQL "INSERT INTO teams(name) VALUES('$OPPONENT');")"
    fi

    WINNER_ID="$($PSQL "SELECT team_id FROM teams WHERE name='$WINNER'")"
    OPPONENT_ID="$($PSQL "SELECT team_id FROM teams WHERE name='$OPPONENT'")"
    echo "$($PSQL "INSERT INTO games(year, round, winner_goals, opponent_goals, winner_id, opponent_id) VALUES($YEAR, '$ROUND', $WINNER_GOALS, $OPPONENT_GOALS, $WINNER_ID, $OPPONENT_ID);")"

  fi

done