#include once "fbgfx.bi"
#include once "inc/math.bi"      '' math functions and constants
#include once "inc/vec4.bi"      '' vec4 type and operations
#include once "inc/mat4.bi"      '' mat4 type and operations
#include once "inc/array-list.bi" '' convenience

#include once "inc/camera.bi"  '' the camera class definition
#include once "inc/object.bi"  '' the object definition
#include once "inc/utility.bi" '' to draw lines and stuff directly in 3D space

/'
  3D Playground
  
  Intended as a simple tutorial/framework to do 3D stuff without too much complication.
  It is a bare-bones implementation, actually. Mostly to test all the math/conventions 
  behind the representation of a 3D scene (using the term 'scene' veeeery loosely here)
  
  Conventions used
    RIGHT HANDED coordinate system
    positive rotations are COUNTER-CLOCKWISE
    facets are defined in COUNTER-CLOCKWISE order
    angles are in RADIANS - use radians( angle_in_degrees ) for convenience
  
  TODO:
    - Refactor the code to use arrays to store vertices and surfaces instead of edges,
      to make it directly useable with OpenGL.
'/

const as integer scrW = 800, scrH = 600
screenRes( scrW, scrH, 32, , Fb.GFX_ALPHA_PRIMITIVES )

/'
  Define a projection plane (in this case the screen itself)
  
  The projection plane is where the image gets projected (duh)
  in the pinhole camera model, the projection plane is actually the
  so called 'near' plane. The near parameter of the camera is really
  the distance of this plane to the origin of coordinates (in the
  case of the camera, its position in the world coordinate system
'/
dim as Rectangle projectionPlane = ( 0.0, 0.0, scrW, scrH )

/'
  Instantiate a camera.
  
  Remember the parameters for the constructor:
  
  position, in WORLD space
  X axis of the camera's coordinate system
  Y axis of the camera's coordinate system
  Z axis of the camera's coordinate system. If you flip it, you will end with a
    left-handed coordinate system. Not that it matters much, save for the fact that
    all other methods treat the matrix as a right-handed one. If you use lookAt()
    and suddenly the axes get flipped, this is the most probable reason
  near clipping plane Z distance
  far clipping plane Z distance
  projection plane
  
  A word of advice: the axes of the camera have to be of a certain length, for the
  projection matrix depends on it. See the code below, where the U and V vectors
  get scaled to match the relation of the projection plane. If you fool around with
  them and suddenly the image looks like crap, this is the most probable reason.
  
  To remember:
    the U vector (the X one) controls the horizontal field of view
    the V vector (the Y one) controls the vertical field of view
    and the Z vector controls the zoom
    
    Of course, they must be perfectly perpendicular to each other, if not the resulting
    image is sheared. Anyway, you don't have to mess with the constructor if you don't 
    like and/or understand what it does for the camera to do its job.
  
  Having said all that, play around! See how each function transforms the camera, and
  the effect it has on the image. Look at the implementation to see how it's done, but
  most important of all, have fun!
'/
var cam = Camera( _
  vec4( 2.0, 1.0,-2.0 ), _
  vec4( 1.0, 0.0, 0.0 ), _
  vec4( 0.0, 1.0, 0.0 ), _
  vec4( 0.0, 0.0, -1.0 ), _
  0.1, 10000.0, projectionPlane )

/'
  A list that contains the objects to be rendered. In real code it
  is bound to be more sophisticated than this.
'/
dim as ArrayList objects

/'
  Let's create some objects, shall we? One, actually (yeah I'm cheap).
  
  The objects ideally should be loaded from a file, but that will
  complicate the implementation. Here, we just use a function that
  defines the vertices and edges for a small paper plane.
'/
'' Add the defined object to the scene
objects.add( paperplane() )

'' Have the camera look at the object
cam.lookAt( cast( Object3D ptr, objects.get( 0 ) )->getPos() )

'' Some variables used for interaction
dim as integer mouseX, mouseY, mouseButton, oldMouseX, oldMouseY

'' To make movement (somewhat) constant
dim as double frameTime, oldTime

