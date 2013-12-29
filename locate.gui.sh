#!/bin/bash
for ((i=0; i < 20; i++)); do
	i=`expr $i - 1`

	var=$(kdialog --inputbox "Please enter the name of any file or folder you want to find.") || exit 1

	if [ "$(echo $var |head --bytes 1)" = '/' ];
	then
			if [ "$var" = "/refresh" ]; then updatedb || killall xmessage & xmessage -buttons Abbrechen -center "Refreshing databse... this may take up to ten minutes.
				Click Abort to abort the progress." && killall find; killall sort; killall locate; exit 1; fi
			else
				locate $var > /tmp/.serg-locate

				number=$(cat /tmp/.serg-locate |grep -c '/')

				echo "$number Funde(?)"
				if [ "$number" -eq 0 ]; then
					kdialog --sorry "No files were found. Please try again using other keywords."
				else
					if [ "$number" -lt 16 ]; then
						kdialog --title Suchergebnisse --msgbox "$number files / folders found.
						=================================================
						$(cat /tmp/.serg-locate)
						================================================="
					else
						kdialog --title Suchergebnisse --yesno "$number files / folders found. Displaying top 15 of them; click Yes to see all.
						=================================================
						$(cat /tmp/.serg-locate |head -n 15)
						=================================================" && kedit /tmp/.serg-locate
					fi
				fi
			fi
		done
