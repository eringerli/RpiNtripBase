# RpiNtripBase

Dies ist eine einfach zu konfigurierende F9P-Basis für den RPI.

# Features
* NTRIP Caster auf Port 2101
* Proxy für die serielle Schnittstelle auf dem Port 2102; die Basis kann auch nach der 
  Installation mit dem uCenter konfiguriert und geupdatet werden
* Alles über systemd-services geregelt; werden automatisch gestartet, haben in eingebautes logging und starten sich bei Absturz selber neu
* Baudrate einfach änderbar

# Voraussetzungen

* Der RPI ist mit Raspbian geflasht, alle Passwörter sind geändert und alle Netzwerke eingerichtet
* Ein Zugriff mit `ssh` (oder Putty auf Windows) besteht (Datei `ssh` auf der Bootpartition anlegen)
* Der F9P ist als Basis konfiguriert; es sollten nur RTCM-Nachrichten ausgegeben werden.
* **Der Benutzer hat alles durchgelesen und versteht was er macht (oder macht nur das, was hier beschrieben ist...)**

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

Jetzt müssen noch die entsprechenden Services gestartet und aktiviert werden:
```
sudo systemctl enable baseProxy@115200.service
sudo systemctl start baseProxy@115200.service
sudo systemctl enable ntripcaster.service
sudo systemctl start ntripcaster.service
sudo systemctl enable str2str.service
sudo systemctl start str2str.service
sudo systemctl enable logrotate-ntripcaster.timer
sudo systemctl start logrotate-ntripcaster.timer
```

Wenn der GPS-Empfänger über eine serielle Schnittstelle angeschlossen wurde (z.B. M8T mit TTL-Serial-zu-USB-Wandler), muss die Baudrate
korrekt konfiguriert sein (zwei mal!). Wenn er direkt über USB verbunden ist, ist es egal (z.B. F9P über USB). Hier hilft ausprobieren:
im u-center kann eine Text-Anzeige geöffnet werden (View -> Text Console), dann sieht man es sofort.

Um die Basis erreichen zu können, muss auf dem Router eine Portweiterleitung auf den eingestellten
Port des NTRIP-Casters und eine DynDNS-Adresse (oder ähnlich, gibt viele Anbieter) eingerichtet werden,
sodass ein Zugriff vim Rover übers Internet möglich wird. FritzBox-Besitzer können auch eine MyFritz-Addresse
verwenden. Der Port 2102 erlaubt einen direkten Zugang zum F9P, diesen **nicht** öffentlich zugänglich machen.

# Konfiguration
Die Konfiguration wird in der Datei `ntripcaster.conf` hier gemacht. Standartmässig wird der
Caster auf dem Port 2101 gestartet, der Mountpoint ist "STALL", der Benutzername und
das Passwort je "gps". Wenn der Mountpoint verändert wird, muss er in der Datei 
str2str.service ebenfalls angepasst werden. **Achtung: das Passwort für NTRIP wird im Klartext (HTTP Basic Auth)
über das Internet übertragen. Also etwas nie eines wählen, das schon an anderen Orten verwendet wird!**

Wenn Dateien geändert werden, muss die Datei `update.sh` neu  ausgeführt werden, um sie zu übernehmen.

# Logging

Das Logging funktioniert über journald. Wenn alle Ausgaben der Programme live angezeigt werden sollen, muss 
```
journalctl -f -u baseProxy@115200.service -u ntripcaster.service -u str2str.service
```
ausgeführt werden. Der Status der Services kann mit `systemctl status SERVICE` angezeigt werden. Damit werden neben dem Zustand und 
eventuellen Startschwierigkeiten auch die paar letzten Zeilen Ausgabe mit dem Zeitstempel angezeigt.

Weiter ist der ntripcaster so konfiguriert, dass er in die Datei `/tmp/ntripcaster.log` schreibt. Um diese Datei komfortabel anzuzeigen,
muss `less /tmp/ntripcaster.log` ausgeführt werden. Das zeigt eine scrollbare Ansicht der Datei an. Mit Eingabe von `End` (die Taste) wird
an das Ende gesprungen, mit `Shift+F` in Echtzeit aktualisiert. Um diesen Modus zu verlassen, wird `Ctrl+C` eingeben. Um das Programm zu
verlassen, wird `Q` gedrückt.

Debian Stretch Lite ist so konfiguriert, dass journald nicht auf die SD-Karte schreibt, um diese zu schonen. Wenn es anders gewünscht wird
(nicht zu empfehlen), kann das natürlich geändert werden. Anleitungen findet man im Internet (nach `journald persistent storage` suchen).
Auch der Speicherort von `ntripcaster.log` ist so gewählt, dass keine Schreiboperationen auf die SD-Karte ausgelöst werden. Mittels dem 
`logrotate-ntripcaster.service` wird die Grösse auf max 10MB begrenzt und die Anzahl Dateien auf drei. Somit ist mit der RTK-Basis ein
wartungsfreier Dauereinsatz möglich. Wenn ein persistentes Logging gewünscht wird, kann der Speicherort auf `/var/log/` geändert werden.
Auch können alle Parameter der Rotation in `ntripcaster.logrotate` eingestellt werden.

Ein Nachteil gibt es an dieser Konfiguration: die Logdateien und Einträge werden bei jedem Herunterfahren gelöscht. Sollte aber kein
Problem darstellen, da die Basis nie automatisch neu Startet oder ähnliches. Falls eine Boot-Schleife entsteht, hat es ziemlich sicher
nichts mit den Services hier zu tun.

# Andere Baud-Raten
Wenn der F9P per USB angeschlossen wird, wird die Baudrate nicht verwendet und kann auf dem Standart belassen werden.
Wenn ein USB-RS232-Wandler und ein anderer GPS-Empfänger verwendet wird, eventuel schon.

Es ist sehr wichtig, dass der alte Service gestoppt und ausgeschaltet wird, dies geschieht mit (ALT=alte Baudrate):
```
sudo systemctl stop baseProxy@ALT.service
sudo systemctl disable baseProxy@ALT.service
```

Um den neuen Service zu starten und aktivieren, wird folgendes eingegeben (NEU=neue Baudrate):
```
sudo systemctl start baseProxy@NEU.service
sudo systemctl enable baseProxy@NEU.service
```

Falls man nicht mehr weiss, wie man es konfiguriert hat, kann mit `systemctl` alle laufenden Services angezeigt werden.
Lieber einmal zuviel `systemctl disable ...` eingeben, als man hat nach dem Reboot zwei baseProxy-Services gleichtzeitig
am laufen. Diese konkurieren um die serielle Schnittstelle, was nicht funktionieren kann.

# Konfiguration mit uCenter

Um die Basis mit dem uCenter zu konfigurieren, wird zuerst str2str abgeschalten:
```
sudo systemctl stop str2str
```

Dann wird im uCenter eine neue Verbindung per TCP hergestellt, also mit `tcp://IP-BASIS:2102`. Die Basis kann nun normal konfiguriert werden.
Um die Basis wieder per NTRIP erreichbar zu machen, muss str2str wieder gestartet werden:
```
sudo systemctl start str2str
```

Falls die Baudrate geändert wird , muss wie oben beschrieben der Service `baseProxy` mit der
neuen Baudrate gestartet werden. Wenn es nur temporär ist, müssen die Kommandos mit `systemctl enable ...` und `systemctl disable ...`
nicht eingegeben werden.
