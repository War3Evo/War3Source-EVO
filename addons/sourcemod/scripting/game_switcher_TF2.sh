#!/bin/bash
cd "$(dirname "$0")"

fullpath=${PWD};

filecurrentgame="`echo $fullpath/include/GAME_SWITCHER/currentgame.inc`";

file1="`echo $fullpath/include/GAME_SWITCHER/github_actions/tf2game.inc`";

cat $file1 > $filecurrentgame
