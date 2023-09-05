#include once "fbgfx.bi"

#include once "inc/math.bi"
#include once "inc/vec4.bi"
#include once "inc/mat4.bi"
#include once "inc/arrayList.bi"

#include once "inc/camera.bi"
#include once "inc/object.bi"
#include once "inc/models.bi"

sub renderGrid( cam as Camera, p as Vec4, w as long, h as long, c as ulong )
  dim as long hw = w shr 1, hh = h shr 1
  
  for z as integer = -hw to hw step 1
    line3D( cam, p + Vec4( -hw, 0, z ), p + Vec4( hw, 0, z ), c )
  next
  
  for x as integer = -hh to hh step 1
    line3D( cam, p + Vec4( x, 0, -hh ), p + Vec4( x, 0, hh ), c )
  next
end sub

sub renderAxes( cam as Camera )
  line3D( cam, Vec4( 0.0, 0.0, 0.0 ), Vec4( 3.0, 0.0, 0.0 ), rgba( 128, 0, 0, 255 ) )
  line3D( cam, Vec4( 0.0, 0.0, 0.0 ), Vec4( 0.0, 3.0, 0.0 ), rgba( 0, 128, 0, 255 ) )
  line3D( cam, Vec4( 0.0, 0.0, 0.0 ), Vec4( 0.0, 0.0, 3.0 ), rgba( 0, 0, 128, 255 ) )
end sub

sub renderObjects( cam as Camera, obj as ArrayList )
  '' Renders the objects
  for i as integer = 0 to obj.count - 1
    dim as Object3D ptr o = obj.get( i )
    
    o->render( cam )
  next
end sub

/'
  FreeBasic 3D playground
  
  Intended as a simple tutorial/framework to do 3D stuff without too much complication.
  It is a bare-bones implementation, actually. Mostly to test all the math/conventions 
  behind the representation of a 3D scene (using the term 'scene' veeeery loosely here)
  
  Conventions used
    RIGHT HANDED coordinate system
    positive rotations are COUNTER-CLOCKWISE
    facets are defined in COUNTER-CLOCKWISE order
    angles are in RADIANS - use radians( angle_in_degrees ) for convenience
'/

const as integer scrW = 600, scrH = 600
screenRes( scrW, scrH, 32, , Fb.GFX_ALPHA_PRIMITIVES )
windowTitle( "FreeBasic 3D Playground" )

/'
  Define a projection plane (in this case the screen itself).
  
  The projection plane is where the image gets projected.
  In the pinhole camera model, the projection plane is actually the
  so called 'near' plane. The near parameter of the camera is really
  the distance of this plane to the origin of coordinates (in the
  case of the camera, its position in the world coordinate system)
'/
dim as Rectangle projectionPlane = ( 0.0, 0.0, scrW, scrH )

/'
  Instantiate a camera class.
  
  Remember the parameters for the constructor:
  
    Position, in WORLD space
    X axis of the camera's coordinate system
    Y axis of the camera's coordinate system
    Z axis of the camera's coordinate system. If you flip it, you will end with a
      left-handed coordinate system. Not that it matters much, save for the fact that
      all other methods treat the matrix as a right-handed one. If you use lookAt()
      and suddenly the axes get flipped, this is the most probable reason
    Near clipping plane Z distance
    Far clipping plane Z distance
    Projection plane
  
  A word of advice: the axes of the camera have to be of a certain length, for the
  projection matrix depends on it. See the code below, where the U and V vectors
  get scaled to match the relation of the projection plane. If you fool around with
  them and suddenly the image looks like crap, this is the most probable reason.
  
  To remember:
    The U vector (the X one) controls the horizontal field of view
    The V vector (the Y one) controls the vertical field of view
    And the Z vector controls the zoom
  
  Of course, they must be perfectly perpendicular to each other; if not, the resulting
  image is sheared. Anyway, you don't have to mess with the constructor if you don't 
  like and/or understand what it does for the camera to do its job.
  
  Having said all that, play around! See how each function transforms the camera, and
  the effect it has on the image. Look at the implementation to see how it's done, but
  most important of all, have fun!
