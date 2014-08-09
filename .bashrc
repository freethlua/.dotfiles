
# .dotfiles | .bashrc

# execute like so:
# curl https://raw.githubusercontent.com/xxx/.dotfiles/master/.bashrc -o /tmp/temp.bashrc 2> /dev/null && . /tmp/temp.bashrc && rm /tmp/temp.bashrc

version=0.1.25

if [[ -z "$bashrc0" ]];then
echo -e "\e[7m dotfiles.bashrc \e[0m \e[7m v$version \e[0m"
export bashrc0='true'
# clear
# Environment Variables
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
	fi
	export winston='winston.log'
	export CLOG='log verbose'
	export CLOG='log verbose info'
	export CLOG=''
# aliases
	d(){
		echo ${PWD}
	}
	dir(){
		echo ${PWD}; ls -1AhsS --color=always
	}
	du(){
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
					command du -s * | sort -nr
				fi
			fi
		fi
	}
	# Save alias on runtime
		save(){
			eval "${@:2}"
			if [[ $? = 0 ]]; then
				str="alias $1='${@:2}'"
				eval $str
				echo -e "\n$str" >> ~/.bashrc
				fi
		}
	# Git graph
		gl(){
			git log --branches --remotes --tags --graph --oneline --abbrev-commit --decorate --date=relative --format=format:"%h %ar %cn %s %C(reverse)%d"
		}
		cm(){
			git add -A
			git commit -m "$@"
		}
	# Meta
		rc(){
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
	# global
	npm(){
		if [[ -f .npmrc ]];then
			command npm --userconfig=.npmrc $@
		else
			command npm $@
		fi
	}
	# alias publish='npm --userconfig=.npmrc publish'
	pub(){
		if [[ -z "$@" ]]; then
			npm version patch
		else
			npm version patch -m $1
		fi
		npm publish
	}
	alias run=run
	run(){
		if [[ "$1" == "update" ]];then
			npm install ${@:2}
		fi
		command npm start
	}
	# alias mongoshell='mongo $app'
	pull(){
		local remote='unset'
		if [[ $remote == "gh" ]];then
			remote=github
		fi
		if [[ $remote == "bb" ]];then
			remote=bitbucket
		fi
		if [[ $remote == "os" ]];then
			remote=openshift
		fi
		if [[ -n "$2" ]];then
			echo git pull -t $remote $2
		else
			echo git pull -t $remote master
		fi
	}
	push(){
		local remote='unset'
		local m=''
		local f=''
		if [[ "$1" == "f" ]];then
			local f='-f'
			remote=$2
		else
			local f=''
			remote=$1
		fi
		local m=''
		if [[ $remote == "gh" ]];then
			m='--mirror'
			remote=github
		fi
		if [[ $remote == "bb" ]];then
			m='--mirror'
			remote=bitbucket
		fi
		if [[ $remote == "os" ]];then
			m='--mirror'
			remote=openshift
		fi
		git push $f $m $remote
	}
	osp(){
		export osp=$@
	}
	rhc(){
		if [[ "${@: -1}" == "app" ]];then
			if [[ -n "$osp" ]];then
				eval "command rhc ${@:1:$(($#-1))} --server openshift.redhat.com -l $osu -p $osp --token $ost -a $app"
			else
				eval "command rhc ${@:1:$(($#-1))} -a $app"
			fi
		else
			eval "command rhc $@"
		fi
	}
	oslogs(){
		rhc tail -f app-root/logs/nodejs.log app
	}
 	sshos(){
		rhc ssh $@ app
	}
	mongo(){
		if [[ -n "$OPENSHIFT_MONGODB_DB_PASSWORD" ]];then
			command mongo --host $OPENSHIFT_MONGODB_DB_HOST --port $OPENSHIFT_MONGODB_DB_PORT -u $OPENSHIFT_MONGODB_DB_USERNAME -p $OPENSHIFT_MONGODB_DB_PASSWORD $@ $app
		else
			command mongo $@ $app
		fi
	}
	mongodb(){
		if [[ -n "$local" ]];then
			start C:\\localhost\\mongodb\\Run.BAT
		else
			/home/ubuntu/mongod
		fi
	}
	mongoeval(){
		mongo --eval $1
		}
	osmongoeval(){
		sshos "--command 'mongo --host \$OPENSHIFT_MONGODB_DB_HOST --port \$OPENSHIFT_MONGODB_DB_PORT -u \$OPENSHIFT_MONGODB_DB_USERNAME -p \$OPENSHIFT_MONGODB_DB_PASSWORD --eval \"$1\" $app'"
		}
	osmongodump(){
		sshos "--command 'mongodump --out ~/app-root/data/dump --host \$OPENSHIFT_MONGODB_DB_HOST --port \$OPENSHIFT_MONGODB_DB_PORT -u \$OPENSHIFT_MONGODB_DB_USERNAME -p \$OPENSHIFT_MONGODB_DB_PASSWORD'"
	}
	# alias osmongodump='rhc ssh itsmaidup --command "mongodump --out ~/app-root/data/dump --host \$OPENSHIFT_MONGODB_DB_HOST --port \$OPENSHIFT_MONGODB_DB_PORT -u \$OPENSHIFT_MONGODB_DB_USERNAME -p \$OPENSHIFT_MONGODB_DB_PASSWORD"'


echo "┌  Handy shortcuts  ┐"
echo "d[ir] …………………………………… echo \${PWD} [ls -1AhsS --color=always]"
echo "gl …………………………………………… git log --graph ..."
echo "cm msg ………………………………… git add -A && commit -m \"msg\""
echo "run [update] [pkg] … [npm install [pkg] &&] npm start"
echo "pull [gh/bb/os] ………… git pull -t [github/bitbucket/openshift] master"
echo "push [f] [gh/bb/os]  git push [-f] --mirror [github/bitbucket/openshift]"
echo "npm [...] ………………………… npm [[if .npmrc] --userconfig=.npmrc] [...]"
echo "publish [msg] ……………… npm version patch && publish [msg]"
echo "rhc [...] [app] ………… rhc [...] -a \$app"
echo "oslogs ………………………………… rhc tail -f app-root/logs/nodejs.log \$app"
echo "sshos [...] …………………… rhc ssh [...] \$app"
echo "mongo [...] …………………… mongo [...] \$app"
echo "mongodb ……………………………… mongod"
echo "[os]mongoeval \"...\"  [sshos --command] mongo --eval \"...\""



if [[ -n $local ]];then
	if [[ "`echo ~`" != "`echo ${PWD}`" ]]; then
		if [[ -f .bashrc ]];then
			. .bashrc
			cd $app 2> /dev/null
			# if [[ -n $local ]];then
			# 	run
			# fi
		fi
	fi
fi

if [[ -f ~/app.bashrc ]];then
	. ~/app.bashrc
fi

# Bash Display Settings
	# Prompt
		PS(){
			if [[ -n "$remote" ]];then
				PS1='\e[7m$remote\e[0m \e[7m$app\e[0m \e[7m$\e[0m '
			else
				PS1='\e[7m$app\e[0m \e[7m$\e[0m '
			fi
		}
		PS
		# PS1='\e[7m…/${PWD##*/}$(__git_ps1) $>\e[0m '
		# PS1='\[\033[33m\]…/${PWD##*/}$(__git_ps1) $> \[\033[0m\]'
			# …/directory (master) $>
		# PS1='\w$(__git_ps1) $ '
		# PS1='\[\033[33m\]\w$(__git_ps1)\[\033[0m\] $'
		# PS1='\[\033[0m\]\[\033[32m\]\u@\h \[\033[33m\]\w$(__git_ps1)\[\033[0m\]\n$'
	# Title
		if [[ -n "$OPENSHIFT" ]];then
			PROMPT_COMMAND='echo -ne "\033]0;$app ($remote) ${PWD}\007"'
		else
			PROMPT_COMMAND='echo -ne "\033]0;$app$(__git_ps1) ${PWD}\007"'
		fi
# ===================================================================================================================== #
fi