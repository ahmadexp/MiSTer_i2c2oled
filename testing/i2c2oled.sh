#!/bin/bash

#
# File: "media/fat/i2x2oled/i2c2oled.sh"
#
# Just for fun ;-)
#
# 2021-04-18 by venice
# License GPL v3
# 
# Using DE10-Nano's i2c Bus and Commands showing the MiSTer Logo on an connected SSD1306 OLED Display
#
# The SSD1306 is organized in eight 8-Pixel-High Pages (=Rows, 0..7) and 128 Columns (0..127).
# I you write an Data Byte you address an 8 Pixel high Column in one Page.
# Commands start with 0x00, Data with 0x40 (as far as I know)
#
# Initial Base for the Script taken from here:
# https://stackoverflow.com/questions/42980922/which-commands-do-i-have-to-use-ssd1306-over-i%C2%B2c
#
# Use Gimp to convert the original to X-PixMap (XPM) and change " " (Space) to "1" and "." (Dot) to "0" for easier handling
# See examples what to modify additionally
# The String Array has 64 Lines with 128 Chars
# Put your X-PixMap files in /media/fat/i2c2oled_pix with extension "pix"
#
# 2021-04-28
# Adding Basic Support for an 8x8 Pixel Font taken from https://github.com/greiman/SdFat under the MIT License
# Use modded ASCII functions from here https://gist.github.com/jmmitchell/c82b03e3fc2dc0dcad6c95224e42c453
# Cosmetic changes
#
# 2021-04-29/30
# Adding Font-Based Animation "pressplay" and "loading"
# The PIX's "pressplay.pix" and "loading.pix" are needed.
#
# 2021-05-01
# Adding "Warp-5" Scrolling :-)
# The PIX "ncc1701.pix" is needed.
# Using "font_width" instead of fixed value.
#
# 2021-05-15
# Adding OLED Address Detection
# If Device is not found the Script ends with Error Code 1 
# Use code from https://raspberrypi.stackexchange.com/questions/26818/check-for-i2c-device-presence
#
# 2021-05-17
# Adding an "contrast" variable so you can set your contrast value
#
# 2021-12-27
# Adding "rotate" option and code from "MickGyver"
#
# 2021-12-29
# Split Daemon Script into Daemon, User and System INI Files
# Added new "animation" option in User INI
#
#

# Load INI files
. /media/fat/i2c2oled/i2c2oled-user.ini
. /media/fat/i2c2oled/i2c2oled-system.ini


# ************************** Main Program **********************************

# Lookup for i2c Device

mapfile -t i2cdata < <(i2cdetect -y ${i2cbus})
for i in $(seq 1 ${#i2cdata[@]}); do
  i2cline=(${i2cdata[$i]})
  echo ${i2cline[@]:1} | grep -q ${oledid}
  if [ $? -eq 0 ]; then
    echo "OLED at 0x${oledid} found, proceed..."
    oledfound="true"
  fi
done

if [ "${oledfound}" = "false" ]; then
  echo "OLED at 0x${oledid} not found! Exit!"
  exit 1
fi

display_off     # Switch Display off
init_display    # Send INIT Commands
flushscreen     # Fill the Screen completly
display_on      # Switch Display on
sleep 0.5       # Small sleep
display_off     # Switch Display off
clearscreen     # Clear the Screen completly
display_on      # Switch Display on

#cfont=${#font[@]}        # Debugging get count font array members
#echo $cfont              # Debugging

set_cursor 16 2           # Set Cursor at Page (Row) 2 to the 16th Pixel (Column)
showtext "MiSTer FPGA"    # Some Text for the Display

#sleep 0.5                 # Wait a moment

set_cursor 16 4           # Set Cursor at Page (Row) 4 to the 16th Pixel (Column)
showtext "by Sorgelig"    # Some Text for the Display

sleep 2.0                 # Wait a moment
# reset_cursor

# Run Loading Animation
# loading

# Run NCC1701 Animation
# warp5

while true; do											# main loop
  if [ -r ${corenamefile} ]; then						# proceed if file exists and is readable (-r)
    newcore=$(cat ${corenamefile})						# get CORENAME
    echo "Read CORENAME: -${newcore}-"					# some output
    dbug "Read CORENAME: -${newcore}-"					# some debug output
    if [ "${newcore}" != "${oldcore}" ]; then			# proceed only if Core has changed
      dbug "Send -${newcore}- to i2c-${i2cbus}"			# some debug output
      if [ ${newcore} != "MENU" ]; then					# If Corename not "MENU"
	  
		echo "${animation}"
	    if (( ${animation} ==  -1 )); then				# 
		  anirandom=$[$RANDOM%3+1]						# Generate an Random Number between 1 (Offset) and 3 (Modulo Factor 3 = Numbers between 0 and 2)
		fi
		echo "${anirandom}"
		
	    if (( ${anirandom} == 1 )); then
          pressplay										# Run "pressplay" Animation
	    elif (( ${anirandom} == 2 )); then				
          loading										# Run "loading" Animation v1
	    elif (( ${anirandom} == 3 )); then
          loading2										# Run "loading" Animation v2
        fi		
      fi       											# end if
      display_off
      showpix ${newcore}				 				# The "Magic"
      display_on
      oldcore=${newcore}								# update oldcore variable
    fi  												# end if core check
    inotifywait -e modify "${corenamefile}"				# wait here for next change of corename
  else  												# CORENAME file not found
    echo "File ${corenamefile} not found!"				# some output
    dbug "File ${corenamefile} not found!"				# some debug output
  fi  													# end if /tmp/CORENAME check
done  													# end while

# ************************** End Main Program *******************************
