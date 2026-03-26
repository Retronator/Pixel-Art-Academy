AM = Artificial.Mirage

if Meteor.isClient
  require 'path-data-polyfill/path-data-polyfill.js'

# Helper functions for dealing with SVG.
class AM.SVGHelper
  @namespace = "http://www.w3.org/2000/svg"
  
  # Split a SVG path into its subpaths.
  @splitPath: (svgPath) ->
    pathSegments = svgPath.getPathData normalize: true
    
    while pathSegments.length
      # Find where the next subpath starts.
      nextSubpathStartIndex = 1
      nextSubpathStartIndex++ while nextSubpathStartIndex < pathSegments.length and pathSegments[nextSubpathStartIndex].type isnt "M"
      
      # Extract the subpath segments and create a new SVG path out of them.
      subpathSegments = pathSegments.splice 0, nextSubpathStartIndex
      svgSubpath = svgPath.ownerDocument.createElementNS @namespace, "path"
      svgSubpath.setPathData subpathSegments
      
      # Copy other attributes from the main path to preserve its style.
      for attribute from svgPath.attributes
        continue if attribute.name in ['d', 'id']
        svgSubpath.setAttribute attribute.name, attribute.value
      
      svgSubpath
