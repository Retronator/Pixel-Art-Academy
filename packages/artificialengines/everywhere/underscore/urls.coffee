_.mixin
  urlOrigin: (url) ->
    pathArray = url.split '/'
    protocol = pathArray[0]
    host = pathArray[2]
    protocol + '//' + host
