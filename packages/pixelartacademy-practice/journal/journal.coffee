AM = Artificial.Mummification
PAA = PixelArtAcademy
LOI = LandsOfIllusions

class PAA.Practice.Journal extends AM.Document
  @id: -> 'PixelArtAcademy.Practice.Journal'
  # character: character who owns the journal
  #   _id
  #   avatar
  #     fullName
  #     color
  # title: string of journal's title
  # defaultFont: string with the name of the font used by default (when no specific formatting is applied)
  # design: options that specify the look of the journal
  #   type: main template identifier
  #   size
  #   orientation
  #   bindingPosition
  #   writingSide
  #   paper
  #     type
  #     spacing
  #     color
  #       hue
  #       shade
  #   cover
  #     color
  #       hue
  #       shade
  #     art
  # archived: boolean whether the journal is put away in the archive pile
  # entries: reverse of entry.journal, mostly used to know how many entries there are in the journal
  #   _id
  @Meta
    name: @id()
    fields: =>
      character: Document.ReferenceField LOI.Character, ['avatar.fullName', 'avatar.color'], true

  # Methods

  @insert: @method 'insert'
  @remove: @method 'remove'
  @updateTitle: @method 'updateTitle'
  @updateDefaultFont: @method 'updateDefaultFont'
  @updateDesign: @method 'updateDesign'
  @updateArchived: @method 'updateArchived'
  @updateOrder: @method 'updateOrder'

  # Subscriptions

  @forId: @subscription 'forId'
  @forCharacterId: @subscription 'forCharacterId'
  @forCharacterIds: @subscription 'forCharacterIds'

  # Design enumerations

  @Design:
    Type:
      Traditional: 'Traditional'

    Size:
      Small: 'Small'
      Medium: 'Medium'
      Large: 'Large'

    Orientation:
      Portrait: 'Portrait'
      Landscape: 'Landscape'

    BindingPosition:
      Top: 'Top'
      Left: 'Left'

    WritingSides:
      Single: 'Single'
      Double: 'Double'

    PaperType:
      Blank: 'Blank'
      Quad: 'Quad'
      Rule: 'Rule'
