AB = Artificial.Base
LOI = LandsOfIllusions
HQ = Retronator.HQ

class HQ.Adventure extends LOI.Adventure
  @id: -> 'Retronator.HQ.Adventure'
  @register @id()

  @title: -> "Retronator HQ // The home of pixel art"

  @description: -> "Visit Retronator HQ café, store, gallery, and more."

  titleSuffix: -> ''

  template: -> 'LandsOfIllusions.Adventure'

  # We don't allow the user to play the whole game from retronator.com since the URL scheme doesn't allow it.
  usesDatabaseState: -> false

  # Instead we use just the local state.
  usesLocalState: -> true

  startingPoint: ->
    # We start in Retronator HQ Cafe (where one can also read the daily).
    locationId: HQ.Cafe.id()
    timelineId: LOI.TimelineIds.RealLife

  constructor: ->
    super

    # Enable directly linking to some items.
    directItems = [
      item: HQ.Items.Daily
      location: HQ.Cafe
    ,
      item: HQ.Store.Display
      location: HQ.Store
    ]

    for directItem in directItems
      do (directItem) =>
        LOI.Adventure.registerDirectRoute "/#{directItem.item.url()}", =>
          # Show the item if we need to.
          unless LOI.adventure.activeItemId() is directItem.item.id()
            # Move to the location if necessary.
            LOI.adventure.setLocationId directItem.location unless LOI.adventure.currentLocationId() is directItem.location.id()

            Tracker.autorun (computation) =>
              # Wait until the item is available.
              return unless LOI.adventure.getCurrentThing directItem.item
              computation.stop()

              # Show the item.
              LOI.adventure.goToItem directItem.item

    # Enable directly linking to some locations.
    directLocations = [
      HQ.Cafe
      HQ.Store
      HQ.GalleryEast
      HQ.GalleryWest
    ]

    for directLocation in directLocations
      do (directLocation) =>
        LOI.Adventure.registerDirectRoute "/#{directLocation.url()}", =>
          # Move to the location if necessary.
          LOI.adventure.setLocationId directLocation unless LOI.adventure.currentLocationId() is directLocation.id()

  currentUrl: ->
    # HACK: Feed the 'daily' parameter into the URL so that adventure routing will trigger the daily direct route.
    prefix = 'retronator'

    parameters = AB.Router.currentParameters()
    prefix = 'daily' if parameters.parameter2 in [undefined, 'page', 'tagged', 'post']

    "/#{prefix}#{AB.Router.currentRoutePath()}"

  buildDesiredUrlParameters: (url) ->
    parametersObject = {}

    if url.length
      urlParameters = url.split '/'

      # HACK: Start filling parameters from 2 forward if we're not on the daily or retronator paths.
      indexOffset = if urlParameters[0] in ['daily', 'retronator'] then 1 else 2

      for urlParameter, index in urlParameters
        parametersObject["parameter#{index + indexOffset}"] = urlParameter unless urlParameter is '*'

    parametersObject
