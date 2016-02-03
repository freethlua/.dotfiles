#!/bin/bash
# .dotfiles | .bashrc
# put in your .bashrc like so:
# source <(curl -sk https://raw.githubusercontent.com/xxxxxxxxx/.dotfiles/master/.bashrc)
# or
# curl -sk https://raw.githubusercontent.com/xxxxxxxxx/.dotfiles/master/.bashrc -o /tmp/temp.bashrc 2> /dev/null && . /tmp/temp.bashrc && rm -f /tmp/temp.bashrc
# or
# if [[ -t 0 ]];then curl -sk https://raw.githubusercontent.com/xxxxxxxxx/.dotfiles/master/.bashrc -o /tmp/temp.bashrc 2> /dev/null && . /tmp/temp.bashrc && rm -f /tmp/temp.bashrc; fi


version=1_5_2
if [[ "$dotfilesbashrcversion1_5_2" == "true" ]];then
    return
else
    dotfilesbashrcversion1_5_2="true"
fi
function .v(){
    # echo -e "\e[7m .dotfiles/.bashrc \e[0m \e[7m v$version \e[0m"
    echo -e "\e[7m.v$version\e[0m"
}
# clear
## Run local .bashrc(s)
    if [[ -f ./.bashrc ]];then
        . ./.bashrc
    fi

alias rm="rm -rf $@"

