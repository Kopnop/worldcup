#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.
echo $($PSQL "TRUNCATE games, teams")
cat games.csv | while IFS=',' read YEAR ROUND WINNER OPP WINNER_GOALS OPP_GOALS
do
  if [[ $YEAR != year ]]
  then
    #get winner_id
    WINNER_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$WINNER'")
    #get loser_id
    OPP_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$OPP'")
    #if winner null    
    if [[ -z $WINNER_ID ]]
    then
      #insert winner
      INSERT_WINNER_OUTPUT=$($PSQL "INSERT INTO teams(name) VALUES('$WINNER')")
      if [[ $INSERT_WINNER_OUTPUT = 'INSERT 0 1' ]]
      then
        echo Inserted into teams: $WINNER
        WINNER_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$WINNER'")
      fi
    fi
    #if opp null
    if [[ -z $OPP_ID ]]
    then
      #insert opp
      INSERT_OPP_OUTPUT=$($PSQL "INSERT INTO teams(name) VALUES('$OPP')")
      if [[ $INSERT_OPP_OUTPUT = 'INSERT 0 1' ]]
      then
        echo Inserted into teams: $OPP
        OPP_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$OPP'")
      fi
    fi
    
    #insert game
    INSERT_GAME_OUTPUT=$($PSQL "INSERT INTO games(year, round, winner_id, opponent_id, winner_goals, opponent_goals)
                                 VALUES($YEAR, '$ROUND', $WINNER_ID, $OPP_ID, $WINNER_GOALS, $OPP_GOALS)")
    echo Inserted into games: $YEAR $ROUND: $WINNER vs $OPP 
  fi
done
