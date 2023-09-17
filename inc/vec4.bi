#ifndef __FB3D_VEC4__
#define __FB3D_VEC4__	

#include once "math.bi"

/'
	4 tuple vector type.
	
	It is meant to be used as an homogeneous 3D vector (like the ones
	used by OpenGL or Direct3D).
	
	Conceptually, they are to be interpreted like this:
	
	| x |
	| y |
	| z |
	| 1 |
	
	which is known as a column vector.
	
	10/7/2017: fixed a typo in the + operator
		now this was the original code. Take a very close look at it (the comment was removed
		after the fix out of pure anger, as you can imagine):
			
			operator +( byref v as vec4, byref w as vec4 ) as vec4
				'' addition operator (all rocket science stuff...)
				return( vec4( v.x + w.x, v.y + w.y, v.x + w.z ) )
			end operator
		
		Goes to show you what happens when you are a fucking idiot and write code in a hurry.
		STAY TUNED FOR THE NEXT EXCITING TUTORIAL: how to write unbelievable shitty 3D code!!!
'/	
type vec4
	public:
		as single x
		as single y
		as single z
		as single w
	
		declare constructor( byval nx as single = 0.0, byval ny as single = 0.0, byval nz as single = 0.0, byval nw as single = 1.0 )
		declare constructor( byref rhs as vec4 )
		declare operator let( byref rhs as vec4 )
		
		declare operator cast() as string
		
		declare function length() as single
		declare sub setLength( byval l as single )
		declare function squaredLength() as single
		declare sub normalize()
		declare function normal() as vec4
		declare sub homogeneize()
		declare function homogeneous() as vec4
		declare function cross( byref v as vec4 ) as vec4
		declare function dot( byref v as vec4 ) as single
		declare function distance( byref v as vec4 ) as single
end type

constructor vec4( byval nx as single = 0.0, byval ny as single = 0.0, byval nz as single = 0.0, byval nw as single = 1.0 )
	'' default constructor creates an homogeneous vector
	x = nx
	y = ny
	z = nz
	w = nw
end constructor

constructor vec4( byref rhs as vec4 )
	'' copy constructor
	x = rhs.x
	y = rhs.y
	z = rhs.z
	w = rhs.w
end constructor

operator vec4.let( byref rhs as vec4 )
	'' assignment constructor
	x = rhs.x
	y = rhs.y
	z = rhs.z
	w = rhs.w
end operator

operator vec4.cast() as string
	'' human readable string representation (useful for debugging)
	return( _
		"| " & trim( str( x ) ) & " |" & chr( 13 ) & chr( 10 ) & _
		"| " & trim( str( y ) ) & " |" & chr( 13 ) & chr( 10 ) & _
		"| " & trim( str( z ) ) & " |" & chr( 13 ) & chr( 10 ) & _
		"| " & trim( str( w ) ) & " |" & chr( 13 ) & chr( 10 ) )
end operator

function vec4.squaredLength() as single
	/'
		returns the squared length of this vector
		useful when you just want to compare which one is bigger, as
			this avoids having to compute a square root
	'/
	return( x * x + y * y + z * z )
end function

function vec4.length() as single
	'' returns the length of this vector
	return( sqr( x * x + y * y + z * z ) )
end function

sub vec4.setLength( byval l as single )
	dim as single ol = 1 / length()
	
	x = ( x * ol ) * l
	y = ( y * ol ) * l
	z = ( z * ol ) * l
end sub

sub vec4.normalize()
	/'
		normalizes the vector
			note that the homogeneous coordinate (w) is not touched
	'/
	dim as single l = length()
	
	if l > 0 then
		x /= l : y /= l : z /= l
	end if
end sub

function normalize( byref v as vec4 ) as vec4
	'' for compatibility
	return( v.normal() )
end function

function vec4.normal() as vec4
	/'
		returns this vector normalized but without altering itself
		again the homogeneous coordinate is left alone
	'/
	dim as single l = length()
	dim as vec4 v = vec4( this )
	
	if l > 0 then
		v.x /= l : v.y /= l : v.z /= l
	end if
	
	return( v )
end function

sub vec4.homogeneize()
	/'
		homogeneizes the vector
			this is done by dividing the components by the homogeneous coordinate (w)
	'/
	x /= w : y /= w : z /= w : w /= w
end sub

function vec4.homogeneous() as vec4
	/'
		returns this vector homogeneized but without altering it
	'/
	return( vec4( x / w, y / w, z / w, w / w ) )
end function

function vec4.cross( byref v as vec4 ) as vec4
	/'
		returns the cross product (aka vectorial product) of this vector and
		another vector v
			note that there's no cross product defined for a 4 tuple, so
			we simply use a standard 3d cross product, and make the w component 1
	'/
	return( vec4( _
		v.y * z - v.z * y, _
		v.z * x - v.x * z, _
		v.x * y - v.y * x, _
		1.0 ) )
end function

function cross( byref v as vec4, byref w as vec4 ) as vec4
	'' returns the cross product between vectors v and w
	return( v.cross( w ) )
end function

function vec4.dot( byref v as vec4 ) as single
  '' returns the dot product (aka scalar product) of this vector and vector v
	return( v.x * x + v.y * y + v.z * z )
end function

function dot( byref v as vec4, byref w as vec4 ) as single
	'' returns the dot product between two vectors
	return( v.dot( w ) )
end function

