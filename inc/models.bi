#include once "object.bi"

'' Predefined models for convenience
namespace Models
  function paperPlane() as Object3D ptr
    '' Creates a small paper plane
    dim as Object3D ptr obj = new Object3D
    
    obj->vertices->add( new Vec4( -0.1, 0.0, 0.0 ) )
    obj->vertices->add( new Vec4(  0.1, 0.0, 0.0 ) )
    obj->vertices->add( new Vec4(  0.0, 0.0, 0.3 ) )
    
    obj->vertices->add( new Vec4(  0.0,  0.0, 0.0 ) )
    obj->vertices->add( new Vec4(  0.0, -0.1, 0.0 ) )
    obj->vertices->add( new Vec4(  0.0,  0.0, 0.3 ) )
    
    obj->edges->add( new Edge( obj->vertices->get( 0 ), obj->vertices->get( 1 ) ) )
    obj->edges->add( new Edge( obj->vertices->get( 1 ), obj->vertices->get( 2 ) ) )
    obj->edges->add( new Edge( obj->vertices->get( 2 ), obj->vertices->get( 0 ) ) )
    
    obj->edges->add( new Edge( obj->vertices->get( 3 ), obj->vertices->get( 4 ) ) )
    obj->edges->add( new Edge( obj->vertices->get( 4 ), obj->vertices->get( 5 ) ) )
    obj->edges->add( new Edge( obj->vertices->get( 5 ), obj->vertices->get( 3 ) ) )
    
    return( obj )
  end function
  
  function cube( w as single = 1.0, h as single = 1.0, d as single = 1.0 ) as Object3D ptr
    '' Creates a simple cube, with width w, height h and depth d, centered at the origin
    dim as single _
      hw = w / 2, hh = h / 2, hd = d / 2
    
    dim as Object3D ptr obj = new Object3D
    
    '' Top
    obj->vertices->add( new Vec4( -hw, hh, -hd ) )
    obj->vertices->add( new Vec4( -hw, hh,  hd ) )
    obj->vertices->add( new Vec4(  hw, hh,  hd ) )
    obj->vertices->add( new Vec4(  hw, hh, -hd ) )
    
    ' Bottom
    obj->vertices->add( new Vec4( -hw, -hh, -hd ) )
    obj->vertices->add( new Vec4( -hw, -hh,  hd ) )
    obj->vertices->add( new Vec4(  hw, -hh,  hd ) )
    obj->vertices->add( new Vec4(  hw, -hh, -hd ) )
    
    '' Top quad
    obj->edges->add( new Edge( obj->vertices->get( 0 ), obj->vertices->get( 1 ) ) )
    obj->edges->add( new Edge( obj->vertices->get( 1 ), obj->vertices->get( 2 ) ) )
    obj->edges->add( new Edge( obj->vertices->get( 2 ), obj->vertices->get( 3 ) ) )
    obj->edges->add( new Edge( obj->vertices->get( 3 ), obj->vertices->get( 0 ) ) )
    
    '' Bottom quad
    obj->edges->add( new Edge( obj->vertices->get( 4 ), obj->vertices->get( 5 ) ) )
    obj->edges->add( new Edge( obj->vertices->get( 5 ), obj->vertices->get( 6 ) ) )
    obj->edges->add( new Edge( obj->vertices->get( 6 ), obj->vertices->get( 7 ) ) )
    obj->edges->add( new Edge( obj->vertices->get( 7 ), obj->vertices->get( 4 ) ) )
    
    '' Side edges
    obj->edges->add( new Edge( obj->vertices->get( 0 ), obj->vertices->get( 4 ) ) )
    obj->edges->add( new Edge( obj->vertices->get( 1 ), obj->vertices->get( 5 ) ) )
    obj->edges->add( new Edge( obj->vertices->get( 2 ), obj->vertices->get( 6 ) ) )
    obj->edges->add( new Edge( obj->vertices->get( 3 ), obj->vertices->get( 7 ) ) )
    
    return( obj )
  end function
  
  function octahedron( w as single = 1.0, h as single = 1.0, d as single = 1.0 ) as Object3D ptr
    dim as single a = 1 / ( 2 * sqr( 2 ) ), b = 1 / 2
    
    dim as Object3D ptr obj = new Object3D
    
    obj->vertices->add( new Vec4( -a, 0,  a ) ) '' 0
    obj->vertices->add( new Vec4( -a, 0, -a ) ) '' 1
    obj->vertices->add( new Vec4(  0, b,  0 ) ) '' 2
    
    obj->edges->add( new Edge( obj->vertices->get( 0 ), obj->vertices->get( 1 ) ) )
    obj->edges->add( new Edge( obj->vertices->get( 1 ), obj->vertices->get( 2 ) ) )
    obj->edges->add( new Edge( obj->vertices->get( 2 ), obj->vertices->get( 0 ) ) )
    
    obj->vertices->add( new Vec4( -a, 0, -a ) ) '' 3
    obj->vertices->add( new Vec4(  a, 0, -a ) ) '' 4
    obj->vertices->add( new Vec4(  0, b,  0 ) ) '' 5
    
    obj->edges->add( new Edge( obj->vertices->get( 3 ), obj->vertices->get( 4 ) ) )
    obj->edges->add( new Edge( obj->vertices->get( 4 ), obj->vertices->get( 5 ) ) )
    obj->edges->add( new Edge( obj->vertices->get( 5 ), obj->vertices->get( 3 ) ) )
    
    obj->vertices->add( new Vec4( a, 0, -a ) ) '' 6
    obj->vertices->add( new Vec4( a, 0,  a ) ) '' 7
    obj->vertices->add( new Vec4( 0, b,  0 ) ) '' 8
    
    obj->edges->add( new Edge( obj->vertices->get( 6 ), obj->vertices->get( 7 ) ) )
    obj->edges->add( new Edge( obj->vertices->get( 7 ), obj->vertices->get( 8 ) ) )
    obj->edges->add( new Edge( obj->vertices->get( 8 ), obj->vertices->get( 6 ) ) )
    
    obj->vertices->add( new Vec4(  a, 0, a ) ) '' 9
    obj->vertices->add( new Vec4( -a, 0, a ) ) '' 10
    obj->vertices->add( new Vec4(  0, b, 0 ) ) '' 11
    
    obj->edges->add( new Edge( obj->vertices->get( 9 ), obj->vertices->get( 10 ) ) )
    obj->edges->add( new Edge( obj->vertices->get( 10 ), obj->vertices->get( 11 ) ) )
    obj->edges->add( new Edge( obj->vertices->get( 11 ), obj->vertices->get( 9 ) ) )
    
    obj->vertices->add( new Vec4(  a,  0, -a ) ) '' 12
    obj->vertices->add( new Vec4( -a,  0, -a ) ) '' 13
    obj->vertices->add( new Vec4(  0, -b,  0 ) ) '' 14
    
    obj->edges->add( new Edge( obj->vertices->get( 12 ), obj->vertices->get( 13 ) ) )
    obj->edges->add( new Edge( obj->vertices->get( 13 ), obj->vertices->get( 14 ) ) )
    obj->edges->add( new Edge( obj->vertices->get( 14 ), obj->vertices->get( 12 ) ) )
    
    obj->vertices->add( new Vec4( -a,  0, -a ) ) '' 15
    obj->vertices->add( new Vec4( -a,  0,  a ) ) '' 16
    obj->vertices->add( new Vec4(  0, -b,  0 ) ) '' 17
    
    obj->edges->add( new Edge( obj->vertices->get( 15 ), obj->vertices->get( 16 ) ) )
    obj->edges->add( new Edge( obj->vertices->get( 16 ), obj->vertices->get( 17 ) ) )
    obj->edges->add( new Edge( obj->vertices->get( 17 ), obj->vertices->get( 15 ) ) )
    
    obj->vertices->add( new Vec4(  a,  0,  a ) ) '' 18
    obj->vertices->add( new Vec4(  a,  0, -a ) ) '' 19
    obj->vertices->add( new Vec4(  0, -b,  0 ) ) '' 20
    
    obj->edges->add( new Edge( obj->vertices->get( 18 ), obj->vertices->get( 19 ) ) )
    obj->edges->add( new Edge( obj->vertices->get( 10 ), obj->vertices->get( 20 ) ) )
    obj->edges->add( new Edge( obj->vertices->get( 20 ), obj->vertices->get( 18 ) ) )
    
    obj->vertices->add( new Vec4( -a,  0,  a ) ) '' 21
    obj->vertices->add( new Vec4(  a,  0,  a ) ) '' 22
    obj->vertices->add( new Vec4(  0, -b,  0 ) ) '' 23
    
    obj->edges->add( new Edge( obj->vertices->get( 21 ), obj->vertices->get( 22 ) ) )
    obj->edges->add( new Edge( obj->vertices->get( 22 ), obj->vertices->get( 23 ) ) )
    obj->edges->add( new Edge( obj->vertices->get( 23 ), obj->vertices->get( 21 ) ) )
    
    return( obj )
  end function
end namespace