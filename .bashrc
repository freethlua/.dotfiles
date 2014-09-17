# .dotfiles | .bashrc
# execute like so:
# curl https://raw.githubusercontent.com/xxx/.dotfiles/master/.bashrc -s -o /tmp/temp.bashrc && . /tmp/temp.bashrc && rm /tmp/temp.bashrc
version=0.5.8a
# echo $version
if [[ -z "$bashrcloaded053a" ]];then
export bashrcloaded053a='true'
function .v(){
    echo -e "\e[7m .dotfiles/.bashrc \e[0m \e[7m v$version \e[0m"
}
# clear
# Setting some Environment Variables
    if [[ -z "$PORT" ]];then
        export local='true'
        export PORT='80'
        export app=${PWD##*/}
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
    export winston='winston.log'
    export CLOG='log verbose'
    export CLOG='log verbose info'
    export CLOG=''
## Basic commands
    # exit
        function e(){
            command exit
        }
    # directory
        function d(){
            command echo ${PWD}
        }
        function dir(){
            command echo ${PWD}; ls -1Ahs --color=always
        }
    # disk usage; default
        function du(){
            d
            if [[ -n "$@" ]];then
                command du $@
            else
                sort -h /dev/null 2> /dev/null
                if [[ $? -eq 0 ]];then
                    command du -hs * | sort -hr | more
                else
                    if [[ -x more ]];then
                        command du -s * | sort -nr | more
                    else
                        command du -s * | sort -n
                    fi
                fi
            fi
        }
        function size(){
            du
        }
    # ls
        function ls(){
            command ls -a $@
        }
    # remove
        function rm(){
            command rm -rf $@
        }
        function del(){
            rm $@
        }
## Git related
    # Pretty Git graph
        function gl(){
            command git log --branches --remotes --tags --graph --oneline --abbrev-commit --decorate --date=relative --format=format:"%h %ar %cn %s %C(reverse)%d"
        }
    # git gui and gitk
        function gui(){
            command git gui & gitk
        }
    # commit auto
        function m(){
            command git add -A
            if [[ -z "$@" ]];then
                command git commit -m "."
            else
                command git commit -m "$@"
            fi
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
            local branch="master"
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
            command git push -f $remote $branch
        }
    # SSH Generate key
        function sshg(){
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
        function sshk(){
            sshg $@
        }
        function sshkg(){
            sshg $@
        }
        function sshkeygen(){
            sshg $@
        }
        function sshkgen(){
            sshg $@
        }
        function sshkgn(){
            sshg $@
        }
        function sshkn(){
            sshg $@
        }
    # # git rewrite usernames in history
    #     function gh(){
    #         if [[ -n "$1" && -n "$2" ]];then
    #             local from="$1"
    #             local to="$2"
    #             command git filter-branch --commit-filter 'if [ "$GIT_COMMITTER_NAME" = "x" ]; then export GIT_AUTHOR_NAME="$to"; GIT_COMMITTER_NAME="$to"; export GIT_AUTHOR_EMAIL=$to@gmail.com; export GIT_COMMITTER_EMAIL=$to@gmail.com; fi; git commit-tree "$@"'
    #         fi
    #     }
## Meta (bash related)
    # save <alias> <command> [argument(s)]
        # Run a command and save it as alias in your local .bashrc
        function save(){
            eval "${@:2}"
            if [[ $? -eq 0 ]]; then
                str="alias $1='${@:2}'"
                eval $str
                echo -e "\n$str" >> ~/.bashrc
                fi
        }
    # edit yourlocal .bashrc
        function rc(){
            if [[ "$1" == "v" ]];then
                vim ~/.bashrc
            else
                command -v "C:\Program Files (x86)\Sublime Text 2\sublime_text.exe"
                if [[ "$?" == 0 ]];then
                    "C:\Program Files (x86)\Sublime Text 2\sublime_text.exe" ~/.bashrc
                else
                    vim ~/.bashrc
                fi
            fi
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
## npm related
    # .npmrc if exists, run with that (usefull for multiple accounts on same machine)
        function npm(){
            if [[ -f .npmrc ]];then
                command npm --no-color --userconfig=.npmrc $@
            else
                command npm --no-color $@
            fi
        }
    # publish after incrementing version (patch)
        function pub(){
            if [[ -z "$@" ]]; then
                npm version patch
            else
                npm version patch -m $1
            fi
            npm publish
        }
## node app related
    # run through npm
        function run(){
            if [[ "$1" == "update" ]];then
                npm install ${@:2}
            fi
            npm start
        }
        function r(){
            run $@
        }
        function s(){
            run $@
        }
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
    # ! Store your username password and maybe token in your local .bashrc
        # export osu='username'
        # export osp='password'
        # export ost='token_-_-_-_-_-_-_-...'
        # set password at runtime (if you don't wanna store it in your local .bashrc)
            function osp(){
                export osp=$@
            }
    # rhc <commands> ["app"]
        # add "app" at the end to add "-a $app" at the end. (store your app's name in local .bashrc)
        function rhc(){
            if [[ "${@: -1}" == "app" ]];then
                if [[ -n "$osp" ]];then
                    eval "command rhc ${@:1:$(($#-1))} --server openshift.redhat.com -l $osu -p $osp -a $app"
                elif [[ -n "$ost" ]];then
                    eval "command rhc ${@:1:$(($#-1))} --token $ost -a $app"
                else
                    eval "command rhc ${@:1:$(($#-1))} -a $app"
                fi
            else
                eval "command rhc $@"
            fi
        }
    # ssh into opsnshift
        function sshos(){
            rhc ssh $@ app
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
                rhc tail -f app-root/logs/nodejs.log app
            fi
        }
## mongoDB related
    function mongo(){
        if [[ -n "$OPENSHIFT_MONGODB_DB_PASSWORD" ]];then
            command mongo --host $OPENSHIFT_MONGODB_DB_HOST --port $OPENSHIFT_MONGODB_DB_PORT -u $OPENSHIFT_MONGODB_DB_USERNAME -p $OPENSHIFT_MONGODB_DB_PASSWORD $@ $app
        else
            command mongo $@ $app
        fi
    }
    function mongodb(){
        if [[ -n "$local" ]];then
            start C:\\localhost\\mongodb\\Run.BAT
        else
            /home/ubuntu/mongod
        fi
    }
    function mongoeval(){
        mongo --eval $1
        }
    function osmongoeval(){
        sshos "--command 'mongo --host \$OPENSHIFT_MONGODB_DB_HOST --port \$OPENSHIFT_MONGODB_DB_PORT -u \$OPENSHIFT_MONGODB_DB_USERNAME -p \$OPENSHIFT_MONGODB_DB_PASSWORD --eval \"$1\" $app'"
        }
    function osmongodump(){
        sshos "--command 'mongodump --out ~/app-root/data/dump --host \$OPENSHIFT_MONGODB_DB_HOST --port \$OPENSHIFT_MONGODB_DB_PORT -u \$OPENSHIFT_MONGODB_DB_USERNAME -p \$OPENSHIFT_MONGODB_DB_PASSWORD'"
    }
## project related
    # simpleapp
        alias sm='clear ; rm -dfr ; yo --no-color simpleapp ; node simpleapp/server/app.js'
    # itsmaidup
        function delip(){
            osmongoeval "db.logs.remove({ip:\\\"$1\\\"})"
        }
        function oslogsby(){
            if [[ -n "$2" ]];then
                oslogs f | grep "$1" | grep -v "$2"
            else
                oslogs f | grep "$1"
            fi
        }
        function oslogscheck(){
            oslogsby /logs? 122.162.62.132
        }
        # echo "delip x.x.x.x ……………… osmongoeval db.logs.remove({ip:\"x.x.x.x\"})"

# # echo "┌  Handy shortcuts  ┐"
#   echo "d[ir] …………………………………… echo \${PWD} [ls -1AhsS --color=always]"
#   echo "gl …………………………………………… git log --graph ..."
#   echo "cm msg ………………………………… git add -A && commit -m \"msg\""
#   echo "run [update] [pkg] … [npm install [pkg] &&] npm start"
#   echo "pull [gh/bb/os] ………… git pull -t [github/bitbucket/openshift] master"
#   echo "push [f] [gh/bb/os]  git push [-f] --mirror [github/bitbucket/openshift]"
#   echo "npm [...] ………………………… npm [[if .npmrc] --userconfig=.npmrc] [...]"
#   echo "publish [msg] ……………… npm version patch && publish [msg]"
#   echo "rhc [...] [app] ………… rhc [...] -a \$app"
#   echo "oslogs ………………………………… rhc tail -f app-root/logs/nodejs.log \$app"
#   echo "sshos [...] …………………… rhc ssh [...] \$app"
#   echo "mongo [...] …………………… mongo [...] \$app"
#   echo "mongodb ……………………………… mongod"
#   echo "[os]mongoeval \"...\"  [sshos --command] mongo --eval \"...\""
## Run local .bashrc(s)
    if [[ -n $local ]];then
        if [[ "`echo ~`" != "`echo ${PWD}`" ]]; then
            if [[ -f .bashrc ]];then
                . .bashrc
                cd $app 2> /dev/null
                # if [[ -n $local ]];then
                #   run
                # fi
            fi
        fi
    fi
    if [[ -f ~/app.bashrc ]];then
        . ~/app.bashrc
    fi
# Bash Display Settings
    # Prompt
        # check if git available
            __git_ps1 > /dev/null 2>&1
            if [[ $? -ne 0 ]]; then
                function gitps1(){
                    echo " "
                }
            else
                function gitps1(){
                    if [[ "$(__git_ps1)" != " (master)" ]];then
                        echo "$(__git_ps1) "
                    else
                        echo " "
                    fi
                }
            fi
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
            if [[ "${PWD##*/}" == "$app" ]];then
                echo -e "\e[0m./\e[0m"
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
        PROMPT_COMMAND='echo -ne "\033]0;$app$(gitps1) ${PWD}\007"'
        # if [[ -n "$OPENSHIFT" ]];then
        #   PROMPT_COMMAND='echo -ne "\033]0;$app ($remote) ${PWD}\007"'
        # else
        #   PROMPT_COMMAND='echo -ne "\033]0;$app$(if [[ "$(__git_ps1)" != " (master)" ]];then echo "$(__git_ps1)"; fi) ${PWD}\007"'
        # fi
# ===================================================================================================================== #
fi