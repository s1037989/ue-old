#!/bin/sh

tar cvzf ubuntu_environment_$(date +"%Y%m%d%H%M%S").tar.gz /etc/profile.d /etc/skel /usr/local /root/{*.sh,packages.log,.bashrc,.profile} /home/local/{.bashrc,.profile} /etc/joe/{joerc,ftyperc} /etc/lynx-cur/lynx.cfg
