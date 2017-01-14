url = Npm.require('url')

# This is a fork of force-ssl that also handles the subdomain rules for our apps.

# Unfortunately we can't use a connect middleware here since sockjs installs itself prior to all existing listeners
# (meaning prior to any connect middlewares) so we need to take an approach similar to overshadowListeners in
# https://github.com/sockjs/sockjs-node/blob/cf820c55af6a9953e16558555a31decea554f70e/src/utils.coffee
httpServer = WebApp.httpServer
oldHttpServerListeners = httpServer.listeners('request').slice(0)

httpServer.removeAllListeners 'request'
httpServer.addListener 'request', (request, response) ->
  # Allow connections if they have been handled with ssl already (either by us or by a proxy)
  # or the connection is entirely over localhost (development mode).
  #
  # Note: someone could trick us into serving over non-ssl by setting x-forwarded-for or x-forwarded-proto.
  # Not much we can do there if we still want to operate behind proxies.
  remoteAddress = request.connection.remoteAddress or request.socket.remoteAddress

  # Determine if the connection is only over localhost. Both we
  # received it on localhost, and all proxies involved received on localhost.
  localhostRegexp = /^\s*(127\.0\.0\.1|::1)\s*$/

  isLocalhost = localhostRegexp.test(remoteAddress) and (not request.headers['x-forwarded-for'] or request.headers['x-forwarded-for'] is 'undefined' or _.every(request.headers['x-forwarded-for'].split(','), (x) ->
    localhostRegexp.test x
  ))

  # Determine if the connection was over SSL at any point. Either we
  # received it as SSL, or a proxy did and translated it for us.
  isSsl = request.connection.pair or request.headers['x-forwarded-proto'] and request.headers['x-forwarded-proto'].indexOf('https') isnt -1

  requestedHost = request.headers.host

  isInvalidSubdomain = false

  isIp = requestedHost.match /^\s*\d*.\d*.\d*\.\d*/
  domainParts = requestedHost.split '.'

  # Remove the domain part.
  if not isIp and domainParts.length > 2
    subdomainParts = domainParts[0...-2]

    subdomain = subdomainParts.join '.'

    isLocalhost = true if subdomain is 'localhost'

    # Right now we don't have any valid subdomains.
    # TODO: Add support for registering valid subdomains.
    isInvalidSubdomain = true

  # Redirect the URL if:
  #   - we're not on localhost and
  #   - we're not accessing directly through an ip and
  #     - we have a subdomain that is not a valid subdomain or
  #     - we are not using ssl
  if not isLocalhost and not isIp and (isInvalidSubdomain or not isSsl)
    # Connection is not cool. Send a 302 redirect.
    redirectedHost = requestedHost

    # Redirect to main domain if subdomain is not specifically handled.
    redirectedHost = domainParts[-2..-1].join '.' if isInvalidSubdomain

    # Strip off the port number. If we went to a URL with a custom
    # port, we don't know what the custom SSL port is anyway.
    redirectedHost = redirectedHost.replace /:\d+$/, ''

    response.writeHead 302, 'Location': 'https://' + redirectedHost + request.url
    response.end()

    return

  # Connection is OK. Proceed normally.
  oldListener.apply httpServer, arguments for oldListener in oldHttpServerListeners
