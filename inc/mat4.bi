#ifndef __FB3DPG_MAT4__
#define __FB3DPG_MAT4__

#include once "vec4.bi"

/'
  4x4 matrix type
    | a b c d |
    | e f g h |
    | i j k l |
    | m n o p |
  
  03/31/2023: Refactor.
  09/30/2017: Improved 4x4 matrix inverse calculation. With -gen gcc -Wc -Ofast
    (the settings I always use) it is more than 60% faster than the previous
    version. A byproduct of correcting the bug mentioned below.
  09/29/2017: Fixed determinant calculation (it was erroneously computed)
    The funny thing was that this library is used in various applications,
    including my 3D engine and various tools. When I was implementing a
    feature, it kept doing weird things, and the bug was finally tracked to
    an erroneous calculation of the determinant. The determinant was
    correctly calculated in the 3x3	matrix code, but when I ported the code
    to use OpenGL for rendering, it	didn't worked as intended. Goes to show
    you that one is to be extra	careful with the math code, as it is the
    foundation of the entire game engine.
  
    The calculations were cross checked with the help of this online resource:
      https://www.mathsisfun.com/algebra/matrix-calculator.html
    
    which has a very neat matrix calculator for various dimensions.
'/	
type Mat4
  declare constructor( _
    sa as single = 1.0, sb as single = 0.0, sc as single = 0.0, sd as single = 0.0, _
    se as single = 0.0, sf as single = 1.0, sg as single = 0.0, sh as single = 0.0, _
    si as single = 0.0, sj as single = 0.0, sk as single = 1.0, sl as single = 0.0, _
    sm as single = 0.0, sn as single = 0.0, so as single = 0.0, sp as single = 1.0 )
  declare constructor( NM as Mat4 )
  
  declare operator let( RHS as Mat4 )
  declare operator cast() as string
  
  declare function determinant() as single
  declare sub transpose()
  declare function transpose( M as Mat4 ) as Mat4
  declare sub inverse()
  declare sub identity()
  
  as single a, b, c, d
  as single e, f, g, h
  as single i, j, k, l
  as single m, n, o, p
end type

constructor Mat4( _
	sa as single = 1.0, sb as single = 0.0, sc as single = 0.0, sd as single = 0.0, _
	se as single = 0.0, sf as single = 1.0, sg as single = 0.0, sh as single = 0.0, _
	si as single = 0.0, sj as single = 0.0, sk as single = 1.0, sl as single = 0.0, _
	sm as single = 0.0, sn as single = 0.0, so as single = 0.0, sp as single = 1.0 )
  
	/'
    Default constructor initializes the matrix to an identity, if no coefficients are specified.
    This is far more useful than initializing it to all zeros
  '/
  a = sa : b = sb : c = sc : d = sd
  e = se : f = sf : g = sg : h = sh
  i = si : j = sj : k = sk : l = sl
  m = sm : n = sn : o = so : p = sp
end constructor

constructor Mat4( RHS as Mat4 )
  a = RHS.a : b = RHS.b : c = RHS.c : d = RHS.d
  e = RHS.e : f = RHS.f : g = RHS.g : h = RHS.h
  i = RHS.i : j = RHS.j : k = RHS.k : l = RHS.l
  m = RHS.m : n = RHS.n : o = RHS.o : p = RHS.p
end constructor

operator Mat4.let( RHS as Mat4 )
  a = RHS.a : b = RHS.b : c = RHS.c : d = RHS.d
  e = RHS.e : f = RHS.f : g = RHS.g : h = RHS.h
  i = RHS.i : j = RHS.j : k = RHS.k : l = RHS.l
  m = RHS.m : n = RHS.n : o = RHS.o : p = RHS.p
end operator

operator Mat4.cast() as string
  '' The matrix in a human readable form (very useful for debugging purposes)
  return( _
    "| " + trim( str( a ) ) + " | " + trim( str( b ) ) + " | " + trim( str( c ) ) + " | " + trim( str( d ) ) + " |" + chr( 13, 10 ) + _
    "| " + trim( str( e ) ) + " | " + trim( str( f ) ) + " | " + trim( str( g ) ) + " | " + trim( str( h ) ) + " |" + chr( 13, 10 ) + _
    "| " + trim( str( i ) ) + " | " + trim( str( j ) ) + " | " + trim( str( k ) ) + " | " + trim( str( l ) ) + " |" + chr( 13, 10 ) + _
    "| " + trim( str( m ) ) + " | " + trim( str( n ) ) + " | " + trim( str( o ) ) + " | " + trim( str( p ) ) + " |" + chr( 13, 10 ) )
