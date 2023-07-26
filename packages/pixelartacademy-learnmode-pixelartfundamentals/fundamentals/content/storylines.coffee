PAA = PixelArtAcademy
LM = PixelArtAcademy.LearnMode

class LM.PixelArtFundamentals.Fundamentals.Content.Storylines extends LM.Content.FutureContent
  @id: -> 'PixelArtAcademy.LearnMode.PixelArtFundamentals.Fundamentals.Content.Storylines'
  @displayName: -> "Storylines"
  @contents: -> [
    @Japan
    @US
    @UK
  ]
  @initialize()

  class @Japan extends LM.Content.FutureContent
    @id: -> 'PixelArtAcademy.LearnMode.PixelArtFundamentals.Fundamentals.Content.Apps.Japan'
    @displayName: -> "1970s Japan"
    @description: -> "Travel to Japan, where you will create sprites for arcade machines."
    @initialize()

  class @US extends LM.Content.FutureContent
    @id: -> 'PixelArtAcademy.LearnMode.PixelArtFundamentals.Fundamentals.Content.Apps.US'
    @displayName: -> "1980s United States"
    @description: -> "Travel to the US, where you will become a graphic designer for the original 1984 Macintosh."
    @initialize()

  class @UK extends LM.Content.FutureContent
    @id: -> 'PixelArtAcademy.LearnMode.PixelArtFundamentals.Fundamentals.Content.Apps.UK'
    @displayName: -> "1980s United Kingdom"
    @description: -> "Travel to the UK, where you will draw game art for the ZX Spectrum."
    @initialize()
