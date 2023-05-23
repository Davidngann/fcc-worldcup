#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.

#clean table
echo $($PSQL "TRUNCATE TABLE games, teams")

#loop through the CSV file
cat games.csv | while IFS=',' read YEAR ROUND WINNER OPPONENT WINNER_GOALS OPPONENT_GOALS
do
    #ignore the csv header
    if [[ $YEAR != "year" ]]
    then
      #insert data to teams table
      #get team from winner
      WINNER_ID=$($PSQL "SELECT team_id FROM teams where name='$WINNER'")
      #if not found, insert into teams table
      if [[ -z $WINNER_ID ]]
      then
        echo $($PSQL "INSERT INTO teams VALUES (DEFAULT, '$WINNER')")
      fi
      
      #get team from opponent
      OPPONENT_ID=$($PSQL "SELECT team_id FROM teams where name='$OPPONENT'")
      #if not found, insert into teams table
      if [[ -z $OPPONENT_ID ]]
      then
        echo $($PSQL "INSERT INTO teams VALUES (DEFAULT, '$OPPONENT')")
      fi
      
      #get game_id
      GAME_ID=$($PSQL "SELECT game_id FROM games WHERE year=$YEAR AND round='$ROUND' AND winner_id=(SELECT team_id FROM teams WHERE name='$WINNER')")
      
      #if not found, insert into games table
      if [[ -z $GAME_ID ]]
      then
        echo $($PSQL "INSERT INTO games (year, round, winner_id, opponent_id, winner_goals, opponent_goals) VALUES ($YEAR, '$ROUND', (SELECT team_id FROM teams WHERE name='$WINNER'), (SELECT team_id FROM teams WHERE name='$OPPONENT'), $WINNER_GOALS, $OPPONENT_GOALS)")
      fi
    fi
done