end operator

function Mat4.determinant() as single
  /'
    Computes the determinant of the matrix using Laplace cofactor expansion
    
    The determinant of a 3x3 matrix is:
      a * ( e * i - f * h ) - b * ( d * i - f * g ) + c * ( d * h - e * g )
    
    and a 4x4 matrix determinant is given by:
      a *         b *         c *         d *
      | f g h |   | e g h |   | e f h |   | e f g |
      | j k l | - | i k l | + | i j l | - | i j k |
      | n o p |   | m o p |   | m n p |   | m n o |
    
    where the '|' means the determinant of the inner 3x3 matrices. Note that the
    cofactors are already factored in the calculation.
    
    the determinant is thus:
      + ( a * (	f * ( k * p - l * o ) - g * ( j * p - l * n ) + h * ( j * o - k * n ) ) )
      - ( b * ( e * ( k * p - l * o ) - g * ( i * p - l * m ) + h * ( i * o - k * m ) ) )
      +	( c * ( e * ( j * p - l * n ) - f * ( i * p - l * m ) + h * ( i * n - j * m ) ) )
      - ( d * ( e * ( j * o - k * n ) - f * ( i * o - k * m ) + g * ( i * n - j * m ) ) )
  '/
  dim as single det = _
      ( a * (	f * ( k * p - l * o ) - g * ( j * p - l * n ) + h * ( j * o - k * n ) ) ) _
    - ( b * ( e * ( k * p - l * o ) - g * ( i * p - l * m ) + h * ( i * o - k * m ) ) ) _
    +	( c * ( e * ( j * p - l * n ) - f * ( i * p - l * m ) + h * ( i * n - j * m ) ) ) _
    - ( d * ( e * ( j * o - k * n ) - f * ( i * o - k * m ) + g * ( i * n - j * m ) ) )
  
  /'
    This isn't matematically correct, just a programmer's dirty hack.
    If the determinant of a matrix is 0, it means it has no inverse. In the code for
    calculating the inverse, a division by the determinant is performed; and if it is 
    zero, a division by zero is performed on *every* element of the matrix, filling it
    with positive or negative infinity values and rendering it useless. A matrix 
    without inverse is the matrix	itself, so setting the determinant value to 1 
    does the trick.
  '/
  return( iif( det = 0.0, 1.0, det ) )
end function

sub Mat4.transpose()
  /'
    Transposes the matrix.
    
    [ a b c d ]T    [ a e i m ]
    [ e f g h ]  =  [ b f j n ]
    [ i j k l ]     [ c g k o ]
    [ m n o p ]     [ d h l p ]
    
    Why have it, if it is not used by the matrix code itself? Well, there is a
    nice property of matrices, which has to do with rotations. If you can
    be sure that the matrix contains only rotations, transposing it is the
    same as taking its inverse, thus saving you *a lot* of computation
  '/
  this = Mat4( a, e, i, m, b, f, j, n, c, g, k, o, d, h, l, p )
end sub

function transpose( M as Mat4 ) as Mat4
  return( Mat4( _
    M.a, M.e, M.i, M.m, _
    M.b, M.f, M.j, M.n, _
    M.c, M.g, M.k, M.o, _
    M.d, M.h, M.l, M.p ) )
end function

