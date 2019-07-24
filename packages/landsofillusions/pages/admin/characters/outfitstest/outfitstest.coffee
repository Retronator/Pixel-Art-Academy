AB = Artificial.Base
AM = Artificial.Mirage
LOI = LandsOfIllusions

class LOI.Pages.Admin.Characters.OutfitsTest extends AM.Component
  @id: -> 'LandsOfIllusions.Pages.Admin.Characters.OutfitsTest'
  @register @id()

  @version: ->
    '0.1-wip'

  onCreated: ->
    super arguments...

    # Subscribe to templates.
    types = LOI.Character.Part.allPartTypeIds()
    LOI.Character.Part.Template.forTypes.subscribe @, types

    # Create pixel scaling display.
    @display = new AM.Display
      safeAreaWidth: 500
      safeAreaHeight: 300
      minScale: 3

    bodyNames = [
      'ectomorph'
      'mesomorph'
      'endomorph'
      'female-ectomorph2'
      'female-ectomorph3'
      'female-mesomorph1'
      'female-mesomorph2'
      'female-mesomorph3'
      'female-endomorph1'
      'female-endomorph2'
      'female-endomorph4'
      'female-endomorph5'
      'male-ectomorph1'
      'male-mesomorph3'
      'male-endomorph2'
      'male-endomorph3'
      'male-endomorph4'
    ]

    @testOutfitId = new ReactiveField null

    @avatars = []

    for bodyName, index in bodyNames
      @avatars.push
        avatar: new ReactiveField null

      do (bodyName, index) =>
        url = @versionedUrl "/packages/retronator_landsofillusions/pages/admin/characters/outfitstest/bodies/#{bodyName}.json"

        HTTP.call 'GET', url, (error, result) =>
          if error
            console.error error
            return

          document = new LOI.NonPlayerCharacter EJSON.parse result.content
          @avatars[index].avatar new LOI.Character.Avatar document

    # Reactively set outfit on avatars.
    @autorun (computation) =>
      if outfitTemplate = LOI.Character.Part.Template.documents.findOne @testOutfitId()
        outfit = node: outfitTemplate.latestVersion?.data or outfitTemplate.data

      for avatar in @avatars
        avatar.avatar()?.customOutfit outfit

  viewingAngles: ->
    [
      LOI.Engine.RenderingSides.angles.front
      LOI.Engine.RenderingSides.angles.frontLeft
      LOI.Engine.RenderingSides.angles.left
      LOI.Engine.RenderingSides.angles.backLeft
      LOI.Engine.RenderingSides.angles.back
    ]

  avatarPreviewOptions: ->
    viewingAngle = Template.parentData 2

    rotatable: true
    initialViewingAngle: viewingAngle

  class @OutfitSelection extends AM.DataInputComponent
    @register 'LandsOfIllusions.Pages.Admin.Characters.OutfitsTest.OutfitSelection'

    constructor: ->
      super arguments...

      @type = AM.DataInputComponent.Types.Select

    onCreated: ->
      super arguments...

      @outfitsTest = @ancestorComponentOfType LOI.Pages.Admin.Characters.OutfitsTest

    options: ->
      outfits = LOI.Character.Part.Template.documents.fetch
        type: LOI.Character.Part.Types.Avatar.Outfit.options.type

      options = [
        name: ''
        value: ''
      ]

      for outfit in outfits
        options.push
          name: outfit.name.translate().text
          value: outfit._id

      options

    load: ->
      @outfitsTest.testOutfitId()

    save: (value) ->
      @outfitsTest.testOutfitId value
