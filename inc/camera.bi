#ifndef __FB3D_CAMERA__
#define __FB3D_CAMERA__

#include once "math.bi" '' math functions and constants
#include once "Vec4.bi" '' Vec4 type and operations
#include once "Mat4.bi" '' Mat4 type and operations

'' This serves to define a projection plane
type Rectangle
	as single x
	as single y
	as single width
	as single height
end type

/'
	Simple Camera class.
	
	10/10/2017: refactored the code because it was a mess. 		
'/

type Camera
  public:
		declare constructor( _
			position as Vec4, x as Vec4, y as Vec4, z as Vec4, _
			near as single = 1.0, _
			far as single = 10000.0, _
			projPlane as Rectangle )
  		
  		'' lots of crappy functions to play with
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
			declare function getCameraMatrix() as Mat4
			declare function getInverseCameraMatrix() as Mat4
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
  		declare function projectionPlane() as rectangle
  		
  private:
		declare sub generateMatrix()
	  
	  '' members
	  as Vec4 m_pos, m_u, m_v, m_dir
		as Mat4 m_position, m_camMatrix, m_invCamMatrix
	
	  as single m_nearClip, m_farClip, m_fov
	  as Rectangle m_projPlane
	  
	  as single m_uLength, m_vLength, m_dLength	  
end type

constructor Camera( _
	position as Vec4, _
	x as Vec4, _
	y as Vec4, _
	z as Vec4, _
	near as single = 1.0, _
	far as single = 10000.0, _
	projPlane as rectangle )
	
	m_pos = position
	m_u = x
	m_v = y
	m_dir = z
	m_nearClip = near
	m_farClip = far
	m_position = matrices.translation( position )
	m_projPlane = projPlane
	
	/'
		adjust the aspect ratio of the Camera to match the
		projection plane resolution
		
		sorry for this crap, I had to reimplement it this way to shorten
		the code
	'/
	with m_projPlane
		if( .width < .height ) then
			setRatioUV( .width / .height )
		else
			setRatioVU( .height / .width )
		end if
	end with
  
	/'
		preserve the lengths of the Camera vectors
		
		every time one messes with the Camera vectors directly, it has to
		remember to preserve their length, if you do not do this, the projection
		gets distorted, as these vectors control different parameters of the
		Camera model
			REMEMBER
				u controls the horizontal FOV
				v controls the vertical FOV
				dir controls the focal zoom
	'/
  m_uLength = m_u.length()
  m_vLength = m_v.length()
  m_dLength = m_dir.length()
  
  '' and generate the initial matrix with the construction parameters
	generateMatrix()
end constructor

sub Camera.generateMatrix()
  '' generates the Camera's rotation matrix
  with m_camMatrix
		.a = m_u.x : .b = m_v.x : .c = m_dir.x : .d = 0.0
		.e = m_u.y : .f = m_v.y : .g = m_dir.y : .h = 0.0
		.i = m_u.z : .j = m_v.z : .k = m_dir.z : .l = 0.0
		.m = m_u.w : .n = m_v.w : .o = m_dir.w : .p = 1.0
  end with
	
	'' and calculates the inverse immediately
	m_invCamMatrix = inverse( m_camMatrix )
end sub

sub Camera.move( offset as Vec4 )
	m_pos = m_pos + offset	
end sub

sub Camera.rotate( axis as Vec4, angle as single )
	'' rotates the Camera
	m_u = rotateAroundAxis( m_u, axis, angle )
	m_v = rotateAroundAxis( m_v, axis, angle )
	m_dir = rotateAroundAxis( m_dir, axis, angle )
		
	generateMatrix()
end sub

function Camera.projectionPlane() as rectangle
	return( m_projPlane )
end function

function Camera.getU() as Vec4
	return( m_u )
end function

function Camera.getV() as Vec4
	return( m_v )
end function

function Camera.getDir() as Vec4
	return( m_dir )
end function

function Camera.getPos() as Vec4
	return( m_pos )
end function

function Camera.getRatioUV() as single
	return( m_u.length() / m_v.length() )
end function

function Camera.getRatioVU() as single
	return( m_v.length() / m_u.length() )
end function

sub Camera.setRatioUV( ratio as single )
	m_v.normalize()
	m_v = m_v * m_u.length() / ratio
	
	generateMatrix()
end sub

sub Camera.setRatioVU( ratio as single )
	m_u.normalize()
	m_u = m_u * m_v.length() / ratio
	
	generateMatrix()
end sub
 
function Camera.getZoomU() as single
	return( m_dir.length() / m_u.length() )
end function

function Camera.getZoomV() as single
	return( m_dir.length() / m_v.length() )
end function

sub Camera.setZoomU( a as single )
	m_u = m_u / ( a / getZoomU() )
	
	generateMatrix()
end sub

sub Camera.setZoomV( a as single )
	m_v = m_v / ( a / getZoomV() )
	
	generateMatrix()
end sub

sub Camera.zoom( a as single )
	zoomU( a )
	zoomV( a )
end sub

