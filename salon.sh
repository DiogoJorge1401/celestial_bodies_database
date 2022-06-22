#!/bin/bash

PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"

echo -e "\n~~~~~ MY SALON ~~~~~\n"

echo -e "Welcome to My Salon, how can I help you?\n"

MAIN_MENU() {
  if [[ $1 ]]; then
    echo -e "\n$1"
  fi

  AVAILABLE_SERVICES=$($PSQL "SELECT service_id, name FROM services ORDER BY service_id")

  if [[ -z $AVAILABLE_SERVICES ]]; then
    echo "Sorry, we don't have any service available right now"
  else
    echo "$AVAILABLE_SERVICES" | while read SERVICE_ID BAR NAME; do
      echo "$SERVICE_ID) $NAME"
    done

    read SERVICE_ID_SELECTED

    if [[ ! $SERVICE_ID_SELECTED =~ ^[0-9]+$ ]]; then
      MAIN_MENU "That is not a number."
    else
      SERV_ID=$($PSQL "SELECT service_id FROM services WHERE service_id = $SERVICE_ID_SELECTED")

      if [[ -z $SERV_ID ]]; then
        MAIN_MENU "I could not find that service. What would you like today?"
      else
        SERV_NAME=$($PSQL "SELECT name FROM services WHERE service_id=$SERV_ID")

        echo -e "\nWhat's your phone number?"

        read CUSTOMER_PHONE

        CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")

        if [[ -z $CUSTOMER_ID ]]; then

          echo -e "\nI don't have a record for that phone number, what's your name?"

          read CUSTOMER_NAME

          INSERT_CUSTOMER_RESULT=$($PSQL "INSERT INTO customers(phone, name) VALUES('$CUSTOMER_PHONE', '$CUSTOMER_NAME')")

          CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")
        else

          CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE customer_id=$CUSTOMER_ID")
        fi

        echo -e "\nWhat $SERVICE_TIME would you like your$SERV_NAME,$CUSTOMER_NAME?"

        read SERVICE_TIME

        INSERT_APPOINTMENT_RESULT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")

        echo -e "\nI have put you down for a$SERV_NAME at $SERVICE_TIME, $CUSTOMER_NAME.\n"
      fi
    fi
  fi

}

MAIN_MENU