sub Mat4.inverse()
  /'
    Computes the inverse of a 4x4 matrix.
    
    This version is 60%+ faster and 400%+ uglier than the previous version.
    It was made so by computing the determinant inside the method and
    recycling as much	calculation as possible.
  '/
  '' List of 2x2 determinants
  dim as single kplo = k * p - l * o
  dim as single jpln = j * p - l * n
  dim as single jokn = j * o - k * n
  dim as single iplm = i * p - l * m
  dim as single iokm = i * o - k * m
  dim as single injm = i * n - j * m
  dim as single gpho = g * p - h * o
  dim as single fphn = f * p - h * n
  dim as single fogn = f * o - g * n
  dim as single ephm = e * p - h * m
  dim as single eogm = e * o - g * m
  dim as single enfm = e * n - f * m
  dim as single glhk = g * l - h * k
  dim as single flhj = f * l - h * j
  dim as single fkgj = f * k - g * j
  dim as single elhi = e * l - h * i
  dim as single ekgi = e * k - g * i
  dim as single ejfi = e * j - f * i
  
  '' List of 3x3 determinants
  dim as single d1kplo = f * kplo
  dim as single d1jpln = g * jpln
  dim as single d1jokn = h * jokn
  dim as single d2kplo = e * kplo
  dim as single d2iplm = g * iplm
  dim as single d2iokm = h * iokm
  dim as single d3jpln = e * jpln
  dim as single d3iplm = f * iplm
  dim as single d3injm = h * injm
  dim as single d4jokn = e * jokn
  dim as single d4iokm = f * iokm
  dim as single d4injm = g * injm
  dim as single d5kplo = b * kplo
  dim as single d5jpln = c * jpln
  dim as single d5jokn = d * jokn
  dim as single d6kplo = a * kplo
  dim as single d6iplm = c * iplm
  dim as single d6iokm = d * iokm
  dim as single d7jpln = a * jpln
  dim as single d7iplm = b * iplm
  dim as single d7injm = d * injm
  dim as single d8jokn = a * jokn
  dim as single d8iokm = b * iokm
  dim as single d8injm = c * injm
  dim as single d9gpho = b * gpho
  dim as single d9fphn = c * fphn
  dim as single d9fogn = d * fogn
  dim as single d10gpho = a * gpho
  dim as single d10ephm = c * ephm
  dim as single d10eogm = d * eogm
  dim as single d11fphn = a * fphn
  dim as single d11ephm = b * ephm
  dim as single d11enfm = d * enfm
  dim as single d12fogn = a * fogn
  dim as single d12eogm = b * eogm
  dim as single d12enfm = c * enfm
  dim as single d13glhk = b * glhk
  dim as single d13flhj = c * flhj
  dim as single d13fkgj = d * fkgj
  dim as single d14glhk = a * glhk
  dim as single d14elhi = c * elhi
  dim as single d14ekgi = d * ekgi
  dim as single d15flhj = a * flhj
  dim as single d15elhi = b * elhi
  dim as single d15ejfi = d * ejfi
  dim as single d16fkgj = a * fkgj
  dim as single d16ekgi = b * ekgi
  dim as single d16ejfi = c * ejfi
  
  '' 4x4 determinant (inversed)
  dim as single det = _
      ( a * ( d1kplo - d1jpln + d1jokn ) _
    - ( b * ( d2kplo - d2iplm + d2iokm ) ) _
    + ( c * ( d3jpln - d3iplm + d3injm ) ) _
    - ( d * ( d4jokn - d4iokm + d4injm ) ) )
  
  '' if the determinant is 0, the matrix has no inverse
  if det = 0 then exit sub
  
  '' Multiplying with the reciprocal is slightly faster than dividing
  dim as single invDet = 1.0 / det
  
  '' Minors
  dim as single Ma = d1kplo - d1jpln + d1jokn
  dim as single Mb = d2kplo - d2iplm + d2iokm
  dim as single Mc = d3jpln - d3iplm + d3injm
  dim as single Md = d4jokn - d4iokm + d4injm
  dim as single Me = d5kplo - d5jpln + d5jokn
  dim as single Mf = d6kplo - d6iplm + d6iokm
  dim as single Mg = d7jpln - d7iplm + d7injm
  dim as single Mh = d8jokn - d8iokm + d8injm
  dim as single Mi = d9gpho - d9fphn + d9fogn
  dim as single Mj = d10gpho - d10ephm + d10eogm
  dim as single Mk = d11fphn - d11ephm + d11enfm
  dim as single Ml = d12fogn - d12eogm + d12enfm
  dim as single Mm = d13glhk - d13flhj + d13fkgj
  dim as single Mn = d14glhk - d14elhi + d14ekgi
  dim as single Mo = d15flhj - d15elhi + d15ejfi
  dim as single Mp = d16fkgj - d16ekgi + d16ejfi
  
  /'
    Adjugate (the adjugate is the transpose of the cofactored matrix of minors)			
    
    Ma -Me  Mi -Mm
   -Mb  Mf -Mj  Mn
    Mc -Mg  Mk -Mo
   -Md  Mh -Ml  Mp
  '/
  this = Mat4( _
     Ma * invDet, -Me * invDet,  Mi * invDet, -Mm * invDet, _
    -Mb * invDet,  Mf * invDet, -Mj * invDet,  Mn * invDet, _
     Mc * invDet, -Mg * invDet,  Mk * invDet, -Mo * invDet, _
    -Md * invDet,  Mh * invDet, -Ml * invDet,  Mp * invDet )
