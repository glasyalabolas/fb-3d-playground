#ifndef __math__
	#define __math__
	
	#include once "crt.bi"
	/'
		math, geometry and other useful numerical stuff
		
		10/7/2017: removed all OpenGL-related stuff and the x86 assembler implementations of
			floating-point modulus operator, and moved them to their own files (again).
	'/	
	
	'namespace math
		'' some convenience macros
		#ifndef max
			#define max( a, b )						iif( a > b, a, b )
		#endif
		
		#ifndef min
			#define min( a, b )						iif( a < b, a, b )
		#endif
		
		#ifndef clamp
			#define clamp( mn, mx, v )		iif( v < mn, mn, iif( v > mx, mx, v ) )
		#endif
		
		#ifndef wrap
			#define wrap( wrapValue, v )	( ( v ) + wrapValue ) mod wrapValue
		#endif
		
		#ifndef fwrap
			#define fwrap( wrapValue, v )	( fmod( ( v ) + wrapValue, wrapValue )
		#endif
		
		'' portable floating-point mod function
		#ifndef fmod
			#define fmod( numer, denom )	numer - int( numer / denom ) * denom
		#endif
		
		'' useful constants
		const as single pi = 4 * atn( 1 )
		const as single twoPi = 2 * pi
		const as single halfPi = pi / 2
		
		const as single degToRad = pi / 180
		const as single radToDeg = 180 / pi
		const as single epsilon = 0.00000001
		
		'' used to express angles in another unit
		#define radians( ang )	ang * degToRad
		#define degrees( ang )	ang * radToDeg
		
		'' functions to return a delimited random value (uses FB implementation which
		'' is a Mersenne Twister, can't remember the classification
		declare function rndRange overload( byval as integer, byval as integer ) as integer
		declare function rndRange( byval as single, byval as single ) as single
		declare function rndRange( byval as double, byval as double ) as double
		
		public function rndRange( byval mn as integer, byval mx as integer ) as integer
		  return int( rnd() * ( mx + 1 - mn ) + mn )
		end function
		
		public function rndRange( byval mn as single, byval mx as single ) as single
		  return rnd() * ( mx - mn ) + mn
		end function
	
		public function rndRange( byval mn as double, byval mx as double ) as double
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
	'end namespace
#endif
