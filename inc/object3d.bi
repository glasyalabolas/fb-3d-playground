#include once "platform.bi"
#include once "core.bi"
#include once "vec4.bi"
#include once "mat4.bi"

/'
	Object3D interface
	
	Used as a base for all objects in 3D space.
'/
interface IObject3D
	public:
		declare abstract function getMatrix() as mat4
		declare abstract function getInverseMatrix() as mat4
		declare abstract sub setMatrix( byref as mat4 )
		declare abstract sub move( byval as vec4 )
		declare abstract sub rotate( byval as vec4, byval as single )

end interface
