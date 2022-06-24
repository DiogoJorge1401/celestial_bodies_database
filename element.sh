#! /bin/bash

PSQL="psql -X --username=freecodecamp --dbname=periodic_table --tuples-only -c"

NOT_FOUND_MESSAGE() {
  echo "I could not find that element in the database."
}

SHOW_ELEMENT() {
  echo $ELEMENT_RESULT | while IFS=' | ' read ATOMIC_NUMBER ELEMENT_NAME ELEMENT_SYMBOL ELEMENT_TYPE ATOMIC_MASS MELTING_POINT BOILING_POINT; do
    echo "The element with atomic number $ATOMIC_NUMBER is $ELEMENT_NAME ($ELEMENT_SYMBOL). It's a $ELEMENT_TYPE, with a mass of $ATOMIC_MASS amu. $ELEMENT_NAME has a melting point of $MELTING_POINT celsius and a boiling point of $BOILING_POINT celsius."
  done
}

if [[ -z $1 ]]; then
  echo 'Please provide an element as an argument.'
else

  if [[ $1 =~ ^[0-9]+$ ]]; then
    ELEMENT_RESULT=$($PSQL "SELECT atomic_number, name, symbol, type, atomic_mass, melting_point_celsius, boiling_point_celsius FROM properties FULL JOIN elements USING(atomic_number) FULL JOIN types USING(type_id) WHERE atomic_number = $1;")

    if [[ -z $ELEMENT_RESULT ]]; then
      NOT_FOUND_MESSAGE
    else
      SHOW_ELEMENT $ELEMENT_RESULT
    fi

  else
    ELEMENT_RESULT=$($PSQL "SELECT atomic_number, name, symbol, type, atomic_mass, melting_point_celsius, boiling_point_celsius FROM properties FULL JOIN elements USING(atomic_number) FULL JOIN types USING(type_id) WHERE symbol = '$1' or name = '$1';")

    if [[ -z $ELEMENT_RESULT ]]; then
      NOT_FOUND_MESSAGE
    else
      SHOW_ELEMENT $ELEMENT_RESULT
    fi

  fi
fi