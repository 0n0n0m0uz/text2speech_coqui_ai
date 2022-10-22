#! /bin/bash
#converts txt to wav
#using https://github.com/coqui-ai/TTS

FILE="$(yad --file-selection --filename=Desktop --height='400' --width='800' --title='Sapo - Select File to Read'  --window-icon=$HOME/Github_Repos/sapo/sapo.png --hscroll-policy=never --vscroll-policy=never)"
case $? in
  0)
  ;;
  1) exit
  ;;
esac
DIRECTORY=${FILE%/*}/
NAME=${FILE##*/};NAME=${NAME%.*}
TEXT_EDITOR="xed"
AUDIO_EDITOR="audacity"

mkdir "$DIRECTORY""Sapo_""$NAME"/

# 	s/\./\.\n/g;
# 	s/^\.$//g;
# s/\(\(\w\w*\W*\)\{10\}\)/\1\n/g;  
# s/[[:digit:]][qQ]/second quarter\n/g; // fixes financial quarterly abbreviation
# s/\(\xE2\x80\x99\([[:digit:]]\+\)\)/ 20\2\n/g; //fixes unicode curly apostrophe used in yearly date abbreviations

sed "s/[.!?]  */&\n/g;          
					s/—/\,\n/g;
					s/\(\x27\([[:digit:]]\+\)\)/ 20\2/g;
					s/\(\xE2\x80\x99\([[:digit:]]\+\)\)/ 20\2/g;
					s/[1][qQ],*/first quarter\n/g;
					s/[2][qQ],*/second quarter\n/g;
					s/[3][qQ],*/third quarter\n/g;
					s/[4][qQ],*/fourth quarter\n/g;
					s/\%/ percent/g;
					s/\///g;
					s/ - /\,/g;
					s/^ *//g;
					s/^\;$//g;
					s/\…/\,/g;
					s/\’/\'/g;
					s/\“/\"/g;
					s/\”/\"/g;
					s/\"//g;
					s/(/\,\n/g;
					s/)\./,\n/g;
					s/)/,\n/g;
				    s/(*)\.$/)\n/g;
					s/\?/\?\n/g;
					s/\:/\:\n/g;
					s/\!/\!\n/g;
					s/\;/\;\n/g;
					s/\([[:alpha:]]\+\)\([[:digit:]]\+\)/\1 \2 /g;
					s/$\([0-9\]\+\)\( thousand\)/\1\2 dollars/g;
					s/$\([0-9\]\+\)\( [bm]illion\)/\1\2 dollars/g;
					s/\.\.\./\.\n/g" "$FILE" >"$DIRECTORY""Sapo_""$NAME"/"$NAME"sentenced.txt
sed -i 's/^[ \t]*//' "$DIRECTORY""Sapo_""$NAME"/"$NAME"sentenced.txt # remove leading whitespace
sed -i 's/[ \t]*\,$/\,\n/g' "$DIRECTORY""Sapo_""$NAME"/"$NAME"sentenced.txt # remove extra spaces between commas
sed -i "/^$/d" "$DIRECTORY""Sapo_""$NAME"/"$NAME"sentenced.txt #get rid of empty lines
sed -i -f $HOME/Github_Repos/sapo/letters.sed "$DIRECTORY""Sapo_""$NAME"/"$NAME"sentenced.txt
sed -i -f $HOME/Github_Repos/sapo/abbreviations.sed "$DIRECTORY""Sapo_""$NAME"/"$NAME"sentenced.txt
sed -i -f $HOME/Github_Repos/sapo/fonetix.sed "$DIRECTORY""Sapo_""$NAME"/"$NAME"sentenced.txt
##################extra delimit to comma and space ###################################
# For lines with 300 or greater characters create a new line after 3rd comma
# For lines with 290 or greater characters, create new lines every 50 words

#     [^\,]*\,  captures all text that ISNOT a comma, that IS followed by a comma. So it essentially matches each separate clause
#     \([^\,]*\, \) the inner group puts each of those into a group
#     \([^\,]*\, \)\{3\} the inner group only groups the last interation
#     \(\([^\,]*\, \)\{3\}\) a capturing group around the repeated group captures all iterations so now we have actual groups of 3 commas