'/
var cam = Camera( _
  Vec4( 0.5, 0.5, 0.0 ), _
  Vec4( 1.0, 0.0, 0.0 ), _
  Vec4( 0.0, 1.0, 0.0 ), _
  Vec4( 0.0, 0.0, -1.0 ), _
  0.1, 10000.0, projectionPlane )

/'
  Scene manager (sort of)
  
  Here, it's just a list that contains the objects to be rendered, but in real code it
  is far more complex than this.
'/
dim as ArrayList Objects

'' Add an object to the scene. It will be centered at the origin.
var obj = Models.paperPlane()

obj->color = rgb( 255, 255, 0 )

objects.add( obj )

'' Look at the object at the start
cam.lookAt( Vec4( 0, 0.5, 10000 ) )

'cam.lookAt( obj->getPos() )

'' Some variables used for interaction
dim as integer _
  mouseX, mouseY, mouseButton, oldMouseX, oldMouseY

'' To make movement (somewhat) constant
dim as double frameTime, newTime

'' Background color (change it if you don't like it)
dim as ulong backgroundColor = rgba( 8, 0, 16, 255 )
color( , backgroundColor )

dim as string keyP '' holds a keypress
dim as boolean followPlane = false '' to toggle plane following mode

'' Convenience
dim as single cameraSpeed = 5.0, planeSpeed = 5.0

'' Main loop
frameTime = timer()

dim as long gridW = 10, gridH = 10
dim as ulong gridColor = rgb( 0, 192, 0 )

do		
  newTime = timer()
  
  '' Render the screen
  screenLock()
    cls()
    
    '' Draw the floor to have a frame of reference
    renderGrid( cam, Vec4( 0, 0, 0 ), gridW, gridH, gridColor )
    renderGrid( cam, Vec4( 0, 1, 0 ), gridW, gridH, gridColor )
    
    /'
      Draw the absolute axes of the world
      
      x = red
      y = green
      z = blue
    '/
    'renderAxes( cam )
    
    '' Renders the objects
    renderObjects( cam, objects )
  screenUnlock()
  
  '' Grab an object to have fun (in this case, the paper plane)
  dim as Object3D ptr o = objects.get( 0 )
  
  '' Update interaction
  oldMouseX = mouseX
  oldMouseY = mouseY
  
  dim as boolean mouseEvent = not cbool( getMouse( mouseX, mouseY, , mouseButton ) )
  
  '' Get a key press
  keyP = lcase( inkey() )
  
  /'
    Camera controls
    
    Click and drag the mouse to free look
    
    w: forward
    s: backward
    a: strafe left
    d: strafe right
    q: up
    e: down
    space: look at the paper plane (hold to keep looking at it)
  '/	
  if( multikey( Fb.SC_E ) ) then
    '' Down
    cam.move( -Vec4( 0.0, 1.0, 0.0 ) * cameraSpeed * frameTime )
  end if
  
  if( multikey( Fb.SC_Q ) ) then
    '' Up
    cam.move( Vec4( 0.0, 1.0, 0.0 ) * cameraSpeed * frameTime )
  end if
  
  if( multikey( Fb.SC_W ) ) then
    '' Forward
    cam.move( normalize( cam.getDir() ) * cameraSpeed * frameTime )
  end if
  
  if( multikey( Fb.SC_S ) ) then
    '' Backwards
    cam.move( normalize( -cam.getDir() ) * cameraSpeed * frameTime )
  end if
  
  if( multikey( Fb.SC_A ) ) then
    '' Left
    cam.move( normalize( cam.getU() ) * cameraSpeed * frameTime )
  end if
  
  if( multikey( Fb.SC_D ) ) then
    '' Right
    cam.move( normalize( -cam.getU() ) * cameraSpeed * frameTime )
  end if
  
  if( keyP = "0" ) then
    '' Toggles plane following mode
    followPlane xor= true
  end if
  
  '' If the left mouse button is pressed, activate free look mode
  if( mouseEvent andAlso mouseButton and Fb.BUTTON_LEFT ) then
    '' Rotation about the Y axis of the WORLD (aka Yaw)
    cam.rotate( Vec4( 0.0, 1.0, 0.0 ), 320.0 * ( oldMouseX - mouseX ) / cam.projectionPlane.width * frameTime )
    '' Rotation about the X axis of the CAMERA (aka Pitch)
    cam.rotate( cam.getU(), -320.0 * ( oldMouseY - mouseY ) / cam.projectionPlane.height * frameTime )
  end if
  
  if( multikey( Fb.SC_SPACE ) ) then
    '' Look at the object (in case we lost it)
    cam.lookAt( o->getPos() )
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
  if( multikey( Fb.SC_Y ) ) then
    o->rotate( normalize( o->getDir() ), radians( -150.0 ) * frameTime )	
  end if
  
  if( multikey( Fb.SC_P ) ) then
    o->rotate( normalize( o->getDir() ), radians( 150.0 ) * frameTime )
  end if
  
  if( multikey( Fb.SC_U ) ) then
    o->rotate( normalize( o->getU() ), radians( 150.0 ) * frameTime )
  end if
  
  if( multikey( Fb.SC_O ) ) then
    o->rotate( normalize( o->getU() ), radians( -150.0 ) * frameTime )
  end if
  
  if( multikey( Fb.SC_I ) ) then
    o->move( normalize( o->getDir() ) * planeSpeed * frameTime )
  end if
  
  if( multikey( Fb.SC_K ) ) then
    o->move( normalize( -( o->getDir() ) ) * planeSpeed * frameTime )
  end if
  
  if( multikey( Fb.SC_J ) ) then
    o->rotate( normalize( o->getV() ), radians( 150 * frameTime ) )
  end if
  
  if( multikey( Fb.SC_L ) ) then
    o->rotate( normalize( o->getV() ), radians( -150 * frameTime ) )
  end if
  
  if( multikey( Fb.SC_1 ) ) then
    cam.zoom( 1.01 )
  end if
  
  if( multikey( Fb.SC_2 ) ) then
    cam.zoom( 0.99 )
  end if
  
  if( multikey( Fb.SC_3 ) ) then
    cam.zoomU( 1.01 )
  end if
  
  if( multikey( Fb.SC_4 ) ) then
    cam.zoomU( 0.99 )
  end if
  
  if( multikey( Fb.SC_5 ) ) then
    cam.zoomV( 1.01 )
  end if
  
  if( multikey( Fb.SC_6 ) ) then
    cam.zoomV( 0.99 )
  end if
  
  if( followPlane = true ) then
    /'
      Makes the camera follow the plane from behind.
      
      This is done by setting the position of the camera to a point (in this
      case, behind and a little up of the position of the paper plane) and
      then 'lookAt' it.
    '/
    cam.setPos( o->getPos() - normalize( o->getDir() ) * 1.0 + Vec4( 0.0, 0.5, 0.0 ) )
    'cam.lookAt( o->getPos() ) '' use the WORLD'S up axis (the GLOBAL axis)
    cam.lookAt( o->getPos(), o->getV() ) '' use the PLANE'S up axis (the LOCAL axis)
  end if
  
  '' It's important not to let 'frameTime' to be negative, as it gets multiplied with
  '' the camera vectors and could screw some calculations (movement, for example)
  sleep( 1, 1 )
  
  newTime = timer() - newTime
  
  frameTime = newTime
loop until( multikey( Fb.SC_ESCAPE ) )

'' Finally, if there's objects in the list, free them
for i as integer = 0 to objects.count - 1
  delete( cast( Object3D ptr, objects.get( i ) ) )
next
