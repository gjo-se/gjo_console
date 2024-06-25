#!/usr/bin/env bash

#    alias edit_bash_profile='$EDITOR ~/.bash_profile'
    alias reload_shell="source ~/.zsh"

    alias c='clear'

    alias cp='cp -i'                           # Preferred 'cp' implementation
    alias cpdir='cp -r'                        # Copy Folder recursive

    alias ll='ls -FGlAhp'                       # Preferred 'ls' implementation
    alias lr='ls -R | grep ":$" | sed -e '\''s/:$//'\'' -e '\''s/[^-][^\/]*\//--/g'\'' -e '\''s/^/   /'\'' -e '\''s/-/|/'\'' | less'
    cd() { builtin cd "$@"; ll; }

    alias cd..='cd ../'
    alias ..='cd ../'
    alias ...='cd ../../'
    alias .3='cd ../../../'
    alias ~="cd ~"

    alias mv='mv -iv'                           # Preferred 'mv' implementation
    alias mkdir='mkdir -pv'                     # Preferred 'mkdir' implementation
    mcd () { mkdir -p "$1" && cd "$1"; }        # mcd:          Makes new Dir and jumps inside

    alias less='less -FSRXc'                    # Preferred 'less' implementation
    alias finder='open -a Finder ./'            # f:            Opens current directory in MacOS Finder
    alias which='type -all'                     # which:        Find executables
    alias path='echo -e ${PATH//:/\\n}'
    alias show_options='shopt'                  # Show_options: display bash options settings
    alias fix_stty='stty sane'                  # fix_stty:     Restore terminal settings when screwed up
    trash () { command mv "$@" ~/.Trash ; }     # trash:        Moves a file to the MacOS trash
    ql () { qlmanage -p "$*" >& /dev/null; }    # ql:           Opens any file in MacOS Quicklook Preview
    alias DT='tee ~/Desktop/terminalOut.txt'    # DT:           Pipe content to file on MacOS Desktop

    # TODO: funktioniert so nicht
    alias cic='set completion-ignore-case On'   # cic:          Make tab-completion case-insensitive

    alias q='exit'

    alias typo3cms='php vendor/helhum/typo3-console/typo3cms'

    alias cc='typo3cms cache:flush --force'
    alias exportDb='typo3cms database:export --exclude-tables be_sessions,cache_md5params,cache_treelist,cf_cache_hash,cf_cache_hash_tags,cf_cache_imagesizes,cf_cache_imagesizes_tags,cf_cache_pages,cf_cache_pages_tags,cf_cache_pagesection,cf_cache_pagesection_tags,cf_cache_rootline,cf_cache_rootline_tags,cf_extbase_datamapfactory_datamap,cf_extbase_datamapfactory_datamap_tags,cf_extbase_object,cf_extbase_object_tags,cf_extbase_reflection,cf_extbase_reflection_tags,cf_fluidcontent,cf_fluidcontent_tags,cf_flux,cf_flux_tags,cf_vhs_main,cf_vhs_main_tags,cf_vhs_markdown,cf_vhs_markdown_tags,fe_sessions,tx_scheduler_task,tx_scheduler_task_group,tx_extensionmanager_domain_model_extension,tx_extensionmanager_domain_model_repository,sys_log,sys_history'

#   mans:   Search manpage given in agument '1' for term given in argument '2' (case insensitive)
#           displays paginated result with colored search terms and two lines surrounding each hit.             Example: mans mplayer codec
#   --------------------------------------------------------------------
    mans () {
        man $1 | grep -iC2 --color=always $2 | less
    }

#   showa: to remind yourself of an alias (given some part of it) TODO: schau mal unter etc/aliases
#   ------------------------------------------------------------
     showa () { /usr/bin/grep --color=always -i -a1 $@ ~/Library/init/bash/aliases.bash | grep -v '^\s*$' | less -FSRXc ; }

