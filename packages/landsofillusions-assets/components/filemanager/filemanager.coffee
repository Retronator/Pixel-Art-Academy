AE = Artificial.Everywhere
AM = Artificial.Mirage
AC = Artificial.Control
FM = FataMorgana
LOI = LandsOfIllusions

class LOI.Assets.Components.FileManager extends AM.Component
  @id: -> 'LandsOfIllusions.Assets.Components.FileManager'
  @register @id()
  
  constructor: (@options) ->
    super arguments...

  onCreated: ->
    super arguments...

    rootDirectory = new @constructor.Directory
      fileManager: @
      path: ''

    @directories = new ReactiveField [rootDirectory]
