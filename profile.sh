#!/bin/bash
# .dotfiles | .bashrc
# put in your .bashrc like so:
# source <(curl -s https://raw.githubusercontent.com/xxx/.dotfiles/master/.bashrc)
# or
# curl https://raw.githubusercontent.com/xxx/.dotfiles/master/.bashrc -s -o /tmp/temp.bashrc 2> /dev/null && . /tmp/temp.bashrc && rm /tmp/temp.bashrc
# or
# if [[ -t 0 ]];then curl https://raw.githubusercontent.com/xxx/.dotfiles/master/.bashrc -s -o /tmp/temp.bashrc 2> /dev/null && . /tmp/temp.bashrc && rm /tmp/temp.bashrc; fi

version=0.7.50b
if [[ "$dotfilesbashrcversion0750b" == "true" ]];then
    return
else
    dotfilesbashrcversion0750b="true"
fi
function .v(){
    # echo -e "\e[7m .dotfiles/.bashrc \e[0m \e[7m v$version \e[0m"
    echo -e "\e[7m.v$version\e[0m"
}
# clear
## Run local .bashrc(s)
    if [[ -f .bashrc ]];then
        . .bashrc
    fi

## Git related
    # Pretty Git graph
        function gl(){
            command git log --all --branches --remotes --tags --graph --oneline --abbrev-commit --decorate --date=relative --format=format:"%h %ar %cn %s %C(reverse)%d"
        }
        function log(){
            gl
        }
    # git gui
        function gui(){
            command git gui
        }
    # git gui and gitk
        function guik(){
            command gitk & git gui
        }
    # commit auto
        function gc(){
            command git add -A
            if [[ -z "$@" ]];then
                command git commit -a -m "."
            else
                local message="$@"
                command git commit -a -m "$message"
            fi
        }
        function gm(){
            gc $@
        }
    # stash
        function stash(){
            local args=$@
            if [[ $@ == s* ]];then
                local args="save --keep-index"
            fi
            command git stash $args
        }
    # git remote
        function remote(){
            if [[ -z "$@" ]];then
                command git remote -v
            else
                command git remote $@
            fi
        }
    # git status
        function status(){
            command git status $@
        }
        alias st='status'
    # git checkout
        function checkout(){
            local args=$@
            if [[ "$1" == "-" ]];then
                local args="-- ."
                command git clean -df
            fi
            command git checkout $args
        }
        alias ch='checkout'
    # git add
        function add(){
            local args=$@
            if [[ -z "$args" ]];then
                local args="-i"
            fi
            command git add $args
        }
        alias ch='checkout'
    # git checkout master
        function master(){
            checkout $@ master
        }
    # pull [gh/bb/os]
        function pull(){
            local remote="origin"
            if [[ $1 == "gh" ]];then
                remote="github"
            fi
            if [[ $1 == "bb" ]];then
                remote="bitbucket"
            fi
            if [[ $1 == "os" ]];then
                remote="openshift"
            fi
            local branch="$(git rev-parse --symbolic-full-name HEAD)"
            if [[ $remote == "origin" ]];then
                if [[ -n "$1" ]];then
                    branch="$1"
                fi
            fi
            if [[ -n "$2" ]];then
                branch="$2"
            fi
            command git pull -t $remote $branch
        }
    # push [gh/bb/os]
        function push(){
            local remote="origin"
            if [[ $1 == "gh" ]];then
                remote="github"
            fi
            if [[ $1 == "bb" ]];then
                remote="bitbucket"
            fi
            if [[ $1 == "os" ]];then
                remote="openshift"
            fi
            local branch="--mirror"
            if [[ $remote == "origin" ]];then
                if [[ -n "$1" ]];then
                    branch="$1"
                fi
            fi
            if [[ -n "$2" ]];then
                branch="$2"
            fi
            command git push -f --thin $remote $branch
            printf "\a\a\a\a"
        }
    # commit & push
        function gcp(){
            gc $@
            push
        }

    # SSH
        function ssh(){
            if [[ -n $2 && ! $2 == *-* ]]; then
                local command="echo \"${@:2}\" | command ssh $1"
            else
                local command="command ssh $@"
            fi
            # echo "$command"
            eval "$command"
        }
        # function ssh(){
        #     command ssh "$@"
        # }
    # SSH Generate key
        function sshkeygen(){
            command ssh-keygen -f $1_id_rsa -t rsa -C $@ -q -N ''
            if [[ $? -eq 0 ]];then
            command mv $1_id_rsa* ~/.ssh
            command echo "" >> ~/.ssh/config
            command echo "## $1" >> ~/.ssh/config
            command echo "    # github" >> ~/.ssh/config
            command echo "        Host           $1.github.com" >> ~/.ssh/config
            command echo "        Hostname       github.com" >> ~/.ssh/config
            command echo "        IdentityFile   ~/.ssh/$1_id_rsa" >> ~/.ssh/config
            command echo "    # bitbucket" >> ~/.ssh/config
            command echo "        Host           $1.bitbucket.org" >> ~/.ssh/config
            command echo "        Hostname       bitbucket.org" >> ~/.ssh/config
            command echo "        IdentityFile   ~/.ssh/$1_id_rsa" >> ~/.ssh/config
            command echo "" >> ~/.ssh/config
            command cat ~/.ssh/$1_id_rsa.pub > /dev/clipboard
            command echo -e "Copied to clipboard : ~/.ssh/$1_id_rsa.pub : $(cat ~/.ssh/$1_id_rsa.pub)"
            command echo "Updated ~/.ssh/config to use URLs like this..."
            command echo -e "git remote add github git@\e[7m$1.\e[0mgithub.com:$1/<project>.git"
            command echo -e "git remote add bitbucket git@\e[7m$1.\e[0mbitbucket.org:$1/<project>.git"
            fi
        }
    # # git rewrite usernames in history
        # function gh(){
        #     if [[ -n "$1" && -n "$2" ]];then
        #         local from="$1"
        #         local to="$2"
        #         command git filter-branch --commit-filter 'if [ "$GIT_COMMITTER_NAME" = "x" ]; then export GIT_AUTHOR_NAME="$to"; GIT_COMMITTER_NAME="$to"; export GIT_AUTHOR_EMAIL=$to@gmail.com; export GIT_COMMITTER_EMAIL=$to@gmail.com; fi; git commit-tree "$@"'
        #     fi
        # }
