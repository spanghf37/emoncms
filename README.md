![Build Status](https://travis-ci.org/spanghf37/emoncms.svg?branch=master)

# emoncms
emoncms docker container for raspberry-pi 64bits

# 1. Configuration files

Copy and edit ```config.json``` and ```knx_config.json``` to ```/home/docker/homebridge``` on the Raspberry Pi.

# 2. docker run command

```
docker run --restart=always -t -i --net=host -v "/etc/mysql":"/tmp/mysql" -v "/var/lib/mysql":"/tmp/mysql" -v "/var/lib/phpfiwa":"/tmp/phpfiwa" -v "/var/lib/phpfina":"/tmp/phpfina" -v "/var/lib/phptimeseries":"/tmp/phptimeseries" -v "/var/www/html":"/tmp/html" -v "/etc/localtime":"/etc/localtime":ro spanghf37/emoncms:latest
```
Change tmp to your preferred location on the host.
