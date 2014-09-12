########################################################################
# install_source()
#   Install source code for debugging purposes.
#   Default extensions:
#      .cc .c .cpp .C .cxx
#      .h .hh .H .hpp .icc
#      .xml
#     .sh .py .pl .rb
#
# install_headers()
#   Install headers for inclusion by other packages.
#   Default extensions:
#      .h .hh .H .hpp .icc
#
# install_scripts()
#   Install scripts in the package binary directory.
#   Default extensions:
#     .sh .py .pl .rb
#
# install_fhicl()
#   Install fhicl scripts in a top level fcl subdirectory
#   Default extensions:
#     .fcl
#
# The SUBDIRS option allows you to search subdirectories (e.g. a detail subdirectory)
#
# The EXTRAS option is intended to allow you to pick up extra files not otherwise found.
# They should be specified by relative path (eg f1, subdir1/f2, etc.).
#
# The EXCLUDES option will exclude the specified files from the installation list.
#
# The LIST option allows you to install from a list. When LIST is used,
# we do not search for other files to install. Note that the LIST and
# SUBDIRS options are mutually exclusive.
#
####################################
# Recommended use:
#
# install_source( [SUBDIRS subdirectory_list] 
#                 [EXTRAS extra_files] 
#                 [EXCLUDES exclusions] )
# install_source( LIST file_list )
#
# install_headers( [SUBDIRS subdirectory_list] 
#                  [EXTRAS extra_files]
#                  [EXCLUDES exclusions] )
# install_headers( LIST file_list )
#
# install_fhicl( [SUBDIRS subdirectory_list]
#                [EXTRAS extra_files]
#                [EXCLUDES exclusions] )
# install_fhicl( LIST file_list )
#
# install_fw( LIST file_list 
#             [SUBDIRNAME subdirectory_under_fwdir] )
# THERE ARE NO DEFAULTS FOR install_fw
#
# install_gdml( [SUBDIRS subdirectory_list]
#                [EXTRAS extra_files]
#                [EXCLUDES exclusions] )
# install_gdml( LIST file_list )
#
# install_scripts( [SUBDIRS subdirectory_list]
#                  [EXTRAS extra_files]
#                  [EXCLUDES exclusions] )
# install_scripts( LIST file_list )
#
# set_install_root() defines PACKAGE_TOP_DIR
#
########################################################################

include(CMakeParseArguments)
include (CetCopy)

macro( _cet_check_inc_directory )
  if( ${${product}_inc_dir} MATCHES "NONE" )
     message(FATAL_ERROR "Please specify an include directory in product_deps")
  elseif( ${${product}_inc_dir} MATCHES "ERROR" )
     message(FATAL_ERROR "Invalid include directory in product_deps")
  endif()
endmacro( _cet_check_inc_directory )

macro( _cet_check_build_directory )
  FILE(GLOB build_directory_files
	    ${CMAKE_CURRENT_BINARY_DIR}/[^.]*.cc
	    ${CMAKE_CURRENT_BINARY_DIR}/[^.]*.c
	    ${CMAKE_CURRENT_BINARY_DIR}/[^.]*.cpp
	    ${CMAKE_CURRENT_BINARY_DIR}/[^.]*.C
	    ${CMAKE_CURRENT_BINARY_DIR}/[^.]*.cxx
	    ${CMAKE_CURRENT_BINARY_DIR}/[^.]*.h
	    ${CMAKE_CURRENT_BINARY_DIR}/[^.]*.hh
	    ${CMAKE_CURRENT_BINARY_DIR}/[^.]*.H
	    ${CMAKE_CURRENT_BINARY_DIR}/[^.]*.hpp
	    ${CMAKE_CURRENT_BINARY_DIR}/[^.]*.icc
	    ${CMAKE_CURRENT_BINARY_DIR}/[^.]*.xml
	    ${CMAKE_CURRENT_BINARY_DIR}/[^.]*.sh
	    ${CMAKE_CURRENT_BINARY_DIR}/[^.]*.py
	    ${CMAKE_CURRENT_BINARY_DIR}/[^.]*.pl
	    ${CMAKE_CURRENT_BINARY_DIR}/[^.]*.rb
	    )
  FILE(GLOB build_directory_headers
	    ${CMAKE_CURRENT_BINARY_DIR}/[^.]*.h
	    ${CMAKE_CURRENT_BINARY_DIR}/[^.]*.hh
	    ${CMAKE_CURRENT_BINARY_DIR}/[^.]*.H
	    ${CMAKE_CURRENT_BINARY_DIR}/[^.]*.hpp
	    ${CMAKE_CURRENT_BINARY_DIR}/[^.]*.icc
	    )
  if( build_directory_files )
    #message( STATUS "_cet_check_build_directory: installing ${build_directory_files} in ${source_install_dir}")
    INSTALL( FILES ${build_directory_files}
             DESTINATION ${source_install_dir} )
  endif( build_directory_files )
  if( build_directory_headers )
    #message( STATUS "_cet_check_build_directory: installing ${build_directory_headers} in ${source_install_dir}")
    INSTALL( FILES ${build_directory_headers}
             DESTINATION ${header_install_dir} )
  endif( build_directory_headers )
