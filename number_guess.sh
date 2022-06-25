#! /bin/bash

PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

echo "Enter your username:"
read USERNAME

USERNAME_AVAIL=$($PSQL "SELECT username FROM users WHERE username = '$USERNAME'")

if [[ -z $USERNAME_AVAIL ]]; then
  INSERT_USER=$($PSQL "INSERT INTO users(username) VALUES('$USERNAME')")

  echo "Welcome, $USERNAME! It looks like this is your first time here."
else
  BEST_GAME=$($PSQL "SELECT best_game FROM users WHERE username = '$USERNAME'")

  GAMES_PLAYED=$($PSQL "SELECT games_played FROM users WHERE username = '$USERNAME'")

  echo "Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
fi

RANDOM_NUM=$(($RANDOM % 1000 + 1))

GUESS=1

echo "Guess the secret number between 1 and 1000:"

while read NUM; do

  if [[ ! $NUM =~ ^[0-9]+$ ]]; then
    echo "That is not an integer, guess again:"

  else

    if [[ $NUM != $RANDOM_NUM ]]; then

      if [[ $NUM < $RANDOM_NUM ]]; then
        echo "It's higher than that, guess again:"
      else
        echo "It's lower than that, guess again:"
      fi

    else
      break
    fi

  fi

  GUESS=$((GUESS + 1))

done

echo "You guessed it in $GUESS tries. The secret number was $RANDOM_NUM. Nice job!"

if [[ -z $GAMES_PLAYED ]]; then
  GAMES_PLAYED=0
  BEST_GAME=$GUESS

else
  if [[ $GUESS < $BEST_GAME ]]; then
    BEST_GAME=$BEST_GAME
  fi
fi

GAMES_PLAYED=$((GAMES_PLAYED + 1))

INSERT_USER_RESULT=$($PSQL "UPDATE users SET games_played = $GAMES_PLAYED, best_game = $BEST_GAME WHERE username = '$USERNAME'")