## Git related
    # git
        # function git(){
        #     # # command git $@ 2>&1 | tee -a git_$1.log
        #     # if [[ -w git_$1.log ]];then
        #     #     command git $@ 2>&1 | tee -a git_$1.log
        #     # else
        #     #     command git $@
        #     # fi
        #     command git $@
        # }
    # git log
        function gl(){
            git log --all --branches --remotes --tags --graph --oneline --abbrev-commit --decorate --date=relative --format=format:"%h %ar %cn %s %d" 2>&1 | tee -a git.log
            # command git log --all --branches --remotes --tags --graph --oneline --abbrev-commit --decorate --date=relative --format=format:"%h %ar %cn %s %C(reverse)%d"
            # command git log --all --branches --remotes --tags --graph --oneline --abbrev-commit --date=relative --format=format:"%h %ar %cn %s %d"
        }
    # git gui and gitk
        function gui(){
            git gui &
        }
        function gitk(){
            if [[ -n "$@" ]];then
                command gitk $@ &
            else
                command gitk --all --branches --tags --remotes --date-order --full-history &
            fi
        }
        function guik(){
            gitk & gui
        }
    # commit auto
        function gc(){
            git add -A 2>&1 | tee -a git.log
            if [[ -z "$@" ]];then
                local message="."
            else
                local message="$@"
            fi
            git commit -a -m "$message" 2>&1 | tee -a git.log
        }
    # stash
        function stash(){
            local args=$@
            if [[ $@ == s* ]];then
                local args="save --keep-index"
            fi
            git stash $args 2>&1 | tee -a git.log
        }
    # git remote
        function remote(){
            if [[ -z "$@" ]];then
                git remote -v 2>&1 | tee -a git.log
            elif [[ "$1" == *"@"* || "$1" == *"http"* ]];then
                git remote add origin $1 2>&1 | tee -a git.log
                git remote set-url origin $1 2>&1 | tee -a git.log
            else
                git remote $@ 2>&1 | tee -a git.log
            fi
        }
    # git status
        function status(){
            git status $@ 2>&1 | tee -a git.log
        }
        function st(){
            status $@
        }
    # git checkout
        function checkout(){
            local args=$@
            if [[ "$1" == "-" ]];then
                local args="-- ."
                git clean -df 2>&1 | tee -a git.log
            fi
            git checkout $args 2>&1 | tee -a git.log
        }
        function ch(){
            checkout $@
        }
    # git add
        function add(){
            local args=$@
            if [[ -z "$args" ]];then
                local args="-i"
            fi
            git add $args 2>&1 | tee -a git.log
        }
    # git checkout master
        function master(){
            checkout $@ master
        }
    # pull [gh/bb/os]
        function pull(){
            local remote="origin"
            if [[ $1 == "gh" ]];then
                local remote="github"
            fi
            if [[ $1 == "bb" ]];then
                local remote="bitbucket"
            fi
            if [[ $1 == "os" ]];then
                local remote="openshift"
            fi
            if [[ $1 == "wp" ]];then
                local remote="wp-engine"
                local branch="wp-engine"
            fi
            if [[ $1 == "wpst" ]];then
                local remote="wp-engine-staging"
                local branch="wp-engine"
            fi
            local branch="$(git rev-parse --symbolic-full-name HEAD)"
            if [[ $remote == "origin" ]];then
                if [[ -n "$1" ]];then
                    local branch="$1"
                fi
            fi
            if [[ -n "$2" ]];then
                branch="$2"
            fi
            git pull -t $remote $branch 2>&1 | tee -a git.log
        }
    # push [gh/bb/os]
        function push(){
            if [[ $1 == -* ]];then git push $@; return; fi

            local remote="origin"
            local branch="master"

            if [[ -n "$1" ]];then local remote="$1"; fi
            if [[ -n "$2" ]];then local branch="$2"; fi

            # if [[ "$remote" == "os" ]];then local remote="openshift"; fi

            if [[ $1 == "gh" ]];then
                local remote="github"
            fi
            if [[ $1 == "bb" ]];then
                local remote="bitbucket"
            fi
            if [[ $1 == "os" ]];then
                local remote="openshift"
            fi
            if [[ $1 == "wp" ]];then
                local remote="wp-engine"
                local branch="wp-engine"
            fi
            if [[ $1 == "wpst" ]];then
                local remote="wp-engine-staging"
                local branch="wp-engine"
            fi

            if [[ $branch == "master" ]];then
                local all="--all"
                local branch=
            fi


            echo Pushing to:\"$remote\" branch:\"$branch$all\" 2>&1 | tee -a git.log
            git push -f $all --thin $remote $branch 2>&1 | tee -a git.log
        }
    # commit & push
        function gcp(){
            gc $@
            push
        }
        function gcpos(){
            gcp $@
            rhc app-tidy
            push os
        }
    # init, remote, commit & push
        function girp(){
            git init
            remote $@
            gcp initial commit
        }
    # init, name
        function gin(){
            git init
            git config user.name $1
            if [[ -n $2 ]]; then
                git config user.email $2
            else
                git config user.email $1@gmail.com
            fi
        }

    # SSH
        function ssh(){
            command ssh -t $@ 2>&1 | tee -a ssh.log
            # if [[ -n $2 && ! $2 == *-* ]]; then
            #     local command="${@:2}"
            # fi
            #     # command ssh -t $1 "${@:2}"
            #     # local command="echo \"${@:2}\" | command ssh $1"
            # # else
            # #     local command="command ssh $@"
            # # # echo "$command"
            # # eval "$command"
        }
        # function ssh(){
        #     command ssh "$@"
        # }
    # SSH Generate key
        function sshkey(){
            echo Creating SSH Key
            # sshkeygen your-name
            if [[ -z "$@" ]];then
                printf " Usage: $ sshkey enter_your_project_name "
                read project_name
            else
                local project_name=$@
            fi
            shift
            command ssh-keygen -f $(echo $project_name)_id_rsa -t rsa -q -N "" -C $project_name
            if [[ ! $? -eq 0 ]];then return; fi
            command mv $(echo $project_name)_id_rsa* ~/.ssh
            command echo "" >> ~/.ssh/config
            command echo "## $(echo $project_name)" >> ~/.ssh/config
            command echo "    # github" >> ~/.ssh/config
            command echo "        Host           $(echo $project_name).github.com" >> ~/.ssh/config
            command echo "        Hostname       github.com" >> ~/.ssh/config
            command echo "        IdentityFile   ~/.ssh/$(echo $project_name)_id_rsa" >> ~/.ssh/config
            command echo "    # bitbucket" >> ~/.ssh/config
            command echo "        Host           $(echo $project_name).bitbucket.org" >> ~/.ssh/config
            command echo "        Hostname       bitbucket.org" >> ~/.ssh/config
            command echo "        IdentityFile   ~/.ssh/$(echo $project_name)_id_rsa" >> ~/.ssh/config
            command echo "" >> ~/.ssh/config
            echo " Done!"
            echo " ~/.ssh/$(echo $project_name)_id_rsa.pub"
            command cat ~/.ssh/$(echo $project_name)_id_rsa.pub > /dev/clipboard
            command cat ~/.ssh/$(echo $project_name)_id_rsa.pub
            command echo " Copied to clipboard"
            command echo " Updated ~/.ssh/config, now you can use URLs like this..."
            command echo -e "  $ git remote add github git@\e[7m$(echo $project_name).\e[0mgithub.com:$(echo $project_name)/<project>.git"
            command echo -e "  $ git remote add bitbucket git@\e[7m$(echo $project_name).\e[0mbitbucket.org:$(echo $project_name)/<project>.git"
        }
    # # git rewrite usernames in history
        # function gh(){
        #     if [[ -n "$1" && -n "$2" ]];then
        #         local from="$1"
        #         local to="$2"
        #         command git filter-branch --commit-filter 'if [[ "$GIT_COMMITTER_NAME" = "x" ]]; then export GIT_AUTHOR_NAME="$to"; GIT_COMMITTER_NAME="$to"; export GIT_AUTHOR_EMAIL=$to@gmail.com; export GIT_COMMITTER_EMAIL=$to@gmail.com; fi; git commit-tree "$@"'
        #     fi
        # }
