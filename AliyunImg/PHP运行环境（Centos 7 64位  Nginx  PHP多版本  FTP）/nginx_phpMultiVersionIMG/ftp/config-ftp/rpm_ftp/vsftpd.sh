#!/bin/bash
#
# vsftpd This shell script takes care of starting and stopping
#             standalone vsftpd.
#
# chkconfig: - 60 50
# description: Vsftpd is a ftp daemon, which is the program \
#              that answers incoming ftp service requests.
# processname: vsftpd
# config: /etc/vsftpd.conf
# Source function library.
. /etc/rc.d/init.d/functions
# Source networking configuration.
. /etc/sysconfig/network
# Check that networking is up.
[ ${NETWORKING} = "no" ] && exit 0
[ -x /usr/sbin/vsftpd ] || exit 0
RETVAL=0
prog="vsftpd"
start() {
        # Start daemons.
        if [ -d /etc ] ; then
                for i in `ls /etc/vsftpd/vsftpd.conf`; do
                        site=`basename $i .conf`
                        echo -n $"Starting $prog for $site: "
                        /usr/local/sbin/vsftpd $i &
                        RETVAL=$?
                        [ $RETVAL -eq 0 ] && {
                           touch /var/lock/subsys/$prog
                           success $"$prog $site"
                        }
                        echo
                done
        else
                RETVAL=1
        fi
        return $RETVAL
}
stop() {
        # Stop daemons.
        echo -n $"Shutting down $prog: "
        killproc $prog
        RETVAL=$?
        echo
        [ $RETVAL -eq 0 ] && rm -f /var/lock/subsys/$prog
        return $RETVAL
}
# See how we were called.
case "$1" in
start)
        start
        ;;
stop)
        stop
        ;;
restart|reload)
        stop
        start
        RETVAL=$?
        ;;
condrestart)
        if [ -f /var/lock/subsys/$prog ]; then
            stop
            start
            RETVAL=$?
        fi
        ;;
status)
        status $prog
        RETVAL=$?
        ;;
*)
        echo $"Usage: $0 {start|stop|restart|condrestart|status}"
        exit 1
esac
exit $RETVAL