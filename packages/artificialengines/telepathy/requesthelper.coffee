AT = Artificial.Telepathy

# Helper for sending HTTP requests.
class AT.RequestHelper
  @requestUntilSucceeded: (options) =>
    call = =>
      # Request the resource.
      HTTP.get options.url, (error, result) =>
        if error
          # We were not able to reach the server so retry after a timeout.
          Meteor.setTimeout =>
            call()
          ,
            options.retryAfterSeconds * 1000

        else
          # We got a response, return the result to the caller.
          options.callback result

    # Initiate the first call.
    call()
