# RpiNtripBase

Dies ist eine einfach zu konfigurierende F9P-Basis für den RPI.

# Features
* NTRIP Caster auf Port 2102
* Proxy für die serielle Schnittstelle auf dem Port 2102; die Basis kann auch nach der 
  Installation mit dem uCenter konfiguriert und geupdatet werden
* Alles über systemd-services geregelt; werden automatisch gestartet und sind robust
* Baudrate einfach änderbar

# Voraussetzungen

* Der RPI ist mit Raspbian geflasht, alle Passwörter sind geändert und alle Netzwerke eingerichtet
* Ein Zugriff mit `ssh` (oder Putty auf Windows) besteht (Datei `ssh` auf der Bootpartition anlegen)
* Der F9P ist als Basis konfiguriert; es sollten nur RTCM-Nachrichten ausgegeben werden.
* Der Benutzer hat alles durchgelesen und versteht was er macht (oder macht nur das, was hier beschrieben ist...)

# Installation

Um das Ganze zu installieren, wird zuerst ein normales Raspbian-Image (ohne Desktop; Stretch Lite reicht) auf eine SD-Karte
gebrannt und konfiguriert. Anleitungen dazu findet man genug auf dem Internet, 
z.B. https://howtoraspberrypi.com/how-to-raspberry-pi-headless-setup/ oder https://www.dahlen.org/2017/10/raspberry-pi-zero-w-headless-setup/

Dann wird auf dem Pi per `ssh` (oder Putty)  eingelogt und Git und Socat installiert:
```
sudo apt-get install git socat
```

Dieses Repository wird geklont:
```
git clone https://github.com/eringerli/RpiNtripBase.git
```

Dann wird die Datei `compile.sh` und `update.sh` als `root` ausgeführt:
```
cd RpiNtripBase
sudo ./compile.sh
sudo ./update.sh
```

Jetzt müssen noch die entsprechenden Services gestartet werden:
```
sudo systemctl enable baseProxy@115200.service
sudo systemctl start baseProxy@115200.service
sudo systemctl enable ntripcaster.service
sudo systemctl start ntripcaster.service
sudo systemctl enable str2str
sudo systemctl start str2str
```

In einigen Konfigurationen ist die Baudrate anders konfiguriert, diese oben anpassen (zwei mal!).

Um die Basis erreichen zu können, muss auf dem Router eine Portweiterleitung auf den eingestellten
Port des NTRIP-Casters und eine DynDNS-Adresse (oder ähnlich, gibt viele Anbieter) eingerichtet werden,
sodass ein Zugriff vim Rover übers Internet möglich wird. FritzBox-Besitzer können auch eine MyFritz-Addresse
verwenden. Der Port 2102 erlaubt einen direkten Zugang zum F9P, diesen **nicht** öffentlich zugänglich machen.

# Konfiguration
Die Konfiguration wird in der Datei `ntripcaster.conf` hier gemacht. Standartmässig wird der
Caster auf dem Port 2101 gestartet, der Mountpoint ist "STALL", der Benutzername und
das Passwort je "gps". Wenn der Mountpoint verändert wird, muss er in der Datei 
str2str.service ebenfalls angepasst werden.

Wenn Werte geändert werden, muss die Datei `update.sh` neu  ausgeführt werden, um sie zu übernehmen.

# Andere Baud-Rate vom F9P
Es ist sehr wichtig, dass der alte Service gestoppt und ausgeschaltet wird, dies geschieht mit:
```
sudo systemctl stop baseProxy@ALT.service
sudo systemctl disable baseProxy@ALT.service
```

Um den neuen Service zu starten und aktivieren, wird folgendes eingegeben:
```
sudo systemctl start baseProxy@NEU.service
sudo systemctl enable baseProxy@NEU.service
```

Falls man nicht mehr weiss, wie man es konfiguriert hat, kann mit `systemctl` alle laufenden Services angezeigt werden.
Lieber einmal zuviel `systemctl disable ...` eingeben, als man hat nach dem Reboot zwei baseProxy-Services gleichtzeitig
am laufen. Diese konkurieren um die serielle Schnittstelle, was nicht funktionieren kann.

