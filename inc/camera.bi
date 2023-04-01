#ifndef __FB3DPG_CAMERA__
#define __FB3DPG_CAMERA__

#include once "math.bi"
#include once "vec4.bi"
#include once "mat4.bi"

'' This serves to define a projection plane
type Rectangle
  as single x, y, width, height
end type

/'
  Simple camera type.
  
  Represents a pinhole camera. Can be used to navigate a scene, FPS style.
  Very useful for debugging purposes (especially geometry code).
  
  03/31/2023: Further refactoring.
  10/10/2017: Refactored the code because it was a mess.
'/

type Camera
  public:
    declare constructor( _
      position as Vec4, x as Vec4, y as Vec4, z as Vec4, _
      near as single = 1.0, far as single = 10000.0, _
      projPlane as Rectangle )
    
    '' Lots of functions to play with
    declare function getU() as Vec4
    declare function getV() as Vec4
    declare function getDir() as Vec4
    declare function getPos() as Vec4			
    declare sub move( offset as Vec4 )
    declare sub rotate( axis as Vec4, angle as single )
    declare function getRatioUV() as single
    declare function getRatioVU() as single
    declare sub setRatioUV( ratio as single )
    declare sub setRatioVU( ratio as single)
    declare function getZoomU() as single
    declare function getZoomV() as single
    declare sub setZoomU( a as single )
    declare sub setZoomV( a as single )
    declare sub zoom( a as single )
    declare sub zoomU( a as single )
    declare sub zoomV( a as single )
    declare function getFOVV() as single
    declare function getFOVU() as single
    declare sub setFOVU( angle as single )
    declare sub setFOVV( angle as single )
    declare function getYaw() as single
    declare function getPitch() as single
    declare function getRoll() as single
    declare sub setYaw( angle as single )
    declare sub setPitch( angle as single )
    declare sub setRoll( angle as single )
    declare sub yawAbsolute( angle as single )
    declare sub yaw( angle as single )
    declare sub pitch( angle as single )
    declare sub roll( angle as single )
    declare function getCameraMatrix() as mat4
    declare function getInverseCameraMatrix() as mat4
    declare function transform( v as Vec4 ) as Vec4
    declare function orthogonal( pnt as Vec4, plane as Rectangle, byref x as single, byref y as single, byref z as single ) as integer
    declare function perspective( pnt as Vec4, plane as Rectangle, byref x as single, byref y as single, byref z as single ) as integer
    declare function projectOnScreen( pnt as Vec4, plane as Rectangle, byref x as single, byref y as single, byref z as single ) as integer
    declare function projectOnScreenOrtho( pnt as Vec4, plane as Rectangle, byref x as single, byref y as single, byref z as single ) as integer
    declare function getScale() as single
    declare sub setScale( dirLength as single )
    declare sub scale( factor as single )
    declare sub resetSkewU()
    declare sub resetSkewV()
    declare function getDistance( pnt as Vec4 ) as single
    declare sub setDistance( pnt as Vec4, dist as single )
    declare sub setLookDirection( newDir as Vec4 )
    declare sub lookAt( target as Vec4 )
    declare sub lookAt( target as Vec4, up as Vec4 )
    declare sub setU( newU as Vec4 )
    declare sub setV( newV as Vec4 )
    declare sub setDir( newDir as Vec4 )
    declare sub setPos( newPos as Vec4 )
    declare function nearClip() as single
    declare function farClip() as single
    declare function projectionPlane() as Rectangle
  
  private:
    declare sub generateMatrix()
    
    as Vec4 _
      _pos, _u, _v, _dir
    
    as mat4 _position, _camMatrix, _invCamMatrix
    
    as single _
      _nearClip, _farClip, _fov, _uLength, _vLength, _dLength	  
    
    as Rectangle _projPlane
end type