'' Background color (change it if you don't like it)
dim as ulong backgroundColor = rgba( 8, 0, 16, 255 )
color( , backgroundColor )

dim as string keyP '' holds a keypress
dim as boolean followPlane = false '' to toggle plane following mode
dim as single prevDist, dist

dim as single playerSpeed = 5.0
dim as single planeSpeed = 5.0

dim as Object3d ptr o
dim as double sum
dim as uinteger count

'' Main loop

do    
  oldTime = timer()
  
  '' Render the screen
  screenLock()
    cls()
    
    '' Draw the floor to have a frame of reference
    for zz as integer = -10 to 10 step 1
      drawLine3d(  cam, vec4( -10, 0, zz ), vec4( 10, 0, zz ), rgba( 32, 32, 32, 255 ) )
    next
    
    for xx as integer = -10 to 10 step 1
      drawLine3d( cam, vec4( xx, 0, -10 ), vec4( xx, 0, 10 ), rgba( 32, 32, 32, 255 ) )
    next
    
    /'
      Draw the absolute axes of the world
      
      x = red
      y = green
      z = blue
    '/
    drawLine3d( cam, vec4( 0.0, 0.0, 0.0 ), vec4( 3.0, 0.0, 0.0 ), rgba( 128, 0, 0, 255 ) )
    drawLine3d( cam, vec4( 0.0, 0.0, 0.0 ), vec4( 0.0, 3.0, 0.0 ), rgba( 0, 128, 0, 255 ) )
    drawLine3d( cam, vec4( 0.0, 0.0, 0.0 ), vec4( 0.0, 0.0, 3.0 ), rgba( 0, 0, 128, 255 ) )
    
    '' Renders the objects
    for i as integer = 0 to objects.count - 1
      dim as Object3D ptr o = objects.get( i )
      
      '' Render the edges
      for j as integer = 0 to o->edges->count - 1
        dim as Edge ptr e = o->edges->get( j )
        
        '' Transform the points of the object to world space, as the drawLine3d()
        '' function expects them in world coordinates.        
        drawLine3d( cam, _
          o->objectSpaceToWorldSpace( *e->vertex1 ), _
          o->objectSpaceToWorldSpace( *e->vertex2 ), rgba( 255, 255, 0, 255 ) )      
      next
    next
  screenUnlock()
  
  '' Grab an object to have fun (in this case, the paper plane)
  o = objects.get( 0 )
  
  '' Update interaction
  oldMouseX = mouseX
  oldMouseY = mouseY
  
  getMouse( mouseX, mouseY, , mouseButton )
  
  '' Get a key press
  keyP = lcase( inkey() )
  
  /'
    Camera controls
    
    click and drag the mouse to free look
    w: forward
    s: backward
    a: strafe left
    d: strafe right
    q: up
    e: down
    space: look at the paper plane (hold to keep looking at it)
    
    Akin to that of a FPS
  '/  
  if( multiKey( Fb.SC_E ) ) then
    '' down
    cam.move( -vec4( 0.0, 1.0, 0.0 ) * playerSpeed * frameTime )
  end if
  
  if( multiKey( Fb.SC_Q ) ) then
    '' up
    cam.move( vec4( 0.0, 1.0, 0.0 ) * playerSpeed * frameTime )
  end if

  if( multiKey( Fb.SC_W ) ) then
    '' forward
    cam.move( normalize( cam.getDir() ) * playerSpeed * frameTime )
  end if
  
  if( multiKey( Fb.SC_S ) ) then
    '' Backwards
    cam.move( normalize( -cam.getDir() ) * playerSpeed * frameTime )
  end if

  if( multiKey( Fb.SC_A ) ) then
    '' Left
    cam.move( normalize( cam.getU() ) * playerSpeed * frameTime )
  end if

  if( multiKey( Fb.SC_D ) ) then
    '' Right
    cam.move( normalize( -cam.getU() ) * playerSpeed * frameTime )
  end if
    
  /'
    Paper plane controls
    
      i: forward
      k: backwards
      j: turn left
      l: turn right
      u: turn up
      o: turn down 
  '/
  if( keyP = "0" ) then
    '' Toggles plane following mode
    followPlane xor= true
  end if

  if( multiKey( Fb.SC_Y ) ) then
    o->rotate( normalize( o->getDir() ), radians( -150.0 ) * frameTime )  
  end if

  if( multiKey( Fb.SC_P ) ) then
    o->rotate( normalize( o->getDir() ), radians( 150.0 ) * frameTime )
  end if

  if( multiKey( Fb.SC_U ) ) then
    o->rotate( normalize( o->getU() ), radians( 150.0 ) * frameTime )
  end if

  if( multiKey( Fb.SC_O ) ) then
    o->rotate( normalize( o->getU() ), radians( -150.0 ) * frameTime )
  end if

  if( multiKey( Fb.SC_I ) ) then
    o->move( normalize( o->getDir() ) * planeSpeed * frameTime )
  end if

  if( multiKey( Fb.SC_K ) ) then
    o->move( normalize( -( o->getDir() ) ) * planeSpeed * frameTime )
  end if

  if( multiKey( Fb.SC_J ) ) then
    o->rotate( normalize( o->getV() ), radians( 150 * frameTime ) )
  end if

  if( multiKey( Fb.SC_L ) ) then
    o->rotate( normalize( o->getV() ), radians( -150 * frameTime ) )
  end if
  
  if( followPlane = true ) then
    /'
      Makes the camera follow the plane from behind.
      
      This is done by setting the position of the camera to a point (in this
      case, behind and a little up of the position of the paper plane) and
      then 'lookAt' it.
    '/
      cam.setPos( o->getPos() - normalize( o->getDir() ) * 1.0 + vec4( 0.0, 0.5, 0.0 ) )
      'cam.lookAt( o->getPos() ) '' use the WORLD'S up axis (the GLOBAL axis)
      cam.lookAt( o->getPos(), o->getV() ) '' use the PLANE'S up axis (the LOCAL axis)
  end if
  
  '' If the left mouse button is pressed, activate free look mode
  if( mouseButton and Fb.BUTTON_LEFT ) then
    '' Rotation about the Y axis of the WORLD (aka Yaw)
    cam.rotate( vec4( 0.0, 1.0, 0.0 ), 320.0 * ( oldMouseX - mouseX ) / cam.projectionPlane.width * frameTime )
    '' Rotation about the X axis of the CAMERA (aka Pitch)
    cam.rotate( cam.getU(), -320.0 * ( oldMouseY - mouseY ) / cam.projectionPlane.height * frameTime )
  end if
  
  if( multikey( Fb.SC_SPACE ) ) then
    '' Look at the object (in case we lost it)
    cam.lookAt( o->getPos() )
  end if
  
  /'
    Tt's important not to let 'frameTime' to be negative, as it gets multiplied with
    the camera vectors and could screw some calculations (movement, for example)
    told you, the loop implementation is very crappy, but it seems like this is
    esier for most people to grasp
  '/
  sleep( 1, 1 )
  
  frameTime = timer() - oldTime
   
  windowTitle( "FreeBasic " & __FB_VERSION__ & " - 3D Playground" )
loop until( multiKey( Fb.SC_ESCAPE ) ) '' loop until esc is pressed

'' Finally, if there's objects in the list, free them
for i as integer = 0 to objects.count - 1
  delete( cast( Object3D ptr, objects.get( i ) ) )
next
