#! /bin/sh

# Global variables and options
defineGlobals()
{
  XLIFEPP_DIR="/home/tmougin/xlifepp-sources-v2.3-2022-04-22"
  XLIFEPP_ARCH="x86_64-linux"
  XLIFEPP_VERSION="???"
  XLIFEPP_DATE="???"
  XLIFEPP_DOC_VIEWER="acroread"
  XLIFEPP_DOC_TYPE=""
  XLIFEPP_BUILD=1
  XLIFEPP_BUILD_CHECK_DIRECTORY=1
  XLIFEPP_BUILD_CHECK_DIRECTORY_TMP=1
  XLIFEPP_BUILD_CXX_COMPILER="g++-11"
  XLIFEPP_BUILD_CXX_COMPILER_TMP="g++-11"
  XLIFEPP_BUILD_CXX_REAL_COMPILER="/usr/bin/x86_64-linux-gnu-g++-11"
  XLIFEPP_BUILD_CXX_REAL_COMPILER_TMP="/usr/bin/x86_64-linux-gnu-g++-11"
  XLIFEPP_BUILD_INTERACTIVE=1
  XLIFEPP_BUILD_GENERATE=1
  XLIFEPP_BUILD_GENERATE_TMP=1
  XLIFEPP_BUILD_DIRECTORY=.
  XLIFEPP_BUILD_DIRECTORY_TMP=.
  XLIFEPP_BUILD_TYPE="Release"
  XLIFEPP_BUILD_TYPE_TMP="Release"
  XLIFEPP_BUILD_WITH_FILE="None"
  XLIFEPP_BUILD_WITH_FILE_TMP="None"
  XLIFEPP_BUILD_WITH_OMP=1
  XLIFEPP_BUILD_WITH_OMP_TMP=1
  XLIFEPP_BUILD_GENERATOR="Unix Makefiles"
  XLIFEPP_BUILD_GENERATOR_TMP="Unix Makefiles"
  XLIFEPP_VERBOSE_LEVEL=1
  XLIFEPP_CMAKE_CMD="/usr/bin/cmake"
  XLIFEPP_FROM_SRCS="ON"
  XLIFEPP_USR_CMAKELISTS_PATH="/home/tmougin/xlifepp-sources-v2.3-2022-04-22/build"
  XLIFEPP_INFO_TXT_DIR="/home/tmougin/xlifepp-sources-v2.3-2022-04-22/lib/x86_64-linux/g++-11/omp/Release"
  XLIFEPP_INFO_TXT_DIR_TMP="/home/tmougin/xlifepp-sources-v2.3-2022-04-22/lib/x86_64-linux/g++-11/omp/Release"
}

