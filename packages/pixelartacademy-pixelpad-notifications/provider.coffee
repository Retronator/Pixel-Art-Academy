AE = Artificial.Everywhere
AB = Artificial.Babel
AM = Artificial.Mirage
PAA = PixelArtAcademy

class PAA.PixelPad.Systems.Notifications.Provider
  @_providerClassesById = {}
  
  @getClasses: ->
    _.values @_providerClassesById
  
  @id: -> throw new AE.NotImplementedException "You must specify provider's id."
  
  @initialize: ->
    # Store provider class by ID.
    @_providerClassesById[@id()] = @
  
  availableNotificationIds: ->
    # Override to provide currently relevant notifications.
    []
