cmake_minimum_required (VERSION 3.8.2)

if (DEFINED CMAKE_BUILD_TYPE AND NOT CMAKE_BUILD_TYPE STREQUAL "")
   set(CMAKE_BUILD_TYPE ${CMAKE_BUILD_TYPE} CACHE STRING "Choose the type of build, options are: None(CMAKE_CXX_FLAGS or CMAKE_C_FLAGS used) Debug Release RelWithDebInfo MinSizeRel.")
else()
   set(CMAKE_BUILD_TYPE Release CACHE STRING "Choose the type of build, options are: None(CMAKE_CXX_FLAGS or CMAKE_C_FLAGS used) Debug Release RelWithDebInfo MinSizeRel." FORCE)
endif()

project(XLiFE++-user NONE)
enable_language(CXX)

# Variables provided by XLiFE++ installation
set(XLIFEPP_DIR "/home/tmougin/xlifepp-sources-v2.3-2022-04-22")
set(LAPACK XLIFEPP_WITHOUT_LAPACK)
set(BLAS XLIFEPP_WITHOUT_BLAS)
set(ARPACK XLIFEPP_WITHOUT_ARPACK)
set(UMFPACK XLIFEPP_WITHOUT_UMFPACK)
set(OMP XLIFEPP_WITH_OMP)
set(EIGEN XLIFEPP_WITH_EIGEN)
set(AMOS XLIFEPP_WITH_AMOS)
set(OPENCASCADE XLIFEPP_WITHOUT_OPENCASCADE)
set(MAGMA XLIFEPP_WITHOUT_MAGMA)
set(METIS XLIFEPP_WITHOUT_METIS)
set(MPI XLIFEPP_WITHOUT_MPI)
set(FORTRAN_LIB_DIR " ")
set(FORTRAN_LIB " ")
set(XLIFEPP_INFO_TXT_DIR "/home/tmougin/xlifepp-sources-v2.3-2022-04-22/lib/x86_64-linux/g++-11/omp/Release")

# global environment stuff
include(${XLIFEPP_DIR}/cmake/xlifeppUtils.cmake)
guessCompiler(XLIFEPP_CXX_COMPILER XLIFEPP_CXX_REAL_COMPILER XLIFEPP_CXX_COMPILER_VERSION ${CMAKE_CXX_COMPILER})
string(TOLOWER ${CMAKE_SYSTEM_NAME} system_name)
set(exe exec-${CMAKE_SYSTEM_PROCESSOR}-${system_name}-${XLIFEPP_CXX_COMPILER}-${CMAKE_BUILD_TYPE})

set(CMAKE_MODULE_PATH ${CMAKE_MODULE_PATH} "${XLIFEPP_DIR}/cmake/modules")

option(XLIFEPP_FROM_SRCS "Is XLiFE++ installed from sources ? (ON, OFF)" ON)

############## management of options ##############

##### OMP -> XLIFEPP_WITH_OMP or XLIFEPP_WITHOUT_OMP
set(OMP_DEFAULT OFF)
if (${OMP} STREQUAL "XLIFEPP_WITH_OMP")
  set(OMP_DEFAULT ON)
endif()
option(ENABLE_OMP "Enable OPENMP (ON, OFF)" ${OMP_DEFAULT})

set(OMP XLIFEPP_WITHOUT_OMP)
if (ENABLE_OMP)
  message(STATUS "OpenMP is used")
  find_package(OpenMP)
  if (OPENMP_FOUND)
    set(OMP XLIFEPP_WITH_OMP)
    set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} ${OpenMP_CXX_FLAGS}")
    mark_as_advanced(CLEAR OpenMP_CXX_FLAGS)
    if (OpenMP_EXE_LINKER_FLAGS)
      set(CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} ${OpenMP_EXE_LINKER_FLAGS}")
    endif(OpenMP_EXE_LINKER_FLAGS)
    if (NOT ${XLIFEPP_CXX_COMPILER} STREQUAL "clang++")
        include_directories(${OpenMP_CXX_INCLUDE_DIRS})
        list(APPEND libexts ${OpenMP_CXX_LIBRARIES})
    else()
      set(OMP XLIFEPP_WITHOUT_OMP)
      message(STATUS "Native clang++ does not work properly with OpenMP ! It is disabled")
    endif()
  else()
    message(STATUS "###### OpenMP is not supported !")
  endif()
