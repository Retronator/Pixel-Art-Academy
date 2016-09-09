AB = Artificial.Base

class AB.Services
  constructor: ->
    @services = []

  addService: (type, provider) ->
    # Make sure we don't have the service already registered.
    service = _.find @services, (service) -> service.type is type

    assert not service, "The service of this type was already added."

    @services.push
      type: type
      provider: provider

  getService: (type) ->
    # Look if we have a registered provider for this type.
    service = _.find @services, (service) -> service.type is type

    assert service, "The requested service is not available."

    # Return the matched provider, if we found it.
    service?.provider

  removeService: (type) ->
    # Look if we have a registered provider for this type.
    service = _.find @services, (service) -> service.type is type

    assert service, "The requested service was never added."

    @services.splice _.indexOf(@services, service), 1
