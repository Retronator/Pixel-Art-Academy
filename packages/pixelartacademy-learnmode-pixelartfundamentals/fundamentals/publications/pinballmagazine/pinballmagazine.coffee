PAA = PixelArtAcademy
LM = PixelArtAcademy.LearnMode

class LM.PixelArtFundamentals.Fundamentals.Publications

if Meteor.isClient
  PAA.Publication.Article.CustomClass.registerClass "pinballmagazine-cover-line pinballmagazine-cover-line-#{lineNumber}" for lineNumber in [1..3]
  PAA.Publication.Article.CustomClass.registerClass "pinballmagazine-lead-paragraph"
  PAA.Publication.Article.CustomClass.registerClass "pinballmagazine-lead-image-credit"