else()
  message(STATUS "OpenMP is not used")
endif()

############ getting XLiFE++ libraries ############
set(parDir seq)
if (XLIFEPP_FROM_SRCS)
  # checking asked compiler
  set(XLIFEPP_LIB_ROOTDIR ${XLIFEPP_DIR}/lib/${CMAKE_SYSTEM_PROCESSOR}-${system_name})
  file(GLOB compilers RELATIVE ${XLIFEPP_LIB_ROOTDIR} ${XLIFEPP_LIB_ROOTDIR}/*)
  list(FIND compilers ${XLIFEPP_CXX_COMPILER} compiler_index)
  if (${compiler_index} STREQUAL "-1")
    list(APPEND error_message "XLiFE++ was not compiled with ${XLIFEPP_CXX_COMPILER} ! Please compile XLiFE++ with this compiler or chose one of the following :")
    foreach (ci IN LISTS compilers)
      list(APPEND error_message " ")
      list(APPEND error_message ${ci})
    endforeach()
    message(FATAL_ERROR ${error_message})
  else()
    message(STATUS "XLiFE++ was compiled with ${XLIFEPP_CXX_COMPILER}")
  endif()

  # checking parallel mode (sequential or with OpenMP)
  set(XLIFEPP_LIB_ROOTDIRC ${XLIFEPP_LIB_ROOTDIR}/${XLIFEPP_CXX_COMPILER})
  file(GLOB parModes RELATIVE ${XLIFEPP_LIB_ROOTDIRC} ${XLIFEPP_LIB_ROOTDIRC}/*)
  set(parMode_text "without OpenMP")
  if (${OMP} STREQUAL XLIFEPP_WITH_OMP)
    set(parDir omp)
    set(parMode_text "with OpenMP")
  endif()
  list(FIND parModes ${parDir} parMode_index)
  if (${parMode_index} STREQUAL "-1")
    message(FATAL_ERROR "XLiFE++ was not compiled ${parMode_text} ! Please compile XLiFE++ with this configuration or choose the other one")
  else()
    message(STATUS "XLiFE++ was compiled ${parMode_text}")
  endif()

  if (${OMP} STREQUAL XLIFEPP_WITH_OMP)
    set(XLIFEPP_LIB_ROOTDIROMP ${XLIFEPP_LIB_ROOTDIR}/${XLIFEPP_CXX_COMPILER}/omp)
  endif()

  # checking asked CMAKE_BUILD_TYPE
  set(XLIFEPP_LIB_ROOTDIRPM ${XLIFEPP_LIB_ROOTDIRC}/${parDir})
  file(GLOB modes RELATIVE ${XLIFEPP_LIB_ROOTDIRPM} ${XLIFEPP_LIB_ROOTDIRPM}/*)
  list(FIND modes ${CMAKE_BUILD_TYPE} mode_index)
  if (${mode_index} STREQUAL "-1")
    list(APPEND error_message "XLiFE++ was not compiled in ${CMAKE_BUILD_TYPE} mode ! Please compile XLiFE++ in this mode or choose one of the following :")
    foreach (mi IN LISTS modes)
      list(APPEND error_message " ")
      list(APPEND error_message ${mi})
    endforeach()
    message(FATAL_ERROR ${error_message})
  else()
    message(STATUS "XLiFE++ was compiled in ${CMAKE_BUILD_TYPE} mode")
  endif()

  # when XLiFE++ is compiled from sources, we have to include header files in src directory
  include_directories(${XLIFEPP_DIR}/src/)

  # checking library files
  set(XLIFEPP_LIB_DIR ${XLIFEPP_LIB_ROOTDIRPM}/${CMAKE_BUILD_TYPE})
else()
  set(XLIFEPP_LIB_DIR ${XLIFEPP_DIR}/lib)
endif()

file(GLOB libs ${XLIFEPP_LIB_DIR}/*xlifepp_*)

if (libs STREQUAL "")
  message(FATAL_ERROR "No libs to link with in " ${XLIFEPP_LIB_DIR})
else()
  message(STATUS "XLiFE++ libraries found !")
endif()

include_directories(${XLIFEPP_DIR}/include/)

############ management of external libraries ############

set(XLIFEPP_USR_WITH_LIBGFORTRAN TRUE)

if (${ARPACK} STREQUAL XLIFEPP_WITH_ARPACK)
  # if XLiFE++ is installed with ARPACK, we need to link to the libraries
  # Lapack and blas are already appended
  message(STATUS "Arpack is used")
  list(APPEND libexts " ")
  set(XLIFEPP_USR_WITH_LIBGFORTRAN TRUE)
else()
  message(STATUS "Arpack is not used")
  list(REMOVE_ITEM libs ${XLIFEPP_LIB_DIR}/libxlifepp_arpackppSupport.a)
endif()

if (${UMFPACK} STREQUAL XLIFEPP_WITH_UMFPACK)
  # if XLiFE++ is installed with UMFPACK, we need to link to the libraries
  # Lapack and blas are already appended
  message(STATUS "Umfpack is used")
  list(APPEND libexts "")
  set(XLIFEPP_USR_WITH_LIBGFORTRAN TRUE)
else()
  message(STATUS "Umfpack is not used")
  list(REMOVE_ITEM libs ${XLIFEPP_LIB_DIR}/libxlifepp_umfpackSupport.a)
endif()

if (${LAPACK} STREQUAL XLIFEPP_WITH_LAPACK)
  # if XLiFE++ is installed with lapack libraries, we need to link to the libraries
  message(STATUS "LAPACK is used")
  list(APPEND libexts " ")
else()
  message(STATUS "LAPACK is not used")
endif()

if (${BLAS} STREQUAL XLIFEPP_WITH_BLAS)
  # if XLiFE++ is installed with blas libraries, we need to link to the libraries
  message(STATUS "BLAS is used")
  list(APPEND libexts " ")
else()
  message(STATUS "BLAS is not used")
endif()

if (${EIGEN} STREQUAL XLIFEPP_WITH_EIGEN)
  include_directories("/home/tmougin/xlifepp-sources-v2.3-2022-04-22/ext/Eigen/Eigen")
endif()

if (${AMOS} STREQUAL XLIFEPP_WITH_AMOS)
  # if XLiFE++ is installed with amos libraries, we need to link to the libraries
  message(STATUS "AMOS is used")
  list(APPEND libexts "/home/tmougin/xlifepp-sources-v2.3-2022-04-22/lib/x86_64-linux/g++-11/omp/Release/libamos.a")
else()
  message(STATUS "AMOS is not used")
endif()

if (${OPENCASCADE} STREQUAL XLIFEPP_WITH_OPENCASCADE)
  # if XLiFE++ is installed with OpenCASCADE, we need to link to the libraries
  find_package(XLIFEPP_OPENCASCADE)
  if (XLIFEPP_OPENCASCADE_FOUND)
    message(STATUS "OpenCASCADE is used")
    message(STATUS "Found OpenCASCADE : ${XLIFEPP_OPENCASCADE_DIR}")
    set(OPENCASCADE XLIFEPP_WITH_OPENCASCADE)
    include_directories(${XLIFEPP_OPENCASCADE_INCLUDE_DIR})
    foreach (occlib ${XLIFEPP_OPENCASCADE_LIBRARIES})
      list(APPEND libexts ${occlib})
    endforeach()
  else()
    message(STATUS "OpenCASCADE is not used")
  endif()
else()
  message(STATUS "OpenCASCADE is not used")
endif()

if (${MAGMA} STREQUAL XLIFEPP_WITH_MAGMA)
  # if XLiFE++ is installed with Magma libraries, we need to link to the libraries
  message(STATUS "Magma is used")
  list(APPEND libexts "")
  include_directories("")
else()
  message(STATUS "Magma is not used")
endif()

if (${METIS} STREQUAL XLIFEPP_WITH_METIS AND ${UMFPACK} STREQUAL XLIFEPP_WITHOUT_UMFPACK)
  # if XLiFE++ is installed with Metis libraries, we need to link to the libraries
  message(STATUS "Metis is used")
  list(APPEND libexts "")
  include_directories("")
else()
  message(STATUS "Metis is not used")
endif()

if (${MPI} STREQUAL XLIFEPP_WITH_MPI)
  # if XLiFE++ is installed with MPI libraries, we need to link to the libraries
  message(STATUS "MPI is used")
  list(APPEND libexts "")
  include_directories("")
else()
  message(STATUS "MPI is not used")
endif()

if (XLIFEPP_USR_WITH_LIBGFORTRAN)
  if (${FORTRAN_LIB} STREQUAL " ")
    list(APPEND libexts "-lgfortran")
    if (NOT ${FORTRAN_LIB_DIR} STREQUAL " ")
      get_filename_component(FORTRAN_LIB_DIR "${FORTRAN_LIB_DIR}" REALPATH)
      list(APPEND libexts "-L\"${FORTRAN_LIB_DIR}\"")
    endif()
  else()
    list(APPEND libexts "${FORTRAN_LIB}")
  endif()
endif()

# getting path to setup.hpp to include it
file(STRINGS "${XLIFEPP_INFO_TXT_DIR}/info.txt" infoLines)
foreach (infoLine IN LISTS infoLines)
  string(FIND ${infoLine} "=" equalIndex)
  math(EXPR keyLength ${equalIndex}-1)
  math(EXPR valStartIndex ${equalIndex}+1)
  string(SUBSTRING ${infoLine} 0 ${keyLength} infoKey)
  string(SUBSTRING ${infoLine} ${valStartIndex} -1 infoValue)
  if (infoKey STREQUAL "BUILD_PATH")
    cleanPathWithBlankSpaces(infoValue ${infoValue})
    include_directories(${infoValue})
  endif()
endforeach()

# adding specific flags to avoid tons of useless warnings due to bugs in MinGW-W64 8.x
if (WIN32)
  string(FIND ${XLIFEPP_CXX_COMPILER} "g++.exe-" GPPEXEINDEX)
  if (NOT ${GPPEXEINDEX} STREQUAL "-1")
    math(EXPR GPPEXEINDEX ${GPPEXEINDEX}+8)
    string(SUBSTRING ${XLIFEPP_CXX_COMPILER} ${GPPEXEINDEX} -1 GPPEXEVERSION)
    if (${GPPEXEVERSION} VERSION_GREATER_EQUAL "7.0")
      set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -Wno-attributes" CACHE STRING "compile flags" FORCE)
      set(CMAKE_CXX_STANDARD_LIBRARIES "${CMAKE_CXX_STANDARD_LIBRARIES} -lquadmath" CACHE STRING "Libraries linked by default with all C++ applications." FORCE)
    endif()
  endif()
endif()

if (EXISTS "${CMAKE_SOURCE_DIR}/userprefs.cmake")
  include("${CMAKE_SOURCE_DIR}/userprefs.cmake")
endif()

if (XLIFEPP_FROM_SRCS)
  add_custom_target(checklock ALL COMMAND ${CMAKE_COMMAND} -DSOURCE_DIR=${XLIFEPP_DIR} -DCMAKE_CXX_COMPILER=${XLIFEPP_CXX_COMPILER} -DCMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE} -DPARMODE=${parDir} -P ${XLIFEPP_DIR}/cmake/lock.cmake)
endif()

set(CMAKE_EXPORT_COMPILE_COMMANDS ON CACHE INTERNAL "")

file(GLOB srcs RELATIVE ${CMAKE_SOURCE_DIR} *.cpp *.cc *.c++)
add_executable(${exe} ${srcs})
target_compile_features(${exe} PUBLIC cxx_std_11)

if (XLIFEPP_FROM_SRCS)
  add_dependencies(${exe} checklock)
endif()
target_link_libraries(${exe} ${libs} ${libs} ${libs} ${libexts})
