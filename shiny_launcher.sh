#!/bin/sh
# shiny_launcher.sh
#

sudo R -e "shiny::runApp('/srv/data/PiShared/EnvDash',host = getOption('shiny.host', '0.0.0.0'),port=8080)" 


# entry in crontan to start app at reboot (contab -e)
# @reboot sh /srv/data/PiShared/EnvDash/shiny_launcher.sh >/srv/data/PiShared/logs/temp_mon_cronlog 2>&1

## On windows
## R -e "shiny::runApp('F:/PiShared/PiShared/EnvDash',host = getOption('shiny.host', '0.0.0.0'),port=8080)"