endmacro( _cet_check_build_directory )

macro( _cet_install_generated_dictionary_code )
  # check for dictionary code
  if( cet_generated_code )
    foreach( dict ${cet_generated_code} )
      INSTALL( FILES ${dict}
        DESTINATION ${source_install_dir} )
    endforeach(dict)
  endif( cet_generated_code )
  set(cet_generated_code) # Clear to avoid causing problems in subdirectories.
endmacro( _cet_install_generated_dictionary_code )

macro( _cet_install_without_list   )
  #message( STATUS "source code will be installed in ${source_install_dir}" )
  FILE(GLOB src_files
	    [^.]*.cc [^.]*.c [^.]*.cpp [^.]*.C [^.]*.cxx
	    [^.]*.h [^.]*.hh [^.]*.H [^.]*.hpp [^.]*.icc
	    [^.]*.xml [^.]*.sh [^.]*.py [^.]*.pl [^.]*.rb
	    )
  if( ISRC_EXCLUDES )
    LIST( REMOVE_ITEM src_files ${ISRC_EXCLUDES} )
  endif()
  if( src_files )
    INSTALL( FILES ${src_files}
             DESTINATION ${source_install_dir} )
  endif( src_files )
  # check for generated files
  _cet_check_build_directory()
  _cet_install_generated_dictionary_code()
  # now check subdirectories
  if( ISRC_SUBDIRS )
     foreach( sub ${ISRC_SUBDIRS} )
	FILE(GLOB subdir_src_files
        	 ${sub}/[^.]*.cc ${sub}/[^.]*.c ${sub}/[^.]*.cpp ${sub}/[^.]*.C ${sub}/[^.]*.cxx
        	 ${sub}/[^.]*.h ${sub}/[^.]*.hh ${sub}/[^.]*.H ${sub}/[^.]*.hpp ${sub}/[^.]*.icc
        	 ${sub}/[^.]*.xml ${sub}/[^.]*.sh ${sub}/[^.]*.py ${sub}/[^.]*.pl ${sub}/[^.]*.rb )
	if( ISRC_EXCLUDES )
          LIST( REMOVE_ITEM subdir_src_files ${ISRC_EXCLUDES} )
	endif()
	if( subdir_src_files )
          INSTALL( FILES ${subdir_src_files}
                   DESTINATION ${source_install_dir}/${sub} )
	endif( subdir_src_files )
     endforeach(sub)
     #message( STATUS "also installing in subdirectories: ${ISRC_SUBDIRS}")
  endif( ISRC_SUBDIRS )
endmacro( _cet_install_without_list )

macro( _cet_install_from_list  source_files  )
  #message( STATUS "_cet_install_from_list debug: source code list will be installed in ${source_install_dir}" )
  #message( STATUS "_cet_install_from_list debug: install list is ${source_files}")
  INSTALL( FILES ${source_files}
           DESTINATION ${source_install_dir} )
endmacro( _cet_install_from_list )