sub Camera.zoomU( a as single )
	m_u = m_u / a
	
	generateMatrix()
end sub

sub Camera.zoomV( a as single )
	m_v = m_v / a
	
	generateMatrix()
end sub

function Camera.getFOVV() as single
	return( 2.0 * atan2( m_v.length(), m_dir.length() ) )
end function

function Camera.getFOVU() as single
	return( 2.0 * atan2( m_u.Length(), m_dir.length() ) )
end function

sub Camera.setFOVU( angle as single )
	setzoomU( 1.0 / tan( angle / 2.0 ) )
end sub

sub Camera.setFOVV( angle as single )
	setzoomV( 1.0 / tan( angle / 2.0 ) )
end sub

function Camera.getYaw() as single
	return( atan2( m_dir.x, m_dir.z ) )
end function

function Camera.getPitch() as single
	return( atan2( m_dir.y, sqr( m_dir.x * m_dir.x + m_dir.z * m_dir.z ) ) )
end function

function Camera.getRoll() as single
  return( vectorAngle( cross( Vec4( 0.0, 1.0, 0.0 ), m_dir ), cross( m_v, m_dir ) ) )
end function

sub Camera.setYaw( angle as single )
  '' to change yaw, you have to rotate around the "up" axis of the WORLD = the y axis
  dim currentAngle as single = getyaw()
  
  rotate( Vec4( 0.0, 1.0, 0.0 ), -angle + currentAngle )
end sub

sub Camera.setPitch( angle as single )
	dim currentAngle as single = getPitch()
	
	rotate( m_u, angle - currentAngle )
end sub

sub Camera.setRoll( angle as single )
	dim currentAngle as single = getRoll()
	
	rotate( m_dir, angle - currentAngle )
end sub

sub Camera.yawAbsolute( angle as single )
	rotate( Vec4( 0.0, 1.0, 0.0 ), angle )
end sub

sub Camera.yaw( angle as single )
	rotate( m_v, angle)
end sub

sub Camera.pitch( angle as single )
	rotate( m_u, angle )
end sub

sub Camera.roll( angle as single )
	rotate( m_dir, angle )
end sub

function Camera.getCameraMatrix() as Mat4
	return( m_camMatrix )
end function

function Camera.getInverseCameraMatrix() as Mat4
	return( m_invCamMatrix )
end function

function Camera.transform( v as Vec4 ) as Vec4
	return( m_invCamMatrix * v )
end function

function Camera.orthogonal( pnt as Vec4, plane as Rectangle, byref x as single, byref y as single, byref z as single ) as integer
	dim as single ratio
	
	if( plane.width < plane.height ) then
		ratio = plane.height
	else
		ratio = plane.width
	end if
	
	dim as Mat4 PM
	
	with PM
		.a = ( 2 / ratio ) * 7 : .b = 0.0 : .c = 0.0 : .d = 0.0
		.e = 0.0 : .f = -( 2 / ratio ) * 7 : .g = 0.0 : .h = 0.0
		.i = 0.0 : .j = 0.0 : .k = ( -2.0 / ( m_farClip - m_nearClip ) ) * 7 : .l = ( ( m_farClip + m_nearClip ) / ( m_farClip - m_nearClip ) )
		.m = 0.0 : .n = 0.0 : .o = 0.0 : .p = 1.0
	end with
	
	var b = PM * pnt
	
	dim as single px, py
	
	px = ( b.x * plane.width ) + plane.width / 2
	py = ( b.y * plane.height ) + plane.height / 2
	
	if( px >= 0 and px <= plane.width - 1 and py >= 0 and py <= plane.height - 1 ) then
    x = px
    y = py
    z = b.z
    
    return( -1 )
	else
    x = px
    y = py
    z = b.z
    
    return( 0 )
	end if
end function

function Camera.perspective( pnt as Vec4, plane as Rectangle, byref x as single, byref y as single, byref z as single ) as integer	
	'' the current matrix
	dim as single _
	  fovX = radians( 90 ), fovY = radians( 90 ), _
	  fovTanX = 1 / tan( fovX / 2 ), fovTanY = 1 / tan( fovY / 2 )
	
	'' projection matrix (assumes a right-handed coord system)
  dim as Mat4 PM
  
  with PM
    .a = fovTanX : .b = 0.0 : .c = 0.0 : .d = 0.0
    .e = 0.0 : .f = fovTanY : .g = 0.0 : .h = 0.0
    .i = 0.0 : .j = 0.0 : .k = -( ( farClip + nearClip ) / ( farClip - nearClip ) ) : .l = -( ( 2 * ( farClip * nearClip ) ) / ( farClip - nearClip ) )
    .m = 0.0 : .n = 0.0 : .o = -1.0 : .p = 0.0
  end with
	
	'' project the point
	var b = PM * pnt
	
	dim as single px, py
	
	px = ( b.x * plane.width ) / ( 1.0 * b.w ) + plane.width / 2
	py = ( b.y * plane.height ) / ( 1.0 * b.w ) + plane.height / 2	
	
	if( px >= 0 and px <= plane.width - 1 and py >= 0 and py <= plane.height - 1 and b.z > m_nearClip ) then
    x = px
    y = py
    z = b.z
    
    return( -1 )
	else
    x = px
    y = py
    z = b.z
    
    return( 0 )
	end if