constructor Camera( _
  position as Vec4, x as Vec4, y as Vec4, z as Vec4, near as single = 1.0, far as single = 10000.0, _
  projPlane as Rectangle )
  
  _pos = position : _u = x : _v = y : _dir = z
  _nearClip = near : _farClip = far
  _position = Matrices.translation( position )
  _projPlane = projPlane
  
  /'
    Adjust the aspect ratio of the camera to match the projection plane resolution.
    
    Sorry for this crap, I had to reimplement it this way to shorten
    the code.
  '/
  with _projPlane
    if( .width < .height ) then
      setRatioUV( .width / .height )
    else
      setRatioVU( .height / .width )
    end if
  end with
  
  /'
    Preserve the lengths of the camera vectors.
    
    Every time one messes with the camera vectors directly, it has to
    remember to preserve their length, if you do not do this, the projection
    gets distorted, as these vectors control different parameters of the
    camera model.
    
    REMEMBER
      u controls the horizontal FOV
      v controls the vertical FOV
      dir controls the focal zoom
  '/
  _uLength = _u.length()
  _vLength = _v.length()
  _dLength = _dir.length()
  
  '' And generate the initial matrix with the construction parameters
  generateMatrix()
end constructor

sub Camera.generateMatrix()
  '' Generates the camera's rotation matrix
  with _camMatrix
    .a = _u.x : .b = _v.x : .c = _dir.x : .d = 0.0
    .e = _u.y : .f = _v.y : .g = _dir.y : .h = 0.0
    .i = _u.z : .j = _v.z : .k = _dir.z : .l = 0.0
    .m = _u.w : .n = _v.w : .o = _dir.w : .p = 1.0
  end with
  
  '' And calculates the inverse immediately
  _invCamMatrix = inverse( _camMatrix )
end sub

sub Camera.move( offset as Vec4 )
  _pos = _pos + offset	
end sub

sub Camera.rotate( axis as Vec4, angle as single )
  '' Rotates the camera
  _u = rotateAroundAxis( _u, axis, angle )
  _v = rotateAroundAxis( _v, axis, angle )
  _dir = rotateAroundAxis( _dir, axis, angle )
  
  generateMatrix()
end sub

function Camera.projectionPlane() as Rectangle
  return( _projPlane )
end function

function Camera.getU() as Vec4
  return( _u )
end function

function Camera.getV() as Vec4
  return( _v )
end function

function Camera.getDir() as Vec4
  return( _dir )
end function

function Camera.getPos() as Vec4
  return( _pos )
end function

function Camera.getRatioUV() as single
  return( _u.length() / _v.length() )
end function

function Camera.getRatioVU() as single
  return( _v.length() / _u.length() )
end function

sub Camera.setRatioUV( ratio as single )
  _v.normalize()
  _v = _v * _u.length() / ratio
  
  generateMatrix()
end sub

sub Camera.setRatioVU( ratio as single )
  _u.normalize()
  _u = _u * _v.length() / ratio
  
  generateMatrix()
end sub
 
function Camera.getZoomU() as single
  return( _dir.length() / _u.length() )
end function

function Camera.getZoomV() as single
  return( _dir.length() / _v.length() )
end function

sub Camera.setZoomU( a as single )
  _u = _u / ( a / getZoomU() )
  
  generateMatrix()
end sub

sub Camera.setZoomV( a as single )
  _v = _v / ( a / getZoomV() )
  
  generateMatrix()
end sub

sub Camera.zoom( a as single )
  zoomU( a )
  zoomV( a )
end sub

sub Camera.zoomU( a as single )
  _u = _u / a
  
  generateMatrix()
end sub

sub Camera.zoomV( a as single )
  _v = _v / a
  
  generateMatrix()
end sub

function Camera.getFOVV() as single
  return( 2.0 * atan2( _v.length(), _dir.length() ) )
end function

function Camera.getFOVU() as single
  return( 2.0 * atan2( _u.Length(), _dir.length() ) )
end function

sub Camera.setFOVU( byval angle as single )
  setzoomU( 1.0 / tan( angle / 2.0 ) )
end sub

sub Camera.setFOVV( byval angle as single )
  setzoomV( 1.0 / tan( angle / 2.0 ) )
end sub

function Camera.getYaw() as single
  return( atan2( _dir.x, _dir.z ) )
end function

function Camera.getPitch() as single
  return( atan2( _dir.y, sqr( _dir.x * _dir.x + _dir.z * _dir.z ) ) )
end function

function Camera.getRoll() as single
  return( vectorAngle( cross( Vec4( 0.0, 1.0, 0.0 ), _dir ), cross( _v, _dir ) ) )
end function

sub Camera.setYaw( angle as single )
  '' To change yaw, you have to rotate around the "up" axis of the WORLD = the y axis
  rotate( Vec4( 0.0, 1.0, 0.0 ), -angle + getyaw() )
end sub

sub Camera.setPitch( angle as single )
  rotate( _u, angle - getPitch() )
end sub

