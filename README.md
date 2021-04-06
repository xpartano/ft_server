![Passed 100/100](https://img.shields.io/badge/PASSED-100%2F100-green?style=for-the-badge&logo=42)
# ft_server
The aim of this project is to introduce Docker and the use of Dockerfiles. We will have to deploy a server based on Debian Buster with the following services:
* A nginx instance to serve pages
* MariaDB to have some databases
* PhpMyAdmin to be able to manage these databases on a browser
* A Wordpress instance

Also we will need to serve pages using SSL with autosigned certificates and the ability to toggle nginx's autoindex on and off while the server is up.

## Content
The project consists of a `Dockerfile` with all the instructions to deploy the server and all its services and a `srcs` folder which contains all files needed for the project.

## How to test it?
You can start by cloning this repository:
```bash
https://github.com/xpartano/ft_server.git ft_server && cd ft_server
```
### Building the image using the Dockerfile
Assuming you have docker already installed, you can proceed to build an image.
```bash
docker build -t ft_server .
```
We use `-t` option to tag the image with the name `ft_server`.
After building the image (it can take some time), we can check the image created:
```bash
docker images ft_server
```
### Running the container using the image we just built
After this we can run a container using this image:
```bash
docker run --name ft_server -it -p 80:80 -p 443:443 ft_server
```
If you want to enable or disable **autoindex** you can use the `-e` option as follows:
```bash
docker run --name ft_server -e AUTOINDEX=on -it -p 80:80 -p 443:443 ft_server
```
or
```bash
docker run --name ft_server -e AUTOINDEX=off -it -p 80:80 -p 443:443 ft_server
```
* We use `--name` to give our container a name
* Also `-p` to forward container ports to host ports ([host_port]:[container_port]). 
* The `-it` instructs Docker to allocate a pseudo-TTY connected to the container’s stdin; creating an interactive bash shell in the container.
* The `-e` option allow us to set a value to an environment variable. In this case we will use it to set $AUTOINDEX **on** or **off**.

## Autoindex
Autoindex allow nginx to list files in a repository if it does not find a **index.html** or any other file declared in the index field on your /etc/nginx/sites-available configuration files. For this, I made a script to toggle on/off nginx's autoindex. This tool is on `srcs/scripts/toggle_autoindex.sh` and when built you will find it under `/tmp/scripts/toggle_autoindex.sh`.
### How to use the script?
The script is simple. For using it on a running server just call `./tmp/scripts/toggle_autoindex.sh [on/off/env]`. You can type as a first argument one of the following:
* `on` - Toggles on autoindex and restarts nginx
* `off` - Toggles off autoindex and restarts nginx
* `env` - Checks the value of `$AUTOINDEX`. If it's equal to "on" or "off" it will toggle autoindex on or off. If it's value is none of the above, it will warn you to first export AUTOINDEX with a valid value (on or off). 
