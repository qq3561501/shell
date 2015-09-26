# .bash_profile

# Get the aliases and functions
if [ -f ~/.bashrc ]; then
	. ~/.bashrc
fi

# User specific environment and startup programs

PATH=$PATH:$HOME/bin

export PATH
board=`cat /sys/hypervisor/board/board_part | awk '{ print $3}'`
serial=`cat /sys/hypervisor/board/board_serial`
serial=${serial:0-4:4}
export PS1='[\u@$board:$serial \w]\$ '