macro( _cet_install_header_without_list   )
  #message( STATUS "headers will be installed in ${header_install_dir}" )
  FILE(GLOB headers [^.]*.h [^.]*.hh [^.]*.H [^.]*.hpp [^.]*.icc )
  FILE(GLOB dict_headers classes.h )
  if( dict_headers )
    #message(STATUS "install_headers debug: removing ${dict_headers} from header list")
    LIST(REMOVE_ITEM headers ${dict_headers} )
  endif( dict_headers)
  if(IHDR_EXCLUDES)
    LIST( REMOVE_ITEM headers ${IHDR_EXCLUDES} )
  endif()
  if( headers )
    #message( STATUS "installing headers ${headers} in ${header_install_dir}")
    INSTALL( FILES ${headers}
             DESTINATION ${header_install_dir} )
  endif( headers )
  # now check subdirectories
  if( IHDR_SUBDIRS )
    foreach( sub ${IHDR_SUBDIRS} )
      FILE(GLOB subdir_headers
                ${sub}/[^.]*.h ${sub}/[^.]*.hh ${sub}/[^.]*.H ${sub}/[^.]*.hpp ${sub}/[^.]*.icc  )
      if(IHDR_EXCLUDES)
        LIST( REMOVE_ITEM subdir_headers ${IHDR_EXCLUDES} )
      endif()
      if( subdir_headers )
        INSTALL( FILES ${subdir_headers}
                 DESTINATION ${header_install_dir}/${sub} )
      endif( subdir_headers )
    endforeach(sub)
    #message( STATUS "also installing in subdirectories: ${IHDR_SUBDIRS}")
  endif( IHDR_SUBDIRS )
endmacro( _cet_install_header_without_list )

macro( _cet_install_header_from_list header_list  )
  ##message( STATUS "_cet_install_header_from_list debug: source code list will be installed in ${header_install_dir}" )
  ##message( STATUS "_cet_install_header_from_list debug: install list is ${header_list}")
  INSTALL( FILES ${header_list}
           DESTINATION ${header_install_dir} )
endmacro( _cet_install_header_from_list )

macro( _cet_install_script_without_list   )
  #message( STATUS "scripts will be installed in ${script_install_dir}" )
  FILE(GLOB scripts [^.]*.sh [^.]*.py [^.]*.pl [^.]*.rb )
  if( IS_EXCLUDES )
    LIST( REMOVE_ITEM scripts ${IS_EXCLUDES} )
  endif()
  if( scripts )
    #message( STATUS "installing scripts ${scripts} in ${script_install_dir}")
    INSTALL ( PROGRAMS ${scripts}
              DESTINATION ${script_install_dir} )
  endif( scripts )
  # now check subdirectories
  if( IS_SUBDIRS )
    foreach( sub ${IS_SUBDIRS} )
      FILE(GLOB subdir_scripts
                ${sub}/[^.]*.sh ${sub}/[^.]*.py ${sub}/[^.]*.pl ${sub}/[^.]*.rb )
      if( IS_EXCLUDES )
        LIST( REMOVE_ITEM subdir_scripts ${IS_EXCLUDES} )
      endif()
      if( subdir_scripts )
        INSTALL ( PROGRAMS ${subdir_scripts}
                  DESTINATION ${script_install_dir} )
      endif( subdir_scripts )
    endforeach(sub)
  endif( IS_SUBDIRS )
endmacro( _cet_install_script_without_list )

macro( _cet_copy_fcl )
  set( mrb_build_dir $ENV{MRB_BUILDDIR} )
  get_filename_component( fclpathname ${fhicl_install_dir} NAME )
  #message(STATUS "_cet_copy_fcl: copying to mrb ${mrb_build_dir}/${product}/${fclpathname} or cet ${CETPKG_BUILD}/${fclpathname}")
  if( mrb_build_dir )
    set( fclbuildpath ${mrb_build_dir}/${product}/${fclpathname} )
  else()
    set( fclbuildpath ${CETPKG_BUILD}/${fclpathname} )
  endif()
  #message(STATUS "_cet_copy_fcl: copying to ${fclbuildpath}")
  cet_copy(${ARGN} DESTINATION "${fclbuildpath}")
