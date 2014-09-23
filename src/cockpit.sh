#!/usr/bin/env bash

CONFIG=~/.cockpit

echo -e "\nCOCKPIT** \npimping developer terminal workspace, by Team Vicious"
echo -e "-------"

checkConfigFile() {
  found=1
  if [[ ! -f $CONFIG ]];
  then
    found=0
  fi

  return $found
}


args=("$@")

COMMANDS=(
  '-h:helper'
  'help:helper'
  'load:loadCockpit'
  'init:createFile'
  'exit:exitTerminal'
)

helper() {
  echo "Start creating cockpits."
  echo -e "\tcockpit init - to create new config file."
  echo -e "\tcockpit load <cockpit-name> - to load cockpit."
}

parseConfig() {
  tab="--tab"
  fullscreen="--full-screen"

  execute=""
  settingsName=${args[1]}
  settings="$settingsName[@]"
  for setting in "${!settings}"
  do
    tabName="${setting%%:*}"
    tabCmd="${setting##*:}"

    execute+=($fullscreen $tab --title="${tabName}" -e "bash -c '$tabCmd';bash")
  done

  if [ ${#execute[@]} -eq 1 ]
  then
    fault=1;
  else
    gnome-terminal "${execute[@]}"
	sleep 1
  fi
}

loadCockpit() {
  if checkConfigFile
  then
    echo -e "\nFile Not Found!.\nCreated a new file at ~/.cockpit add your cockpit configuration and enjoy."
    echo -e  '\n\t eg: work( "vim:cd ~/project;vim") \n'
    echo "" >> ${CONFIG}
    exit 0
  fi

  . $CONFIG
  config=${args[1]}

  parseConfig
}

createFile() {
  echo "" >> ${CONFIG}
  helper
}


exitTerminal() {
  if [ ${args[1]} = all ]
  then
    killall gnome-terminal
  else
    . $CONFIG
    settingsName=${args[1]}
    settings="$settingsName[@]"
    for setting in "${!settings}"
    do
	  tabName="${setting%%:*}"
	  tabCmd="${setting##*:}"

      processId=`grep "$tabCmd" /tmp/${args[1]} | awk '{print $2}'`

	  if [ ${args[2]} = all ] || [ ${args[2]} = $tabName ]
	  then
	    kill -9 $processId 2>/dev/null
	  fi
    done
  fi
}

fault=0;


for cmd in "${COMMANDS[@]}"
do
  key="${cmd%%:*}"
  value="${cmd##*:}"

  if [ ${args[0]} == $key ]
  then
    eval ${value}
  fi
done

# Extracting Process id of the cockpit tabs
ps aux | grep bash | grep -v grep > /tmp/${args[1]}

if [ $fault == 1 ]
then
  echo "Cockpit not found. Please confirm the at ~/.cockpit"
fi

exit 0
