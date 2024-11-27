include(Compiler/Clang-OBJC)

if((NOT DEFINED CMAKE_DEPENDS_USE_COMPILER OR CMAKE_DEPENDS_USE_COMPILER)
    AND CMAKE_GENERATOR MATCHES "Makefiles"
    AND CMAKE_DEPFILE_FLAGS_OBJC)
  # dependencies are computed by the compiler itself
  set(CMAKE_OBJC_DEPFILE_FORMAT gcc)
  set(CMAKE_OBJC_DEPENDS_USE_COMPILER TRUE)
endif()


if(NOT CMAKE_OBJC_COMPILER_VERSION VERSION_LESS 4.0)
  set(CMAKE_OBJC90_STANDARD_COMPILE_OPTION "-std=c90")
  set(CMAKE_OBJC90_EXTENSION_COMPILE_OPTION "-std=gnu90")
  set(CMAKE_OBJC90_STANDARD__HAS_FULL_SUPPORT ON)

  set(CMAKE_OBJC99_STANDARD_COMPILE_OPTION "-std=c99")
  set(CMAKE_OBJC99_EXTENSION_COMPILE_OPTION "-std=gnu99")
  set(CMAKE_OBJC99_STANDARD__HAS_FULL_SUPPORT ON)

  set(CMAKE_OBJC11_STANDARD_COMPILE_OPTION "-std=c11")
  set(CMAKE_OBJC11_EXTENSION_COMPILE_OPTION "-std=gnu11")
  set(CMAKE_OBJC11_STANDARD__HAS_FULL_SUPPORT ON)
endif()

# AppleClang 10.0 was the oldest compiler available to test C17 support
if(NOT CMAKE_OBJC_COMPILER_VERSION VERSION_LESS 10.0)
  set(CMAKE_OBJC17_STANDARD_COMPILE_OPTION "-std=c17")
  set(CMAKE_OBJC17_EXTENSION_COMPILE_OPTION "-std=gnu17")
  set(CMAKE_OBJC17_STANDARD__HAS_FULL_SUPPORT ON)
endif()

if(NOT CMAKE_OBJC_COMPILER_VERSION VERSION_LESS 11.0)
  set(CMAKE_OBJC23_STANDARD_COMPILE_OPTION "-std=c2x")
  set(CMAKE_OBJC23_EXTENSION_COMPILE_OPTION "-std=gnu2x")
  set(CMAKE_OBJC23_STANDARD__HAS_FULL_SUPPORT ON)
endif()

# AppleClang 10.0 was the oldest compiler available to test default C11 support
__compiler_check_default_language_standard(OBJC 4.0 99 10.0 11)
