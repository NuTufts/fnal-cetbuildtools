# create the cmake configure files for this package
#
# set_flavor_qual( [arch] )
# allow optional architecture declaration
# noarch is recognized, others are used at your own discretion
#
# cet_cmake_config( [NO_FLAVOR] )
#   build and install PackageConfig.cmake and PackageConfigVersion.cmake
#   these files are installed in ${flavorqual_dir}/lib/PACKAGE/cmake
#   if NO_FLAVOR is specified, the files are installed under ${product}/${version}/include

# this requires cmake 2.8.8 or later
include(CMakePackageConfigHelpers)

include(CetParseArgs)

macro( cet_write_version_file _filename )

  cet_parse_args( CWV "VERSION;COMPATIBILITY" "" ${ARGN})

  find_file( versionTemplateFile
             NAMES CetBasicConfigVersion-${CWV_COMPATIBILITY}.cmake.in
             PATHS ${CMAKE_MODULE_PATH} )
  if(NOT EXISTS "${versionTemplateFile}")
    message(FATAL_ERROR "Bad COMPATIBILITY value used for cet_write_version_file(): \"${CWV_COMPATIBILITY}\"")
  endif()

  if("${CWV_VERSION}" STREQUAL "")
    message(FATAL_ERROR "No VERSION specified for cet_write_version_file()")
  endif()

  configure_file("${versionTemplateFile}" "${_filename}" @ONLY)
endmacro( cet_write_version_file )

macro( cet_cmake_config  )

  cet_parse_args( CCC "" "NO_FLAVOR" ${ARGN})

  if( CCC_NO_FLAVOR )
    set( distdir "${product}/${version}/cmake" )
  else()
    set( distdir "${flavorqual_dir}/lib/${product}/cmake" )
  endif()

  #message(STATUS "cet_cmake_config debug: will install cmake configure files in ${distdir}")
  #message(STATUS "cet_cmake_config debug: ${CONFIG_FIND_UPS_COMMANDS}")
  #message(STATUS "cet_cmake_config debug: ${CONFIG_FIND_LIBRARY_COMMANDS}")
  #message(STATUS "cet_cmake_config debug: ${CONFIG_LIBRARY_LIST}")
 
  # add to library list for package configure file
  foreach( my_library ${CONFIG_LIBRARY_LIST} )
    string(TOUPPER  ${my_library} ${my_library}_UC )
    string(TOUPPER  ${product} ${product}_UC )
    set(CONFIG_FIND_LIBRARY_COMMANDS "${CONFIG_FIND_LIBRARY_COMMANDS}
    cet_find_library( ${${my_library}_UC} NAMES ${my_library} PATHS ENV ${${product}_UC}_LIB NO_DEFAULT_PATH )" )
  endforeach(my_library)
  #message(STATUS "cet_cmake_config debug: ${CONFIG_FIND_LIBRARY_COMMANDS}")
 
  configure_package_config_file( 
             ${CMAKE_CURRENT_SOURCE_DIR}/product-config.cmake.in
             ${CMAKE_CURRENT_BINARY_DIR}/${product}Config.cmake 
	     INSTALL_DESTINATION ${distdir} )

  # allowed COMPATIBILITY values are:
  # AnyNewerVersion ExactVersion SameMajorVersion
  if( CCC_NO_FLAVOR )
    cet_write_version_file(
               ${CMAKE_CURRENT_BINARY_DIR}/${product}ConfigVersion.cmake
	       VERSION ${cet_dot_version}
	       COMPATIBILITY AnyNewerVersion )
  else()
    write_basic_package_version_file(
               ${CMAKE_CURRENT_BINARY_DIR}/${product}ConfigVersion.cmake
	       VERSION ${cet_dot_version}
	       COMPATIBILITY AnyNewerVersion )
  endif()

  install( FILES ${CMAKE_CURRENT_BINARY_DIR}/${product}Config.cmake
        	 ${CMAKE_CURRENT_BINARY_DIR}/${product}ConfigVersion.cmake
           DESTINATION ${distdir} )

endmacro( cet_cmake_config )
