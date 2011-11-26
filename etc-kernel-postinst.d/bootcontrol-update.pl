#!/usr/bin/perl

# When a new kernel is installed, rpm runs /sbin/new-kernel-pkg a few times
# during %post and %posttrans.
#
# The first time, new-kernel-pkg runs grubby to insert the new kernel config
# into /boot/grub2/grub.cfg. (This is slightly naughty, since that config file
# is meant to be generated from /etc/default/grub and /etc/grub.d/* by
# /sbin/grub2-mkconfig.)
#
# Then, new-kernel-pkg runs all scripts in /etc/kernel/postinst.d/. Thus, this
# script takes the new kernel entry out of grub.cfg and uses it to create
# /boot/control/{linux,menu}.cfg (and for good measure also windows.cfg,
# although that should never change).
#
# We also fix up a problem that buggy grubby introduces, namely that it screws
# up the "set default" line.

use File::Copy;

my $GRUB_CFG = '/boot/grub2/grub.cfg';

copy $GRUB_CFG, "$GRUB_CFG.old" or die "$!";
# system ("/sbin/grub2-mkconfig -o $GRUB_CFG");

open (my $incfg, $GRUB_CFG) or die "$!";

my (@cfg, @linux, @windows);

my ($done_linux, $done_windows);
for (<$incfg>)
{
    # grubby is massively buggy and screws up the "set default" line; restore it
    s/^set default\s*=.*/set default="BOOTCONTROL REDIRECT"/;
    push @cfg, $_;

    # Linux needs this
    if (/^function load_video/ .. /^}$/) {
        push @linux, $_;
    }

    # Take the first Linux entry
    my $linux = /^menuentry.*gnu-linux/ .. /^}$/;
    if ($linux && !$done_linux) {
        push @linux, $_;
        $linux =~ /E0$/ and $done_linux = 1;
    }

    # Take the Windows entry
    my $windows = /^menuentry.*Windows/ .. /^}$/;
    if ($windows && !$done_windows) {
        push @windows, $_;
        $windows =~ /E0$/ and $done_windows = 1;
    }
}

close $incfg;

open (my $outcfg, ">$GRUB_CFG") or die "$!";
print $outcfg @cfg;
close $outcfg;

sub writefile ($$@) {
    my ($fn, $timeout, @lines) = @_;
    open (my $fh, ">/boot/control/$fn.cfg") or die "$!";
    print $fh "set timeout=$timeout\n";
    print $fh @lines;
    close $fh;
}

sub cpcfg ($$) {
    my ($a, $b) = @_;
    copy "/boot/control/$a", "/boot/control/$b";
}

for (qw(menu linux windows grub)) {
    cpcfg "$_.cfg", "$_.cfg.old";
}

writefile "menu", 5, @linux, @windows;
writefile "linux", 0, @linux;
writefile "windows", 0, @windows;

cpcfg "menu.cfg", "grub.cfg" or die "$!";
