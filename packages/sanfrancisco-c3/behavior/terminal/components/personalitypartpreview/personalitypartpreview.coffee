AM = Artificial.Mirage
LOI = LandsOfIllusions
C3 = SanFrancisco.C3

Factors = LOI.Character.Behavior.Personality.Factors

class C3.Behavior.Terminal.Components.PersonalityPartPreview extends AM.Component
  @register 'SanFrancisco.C3.Behavior.Terminal.Components.PersonalityPartPreview'

  factors: ->
    [
      Factors[1]
      Factors[2]
      Factors[4]
      Factors[3]
      Factors[5]
    ]

  # Provide personality part to the factor axis.
  personalityPart: ->
    @data()
