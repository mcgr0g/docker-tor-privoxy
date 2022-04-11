![](logo.jpg)

If you need molehole to fanced sites, talpa can help you. This kind of talpa have tor, socks and squid.

# Background

Tor provides a [SOCKS](https://en.wikipedia.org/wiki/SOCKS) proxy. Privoxy provide an HTTP proxy. Squid help with routing.
These ports are exposed by the image:
- `8888` ⁠— Tor HTTP proxy
- `9050` ⁠— Tor SOCKS5 proxy
- `9051` ⁠— Tor control

## Build

A pre-built image is available [here](https://hub.docker.com/r/mcgr0g/talpa-altaica). Pull it using:
```
$ docker pull mcgr0g/talpa-altaica
```

You can also build your own using this repository. Check [docs/build](https://github.com/mcgr0g/talpa-altaica/tree/master/docs/build.adoc)

## Run

```
docker run --rm --name torproxy -p 8888:8888 -p 9050:9050 mcgr0g/talpa-altaica
```

Or use the `Makefile` as follow:

```
make run
```

Or use the `docker-compose up` with such config
```
version: '3.8'
services:

  molehole:
    container_name: torproxy
    image: mcgr0g/talpa-altaica:latest
    environment:
     ExcludeExitNodes: '{RU},{UA},{AM},{KG},{BY}'
    ports:
    - 8888:8888
    - 9050:9050/tcp
    restart: unless-stopped
```

### Environment Variables

The following environment variables will modify the behaviour of the container:

- `IP_CHANGE_SECONDS` - Number of seconds between changes of Tor exit address.
- `EXIT_NODE` - Specify exit node location via [alpha-2 country codes](https://en.wikipedia.org/wiki/ISO_3166-1_alpha-2)
- `LOG_NOTICE_TARGET` - Where should logging go?
- `EXCLUDE_NODE` - What county ignore to use in Exit nodes, spec via [alpha-2 country codes](https://en.wikipedia.org/wiki/ISO_3166-2)

For example:

```bash
docker run -e IP_CHANGE_SECONDS=180 talpa-altaica
```

#### Setting Exit Nodes

It's possible to restrict the exit nodes via the configuration in `torrc`.

```
# Specify exit node by IP address.
ExitNodes 176.10.99.202
# Specify exit node by fingerprint.
ExitNodes 19B6F025B4580795FBD9F3ED3C6574CDAF979A2F
# Specify exit node by country code.
ExitNodes {us} StrictNodes 1
ExitNodes {ua},{ug},{ie} StrictNodes 1
```

You can also exclude specific nodes.

```
ExcludeExitNodes {ua} 
```

Note that `ExcludeExitNodes` takes precedence over `ExitNodes`.

There are three ways to specify exit nodes:

- using [country codes](https://b3rn3d.herokuapp.com/blog/2014/03/05/tor-country-codes)
- IP addresses or
- hashes.

If you want to specify multiple options, use a comma-separated list.

Country codes need to be enclosed in braces, for example, `{us}`.

# Check

To check that you are on Tor:

- configure your browser to use 127.0.0.1:8888 as proxy then
- browse to https://check.torproject.org/

Other checks via cli you can find in [docs/checks](https://github.com/mcgr0g/talpa-altaica/tree/master/docs/checks.adoc)

Below most popular check in shell

## Shell

```bash
# Direct access to internet.
$ curl http://httpbin.org/ip
{
  "origin": "105.224.106.150"
}
# Access internet through Tor (HTTP proxy).
$ curl --proxy 127.0.0.1:8888 http://httpbin.org/ip
{
  "origin": "185.220.102.4"
}
# Access internet through Tor (SOCKS proxy).
$ curl --proxy socks5://127.0.0.1:9050 http://httpbin.org/ip
{
  "origin": "185.100.87.206"
}
```

You get a different IP address when you send the request via the proxy. If you wait a while and then send the request again, you'll find that the IP address has changed.


## Similar Projects

- https://github.com/mattes/rotating-proxy (Provides access to multiple simultaneous Tor proxies)
- https://github.com/wallneradam/docker-tor-proxy
- https://hub.docker.com/r/dperson/torproxy and https://github.com/dperson/torproxy