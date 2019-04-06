#!/bin/bash


#para dar formato
ROJO=`tput setaf 1`
VERDE=`tput setaf 2`
AMARILLO=`tput setaf 3`
RESET=`tput sgr0`
SUBR=`tput smul`


#para cálculos resultados
totalLineas=0
lineasDiferentes=0
porcentajeLineas=0
MAIN_NAME=main

usage() { echo "Usage: $0 [-v]" 1>&2; exit 1; }

# Comprobar parametros de entrada
VERBOSE=false
while getopts "v" opt; do
    case "$opt" in
      v)
          VERBOSE=true
          echo VERBOSETRUE
          ;;
      *)
          usage
          ;;
    esac
done
MAIN="./"$MAIN_NAME

ficherosEntrada=("script_minimos/create" "script_minimos/new" "script_minimos/vote" "script_minimos/remove")
ficherosRef=("script_minimos/create_ref" "script_minimos/new_ref" "script_minimos/vote_ref" "script_minimos/remove_ref")


# Funcion para comprobar la salida del programa
# Parametros de entrada:
#   - salida verbosa
# Parametros de salida:
#   - Exito (1) o fallo (0) en la comprobacion
function check_output {
    VERBOSE=$1

    rm -f *.o *.ppu ${MAIN}

    printf "${AMARILLO}Running script..."



    printf "\n${AMARILLO}Compiling "$MAIN_NAME"...${RESET}\n\n"

    fpc ${MAIN}

    if [ -f ${MAIN} ]
    then
        allOK=1
        printf "\n${AMARILLO}Checking "$MAIN_NAME" program output...\n${RESET}"
	    printf "\n${SUBR}Input file${RESET}                          ${SUBR}Result${RESET}  ${SUBR}Notes${RESET}\n"
      for index in ${!ficherosEntrada[*]}
	    do
            nombre=${ficherosEntrada[$index]}
            ficheroEntrada="$nombre".txt
            ficheroReferencia=${ficherosRef[$index]}.txt
            ficheroSalida="$nombre"_output.txt
            ficheroDiff="$nombre"_diff.txt
            ${MAIN} $ficheroEntrada > $ficheroSalida
            diff -w -B -b -y --suppress-common-lines --width=100 $ficheroReferencia $ficheroSalida > $ficheroDiff
            iguales=$(stat -c%s $ficheroDiff)
            if [ "$ficheroEntrada" = "" ]; then
            ficheroEntrada="(no input file)"
            fi
                if [ ${iguales} -eq "0" ]
                then
                    printf "%-35s %-12s %s\n" "$ficheroEntrada" "${VERDE}OK"  "${RESET}"
                else
                    printf "%-35s %-12s %s\n" "$ficheroEntrada" "${ROJO}FAIL" "${RESET}Check ${ficheroReferencia} and ${ficheroSalida}"
                    allOK=0
                    if  ${VERBOSE}
                    then
                        printf '\nFile: %-39s | File: %s\n' $ficheroReferencia $ficheroSalida
                        printf '=%.0s' {1..100}
                        printf '\n'
                        cat ${ficheroDiff}
                        printf '\n'
                    fi
                fi
	    	rm $ficheroDiff
	    done
    else
   		allOK=0
	    printf "\n${ROJO}Compilation failed${RESET}"
    fi
	printf "\n\n"
    return ${allOK}
}


#Comprobar que existen en path actual los ficheros output de referencia
#(sino, tal y como está el script da un OK a pesar de mostrar un error en el diff)
for file in ${ficherosRef[@]}
do
	if [ ! -f "${file}.txt" ]
	then
		printf "${ROJO}Please add the reference file ${file}.txt to the script_minimos folder${RESET}\n"
		exit 1
	fi
done


check_output ${VERBOSE}
RESULT_OK=$?


printf "${AMARILLO}Global result: "
if  [ ${RESULT_OK} -eq 1 ]
then
	printf "${VERDE}OK${RESET}"
else
	printf "${ROJO}FAIL${RESET}"
fi
printf "\n\n"
