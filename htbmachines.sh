#!/bin/bash

#Colours
greenColour="\e[0;32m\033[1m"
endColour="\033[0m\e[0m"
redColour="\e[0;31m\033[1m"
blueColour="\e[0;34m\033[1m"
yellowColour="\e[0;33m\033[1m"
purpleColour="\e[0;35m\033[1m"
turquoiseColour="\e[0;36m\033[1m"
grayColour="\e[0;37m\033[1m"

#Variables globales
main_url="https://htbmachines.github.io/bundle.js"

#Functions
function ctrl_c() {
  echo -e "\n\n${redColour} [!] Terminado ...${endColour}\n"
  tput cnorm && exit 1
}

function helpPanel(){
  echo -e "\n${yellowColour}[+]${endColour} ${grayColour}Use:${endColour}\n" 
  echo -e "\t${purpleColour}u)${endColour} ${grayColour}Descargar o actualizar archivos necesarios${endColour}"
  echo -e "\t${purpleColour}m)${endColour} ${grayColour}Buscar por un nombre de máquina${endColour}"
  echo -e "\t${purpleColour}i)${endColour} ${grayColour}Busqueda por dirección IP${endColour}"
  echo -e "\t${purpleColour}d)${endColour} ${grayColour}Buscar por dificultad${endColour}"
  echo -e "\t${purpleColour}o)${endColour} ${grayColour}Busqueda por sistema operativo${endColour}"
  echo -e "\t${purpleColour}s)${endColour} ${grayColour}Busqueda por skill${endColour}"  
  echo -e "\t${purpleColour}h)${endColour} ${grayColour}Mostrar este panel de ayuda${endColour}\n"
}

function machineExists(){
  name="$1"
  machines="$(cat bundle.js | grep name | awk 'NF{print $NF}' | tr -d '"' | tr -d ',')"
  for machine in $machines; do 
    if [[ "$name" == "$machine" ]]; then
       return 0 
    fi 
  done 
  return 1
}

function searchMachine(){
 #$1 hace referencia al argumento de la funcion 
 machineName="$1"
 #Para colorear cada línea habría que definir una variable para cada una y grepear por ello -> Se mantiene así para ver ejemplo de filtrado por tramo con grep!!!
 echo -e "${purpleColour}[+]${endColour} ${grayColour}Listando propiedades de la maquina ${blueColour}$machineName${endColour} ${grayColour}:${endColour}\n"
 cat bundle.js | awk "/name: \"$machineName\"/, /resuelta:/" | grep -vE "id:|sku:|resuelta:" | tr -d '"' | tr -d ',' | sed 's/^ *//'
}

function updateFiles(){
  tput civis
  if [ ! -f bundle.js ]; then
    echo -e "${purpleColour}[+]${endColour} ${grayColour}Descargando recursos necesarios...${endColour}\n"
    sleep 1
    curl -s -X GET $main_url | js-beautify > bundle.js

    echo -e "${purpleColour}[+]${endColour} ${grayColour}Descarga completada con éxito${endColour}\n"

  else
    echo -e "${purpleColour}[+]${endColour} ${grayColour}Comprobando actualizaciones pendientes...${endColour}\n"
    sleep 1

    curl -s -X GET $main_url | js-beautify > bundle_temp.js
    #Definimos una variable a temporal
    md5_temp_value=$(md5sum bundle_temp.js | awk '{print $1}')
    md5_original_value=$(md5sum bundle.js | awk '{print $1}')

    if [ "$md5_original_value" == "$md5_temp_value" ]; then
      echo -e "${purpleColour}[+]${endColour} ${grayColour}No hay actualizaciones disponibles, todo está al día${endColour}\n"
      rm bundle_temp.js
    else
      echo -e "${purpleColour}[+]${endColour} ${grayColour}Se han encontrado actualizaciones, actualizando archivos...${endColour}\n"
      sleep 1

      rm bundle.js && mv bundle_temp.js bundle.js

      echo -e "${purpleColour}[+]${endColour} ${grayColour}Actualización realizada con éxito${endColour}\n"
    fi
  fi
  tput cnorm
  
}

function searchIp(){
  ip="$1"
  nombre_maquina_ip="$(cat bundle.js | grep \"$ip\" -B 3 | grep "name: " | awk 'NF{print $NF}' | tr -d '"' | tr -d ',')"
  if machineExists "$nombre_maquina_ip"; then
    echo -e "\n${purpleColour}[+]${endColour} ${grayColour} El nombre de la máquina con la IP: ${blueColour}$ip${endColour} ${grayColour}es${endColour} ${redColour}$nombre_maquina_ip${endColour}\n"
  else
    echo -e "\n${redColour}[!] No existe ninguna máquina con la IP:${endColour} ${blueColour}$ip${endColour}\n"
  fi
}

function searchYoutubeLink(){
  machineName="$1"
  link="$(cat bundle.js | awk "/name: \"$machineName\"/, /resuelta:/" | grep -vE "id:|sku:|resuelta:" | tr -d '"' | tr -d ',' | sed 's/^ *//' | grep youtube | awk 'NF{print $NF}')"
  if machineExists "$machineName"; then
    echo -e "\n${purpleColour}[+]${endColour} ${grayColour} El link para la máquina ${blueColour}$machineName${endColour} ${grayColour}es${endColour} ${redColour}$link${endColour}\n"
  else
    echo -e "\n${redColour}[!] No existe ninguna máquina con el nombre:${endColour} ${blueColour}$machineName${endColour}\n"
  fi

}