# Parsing options
parsargs()
{
  while test "$1" != ""
  do
    case "$1" in
      "--build" | "-b")
        XLIFEPP_BUILD=1
        shift
        ;;
      "--build-type" | "-bt")
        shift
        XLIFEPP_BUILD_TYPE_TMP=$1
        shift
        ;;
      "--check")
        XLIFEPP_BUILD_CHECK_DIRECTORY_TMP=1
        shift
        ;;
      "--cxx-compiler" | "-cxx")
        shift
        XLIFEPP_BUILD_CXX_COMPILER_TMP=$1
        shift
        ;;
      "--directory" | "-d")
        shift
        XLIFEPP_BUILD_DIRECTORY_TMP=$1
        shift
        ;;
      "--doc")
        shift
        XLIFEPP_DOC_TYPE=$1
        shift
        ;;
      "--doc-viewer")
        shift
        XLIFEPP_DOC_VIEWER=$1
        shift
        ;;
      "--generate" | "-g")
        XLIFEPP_BUILD_GENERATE=1
        shift
        ;;
      "--generator-name" | "-gn")
        shift
        XLIFEPP_BUILD_GENERATOR_TMP=$1
        shift
        ;;
      "--help" | "-h")
        printHelp
        exit 1
        ;;
      "--interactive" | "-i")
        XLIFEPP_BUILD_INTERACTIVE=1
        shift
        ;;
      "--info-dir" | "-id")
        shift
        XLIFEPP_INFO_TXT_DIR_TMP=$1
        shift
        ;;
      "--main-file" | "-f")
        shift
        XLIFEPP_BUILD_WITH_FILE_TMP=$1
        shift
        ;;
      "--non-interactive" | "-noi")
        XLIFEPP_BUILD_INTERACTIVE=0
        shift
        ;;
      "--no-generate" | "-nog")
        XLIFEPP_BUILD_GENERATE=0
        shift
        ;;
      "--no-main-file" | "-nof")
        XLIFEPP_BUILD_WITH_FILE_TMP="None"
        shift
        ;;
      "--verbose-level" | "-vl")
        shift
        XLIFEPP_VERBOSE_LEVEL=$1
        shift
        ;;
      "--version" | "-v")
        printVersion
        exit 1
        ;;
      "--with-omp" | "-omp")
        XLIFEPP_BUILD_WITH_OMP_TMP=1
        shift
        ;;
      "--without-omp" | "-nomp")
        XLIFEPP_BUILD_WITH_OMP_TMP=0
        shift
        ;;
      -*)
        # We forbid unknown options
        echo ""
        echo "Unknown option : $1"
        echo ""
        printHelp
        exit 1
        ;;
      *)
        # We forbid unknown arguments
        echo ""
        echo "Unknown parameter : $1"
        echo ""
        printHelp
        exit 1
        ;;
    esac
  done
 
  openDocumentation
  
  if test $XLIFEPP_BUILD_INTERACTIVE -eq 0
  then
    XLIFEPP_BUILD_DIRECTORY=$XLIFEPP_BUILD_DIRECTORY_TMP
    XLIFEPP_BUILD_CHECK_DIRECTORY=$XLIFEPP_BUILD_CHECK_DIRECTORY_TMP
    XLIFEPP_BUILD_CXX_COMPILER=$XLIFEPP_BUILD_CXX_COMPILER_TMP
    XLIFEPP_BUILD_CXX_REAL_COMPILER=$XLIFEPP_BUILD_CXX_REAL_COMPILER_TMP
    XLIFEPP_BUILD_TYPE=$XLIFEPP_BUILD_TYPE_TMP
    XLIFEPP_BUILD_GENERATOR=$XLIFEPP_BUILD_GENERATOR_TMP
    XLIFEPP_BUILD_WITH_FILE=$XLIFEPP_BUILD_WITH_FILE_TMP
    XLIFEPP_BUILD_WITH_OMP=$XLIFEPP_BUILD_WITH_OMP_TMP
    XLIFEPP_INFO_TXT_DIR=$XLIFEPP_INFO_TXT_DIR_TMP

    if test $XLIFEPP_VERBOSE_LEVEL -ge 2
    then
      echo "Parsing arguments:"
      echo "- Project directory: $XLIFEPP_BUILD_DIRECTORY"
      echo "- Cxx compiler: $XLIFEPP_BUILD_CXX_COMPILER"
      echo "- CMake build type: $XLIFEPP_BUILD_TYPE"
      if test $XLIFEPP_BUILD_GENERATE -eq 0
      then
        echo "- Run CMake ? No"
      else
        echo "- Run CMake ? Yes"
      fi
      if test $XLIFEPP_BUILD_WITH_OMP -eq 0
      then
        echo "- Compile with OpenMP flag ? No"
      else
        echo "- Compile with OpenMP flag ? Yes"
      fi
      echo "- CMake IDE generator: $XLIFEPP_BUILD_GENERATOR"
      if test $XLIFEPP_BUILD_WITH_FILE = "None"
      then
        echo "- Copy main file ? No"
      else
        echo "- Copy main file ? Yes ($XLIFEPP_BUILD_WITH_FILE)"
      fi
    fi
  fi
}

printVersion()
{
  echo "OVERVIEW: XLiFE++ user script"
  echo "VERSION: $XLIFEPP_VERSION"
  echo "DATE: $XLIFEPP_DATE"
}

