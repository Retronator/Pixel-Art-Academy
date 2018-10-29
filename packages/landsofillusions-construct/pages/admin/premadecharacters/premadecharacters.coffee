AM = Artificial.Mirage
AB = Artificial.Babel
ABs = Artificial.Base
LOI = LandsOfIllusions

class LOI.Construct.Pages.Admin.PreMadeCharacters extends AM.Component
  @id: -> 'LandsOfIllusions.Construct.Pages.Admin.PreMadeCharacters'
  @register @id()

  @insert: new ABs.Method name: "#{@id()}.insert"
  @setCharacter: new ABs.Method name: "#{@id()}.setCharacter"
  
  onCreated: ->
    super arguments...
    
    LOI.Construct.Loading.PreMadeCharacter.all.subscribe @
    LOI.Character.forCurrentUser.subscribe @

  preMadeCharacters: ->
    LOI.Construct.Loading.PreMadeCharacter.documents.find()

  events: ->
    super(arguments...).concat
      'click .new-pre-made-character': => @constructor.insert()

  class @PreMadeCharacter extends AM.Component
    @register 'LandsOfIllusions.Construct.Pages.Admin.PreMadeCharacters.PreMadeCharacter'

    onCreated: ->
      super arguments...

      @bioTranslatable = new AB.Components.Translatable
        type: AB.Components.Translatable.Types.TextArea
        editable: true

    renderBioTranslatable: ->
      @bioTranslatable.renderComponent @currentComponent()

    class @CharacterSelection extends AM.DataInputComponent
      @register 'LandsOfIllusions.Construct.Pages.Admin.PreMadeCharacters.PreMadeCharacter.CharacterSelection'

      constructor: ->
        super arguments...

        @type = AM.DataInputComponent.Types.Select

      options: ->
        return unless characters = Retronator.user()?.characters

        options = [
          name: ''
          value: ''
        ]

        for character in characters
          options.push
            value: character._id
            name: character.displayName

        options

      load: ->
        preMadeCharacter = @data()
        preMadeCharacter.character?._id

      save: (value) ->
        preMadeCharacter = @data()
        LOI.Construct.Pages.Admin.PreMadeCharacters.setCharacter preMadeCharacter._id, value
