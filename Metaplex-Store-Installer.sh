#!/bin/sh

#**********************************************
#          Metaplex Store Installer           *
# Created By: BlackRanger07                   *
# Copyright: BlackRanger07                    *
#**********************************************

#IMPORTANT! - Place file into cloned Metaplex directory /home/yourusername/metaplex prior to running.

filechanges () {
  #Edit package.json file at line 49
  clear
  echo "Preparing to change the owner name of the repository for Metaplex."
  read -p "Enter your github name: " GITHUB
  sed -i 's/metaplex-foundation/'${GITHUB}'/g' js/packages/web/package.json
  #Add wallet address in .env file.
  read -p "Paste the wallet address for the store owner: " WALLET
  cat > js/packages/web/.env <<EOF
  REACT_APP_STORE_OWNER_ADDRESS_ADDRESS=${WALLET}
  REACT_APP_STORE_ADDRESS=
EOF
  #Add CNAME
  touch js/packages/web/public/CNAME
  read -p "Enter your CNAME or website name that will point to github pages: " SITENAME
  echo ${SITENAME} > js/packages/web/public/CNAME
}

# Prerequisites for Metaplex Store to be installed.
sudo apt update -y
sudo apt upgrade -y
sudo apt install -y curl
if [ $? = 0 ]; then
  curl -fsSL https://deb.nodesource.com/setup_16.x | sudo -E bash -
  if [ $? = 0 ]; then
    sudo apt install -y nodejs
  else
    echo "Nodejs did not install! Please Investigate."
  fi
else
  echo "Curl did not install! Please Investigate."
fi

#Run function to make the necessary file changes.
filechanges

#Setup npm, yarn and then deploy.
cd js
npm install -g yarn
if [ $? = 0 ]; then
  echo "Yarn installed successfully!"
  yarn
  if [ $? = 0 ]; then
    yarn bootstrap
    if [ $? = 0 ]; then
      #Ask user if they want to run locally first or go into build and deploy.
      read -p "Do you want to run metaplex locally first (y/N)? " CHOICE
      if [ ${CHOICE} = "n" ] || [ ${CHOICE} = "N" ]; then
        echo "Metaplex will now be built and deployed. Have your github account and access code ready."
        yarn build
        if [ $? = 0 ]; then
          cd packages/web
            #Ask user if they have set their Github identity before, get info and set if not.
            read -p "Have you set your GitHub default identity? (y/N)" IDENTITY
            if [ ${IDENTITY} = "n" ] || [ ${IDENTITY} = "N" ]; then
              read -p "Enter your email address that is used for Github: " EMAIL
              read -p "Enter your Github User Name: " USER
              git config --global user.email "${EMAIL}"
              git config --global user.name "${USER}"
            fi
          yarn deploy
          if [ $? = 0 ]; then
            clear
            echo "Your metaplex store is now ready to be used at the site you used during the install process."
            echo "If you found this installer helpful and want to support with SOL"
            echo "Donate SOL: 9inpsvQZYiTekRJEuNBLjPjNoQzSCDx9iuHMq3uTzssB"
          fi
        else
          echo "The command (yarn build) had an issue, please investigate."
        fi
      else
        echo "Local Metaplex is now being setup and can be accessed in your browser at localhost:3000"
        yarn start
      fi
    fi
  fi
else
  echo "Yarn did not install, please investigate."
fi
