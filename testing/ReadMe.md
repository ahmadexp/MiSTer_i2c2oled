##Testing Version  
  
  wget https://raw.githubusercontent.com/venice1200/MiSTer_i2c2oled/main/testing/update_i2c2oled.sh -O /media/fat/Scripts/update_i2c2oled.sh  
  
* Split Daemon Script into Daemon, User and System INI Files  
  User-INI: i2c2oled-user.ini  
  System-INI: i2c2oled-system.ini  
  
* Added User-INI Option to rotate the display direction for 180 degrees.  
  Default: rotate="no"  
  After changing this Option your Display need an power-cycle.  
* Added User-INI Option for the tiny animation before the picture  
  Set "animation" to:  
  -1 (default) for Random Animation 1..3  
  0 for NO Animation  
  1 for PressPlay Animation  
  2 for Loading v1 Animation  
  3 for Loading v2 Animation  
* Added User-INI Option for Slideshow  
  Default: slideTime=3.0 secs  
  