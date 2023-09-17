#include once "fbgfx.bi"
#include once "inc/math.bi" '' math functions and constants
#include once "inc/vec4.bi" '' vec4 type and operations
#include once "inc/mat4.bi" '' mat4 type and operations
#include once "inc/arrayList.bi" '' convenience

#include once "inc/camera.bi" '' the camera class definition
#include once "inc/object.bi" '' the object definition
#include once "inc/utility.bi" '' to draw lines an' stuff directly in 3D space

/'
	3D playground
	
	intended as a simple tutorial/framework to do 3D stuff without too much complication
	it is a bare-bones implementation, actually. Mostly to test all the math/conventions 
	behind the representation of a 3D scene (using the term 'scene' veeeery loosely here)
	
	conventions used
		RIGHT HANDED coordinate system
		positive rotations are COUNTER-CLOCKWISE
		facets are defined in COUNTER-CLOCKWISE order
		angles are in RADIANS - use radians( angle_in_degrees ) for convenience
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
	Instantiate a camera class.
	
	remember the parameters for the constructor:
	
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
	Scene manager (yeah right)
	
	Here, it's just a list that contains the objects to be rendered, but in real code it
	is an instance of the scene manager.
'/
dim as arrayList objects

/'
	Let's create some objects, shall we? One, actually (yeah I'm cheap).
	
	These are the vertices and edges to define a small paper plane that
	you can manipulate (see the code in the main loop).
	The objects ideally should be loaded from a file, but that will
	complicate the implementation. If there's some interest, I will show
	how you can load an obj file (or invent your own format if you wish).
'/
'' It will be centered at the origin when starting
var obj = new Object3d()

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

'' Add the defined object to the scene
objects.add( obj )

'' Have the camera look at the oject
cam.lookAt( obj->getPos() )

'' Some variables used for interaction
dim as integer mouseX, mouseY, mouseButton, oldMouseX, oldMouseY

'' To make movement (somewhat) constant
dim as double frameTime, newTime

