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

function ctrl_c(){
echo -e "\n\n${redColour}[!] Saliendo...${endColour}\n"
exit 1

}

# Ctrl+c
trap ctrl_c INT 

# Variables globales
main_url="https://htbmachines.github.io/bundle.js"

function helpPanel(){
 echo -e "\n${yellowColour}[+]${endColour} ${greenColour}Uso:${endColour}"
 echo -e "\t${purpleColour}u)${endColour} ${greenColour}Descargar o actualizar archivos necesarios${endColour}" 
 echo -e "\t${purpleColour}m)${endColour} ${greenColour}Buscar por un nombre de máquina${endColour}" 
 echo -e "\t${purpleColour}i)${endColour} ${greenColour}Buscar por dirección IP${endColour}" 
 echo -e "\t${purpleColour}d)${endColour} ${greenColour}Buscar máquina por dificultad${endColour}" 
 echo -e "\t${purpleColour}o)${endColour} ${greenColour}Buscar máquina por sistema operativo${endColour}" 
 echo -e "\t${purpleColour}s)${endColour} ${greenColour}Buscar máquina por skill${endColour}" 
 echo -e "\t${purpleColour}y)${endColour} ${greenColour}Obtener el link de la resolución de la maquina en youtube${endColour}" 
 echo -e "\t${purpleColour}h)${endColour} ${greenColour}Mostrar este panel de ayuda${endColour}\n" 
}

function updateFiles(){ 
  if [ ! -f bundle.js ]; then
    tput civis
 echo -e "\n${yellowColour}[+]${endColour} ${greenColour}Descargargando archivos necesarios...${endColour}\n" 
    curl -s $main_url > bundle.js
 js-beautify bundle.js | sponge bundle.js
 echo -e "\n${yellowColour}[+]${endColour} ${greenColour}Todos los archivos han sido descargados${endColour}\n"
 tput cnorm
else 
  tput civis
  curl -s $main_url > bundle_temp.js
  js-beautify bundle_temp.js | sponge bundle_temp.js
  md5_temp_value=$(md5sum bundle_temp.js | awk '{print $1}')
  md5_original_value=$(md5sum bundle.js | awk '{print $1}')
  
  if [ "$md5_temp_value" == "$md5_original_value" ]; then
  echo -e "\n${yellowColour}[+]${endColour} ${greenColour}No hay actualizaciones disponibles${endColour}\n"
  rm bundle_temp.js
else
  echo -e "\n${yellowColour}[+]${endColour} ${greenColour}Hay actualizaciones disponibles${endColour}\n"
  echo -e "\n${yellowColour}[+]${endColour} ${greenColour}Descargando actualizaciones...${endColour}\n"
  sleep 2
  rm bundle.js && mv bundle_temp.js bundle.js
  fi
  tput cnorm
fi
}

function searchMachine(){
  machineName="$1"
  
  machineName_checker="$(cat bundle.js | awk "/name: \"$machineName\"/,/resuelta:/" | grep -vE "id:|sku:|resuelta" | tr -d '"' | tr -d ',' | sed 's/^ *//')"

  if [ "$machineName_checker" ]; then
      echo -e "\n${yellowColour}[+]${endColour} ${greenColour}Listando las propiedades de la maquina${endColour} ${blueColour}$machineName${endColour}${grayColour} :${endColour}\n"
  
  cat bundle.js | awk "/name: \"$machineName\"/,/resuelta:/" | grep -vE "id:|sku:|resuelta" | tr -d '"' | tr -d ',' | sed 's/^ *//'
  
else
    echo -e "\n${redColour}[!] La máquina no existe${endColour}\n"
  fi
}

function searchIP(){
 ipAddress="$1"

 machineName="$(cat bundle.js |grep "ip: \"$ipAddress\"" -B 3 | grep "name: " | awk 'NF{print $NF}' | tr -d '"' | tr -d ',')"

if [ "$machineName" ]; then

 echo -e "\n${yellowColour}[+]${endColour} ${greenColour}La máquina correspondiente para la IP${endColour}${blueColour} $ipAddress${endColour}${greenColour} es${endColour}${purpleColour} $machineName${endColour}\n" 

else

  echo -e "\n${redColour}[!] La dirección IP no existe${endColour}\n"
fi
}

  function getYoutubeLink(){

    machineName="$1"

    youtubeLink="$(cat bundle.js | awk "/name: \"$machineName\"/,/resuelta:/" | grep -vE "id:|sku:|resuelta" | tr -d '"' | tr -d ',' | sed 's/^ *//' | grep youtube | awk 'NF{print $NF}')"
    
    if [ "$youtubeLink" ]; then

    echo -e "\n${yellowColour}[+]${endColour} ${greenColour}El tutorial para esta máquina esta en el siguiente enlace:${endColour} ${blueColour}$youtubeLink${endColour}\n"
     
    else
    echo -e "\n${redColour}[!] La máquina no existe${endColour}\n"

    fi
  }

  function getMachineDificulty(){

dificulty="$1"

dificulty_resume="$(cat bundle.js | grep "dificultad: \"$dificulty\"" -B5 | grep name | awk 'NF{print $NF}' | tr -d '"' | tr -d ',' | column)"