function searchDifficulty(){
  difficulty="$1"
  machine_names="$(cat bundle.js | grep "dificultad: \"$difficulty\"" -B5 | grep name | awk 'NF{print $NF}' | tr -d '"' | tr -d ',' | column)"
  if [ "$dificulty" == "Insane" ]; then
    echo -e "\n${grayColour}[+] Dificultad: ${endColour} ${purpleColour}$difficulty${endColour}\n"
    echo -e "\n$machine_names\n"
  elif [ "$dificulty" == "Difícil" ]; then
    echo -e "\n${grayColour}[+] Dificultad: ${endColour} ${turquoiseColour}$difficulty${endColour}\n"
    echo -e "\n$machine_names\n"
  elif [ "$dificulty" == "Media" ]; then
    echo -e "\n${grayColour}[+] Dificultad: ${endColour} ${yellowColour}$difficulty${endColour}\n"
    echo -e "\n$machine_names\n"
  elif [ "$dificulty" == "Fácil" ]; then
    echo -e "\n${grayColour}[+] Dificultad: ${endColour} ${greenColour}$difficulty${endColour}\n"
    echo -e "\n$machine_names\n"
  else
    echo -e "\n${redColour}[!] La dificultad ${endColour} ${purpleColour}$difficulty${endColour} ${redColour} no existe${endColour}\n"
  fi
}

function searchOperativeSystem(){
  so="$1"
  machine_names="$(cat bundle.js | grep "so: \"$so\"" -B4 | grep name | awk 'NF{print $NF}' | tr -d '"' | tr -d ',' | column)"
  if [ "$so" == "Linux" ]; then
    echo -e "\n${grayColour}[+] Las máquinas con el sistema operativo${endColour} ${redColour}$so${endColour} ${grayColour}son:${endColour}\n"
    echo -e "\n$machine_names\n"
  elif [ "$so" == "Windows" ]; then
    echo -e "\n${grayColour}[+] Las máquinas con el sistema operativo${endColour} ${blueColour}$so${endColour} ${grayColour}son:${endColour}\n"   
    echo -e "\n$machine_names\n"
  else
    echo -e "\n${redColour}[!] El sistema operativo ${endColour} ${purpleColour}$so${endColour} ${redColour} no existe${endColour}\n"
  fi
}

function searchSODifficulty(){
  so="$1"
  difficulty="$2"
  machine_names="$(cat bundle.js | grep "dificultad: \"$difficulty\"" -B5 | grep "so: \"$so\"" -B4 | grep name | awk 'NF{print $NF}' | tr -d '"' | tr -d ',' | column)"
  if [ "$machine_names" ]; then
    echo -e "\n${grayColour}[+] Filtrando por SO: ${endColour} ${blueColour}$so${endColour} ${grayColour} y dificultad: ${endColour} ${redColour}$difficulty${endColour}\n"
    echo -e "\n$machine_names\n"
  else
    echo -e "\n${redColour} [!] El sistema operativo y/o dificultad introducido(s) no existen${endColour}\n"
  fi
}

function searchSkill(){
  skill="$1"
  machine_names="$(cat bundle.js | grep "skills: " -B 6 | grep "$skill" -i -B 6 | grep name | awk 'NF{print $NF}' | tr -d '"' | tr -d ',' | column)"
  echo -e "$machine_names"
  if [ "$machine_names" ]; then
    echo -e "\n${grayColour}[+] Las máquinas con la(s) skill(s) ${endColour} ${blueColour}$skill${endColour} ${grayColour}son:${endColour}\n"
    echo -e "\n$machine_names\n"
  else
    echo -e "\n${redColour} [!] La(s) skill(s) introducidas no existe(n)${endColour}\n"
  fi
}

#Ctrl+c 
trap ctrl_c INT

#Indicadores
declare -i parameter_counter=0 

#Chivatos 
declare -i chivato_so=0 
declare -i chivato_difficulty=0

#Gestion de comandos en el buscador
while getopts "m:i:y:d:o:s:hu" arg; do
  case $arg in 
    m) machineName=$OPTARG; let parameter_counter+=1;;
    u) let parameter_counter+=2;;
    i) ip=$OPTARG; let parameter_counter+=3;;
    y) machineName=$OPTARG; let parameter_counter+=4;;
    d) difficulty=$OPTARG; chivato_difficulty=1; parameter_counter+=5;;
    o) system_op=$OPTARG; chivato_so=1; let parameter_counter+=6;;
    s) skill=$OPTARG; let parameter_counter+=7;;
    h) ;;
  esac
done

if [ $parameter_counter -eq 1 ]; then
  searchMachine $machineName
elif [ $parameter_counter -eq 2 ]; then
  updateFiles
elif [ $parameter_counter -eq 3 ]; then
  searchIp $ip
elif [ $parameter_counter -eq 4 ]; then
  searchYoutubeLink $machineName
elif [ $parameter_counter -eq 5 ]; then
  searchDifficulty $difficulty
elif [ $parameter_counter -eq 6 ]; then
  searchOperativeSystem $system_op
elif [ $parameter_counter -eq 7 ]; then
  searchSkill $skill
elif [ $chivato_so -eq 1 ] && [ $chivato_difficulty -eq 1 ]; then
  searchSODifficulty $system_op $difficulty
else
  helpPanel
fi