sed -e '/.\{300,\}/s/\(\([^\,]*\, \)\{3\}\)/\1\n/g' "$DIRECTORY""Sapo_""$NAME"/"$NAME"sentenced.txt|sed -e '/.\{290,\}/s/\(\([^\ ]*\ \)\{50\}\)/\1\|\n/g'>"$DIRECTORY""Sapo_""$NAME"/temp1.txt
mv "$DIRECTORY""Sapo_""$NAME"/temp1.txt "$DIRECTORY""Sapo_""$NAME"/"$NAME"sentenced.txt
####################### Extra substitutions
sed -i "s/^\,$//g;s/^ *'//g;s/^'//g;s/^ *‘//g;s/^‘//g " "$DIRECTORY""Sapo_""$NAME"/"$NAME"sentenced.txt
sed -i "/^$/d" "$DIRECTORY""Sapo_""$NAME"/"$NAME"sentenced.txt #get rid of empty lines
########################################
yad  --image "$HOME/Github_Repos/sapo/sapo.png" --height=40 --width=400 --title="${NAME} - Sapo" --button=gtk-cancel:1 --button=gtk-open:2 --button=gtk-ok:0 --text="The text is prepared, Press:
1. <span foreground='red'><b>Open </b></span>to edit the new file
2. <span foreground='red'><b>OK </b></span>to proceed to speech conversion." --window-icon=$HOME/Github_Repos/sapo/sapo.png
case $? in
  0)
  ;;
  1) exit
  ;;
  2) $TEXT_EDITOR "$DIRECTORY""Sapo_""$NAME"/"$NAME"sentenced.txt & yad  --image "$HOME/Github_Repos/sapo/sapo.png" --height=40 --width=400 --title="${NAME} - Sapo" --button=gtk-cancel:1 --button=gtk-ok:0 --text="If you are done editing $NAME\sentenced.txt, <span foreground='red'><b>press OK</b></span> to continue!" --window-icon=$HOME/Github_Repos/sapo/sapo.png
 case $? in
  0)
  ;;
  1) exit
  ;;
 esac
esac
# TOTALLINES=$(cat "$DIRECTORY""Sapo_""$NAME"/"$NAME"sentenced.txt|wc -l)
TOTALLINES=$(sed -n '$=' "$DIRECTORY""Sapo_""$NAME"/"$NAME"sentenced.txt)