end sub

sub Mat4.identity()
  '' Makes the matrix an identity matrix
  a = 1.0 : b = 0.0 : c = 0.0 : d = 0.0
  e = 0.0 : f = 1.0 : g = 0.0 : h = 0.0
  i = 0.0 : j = 0.0 : k = 1.0 : l = 0.0
  m = 0.0 : n = 0.0 : o = 0.0 : p = 1.0
end sub

operator * ( A as Mat4, B as Mat4 ) as Mat4
  /'
    Multiply two 4x4 matrices
    
    Remember that matrix multiplication is not commutative!
      A * B != B * A
  '/
  return( Mat4( _
    A.a * B.a + A.b * B.e + A.c * B.i + A.d * B.m, _
    A.a * B.b + A.b * B.f + A.c * B.j + A.d * B.n, _
    A.a * B.c + A.b * B.g + A.c * B.k + A.d * B.o, _
    A.a * B.d + A.b * B.h + A.c * B.l + A.d * B.p, _
    A.e * B.a + A.f * B.e + A.g * B.i + A.h * B.m, _
    A.e * B.b + A.f * B.f + A.g * B.j + A.h * B.n, _
    A.e * B.c + A.f * B.g + A.g * B.k + A.h * B.o, _
    A.e * B.d + A.f * B.h + A.g * B.l + A.h * B.p, _
    A.i * B.a + A.j * B.e + A.k * B.i + A.l * B.m, _
    A.i * B.b + A.j * B.f + A.k * B.j + A.l * B.n, _
    A.i * B.c + A.j * B.g + A.k * B.k + A.l * B.o, _
    A.i * B.d + A.j * B.h + A.k * B.l + A.l * B.p, _
    A.m * B.a + A.n * B.e + A.o * B.i + A.p * B.m, _
    A.m * B.b + A.n * B.f + A.o * B.j + A.p * B.n, _
    A.m * B.c + A.n * B.g + A.o * B.k + A.p * B.o, _
    A.m * B.d + A.n * B.h + A.o * B.l + A.p * B.p ) )
end operator

operator + ( A as Mat4, B as Mat4 ) as Mat4
  '' Adds two 4x4 matrices
  return( Mat4( _
    A.a + B.a, A.b + B.b, A.c + B.c, A.d + B.d, _
    A.e + B.e, A.f + B.f, A.g + B.g, A.h + B.h, _
    A.i + B.i, A.j + B.j, A.k + B.k, A.l + B.l, _
    A.m + B.m, A.n + B.n, A.o + B.o, A.p + B.p ) )
end operator

operator - ( A as Mat4, B as Mat4 ) as Mat4
  '' Substracts two 4x4 matrices
  return( Mat4( _
    A.a - B.a, A.b - B.b, A.c - B.c, A.d - B.d, _
    A.e - B.e, A.f - B.f, A.g - B.g, A.h - B.h, _
    A.i - B.i, A.j - B.j, A.k - B.k, A.l - B.l, _
    A.m - B.m, A.n - B.n, A.o - B.o, A.p - B.p ) )
end operator

operator - ( A as Mat4 ) as Mat4
  '' Negates the matrix
  return( Mat4( _
    -A.a, -A.b, -A.c, -A.d, _
    -A.e, -A.f, -A.g, -A.h, _
    -A.i, -A.j, -A.k, -A.l, _
    -A.m, -A.n, -A.o, -A.p ) )
end operator

operator * ( A as Mat4, s as single ) as Mat4
  '' Scalar multiplication
  return( Mat4( _
    A.a * s, A.b * s, A.c * s, A.d * s, _
    A.e * s, A.f * s, A.g * s, A.h * s, _
    A.i * s, A.j * s, A.k * s, A.l * s, _
    A.m * s, A.n * s, A.o * s, A.p * s ) )
end operator

operator * ( s as single, A as Mat4 ) as Mat4
  '' Scalar multiplication
  return( Mat4( _
    A.a * s, A.b * s, A.c * s, A.d * s, _
    A.e * s, A.f * s, A.g * s, A.h * s, _
    A.i * s, A.j * s, A.k * s, A.l * s, _
    A.m * s, A.n * s, A.o * s, A.p * s ) )
