AM = Artificial.Mirage
LOI = LandsOfIllusions

class LOI.Adventure extends AM.Component
  @register 'LandsOfIllusions.Adventure'

  constructor: ->
    super

  onCreated: ->
    super

    $('html').addClass('lands-of-illusions-style-adventure')

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
        locationClass = _.nestedProperty LOI.Adventure.Location.Locations, path
        itemClass = null # _.nestedProperty LOI.Adventure.Item.Locations, path

        if locationClass
          # We are at a location.
          location = new locationClass
          @currentLocation location

        if itemClass
          # We are trying to use this item.
          item = new itemClass
          item.activate()

  onDestroyed: ->
    super

    $('html').removeClass('lands-of-illusions-style-adventure')

  @goToLocation: (locationKeyName) ->
    FlowRouter.go 'LandsOfIllusions.Adventure', parameter1: locationKeyName

  @activateItem: (itemKeyName) ->
    FlowRouter.go 'LandsOfIllusions.Adventure', parameter1: itemKeyName
