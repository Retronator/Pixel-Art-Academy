AB = Artificial.Base
AM = Artificial.Mirage
LOI = LandsOfIllusions

class LOI.Pages.Admin.GroupPhoto extends AM.Component
  @id: -> 'LandsOfIllusions.Pages.Admin.GroupPhoto'
  @register @id()

  @characters: new AB.Subscription name: "#{@id()}.characters"

  onCreated: ->
    super arguments...

    @constructor.characters.subscribe @

    types = LOI.Character.Part.allPartTypeIds()
    LOI.Character.Part.Template.forTypes.subscribe @, types

    # Create pixel scaling display.
    @display = new AM.Display
      safeAreaWidth: 500
      safeAreaHeight: 300
      minScale: 2

    @avatars = {}

  characters: ->
    LOI.Character.documents.fetch()

  avatar: ->
    character = @currentData()
    @avatars[character._id] ?= new LOI.Character.Avatar character
    @avatars[character._id]

  avatarStyle: ->
    marginRight: "#{_.random 5}rem"
