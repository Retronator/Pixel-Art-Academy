AE = Artificial.Everywhere
AP = Artificial.Pyramid
PAA = PixelArtAcademy
PAG = PAA.Practice.PixelArtEvaluation

PAG.Line.Part.StraightLine::getSegmentCorners = ->
  @_analyzeSegments()
  
  startPoint = _.first @points
  endPoint = _.last @points
  
  deltaX = endPoint.x - startPoint.x
  deltaY = endPoint.y - startPoint.y
  
  mainDirectionX = Math.sign deltaX
  mainDirectionY = Math.sign endPoint.y - startPoint.y
  
  if mainDirectionX is 0
    leftDirectionX = if mainDirectionY > 1 then 1 else -1
    
    return {
      left: [
        x: startPoint.x + leftDirectionX * startPoint.radius, y: startPoint.y - mainDirectionY * startPoint.radius
      ,
        x: endPoint.x + leftDirectionX * endPoint.radius, y: endPoint.y + mainDirectionY * endPoint.radius
      ]
      right: [
        x: startPoint.x - leftDirectionX * startPoint.radius, y: startPoint.y - mainDirectionY * startPoint.radius
      ,
        x: endPoint.x - leftDirectionX * endPoint.radius, y: endPoint.y + mainDirectionY * endPoint.radius
      ]
    }
  
  if mainDirectionY is 0
    leftDirectionY = if mainDirectionX > 1 then -1 else 1
    
    return {
      left: [
        x: startPoint.x - mainDirectionX * startPoint.radius, y: startPoint.y + leftDirectionY * startPoint.radius
      ,
        x: endPoint.x + mainDirectionX * startPoint.radius, y: endPoint.y + leftDirectionY * startPoint.radius
      ]
      right: [
        x: startPoint.x - mainDirectionX * startPoint.radius, y: startPoint.y - leftDirectionY * startPoint.radius
      ,
        x: endPoint.x + mainDirectionX * endPoint.radius, y: endPoint.y - leftDirectionY * endPoint.radius
      ]
    }
    
  if mainDirectionX is mainDirectionY
    leftDirectionX = mainDirectionX
    leftDirectionY = -mainDirectionY
    
  else
    leftDirectionX = -mainDirectionX
    leftDirectionY = mainDirectionY
    
  verticalSegments = Math.abs(deltaY) > Math.abs(deltaX)
  
  left = []
  right = []
  
  startPointIndex = 0
  
  for pointSegmentLength in @pointSegmentLengths
    endPointIndex = startPointIndex + pointSegmentLength - 1
    
    segmentStartPoint = @points[startPointIndex]
    segmentEndPoint = @points[endPointIndex]
    
    # TODO: Remove this when point segments on thick lines are correctly calculated.
    continue unless segmentStartPoint and segmentEndPoint
    
    leftPoint = if (mainDirectionX is mainDirectionY) is verticalSegments then segmentStartPoint else segmentEndPoint
    rightPoint = if (mainDirectionX is mainDirectionY) is verticalSegments then segmentEndPoint else segmentStartPoint
    
    left.push x: leftPoint.x + leftDirectionX * leftPoint.radius, y: leftPoint.y + leftDirectionY * leftPoint.radius
    right.push x: rightPoint.x - leftDirectionX * rightPoint.radius, y: rightPoint.y - leftDirectionY * rightPoint.radius
    
    startPointIndex += pointSegmentLength
  
  {left, right}
