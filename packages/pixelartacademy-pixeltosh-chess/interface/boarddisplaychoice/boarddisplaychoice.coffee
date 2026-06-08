AM = Artificial.Mirage
FM = FataMorgana
LOI = LandsOfIllusions
PAA = PixelArtAcademy
Chess = PAA.Pixeltosh.Programs.Chess

class Chess.Interface.BoardDisplayChoice extends FM.View
  @id: -> 'PixelArtAcademy.Pixeltosh.Programs.Chess.Interface.BoardDisplayChoice'
  @register @id()

  @createInterfaceData: ->
    contentComponentId: @id()
    programId: PAA.Pixeltosh.Programs.Chess.id()
    left: 0
    top: 0
    right: 0
    bottom: 0

  onCreated: ->
    super arguments...

    @os = @ancestorComponentOfType PAA.Pixeltosh.OS
    @chess = @os.getProgram Chess
    
    @choice = new ReactiveField null
    
    # Auto-close when the choice is made (through this UI or the program menu).
    @autorun (computation) =>
      return unless Chess.state 'boardDisplayType'
      @chess.interfaceManager().closeBoardDisplayChoice()
      
  choiceIsAvailable: ->
    # TODO: Change when 3D chess exists.
    @choice() is Chess.BoardDisplayTypes.TwoDimensional

  options: -> [
    type: Chess.BoardDisplayTypes.TwoDimensional
    label: '2D'
  ,
    type: Chess.BoardDisplayTypes.ThreeDimensional
    label: '3D'
  ]
  
  boardDisplayTypeClass: ->
    option = @currentData()
    _.kebabCase option.type

  activeClass: ->
    option = @currentData()
    'active' if option.type is @choice()
  
  doneButtonDisabledAttribute: ->
    # Change when 3D chess exists.
    'disabled' unless @choiceIsAvailable()

  events: ->
    super(arguments...).concat
      'click .option-button': @onClickOptionButton
      'click .done-button': @onClickDoneButton

  onClickOptionButton: (event) ->
    option = @currentData()
    @choice option.type

  onClickDoneButton: (event) ->
    Chess.state 'boardDisplayType', @choice()