if [ "$dificulty_resume" ]; then
    
  echo -e "\n${yellowColour}[+]${endColour} ${greenColour}Las máquinas de esta dificultad se mostraran acontinuación:${endColour}\n"

  cat bundle.js | grep "dificultad: \"$dificulty\"" -B5 | grep name | awk 'NF{print $NF}' | tr -d '"' | tr -d ',' | column

else
  
  echo -e "\n${redColour}[!] La máquina no existe${endColour}\n"
  
  fi

  }

  function getOSmachines(){

    os="$1"

    os_resume="$(cat bundle.js | grep "so: \"$os\"" -B5 | grep "name:" | awk 'NF{print $NF}' | tr -d '"' | tr -d ',' | column)"

   if [ "$os_resume" ]; then

 echo -e "\n${yellowColour}[+]${endColour} ${greenColour}Se mostraran las maquinas cuyo OS es:${endColour} ${blueColour}$os${endColour}\n"
    
    cat bundle.js | grep "so: \"$os\"" -B5 | grep "name:" | awk 'NF{print $NF}' | tr -d '"' | tr -d ',' | column

    else

      echo -e "\n${redColour}[!] El sistema operativo no existe${endColour}\n"

    fi

  }

  function getOSDificultyMachines(){

dificulty="$1"
os="$2"

os_dificulty="$(cat bundle.js | grep "so: \"$os\"" -C5 | grep "dificultad: \"$dificulty\"" -B5 | grep "name:" | awk 'NF{print $NF}' | tr -d ',' | tr -d '"' | column)"

if [ "$os_dificulty" ]; then

echo -e "\n${yellowColour}[+]${endColour} ${greenColour}Se aplicara un filtro por dificultad${endColour} ${purpleColour}$dificulty${endColour} ${greenColour}y sistema operativo${endColour} ${blueColour}$os${endColour}\n"

cat bundle.js | grep "so: \"$os\"" -C5 | grep "dificultad: \"$dificulty\"" -B5 | grep "name:" | awk 'NF{print $NF}' | tr -d ',' | tr -d '"' | column

else

      echo -e "\n${redColour}[!] La máquina no existe${endColour}\n"

fi
  }

  function getSkill(){

    skill="$1"

    check_skill="$(cat bundle.js | grep "skills:" -B 6 | grep "$skill" -B 6 | grep "name:" | awk 'NF{print $NF}' | tr -d ',' | tr -d '"')"

    if [ "$check_skill" ]; then

echo -e "\n${yellowColour}[+]${endColour} ${greenColour}Se listaran las máquinas con la skill ${endColour} ${purpleColour}$skill${endColour}\n"

cat bundle.js | grep "skills:" -B 6 | grep "$skill" -B 6 | grep "name:" | awk 'NF{print $NF}' | tr -d ',' | tr -d '"' | column


else
      echo -e "\n${redColour}[!] No hay máquinas con la skill asignada${endColour}\n"
   
    fi

  }

# Indicadores
declare -i parameter_counter=0

# Chivaatos
declare -i Chivato_dificulty=0
declare -i Chivato_os=0

while getopts "m:ui:y:d:o:s:h" arg; do
  case $arg in
    m) machineName="$OPTARG"; let parameter_counter+=1;;
    u) let parameter_counter+=2;;
    i) ipAddress="$OPTARG"; let parameter_counter+=3;;
    y) machineName="$OPTARG"; let parameter_counter+=4;;
    d) dificulty="$OPTARG"; Chivato_dificulty=1; let parameter_counter+=5;;
    o) os="$OPTARG"; Chivato_os=1; let parameter_counter+=6;;
    s) skill="$OPTARG"; let parameter_counter+=7;;
    h) ;;
  esac
done

if [ "$parameter_counter" -eq 1 ]; then
 searchMachine $machineName
elif [ "$parameter_counter" -eq 2 ]; then
 updateFiles
elif [ "$parameter_counter" -eq 3 ]; then
  searchIP $ipAddress
elif [  "$parameter_counter" -eq 4 ]; then
  getYoutubeLink $machineName
elif [ "$parameter_counter" -eq 5 ]; then
  getMachineDificulty $dificulty
elif [ "$parameter_counter" -eq 6 ]; then
getOSmachines $os
elif [ "$Chivato_dificulty" -eq 1 ] && [ "$Chivato_os" -eq 1 ]; then
  getOSDificultyMachines $dificulty $os
elif [ "$parameter_counter" -eq 7 ]; then
  getSkill "$skill"
else
 helpPanel
fi
