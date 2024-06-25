#!/usr/bin/env bash

#   Change Prompt
#   ------------------------------------------------------------
    export PS1="________________________________________________________________________________\n| \w @ \h (\u) \n| => "
    export PS2="| => "

    export TYPO3_CONTEXT=Development

#   Set Paths
#   ------------------------------------------------------------

#    export PATH="$(brew --prefix homebrew/php/php53)/bin"
    PATH=""
    PATH="${PATH}:${scriptPath}/bin"
    PATH="${PATH}:/usr/local/bin"
    PATH="${PATH}:/usr/bin"
    PATH="${PATH}:/bin"

    PATH="${PATH}:/usr/local/sbin"
    PATH="${PATH}:/usr/sbin"
    PATH="${PATH}:/sbin"

    PATH="${PATH}:/opt/X11/bin"
    PATH="${PATH}:/opt/X12/bin"
    export PATH="${PATH}:/usr/local/pcre/bin"

#   Set Default Editor
#   ------------------------------------------------------------
    EDITOR=nano

#   Set default blocksize for ls, df, du
#   from this: http://hints.macworld.com/comment.php?mode=view&cid=24491
#   ------------------------------------------------------------
    export BLOCKSIZE=1k