#! /bin/bash
PSQL="psql --username=freecodecamp --dbname=periodic_table -t --no-align -c"

if [[ $1 ]]
then

    if [[ $1 =~ ^[0-9]+$ ]]
    then
        # get atomic_number
        ATOMIC_NUMBER=$($PSQL "SELECT atomic_number FROM elements WHERE atomic_number=$1")

        # get name
        NAME=$($PSQL "SELECT name FROM elements WHERE atomic_number=$1")

        # get symbol
        SYMBOL=$($PSQL "SELECT symbol FROM elements WHERE atomic_number=$1")

    elif [[ -z $ATOMIC_NUMBER ]]
    then
        # get symbol
        SYMBOL=$($PSQL "SELECT symbol FROM elements WHERE symbol='$1'")

        # get atomic_number
        ATOMIC_NUMBER=$($PSQL "SELECT atomic_number FROM elements WHERE symbol='$1'")

        # get name
        NAME=$($PSQL "SELECT name FROM elements WHERE symbol='$1'")

    fi

    if [[ -z $ATOMIC_NUMBER ]]
    then
        # get name
        NAME=$($PSQL "SELECT name FROM elements WHERE name='$1';")

        # get atomic_number
        ATOMIC_NUMBER=$($PSQL "SELECT atomic_number FROM elements WHERE name='$1';")

        # get symbol
        SYMBOL=$($PSQL "SELECT symbol FROM elements WHERE name='$1';")

    fi


    # if element not found
    if [[ -z $ATOMIC_NUMBER ]]
    then
        # print message
        echo "I could not find that element in the database."

    else
        # get the rest of the info
        MORE_INFO=$($PSQL "SELECT type, atomic_mass, melting_point_celsius, boiling_point_celsius FROM elements FULL JOIN properties USING (atomic_number) FULL JOIN types USING (type_id) WHERE atomic_number=$ATOMIC_NUMBER")

        # read more info into variables
        echo "$MORE_INFO" | while IFS='|' read TYPE ATOMIC_MASS MELTING_POINT BOILING_POINT
        do
          echo -e "The element with atomic number $ATOMIC_NUMBER is $NAME ($SYMBOL). It's a $TYPE, with a mass of $ATOMIC_MASS amu. $NAME has a melting point of $MELTING_POINT celsius and a boiling point of $BOILING_POINT celsius."
        done

    fi

else
    echo "Please provide an element as an argument."

fi