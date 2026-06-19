PAA = PixelArtAcademy
LM = PixelArtAcademy.LearnMode

class LM.PixelArtFundamentals.Fundamentals.Publications.SixtyFourSquares
  @id: -> 'PixelArtAcademy.LearnMode.PixelArtFundamentals.Fundamentals.Publications.SixtyFourSquares'
  
  @IssueIDs =
    ArtOfTheBoard: "#{@id()}.ArtOfTheBoard"

if Meteor.isClient
  PAA.Publication.Article.CustomClass.registerClass "sixtyfoursquares-cover-specialeditiontitle"
  PAA.Publication.Article.CustomClass.registerClass "sixtyfoursquares-cover-specialeditiondescription"
  PAA.Publication.Article.CustomClass.registerClass "sixtyfoursquares-cover-article sixtyfoursquares-cover-article-#{lineNumber}" for lineNumber in [1..3]
  PAA.Publication.Article.CustomClass.registerClass "sixtyfoursquares-cover-line sixtyfoursquares-cover-line-#{lineNumber}" for lineNumber in [1..4]
