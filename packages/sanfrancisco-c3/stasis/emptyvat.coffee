LOI = LandsOfIllusions
C3 = SanFrancisco.C3

Vocabulary = LOI.Parser.Vocabulary

class C3.Stasis.EmptyVat extends LOI.Adventure.Item
  @id: -> 'SanFrancisco.C3.Stasis.EmptyVat'
  @fullName: -> "empty vat"
  @nameAutoCorrectStyle: -> LOI.Avatar.NameAutoCorrectStyle.Name
  @description: ->
    "
      It's a chamber full of liquid, big enough to hold a body.
    "

  @initialize()
