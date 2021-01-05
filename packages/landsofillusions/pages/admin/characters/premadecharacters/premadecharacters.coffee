AM = Artificial.Mirage
AB = Artificial.Babel
ABs = Artificial.Base
LOI = LandsOfIllusions

class LOI.Pages.Admin.Characters.PreMadeCharacters extends AM.Component
  @id: -> 'LandsOfIllusions.Pages.Admin.Characters.PreMadeCharacters'
  @register @id()

  @insert: new ABs.Method name: "#{@id()}.insert"
  @setCharacter: new ABs.Method name: "#{@id()}.setCharacter"
  
  onCreated: ->
    super arguments...
    
    LOI.Character.PreMadeCharacter.all.subscribe @
    LOI.Character.forCurrentUser.subscribe @

  preMadeCharacters: ->
    LOI.Character.PreMadeCharacter.documents.find()

  events: ->
    super(arguments...).concat
      'click .new-pre-made-character': => @constructor.insert()

  class @PreMadeCharacter extends AM.Component
    @register 'LandsOfIllusions.Pages.Admin.Characters.PreMadeCharacters.PreMadeCharacter'

    onCreated: ->
      super arguments...

      @bioTranslatable = new AB.Components.Translatable
        type: AB.Components.Translatable.Types.TextArea
        editable: true

    renderBioTranslatable: ->
      @bioTranslatable.renderComponent @currentComponent()

    class @CharacterSelection extends AM.DataInputComponent
      @register 'LandsOfIllusions.Pages.Admin.Characters.PreMadeCharacters.PreMadeCharacter.CharacterSelection'

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
