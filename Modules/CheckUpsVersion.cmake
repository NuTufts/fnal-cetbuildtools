# This macro is used by the FindUps modules

#internal macro
macro(_parse_version version )
   # convert vx_y_z to x.y.z
   # must also recognize vx_y
   STRING( REGEX REPLACE "v(.*)_(.*)_(.*)" "\\1.\\2.\\3" dotver "${version}" )
   STRING( REGEX REPLACE "v(.*)_(.*)_(.*)" "\\1" major "${version}" )
   STRING( REGEX REPLACE "v(.*)_(.*)_(.*)" "\\2" minor "${version}" )
   STRING( REGEX REPLACE "v(.*)_(.*)_(.*)" "\\3" patch "${version}" )
   STRING(REGEX MATCH [_] has_underscore ${dotver})
     if( has_underscore )
       STRING( REGEX REPLACE "v(.*)_(.*)" "\\1.\\2" dotver "${version}" )
       STRING( REGEX REPLACE "v(.*)_(.*)" "\\1" major "${version}" )
       STRING( REGEX REPLACE "v(.*)_(.*)" "\\2" minor "${version}" )
       set(patch 0)
     endif( has_underscore )
   string(TOUPPER  ${patch} PATCH_UC )
   STRING(REGEX MATCH [A-Z] has_alpha ${PATCH_UC})
   if( has_alpha )
      #message( STATUS "deal with alphabetical character in patch version ${patch}" )
      STRING(REGEX REPLACE "(.*)([A-Z])" "\\1" patch  ${PATCH_UC})
      STRING(REGEX REPLACE "(.*)([A-Z])" "\\2" patchchar  ${PATCH_UC})
   else( has_alpha )
      set( patchchar " ")
   endif( has_alpha )
endmacro(_parse_version)

macro( _check_version product version minimum )
   _parse_version( ${minimum}  )
   set( MINVER ${dotver} )
   set( MINMAJOR ${major} )
   set( MINMINOR ${minor} )
   set( MINPATCH ${patch} )
   set( MINCHAR ${patchchar} )
   _parse_version( ${version}  )
   set( THISVER ${dotver} )
   set( THISMAJOR ${major} )
   set( THISMINOR ${minor} )
   set( THISPATCH ${patch} )
   set( THISCHAR ${patchchar} )
   #message(STATUS "${product} minimum version is ${MINVER} ${MINMAJOR} ${MINMINOR} ${MINPATCH} ${MINCHAR} from ${minimum} " )
   #message(STATUS "${product} version is ${THISVER} ${THISMAJOR} ${THISMINOR} ${THISPATCH} ${THISCHAR} from ${version} " )
  if( ${THISMAJOR} LESS ${MINMAJOR} )
    message( FATAL_ERROR "Bad Major Version: ${product} ${THISVER} is less than minimum required version ${MINVER}")
  elseif( ${THISMAJOR} EQUAL ${MINMAJOR}
      AND ${THISMINOR} LESS ${MINMINOR} )
    message( FATAL_ERROR "Bad Minor Version: ${product} ${THISVER} is less than minimum required version ${MINVER}")
  elseif( ${THISMAJOR} EQUAL ${MINMAJOR}
      AND ${THISMINOR} EQUAL ${MINMINOR}
      AND ${THISPATCH} LESS ${MINPATCH} )
    message( FATAL_ERROR "Bad Patch Version: ${product} ${THISVER} is less than minimum required version ${MINVER}")
  elseif( ${THISMAJOR} EQUAL ${MINMAJOR}
      AND ${THISMINOR} EQUAL ${MINMINOR}
      AND ${THISPATCH} EQUAL ${MINPATCH}
      AND ${THISCHAR} STRLESS ${MINCHAR} )
    message( FATAL_ERROR "Bad Patch Version: ${product} ${THISVER} is less than minimum required version ${MINVER}")
  endif()

  message( STATUS "${product} ${THISVER} meets minimum required version ${MINVER}")
endmacro( _check_version product version minimum )