##notify
    #notify
        function notify {
            nircmd mediaplay 1000 "C:\Windows\Media\Windows Ding.wav" > /dev/null 2>&1
            if [ "$?" -ne "0" ]; then
                echo -e "\a\a"
            fi
        }


## npm related
    # .npmrc if exists, run with that (usefull for multiple accounts on same machine)
        function npm(){
            local args="--no-color"
            if [[ -f .npmrc ]];then
                local userconfig="--userconfig=.npmrc"
            elif [[ -f ._npmrc ]];then
                local userconfig="--userconfig=._npmrc"
            elif [[ -f npmrc ]];then
                local userconfig="--userconfig=npmrc"
            fi
            local globalignorefile="--globalignorefile=~/.gitignore"
            eval "command npm $userconfig $globalignorefile $args $@"
        }
    # publish after incrementing version (patch)
        function publish(){
            if [[ -z "$@" ]]; then
                npm version patch
            else
                local msg="$@"
                npm version patch -m "$msg"
            fi
            npm publish
            gcp
            notify
        }

## Proceed only if interactive terminal
    if ! [[ -t 0 ]];then return; fi




## Basic commands
    # Setting some Environment Variables
        if [[ -z "$app" ]];then
            export app=${PWD##*/}
        fi
        if [[ -z "$IP" ]];then
            export IP='0.0.0.0'
        fi
        if [[ -z "$PORT" ]];then
            # export local='trueByPort'
            export PORT='80'
        fi
        export env='dev'
        if [[ -n "$C9_USER" ]];then
            export remote='C9'
        fi
        if [[ -n "$OPENSHIFT_LOG_DIR" ]];then
            export remote='OS'
            export OPENSHIFT='true'
            export OPENSHIFT_HOME_DIR='app-root/data/'
            export HOME=$HOME$OPENSHIFT_HOME_DIR
            function logs(){
                cd $OPENSHIFT_LOG_DIR
            }
            cd ~
        fi
        parts > /dev/null 2>&1
        if [[ $? -eq 0 ]]; then
            export remote='nitrous'
        fi
    # exit
        function e(){
            command exit
        }
    # directory
        function d(){
            command echo ${PWD}
        }
        function dir(){
            ls -1Ash --color=always
        }
    # disk usage; default
        duarg="-hsc *"
        sort -h /dev/null > /dev/null 2>&1
        if [[ $? -eq 0 ]];then
            dusortarg="| sort -h"
        else
            dusortarg="| perl -e 'sub h{%h=(K=>10,M=>20,G=>30);(\$n,\$u)=shift=~/([0-9.]+)(\D)/; return \$n*2**\$h{\$u}}print sort{h(\$a)<=>h(\$b)}<>;'"
        fi
        if [[ -x more ]];then
            dumorearg="| more"
        fi
        function du(){
            if [[ -n "$@" ]];then
                command du $@
            else
                # eval $(echo command du "$duarg" "$dusortarg" "$dumorearg")
                eval "command du $duarg $dusortarg $dumorearg"
            fi
        }
        function size(){
            du
        }
        function df(){
            command df -h $@
        }
    # ls
        function ls(){
            command ls -A --color=always $@
            d
        }
    # remove
        function rm(){
            command rm -rf $@
        }
        function del(){
            rm $@
        }
    # cd
        function cd..(){
            command cd ..
        }
        function cd/(){
            command cd /
        }
    # screen
        function screen(){
            if [[ $@ == *-* ]]; then
                local args="$@"
            elif [[ -n "$@" ]]; then
                local args="-r $@"
                local backupargs="-S $@"
            elif [[ -z "$@" ]]; then
                local args="-ls"
            else
                local args="$@"
            fi

            eval "command screen $args"

            if [[ $? -ne 0 && -n $backupargs ]]; then
                eval "command screen $backupargs"
            fi
        }
        function scr(){ screen $@; }
        function sc(){ scr $@; }

## --no-color
    # grunt --no-color
        function grunt(){
            command grunt --no-color $@
        }
        function g(){
            grunt $@
        }
    # bower --no-color
        function bower(){
            if [[ -z "$@" ]];then
                command bower --no-color install
            else
                command bower --no-color $@
            fi
        }
        function b(){
            bower $@
        }
## node app related
    # run through npm
        # function run(){
        #     if [[ "$1" == "update" ]];then
        #         npm install ${@:2}
        #     fi
        #     npm start
        # }
        # function r(){
        #     run $@
        # }
        # # function s(){
        # #     run $@
        # # }
## yoman related
    # run without colors by default
        function yo(){
            command yo --no-color $@
        }
## mocha
    # run mocha without colors by default
        function mocha(){
            command mocha --no-colors $@
        }
## opsnshift related
    # ! Store your appname, username, password, maybe token in your local .bashrc
        # export app='appname'
        # export osu='username'
        # export osp='password'
        # export ost='token_-_-_-_-_-_-_-...'
        # set password at runtime (if you don't wanna store it in your local .bashrc)
            function osp(){
                export osp=$@
            }
    # rhc <commands>
        function rhc(){
            if [[ -n "$osp" ]];then
                local auth="--server openshift.redhat.com -l $osu -p $osp"
            elif [[ -n "$ost" ]];then
                local auth="--token $ost"
            fi
            # commands with a hyphen "-" in them automatically add your app name.
            if [[ $1 == *-* ]];then
                eval "command rhc $@ $auth -a $app"
            else
                eval "command rhc $@ $auth"
            fi
        }
    # ssh into opsnshift
        function sshos(){
            rhc ssh $@ -a $app
        }
    # oslogs [f][r]
        # view oslogs of nodejs.log;
        # default tailed logs
        # f=full logs from file
        # r= in reverse order (latest bottom)
        function oslogs(){
            if [[ "${1:0:1}" == "f" ]];then
                if [[ "${1:1:2}" == "r" ]] || [[ "${2:0:1}" == "r" ]];then
                    sshos "--command 'tac app-root/logs/nodejs.log'"
                else
                    sshos "--command 'cat app-root/logs/nodejs.log'"
                fi
            else
                rhc tail -f app-root/logs/nodejs.log -a $app
            fi
        }
## mysql apache related
    #mysql
        function mysqld(){
            if [[ "$remote" == "nitrous" ]];then
                if [[ $@ == stop* ]];then
                    command parts stop mysql
                elif [[ $@ == start* ]];then
                    command parts stop mysql
                    command parts start mysql &
                else
                    command mysqld $@
                fi
            elif [[ "$remote" == "C9" ]];then
                if [[ $@ == stop* ]];then
                    mysql-ctl stop
                elif [[ $@ == start* ]];then
                    mysql-ctl stop
                    mysql-ctl start &
                else
                    mysql-ctl $@
                fi
            else
                command mysqld $@
            fi
        }
        function mysql(){
            if [[ "$remote" == "C9" ]];then
                # mysql-ctl cli
                local user="-u $C9_USER"
                local socket="-S /home/ubuntu/lib/mysql/socket/mysql.sock"
            fi
            if [[ -n "$mysqlpassword" ]];then
                local password="--password=$mysqlpassword"
            fi
            if [[ -n "$mysqluser" ]];then
                local user="-u $mysqluser"
            else
                local user="-u root"
            fi
            command mysql $user $password $socket $@
        }
        function mysqldump(){
            if [[ -n "$mysqlpassword" ]];then
                local password="--password=$mysqlpassword"
            fi
            if [[ -n "$mysqluser" ]];then
                local user="-u $mysqluser"
            else
                local user="-u root"
            fi
            command mysqldump $user $password $@
        }
    #apache
        function apache(){
            if [[ "$remote" == "nitrous" ]];then
                if [[ $@ == stop* ]];then
                    command parts stop apache2
                elif [[ $@ == start* ]];then
                    command parts stop apache2
                    command parts start apache2 &
                else
                    command apachectl $@
                fi
            else
                command apachectl $@
            fi
        }
    #httpd.conf & php.ini
        if [[ "$remote" == "nitrous" ]];then
            export httpd="~/.parts/etc/apache2/httpd.conf"
            export php="~/.parts/etc/php5/php.ini"
        fi
## mongoDB related
    #mongo
        function mongo(){
            # if [[ "$@" =~ "[\(\)]+" ]]; then
            # if echo $@ | grep -E "[\(\)]+" ; then
            if [[ "$@" == *\(* ]]; then
                local commands="--eval '$@'"
            else
                local args="$@"
            fi
            if [[ -n "$OPENSHIFT_MONGODB_DB_PASSWORD" ]];then
                local auth="--host $OPENSHIFT_MONGODB_DB_HOST --port $OPENSHIFT_MONGODB_DB_PORT -u $OPENSHIFT_MONGODB_DB_USERNAME -p $OPENSHIFT_MONGODB_DB_PASSWORD"
            fi
            eval "command mongo $args $commands $app"
        }
    #mongod
        function mongod(){
            if [[ -n "$local" ]];then
                start C:\\localhost\\mongodb\\Run.BAT
            else
                if [[ "$remote" == "nitrous" ]];then
                    if [[ $@ == stop* ]];then
                        command parts stop mongodb
                    else
                        command parts stop mongodb
                        command parts start mongodb &
                    fi
                elif [[ "$remote" == "C9" ]];then
                    mkdir /home/ubuntu/data
                    rm /home/ubuntu/data/mongod.lock
                    command mongod --bind_ip=$IP --dbpath=/home/ubuntu/data --nojournal &
                else
                    if [[ -z "$@" ]];then
                        command mongod
                    elif [[ $@ == *-* ]];then
                        command mongod $@
                    else
                        if [[ $1 == */ ]];then
                            set -- "${1::-1}"
                        fi
                        rm $1/mongod.lock
                        command mongod --bind_ip=$IP --dbpath=$1 --nojournal &
                    fi
                fi
            fi
        }


## Last command execution time
    #Last command
        function last_command(){
            local last_command="$(history 1)"
            last_command=${last_command:7}
            echo "$last_command"
        }
    #timer
        first_time="true"
        function timer_start {
            timer=${timer:-$SECONDS}
            echo -ne "\033]0;$app $remote - sh ($(last_command))\007"
            # if [[ "$first_time" == "true" ]];then
            #     first_time="false"
            # else
            #     echo -ne "\033]0;$app$remote - sh ($(last_command))\007"
            # fi
        }
        function timer_stop {
            timer_show=$(($SECONDS - $timer))
            unset timer
            if [[ $timer_show -gt 60 ]];then
                timer_show=$((timer_show/60))
                timer_show_unit="m"
            else
                timer_show_unit="s"
                [[ $timer_show -lt 5 ]] && return # if <5sec
            fi
            # echo "$timer_show"
            # echo -e "\e[7m$timer_show$timer_show_unit $(date +'[%T (%d-%b-%Y)]')\e[0m"
            # echo -e "\e[7m$timer_show$timer_show_unit $(date +'[%T]')\e[0m"
            echo -e "\e[7m$timer_show$timer_show_unit\e[0m \e[7m$(date +'%H:%M')\e[0m"
            notify
        }
        trap 'timer_start' DEBUG
## Bash Display Settings
    # Prompt
        # check if git available
        function __git_ps1(){
            local b="$(git symbolic-ref HEAD 2>/dev/null)";
            if [ -n "$b" ]; then
                printf " (%s)" "${b##refs/heads/}";
            fi
        }
        # modified gitps1
        function gitps1(){
            if [[ "$(__git_ps1)" != " (master)" ]];then
                echo "$(__git_ps1) "
            else
                echo " "
            fi
        }

        function PSremote(){
            if [[ -n "$remote" ]];then
                echo -e "\e[7m$remote\e[0m "
            fi
        }
        function PSappname(){
            if [[ -n "$app" ]];then
                echo -e "\e[7m$app\e[0m "
            fi
        }
        function PSdir(){
            if [[ "${PWD##*/}" == "" ]];then
                echo -e "\e[0m/\e[0m"
            elif [[ "${PWD}" == "$HOME" ]];then
                echo -e "\e[0m~\e[0m"
            elif [[ "${PWD##*/}" == "workspace" ]];then
                echo -e "\b"
            elif [[ "${PWD}" == "$HOME/${PWD##*/}" ]];then
                echo -e "\e[0m~/${PWD##*/}\e[0m"
            elif [[ "${PWD##*/}" == "$app" ]];then
                # echo -e "\e[0m./\e[0m"
                echo -e "\b"
            elif [[ "${PWD}" == "/${PWD##*/}" ]];then
                echo -e "\e[0m/${PWD##*/}\e[0m"
            else
                echo -e "\e[0m…/${PWD##*/}\e[0m"
            fi
        }
        function PSgit(){
            gitps1
        }
        function PSpromptsymbol(){
            echo -e "\e[7m$\e[0m "
        }

        function p(){
            PS1='$(PSremote)$(PSappname)$(PSdir)$(PSgit)$(PSpromptsymbol)'
            # PS1='$(if [[ -n "$remote" ]];then echo -e "\e[7m$remote\e[0m ";fi)$(if [[ -n "$app" ]];then echo -e "\e[7m$app\e[0m ";fi)…/${PWD##*/}$(gitps1)\e[7m$\e[0m '
            # http://google.com/search?q=bash+prompt+right+align+???
            # PS1='\e[7m$remote\e[0m \e[7m$app\e[0m …/${PWD##*/}$(if [[ "$(__git_ps1)" != " (master)" ]];then echo "$(__git_ps1)"; fi) \e[7m$\e[0m '
            # PS1='\e[7m$remote\e[0m \e[7m$app\e[0m …/${PWD##*/} \e[7m$\e[0m '
            # if [[ -n "$remote" ]];then
            # else
            #   PS1='\e[7m$app\e[0m \e[7m$\e[0m '
            # fi
            # PS1='\e[7m…/${PWD##*/}$(__git_ps1) $>\e[0m '
            # PS1='\[\033[33m\]…/${PWD##*/}$(__git_ps1) $> \[\033[0m\]'
                # …/directory (master) $>
            # PS1='\w$(__git_ps1) $ '
            # PS1='\[\033[33m\]\w$(__git_ps1)\[\033[0m\] $'
            # PS1='\[\033[0m\]\[\033[32m\]\u@\h \[\033[33m\]\w$(__git_ps1)\[\033[0m\]\n$'
        }
        p
        function ps(){
            p
        }
        function ps1(){
            p
        }
    # Title
        function PCremote(){
            if [[ -n "$remote" ]];then
                echo -e "$remote"
            fi
        }
        function prompt_command(){
            # Title bar
                # echo -ne "\033]0;$app$(gitps1) [${PWD}] - sh\007"
                # echo -ne "\033]0;$app$(gitps1) - sh\007"
                # echo -ne "\033]0;$app$(gitps1)$remote - sh\007"
                # echo -ne "\033]0;$app$(gitps1)$remote - sh [$(fc -nl 0)]\007"
                echo -ne "\033]0;$app$(gitps1)$remote - sh ($(last_command))\007"


            # Last command execution time
                # last_execution_time_prompt_command
                timer_stop
        }
        PROMPT_COMMAND='prompt_command'


# ===================================================================================================================== #
# fi
