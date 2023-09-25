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
      
      operator +( byref v as Vec4, byref w as Vec4 ) as Vec4
        '' addition operator (all rocket science stuff...)
        return( Vec4( v.x + w.x, v.y + w.y, v.x + w.z ) )
      end operator
    
    Goes to show you what happens when you are a fucking idiot and write code in a hurry.
    STAY TUNED FOR THE NEXT EXCITING TUTORIAL: how to write unbelievable shitty 3D code!!!
'/  
type Vec4
  declare constructor( nx as single = 0.0, ny as single = 0.0, nz as single = 0.0, nw as single = 1.0 )
  declare constructor( rhs as Vec4 )
  declare operator let( rhs as Vec4 )
  
  declare operator cast() as string
  
  declare function length() as single
  declare sub setLength( l as single )
  declare function squaredLength() as single
  declare sub normalize()
  declare function normal() as Vec4
  declare sub homogeneize()
  declare function homogeneous() as Vec4
  declare function cross( v as Vec4 ) as Vec4
  declare function dot( v as Vec4 ) as single
  declare function distance( v as Vec4 ) as single
  
  as single x
  as single y
  as single z
  as single w
end type

constructor Vec4( nx as single = 0.0, ny as single = 0.0, nz as single = 0.0, nw as single = 1.0 )
  '' Default constructor creates an homogeneous vector
  x = nx
  y = ny
  z = nz
  w = nw
end constructor

constructor Vec4( rhs as Vec4 )
  '' Copy constructor
  x = rhs.x
  y = rhs.y
  z = rhs.z
  w = rhs.w
end constructor

operator Vec4.let( rhs as Vec4 )
  '' Assignment constructor
  x = rhs.x
  y = rhs.y
  z = rhs.z
  w = rhs.w
end operator

operator Vec4.cast() as string
  '' Human readable string representation (useful for debugging)
  return( _
    "| " & trim( str( x ) ) & " |" & chr( 13 ) & chr( 10 ) & _
    "| " & trim( str( y ) ) & " |" & chr( 13 ) & chr( 10 ) & _
    "| " & trim( str( z ) ) & " |" & chr( 13 ) & chr( 10 ) & _
    "| " & trim( str( w ) ) & " |" & chr( 13 ) & chr( 10 ) )
end operator

function Vec4.squaredLength() as single
  /'
    Returns the squared length of this vector.
    
    Useful when you just want to compare which one is bigger, as
    this avoids having to compute a square root
  '/
  return( x * x + y * y + z * z )
end function

function Vec4.length() as single
  '' Returns the length of this vector
  return( sqr( x * x + y * y + z * z ) )
end function

sub Vec4.setLength( l as single )
  '' Sets the length of the vector
  dim as single ol = 1 / length()
  
  x = ( x * ol ) * l
  y = ( y * ol ) * l
  z = ( z * ol ) * l
end sub

sub Vec4.normalize()
  '' Normalizes the vector.
  '' Note that the homogeneous coordinate (w) is not touched.
  dim as single l = 1 / length()
  
  if( l > 0 ) then
    x *= l : y *= l : z *= l
  end if
end sub

function normalize( v as Vec4 ) as Vec4
  return( v.normal() )
end function

function Vec4.normal() as Vec4
  '' Returns this vector normalized but without altering itself.
  '' Again the homogeneous coordinate is left alone.
  dim as single l = 1 / length()
  dim as Vec4 v = Vec4( this )
  
  if( l > 0 ) then
    v.x *= l : v.y *= l : v.z *= l
  end if
  
  return( v )
end function

sub Vec4.homogeneize()
  dim as single iw = 1 / w
  
  x *= iw : y *= iw : z *= iw : w *= iw
end sub

function Vec4.homogeneous() as Vec4
  dim as single iw = 1 / w
  return( Vec4( x * iw, y * iw, z * iw, w * iw ) )
end function

function Vec4.cross( v as Vec4 ) as Vec4
  /'
    Returns the cross product (aka vectorial product) of this vector and
    another vector v.
    Note that there's no cross product defined for a 4 tuple, so
    we simply use a standard 3d cross product, and make the w component 1.
  '/
  return( Vec4( _
    v.y * z - v.z * y, _
    v.z * x - v.x * z, _
    v.x * y - v.y * x, _
    1.0 ) )
end function

function cross( v as Vec4, w as Vec4 ) as Vec4
  '' Returns the cross product between vectors v and w
  return( v.cross( w ) )
end function

function Vec4.dot( v as Vec4 ) as single
  '' Returns the dot product (aka scalar product) of this vector and vector v
  return( v.x * x + v.y * y + v.z * z )
end function

function dot( v as Vec4, w as Vec4 ) as single
  '' Returns the dot product between two vectors
  return( v.dot( w ) )
end function

function Vec4.distance( v as Vec4 ) as single
'' Gets the distance of this vector with vector v
  return( sqr( ( v.x - x ) ^ 2 + ( v.y - y ) ^ 2 + ( v.z - z ) ^ 2 ) )