endmacro( _cet_copy_fcl )

macro( _cet_install_fhicl_without_list   )
  #message( STATUS "fhicl scripts will be installed in ${fhicl_install_dir}" )
  FILE(GLOB fcl_files [^.]*.fcl )
  if( IFCL_EXCLUDES )
    LIST( REMOVE_ITEM fcl_files ${IFCL_EXCLUDES} )
  endif()
  if( fcl_files )
    #message( STATUS "installing fhicl files ${fcl_files} in ${fhicl_install_dir}")
    _cet_copy_fcl( ${fcl_files} )
    INSTALL ( FILES ${fcl_files}
              DESTINATION ${fhicl_install_dir} )
  endif( fcl_files )
  # now check subdirectories
  if( IFCL_SUBDIRS )
    foreach( sub ${IFCL_SUBDIRS} )
      FILE(GLOB subdir_fcl_files
                ${sub}/[^.]*.fcl )
      if( IFCL_EXCLUDES )
        LIST( REMOVE_ITEM subdir_fcl_files ${IFCL_EXCLUDES} )
      endif()
      if( subdir_fcl_files )
        _cet_copy_fcl( ${subdir_fcl_files} )
        INSTALL ( FILES ${subdir_fcl_files}
                  DESTINATION ${fhicl_install_dir} )
      endif( subdir_fcl_files )
    endforeach(sub)
  endif( IFCL_SUBDIRS )
endmacro( _cet_install_fhicl_without_list )

macro( install_source   )
  cmake_parse_arguments( ISRC "" "" "SUBDIRS;LIST;EXTRAS;EXCLUDES" ${ARGN})
  STRING( REGEX REPLACE "^${CMAKE_SOURCE_DIR}(.*)" "\\1" CURRENT_SUBDIR "${CMAKE_CURRENT_SOURCE_DIR}" )
  set(source_install_dir ${product}/${version}/source/${CURRENT_SUBDIR} )
  #message( STATUS "install_source: source code will be installed in ${source_install_dir}" )
  if( ISRC_LIST )
    if( ISRC_SUBDIRS )
      message( FATAL_ERROR
               "ERROR: call install_source with EITHER LIST or SUBDIRS but not both")
    endif( ISRC_SUBDIRS )
    _cet_install_from_list("${ISRC_LIST}")
  else()
    if( ISRC_EXTRAS )
      _cet_install_from_list("${ISRC_EXTRAS}")
    endif( ISRC_EXTRAS )
    _cet_install_without_list()
  endif()
endmacro( install_source )

macro( install_headers   )
  cmake_parse_arguments( IHDR "" "" "SUBDIRS;LIST;EXTRAS;EXCLUDES" ${ARGN})
  STRING( REGEX REPLACE "^${CMAKE_SOURCE_DIR}(.*)" "\\1" CURRENT_SUBDIR "${CMAKE_CURRENT_SOURCE_DIR}" )
  _cet_check_inc_directory()
  set(header_install_dir ${${product}_inc_dir}${CURRENT_SUBDIR} )
  #message( STATUS "install_headers: headers will be installed in ${header_install_dir}" )
  if( IHDR_LIST )
    if( IHDR_SUBDIRS )
      message( FATAL_ERROR
               "ERROR: call install_headers with EITHER LIST or SUBDIRS but not both")
    endif( IHDR_SUBDIRS )
    _cet_install_header_from_list("${IHDR_LIST}")
  else()
    if( IHDR_EXTRAS )
      _cet_install_header_from_list("${IHDR_EXTRAS}")
    endif( IHDR_EXTRAS )
    _cet_install_header_without_list()
  endif()
endmacro( install_headers )