##notify
    #notify
        function notify {
            echo -e "\a\a"

            nircmd mediaplay 1000 "C:\Windows\Media\Windows Ding.wav" > /dev/null 2>&1
            local title=$1
            if [[ -z $title ]]; then
                local title=bash
            fi
            local message=${@:2}
            if [[ -z $message ]]; then
                local message=notification
            fi
            notifu.exe -p "$title" -m "$message" > /dev/null 2>&1
        }


## node related
    # node .
        function node_auto(){
            local file=$(node_getFileAuto)
            echo $file
            node $file
        }
        function nodeloop(){
            echo -e "Running node..."
            eval "command node $@ $flags $file 2>&1 | tee -a .log"
            # eval "command node $file $@"
            if [[ "$loop" == "true" ]]; then
                echo -e "\n=x=====================x=\n"
            else
                read -rsp $'\n\n========\nFinished. Press Enter to re-run...\n'
            fi
            # clear
            node $@
        }
        function node_getFileAuto(){
            # if [[ -n $1 && -f $1 ]]; then local file=$1; shift; fi
            if [[ -f ./lib/index.js ]]; then cd lib; local file="index.js"; fi
            if [[ -f ./server/index.js ]]; then local file="server"; fi
            if [[ -f ./server.js ]]; then local file="server.js"; fi
            if [[ -f ./index.js ]]; then local file="index.js"; fi
            if [[ -f ./app.js ]]; then local file="app.js"; fi
            if [[ -f ./app/index.js ]]; then local file="app"; fi
            echo "$file"
        }
        # function node(){
        #     # local file=$(node_getFileAuto)
        #     echo -e "Running $@ \n=======\n"
        #     # eval "command node $file $@ $flags 2>&1 | tee -a nodejs.log"
        #     eval "command node $@ 2>&1 | tee -a nodejs.log"
        #     if [[ "$loop" == "true" ]]; then
        #         echo -e "\n=x=====================x=\n"
        #     else
        #         read -rsp $'\n\n========\nFinished. Press Enter to re-run...\n'
        #     fi
        #     # clear
        #     node $@
        # }
        # function node(){
        #     # local flags="--harmony --harmony_modules --harmony_regexps --harmony_proxies --harmony_sloppy_function --harmony_sloppy_let --harmony_unicode_regexps --harmony_reflect --harmony_destructuring --harmony_default_parameters --harmony_sharedarraybuffer --harmony_atomics --harmony_simd"
        #     local flags=""
        #     # if [[ $@ =~ loop|run ]]; then local loop=true; shift; fi
        #     # if [[ $1 == loop ]]; then local loop=true; shift; fi
        #     if [[ $@ == *"loop" ]]; then local loop=true; shift; fi
        #     if [[ -n $@ ]]; then
        #         command node $@
        #     else
        #         if [[ -f ./lib/index.js ]]; then cd lib; fi
        #         if [[ -f ./server/index.js ]]; then local file="server"; fi
        #         if [[ -f ./server.js ]]; then local file="server"; fi
        #         if [[ -f ./index.js ]]; then local file="."; fi
        #         if [[ -f ./app.js ]]; then local file="app"; fi
        #         if [[ -f ./app/index.js ]]; then local file="app"; fi
        #         if [[ -n $file ]]; then
        #             echo -e "Running $file $@ \n=======\n"
        #             eval "command node $@ $flags $file 2>&1 | tee -a .log"
        #             # eval "command node $file $@"
        #             if [[ "$loop" == "true" ]]; then
        #                 echo -e "\n=x=====================x=\n"
        #             else
        #                 read -rsp $'\n\n========\nFinished. Press Enter to re-run...\n'
        #             fi
        #             # clear
        #             node $@
        #         else
        #             command node $@
        #         fi
        #     fi
        # }
        function babel(){
            if [[ ! -f ./index.js ]]; then
                command babel-node $@
            else
                command babel-node . $@
                read -rsp $'Press enter to continue...\n'
                # read -rsp $'Press escape to continue...\n' -d $'\e'
                clear
                babel-node $@
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
            echo "\$npm $@" >> npm.log
            eval "command npm $userconfig $globalignorefile $args $@ 2>&1 | tee -a npm.log"
        }
    # publish after incrementing version (patch)
        function publish(){
            local whoami="$(npm whoami)"
            echo You are $whoami
            if [[ $whoami == *"Not authed"* ]]; then return; fi
            read -rsp $'Press Enter to Publish\n'
            echo -e "\n Comitting unsaved changes, if any..."
            gc $@
            # echo -e "\n Upping patch version..." (You manually update it)
            # if [[ -n "$@" ]]; then
            #     npm version patch -m "$@"
            # else
            #     npm version patch
            # fi
            echo -e "\n Git Push..."
            gcp $@
            echo -e "\n Publishing..."
            npm publish
            echo -e "\n Done"
            notify Published by $whoami
        }


