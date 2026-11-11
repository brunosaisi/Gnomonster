This repo is a quick guick guide/resource to building the veyecam2m driver on the Pi 5 running Astroarch and creating a video pipeline from the Veye driver to the INDI driver for astronomical autoguiding. There is probably a better way of doing it, but for now im just happy it works :) if u have any sugestions feel free to make a pull request.

This README is a simplified version of the official Veye repository (https://github.com/veyeimaging/raspberrypi_v4l2) mixed with some information avaliable on the Veye wiki and some other resources.

I still haven't made a GUI for the camera configuration module, you can control the camera via the script veye_mipi_i2c.sh in the  "i2c_cmd" folder. I recomend you also build the read/write from source using the script inside "i2c_cmd/source", or use the one in the original Veye repo, they are the same.
Camera setup script commands are avliable on this page: https://wiki.veye.cc/index.php/VEYE-MIPI-290/327_i2c/

After instalation
The start_camera.sh script must be run to start the video pipeline. It calls the Veye scripts for driver configuration and starts a gstreamer+ffmpeg video pipeline, so the INDI V4L2 driver recognizes the sensor data stream.

# Building the Drivers Locally
The following operations are performed on the Raspberry Pi.
The following is an example for the driver veyecam2m on an Astroarch 6.18.20-1-rpi.
## Prepare environment
```
sudo pacman -S bc bison flex openssl make git ncurses
```
## Download the kernel headers for the local piOS
```
sudo pacman -S linux-rpi-headers
```
## Download drivers code from veye
```
git clone https://github.com/veyeimaging/raspberrypi_v4l2.git
```

## Confirm the version of piOS on your own Raspberry Pi
```
$ uname -a
Linux astroarch 6.18.20-1-rpi #1 SMP PREEMPT Wed Mar 25 15:09:28 UTC 2026 aarch64 GNU/Linux
```
## Patch our code to kernel
```
git clone https://github.com/veyeimaging/raspberrypi_v4l2.git
```
- Driver source code
camera driver path is ? linux/drivers/media/i2c?copy our camera module drivers to this path.
-Modify the the Makefile and Kconfig files
Modify the Config and Makefile in the same path?add the corresponding camera driver.
- dts file
dts file path is ?linux/arch/arm/boot/dts/overlays?copy our [camera]-overlay.dts files to this path.
- Modify dts Makefile
Modify the Makefile in the same path?add the corresponding dts compilation option.

## Building
Run the prepare.sh and build.sh from https://github.com/brunosaisi/pibuildkernel

The files into the adjacent folders already have their Makefile and Kconfig correctly modified for this example, and also the dtbo is what i got from the compilathion in my system. U can try to use it, but i recommend u build your own.

DO NOT install the built kernel. You will build the kernel solely to generate the correct dtbo file.
When it says to place the compiled driver and dtbo files into the /release/driver_bin/$(uname -r) folder:
 - Get the dtbo from inside the built kernel's overlay directory (/linux/arch/arm/boot/dts/overlays).
 - Get the compiled driver (using the make command) from /raspberrypi_v4l2/driver_source/cam_drv_src/rpi-6.18.y.

 Only the dtbo will come from the compiled kernel. Compile the driver after compiling the DTS, making sure the dtbo file is already in the /release/driver_bin/$(uname -r) folder.

## Compile drivers
```
cd ~/raspberrypi_v4l2/driver_source/cam_drv_src/rpi-6.18.y
make
```
Done.

## Compile dts
```
cd ~/raspberrypi_v4l2/driver_source/dts/rpi-6.18.y
./build_dtbo.sh
```
Done.

## Driver Installation
We have saved the code for v4l2 driver mode in this github repository.
Download the driver
```
wget https://github.com/veyeimaging/raspberrypi_v4l2/releases/latest/download/raspberrypi_v4l2.tgz
```
Install the driver
```
tar -xzvf raspberrypi_v4l2.tgz
cd raspberrypi_v4l2/release/
chmod +x *
sudo ./install_driver_rpi5.sh veyecam2m
```
It will install both CAM1 and CAM0 overlays in /boot/firm/config.txt.

For older Raspberry Pi
sudo ./install_driver.sh veyecam2m

# Uninstall the driver
If you need to change to using the camera by veye_raspicam software, or if you want to change to a driver of another camera module model, you must first uninstall the current driver.
```
sudo ./uninstall_driver.sh veyecam2m
```

List the video device
```
ls /dev/video0
```
The device node exsit.


# References

https://wiki.veye.cc/index.php/V4L2_mode_for_Raspberry_Pi#TCP_streaming
https://github.com/veyeimaging/raspberrypi_v4l2
https://www.raspberrypi.org/documentation/linux/kernel/building.md
https://wiki.veye.cc/index.php/V4L2_mode_for_Raspberry_Pi#TCP_streaming
https://wiki.veye.cc/index.php/VEYE-MIPI-290/327_i2c/