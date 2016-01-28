# define the environment for a ups product
#
# find_ups_product( PRODUCTNAME [version] )
#  PRODUCTNAME - product name
#  version - optional minimum version
#
# cet_cmake_config() will put ${PRODUCTNAME}Config.cmake in
#  $ENV{${PRODUCTNAME_UC}_FQ_DIR}/lib/${PRODUCTNAME}/cmake or $ENV{${PRODUCTNAME_UC}_DIR}/cmake
# check these directories for allowed cmake configure files:
# either ${PRODUCTNAME_LC}-config.cmake  or ${PRODUCTNAME}Config.cmake
# call find_package() if we find the config file
# if the config file is not found, call _check_version()

include(CheckUpsVersion)

# - Internal find_package wrapper
macro(_use_find_package PNAME PNAME_UC)
  cmake_parse_arguments(UFP "" "" "" ${ARGN})
  set(dotver "")
  if(UFP_UNPARSED_ARGUMENTS)
    list(GET UFP_UNPARSED_ARGUMENTS 0 PVER)
    _get_dotver(${PVER})
  endif()

  set(${PNAME}_SAVE_VERSION ${${PNAME_UC}_VERSION})

  # we use find package to check the version
  # define the cmake search path
  set(${PNAME_UC}_SEARCH_PATH $ENV{${PNAME_UC}_FQ_DIR})

  if(NOT ${PNAME_UC}_SEARCH_PATH)
    find_package(${PNAME} ${dotver} PATHS $ENV{${PNAME_UC}_DIR})
  else()
    find_package(${PNAME} ${dotver} PATHS $ENV{${PNAME_UC}_FQ_DIR})
  endif()

  # make sure we found the product
  if(NOT ${${PNAME}_FOUND})
    message(FATAL_ERROR "ERROR: ${PNAME} was NOT found ")
  endif()

  set(${PNAME}_DOT_VERSION ${${PNAME}_VERSION})

  if(${PNAME_UC} STREQUAL ${PNAME})
    set(${PNAME_UC}_VERSION ${${PNAME}_SAVE_VERSION})
  endif()

  # make sure the version numbers match
  if(${${PNAME_UC}_VERSION} MATCHES ${${PNAME}_UPS_VERSION})
    #message(STATUS "${PNAME} versions match: ${${PNAME_UC}_VERSION} ${${PNAME}_UPS_VERSION} ")
  else()
    message(STATUS "ERROR: There is an inconsistency between the ${PNAME} table and config files ")
    message(FATAL_ERROR "${PNAME} versions DO NOT match: ${${PNAME_UC}_VERSION} ${${PNAME}_UPS_VERSION} ")
  endif()
endmacro()

# - Internal find_package wrapper
macro(_use_find_package_noversion PNAME PNAME_UC)
  # we use find package to check the version
  # however, if we have some special build such as "nightly", we cannot compare version numbers
  # define the cmake search path
  set(${PNAME_UC}_SEARCH_PATH $ENV{${PNAME_UC}_FQ_DIR})
  if(NOT ${PNAME_UC}_SEARCH_PATH)
    find_package(${PNAME} PATHS $ENV{${PNAME_UC}_DIR})
  else()
    find_package(${PNAME} PATHS $ENV{${PNAME_UC}_FQ_DIR})
  endif()

  # make sure we found the product
  if(NOT ${${PNAME}_FOUND})
    message(FATAL_ERROR "ERROR: ${PNAME} was NOT found ")
  endif()

  # make sure the version numbers match
  if(${${PNAME_UC}_VERSION} MATCHES ${${PNAME}_UPS_VERSION})
    #message(STATUS "_use_find_package_noversion: ${PNAME} versions match: ${${PNAME_UC}_VERSION} ${${PNAME}_UPS_VERSION} ")
  else()
    message(STATUS "ERROR: _use_find_package_noversion: There is an inconsistency between the ${PNAME} table and config files ")
    message(FATAL_ERROR "${PNAME} versions DO NOT match: ${${PNAME_UC}_VERSION} ${${PNAME}_UPS_VERSION} ")
  endif()
endmacro()

