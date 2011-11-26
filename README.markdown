# bootcontrol

A set of tools to make rebooting to Windows from Linux and vice-versa as easy as possible, in a Fedora 16 / GRUB 2 configuration. Specifically, you will be able to select "Reboot to Windows" from your Linux shutdown menu (we show how this is done for the GNOME 3 case), and conversely, "Reboot to Linux" from Windows. This will affect only the next reboot; subsequent reboots will land you at your GRUB menu as usual.

This is entirely based on [an excellent IBM developerWorks article](http://www.ibm.com/developerworks/linux/library/l-osswitch/).

## The idea

Fedora 16 comes with boot loader GRUB version 1.99 (also known as GRUB 2, as opposed to GRUB 1.97 which is known as GRUB Legacy and came with Fedora up to release 15). The Fedora installer will detect your Windows installation and add an appropriate entry to the GRUB menu, which is configured in `/boot/grub2/grub.cfg`.

One of the commands that GRUB offers is [configfile](http://www.gnu.org/software/grub/manual/grub.html#configfile), which causes GRUB to read a new config file with a new menu definition. We will use this command to immediately redirect from the primary GRUB config file `/boot/grub2/grub.cfg` to one residing on our shared partition, `/boot/control/grub.cfg`. That way, both Linux and Windows are able to modify this latter `grub.cfg` before a reboot, giving us the freedom to decide what the next reboot should do.

For detailed instructions, see INSTALL.
