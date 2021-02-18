# pistorm

![logo](https://pbs.twimg.com/media/EoFm2H-WEAIxuTE?format=jpg)


# Join us on IRC Freenode #PiStorm 

* Hardware files are in Hardware.zip, using the hardware design or parts of it in a commercial product (aka selling with profit) needs a explicit approval from me!
* Even selling blank PCBs at eBay or so without my approval might makes me pretty mad and probably leads to the forthcomming related projects to be closed source. You have been warned :)

# wip-crap tutorial/quickstart

In order to successfully use the features on the wip-crap branch, you need to take a few additional steps:

* Follow the steps in the "Simple quickstart" below up to `sudo apt-install git`, then do this:
* `git clone https://github.com/beeanyew/pistorm/tree/wip-crap`
* `cd pistorm`
* `git checkout wip-crap`
* `make`
* Follow the instructions for `FPGA bitstream update` below the quickstart. This is very important, as the latest commit on the branch uses the updated proto3 firmware.


# Simple quickstart

* Download Raspberry OS from https://www.raspberrypi.org/software/operating-systems/ , the Lite version is sufficent
* Write the Image to a SD Card (8GB sized is plenty, for larger HDD Images pick a bigger one)
* Install the pistorm adapter inplace of the orignal CPU into the Amiga500. Make sure the pistorm sits flush and correct in the Amiga.
  The correct orientation on the pistorm is the USB port facing towards you and the HDMI port is facing to the right

  If the pistorm should not stay in place properly (jumping out of the CPU socket) then bend the pins of the pistorm very very very slightly
  outwards. Double check that all is properly in place and no pins are bend.

* Connect a HDMI Display and a USB Keyboard to the pistorm. Using a USB Hub is possible, connect the Amiga to the PSU and PAL Monitor
* Insert the SD into the Raspberry, Power on the Amiga now. You should see a Rainbow colored screen on the HDMI Monitor and the pistrom booting


* As soon as the boot process is finished (on the first run it reboots automatically after resizing the filesystems to your SD) you should be greeted
  with the login prompt
* Log in as user : pi , password : raspberry (The keyboard is set to US Layout on first boot!)
* run : `sudo raspi-config`
* Setup your preferences like keyboard layout,language etc.
* Setup your Wifi credentials
* Enable SSH at boot time
* Exit raspi-config 
  
  You can now reach the pistorm over SSH , look into you router webpage to find the IP of the pistorm or run : ifconfig 

* run : `sudo apt-get install git`

* run : `git clone https://github.com/captain-amygdala/pistorm.git`

* run : `cd pistorm`

* run : `make`


to start the pistorm emulator 

run : `sudo ./emulator`

to exit emulation
`ctrl+c` or pressing `q` on the keyboard connected to the Raspberry Pi.

The IDE emulation can take both hard drive images generated using `makedisk` in the `ide` directory (these have a 1KB header) or headerless RDSK/RDB images created for instance in WinUAE or as empty files. The IDE emulation currently has a quirk that may require you to reduce/increase the size of the image file by 2MB in order for it to work.

Since PiSCSI can now autoboot RDSK hard drive images, using the IDE controller emulation is not recommended unless you already have a suitable .img file set up for it.

# FPGA bitstream update :

install openocd 
`sudo apt-get install openocd`

make nprog.sh executable
`chmod +x nprog.sh`

run the FPGA update with
`sudo ./nprog.sh`