end operator

operator / ( s as single, A as Mat4 ) as Mat4
  /'
    Scalar divide.
    
    The 'division' of a matrix by another matrix is not defined, the
    equivalent operation is multiplying one matrix by the inverse of the other
    on scalars though, it can be defined, mostly for convenience purposes
  '/
  return( Mat4( _
    A.a / s, A.b / s, A.c / s, A.d / s, _
    A.e / s, A.f / s, A.g / s, A.h / s, _
    A.i / s, A.j / s, A.k / s, A.l / s, _
    A.m / s, A.n / s, A.o / s, A.p / s ) )
end operator

operator / ( A as Mat4, s as single ) as Mat4
  return( Mat4( _
    A.a / s, A.b / s, A.c / s, A.d / s, _
    A.e / s, A.f / s, A.g / s, A.h / s, _
    A.i / s, A.j / s, A.k / s, A.l / s, _
    A.m / s, A.n / s, A.o / s, A.p / s ) )
end operator

operator * ( v as Vec4, A as Mat4 ) as Vec4
  /'
    Multiply a vector with a row matrix, resulting in a row vector (like Direct3D)
    
    A row vector looks like this:
    
    | x y z w |
    
    and is the format that Direct3D uses. What this means, code-wise, is that you
    have to pre-multiply the vectors with the matrices, and some other stuff, like
    transposing the matrices if you are using column vectors (as this library does)
  '/
  return( Vec4( _ 
    A.a * v.x + A.e * v.y + A.i * v.z + A.m * v.w, _
    A.b * v.x + A.f * v.y + A.j * v.z + A.n * v.w, _
    A.c * v.x + A.g * v.y + A.k * v.z + A.o * v.w, _
    A.d * v.x + A.h * v.y + A.l * v.z + A.p * v.w ) )
end operator

operator * ( A as Mat4, v as Vec4 ) as Vec4
  /'
    Multiply a vector with a column matrix, resulting in a column vector (like OpenGL)
    
    A column vector looks like this
    
    | x |
    | y |
    | z |
    | w |
    
    and is the format favored by OpenGL. In this library, column vectors are used, for
    compatibility.
  '/
  return( Vec4( _
    A.a * v.X + A.b * v.Y + A.c * v.Z + A.d * v.W, _
    A.e * v.X + A.f * v.Y + A.g * v.Z + A.h * v.W, _
    A.i * v.X + A.j * v.Y + A.k * v.Z + A.l * v.W, _
    A.m * v.X + A.n * v.Y + A.o * v.Z + A.p * v.W ) )
end operator

'' Utility functions
function inverse( M as Mat4 ) as Mat4
  '' Returns the inverse of the provided matrix
  dim as Mat4 I = Mat4( M )
  
  I.inverse()
  
  return( I )
end function

namespace Matrices
  function translation( t as Vec4 ) as Mat4
    return Mat4( _
      1.0, 0.0, 0.0, t.x, _
      0.0, 1.0, 0.0, t.y, _
      0.0, 0.0, 1.0, t.z, _
      0.0, 0.0, 0.0, 1.0 ) 
  end function
  
  function identity() as Mat4
    return( Mat4( _
      1.0, 0.0, 0.0, 0.0, _
      0.0, 1.0, 0.0, 0.0, _
      0.0, 0.0, 1.0, 0.0, _
      0.0, 0.0, 0.0, 1.0 ) )
  end function
  
  function rotationAboutAxis( rotAxis as Vec4, angle as single ) as Mat4
    dim as single c = cos( angle )
    dim as single s = sin( angle )
    dim as single t = 1.0 - cos( angle )
    
    dim as Vec4 axis = normalize( rotAxis )
    
    return Mat4( _
      t * axis.x * axis.x + c, t * axis.x + axis.y + s * axis.z, t * axis.x * axis.z - s * axis.y, 0.0, _
      t * axis.x * axis.y - s * axis.z, t * axis.y * axis.y + c, t * axis.y * axis.z + s * axis.x, 0.0, _
      t * axis.x * axis.z + s * axis.y, t * axis.y * axis.z - s * axis.x, t * axis.z * axis.z + c, 0.0, _
      0.0, 0.0, 0.0, 1.0 )
  end function
end namespace

#endif