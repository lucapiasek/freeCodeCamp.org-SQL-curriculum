#! /bin/bash
PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

NUMBER_TO_GUESS=$(( $(( RANDOM % 1000 )) + 1 ))

echo "Enter your username:"
read USERNAME

# get user_id from database
USER_ID=$($PSQL "SELECT user_id FROM users WHERE username='$USERNAME'")

# check if username is in database
if [[ -z $USER_ID ]]
then
  # print welcome message
  echo "Welcome, $USERNAME! It looks like this is your first time here."
  
  # insert new user to database
  INSERT_NEW_USER=$($PSQL "INSERT INTO users (username) VALUES('$USERNAME')")

  # get new user_id
  USER_ID=$($PSQL "SELECT user_id FROM users WHERE username='$USERNAME'")

else
  # get player games info 
  GAMES_INFO=$($PSQL "SELECT COUNT(game_id), MIN(number_of_guesses) FROM users INNER JOIN games USING (user_id) WHERE user_id=$USER_ID")

  # read number of games and best game guesses
  echo "$GAMES_INFO" | while IFS='|' read GAMES_PLAYED BEST_GAME
  do
  
    # echo welcome message
    echo -e "Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."

  done

fi

GUESS_NUMBER () {

  # check if it's first time running
  if [[ ! $1 ]]
  then

    # print welcome message
    echo "Guess the secret number between 1 and 1000:"

    # start counting guesses
    NUMBER_OF_GUESSES=1
      
  else
    
    # print the message from previous guess
    echo "$1"

  fi

  read USER_NUMBER

  # check if number is integer
  if [[ $USER_NUMBER =~ ^[0-9]+$ ]]
  then

    # check if number is correct
    if [[ $USER_NUMBER == $NUMBER_TO_GUESS ]]
    then

      # enter the winning game to database
      INSERT_WINNING_GAME=$($PSQL "INSERT INTO games (number_of_guesses, user_id) VALUES ($NUMBER_OF_GUESSES, $USER_ID)")

      #print winning message
      echo "You guessed it in $NUMBER_OF_GUESSES tries. The secret number was $NUMBER_TO_GUESS. Nice job!"
      
    elif [[ $USER_NUMBER < $NUMBER_TO_GUESS ]]
    then

      # increment number of guesses
      NUMBER_OF_GUESSES=$(( $NUMBER_OF_GUESSES + 1 ))

      # if number was to low, guess again
      GUESS_NUMBER "It's higher than that, guess again:"

    else

      #increment number of guesses
      NUMBER_OF_GUESSES=$(( $NUMBER_OF_GUESSES + 1 ))

      # number was too high, guess again
      GUESS_NUMBER "It's lower than that, guess again:"

    fi

  else

    # increase number of guesses
    NUMBER_OF_GUESSES=$(( $NUMBER_OF_GUESSES + 1 ))

    # if it's not an integer, try again
    GUESS_NUMBER "That is not an integer, guess again:"

  fi

}

  GUESS_NUMBER
