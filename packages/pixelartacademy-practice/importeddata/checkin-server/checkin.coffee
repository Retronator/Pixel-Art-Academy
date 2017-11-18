PAA = PixelArtAcademy
AM = Artificial.Mummification

class PAA.Practice.ImportedData.CheckIn extends AM.Document
  @id: -> 'PixelArtAcademy.Practice.ImportedData.CheckIn'
  # timestamp: the time when form was submitted
  # backerEmail: the email of the backer
  # text: the text submitted on practice day
  # image: the image submitted on practice day
  # feedback: (optional) private feedback shared with us
  # {extraData}: any extra data included in the form
  @Meta
    name: @id()
