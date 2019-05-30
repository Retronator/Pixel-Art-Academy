AB = Artificial.Base
AM = Artificial.Mirage
LOI = LandsOfIllusions

class LOI.Pages.Admin.Characters.ApprovedDesigns extends AM.Component
  @id: -> 'LandsOfIllusions.Pages.Admin.Characters.ApprovedDesigns'
  @register @id()

  @characters: new AB.Subscription name: "#{@id()}.characters"
  
  onCreated: ->
    super arguments...

    # Subscribe to characters.
    @limit = new ReactiveField 20
    @skip = new ReactiveField 0

    @autorun (computation) =>
      @constructor.characters.subscribe @limit(), @skip()

    # Subscribe to templates.
    types = LOI.Character.Part.allPartTypeIds()
    LOI.Character.Part.Template.forTypes.subscribe @, types

    # Create pixel scaling display.
    @display = new AM.Display
      safeAreaWidth: 500
      safeAreaHeight: 300
      minScale: 2

    @avatars = {}

    @drawOutfit = new ReactiveField true

  minIndex: ->
    @skip() + 1

  maxIndex: ->
    @skip() + @limit()

  drawOutfitCheckedAttribute: ->
    return unless @drawOutfit()

    checked: true

  characters: ->
    LOI.Character.documents.fetch()

  events: ->
    super(arguments...).concat
      'change .limit-input': @onChangeLimitInput
      'change .draw-outfit-checkbox': @onChangeDrawOutfitCheckbox
      'click .previous-button': @onClickPreviousButton
      'click .next-button': @onClickNextButton

  onChangeLimitInput: (event) ->
    @limit parseInt $(event.target).val()

  onChangeDrawOutfitCheckbox: (event) ->
    @drawOutfit $(event.target).is(':checked')

  onClickPreviousButton: (event) ->
    @skip @skip() - @limit()

  onClickNextButton: (event) ->
    @skip @skip() + @limit()

  class @Avatar extends AM.Component
    @register 'LandsOfIllusions.Pages.Admin.Characters.ApprovedDesigns.Avatar'

    onCreated: ->
      super arguments...

      @parent = @ancestorComponentOfType LOI.Pages.Admin.Characters.ApprovedDesigns

      character = @data()
      @avatar = new LOI.Character.Avatar character

    onDestroyed: ->
      super arguments...

      @avatar.destroy()

    avatarPreviewOptions: ->
      rotatable: true
      drawOutfit: @parent.drawOutfit()