sub Camera.setRoll( angle as single )
  rotate( _dir, angle - getRoll() )
end sub

sub Camera.yawAbsolute( angle as single )
  rotate( Vec4( 0.0, 1.0, 0.0 ), angle )
end sub

sub Camera.yaw( angle as single )
  rotate( _v, angle)
end sub

sub Camera.pitch( angle as single )
  rotate( _u, angle )
end sub

sub Camera.roll( angle as single )
  rotate( _dir, angle )
end sub

function Camera.getCameraMatrix() as mat4
  return( _camMatrix )
end function

function Camera.getInverseCameraMatrix() as mat4
  return( _invCamMatrix )
end function

function Camera.transform( v as Vec4 ) as Vec4
  return( _invCamMatrix * v )
end function

function Camera.orthogonal( pnt as Vec4, plane as Rectangle, byref x as single, byref y as single, byref z as single ) as integer
  dim as single ratio = iif( plane.width < plane.height, plane.height, plane.width )
  
  dim as mat4 PM
  
  with PM
    .a = ( 2 / ratio ) * 7 : .b = 0.0 : .c = 0.0 : .d = 0.0
    .e = 0.0 : .f = -( 2 / ratio ) * 7 : .g = 0.0 : .h = 0.0
    .i = 0.0 : .j = 0.0 : .k = ( -2.0 / ( _farClip - _nearClip ) ) * 7 : .l = ( ( _farClip + _nearClip ) / ( _farClip - _nearClip ) )
    .m = 0.0 : .n = 0.0 : .o = 0.0 : .p = 1.0
  end with
  
  dim as Vec4 b = PM * pnt
  
  dim as single _
    px = ( b.x * plane.width ) + plane.width / 2, _
    py = ( b.y * plane.height ) + plane.height / 2
  
  if( px >= 0 andAlso px <= plane.width - 1 andAlso py >= 0 andAlso py <= plane.height - 1 ) then
    x = px : y = py : z = b.z
    
    return( -1 )
  else
    x = px : y = py : z = b.z
  
    return( 0 )
  end if
end function

function Camera.perspective( pnt as Vec4, plane as Rectangle, byref x as single, byref y as single, byref z as single ) as integer	
  '' The current matrix
  dim as single _
    fovX = radians( 90 ), fovY = radians( 90 ), _
    fovTanX = 1 / tan( fovX / 2 ), fovTanY = 1 / tan( fovY / 2 )
  
  '' Projection matrix (assumes a right-handed coord system)
  dim as mat4 PM
  
  with PM
    .a = fovTanX : .b = 0.0 : .c = 0.0 : .d = 0.0
    .e = 0.0 : .f = fovTanY : .g = 0.0 : .h = 0.0
    .i = 0.0 : .j = 0.0 : .k = -( ( farClip + nearClip ) / ( farClip - nearClip ) ) : .l = -( ( 2 * ( farClip * nearClip ) ) / ( farClip - nearClip ) )
    .m = 0.0 : .n = 0.0 : .o = -1.0 : .p = 0.0
  end with
  
  '' Project the point
  dim as Vec4 b = PM * pnt
  
  dim as single _
    px = ( b.x * plane.width ) / ( 1.0 * b.w ) + plane.width / 2, _
    py = ( b.y * plane.height ) / ( 1.0 * b.w ) + plane.height / 2	
  
  if( px >= 0 andAlso px <= plane.width - 1 andAlso py >= 0 andAlso py <= plane.height - 1 andAlso b.z > _nearClip ) then
    x = px : y = py : z = b.z
    
    return( -1 )
  else
    x = px : y = py : z = b.z
    
    return( 0 )
  end if
end function

function Camera.projectOnScreen( pnt as Vec4, plane as Rectangle, byref x as single, byref y as single, byref z as single ) as integer
  '' First transformation: translation
  dim as mat4 TM = matrices.translation( -_pos )
  dim as Vec4 a = Vec4( TM * pnt )
  
  /'
    Second transformation: rotation.
    
    Transform() multiplies the vector with the INVERSE of the camera matrix
    to bring the point from camera space to world space
  '/
  dim as Vec4 b = Vec4( transform( a ) )
  
  '' Third transformation: projection
  return( perspective( b, plane, x, y, z ) )
end function

