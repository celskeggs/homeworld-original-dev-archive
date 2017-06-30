# How to deploy a Homeworld cluster

## Building Software

 * Install go, acbuild, and ruby. See trust.txt for signatures.
 * Install fpm from the gems in build-rkt.
 * Build hyauth, etcd, and flannel with the ./build.sh scripts.
 * Make sure you have these installed:
    git build-essential zlib1g-dev libxml2 libxml2-dev libreadline-dev
    libssl-dev zlibc automake squashfs-tools libacl1-dev libsystemd-dev
    libcap-dev libglib2.0-dev libpcre3-dev libpcrecpp0 libpixman-1-dev
    pkg-config realpath flex bison
 * For rkt, run ./build.sh.
    You may need to tweak the removal of stage1/usr_from_kvm/kernel/patches/0002-for-debian-gcc.patch if you get '-no-pie' problems.
 * For kubernetes, run ./build.sh
    You may need to allocate additional memory to your build environment.

## Set up the authentication server

(IF YOU ARE REINITIALIZING AN AUTHSERVER, MAKE SURE TO COPY OFF THE KEYTAB AND SSH CA!)

 * Request a keytab from accounts@, if necessary.
 * Provision yourself a Debian Stretch machine. Choose SSH Server and Standard System Utilities.
   * Remove irrelevant things like exim4 if necessary.
 * Install krb5-user
 * Stick keytab into /etc/krb5.keytab
 * k5srvutil change
 * Consider backing up new keytab
 * Create user kauth with a homedir
 * Set up the ACL for the authserver in kauth's .k5login.
 * Generate yourself a SSH user CA, if necessary. '/home/kauth/ca_key'.
 * Back up the user CA somewhere, probably?
 * Copy the user CA pubkey off of the server.
 * Setup SSH access via kerberos, or, if you don't have the keytab yet, SSH keys.
 * Turn off PasswordAuthentication.
 * Set up a .k5login in the homedir of any user with shell access, even if empty.
 * Upload hyauth to /usr/local/bin/hyauth
 * Set hyauth as kauth's shell

 * Run req-cert and see if it works.

## Initial server setup

 * Provision yourself new Debian Stretch machines. Choose SSH Server and Standard System Utilities.
