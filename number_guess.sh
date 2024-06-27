#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

echo -e "\nEnter your username:"
read USERNAME

USERNAME_RESULT=$($PSQL "SELECT username FROM users WHERE username='$USERNAME';")

if [[ -z $USERNAME_RESULT ]]
then
  echo -e "\nWelcome, $USERNAME! It looks like this is your first time here."
  NEW_USER=$($PSQL "INSERT INTO users(username) VALUES('$USERNAME');")
  BEST_GAME=0
else 
  NUMB_GAMES=$($PSQL "SELECT games_played FROM users WHERE username='$USERNAME';")
  BEST_GAME=$($PSQL "SELECT best_game FROM users WHERE username='$USERNAME';")
  echo -e "\nWelcome back, $USERNAME! You have played $NUMB_GAMES games, and your best game took $BEST_GAME guesses."
fi

((NUMB_GAMES++))
UPDATE_USER_GAME=$($PSQL "UPDATE users SET games_played=$NUMB_GAMES WHERE username='$USERNAME';")

WINNING_NUMBER=$(( 1 + $RANDOM % 1000 ))
GUESSES=0

echo -e "\nGuess the secret number between 1 and 1000:"
read GUESS

until [[ $GUESS == $WINNING_NUMBER ]]
do
  if [[ ! $GUESS =~ ^[0-9]+$ ]]
  then
    echo -e "\nThat is not an integer, guess again:"
    ((GUESSES++))
    read GUESS
  else
    if [[ $GUESS -gt $WINNING_NUMBER ]]
    then
      echo -e "\nIt's lower than that, guess again:"
      ((GUESSES++))
      read GUESS
    else
      echo -e "\nIt's higher than that, guess again:"
      ((GUESSES++))
      read GUESS
    fi
  fi
done

((GUESSES++))
echo -e "\nYou guessed it in $GUESSES tries. The secret number was $WINNING_NUMBER. Nice job!"


if [[ $BEST_GAME == 0 ]]
then
  UPDATE_USER_GAME=$($PSQL "UPDATE users SET games_played=$NUMB_GAMES, best_game=$GUESSES WHERE username='$USERNAME';")
else
  if [[ $GUESSES < $BEST_GAME ]]
  then
    BEST_GAME=$GUESSES
    UPDATE_USER_GAME=$($PSQL "UPDATE users SET games_played=$NUMB_GAMES, best_game=$BEST_GAME WHERE username='$USERNAME';")
  fi
fi