'' Background color (change it if you don't like it)
dim as ulong backgroundColor = rgba( 8, 0, 16, 255 )
color( , backgroundColor )

dim as string keyP '' holds a keypress
dim as boolean followPlane = false '' to toggle plane following mode
dim as single prevDist, dist

'' convenience
dim as single playerSpeed = 5.0
dim as single planeSpeed = 5.0

dim as Object3d ptr o
dim as double sum
dim as uinteger count

'' Main loop
frameTime = timer()

do		
	newTime = timer()
	
	'' Render the screen
	screenLock()
		cls()
		
		'' Draw the floor to have a frame of reference
		for zz as integer = -10 to 10 step 1
			drawLine3d(	cam, vec4( -10, 0, zz ), vec4( 10, 0, zz ), rgba( 32, 32, 32, 255 ) )
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
		
		'' renders the objects
		for i as integer = 0 to objects.count - 1
			dim as object3d ptr o
			
			o = objects.get( i )
			'' render the edges
			for j as integer = 0 to o->edges->count - 1
				dim as edge ptr e = o->edges->get( j )
				
				'' transform the points of the object to world space, as the drawLine3d() function expects them in world coordinates				
		  	drawLine3d( cam, o->objectSpaceToWorldSpace( *e->vertex1 ), o->objectSpaceToWorldSpace( *e->vertex2 ), rgba( 255, 255, 0, 255 ) )			
			next
		next
	screenUnlock()
	
	'' grab an object to have fun (in this case, the paper plane)
	o = objects.get( 0 )
	
	'' update interaction
	oldMouseX = mouseX
	oldMouseY = mouseY
	
	getMouse( mouseX, mouseY, , mouseButton )
	
	'' get a key press
	keyP = lcase( inkey() )
	
	/'
		camera controls
		
		click and drag the mouse to free look
		w: forward
		s: backward
		a: strafe left
		d: strafe right
		q: up
		e: down
		space: look at the paper plane (hold to keep looking at it)
		
		you see, they are very similar to that of a FPS
	'/	
	if( multikey( fb.sc_e ) ) then
		'' down
		cam.move( -vec4( 0.0, 1.0, 0.0 ) * playerSpeed * frameTime )
	end if
	
	if( multikey( fb.sc_q ) ) then
		'' up
		cam.move( vec4( 0.0, 1.0, 0.0 ) * playerSpeed * frameTime )
	end if

	if( multikey( fb.sc_w ) ) then
		'' forward
		cam.move( normalize( cam.getDir() ) * playerSpeed * frameTime )
	end if
	
	if( multikey( fb.sc_s ) ) then
		'' backwards
		cam.move( normalize( -cam.getDir() ) * playerSpeed * frameTime )
	end if

	if( multikey( fb.sc_a ) ) then
		'' left
		cam.move( normalize( cam.getU() ) * playerSpeed * frameTime )
	end if

	if( multikey( fb.sc_d ) ) then
		'' right
		cam.move( normalize( -cam.getU() ) * playerSpeed * frameTime )
	end if
		
	/'
		paper plane controls
		
			i: forward
			k: backwards
			j: turn left
			l: turn right
			u: turn up
			o: turn down 
	'/
	if( keyP = "0" ) then
		'' toggles plane following mode
		followPlane xor= true
	end if

	if( multikey( fb.sc_y ) ) then
		o->rotate( normalize( o->getDir() ), radians( -150.0 ) * frameTime )	
	end if

	if( multikey( fb.sc_p ) ) then
		o->rotate( normalize( o->getDir() ), radians( 150.0 ) * frameTime )
	end if

	if( multikey( fb.sc_u ) ) then
		o->rotate( normalize( o->getU() ), radians( 150.0 ) * frameTime )
	end if

	if( multikey( fb.sc_o ) ) then
		o->rotate( normalize( o->getU() ), radians( -150.0 ) * frameTime )
	end if

	if( multikey( fb.sc_i ) ) then
		o->move( normalize( o->getDir() ) * planeSpeed * frameTime )
	end if

	if( multikey( fb.sc_k ) ) then
		o->move( normalize( -( o->getDir() ) ) * planeSpeed * frameTime )
	end if

	if( multikey( fb.sc_j ) ) then
		o->rotate( normalize( o->getV() ), radians( 150 * frameTime ) )
	end if

	if( multikey( fb.sc_l ) ) then
		o->rotate( normalize( o->getV() ), radians( -150 * frameTime ) )
	end if
	
	if( followPlane = true ) then
		/'
			makes the camera follow the plane from behind
			
			this is done by setting the position of the camera to a point (in this
			case, behind and a little up of the position of the paper plane) and
			then 'lookAt' it
		'/
			cam.setPos( o->getPos() - normalize( o->getDir() ) * 1.0 + vec4( 0.0, 0.5, 0.0 ) )
			'cam.lookAt( o->getPos() ) '' use the WORLD'S up axis (the GLOBAL axis)
			cam.lookAt( o->getPos(), o->getV() ) '' use the PLANE'S up axis (the LOCAL axis)
	end if
	
	'' if the left mouse button is pressed, activate free look mode
	if( mouseButton = 1 ) then
		'' rotation about the Y axis of the WORLD (aka Yaw)
		cam.rotate( vec4( 0.0, 1.0, 0.0 ), 320.0 * ( oldMouseX - mouseX ) / cam.projectionPlane.width * frameTime )
		'' rotation about the X axis of the CAMERA (aka Pitch)
		cam.rotate( cam.getU(), -320.0 * ( oldMouseY - mouseY ) / cam.projectionPlane.height * frameTime )
	end if
	
	if( multikey( fb.sc_space ) ) then
		'' look at the object (in case we lost it)
		cam.lookAt( o->getPos() )
	end if
	
	/'
		it's important not to let 'frameTime' to be negative, as it gets multiplied with
		the camera vectors and could screw some calculations (movement, for example)
		told you, the loop implementation is very crappy, but it seems like this is
		esier for most people to grasp
	'/
	sleep( 1, 1 )
	
	newTime = timer() - newTime
	
	frameTime = newTime
	
	sum += frameTime
	count += 1
	
	windowTitle( __FB_VERSION__ & " - 3D Playground (" & str( int( 1 / ( sum / count ) ) ) & " fps)" )
loop until multikey( fb.sc_escape ) '' loop until esc is pressed

'' finally, if there's objects in the list, free them
if( objects.count > 0 ) then
	dim as object3d ptr o
	
	for i as integer = 0 to objects.count - 1
		o = objects.get( i )
		delete( o )
	next
end if