printHelp()
{
  printVersion
  echo ""
  echo "USAGE:"
  echo "    xlifepp.sh --build [--interactive] [(--generate|--no-generate)]"
  echo "    xlifepp.sh --build --non-interactive [(--generate|--no-generate)]"
  echo "                       [--compiler <compiler>] [--directory <dir>]"
  echo "                       [--generator-name <generator>]"
  echo "                       [--build-type <build-type>]"
  echo "                       [(--with-omp|--without-omp)]"
  echo "    xlifepp.sh --help"
  echo "    xlifepp.sh --version"
  echo ""
  echo "MAIN OPTIONS:"
  echo "    --build, -b               copy cmake files and eventually sample of"
  echo "                              main file"
  echo "                              and run cmake on it to prepare your so-called"
  echo "                              project directory. This is the default"
  echo "    --check                   check project directory (outside of XLiFE++ home directory)"
  echo "    --doc <doctype>           display <doctype> documentation. <doctype> can be user,"
  echo "                              dev, install, examples or tutorial"
  echo "    --doc-viewer <exe>        set the viewer to use to display documentation."
  echo "                              Default is acroread"
  echo "    --check                   check project directory (outside of XLiFE++ home directory)"
  echo "    --generate, -g            generate the project. Used with --build option."
  echo "                              This is the default."
  echo "    --help, -help, -h         show the current help"
  echo "    --interactive, -i         run xlifepp in interactive mode. Used with"
  echo "                              --build option. This is the default"
  echo "    --non-interactive, -noi   run xlifepp in non interactive mode. Used with"
  echo "                              --build option"
  echo "    --no-generate, -nog       prevent generation of your project. You will"
  echo "                              do it yourself."
  echo "    --version, -v             print version number of XLiFE++ and its date"
  echo "    --verbose-level <value>,  set the verbose level. Default value is 1"
  echo "    -vl <value>"
  echo ""
  echo "OPTIONS FOR BUILD IN NON INTERACTIVE MODE:"
  echo "    --build-type <value>,     set cmake build type (Debug, Release, ...)."
  echo "    -bt <value>"
  echo "    --cxx-compiler <value>,   set the C++ compiler to use."
  echo "    -cxx <value>"
  echo "    --directory <dir>,        set the directory where you want to build"
  echo "    -d <dir>                  your project"
  echo "    --generator-name <name>,  set the cmake generator."
  echo "    -gn <name>"
  echo "    -f <filename>,            copy <filename> as a main file for the user"
  echo "    --main-file <filename>    project."
  echo "    --info-dir, -id           set the directory where the info.txt file is"
  echo "    -nof,                     do not copy the sample main.cpp file. This is"
  echo "    --no-main-file            the default."
  echo "    --with-omp, -omp          activates OpenMP mode"
  echo "    --without-omp, -nomp      deactivates OpenMP mode"
}

openDocumentation()
{
  case "$XLIFEPP_DOC_TYPE" in
    "user")
      $XLIFEPP_DOC_VIEWER "$XLIFEPP_DIR/doc/tex/user_documentation.pdf"
      exit 1
      ;;
    "dev")
      $XLIFEPP_DOC_VIEWER "$XLIFEPP_DIR/doc/tex/dev_documentation.pdf"
      exit 1
      ;;
    "tutorial")
      $XLIFEPP_DOC_VIEWER "$XLIFEPP_DIR/doc/tex/tutorial.pdf"
      exit 1
      ;;
    "examples")
      $XLIFEPP_DOC_VIEWER "$XLIFEPP_DIR/doc/tex/examples.pdf"
      exit 1
      ;;
    "install")
      $XLIFEPP_DOC_VIEWER "$XLIFEPP_DIR/doc/tex/install.pdf"
      exit 1
      ;;
    *)
      # we ignore other values
      ;;
  esac
}

