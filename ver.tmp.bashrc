grep "echo version" ~/.bashrc | cut -c 14- | sed -e 's/\./\n/g'
grep "echo version" ~/.bashrc | cut -c 14- | sed -e 's/\./\n/g' | sed -n '$p'


grep "echo -e \"\e\[7m dotfiles.bashrc \e\[0m \e\[7m v" ~/.bashrc
grep "echo.*dotfiles.bashrc" ~/.bashrc | cut -c 45- | sed -e 's/\./\n/g' | sed -n '$p'


grep "local version=" ~/.bashrc | cut -c 15- | sed -e 's/\./\n/g' | sed -n '$p'



versionpatch=$(grep "local version=" ~/.bashrc | cut -c 15- | sed -e 's/\./\n/g' | sed -n '$p') && echo $((versionpatch+1))


[ -x $(sort -h /dev/null) ] && echo 'cat is executable'

[ -x more ] && echo 'cat is executable'

command -v 'sort -h /dev/null' > /dev/null && echo $?

sort -h /dev/null 2> /dev/null

{sort --help} | egrep "--help"