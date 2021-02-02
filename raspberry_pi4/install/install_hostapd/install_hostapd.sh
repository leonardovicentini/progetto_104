#!binbash

DEBUG=false

GREEN='033[0;32m' # Green
RED='033[0;31m'   # Red
NC='033[0m'       # No Color

# script path and its directory
scriptpath=$(realpath $0)
dirpath=$(dirname ${scriptpath})

# set working directory = script path
cd $dirpath


logger(){
    software=$1
    message=$2
    success=$3
    output=$4
    error=$5

    if $success ; then

        printf ${GREEN}
    else
        printf ${RED}
    fi

    printf [${software}]${NC} ${message}n

    currenttime=$(date +%s)
    printf ${currenttime} [${software}] ${message}  ${output}

    if ! $success ; then
        printf  - error ${error}
    fi

    printf  n  ${output}
}


########################################################################
#                                                                      #
#                         HOSTAPD FUNCTIONS                            #
#                                                                      #
########################################################################


hostapdinstall(){
    # installs hostapd, calls hostapdstop

    if $DEBUG ; then
        echo HOSTAPD  hostapdinstall()
    fi

    logger HOSTAPD Installing Hostapd... true autohostapd.log

    if ! $DEBUG ; then
        sudo apt-get install hostapd -y
    else
        echo Should have installed hostapd...
    fi

    if [ $ -eq 0 ] ; then
        logger HOSTAPD Done Installing Hostapd true autohostapd.log
        echo status='installed hostapd'  status.autohostapd.txt
        hostapdstop
    else
        logger HOSTAPD Failed Installing Hostapd false autohostapd.log $
        exit 1
    fi
}


hostapdstop(){
    # stops hostapd service, calls autostartscript

    if $DEBUG ; then
        echo HOSTAPD  hostapdstop()
    fi

    logger HOSTAPD Stopping Hostapd... true autohostapd.log

    if ! $DEBUG ; then
        sudo systemctl stop hostapd
    else
        echo Should have stopped hostapd...
    fi

    if [ $ -eq 0 ] ; then
        logger HOSTAPD Done Stopping Hostapd true autohostapd.log
        autostartscript

    else
        logger HOSTAPD Failed Stopping Hostapd false autohostapd.log $
        exit 1
    fi
}


########################################################################
#                                                                      #
#                          SYSTEM FUNCTIONS                            #
#                                                                      #
########################################################################


autostartscript(){
    # makes this file run on the next boot, calls reboot

    if $DEBUG ; then
        echo AUTOHOSTAPD  autostartscript()
    fi

    logger AUTOHOSTAPD Setting start on reboot of this script... true autohostapd.log

    if ! $DEBUG ; then
        sudo bash -c echo '@lxterminal --command=${scriptpath}'  sudo cat - etcxdglxsessionLXDE-piautostart  temp && sudo mv temp etcxdglxsessionLXDE-piautostart
    else
        echo Should have set start on reboot...
    fi

    if [ $ -eq 0 ] ; then
        logger AUTOHOSTAPD Done Setting start on reboot true autohostapd.log
        reboot
    else
        logger AUTOHOSTAPD Failed Setting start on reboot false autohostapd.log $
        exit 1
    fi
}


reboot(){
    # reboots system

    if $DEBUG ; then
        echo AUTOHOSTAPD  reboot()
    fi

    logger AUTOHOSTAPD Rebooting system... true autohostapd.log

    if ! $DEBUG ; then
        sudo reboot
    else
        echo Should have rebooted...
    fi

    if [ $ -eq 0 ] ; then
        logger AUTOHOSTAPD Done Rebooting true autohostapd.log
    else
        logger AUTOHOSTAPD Failed Rebooting false autohostapd.log $
        exit 1
    fi
}


staticip(){
    # sets static ip, calls dhcpcdrestart

    if $DEBUG ; then
        echo AUTOHOSTAPD  staticip()
    fi

    logger AUTOHOSTAPD Setting static ip... true autohostapd.log

    if ! $DEBUG ; then
        echo -e ninterface wlan0nstatic ip_address=${hostapd_ip}nnohook wpa_supplicant  etcdhcpcd.conf
    else
        echo Should have set static ip...
    fi

    if [ $ -eq 0 ] ; then
        logger AUTOHOSTAPD Done Setting static ip true autohostapd.log
        dhcpcdrestart

    else
        logger AUTOHOSTAPD Failed Setting static ip false autohostapd.log $
        exit 1
    fi
}