xlifepp_build_project()
{
  if test $XLIFEPP_BUILD_INTERACTIVE -eq 1
  then
    echo "Project directory (default is current directory):"
    read project_dir
    if test -z $project_dir
    then
      project_dir=$(pwd)
    fi
  else
    project_dir=$XLIFEPP_BUILD_DIRECTORY
  fi

  if test -d $project_dir
  then
    if test $XLIFEPP_VERBOSE_LEVEL -ge 1
    then
      echo "$project_dir exists"
    fi
  fi

  XLIFEPP_PROJECTDIR_TEST=`echo $project_dir | grep -c $XLIFEPP_DIR/`
  
  if test $XLIFEPP_PROJECTDIR_TEST -ne 0
  then
    echo "A project directory cannot be inside $XLIFEPP_DIR (XLiFE++ home directory) ! Abort"
    exit
  fi

  if test ! -d $project_dir
  then
    if test $XLIFEPP_VERBOSE_LEVEL -ge 1
    then
      echo "$project_dir does not exist. We create it !"
    fi
    mkdir -p "$project_dir"
  fi

  if test $XLIFEPP_BUILD_INTERACTIVE -eq 1
  then
    echo "The following generators are available on this platform:"
    echo "1 -> Green Hills MULTI"
    echo "2 -> Unix Makefiles"
    echo "3 -> Ninja"
    echo "4 -> Ninja Multi-Config"
    echo "5 -> Watcom WMake"
    echo "6 -> CodeBlocks - Ninja"
    echo "7 -> CodeBlocks - Unix Makefiles"
    echo "8 -> CodeLite - Ninja"
    echo "9 -> CodeLite - Unix Makefiles"
    echo "10 -> Eclipse CDT4 - Ninja"
    echo "11 -> Eclipse CDT4 - Unix Makefiles"
    echo "12 -> Kate - Ninja"
    echo "13 -> Kate - Unix Makefiles"
    echo "14 -> Sublime Text 2 - Ninja"
    echo "15 -> Sublime Text 2 - Unix Makefiles"
    printf "Your choice (default is 1): "
    read answer
    case $answer in
      1|2|3|4|5|6|7|8|9|10|11|12|13|14|15)
        ;;
      "")
        answer=1
        ;;
      *)
        echo "$answer is not between 1 and 15 !!! Abort"
        exit
        ;;
    esac

    case $answer in
      1)
        generator="Green Hills MULTI"
        ;;
      2)
        generator="Unix Makefiles"
        ;;
      3)
        generator="Ninja"
        ;;
      4)
        generator="Ninja Multi-Config"
        ;;
      5)
        generator="Watcom WMake"
        ;;
      6)
        generator="CodeBlocks - Ninja"
        ;;
      7)
        generator="CodeBlocks - Unix Makefiles"
        ;;
      8)
        generator="CodeLite - Ninja"
        ;;
      9)
        generator="CodeLite - Unix Makefiles"
        ;;
      10)
        generator="Eclipse CDT4 - Ninja"
        ;;
      11)
        generator="Eclipse CDT4 - Unix Makefiles"
        ;;
      12)
        generator="Kate - Ninja"
        ;;
      13)
        generator="Kate - Unix Makefiles"
        ;;
      14)
        generator="Sublime Text 2 - Ninja"
        ;;
      15)
        generator="Sublime Text 2 - Unix Makefiles"
        ;;
    esac
  else
    generator=$XLIFEPP_BUILD_GENERATOR
  fi

  if test $XLIFEPP_BUILD_INTERACTIVE -eq 1
  then
    if test $XLIFEPP_FROM_SRCS = "ON"
    then
      compilers=`ls $XLIFEPP_DIR/lib/$XLIFEPP_ARCH`
    else
      compilers=$XLIFEPP_BUILD_CXX_COMPILER
    fi
    iter=1
    echo "The following compilers are available:"
    if test "$generator" = "Xcode"
    then
      for comp in $compilers
      do
        if echo $comp | grep clang > /dev/null 2>&1
        then 
          echo "$iter -> $comp"
          iter=$((iter+1))
          answercompiler=1
          compiler=$comp
        fi
        if test $iter -eq 1
        then
          echo "You asked for Xcode generator but XLiFE++ was not compiled with clang++ compiler"
          exit
        fi
      done
    else
      for compiler in $compilers
      do
        echo "$iter -> $compiler"
        iter=$((iter+1))
      done
      if test $iter -ne 2
      then
        printf "Your choice (default is 1): "
        read answerCompiler
        case $answerCompiler in
          "")
            answerCompiler=1
            ;;
          *)
            if test $answerCompiler -ge $iter
            then
              echo "$answerCompiler is not between 1 and $((iter-1)) !!! Abort"
              exit
            fi
            ;;
        esac
      else
        answerCompiler=1
      fi
      iter=1
      for com in $compilers
      do
        if test $iter -eq $answerCompiler
        then
          compiler=$com
        fi
        iter=$((iter+1))
      done
    fi
  else
    compiler=$XLIFEPP_BUILD_CXX_COMPILER
  fi
  
  if test $XLIFEPP_BUILD_INTERACTIVE -eq 1
  then
    nbOfCppFilesInDir=`ls $project_dir/*.cpp $project_dir/*.c++ $project_dir/*.cc 2>/dev/null | wc -l`
    askForMainFile=0
    if test $nbOfCppFilesInDir -eq 0
    then
      askForMainFile=1
    fi 
    if test $nbOfCppFilesInDir -ne 0
    then
      nbOfMainInFiles=`grep -i \ main\( $project_dir/*.cpp $project_dir/*.c++ $project_dir/*.cc 2>/dev/null | wc -l`
      if test $nbOfMainInFiles -gt 1
      then
        echo "There are cpp files with several main functions !!! Abort"
        exit;
      fi
      if test $nbOfMainInFiles -eq 1
      then
        echo "There are cpp files with only one main function"
      fi
      if test $nbOfMainInFiles -eq 0
      then
        echo "There are no cpp files"
        askForMainFile=1
      fi
    fi

    if test $askForMainFile -eq 1
    then
      echo "The following main files are available:"
        echo "1 -> main.cpp"
        echo "2 -> bilaplacian2d_morley.cpp"
        echo "3 -> elasticity2dP1.cpp"
        echo "4 -> helmholtz2d-Dirichlet_single_layer.cpp"
        echo "5 -> helmholtz2dP1-DtN_scalar.cpp"
        echo "6 -> helmholtz2dP1-cg.cpp"
        echo "7 -> helmholtz2d_FEM_BEM.cpp"
        echo "8 -> helmholtz2d_FE_IR.cpp"
        echo "9 -> helmholtz3d-Dirichlet_single_layer.cpp"
        echo "10 -> laplace1dGL60-eigen.cpp"
        echo "11 -> laplace1dP1.cpp"
        echo "12 -> laplace1dP10Robin.cpp"
        echo "13 -> laplace2dDGP1.cpp"
        echo "14 -> laplace2dP0_RT1.cpp"
        echo "15 -> laplace2dP1-average.cpp"
        echo "16 -> laplace2dP1-dirichlet.cpp"
        echo "17 -> laplace2dP1-ficticious_domain.cpp"
        echo "18 -> laplace2dP1-periodic.cpp"
        echo "19 -> laplace2dP1_Neumann.cpp"
        echo "20 -> laplace2dP2-eigen.cpp"
        echo "21 -> laplace2dP2-transmission.cpp"
        echo "22 -> maxwell2dN1.cpp"
        echo "23 -> maxwell3D_EFIE.cpp"
        echo "24 -> wave_2d_leap-frog.cpp"
        printf "Your choice (default is 1): "
      read answerFile
      case $answerFile in
          1|2|3|4|5|6|7|8|9|10|11|12|13|14|15|16|17|18|19|20|21|22|23|24)
            ;;
          "")
            answerFile=1
            ;;
          *)
            echo "$answerFile is not between 1 and 24 !!! Abort"
            exit
            ;;
        esac

      case $answerFile in
          1)
            XLIFEPP_BUILD_WITH_FILE="main.cpp"
            ;;
          2)
            XLIFEPP_BUILD_WITH_FILE="bilaplacian2d_morley.cpp"
            ;;
          3)
            XLIFEPP_BUILD_WITH_FILE="elasticity2dP1.cpp"
            ;;
          4)
            XLIFEPP_BUILD_WITH_FILE="helmholtz2d-Dirichlet_single_layer.cpp"
            ;;
          5)
            XLIFEPP_BUILD_WITH_FILE="helmholtz2dP1-DtN_scalar.cpp"
            ;;
          6)
            XLIFEPP_BUILD_WITH_FILE="helmholtz2dP1-cg.cpp"
            ;;
          7)
            XLIFEPP_BUILD_WITH_FILE="helmholtz2d_FEM_BEM.cpp"
            ;;
          8)
            XLIFEPP_BUILD_WITH_FILE="helmholtz2d_FE_IR.cpp"
            ;;
          9)
            XLIFEPP_BUILD_WITH_FILE="helmholtz3d-Dirichlet_single_layer.cpp"
            ;;
          10)
            XLIFEPP_BUILD_WITH_FILE="laplace1dGL60-eigen.cpp"
            ;;
          11)
            XLIFEPP_BUILD_WITH_FILE="laplace1dP1.cpp"
            ;;
          12)
            XLIFEPP_BUILD_WITH_FILE="laplace1dP10Robin.cpp"
            ;;
          13)
            XLIFEPP_BUILD_WITH_FILE="laplace2dDGP1.cpp"
            ;;
          14)
            XLIFEPP_BUILD_WITH_FILE="laplace2dP0_RT1.cpp"
            ;;
          15)
            XLIFEPP_BUILD_WITH_FILE="laplace2dP1-average.cpp"
            ;;
          16)
            XLIFEPP_BUILD_WITH_FILE="laplace2dP1-dirichlet.cpp"
            ;;
          17)
            XLIFEPP_BUILD_WITH_FILE="laplace2dP1-ficticious_domain.cpp"
            ;;
          18)
            XLIFEPP_BUILD_WITH_FILE="laplace2dP1-periodic.cpp"
            ;;
          19)
            XLIFEPP_BUILD_WITH_FILE="laplace2dP1_Neumann.cpp"
            ;;
          20)
            XLIFEPP_BUILD_WITH_FILE="laplace2dP2-eigen.cpp"
            ;;
          21)
            XLIFEPP_BUILD_WITH_FILE="laplace2dP2-transmission.cpp"
            ;;
          22)
            XLIFEPP_BUILD_WITH_FILE="maxwell2dN1.cpp"
            ;;
          23)
            XLIFEPP_BUILD_WITH_FILE="maxwell3D_EFIE.cpp"
            ;;
          24)
            XLIFEPP_BUILD_WITH_FILE="wave_2d_leap-frog.cpp"
            ;;
        esac

      if test $XLIFEPP_BUILD_WITH_FILE != "None"
      then
        if test $XLIFEPP_VERBOSE_LEVEL -ge 1
        then
          echo "Copying $XLIFEPP_BUILD_WITH_FILE"
        fi
        if test $XLIFEPP_FROM_SRCS = "ON"
        then
          if test $XLIFEPP_BUILD_WITH_FILE = "main.cpp"
          then
            cp "$XLIFEPP_DIR/usr/main.cpp" "$project_dir"
          else
            cp "$XLIFEPP_DIR/examples/$XLIFEPP_BUILD_WITH_FILE" "$project_dir"
          fi
        else
          cp "$XLIFEPP_DIR/share/examples/$XLIFEPP_BUILD_WITH_FILE" "$project_dir"
        fi
      fi
    fi
  else
    if test $XLIFEPP_BUILD_WITH_FILE != "None"
    then
      if test $XLIFEPP_VERBOSE_LEVEL -ge 1
      then
        echo "Copying $XLIFEPP_BUILD_WITH_FILE file"
      fi
      if test $XLIFEPP_FROM_SRCS = "ON"
        then
          if test $XLIFEPP_BUILD_WITH_FILE = "main.cpp"
        then
          cp "$XLIFEPP_DIR/usr/main.cpp" "$project_dir"
        else
          cp "$XLIFEPP_DIR/examples/$XLIFEPP_BUILD_WITH_FILE" "$project_dir"
        fi
      else
        cp "$XLIFEPP_DIR/share/examples/$XLIFEPP_BUILD_WITH_FILE" "$project_dir"
      fi
    fi
  fi

  if test $XLIFEPP_VERBOSE_LEVEL -ge 1
  then
    echo "Cleaning CMake build files"
  fi
  rm -rf "$project_dir/CMakeCache.txt" "$project_dir/CMakeFiles" "$project_dir/cmake_install.cmake"
  
  if test $XLIFEPP_BUILD_INTERACTIVE -eq 1
  then
    if test $XLIFEPP_FROM_SRCS = "ON"
    then
      parModes=`ls $XLIFEPP_DIR/lib/$XLIFEPP_ARCH/$compiler/`
    else
      if test $XLIFEPP_BUILD_WITH_OMP -eq 1
      then
        parModes="omp"
      else
        parModes="seq"
      fi
    fi
    echo "You can use:"
    iter=1
    for parMode in $parModes
    do
      if test $parMode = "omp"
      then
        echo "$iter -> multi-threading with OpenMP"
        iter=$((iter+1))
      fi
    done
    for parMode in $parModes
    do
      if test $parMode = "seq"
      then
        echo "$iter -> sequential"
        iter=$((iter+1))
      fi
    done
    if test $iter -ne 2
    then
      printf "Your choice (default is 1): "
      read answerParMode
      case $answerParMode in
        "")
          answerParMode=1
          ;;
        *)
          if test $answerParMode -ge $iter
          then
            echo "$answerParMode is not between 1 and $((iter-1)) !!! Abort"
            exit
          fi
          ;;
      esac
    else
      answerParMode=1
    fi
    iter=1
    for parMode in $parModes
    do
      if test $parMode = "omp"
      then
        if test $iter -eq $answerParMode
        then
          omp=1
        fi
        iter=$((iter+1))   
      fi
    done
    for parMode in $parModes
    do
      if test $parMode = "seq"
      then
        if test $iter -eq $answerParMode
        then
          omp=0
        fi  
      fi
    done
  else
    omp=$XLIFEPP_BUILD_WITH_OMP
  fi

  parMode="seq"
  if test $omp -eq 1
  then
    parMode="omp"
  fi

  if test $XLIFEPP_BUILD_INTERACTIVE -eq 1
  then
    if test $XLIFEPP_FROM_SRCS = "ON"
    then
      buildtypes=`ls $XLIFEPP_DIR/lib/$XLIFEPP_ARCH/$compiler/$parMode`
    else
      buildtypes=$XLIFEPP_BUILD_TYPE
    fi
    iter=1
    echo "The following build types are available"
    for buildtype in $buildtypes
    do
      if test $buildtype != "info.txt"
      then
        echo "$iter -> $buildtype"
        iter=$((iter+1))
      fi
    done
    if test $iter -ne 2
    then
      printf "Your choice (default is 1): "
      read answerBuildType
      case $answerBuildType in
        "")
          answerBuildType=1
          ;;
        *)
          if test $answerBuildType -ge $iter
          then
            echo "$answerBuildType is not between 1 and $((iter-1)) !!! Abort"
            exit
          fi
          ;;
      esac
    else
      answerBuildType=1
    fi
    iter=1
    for btype in $buildtypes
    do
      if test $iter -eq $answerBuildType
      then
        buildtype=$btype
      fi
      iter=$((iter+1))
    done
  else
    buildtype=$XLIFEPP_BUILD_TYPE
  fi

  if test $XLIFEPP_VERBOSE_LEVEL -ge 1
  then
    echo "Copying CMakeLists.txt"
  fi

  if test $XLIFEPP_FROM_SRCS = "ON"
  then
    XLIFEPP_INFO_TXT_DIR="$XLIFEPP_DIR/lib/$XLIFEPP_ARCH/$compiler/$parMode"
    if test -f "$XLIFEPP_INFO_TXT_DIR/$buildtype/info.txt"
    then
      XLIFEPP_INFO_TXT_DIR="$XLIFEPP_DIR/lib/$XLIFEPP_ARCH/$compiler/$parMode/$buildtype"
    fi
    iter=1

    for line in $(cat "$XLIFEPP_INFO_TXT_DIR/info.txt")
    do
      if test $iter -eq 3
      then
        trueCompiler=$line
      fi
      if test $iter -eq 6
      then
        buildPath=$line
      fi
      iter=$((iter+1))
    done
  else
    trueCompiler=$XLIFEPP_BUILD_CXX_REAL_COMPILER
    buildPath=$XLIFEPP_USR_CMAKELISTS_PATH
  fi

  cp "$buildPath/CMakeLists.txt" "$project_dir"

  if test -z $compiler
  then
    if test $omp -eq 1
    then 
      cmd="$XLIFEPP_CMAKE_CMD \"$project_dir\" -G\"$generator\" -DCMAKE_BUILD_TYPE=$buildtype -DENABLE_OMP=ON -B\"$project_dir\""
    else
      cmd="$XLIFEPP_CMAKE_CMD \"$project_dir\" -G\"$generator\" -DCMAKE_BUILD_TYPE=$buildtype -B\"$project_dir\""
    fi
  else
    if test $omp -eq 1
    then 
      cmd="$XLIFEPP_CMAKE_CMD \"$project_dir\" -G\"$generator\" -DCMAKE_BUILD_TYPE=$buildtype -DCMAKE_CXX_COMPILER=$trueCompiler -DENABLE_OMP=ON -B\"$project_dir\""
    else
      cmd="$XLIFEPP_CMAKE_CMD \"$project_dir\" -G\"$generator\" -DCMAKE_BUILD_TYPE=$buildtype -DCMAKE_CXX_COMPILER=$trueCompiler -B\"$project_dir\""
    fi
  fi

  if test $compiler = "ccache"
  then
    cmd="$cmd -DCMAKE_CXX_COMPILER=g++"
  fi

  if test $XLIFEPP_VERBOSE_LEVEL -ge 2
  then
    echo "Command to run: $cmd"
  fi
  if test $XLIFEPP_BUILD_GENERATE -eq 1
  then
    eval $cmd
  fi
}

main()
{
  defineGlobals "$@"
  parsargs "$@"

  echo "*********************************"
  echo "*           xlifepp             *"
  echo "*********************************"

  if test $XLIFEPP_BUILD -eq 1
  then
    xlifepp_build_project
  fi
}

main "$@"