## Proceed only if interactive terminal
    if ! [[ -t 0 ]];then
        # echo Non-interactive terminal, some commands un-available
        return;
    fi




## Basic commands
    # Setting some Environment Variables
        if [[ -z "$app" ]];then
            export app=${PWD##*/}
        fi
        if [[ -z "$IP" ]];then
            export IP="0.0.0.0"
        fi
        if [[ -z "$PORT" ]];then
            # export local="trueByPort"
            export PORT="80"
        fi
        # export env="dev"
        if [[ -n "$C9_USER" ]];then
            export remote="C9"
            export app="$C9_PROJECT"
        fi
        if [[ -n "$OPENSHIFT_LOG_DIR" ]];then
            export app="$OPENSHIFT_APP_NAME"
            export remote="OS"
            export OPENSHIFT="true"
            export NODE_ENV="production"
            # export OPENSHIFT_HOME_DIR="app-root/data/"
            # export HOME=$OPENSHIFT_REPO_DIR
            function logs(){
                cd $OPENSHIFT_LOG_DIR
            }
            function data(){
                cd $OPENSHIFT_DATA_DIR
            }
            function repo(){
                cd $OPENSHIFT_REPO_DIR
            }
            cd $OPENSHIFT_REPO_DIR
        fi
        parts > /dev/null 2>&1
        if [[ $? -eq 0 ]]; then
            export remote="nitrous"
        fi
    # exit
        function e(){
            command exit
        }
        function q(){
            command exit
        }
    # directory
        function d(){
            command echo ${PWD}
        }
        function dir(){
            ls -1Ash --color=always
        }
    # mkdir cd
        function mkcd(){
            mkdir $@
            cd $@
        }
    # disk usage; default
        # duarg="-hsc *"
        # duarg="-hsc * .*"
        # duarg="-hsc .[!.]* *"
        # duarg="-hsc .[^.]*"
        duarg="-hsc .[^.]* *"
        # http://askubuntu.com/questions/356902/why-doesnt-this-show-the-hidden-files-folders#comment852800_356902
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
            command ls -Ahl $@
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
    # yum install
        function yum(){
            command yum -y $@
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

## Git Advanced
    # cdc
        # http://stackoverflow.com/questions/454734/how-can-one-change-the-timestamp-of-an-old-commit-in-git/24584976#24584976
        function cdc(){
            commit="$1" datecal="$2" message="${@:3}"
            # echo $commit $datecal $message
            temp_branch="temp-rebasing-branch"
            current_branch="$(git rev-parse --abbrev-ref HEAD)"

            date_timestamp=$(date -d "$datecal" +%s)
            date_r=$(date -R -d "$datecal")

            if [[ -z "$commit" ]]; then
                exit 0
            fi

            git checkout -b "$temp_branch" "$commit"
            GIT_COMMITTER_DATE="$date_timestamp" GIT_AUTHOR_DATE="$date_timestamp" git commit --amend --no-edit --date "$date_r" -m "$message"
            git checkout "$current_branch"
            git rebase  --autostash --committer-date-is-author-date "$commit" --onto "$temp_branch"
            git branch -d "$temp_branch"
        }


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
## c9 related
    # tidy
        function c9tidy(){
            df
            rm ~/tmp
            rm ~/.npm
            rm ~/.nvm
            rm ~/workspace/node_modules
            rm ~/workspace/node_modules
            rm ~/data/$app*
            df
        }

## openshift related
    # ! Store your appname, username, password, maybe token in your local .bashrc
        # export app="appname"
        # export osu="username"
        # export osp="password"
        # export ost="token_-_-_-_-_-_-_-..."
        # set password at runtime (if you don't wanna store it in your local .bashrc)
            function osp(){
                export osp=$@
            }

    # rhc <commands>
        rhc(){
            # eval "command rhc $@"
            echo "\$rhc $@" >> rhc.log
            eval "command rhc $@ 2>&1 | tee -a rhc.log"
        }
    # rhc <commands>
        function rhca(){
            if [[ -n "$osp" ]];then
                local auth="--server openshift.redhat.com -l $osu -p $osp"
            elif [[ -n "$ost" ]];then
                local auth="--token $ost"
            fi
            eval "rhc $@ $auth -a $app"
        }
        function rhcja(){
            if [[ -n "$osp" ]];then
                local auth="--server openshift.redhat.com -l $osu -p $osp"
            elif [[ -n "$ost" ]];then
                local auth="--token $ost"
            fi
            eval "rhc $@ $auth"
        }
    # ssh into opsnshift
        function sshos(){
            if [[ -n "$@" ]];then
                local command="--command \'$@\'"
            fi
            rhca ssh $command
        }
    # oslogs
        function sshosl(){
            sshos tail -n 100 -f app-root/logs/nodejs.log
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
            if [[ -z "$@" ]];then
                local alldbs="--all-databases"
            fi
            command mysqldump $user $password $alldbs $@
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
            eval "command mongo $auth $args $commands $app"
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
                    command mongod --bind_ip=$IP --dbpath=/home/ubuntu/data --nojournal --smallfiles &
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

## wp-engine related
    # wpmerge
        function wpmerge(){
            if [[ "$(__git_ps1)" != " (master)" ]];then
                echo "You are not on Master branch. Checkout Master branch and commit any unsaved changes first."
                return;
            fi
            gc
            echo Step 1: Checking out [wp-engine]
            checkout wp-engine
            echo Step 2: Import changes from [master]
            checkout master -- .
            echo Step 2: Unstage
            git reset
            echo Step 3: Restore .gitignore
            checkout -- .gitignore
            echo Step 4: Re-stage and commit
            gc "merge master"
            echo Step 5: Go back to master
            checkout master
        }


## repeat
    # repeat
        function repeat(){
            echo -e "\n$@ \n=======\n"
            eval "$@ 2>&1 | tee -a ${args[0]}.log"

            echo -e "\n--------\nFinished. Press Enter to repeat"
            read -rs

            eval "repeat $@"
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
            echo -ne "\033]0;$app $remote \$ $(last_command)\007"
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
            notify bash $(last_command)\\ncommand finished executing \($timer_show$timer_show_unit\)
        }
        trap "timer_start" DEBUG
## Bash Display Settings
    # Prompt
        # check if git available
        function __git_ps1(){
            local b="$(git symbolic-ref HEAD 2>/dev/null)";
            if [[ -n "$b" ]]; then
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
            PS1="$(PSremote)$(PSappname)$(PSdir)$(PSgit)$(PSpromptsymbol)"
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
        # p
        # function ps(){
        #     p
        # }
        # function ps1(){
        #     p
        # }
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
                echo -ne "\033]0;$app$(gitps1)$remote \$ $(last_command)\007"


            # Last command execution time
                # last_execution_time_prompt_command
                timer_stop
            # PS1
                p
        }
        PROMPT_COMMAND="prompt_command"


# ===================================================================================================================== #
# fi
