  #!/bin/bash


FETCH_DATA() {
  RESULT=$($PSQL "SELECT * FROM elements LEFT JOIN properties USING(atomic_number) LEFT JOIN types USING(type_id) WHERE atomic_number = $1")
  
  # Empty?
  if [[ -z $RESULT ]]
  then
    OUTPUT_ERROR
  fi

  #echo -e "\nResult is:\n $RESULT"
  echo $RESULT | while read TYPE_ID BAR NUMBER BAR SYMBOL BAR NAME BARE WEIGHT BAR MELTING BAR BOILING BAR TYPE
  do
    #echo "Found $RESULT. Providing text"
    OUTPUT_SUC $BOILING $MELTING $NAME $NUMBER $SYMBOL $TYPE $WEIGHT
  done
}

VIA_NAME() {
# Check number first based on name and then run function with ID
#echo "Providing number for name $1"
NAME_RESULT=$($PSQL "SELECT atomic_number FROM elements WHERE name = '$1'")
#echo "Atomic Number is: $NAME_RESULT"

if [[ -z $NAME_RESULT ]]
then
  OUTPUT_ERROR
fi

FETCH_DATA $NAME_RESULT
}

VIA_SYMBOL() {
# Check number first based on symbol and then run function with ID
#echo "Providing number for symbol $1"
NAME_RESULT=$($PSQL "SELECT atomic_number FROM elements WHERE symbol = '$1'")
#echo "Atomic Number is: $NAME_RESULT"

if [[ -z $NAME_RESULT ]]
then
  OUTPUT_ERROR
fi

FETCH_DATA $NAME_RESULT
}


OUTPUT_SUC() {
BOILING=$1
MELTING=$2
NAME=$3
NUMBER=$4
SYMBOL=$5
TYPE=$6
WEIGHT=$7

echo -e "The element with atomic number $NUMBER is $NAME ($SYMBOL). It's a $TYPE, with a mass of $WEIGHT amu. $NAME has a melting point of $MELTING celsius and a boiling point of $BOILING celsius."
}

OUTPUT_ERROR() {
echo "I could not find that element in the database."
exit
}

PSQL="psql -X --username=freecodecamp --dbname=periodic_table --tuples-only -c"

if [[ -z $1 ]]
then
  echo "Please provide an element as an argument."
else
  if [[ $1 =~ ^[0-9]+$ ]]
  then
    #echo "-Number identified!"
    FETCH_DATA $1
  elif [[ $1 =~ ^[A-Z][a-z]{2,}+ ]]
  then
    VIA_NAME $1
  else
    VIA_SYMBOL $1
  fi 
fi
