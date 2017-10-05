![Build Status](https://travis-ci.org/spanghf37/homebridge-knx.svg?branch=master)

# emoncms
emoncms docker container for raspberry-pi 64bits

# 1. Configuration files

Copy and edit ```config.json``` and ```knx_config.json``` to ```/home/docker/homebridge``` on the Raspberry Pi.

# 2. docker run command

```
docker run -p 5353:5353 --net=host -p 51826:51826 -v /home/docker/homebridge/:/root/.homebridge/ spanghf37/homebridge-knx:latest
```

Run with:

```
docker run -t -i --rm=true --net="host" \
      -v "/etc/mysql":"/tmp/mysql" \
	  -v "/var/lib/mysql":"/tmp/mysql" \
	  -v "/var/lib/phpfiwa":"/tmp/phpfiwa" \
	  -v "/var/lib/phpfina":"/tmp/phpfina" \
	  -v "/var/lib/phptimeseries":"/tmp/phptimeseries" \
	  -v "/var/www/html":"/tmp/html" \
	  -v "/etc/localtime":"/etc/localtime":ro \
      snoopy86/emoncms
```
Change tmp to your preferred location on the host.