end function

function distance( v as Vec4, w as Vec4 ) as single
  return( sqr( ( v.x - w.x ) ^ 2 + ( v.y - w.y ) ^ 2 + ( v.z - w.z ) ^ 2 ) )
end function

operator -( v as Vec4, w as Vec4 ) as Vec4
  '' Substraction operator
  return( Vec4( v.x - w.x, v.y - w.y, v.z - w.z ) )
end operator

operator -( v as Vec4 ) as Vec4
  '' Negation operator
  return( Vec4( -v.x, -v.y, -v.z ) )
end operator

operator +( v as Vec4, w as Vec4 ) as Vec4
  return( Vec4( v.x + w.x, v.y + w.y, v.z + w.z ) )
end operator

operator *( v as Vec4, a as single ) as Vec4
  /'
    Multiplication with a scalar.
      Note that this is not a 'scalar product', but a multiplication with a number.
      Vectors do not define multiplications per se, they define the dot product
      and the cross product. To avoid confusion (and also correctness), the
      multiplication operator is overloaded to a scaling of the vector
  '/
  return( Vec4( v.x * a, v.y * a, v.z * a ) )
end operator

operator *( v as Vec4, a as double ) as Vec4
  return( Vec4( v.x * a, v.y * a, v.z * a ) )
end operator

operator *( a as single, v as Vec4 ) as Vec4
  '' Same as above but with the parameters inversed
  return( Vec4( v.x * a, v.y * a, v.z * a ) )
end operator

operator *( a as double, v as Vec4 ) as Vec4
  '' same as above but with the parameters inversed
  return( Vec4( v.x * a, v.y * a, v.z * a ) )
end operator

operator /( v as Vec4, a as single ) as Vec4
  '' Division by a scalar. See note above on multiplying a vector
  return( Vec4( v.x / a, v.y / a, v.z / a ) )
end operator
  
function vectorAngle( v as Vec4, w as Vec4 ) as single
  /'
    Returns the angle between two vectors using the dot product, in radians.
    Note that the result of the dot product used here should, mathematically speaking,
    always give a result between -1 and 1. Due to imprecisions of numerical calculations
    it might sometimes be a little bit outside this range however (especially if you
    define Scalar to be float instead of single). If that happens, the acos function will
    give an invalid result. So instead a protection was added that sets the value back to 
    1 or -1 (because, if the value became 1.0000023 for example, it was probably supposed
    to be 1 anyway).      
    
    dotProduct( v, w ) = length( v ) * length( w ) * cos( angle )
    angle = aCos( dotProduct / ( length( v ) * length( w ) ) )
        
    thus:
    
    angle = aCos( dot( normal( v ) * normal( w ) ) )
  '/
  dim as single angleCos = dot( v.normal(), w.normal() )
  
  '' For acos, the value has to be between -1.0 and 1.0, but due to numerical
  '' imprecisions it sometimes comes outside this range.
  
  angleCos = clamp( -1.0, 1.0, angleCos )

  return( -acos( angleCos ) )
end function

function rotateAroundAxis( v as Vec4, axis as Vec4, angle as single ) as Vec4
  /'
    Rotate vector v around arbitrary axis for angle radians
    It can only rotate around an axis through our object, to rotate around another axis:
    first translate the object to the axis, then use this function, then translate back
    in the new direction.
  '/
  if( ( v.x = 0 ) and ( v.y = 0 ) and ( v.z = 0 ) ) then
    return Vec4( 0.0, 0.0, 0.0 )
  end if
  
  dim nAxis as Vec4 = Vec4( axis.x, axis.y, axis.z ) 'normalize( axis )
  nAxis.normalize()
  
  '' Calculate parameters of the rotation matrix
  dim as single c = cos( angle )
  dim as single s = sin( angle )
  dim as single t = 1 - c

  '' Multiply w with rotation matrix
  dim w as Vec4
  
  w.x = ( t * nAxis.x * nAxis.x + c ) * v.x _
      + ( t * nAxis.x * nAxis.y + s * nAxis.z ) * v.y _
      + ( t * nAxis.x * nAxis.z - s * nAxis.y ) * v.z

  w.y = ( t * nAxis.x * nAxis.y - s * nAxis.z ) * v.x _
      + ( t * nAxis.y * nAxis.y + c ) * v.y _
      + ( t * nAxis.y * nAxis.z + s * nAxis.x ) * v.z

  w.z = ( t * nAxis.x * nAxis.z + s * nAxis.y ) * v.x _
      + ( t * nAxis.y * nAxis.z - s * nAxis.x ) * v.y _
      + ( t * nAxis.z * nAxis.z + c ) * v.z
  
  '' The vector has to retain its length, so it's normalized and
  '' multiplied with the original length
  w.normalize()
  w = w * v.length()

  return( w )
end function

#endif
