#! /bin/bash
PSQL="psql --username=freecodecamp --dbname=salon --tuples-only -c"

echo -e "\n~~~~~ MY SALON ~~~~~\n"

MAIN_MENU () {
    SERVICES=$($PSQL "SELECT service_id, name FROM services")

    # check if there is message to main menu
    if [[ $1 ]]
    then
        echo -e "\n$1"

    # if not then
    else
        echo -e "Welcome to My Salon, how can I help you?\n"

    fi

    echo "$SERVICES" | while read SERVICE_ID BAR SERVICE_NAME
    do
        echo "$SERVICE_ID) $SERVICE_NAME"
    done

    read SERVICE_ID_SELECTED

    # get selected service id
    SERVICE_ID=$($PSQL "SELECT service_id FROM services WHERE service_id=$SERVICE_ID_SELECTED")

    # check if service exists
    if [[ -z $SERVICE_ID ]]
    then
        # if not, send to order menu
        MAIN_MENU "I could not find that service. What would you like today?"

    else
        # ask for phone number
        echo "What's your phone number?"
        read CUSTOMER_PHONE

        # get customer_id
        CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")

        # check if customer exists
        if [[ -z $CUSTOMER_ID ]]
        then
            # if not, ask for name
            echo "I don't have a record for that phone number, what's your name?"
            read CUSTOMER_NAME

            # insert customer into base
            INSERT_CUSTOMER_RESULT=$($PSQL "INSERT INTO customers(phone, name) VALUES('$CUSTOMER_PHONE','$CUSTOMER_NAME')")

            #get new customer id
            CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")

        else
            #get customer name
            CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone='$CUSTOMER_PHONE'")
        fi

        # ask for time of service
        echo -e "\nWhat time would you like your color, $(echo $CUSTOMER_NAME | sed -E 's/^ *| *$//g')?"
        read SERVICE_TIME

        # insert appointment into base
        INSERT_APPOINTMENT_RESULT=$($PSQL "INSERT INTO appointments (customer_id, service_id, time) VALUES($CUSTOMER_ID, $SERVICE_ID, '$SERVICE_TIME')")

        # get selected service name
        SERVICE=$($PSQL "SELECT name FROM services WHERE service_id=$SERVICE_ID")
        echo -e "\nI have put you down for a $(echo $SERVICE | sed -E 's/^ *| *$//g') at $(echo $SERVICE_TIME | sed -E 's/^ *| *$//g'), $(echo $CUSTOMER_NAME | sed -E 's/^ *| *$//g')."
    fi

}

MAIN_MENU