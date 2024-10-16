#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.
declare -A teams

# Leer el archivo CSV directamente (games.csv)
while IFS=',' read -r year round winner opponent winner_goals opponent_goals
do
    # Omitir la cabecera
    if [ "$year" != "year" ]; then
        # Añadir los equipos a un array asociativo para eliminar duplicados
        teams["$winner"]=1
        teams["$opponent"]=1
    fi
done < games.csv

# Conectarse a PostgreSQL y agregar los equipos únicos
for team in "${!teams[@]}"
do
    $PSQL "INSERT INTO teams (name) VALUES ('$team') ON CONFLICT (name) DO NOTHING;"
done

while IFS=',' read -r year round winner opponent winner_goals opponent_goals
do
  # Omitir la cabecera
  if [[ "$year" != "year" ]]
  then
    # Obtener el winner_id desde la tabla teams
    winner_id=$($PSQL "SELECT team_id FROM teams WHERE name='$winner';")
    
    # Obtener el opponent_id desde la tabla teams
    opponent_id=$($PSQL "SELECT team_id FROM teams WHERE name='$opponent';")
    
    # Insertar el juego en la tabla games
    if [[ -n $winner_id && -n $opponent_id ]]
    then
      $PSQL "INSERT INTO games(year, round, winner_id, opponent_id, winner_goals, opponent_goals) VALUES($year, '$round', $winner_id, $opponent_id, $winner_goals, $opponent_goals);"
    fi
  fi
done < games.csv