function vec4.distance( byref v as vec4 ) as single
  /'
  	gets the distance of this vector with vector v
  		to calculate the distance, substract them and calculate the length of the resultant vector
	'/
	return( sqr( ( v.x - x ) ^ 2 + ( v.y - y ) ^ 2 + ( v.z - z ) ^ 2 ) )
end function

function distance( byref v as vec4, byref w as vec4 ) as single
	return( sqr( ( v.x - w.x ) ^ 2 + ( v.y - w.y ) ^ 2 + ( v.z - w.z ) ^ 2 ) )
end function

operator -( byref v as vec4, byref w as vec4 ) as vec4
  '' substraction operator
  return( vec4( v.x - w.x, v.y - w.y, v.z - w.z ) )
end operator

operator -( byref v as vec4 ) as vec4
	'' negation operator
	return( vec4( -v.x, -v.y, -v.z ) )
end operator

operator +( byref v as vec4, byref w as vec4 ) as vec4
	return( vec4( v.x + w.x, v.y + w.y, v.z + w.z ) )
end operator

operator *( byref v as vec4, byref a as single ) as vec4
	/'
		multiplication with a scalar
			note that this is not a 'scalar product', but a multiplication with a number
			vectors do not define multiplications per se, they define the dot product
			and the cross product. To avoid confusion (and also correctness), the
			multiplication operator is overloaded to a scaling of the vector
	'/
	return( vec4( v.x * a, v.y * a, v.z * a ) )
end operator

operator *( byref v as vec4, byref a as double ) as vec4
	/'
		multiplication with a scalar
			note that this is not a 'scalar product', but a multiplication with a number
			vectors do not define multiplications per se, they define the dot product
			and the cross product. To avoid confusion (and also correctness), the
			multiplication operator is overloaded to a scaling of the vector
	'/
	return( vec4( v.x * a, v.y * a, v.z * a ) )
end operator

operator *( byref a as single, byref v as vec4 ) as vec4
	'' same as above but with the parameters inversed
	return( vec4( v.x * a, v.y * a, v.z * a ) )
end operator

operator *( byref a as double, byref v as vec4 ) as vec4
	'' same as above but with the parameters inversed
	return( vec4( v.x * a, v.y * a, v.z * a ) )
end operator

operator /( byref v as vec4, byref a as single ) as vec4
	'' division by a scalar. See note above on multiplying a vector
	return( vec4( v.x / a, v.y / a, v.z / a ) )
end operator
	
function vectorAngle( byref v as vec4, byref w as vec4 ) as single
	/'
		returns the angle between two vectors using the dot product, in radians
    note that the result of the dot product used here
    should mathematically speaking, always give a result between -1 and 1. Due to imprecisions of
    numerical calculations it might sometimes be a little bit outside this range however (especially
    if you define Scalar to be float instead of single). If that happens, the acos function will give
    an invalid result. So instead a protection was added that sets the value back to 1 or -1
    (because, if the value became 1.0000023 for example, it was probably supposed to be 1 anyway).
      
		dotProduct( v, w ) = length( v ) * length( w ) * cos( angle )
		angle = aCos( dotProduct / ( length( v ) * length( w ) ) )
				
				thus:
				
				angle = aCos( dot( normal( v ) * normal( w ) ) )
	'/
  dim as single angleCos = dot( v.normal(), w.normal() )
  
  '' for acos, the value has to be between -1.0 and 1.0, but due to numerical imprecisions it
  '' sometimes comes outside this range
	
	angleCos = clamp( -1.0, 1.0, angleCos )

  return( -acos( angleCos ) )
end function

function rotateAroundAxis( byref v as vec4, byref axis as vec4, byval angle as single ) as vec4
  /'
  	rotate vector v around arbitrary axis for angle radians
  	it can only rotate around an axis through our object, to rotate around another axis:
  	first translate the object to the axis, then use this function, then translate back
  	in the new direction.
	'/
  if( ( v.x = 0 ) and ( v.y = 0 ) and ( v.z = 0 ) ) then
  	return vec4( 0.0, 0.0, 0.0 )
  end if
			
  dim nAxis as vec4 = vec4( axis.x, axis.y, axis.z ) 'normalize( axis )
	nAxis.normalize()
	
  '' calculate parameters of the rotation matrix
  dim as single c = cos( angle )
  dim as single s = sin( angle )
  dim as single t = 1 - c

  '' multiply w with rotation matrix
  dim w as vec4
  
  w.x = ( t * nAxis.x * nAxis.x + c ) * v.x _
      + ( t * nAxis.x * nAxis.y + s * nAxis.z ) * v.y _
      + ( t * nAxis.x * nAxis.z - s * nAxis.y ) * v.z

  w.y = ( t * nAxis.x * nAxis.y - s * nAxis.z ) * v.x _
      + ( t * nAxis.y * nAxis.y + c ) * v.y _
      + ( t * nAxis.y * nAxis.z + s * nAxis.x ) * v.z

  w.z = ( t * nAxis.x * nAxis.z + s * nAxis.y ) * v.x _
      + ( t * nAxis.y * nAxis.z - s * nAxis.x ) * v.y _
      + ( t * nAxis.z * nAxis.z + c ) * v.z
	
	'' the vector has to retain its length, so it's normalized and
	'' multiplied with the original length
  w.normalize()
  w = w * v.length()

  return( w )
end function

#endif