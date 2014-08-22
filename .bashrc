# .dotfiles | .bashrc
# execute like so:
# curl https://raw.githubusercontent.com/xxx/.dotfiles/master/.bashrc -s -o /tmp/temp.bashrc && . /tmp/temp.bashrc && rm /tmp/temp.bashrc
version=0.3.0e
echo loading... $version
echo bashrc1=$bashrc1
# Run only if never run before
	if [[ -z "$bashrc1" ]];then
	export bashrc1='true'
	echo loading...

else echo skipped.
fi