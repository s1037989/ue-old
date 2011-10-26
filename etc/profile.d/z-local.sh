function cd { builtin cd "$@"; echo $(pwd) > $HOME/.pwd; }
test -f "$HOME/.pwd" || echo $(pwd) > $HOME/.pwd
cd "$(< $HOME/.pwd)"
JOE=`which joe`
VI=`which vi`
[ "$JOE" ] && EDITOR=$JOE || EDITOR=$VI
HISTTIMEFORMAT="%Y%m%d - %H:%M:%S "
alias dir="ls"
resetuser() {
	[ -z "$1" ] && {
		echo Usage: $FUNCNAME uid '[uid...]';
		return 1
	};
	until [ -z "$1" ]; do
		u=$(getent passwd $1 | cut -d : -f 3);
		g=$(getent passwd $1 | cut -d : -f 4);
		h=$(getent passwd $1 | cut -d : -f 6);
		if [ $u -a $g -a $h ]; then
			if [[ $h =~ ^/(data/users|home) ]]; then
				/bin/echo $1 : $u : $g : $h;
				/bin/mkdir -p $h;
				#/bin/mkdir -p $h/Maildir;
				/bin/chown -RLP $u.$g $h;
				/bin/chmod 0701 $h;
				#/bin/chmod 0700 $h/Maildir;
				#/bin/mkdir -p $h/mail;
				#/bin/chown $u.mail $h/mail;
				#/bin/chmod 0770 $h/mail;
				#/bin/touch $h/mail/mbox;
				#/bin/chown $u.mail $h/mail/mbox;
				#/bin/chmod 0660 $h/mail/mbox;
			fi;
		fi
		shift || break
	done
}
#    eval set -- $(ldapsearch -LLL uid=$1 uid gidNumber homeDirectory mailMessageStore | ldif2csv uid gidNumber homeDirectory mailMessageStore);
#    u=$1;
#    g=$2;
#    h=$3;
#    m=$4;
#    if [ $u -a $g -a $h ]; then
#        if [[ $h =~ ^(/data/users|/home) ]]; then
#            /bin/echo $u : $g : $h : $m;
#            /bin/mkdir -p $h;
#            /bin/chown -RLP $u.$g $h;
#            /bin/chmod 0701 $h;
#            /bin/mkdir -p $h/mail;
#            /bin/chown $u.mail $h/mail;
#            /bin/chmod 0770 $h/mail;
#            /bin/touch $h/mail/mbox;
#            /bin/chown $u.mail $h/mail/mbox;
#            /bin/chmod 0660 $h/mail/mbox;
#            /bin/mkdir -p $h/Maildir/{cur,new,tmp};
#            /bin/chmod 0700 $h/Maildir $h/Maildir/{cur,new,tmp};
#            /bin/chown -R $u.$g $h/Maildir;
#        fi;
#    fi
alias cups-lpq='cups-lpq | sort +0 +1 | swrite 16,5,16,64,24 0'
alias nocomments='sed -r "/^[[:space:]]*$/d;/^[[:space:]]*#/d;s/[[:space:]]+#.*//" '
alias sp2tb="perl -pi -e 's/ +/\t/g'"
alias unix2dos='perl -pi -e "s/\n/\r\n/"'
alias dos2unix='perl -pi -e "s/\r\n/\n/"'
alias striplf='paste -s -d " "'
alias epochs=sec2date
sec2date() { date -d "1970-01-01 $1 seconds GMT"; }
alias epochd=days2date
days2date() { date -d "1970-01-01 $1 days"; }
doy() { [ "$1" ] && d="-d $1"; date $d +%j; }
now() { date +%s; }
alias df='df -h'
alias h2d='printf "%d" 0x${1}'
alias d2h='printf "%x" ${1}'
d2a() { perl -e "print chr '$1'"; }
a2d() { perl -e "print ord '$1'"; }
a2h() { IFS=''; for i in $@; do perl -e "foreach ( split //, '$i' ) { print sprintf('%x ', ord qq{\$_}) }"; done; unset IFS; }
h2a() { for i in $@; do if [ "$i" != "00" ]; then perl -e "print chr \$ARGV[0]" $(printf "%d" 0x${i}); fi; done; }
db64() { perl -MMIME::Base64 -e 'print decode_base64($ARGV[0]||<STDIN>), "\n"' "$1"; }
eb64() { perl -MMIME::Base64 -e 'print encode_base64($ARGV[0]||<STDIN>), "\n"' "$1"; }
diskuuid() { echo See blkid; return; for i in $(find /dev/disk/by-uuid/ -type l); do j=$(basename $(readlink $i)); if [ "$1" == "$j" ]; then basename $i; fi; done; }
maketiny() {
	if [ -d /etc/tinydns/root ]; then
		cd /etc/tinydns/root;
	elif [ -d /service/tinydns/root ]; then
		cd /service/tinydns/root;
	else
		echo TinyDNS not found.;
		return;
	fi
	if [ "$1" ]; then
		touch data;
	else
		$EDITOR data;
	fi
	make;
	cd - 2>&1 >/dev/null;
}
findonday() {
	path=$1
	day=$2
	next=$(date -d "$day + 1 day")
	find "$path" -type f -newermt "$day" ! -newermt "$next"
}
findnotonday() {
	path=$1
	day=$2
	next=$(date -d "$day + 1 day")
	{ find "$path" -type f -newermt "$day" ! -newermt "$next" ; find "$path" -type f; } | sort | uniq -u
}
highlight() {
        IFS=$'\n'
        while read i; do
                echo -e $(env GREP="$1" perl -pi -e 's/\n/\\n/g;s/($ENV{GREP})/\\033[31m$1\\033[0m/g')
        done
        unset IFS
}
makepatch() {
	[ -z "$2" ] && { echo Usage: $FUNCNAME original new; return; }
	echo Usage: $FUNCNAME original new
	diff -urN $1 $2 > $2.patch
	echo Patch saved as $2.patch
}
fixcron() {
	chmod 0644 /etc/crontab
	chmod 0754 /etc/cron.d
	chmod 0644 /etc/cron.d/*
	chmod 0750 /etc/cron.*ly
	chmod 0500 /etc/cron.*ly/*
	[ -x /etc/init.d/cron ] && /etc/init.d/cron restart
	[ -x /etc/init.d/crond ] && /etc/init.d/crond restart
}
apt-get() {
	echo "$(date) $FUNCNAME $@" >> $HOME/packages.log
	/usr/bin/apt-get "$@"
}
aptitude() {
	echo "$(date) $FUNCNAME $@" >> $HOME/packages.log
	/usr/bin/aptitude "$@"
}
dpkg() {
	echo "$(date) $FUNCNAME $@" >> $HOME/packages.log
	/usr/bin/dpkg "$@"
}
dpkg-deb() {
	echo "$(date) $FUNCNAME $@" >> $HOME/packages.log
	/usr/bin/dpkg-deb "$@"
}
dpkg-divert() {
	echo "$(date) $FUNCNAME $@" >> $HOME/packages.log
	/usr/bin/dpkg-divert "$@"
}
dpkg-preconfigure() {
	echo "$(date) $FUNCNAME $@" >> $HOME/packages.log
	/usr/bin/dpkg-preconfigure "$@"
}
dpkg-query() {
	echo "$(date) $FUNCNAME $@" >> $HOME/packages.log
	/usr/bin/dpkg-query "$@"
}
dpkg-reconfigure() {
	echo "$(date) $FUNCNAME $@" >> $HOME/packages.log
	/usr/bin/dpkg-reconfigure "$@"
}
dpkg-split() {
	echo "$(date) $FUNCNAME $@" >> $HOME/packages.log
	/usr/bin/dpkg-split "$@"
}
dpkg-statoverride() {
	echo "$(date) $FUNCNAME $@" >> $HOME/packages.log
	/usr/bin/dpkg-statoverride "$@"
}
dpkg-trigger() {
	echo "$(date) $FUNCNAME $@" >> $HOME/packages.log
	/usr/bin/dpkg-trigger "$@"
}
