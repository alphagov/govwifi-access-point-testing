# Use Docker

This approach, using a network bridge and a wifi dongle can be made to work on a Linux host but at the expense of interfering with the host's network config (this may not be a problem). It will not work on MacOS or Windows, where Docker is run under a VM.

```
docker build -t govwifi-access-point-testing .
```

Change the value of the INTERFACE var to the name of your own wireless adapter, visible from running 'lsusb'.

```
docker run --rm -it -e INTERFACE=wlx0026f2ec9314 --net host --privileged --name govwifi-access-point-testing-c govwifi-access-point-testing
```
## Notes

- It was not possible to manipulate the wifi interface by passing the wireless dongle to the container as a device, using:

```
docker run --rm -it -e INTERFACE=wlx0026f2ec9314 --device="/sys/devices/wlx0026f2ec9314":"/sys/devices/pci0000:00/0000:00:14.0/usb1/1-1/1-1:1.0/net/wlx0026f2ec9314" --privileged access-point-testing /bin/bash
```
- There may be a workaround to this.
