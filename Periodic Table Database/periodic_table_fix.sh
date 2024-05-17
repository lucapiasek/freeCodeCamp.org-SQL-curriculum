#! /bin/bash
PSQL="psql --username=freecodecamp --dbname=periodic_table -t --no-align -c"

RENAME_WEIGHT_COLUMN=$($PSQL "ALTER TABLE properties RENAME COLUMN weight TO atomic_mass;")

RENAME_M_POINT_COLUMN=$($PSQL "ALTER TABLE properties RENAME COLUMN melting_point TO melting_point_celsius")

RENAME_B_POINT_COLUMN=$($PSQL "ALTER TABLE properties RENAME COLUMN boiling_point TO boiling_point_celsius")

SET_M_POINT_C_NOT_NULL=$($PSQL "ALTER TABLE properties ALTER COLUMN boiling_point_celsius SET NOT NULL")

SET_B_POINT_C_NOT_NULL=$($PSQL "ALTER TABLE properties ALTER COLUMN melting_point_celsius SET NOT NULL")

SET_SYMBOL_COLUMN_UNIQUE=$($PSQL "ALTER TABLE elements ADD UNIQUE (symbol)")

SET_NAME_COLUMN_UNIQUE=$($PSQL "ALTER TABLE elements ADD UNIQUE (name)")

SET_NAME_ELEMENTS_NOT_NULL=$($PSQL "ALTER TABLE elements ALTER COLUMN name SET NOT NULL")

SET_SYMBOL_ELEMENTS_NOT_NULL=$($PSQL "ALTER TABLE elements ALTER COLUMN symbol SET NOT NULL")

ATOMIC_NUMBER_FROM_PROPERTIES_AS_FOREIGN_KEY=$($PSQL "ALTER TABLE properties ADD FOREIGN KEY (atomic_number) REFERENCES elements (atomic_number)")

CREATE_TYPES_TABLE=$($PSQL "CREATE TABLE types (type_id SERIAL PRIMARY KEY)")

ADD_TYPE_TO_TYPES=$($PSQL "ALTER TABLE types ADD COLUMN type VARCHAR (30) NOT NULL")

#GET_TYPE_ID_FROM_PROPERTIES=$($PSQL "")
INSERT_INTO_TYPES_TYPE=$($PSQL "INSERT INTO types (type) VALUES ('nonmetal'),('metalloid'),('metal')")

PROPERTIES_TABLE_ADD_FOREIGN_KEY=$($PSQL "ALTER TABLE properties ADD COLUMN type_id INT REFERENCES types (type_id)")

INSERT_INTO_ELEMENTS_FLUORINE_AND_NEON=$($PSQL "INSERT INTO elements (atomic_number, name, symbol) VALUES (9, 'Fluorine', 'F'),(10, 'Neon', 'Ne')")

INSERT_INTO_PROPERTIES_FLUORINE_AND_NEON=$($PSQL "INSERT INTO properties (atomic_number, atomic_mass, melting_point_celsius, boiling_point_celsius, type) VALUES(9, 18.998, -220, -188.1, 'nonmetal'),(10, 20.18, -248.6, -246.1, 'nonmetal')")

#INSERT _TYPE_ID_INTO_PROPERTIES
TYPES=$($PSQL "SELECT atomic_number, type FROM properties")
echo "$TYPES" | while  IFS='|' read ATOMIC_NUMBER TYPE
do
    # get type_id from types
    TYPE_ID=$($PSQL "SELECT type_id FROM types WHERE type='$TYPE'")

    # update properties table
    UPDATE_RESULT=$($PSQL "UPDATE properties SET type_id=$TYPE_ID WHERE atomic_number=$ATOMIC_NUMBER")

done

ADD_NOT_NULL_PROPERTIES_TYPE_ID=$($PSQL "ALTER TABLE properties ALTER COLUMN type_id SET NOT NULL")

CAPITALIZE_FIRST_LETTER_SYMBOL=$($PSQL "UPDATE elements SET symbol=INITCAP(symbol)")

REMOVE_TRAILING_ZEROS=$($PSQL "ALTER TABLE properties ALTER COLUMN atomic_mass TYPE REAL")

REMOVE_MOTANIUM_FROM_PROPERTIES=$($PSQL "DELETE FROM properties WHERE atomic_number=1000")

REMOVE_MOTANIUM_FROM_ELEMENTS=$($PSQL "DELETE FROM elements WHERE atomic_number=1000")

REMOVE_FROM_PROPERTIES_TYPES_COLUMN=$($PSQL "ALTER TABLE properties DROP COLUMN type")