LINE=1
(
while [ $LINE -le $TOTALLINES ]
do
 CURRENTLINE=$(head -$LINE "$DIRECTORY""Sapo_""$NAME"/"$NAME"sentenced.txt|tail +$LINE)
	FORMLINE="$(printf "%.6d" $LINE)"
	tts --use_cuda true --text "$CURRENTLINE" --model_name "tts_models/en/ljspeech/tacotron2-DDC" --out_path "$DIRECTORY""Sapo_""$NAME"/$FORMLINE.wav
	### wav files of space delimited lines marked |$ are trimmed at the end!
	if [[ "$CURRENTLINE" == *"|" ]]
	then
		sox "$DIRECTORY""Sapo_""$NAME"/$FORMLINE.wav "$DIRECTORY""Sapo_""$NAME"/temp.wav trim 0 -0.5;mv "$DIRECTORY""Sapo_""$NAME"/temp.wav "$DIRECTORY""Sapo_""$NAME"/$FORMLINE.wav
	fi
	####error detection routine######
	CURRENTLINE_LENGTH=$(echo $CURRENTLINE|wc -m)
	WAV_LENGTH=$(jq -n $(sox "$DIRECTORY""Sapo_""$NAME"/$FORMLINE.wav -n stat 2>&1 |sed -n 's#^Length (seconds):[^0-9]*\([0-9.]*\)$#\1#p')-0.660)
	RATIO=$(jq -n $CURRENTLINE_LENGTH/$WAV_LENGTH|sed 's/\..*$//')
	if [ $RATIO -le 8 ]
	then
 	echo $LINE	$FORMLINE.wav	$CURRENTLINE_LENGTH	$WAV_LENGTH	$RATIO>>"$DIRECTORY""Sapo_""$NAME"/errors.tsv
 fi
 ###################################
 ###Estimating Estimated time of arrival
 ### Character based percentage ######
 TOTALCHARS=$(wc -m "$DIRECTORY""Sapo_""$NAME"/"$NAME"sentenced.txt |awk '{print $1}')
 CHARSDONE=$(head -$LINE "$DIRECTORY""Sapo_""$NAME"/"$NAME"sentenced.txt|wc -m)
 CHARSLEFT=$(($TOTALCHARS - $CHARSDONE))
 SECONDS=$(( $CHARSLEFT / 8 ))
 CHARSDONE100=$(($CHARSDONE * 100))
 PERCENTAGE=$(( $CHARSDONE100 / $TOTALCHARS))
 HOURS=$(( SECONDS / 3600 ))
	SECHLEFT=$(( $SECONDS - $((HOURS * 3600 )) ))
	MINUTES=$(( $SECHLEFT / 60 ))
	SECMLEFT=$(( $SECHLEFT - $((MINUTES * 60 )) ))
	HOURSTRING="$HOURS"" hrs"
	MINUTESTRING="$MINUTES"" mins"
	## if hours / minutes left are 0 , they are not mentioned
	if [ $HOURS -eq 0 ]
	then
		HOURSTRING=""
	fi
		if [ $MINUTES -eq 0 ]
	then
		MINUTESTRING=""
	fi
	#echo line starting with #, updated in the yad progress bar window
 echo "# Reading line $(( $LINE + 1)) of $TOTALLINES from "$NAME" ($PERCENTAGE%). Roughly remaining : "$HOURSTRING"  "$MINUTESTRING" " $SECMLEFT" secs"
 echo "$PERCENTAGE"
 ((LINE++))
done
) |
 yad --progress --height="40"  \
  --title="Sapo - Reading . . . ${NAME}" \
  --percentage=0 \
  --height=40 \
  --width="500" \
  --window-icon=$HOME/Github_Repos/sapo/sapo.png \
		--image "$HOME/Github_Repos/sapo/sapo_progress.png" \
		--auto-close
	  #--text="Preparing to read..." \
    case $? in
     0)
     ;;
     1)  exit
     ;;
    esac
##### Error correction routine ######
(
TOTAL_ERRORS=$(cat "$DIRECTORY""Sapo_""$NAME"/errors.tsv|wc -l)
ERROR_LINE=1
while [ $ERROR_LINE -le $TOTAL_ERRORS ]
do
	CURRENT_ERROR_LINE=$(cat "$DIRECTORY""Sapo_""$NAME"/errors.tsv|head -$ERROR_LINE|tail +$ERROR_LINE)
	ERROR_TEXT_LINE=$(echo $CURRENT_ERROR_LINE|awk '{print $1}')
	ERROR_WAV=$(echo $CURRENT_ERROR_LINE|awk '{print $2}')
	echo "#Attempting to fix error $ERROR_LINE of $TOTAL_ERRORS, line $ERROR_TEXT_LINE from $NAME.sentenced.txt"
	 ###################################
 ERROR_LINE100=$(( $ERROR_LINE * 100 ))
 ERROR_PERCENTAGE=$(( $ERROR_LINE100 / $TOTAL_ERRORS))
 echo "$ERROR_PERCENTAGE"
	tts --use_cuda true --text "$(cat "$DIRECTORY""Sapo_""$NAME"/"$NAME"sentenced.txt|head -$ERROR_TEXT_LINE|tail +$ERROR_TEXT_LINE)" --model_name "tts_models/en/ljspeech/tacotron2-DDC" --out_path "$DIRECTORY""Sapo_""$NAME"/$ERROR_WAV


	((ERROR_LINE++))
done
)|
 yad --progress --height="40"  \
					--title="Sapo - Fixing Errors . . . ${NAME}" \
					--percentage=0 \
					--height=40 \
					--width="500" \
					--window-icon=$HOME/Github_Repos/sapo/sapo.png \
					--image "$HOME/Github_Repos/sapo/sapo_progress.png" \
					--auto-close
####### FIXING ERRORS ONE BY ONE or EDIT THE FILE LINE BY LINE############
yad  --image "$HOME/Github_Repos/sapo/sapo.png" \
					--height=40 --width=200 --title="${NAME} - Sapo" \
					--text="Which lines do you want to fix?" \
					--button=gtk-cancel:1 \
					--button='All Lines':2 \
					--button='Just Errors':3 \
					--window-icon=$HOME/Github_Repos/sapo/sapo.png
		case $? in
		 1) exit
		 ;;
		 2) LINES_TO_EDIT="ALL"
		 ;;
		 3) LINES_TO_EDIT="ERRORS"
		 ;;
		esac

