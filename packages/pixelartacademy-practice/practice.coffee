AM = Artificial.Mummification
PAA = PixelArtAcademy

class PAA.Practice
  constructor: ->
    Artificial.Pages.addAdminPage '/admin/practice', @constructor.Pages.Admin
    Artificial.Pages.addAdminPage '/admin/practice/scripts', @constructor.Pages.Admin.Scripts
    Artificial.Pages.addAdminPage '/admin/practice/projects', @constructor.Pages.Admin.Projects
    
if Meteor.isServer
  # Export all public projects.
  AM.DatabaseContent.addToExport ->
    PAA.Practice.Project.documents.fetch profileId: $exists: false