dhcpcdrestart(){
    # restarts dhcpcd service
    if $DEBUG ; then
        echo AUTOHOSTAPD  dhcpcdrestart()
    fi

    logger AUTOHOSTAPD Restarting DHCP service... true autohostapd.log

    if ! $DEBUG ; then
        sudo service dhcpcd restart
        # sudo systemctl daemon-reload
    else
        echo Should have restarted DHCP service...
    fi

    if [ $ -eq 0 ] ; then
        logger AUTOHOSTAPD Done Restarting DHCP service true autohostapd.log

    else
        logger AUTOHOSTAPD Failed Restarting DHCP service false autohostapd.log $
        exit 1
    fi
}


hostapdconfig(){
    # creates settings file and writes hostapd_configs in it
    if $DEBUG ; then
        echo AUTOHOSTAPD  hostapdconfig()
    fi

    logger HOSTAPD Creating Hostapd Settings File... true autohostapd.log

    hostapd_configs=interface=wlan0ndriver=nl80211nssid=${hostapd_ssid}nhw_mode=gnchannel=7nwmm_enabled=0nmacaddr_acl=0nauth_algs=1nignore_broadcast_ssid=0nwpa=2nwpa_passphrase=${hostapd_pass}nwpa_key_mgmt=WPA-PSKnwpa_pairwise=TKIPnrsn_pairwise=CCMP

    if ! $DEBUG ; then
        sudo echo -e ${hostapd_configs}  sudo tee etchostapdhostapd.conf  devnull
    else
        echo Should have created Hostapd settings file...
    fi

    if [ $ -eq 0 ] ; then
        logger HOSTAPD Done Creating Hostapd Settings File true autohostapd.log
        hostapdsetsettings
    else
        logger HOSTAPD Failed Creating Hostapd Settings File false autohostapd.log $
        exit 1
    fi
}


hostapdsetsettings(){
    # says hostapd were the config file is
    if $DEBUG ; then
        echo AUTOHOSTAPD  hostapdsetsettings()
    fi

    logger HOSTAPD Setting were Hostapd Settings File is... true autohostapd.log

    replacingwith='DAEMON_CONF=etchostapdhostapd.conf'
    toreplace='#DAEMON_CONF='

    if ! $DEBUG ; then
        sudo sed -i -e s${toreplace}${replacingwith} etcdefaulthostapd
    else
        echo Should have set were Hostapd Settings File is...
    fi

    if [ $ -eq 0 ] ; then
        logger HOSTAPD Done Setting were Hostapd Settings File is true autohostapd.log
    else
        logger HOSTAPD Failed Setting were Hostapd Settings File is false autohostapd.log $
        exit 1
    fi
}


ipforwarding(){
    # enables ip forward
    if $DEBUG ; then
        echo AUTOHOSTAPD  ipforwarding()
    fi

    logger AUTOHOSTAPD Setting IP forward... true autohostapd.log

    find='#net.ipv4.ip_forward=1'
    replacingwith='net.ipv4.ip_forward=1'

    if ! $DEBUG ; then
        sudo sed -i -e s${find}${replacingwith} etcsysctl.conf
    else
        echo Should have set IP forward...
    fi

    if [ $ -eq 0 ] ; then
        logger AUTOHOSTAPD Done Setting IP forward true autohostapd.log
    else
        logger AUTOHOSTAPD Failed Setting IP forward false autohostapd.log $
        exit 1
    fi

}


setmasquerade(){
    # sets routing and masquerade
    if $DEBUG ; then
        echo AUTOHOSTAPD  setmasquerade()
    fi

    logger AUTOHOSTAPD Setting Masquerade... true autohostapd.log

    if ! $DEBUG ; then
        sudo iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
    else
        echo Should have set Masquerade...
    fi

    if [ $ -eq 0 ] ; then
        logger AUTOHOSTAPD Done Setting Masquerade true autohostapd.log
    else
        logger AUTOHOSTAPD Failed Setting Masquerade false autohostapd.log $
        exit 1
    fi
}


