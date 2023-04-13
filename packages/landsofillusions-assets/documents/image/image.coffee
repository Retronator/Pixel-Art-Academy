AM = Artificial.Mummification
LOI = LandsOfIllusions

# An arbitrary image.
class LOI.Assets.Image extends AM.Document
  @id: -> 'LandsOfIllusions.Assets.Image'
  # profileId: profile that added this image to the CDN or not present if this is a system image
  # lastEditTime: time when image was last edited
  # url: link to the image in the CDN
  @Meta
    name: @id()
    
  @enablePersistence()
  @enableDatabaseContent()
  
  @databaseContentInformationFields =
    url: 1
    
  @forUrl = @subscription 'forUrl'

if Meteor.isServer
  # Export all system images.
  AM.DatabaseContent.addToExport ->
    LOI.Assets.Image.documents.fetch profileId: $exists: false