macro( install_scripts   )
  cmake_parse_arguments( IS "" "" "SUBDIRS;LIST;EXTRAS;EXCLUDES" ${ARGN})
  set(script_install_dir ${${product}_bin_dir} )
  #message( STATUS "install_scripts: scripts will be installed in ${script_install_dir}" )
  if( IS_LIST )
    if( IS_SUBDIRS )
      message( FATAL_ERROR
               "ERROR: call install_scripts with EITHER LIST or SUBDIRS but not both")
    endif( IS_SUBDIRS )
    INSTALL ( PROGRAMS  ${IS_LIST}
              DESTINATION ${script_install_dir} )
  else()
    if( IS_EXTRAS )
      INSTALL ( PROGRAMS  ${IS_EXTRAS}
                DESTINATION ${script_install_dir} )
    endif( IS_EXTRAS )
    _cet_install_script_without_list()
  endif()
endmacro( install_scripts )

macro( install_fhicl   )
  cmake_parse_arguments( IFCL "" "" "SUBDIRS;LIST;EXTRAS;EXCLUDES" ${ARGN})
  set(fhicl_install_dir ${${product}_fcl_dir} )
  #message( STATUS "install_fhicl: fhicl scripts will be installed in ${fhicl_install_dir}" )
  if( IFCL_LIST )
    if( IFCL_SUBDIRS )
      message( FATAL_ERROR
               "ERROR: call install_fhicl with EITHER LIST or SUBDIRS but not both")
    endif( IFCL_SUBDIRS )
    _cet_copy_fcl( ${IFCL_LIST} WORKING_DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}")
    INSTALL ( FILES  ${IFCL_LIST}
              DESTINATION ${fhicl_install_dir} )
  else()
    if( IFCL_EXTRAS )
      _cet_copy_fcl( ${IFCL_EXTRAS} )
      INSTALL ( FILES  ${IFCL_EXTRAS}
                DESTINATION ${fhicl_install_dir} )
    endif( IFCL_EXTRAS )
    _cet_install_fhicl_without_list()
  endif()
endmacro( install_fhicl )

macro( _cet_copy_gdml )
  cmake_parse_arguments( CPGDML "" "SUBDIR;WORKING_DIRECTORY" "LIST" ${ARGN})
  set( mrb_build_dir $ENV{MRB_BUILDDIR} )
  get_filename_component( gdmlpathname ${gdml_install_dir} NAME )
  #message(STATUS "_cet_copy_gdml: copying to mrb ${mrb_build_dir}/${product}/${gdmlpathname} or cet ${CETPKG_BUILD}/${gdmlpathname}")
  if( mrb_build_dir )
    set( gdmlbuildpath ${mrb_build_dir}/${product}/${gdmlpathname} )
  else()
    set( gdmlbuildpath ${CETPKG_BUILD}/${gdmlpathname} )
  endif()
  if( CPGDML_SUBDIR )
    set( gdmlbuildpath "${gdmlbuildpath}/${CPGDML_SUBDIR}" )
  endif( CPGDML_SUBDIR )
  if (CPGDML_WORKING_DIRECTORY)
    cet_copy(${CPGDML_LIST} DESTINATION "${gdmlbuildpath}" WORKING_DIRECTORY "${CPGDML_WORKING_DIRECTORY}")
  else()
    cet_copy(${CPGDML_LIST} DESTINATION "${gdmlbuildpath}")
  endif()
  #message(STATUS "_cet_copy_gdml: copying to ${gdmlbuildpath}")
endmacro( _cet_copy_gdml )

macro( _cet_install_gdml_without_list   )
  #message( STATUS "gdml scripts will be installed in ${gdml_install_dir}" )
  FILE(GLOB gdml_files [^.]*.gdml [^.]*.C [^.]*.xml [^.]*.xsd README )
  if( IGDML_EXCLUDES )
    LIST( REMOVE_ITEM gdml_files ${IGDML_EXCLUDES} )
  endif()
  if( gdml_files )
    #message( STATUS "installing gdml files ${gdml_files} in ${gdml_install_dir}")
    _cet_copy_gdml( LIST ${gdml_files} )
    INSTALL ( FILES ${gdml_files}
              DESTINATION ${gdml_install_dir} )
  endif( gdml_files )
  # now check subdirectories
  if( IGDML_SUBDIRS )
    foreach( sub ${IGDML_SUBDIRS} )
      FILE(GLOB subdir_gdml_files
                ${sub}/[^.]*.gdml  
		${sub}/[^.]*.C 
		${sub}/[^.]*.xml 
		${sub}/[^.]*.xsd 
		${sub}/README
		)
      #message( STATUS "found ${sub} files ${subdir_gdml_files}")
      if( IGDML_EXCLUDES )
        LIST( REMOVE_ITEM subdir_gdml_files ${IGDML_EXCLUDES} )
      endif()
      if( subdir_gdml_files )
        _cet_copy_gdml( LIST ${subdir_gdml_files} SUBDIR ${sub} )
        INSTALL ( FILES ${subdir_gdml_files}
                  DESTINATION ${gdml_install_dir}/${sub} )
      endif( subdir_gdml_files )
    endforeach(sub)
  endif( IGDML_SUBDIRS )