function Camera.projectOnScreenOrtho( pnt as Vec4, plane as Rectangle, byref x as single, byref y as single, byref z as single ) as integer
  dim as mat4 TM
  
  '' First transformation: translation
  with TM
    .a = 1.0 : .b = 0.0 : .c = 0.0 : .d = -_pos.x
    .e = 0.0 : .f = 1.0 : .g = 0.0 : .h = -_pos.y
    .i = 0.0 : .j = 0.0 : .k = 1.0 : .l = -_pos.z
    .m = 0.0 : .n = 0.0 : .o = 0.0 : .p = 1.0
  end with
  
  dim as Vec4 a = Vec4( TM * pnt )
  
  '' Transform() multiplies the vector with the INVERSE of the camera matrix
  '' to bring the point from camera space to world space.
  dim as Vec4 b = Vec4( transform( a ) )
  
  '' Third transformation: projection
  return( orthogonal( b, plane, x, y, z ) )
end function

function Camera.getScale() as single
  return( _dir.length )
end function

sub Camera.setScale( dirLength as single )
  scale( _dir.length() / dirLength )
end sub

sub Camera.scale( factor as single )
  _dir = _dir * factor
  _u = _u * factor
  _v = _v * factor
  
  generateMatrix()
end sub

sub Camera.resetSkewU()
  dim as single oldzoomU = getzoomU(),  oldzoomV = getzoomV()
  
  _u = cross( _dir,  _v )
  _v = cross( _dir, -_u )
  
  setzoomU( oldzoomU )
  setzoomV( oldzoomV )
end sub

sub Camera.resetSkewV()
  dim as single oldzoomU = getzoomU(), oldzoomV = getzoomV()
  
  _v = cross( _dir,  _u )
  _u = cross( _dir, -_v )
  
  setzoomU( oldzoomU )
  setzoomV( oldzoomV )
end sub

sub Camera.setLookDirection( newDir as Vec4 )
  dim as Vec4 axis = Vec4( ( cross( _dir, newDir ) ) )
  
  if axis.length() = 0 then
    exit sub
  end if
  
  dim as single angle = vectorAngle( _dir, newDir )
  
  if angle <> 0 then
    rotate( axis, angle )
  end if
end sub

sub Camera.lookAt( target as Vec4, up as Vec4 )
  _dir = ( normalize( target - _pos ) * _dLength )
  _u = ( normalize( cross( up, _dir ) ) * _uLength )
  _v = ( normalize( cross( _dir, _u ) ) * _vLength )
  
  generateMatrix()
end sub

sub Camera.lookAt( target as Vec4 )	
  '' Compute the forward vector
  dim as Vec4 forward = Vec4( normalize( target - _pos ) )
  
  /'
    Compute temporal up vector based on the forward vector.
    Watch out when look up/down at 90 degree, for example, forward vector is on the Y axis.
  '/
  dim as Vec4 up
  
  if( abs( forward.x ) < epsilon ) andAlso ( abs( forward.z ) < epsilon ) then
    if( forward.y > 0 ) then
      '' forward vector is pointing +Y axis
      up = Vec4( 0.0, 0.0, -1.0 )
    else
      '' forward vector is pointing -Y axis
      up = Vec4( 0.0, 0.0, 1.0 )
    end if
  else
    '' In general, up vector is straight up
    up = Vec4( 0.0, 1.0, 0.0 )
  end if
  
  '' Compute the left vector
  dim as Vec4 leftV = Vec4( normalize( cross( up, forward ) ) )
  
  '' Re-calculate the orthonormal up vector
  up = normalize( cross( forward, leftV ) )
  
  _dir = forward * _dLength
  _u = leftV * _uLength
  _v = up * _vLength
  
  generateMatrix()
end sub

sub Camera.setU( newU as Vec4 )
  _u = newU
  
  generateMatrix()
end sub

sub Camera.setV( newV as Vec4 )
  _v = newV
  
  generateMatrix()
end sub

sub Camera.setDir( newDir as Vec4 )
  _dir = newDir
  
  generateMatrix()
end sub

sub Camera.setPos( newPos as Vec4 )
  _pos = newPos
end sub

function Camera.nearClip() as single
  return( _nearClip )
end function

function Camera.farClip() as single
  return( _farClip )
end function

function Camera.getDistance( pnt as Vec4 ) as single
  return( distance( _pos, pnt ) )
end function

sub Camera.setDistance( pnt as Vec4, dist as single )
  move( distance( _pos, pnt ) * normalize( pnt - _pos ) )
end sub

#endif