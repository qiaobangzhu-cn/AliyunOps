# add syntax highlight for LESS
export LESS=" -R "
export HISTCONTROL=ignorespace

# add sudo alias
sudo_zy() { if [ x"$*" == x"su -" ]; then /usr/bin/sudo -i; else /usr/bin/sudo $*; fi; }
alias sudo=sudo_zy  
# add cmd tracking
PROMT_DECLARE_DECLARE=`/usr/bin/who am i | cut -d" " -f1`
if [ $USER == root ]; then
        PROMT_DECLARE="#"
else
        PROMT_DECLARE="$"
fi

if [ x"$ZY_USER" == x ]; then
        REMOTE_USER_DECLARE=UNKNOW
else
        REMOTE_USER_DECLARE=$ZY_USER
fi

PPPID=$(pstree -p | grep $$ | sed 's/.*sshd(//g; s/).*//g')

h2l_declare='
    THIS_HISTORY="$(history 1)"
    __THIS_COMMAND="${THIS_HISTORY/*:[0-9][0-9] /}"
    if [ x"$LAST_HISTORY" != x"$THIS_HISTORY" ];then
        if [ x"$__LAST_COMMAND" != x ]; then
        __LAST_COMMAND="$__THIS_COMMAND"
        LAST_HISTORY="$THIS_HISTORY"
        logger -p local4.notice -t $PROMT_DECLARE_DECLARE "REMOTE_USER_DECLARE=$REMOTE_USER_DECLARE [$USER@$HOSTNAME $PWD]$PROMT_DECLARE $__LAST_COMMAND"
    else
            __LAST_COMMAND="$__THIS_COMMAND"
            LAST_HISTORY="$THIS_HISTORY"
    fi
    fi'
trap "$h2l_declare" DEBUG
