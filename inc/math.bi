#ifndef __FB3DPG_MATH__
#define __FB3DPG_MATH__

/'
  Math, geometry and other useful numerical stuff.
  
  03/31/2023: Refactor.
  10/07/2017: Removed all OpenGL-related stuff and the x86 assembler implementations of
    floating-point modulus operator, and moved them to their own files (again).
'/	

#include once "crt.bi"

'' Some convenience macros
#ifndef max
  #define max( a, b ) iif( a > b, a, b )
#endif

#ifndef min
  #define min( a, b ) iif( a < b, a, b )
#endif

#ifndef clamp
  #define clamp( mn, mx, v ) iif( v < mn, mn, iif( v > mx, mx, v ) )
#endif

#ifndef wrap
  #define wrap( wrapValue, v ) ( ( ( v ) + ( wrapValue ) ) mod ( wrapValue ) )
#endif

'' Portable floating-point mod function
#ifndef fmod
  #define fmod( numer, denom ) ( ( numer ) - int( ( numer ) / ( denom ) ) * ( denom ) )
#endif

#ifndef fwrap
  #define fwrap( wrapValue, v ) ( fmod( ( v ) + ( wrapValue ), ( wrapValue ) ) )
#endif

'' Useful constants
const as single _
  pi = 4 * atn( 1 ), _
  twoPi = 2 * pi, _
  halfPi = pi / 2, _
  degToRad = pi / 180, _
  radToDeg = 180 / pi, _
  epsilon = 0.00000001

'' Used to express angles in another unit
#define radians( ang ) ( ( ang ) * ( degToRad ) )
#define degrees( ang ) ( ( ang ) * ( radToDeg ) )

'' Functions to return a delimited random value
function rng overload( mn as integer, mx as integer ) as integer
  return int( rnd() * ( mx + 1 - mn ) + mn )
end function

function rng( mn as single, mx as single ) as single
  return rnd() * ( mx - mn ) + mn
end function

function rng( mn as double, mx as double ) as double
  return rnd() * ( mx - mn ) + mn
end function	

function q_rsqrt( number as single ) as single
  dim as long i
  dim as single x2, y
  dim as const single threehalfs = 1.5
  
  x2 = number * 0.5
  y = number
  i = *cast( long ptr, @y )
  i = &h5F375A86 - ( i shr 1 )
  y = *cast( single ptr, @i )
  y = y * ( threehalfs - ( x2 * y * y ) )
  
  return( y )
end function

#endif
