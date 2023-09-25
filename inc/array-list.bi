#ifndef __FB3D_ARRAY_LIST__
#define __FB3D_ARRAY_LIST__

#include once "math.bi"
#include once "crt.bi" '' needed for memcpy

'' Simple java-like ArrayList class
type ArrayList extends Object
  public:
    declare constructor()
    
    declare function get( index as uinteger ) as any ptr
    declare function count() as uinteger
    declare sub add( e as any ptr )
    declare sub insert( e as any ptr, before as uinteger )
    declare function remove( index as uinteger ) as any ptr
    declare function remove( item as any ptr ) as any ptr
    declare function removeLast() as any ptr
    declare function removeFirst() as any ptr
  
  protected:
    as any ptr  m_element( any )
    as uinteger m_count
  
  /'
    Convenience macro for brevity.
    
    This macro resizes the m_element array by v elements, either positive or negative.
      if v is positive, the array expands
      if v is negative, the array shrinks
    
    The code uses +1 and -1 for further clarify the meaning of the expression
  '/
  #macro resizeElements( v )
    m_count += v :
    redim preserve m_element( 0 to m_count - 1 )
  #endmacro
end type

constructor ArrayList()
  m_count = 0
end constructor

function ArrayList.count() as uinteger
  return( m_count )
end function

function ArrayList.get( index as uinteger ) as any ptr
  return( m_element( index ) )
end function

sub ArrayList.add( e as any ptr )
  resizeElements( +1 )
  
  m_element( m_count - 1 ) = e
end sub

sub ArrayList.insert( e as any ptr, before as uinteger )
  '' Don't allow insertion out of bounds
  before = min( m_count, max( 0, before ) )
  
  '' Trivial case, inserting at the end of the list
  if( before = m_count - 1 ) then
    resizeElements( +1 )
    
    m_element( m_count - 1 ) = m_element( m_count - 2 )
    m_element( m_count - 2 ) = e
  else
    resizeElements( +1 )
    
    '' Calculate number of elements to move
    dim as uinteger elem = m_count - 1 - before
    '' And move them to make space for the inserted item
    memcpy( @m_element( before + 1 ), @m_element( before ), elem * sizeOf( any ptr ) )
    
    m_element( before ) = e  
  end if
end sub

function ArrayList.remove( item as any ptr ) as any ptr
  '' Removes an item from the list by pointer
  dim as any ptr ret = 0
  dim as integer elem = -1 '' assume not found
  
  '' Search it
  for i as uinteger = 0 to m_count - 1
    if( item = m_element( i ) ) then
      '' Found it
      elem = i
      exit for
    end if
  next
  
  if( elem <> -1 ) then
    return( remove( elem ) )
  else
    return( 0 )
  end if
end function

function ArrayList.remove( index as uinteger ) as any ptr
  '' Removes an item from the list by index
  '' Don't allow removal out of bounds
  index = min( m_count - 1, max( 0, index ) )

  dim as any ptr ret = m_element( index )
  
  if( index = m_count - 1 ) then
  '' Trivial removal, the last item
    resizeElements( -1 )
    
    return( ret )
  end if
  
  '' Only 2 elements to remove remaining
  if( index = 0 and m_count < 3 ) then
    m_element( 0 ) = m_element( 1 )
    
    resizeElements( -1 )
    
    return( ret )
  end if
  
  '' General case (elements > 2)
  '' Number of elements to move
  dim as uinteger elem = m_count - 1 - index
  '' Move the rest of the elements 
  memcpy( @m_element( index ), @m_element( index + 1 ), elem * sizeOf( any ptr ) )
  
  resizeElements( -1 )
  
  return( ret )
end function

function ArrayList.removeLast() as any ptr
  '' Convenience function for removing the last element of the list
  dim as any ptr ret = m_element( m_count - 1 )
  
  resizeElements( -1 )
  
  return( ret )
end function

function ArrayList.removeFirst() as any ptr
  '' Convenience function for removing the first element of the list
  dim as any ptr ret = m_element( 0 )
  
  '' There's only one element remaining
  if( m_count = 1 ) then
    m_count -= 1
    redim m_element( 0 )
    
    return( ret )    
  end if
  
  '' There's 2 elements remaining
  if( m_count = 2 ) then
    m_element( 0 ) = m_element( 1 )
    
    resizeElements( -1 )
    
    return( ret )
  end if
  
  '' General case
  '' Calculate number of elements to move
  dim as uinteger elem = m_count - 1
  
  '' Move the remaining elements to their new position
  memcpy( @m_element( 0 ), @m_element( 1 ), elem * sizeOf( any ptr ) )
  
  '' And resize the member array
  resizeElements( -1 )
  
  return( ret )
end function    
#endif