saveiptables(){
    # saves iptables to the etciptables.ipv4.nat file
    if $DEBUG ; then
        echo AUTOHOSTAPD  saveiptables()
    fi

    logger AUTOHOSTAPD Saving IP Tables... true autohostapd.log

    if ! $DEBUG ; then
        sudo sh -c iptables-save  etciptables.ipv4.nat
    else
        echo Should have saved IP Tables...
    fi

    if [ $ -eq 0 ] ; then
        logger AUTOHOSTAPD Done Saving IP Tables true autohostapd.log
    else
        logger AUTOHOSTAPD Failed Saving IP Tables false autohostapd.log $
        exit 1
    fi
}


restoreiptables(){
    # set automatic restore on boot of the iptables file
    if $DEBUG ; then
        echo AUTOHOSTAPD  restoreiptables()
    fi

    logger AUTOHOSTAPD Setting automatic IP Tables restore... true autohostapd.log

    newline=iptables-restore  etciptables.ipv4.nat

    if ! $DEBUG ; then
        sudo sed -i $ i$newline etcrc.local
    else
        echo Should have set automatic IP Tables restore...
    fi

    if [ $ -eq 0 ] ; then
        logger AUTOHOSTAPD Done Setting automatic IP Tables restore true autohostapd.log
    else
        logger AUTOHOSTAPD Failed Setting automatic IP Tables restore false autohostapd.log $
        exit 1
    fi
}


removeautostart(){
    # removes this script from the autostart file
    if $DEBUG ; then
        echo AUTOHOSTAPD  removeautostart()
    fi

    logger AUTOHOSTAPD Removing this script from autostart... true autohostapd.log

    if ! $DEBUG ; then
        sudo grep -v @lxterminal --command=${scriptpath} etcxdglxsessionLXDE-piautostart  lxdeautostart.temp
        sudo cp -f lxdeautostart.temp etcxdglxsessionLXDE-piautostart
        sudo rm lxdeautostart.temp
    else
        echo Should have removed this script from autostart...
    fi

    if [ $ -eq 0 ] ; then
        logger AUTOHOSTAPD Done Removing this script from autostart true autohostapd.log
    else
        logger AUTOHOSTAPD Failed Removing this script from autostart false autohostapd.log $
        exit 1
    fi
}


hostapdunmasknenable(){
    # unmasks and enables hostapd

    if $DEBUG ; then
        echo AUTOHOSTAPD  hostapdunmasknenable()
    fi

    logger HOSTAPD Unmasking, Enabling and Starting Hostad... true autohostapd.log

    if ! $DEBUG ; then
        sudo systemctl unmask hostapd
        sudo systemctl enable hostapd
        sudo systemctl start hostapd
    else
        echo Should have Unmasked, Enabled and Started Hostad...
    fi

    if [ $ -eq 0 ] ; then
        logger HOSTAPD Done Unmasking, Enabling and Starting Hostad true autohostapd.log
    else
        logger HOSTAPD Failed Unmasking, Enabling and Starting Hostad false autohostapd.log $
        exit 1
    fi
}


# get from settings.ini file raspberry ip, network password and ssid
source (grep = settings.ini  sed 's = =g')
hostapd_ip=$ip
hostapd_pass=$password
hostapd_ssid=$ssid

# if status file doesn't exist, create it and put starting status
if [ ! -f status.autohostapd.txt ]; then
  echo status='starting'  status.autohostapd.txt
fi

# read status
line=$(head -n 1 status.autohostapd.txt)
if [[ $line == status='starting' ]] ; then
    hostapdinstall # installs and stops hostapd

elif [[ $line == status='installed hostapd' ]] ; then
    staticip       # set static IP, restart DHCP
    hostapdconfig  # creates configs file and tells hostapd to use it
    ipforwarding
    setmasquerade
    saveiptables
    restoreiptables
    removeautostart
    hostapdunmasknenable

    echo status='done'  status.autohostapd.txt

    reboot

elif [[ $line == status='done' ]] ; then
    echo Done
else
    echo Unknown status
fi