if [[ $LINES_TO_EDIT == "ALL" ]]
then
 TOTAL_ERRORS=$(cat "$DIRECTORY""Sapo_""$NAME"/"$NAME"sentenced.txt|wc -l)
else
 TOTAL_ERRORS=$(cat "$DIRECTORY""Sapo_""$NAME"/errors.tsv|wc -l)
fi
ERROR_LINE=1
BROWSE_NEXT=false
while [ $ERROR_LINE -le $TOTAL_ERRORS ]
do
	if [[ $LINES_TO_EDIT == "ALL" ]]
	then
		CURRENT_ERROR_LINE=$ERROR_LINE
		ERROR_TEXT_LINE=$ERROR_LINE

	else
		CURRENT_ERROR_LINE=$(cat "$DIRECTORY""Sapo_""$NAME"/errors.tsv|head -$ERROR_LINE|tail +$ERROR_LINE)
		ERROR_TEXT_LINE=$(echo $CURRENT_ERROR_LINE|awk '{print $1}')
	fi
	ERROR_WAV="$(printf "%.6d" $ERROR_TEXT_LINE)".wav


	TEXT_TO_CORRECT="$(cat "$DIRECTORY""Sapo_""$NAME"/"$NAME"sentenced.txt|head -$ERROR_TEXT_LINE|tail +$ERROR_TEXT_LINE)"
	GO=false

	while [[ $GO == false ]]
	do
		if [[ $BROWSE_NEXT == true ]]
		then
		killall mplayer > /dev/null 2>&1;mplayer -really-quiet -msglevel all=-1 "$DIRECTORY""Sapo_""$NAME"/$ERROR_WAV > /dev/null 2>&1 &
		fi
		BROWSE_NEXT=false
		DURATION=$(sox "$DIRECTORY""Sapo_""$NAME"/$ERROR_WAV  -n stat 2>&1 |grep "Length"|sed 's/^.*\: *//;s/....$//')
		yad  --image "$HOME/Github_Repos/sapo/sapo.png" \
							--height=200 --width=500 \
							--title="Line $ERROR_TEXT_LINE ( of $TOTAL_ERRORS )- $NAME" \
							--button='⏩ Browse':9 \
							--button='▶️ Play':2 \
							--button=gtk-cancel:1 \
							--button='🔃 Render':3 \
							--button='✂️ Trim':4 \
							--button='🪚 Split':5  \
							--button='🛠️ Edit':7 \
							--button='❌ Remove':6 \
							--button='⬅️ Previous':8 \
							--button='➡️ Next':0 \
							--button='👉 Go To':10 \
							--text="-Text of line $ERROR_TEXT_LINE ( of $TOTAL_ERRORS ):

<span foreground='red'><b>$TEXT_TO_CORRECT</b></span>

