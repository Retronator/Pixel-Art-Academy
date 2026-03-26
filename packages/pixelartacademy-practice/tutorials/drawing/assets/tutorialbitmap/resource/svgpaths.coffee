AE = Artificial.Everywhere
PAA = PixelArtAcademy
LOI = LandsOfIllusions

TutorialBitmap = PAA.Practice.Tutorials.Drawing.Assets.TutorialBitmap

class TutorialBitmap.Resource.SvgPaths extends TutorialBitmap.Resource
  constructor: (@url) ->
    super arguments...
    
    @svgPaths = new ReactiveField null

    fetch(Meteor.absoluteUrl @url).then((response) => response.text()).then (svgXml) =>
      parser = new DOMParser();
      svgDocument = parser.parseFromString svgXml, "image/svg+xml"
      @svgPaths svgDocument.getElementsByTagName 'path'
    
  ready: -> @svgPaths()?
