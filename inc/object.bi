#ifndef __FB3D_OBJECT3D__
#define __FB3D_OBJECT3D__

#include once "math.bi"
#include once "Vec4.bi"
#include once "Mat4.bi"
#include once "arrayList.bi"
#include once "camera.bi"
#include once "drawing.bi"

type Edge
	public:
		declare constructor( v1 as Vec4 ptr, v2 as Vec4 ptr )
		
		declare function vertex1() as Vec4 ptr
		declare function vertex2() as Vec4 ptr
		
	private:
		as Vec4 ptr m_v1
		as Vec4 ptr m_v2
end type

constructor Edge( v1 as Vec4 ptr, v2 as Vec4 ptr )
	m_v1 = v1
	m_v2 = v2
end constructor

function Edge.vertex1() as Vec4 ptr
	return( m_v1 )
end function

function Edge.vertex2() as Vec4 ptr
	return( m_v2 )
end function

type Object3D
	public:
		declare constructor()
		
		declare constructor( _
			position as Vec4 = Vec4( 0.0, 0.0, 0.0 ), _
			xAxis as Vec4, yAxis as Vec4, zAxis as Vec4 )
		
		declare destructor()
		
		declare function transform( v as Vec4 ) as Vec4
		declare function objectSpaceToWorldSpace( pnt as Vec4 ) as Vec4
		declare function getObjectMatrix() as Mat4
		declare function getInverseObjectMatrix() as Mat4
		declare sub move( offset as Vec4 )
		declare sub rotate( axis as Vec4, angle as single )
		declare function getyaw() as single
		declare function getPitch() as single
		declare function getRoll() as single
		declare sub setyaw( angle as single )
		declare sub setPitch( angle as single )
		declare sub setRoll( angle as single )
		declare sub yawAbsolute( angle as single )
		declare sub yaw( angle as single )
		declare sub pitch( angle as single )
		declare sub roll( angle as single )
		declare function getDistance( pnt as Vec4 ) as single
		declare sub setDistance( pnt as Vec4, dist as single )
		declare sub setLookDirection( newDir as Vec4 )
		declare sub lookAt( lookAtMe as Vec4 )
		declare sub lookAt( target as Vec4, up as Vec4 )
		declare sub setU( newU as Vec4 )
		declare sub setV( newV as Vec4 )
		declare sub setDir( newDir as Vec4 )
		declare sub setPos( newPos as Vec4 )
		declare function getU() as Vec4
		declare function getV() as Vec4
		declare function getDir() as Vec4
		declare function getPos() as Vec4
		
		'' these two functions are wrong on so many levels that isn't even funny
		'' made it this way to simplify a little
		declare function vertices() as arrayList ptr
		declare function edges() as arrayList ptr
		
		'' provisional
		declare sub render( cam as camera ptr, context as any ptr = 0 )
		
		'' just a hack to set the object color
		as ulong color
		
	private:
		declare sub generateMatrix()
		
		as Vec4 m_pos
		as Vec4 m_u
		as Vec4 m_v
		as Vec4 m_dir
		
		as Mat4 m_objMatrix
		as Mat4 m_invObjMatrix
		
	  as single m_uLength, m_vLength, m_dLength	  

		as arrayList m_vertices, m_edges		
end type

constructor Object3D()
	'' construct an object with the default axes
	m_pos = Vec4( 0.0, 0.0, 0.0 )
	m_u = Vec4( 1.0, 0.0, 0.0 )
	m_v = Vec4( 0.0, 1.0, 0.0 )
	m_dir = Vec4( 0.0, 0.0, 1.0 )
	
  m_uLength = m_u.length()
  m_vLength = m_v.length()
  m_dLength = m_dir.length()

	generateMatrix()
end constructor

constructor Object3D( _
	position as Vec4 = Vec4( 0.0, 0.0, 0.0 ), _
	xAxis as Vec4, yAxis as Vec4, zAxis as Vec4 )
	
	m_pos = position
	m_u = xAxis
	m_v = yAxis
	m_dir = zAxis
	
  m_uLength = m_u.length()
  m_vLength = m_v.length()
  m_dLength = m_dir.length()

	generateMatrix()
end constructor

destructor Object3D()
	'' If there are vertices on the object, release them
	dim as Vec4 ptr v
	
	if( m_vertices.count > 0 ) then
		for i as integer = 0 to m_vertices.count - 1
			v = m_vertices.get( i )
			delete( v )
		next
	end if
	
	'' Same for the edges
	dim as Edge ptr e
	
	if( m_edges.count > 0 ) then
		for i as integer = 0 to m_edges.count - 1
			e = m_edges.get( i )
			delete( e )
		next
	end if
end destructor

function Object3D.vertices() as arrayList ptr
	return( @m_vertices )
end function

function Object3D.edges() as arrayList ptr
	return( @m_edges )
end function

function Object3D.getObjectMatrix() as Mat4
	return( m_objMatrix )
end function

function Object3D.getInverseObjectMatrix() as Mat4
	return( m_invObjMatrix )
end function

sub Object3D.generateMatrix()
  '' Generates the object rotation matrix
  m_objMatrix = Mat4( _
      m_u.x , m_v.x , m_dir.x , 0.0, _
      m_u.y , m_v.y , m_dir.y , 0.0, _
      m_u.z , m_v.z , m_dir.z , 0.0, _
      m_u.w , m_v.w , m_dir.w , 1.0 )
	
	'' And compute the inverse immediately
	m_invObjMatrix = inverse( m_objMatrix )
end sub

sub Object3D.move( offset as Vec4 )
	m_pos += offset
