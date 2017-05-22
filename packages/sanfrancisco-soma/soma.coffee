LOI = LandsOfIllusions

class SanFrancisco.Soma extends LOI.Adventure.Region
  @id: -> 'SanFrancisco.Soma'
  @debug = false

  @initialize()

  @scenes: -> [
    @Muni.Scene
  ]

  scenes: ->
    # Don't show the muni scene until Chapter 3
    chapter3Active = _.find LOI.adventure.currentChapters(), (chapter) => chapter instanceof PixelArtAcademy.Season1.Episode0.Chapter3

    _.filter @_scenes, (scene) =>
      return false if scene instanceof @constructor.Muni.Scene and not chapter3Active

      true

if Meteor.isServer
  LOI.initializePackage
    id: 'retronator_sanfrancisco-soma'
    assets: Assets
