#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.
#This script adds data from games.csv file into worldcup database

echo $($PSQL "TRUNCATE TABLE teams, games")
cat games.csv | while IFS="," read YEAR ROUND WINNER OPPONENT WINNER_GOALS OPPONENT_GOALS
do
	if [[ $YEAR != 'year' ]]
	then 
		#check if the winning team is in database (get id)
		WINNER_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$WINNER'")

		#if not insert it, then get id again
		if [[ -z $WINNER_ID ]]
		then
			RESULT=$($PSQL "INSERT INTO teams(name) VALUES('$WINNER');")
      if [[ $RESULT = 'INSERT 0 1' ]]
      then
			  echo Inserted into teams: $WINNER
      fi
      WINNER_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$WINNER'")
		fi
	
		#check if the opponent team is in database (get id)
		OPPONENT_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$OPPONENT'")

		#if not insert it, then get id again
		if [[ -z $OPPONENT_ID ]]
		then
			RESULT=$($PSQL "INSERT INTO teams(name) VALUES('$OPPONENT');")
      if [[ $RESULT = 'INSERT 0 1' ]]
      then
			  echo Inserted into teams: $OPPONENT
      fi
		  OPPONENT_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$OPPONENT'")
		fi

		#insert vars into games table 
		RESULT=$($PSQL "INSERT INTO games(year, round, winner_id, opponent_id, winner_goals, opponent_goals) VALUES($YEAR, '$ROUND', $WINNER_ID, $OPPONENT_ID, $WINNER_GOALS, $OPPONENT_GOALS);")
    if [[ $RESULT = 'INSERT 0 1' ]]
    then
		  echo Inserted into games: $YEAR, $ROUND, $WINNER_ID, $OPPONENT_ID, $WINNER_GOALS, $OPPONENT_GOALS
    fi
	fi
done
