AM = Artificial.Mirage
LOI = LandsOfIllusions

class LOI.Adventure extends AM.Component
  @register 'LandsOfIllusions.Adventure'

  constructor: ->
    super

  onCreated: ->
    super

    @currentLocation = new ReactiveField null

    @interface = new LOI.Adventure.Interface.Text @
    @parser = new LOI.Adventure.Parser @

  onRendered: ->
    super

    # Handle url changes.
    @autorun =>
      # Let's see what our url path is like.
      parameters = [
        FlowRouter.getParam 'parameter1'
        FlowRouter.getParam 'parameter2'
        FlowRouter.getParam 'parameter3'
        FlowRouter.getParam 'parameter4'
      ]

      # Remove unused parameters.
      parameters = _.without parameters, undefined

      # Create a path from parameters.
      path = parameters.join '.'

      # We only want to react to router changes.
      Tracker.nonreactive =>
        # Find if this is an item or location.
        locationClass = LOI.Adventure.Location.getClassForPath path

        # TODO: Item support.
        itemClass = null

        if locationClass
          # We are at a location. Destroy the previous location and create the new one.
          @currentLocation()?.destroy()
          location = new locationClass

          # Switch to new location.
          @currentLocation location

        if itemClass
          # We are trying to use this item.
          item = new itemClass
          item.activate()

  onDestroyed: ->
    super

    $('html').removeClass('lands-of-illusions-style-adventure')

  ready: ->
    @parser.ready() and @currentLocation()?.ready()

  @goToLocation: (locationId) ->
    locationClass = LOI.Adventure.Location.getClassForID locationId
    FlowRouter.go 'LandsOfIllusions.Adventure', locationClass.urlParameters()

  @activateItem: (itemKeyName) ->
    FlowRouter.go 'LandsOfIllusions.Adventure', parameter1: itemKeyName