end sub

sub Object3D.rotate( axis as Vec4, angle as single )
	'' Rotates the object around an arbitrary axis
	m_u = rotateAroundAxis( m_u, axis, angle )
	m_v = rotateAroundAxis( m_v, axis, angle )
	m_dir = rotateAroundAxis( m_dir, axis, angle )
	
	generateMatrix()
end sub

function Object3D.getU() as Vec4
	return( m_u )
end function

function Object3D.getV() as Vec4
	return( m_v )
end function

function Object3D.getDir() as Vec4
	return( m_dir )
end function

function Object3D.getPos() as Vec4
	return( m_pos )
end function

function Object3D.getyaw() as single
	return( atan2( m_dir.x, m_dir.z ) )
end function

function Object3D.getPitch() as single
	return( atan2( m_dir.y, sqr( m_dir.x * m_dir.x + m_dir.z * m_dir.z ) ) )
end function

function Object3D.getRoll() as single
  return( vectorAngle( cross( Vec4( 0.0, 1.0, 0.0 ), m_dir ), cross( m_v, m_dir ) ) )
end function

sub Object3D.setyaw( angle as single )
  '' To change yaw, you have to rotate around the "up" axis of the WORLD = the y axis
  dim as single currentAngle = getyaw()
  
  rotate( Vec4( 0.0, 1.0, 0.0 ), -angle + currentAngle )
end sub

sub Object3D.setPitch( angle as single )
  dim as single currentAngle = getPitch()
  rotate( m_u, angle - currentAngle )
end sub

sub Object3D.setRoll( angle as single )
	dim as single currentAngle = getRoll()
	rotate( m_dir, angle - currentAngle )
end sub

sub Object3D.yawAbsolute( angle as single )
	rotate( Vec4( 0.0, 1.0, 0.0 ), angle )
end sub

sub Object3D.yaw( angle as single )
	rotate( m_v, angle )
end sub

sub Object3D.pitch( angle as single )
	rotate( m_u, angle )
end sub

sub Object3D.roll( angle as single )
	rotate( m_dir, angle )
end sub

function Object3D.getDistance( pnt as Vec4 ) as single
	return( distance( m_pos, pnt ) )
end function

sub Object3D.setDistance( pnt as Vec4, dist as single )
	dim as single currentDist = distance( m_pos, pnt )
	
	move( currentDist * normalize( pnt - m_pos ) )
end sub

sub Object3D.setLookDirection( newDir as Vec4 )
	dim axis as Vec4 = Vec4( ( cross( m_dir, newDir ) ) )
	
	if axis.length() = 0 then
		exit sub
	end if
	
	dim as single angle = vectorAngle( m_dir, newDir )
	
	if( angle <> 0 ) then
		rotate( axis, angle )
	end if
end sub

sub Object3D.lookAt( target as Vec4, up as Vec4 )
	m_dir = ( normalize( target - m_pos ) * m_dLength )
	m_u = ( normalize( cross( up, m_dir ) ) * m_uLength )
	m_v = ( normalize( cross( m_dir, m_u ) ) * m_vLength )
	
	generateMatrix()
end sub
 
sub Object3D.lookAt( target as Vec4 )
	'' Compute the forward vector
	var forward = Vec4( normalize( target - m_pos ) )
	
	/'
		Compute temporal up vector based on the forward vector.
		
		Watch out when look up/down at 90 degree;
		for example, forward vector is on the Y axis
	'/
	dim as Vec4 up
	
	if( abs( forward.x ) < epsilon ) andAlso ( abs( forward.z ) < epsilon ) then
		if( forward.y > 0 ) then
	    '' Forward vector is pointing +Y axis
			up = Vec4( 0.0, 0.0, -1.0 )
		else
			'' Forward vector is pointing -Y axis
			up = Vec4( 0.0, 0.0, 1.0 )
		end if
	else
		'' In general, up vector is straight up
		up = Vec4( 0.0, 1.0, 0.0 )
	end if
	
	'' Compute the left vector
	var leftV = Vec4( normalize( cross( up, forward ) ) )
	
	'' Re-calculate the orthonormal up vector
	up = normalize( cross( forward, leftV ) )
	
	m_dir = forward * m_dLength
	m_u = leftV * m_uLength
	m_v = up * m_vLength

	generateMatrix()
end sub

sub Object3D.setU( newU as Vec4 )
	m_u = newU
	generateMatrix()
end sub

sub Object3D.setV( newV as Vec4 )
	m_v = newV
	generateMatrix()
end sub

sub Object3D.setDir( newDir as Vec4 )
	m_dir = newDir
	generateMatrix()
end sub

sub Object3D.setPos( newPos as Vec4 )
	m_pos = newPos
end sub

function Object3D.transform( v as Vec4 ) as Vec4
	return( m_objMatrix * v )
end function

function Object3D.objectSpaceToWorldSpace( pnt as Vec4 ) as Vec4
  var b = Vec4( transform( pnt ) )
  var a = Vec4( b + m_pos )
  
  return( a )
end function

sub Object3D.render( cam as Camera ptr, context as any ptr = 0 )
	dim as Edge ptr e
	
	'' Render the Edges
	for j as integer = 0 to m_edges.count - 1
		e = m_edges.get( j )
		
		'' Transform the points of the object to world space, as the drawLine3d()
		'' function expects them in world coordinates.				
  	drawLine3d( *cam, objectSpaceToWorldSpace( *e->vertex1 ), _
  	  objectSpaceToWorldSpace( *e->vertex2 ), color, context )			
	next
end sub

#endif
