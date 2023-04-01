#ifndef __FB3DPG_DRAWING__
#define __FB3DPG_DRAWING__

'' Auxiliary functions for performing some drawings on the 3D plane
function clipSegment( cam as Camera, s1 as Vec4, s2 as Vec4 ) as integer
  /'
    Clip both vertices of a line if necessary.
    
    Note that this 'clipping' is only done on the near plane, not on the scene.
    
    The sensible (and correct) way to do this would be to clip them against
    the view frustum; but alas, in order to keep the code short and clear
    the calculation of the frustum was removed from the camera class. Hence
    this crappy function.
    
    Clipping (especially against the near plane) is important, because if you
    don't clip, when one of the line endpoints goes behind the near clipping
    plane, it gets a negative coordinate (due to the projection), and the line
    segment is no longer valid
  '/
  if( s1.z >= cam.nearClip() andAlso s2.z >= cam.nearClip() ) then
    '' Neither one is behind the camera, draw them both
    return( -1 )
  elseIf( s1.z < cam.nearClip() andAlso s2.z >= cam.nearClip() ) then
    '' First coordinate behind the camera, clip it
    s1.x = s1.x + ((cam.nearClip() - s1.z) / (s2.z - s1.z)) * (s2.x - s1.x)
    s1.y = s1.y + ((cam.nearClip() - s1.z) / (s2.z - s1.z)) * (s2.y - s1.y)
    s1.z = cam.nearClip()
    
    return( -1 )
  elseIf( s1.z >= cam.nearClip() andAlso s2.z < cam.nearClip() ) then
    '' Second coordinate behind the camera, clip it
    s2.x = s1.x + ((cam.nearClip() - s1.z) / (s2.z - s1.z)) * (s2.x - s1.x)
    s2.y = s1.y + ((cam.nearClip() - s1.z) / (s2.z - s1.z)) * (s2.y - s1.y)
    s2.z = cam.nearClip()
    
    return( -1 )
  else
    '' Both coordinates behind the camera, don't draw
    return( 0 )
  end if
end function

sub line3D( cam as Camera, p1 As Vec4, p2 As Vec4, c as ulong, buffer as any ptr = 0 )
  '' Project the points
  dim as Vec4 _
    pos1 = cam.transform( p1 - cam.getPos() ), _
    pos2 = cam.transform( p2 - cam.getPos() )
  
  dim as single x1, y1, x2, y2
  
  '' Clip the segment
  dim as integer visible = clipSegment( cam, pos1, pos2 )
  
  '' If its visible, draw it
  if( visible ) then
    dim as single z1, z2
    
    '' Do the perspective projection
    cam.perspective( pos1, cam.projectionPlane, x1, y1, z1 )
    cam.perspective( pos2, cam.projectionPlane, x2, y2, z2 )
    
    '' And then draw a line connecting the two projected points
    line buffer, ( x1, y1 ) - ( x2, y2 ), c
  end if
end sub

sub point3D( cam as Camera, p As Vec4, c as ulong, buffer as any ptr = 0 )
	'' Project the points
  dim as Vec4 pos1 = cam.transform( p - cam.getPos() )

	dim as single x1, y1, z1
	
	'' Do the perspective projection
  cam.perspective( pos1, cam.projectionPlane, x1, y1, z1 )
  
  '' And then draw the points
  circle buffer, ( x1, y1 ), 2, c, , , , f
end sub

#endif