end function

function Camera.projectOnScreen( pnt as Vec4, plane as Rectangle, byref x as single, byref y as single, byref z as single ) as integer
	'' first transformation: translation
	var TM = matrices.translation( -m_pos )
	var a = Vec4( TM * pnt )
	
	/'
		Second transformation: rotation
		
		transform() multiplies the vector with the INVERSE of the Camera matrix
		to bring the point from Camera space to world space
	'/
	var b = Vec4( transform( a ) )
	
	'' Third transformation: projection
	return( perspective( b, plane, x, y, z ) )
end function

function Camera.projectOnScreenOrtho( pnt as Vec4, plane as Rectangle, byref x as single, byref y as single, byref z as single ) as integer
	dim as Mat4 TM
	
	'' first transformation: translation
	with TM
    .a = 1.0 : .b = 0.0 : .c = 0.0 : .d = -m_pos.x
    .e = 0.0 : .f = 1.0 : .g = 0.0 : .h = -m_pos.y
    .i = 0.0 : .j = 0.0 : .k = 1.0 : .l = -m_pos.z
    .m = 0.0 : .n = 0.0 : .o = 0.0 : .p = 1.0
	end with
	
	var a = Vec4( TM * pnt )
	
	'' transform() multiplies the vector with the INVERSE of the Camera matrix
	'' to bring the point from Camera space to world space
	var b = Vec4( transform( a ) )
	
	'' third transformation: projection
	return( orthogonal( b, plane, x, y, z ) )
end function

function Camera.getScale() as single
	return( m_dir.length )
end function

sub Camera.setScale( dirLength as single )
	scale( m_dir.length() / dirLength )
end sub

sub Camera.scale( factor as single )
	m_dir = m_dir * factor
	m_u = m_u * factor
	m_v = m_v * factor
	
	generateMatrix()
end sub

sub Camera.resetSkewU()
	dim as single oldzoomU = getzoomU(), oldzoomV = getzoomV()
	
	m_u = cross( m_dir, m_v )
	m_v = cross( m_dir, -m_u )
	
	setzoomU( oldzoomU )
	setzoomV( oldzoomV )
end sub

sub Camera.resetSkewV()
	dim as single oldzoomU = getzoomU(), oldzoomV = getzoomV()
	
	m_v = cross( m_dir, m_u )
	m_u = cross( m_dir, -m_v )
	
	setzoomU( oldzoomU )
	setzoomV( oldzoomV )
end sub

sub Camera.setLookDirection( newDir as Vec4 )
  dim as Vec4 axis = Vec4( ( cross( m_dir, newDir ) ) )
  
  if axis.length() = 0 then
    exit sub
  end if
  
  dim as single angle = vectorAngle( m_dir, newDir )
  
  if angle <> 0 then
    rotate( axis, angle )
  end if
end sub

sub Camera.lookAt( target as Vec4, up as Vec4 )
	m_dir = ( normalize( target - m_pos ) * m_dLength )
	m_u = ( normalize( cross( up, m_dir ) ) * m_uLength )
	m_v = ( normalize( cross( m_dir, m_u ) ) * m_vLength )
	
	generateMatrix()
end sub

sub Camera.lookAt( target as Vec4 )	
	'' compute the forward vector
	dim as Vec4 forward = Vec4( normalize( target - m_pos ) )
	
	/'
		Compute temporal up vector based on the forward vector
		
		watch out when look up/down at 90 degree
		for example, forward vector is on the Y axis
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
		'' in general, up vector is straight up
		up = Vec4( 0.0, 1.0, 0.0 )
	end if
	
	'' compute the left vector
	dim as Vec4 leftV = Vec4( normalize( cross( up, forward ) ) )
	
	'' re-calculate the orthonormal up vector
	up = normalize( cross( forward, leftV ) )
	
	m_dir = forward * m_dLength
	m_u = leftV * m_uLength
	m_v = up * m_vLength

	generateMatrix()
end sub

sub Camera.setU( newU as Vec4 )
	m_u = newU
	
	generateMatrix()
end sub

sub Camera.setV( newV as Vec4 )
	m_v = newV
	
	generateMatrix()
end sub

sub Camera.setDir( newDir as Vec4 )
	m_dir = newDir
	
	generateMatrix()
end sub

sub Camera.setPos( newPos as Vec4 )
	m_pos = newPos
end sub

function Camera.nearClip() as single
	return( m_nearClip )
end function

function Camera.farClip() as single
	return( m_farClip )
end function

function Camera.getDistance( pnt as Vec4 ) as single
	return( distance( m_pos, pnt ) )
end function

public sub Camera.setDistance( pnt as Vec4, dist as single )
  dim currentDist as single = distance( m_pos, pnt )
  
  move( currentDist * normalize( pnt - m_pos ) )
end sub

#endif