#- find_up_product implementation
# since variables are passed, this is implemented as a macro
macro(find_ups_product PRODUCTNAME)
  # if ${PRODUCTNAME}_UPS_VERSION is already defined, there is nothing to do
  if(${PRODUCTNAME}_UPS_VERSION)
    ##message( STATUS "find_ups_product debug: ${PRODUCTNAME}_UPS_VERSION ${${PRODUCTNAME}_UPS_VERSION} is defined" )
  else()
    cmake_parse_arguments(FUP "" "" "" ${ARGN})
    set(fup_version "")
    if(FUP_UNPARSED_ARGUMENTS)
      list(GET FUP_UNPARSED_ARGUMENTS 0 fup_version)
    endif()

    # get upper and lower case versions of the name
    string(TOUPPER  ${PRODUCTNAME} ${PRODUCTNAME}_UC)
    string(TOLOWER  ${PRODUCTNAME} ${PRODUCTNAME}_LC)

    # require ${${PRODUCTNAME}_UC}_VERSION or ${${PRODUCTNAME}_UC}_UPS_VERSION
    set(${${PRODUCTNAME}_UC}_VERSION $ENV{${${PRODUCTNAME}_UC}_VERSION})

    if(NOT ${${PRODUCTNAME}_UC}_VERSION)
      set(${${PRODUCTNAME}_UC}_VERSION $ENV{${${PRODUCTNAME}_UC}_UPS_VERSION})

      if(NOT ${${PRODUCTNAME}_UC}_VERSION)
        message(FATAL_ERROR "${${PRODUCTNAME}_UC} has not been setup")
      endif()
    endif()

    # compare for recursion
    list(FIND cet_product_list ${PRODUCTNAME} found_product_match)

    # now check to see if this product is labeled only_for_build
    set(PRODUCT_ONLY_FOR_BUILD FALSE)
    cet_get_product_info_item(ONLY_FOR_BUILD only_for_build_products)
    foreach(pkg ${only_for_build_products})
      if(${PRODUCTNAME} MATCHES "${pkg}")
        set(PRODUCT_ONLY_FOR_BUILD TRUE)
      endif()
    endforeach()

    if(PRODUCT_ONLY_FOR_BUILD)
    elseif(${found_product_match} LESS 0)
      # add to product list
      set(CONFIG_FIND_UPS_COMMANDS "${CONFIG_FIND_UPS_COMMANDS}
      find_ups_product( ${PRODUCTNAME} ${fup_version} )")
      set(cet_product_list ${PRODUCTNAME} ${cet_product_list} )
    endif()

    # MUST use a unique variable name for the config path
    find_file(${${PRODUCTNAME}_UC}_CONFIG_PATH
      NAMES ${${PRODUCTNAME}_LC}-config.cmake  or ${PRODUCTNAME}Config.cmake
      PATHS $ENV{${${PRODUCTNAME}_UC}_FQ_DIR}/lib/${PRODUCTNAME}/cmake $ENV{${${PRODUCTNAME}_UC}_DIR}/cmake
      )

    if(${${PRODUCTNAME}_UC}_CONFIG_PATH)
      # look for the case where there are no underscores
      string(REGEX MATCHALL "_" nfound ${${${PRODUCTNAME}_UC}_VERSION})
      list(LENGTH nfound nfound)
      if(${nfound} EQUAL 0)
        _use_find_package_noversion(${PRODUCTNAME} ${${PRODUCTNAME}_UC})
      else()
        _use_find_package(${PRODUCTNAME} ${${PRODUCTNAME}_UC} ${fup_version})
      endif()
    else()
      _check_version( ${PRODUCTNAME} ${${${PRODUCTNAME}_UC}_VERSION} ${fup_version} )
    endif()

    # add include directory to include path if it exists
    set(${${PRODUCTNAME}_UC}_INC $ENV{${${PRODUCTNAME}_UC}_INC})
    if(NOT ${${PRODUCTNAME}_UC}_INC)
      #message(STATUS "find_ups_product: ${PRODUCTNAME} ${${PRODUCTNAME}_UC} has no ${${PRODUCTNAME}_UC}_INC")
    else()
      include_directories(${${${PRODUCTNAME}_UC}_INC})
    endif()
  endif()
endmacro()