-Duration : <span foreground='orange'><b>$DURATION</b></span> sec
-What would you like to do?" \
						--window-icon=$HOME/Github_Repos/sapo/sapo.png
		case $? in
		 0) killall mplayer > /dev/null 2>&1;GO=true
		 ;;
		 1) exit
		 ;;
		 2) if [[ -e "$DIRECTORY""Sapo_""$NAME"/$ERROR_WAV ]];then killall mplayer > /dev/null 2>&1;mplayer -really-quiet "$DIRECTORY""Sapo_""$NAME"/$ERROR_WAV > /dev/null 2>&1 &  else notify-send "There is no file ""$DIRECTORY""Sapo_""$NAME"/"$ERROR_WAV"".";fi
		 ;;
		 3) killall mplayer > /dev/null 2>&1;s="$(yad --entry --width="800" --text="This is the original text of the line $ERROR_TEXT_LINE.
		 Edit as you wish, then hit OK to render." --entry-text="$TEXT_TO_CORRECT"  --window-icon=$HOME/Github_Repos/sapo/sapo-fix.png --title="Line $ERROR_TEXT_LINE - $NAME")";if [ $? -eq 0 ];then tts --use_cuda true --text "$s" --model_name "tts_models/en/ljspeech/tacotron2-DDC" --out_path "$DIRECTORY""Sapo_""$NAME"/$ERROR_WAV;mplayer -really-quiet "$DIRECTORY""Sapo_""$NAME"/$ERROR_WAV > /dev/null 2>&1 &fi
		 ;;
		 4)killall mplayer > /dev/null 2>&1;sox -V3 "$DIRECTORY""Sapo_""$NAME"/$ERROR_WAV "$DIRECTORY""Sapo_""$NAME"/temp.wav silence 1 0.50 0.1% 1 0.5 0.1%;sox "$DIRECTORY""Sapo_""$NAME"/temp.wav "$DIRECTORY""Sapo_""$NAME"/$ERROR_WAV pad 0 0.5;rm "$DIRECTORY""Sapo_""$NAME"/temp.wav
		 ;;
		 5)killall mplayer > /dev/null 2>&1;s="$(yad --entry --width="600" --text="Split the printed text roughly in half with the pipe symbol (|), so that it can be rendered in two batches: " --entry-text="$TEXT_TO_CORRECT"  --window-icon=$HOME/Github_Repos/sapo/sapo-fix.png --title="Line $ERROR_TEXT_LINE - $NAME")";if [ $? -eq 0 ];then s1="$(echo $s|sed 's/|.*$//')";s2="$(echo $s|sed 's/^.*|//')"; echo $s1;echo $s2 ; tts --use_cuda true --text "$s1" --model_name "tts_models/en/ljspeech/tacotron2-DDC"  --out_path "$DIRECTORY""Sapo_""$NAME"/1temp.wav > /dev/null 2>&1; tts --use_cuda true --text "$s2" --model_name "tts_models/en/ljspeech/tacotron2-DDC" --out_path "$DIRECTORY""Sapo_""$NAME"/2temp.wav > /dev/null 2>&1;sox "$DIRECTORY""Sapo_""$NAME"/1temp.wav "$DIRECTORY""Sapo_""$NAME"/2temp.wav "$DIRECTORY""Sapo_""$NAME"/$ERROR_WAV ; rm "$DIRECTORY""Sapo_""$NAME"/1temp.wav "$DIRECTORY""Sapo_""$NAME"/2temp.wav;mplayer -really-quiet "$DIRECTORY""Sapo_""$NAME"/$ERROR_WAV > /dev/null 2>&1 &fi
		 ;;
		 6)killall mplayer > /dev/null 2>&1; if [[ -e "$DIRECTORY""Sapo_""$NAME"/$ERROR_WAV ]];then rm "$DIRECTORY""Sapo_""$NAME"/$ERROR_WAV;notify-send "$DIRECTORY""Sapo_""$NAME"/"$ERROR_WAV"" has been deleted."; else notify-send "There is no file ""$DIRECTORY""Sapo_""$NAME"/"$ERROR_WAV"". Already deleted?";fi;GO=true
		 ;;
		 7)killall mplayer > /dev/null 2>&1;$AUDIO_EDITOR "$DIRECTORY""Sapo_""$NAME"/$ERROR_WAV
		 ;;
		 8)killall mplayer > /dev/null 2>&1; GO=true; ERROR_LINE=$(($ERROR_LINE - 2))
		 ;;
		 9) killall mplayer > /dev/null 2>&1;BROWSE_NEXT=true; GO=true
		 ;;
		 10)killall mplayer > /dev/null 2>&1;ERROR_LINE="$(yad --entry --height=40 --width=400 --text="Go To Line:" --entry-text="$ERROR_LINE"  --window-icon=$HOME/Github_Repos/sapo/sapo-fix.png --title="Go To Line ")";((ERROR_LINE--));GO=true
		esac
	done
	((ERROR_LINE++))
done
sox "$DIRECTORY""Sapo_""$NAME"/*.wav -r 44100 "$DIRECTORY""Sapo_""$NAME"/"$NAME".wav
yad  --image "$HOME/Github_Repos/sapo/sapo.png" --height=40 --width=400 --title="${NAME} - Sapo" --text="Reading of ""$NAME"" is complete!" --window-icon=$HOME/Github_Repos/sapo/sapo.png