endmacro( _cet_install_gdml_without_list )

macro( install_gdml   )
  cmake_parse_arguments( IGDML "" "" "SUBDIRS;LIST;EXTRAS;EXCLUDES" ${ARGN})
  set(gdml_install_dir ${${product}_gdml_dir} )
  message( STATUS "install_gdml: gdml scripts will be installed in ${gdml_install_dir}" )
  #message( STATUS "install_gdml: IGDML_SUBDIRS is ${IGDML_SUBDIRS}")

  if( IGDML_LIST )
    if( IGDML_SUBDIRS )
      message( FATAL_ERROR
               "ERROR: call install_gdml with EITHER LIST or SUBDIRS but not both")
    endif( IGDML_SUBDIRS )
    _cet_copy_gdml( LIST ${IGDML_LIST} WORKING_DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}")
    INSTALL ( FILES  ${IGDML_LIST}
              DESTINATION ${gdml_install_dir} )
  else()
    if( IGDML_EXTRAS )
      _cet_copy_gdml( LIST ${IGDML_EXTRAS} )
      INSTALL ( FILES  ${IGDML_EXTRAS}
                DESTINATION ${gdml_install_dir} )
    endif( IGDML_EXTRAS )
    _cet_install_gdml_without_list()
  endif()
endmacro( install_gdml )

macro( _cet_copy_fw )
  cmake_parse_arguments( CPFW "" "SUBDIRNAME" "LIST" ${ARGN})
  set( mrb_build_dir $ENV{MRB_BUILDDIR} )
  get_filename_component( fwpathname ${fw_install_dir} NAME )
  #message(STATUS "_cet_copy_fw: copying to mrb ${mrb_build_dir}/${product}/${fwpathname} or cet ${CETPKG_BUILD}/${fwpathname}")
  if( mrb_build_dir )
    set( fwbuildpath ${mrb_build_dir}/${product}/${fwpathname} )
  else()
    set( fwbuildpath ${CETPKG_BUILD}/${fwpathname} )
  endif()
  if( CPFW_SUBDIRNAME )
    set( fwbuildpath ${fwbuildpath}/${CPFW_SUBDIRNAME} )
  endif( CPFW_SUBDIRNAME )
  #message(STATUS "_cet_copy_fw: copying to ${fwbuildpath}")
  cet_copy(${CPFW_LIST} DESTINATION ${fwbuildpath})
endmacro( _cet_copy_fw )

macro( install_fw   )
  cet_parse_args( IFW "" "SUBDIRNAME" "LIST" ${ARGN})
  set( fw_install_dir ${${product}_fw_dir} )
  message( STATUS "install_fw: fw scripts will be installed in ${fw_install_dir}" )

  if( IFW_LIST )
    _cet_copy_fw( ${ARGN} )
    # going to loose subdirectory information here
    if ( SUBDIRNAME )
      INSTALL ( FILES  ${IFW_LIST}
                DESTINATION ${fw_install_dir}/${IFW_ SUBDIRNAME} )
    else()
      INSTALL ( FILES  ${IFW_LIST}
                DESTINATION ${fw_install_dir} )
    endif()
  else()
      message( FATAL_ERROR "ERROR: install_fw has no defaults, you must use LIST")
  endif()
endmacro( install_fw )
