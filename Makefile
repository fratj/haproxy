# This GNU Makefile supports different OS and CPU combinations.
#
# You should use it this way :
#   [g]make TARGET=os [ARCH=arch] [CPU=cpu] USE_xxx=1 ...
#
# When in doubt, invoke help, possibly with a known target :
#   [g]make help
#   [g]make help TARGET=linux-glibc
#
# By default the detailed commands are hidden for a cleaner output, but you may
# see them by appending "V=1" to the make command.
#
# Valid USE_* options are enumerated in the "use_opts" variable and are listed
# below. Most of them are automatically set by the TARGET, others have to be
# explicitly specified :
#   USE_EPOLL            : enable epoll() on Linux 2.6. Automatic.
#   USE_KQUEUE           : enable kqueue() on BSD. Automatic.
#   USE_EVPORTS          : enable event ports on SunOS systems. Automatic.
#   USE_NETFILTER        : enable netfilter on Linux. Automatic.
#   USE_PCRE             : enable use of libpcre for regex. Recommended.
#   USE_PCRE_JIT         : enable JIT for faster regex on libpcre >= 8.32
#   USE_PCRE2            : enable use of libpcre2 for regex.
#   USE_PCRE2_JIT        : enable JIT for faster regex on libpcre2
#   USE_POLL             : enable poll(). Automatic.
#   USE_THREAD           : enable threads support.
#   USE_STATIC_PCRE      : enable static libpcre. Recommended.
#   USE_STATIC_PCRE2     : enable static libpcre2.
#   USE_TPROXY           : enable transparent proxy. Automatic.
#   USE_LINUX_TPROXY     : enable full transparent proxy. Automatic.
#   USE_LINUX_SPLICE     : enable kernel 2.6 splicing. Automatic.
#   USE_LIBCRYPT         : enable encrypted passwords using -lcrypt
#   USE_CRYPT_H          : set it if your system requires including crypt.h
#   USE_GETADDRINFO      : use getaddrinfo() to resolve IPv6 host names.
#   USE_OPENSSL          : enable use of OpenSSL. Recommended, but see below.
#   USE_OPENSSL_WOLFSSL  : enable use of wolfSSL with the OpenSSL API
#   USE_ENGINE           : enable use of OpenSSL Engine.
#   USE_LUA              : enable Lua support.
#   USE_ACCEPT4          : enable use of accept4() on linux. Automatic.
#   USE_CLOSEFROM        : enable use of closefrom() on *bsd, solaris. Automatic.
#   USE_PRCTL            : enable use of prctl(). Automatic.
#   USE_PROCCTL          : enable use of procctl(). Automatic.
#   USE_ZLIB             : enable zlib library support and disable SLZ
#   USE_SLZ              : enable slz library instead of zlib (default=enabled)
#   USE_CPU_AFFINITY     : enable pinning processes to CPU on Linux. Automatic.
#   USE_TFO              : enable TCP fast open. Supported on Linux >= 3.7.
#   USE_NS               : enable network namespace support. Supported on Linux >= 2.6.24.
#   USE_DL               : enable it if your system requires -ldl. Automatic on Linux.
#   USE_MATH             : enable use of -lm. Automatic.
#   USE_RT               : enable it if your system requires -lrt. Automatic on Linux.
#   USE_BACKTRACE        : enable backtrace(). Automatic on Linux.
#   USE_PROMEX           : enable the Prometheus exporter
#   USE_DEVICEATLAS      : enable DeviceAtlas api.
#   USE_51DEGREES        : enable third party device detection library from 51Degrees
#   USE_51DEGREES_V4     : enable use of 51Degrees V4 engine with Hash algorithm
#   USE_WURFL            : enable WURFL detection library from Scientiamobile
#   USE_SYSTEMD          : enable sd_notify() support.
#   USE_OBSOLETE_LINKER  : use when the linker fails to emit __start_init/__stop_init
#   USE_THREAD_DUMP      : use the more advanced thread state dump system. Automatic.
#   USE_OT               : enable the OpenTracing filter
#   USE_MEMORY_PROFILING : enable the memory profiler. Linux-glibc only.
#   USE_LIBATOMIC        : force to link with/without libatomic. Automatic.
#   USE_PTHREAD_EMULATION: replace pthread's rwlocks with ours
#   USE_SHM_OPEN         : use shm_open() for the startup-logs
#
# Options can be forced by specifying "USE_xxx=1" or can be disabled by using
# "USE_xxx=" (empty string). The list of enabled and disabled options for a
# given TARGET is enumerated at the end of "make help".
#
# Variables useful for packagers :
#   CC is set to "cc" by default and is used for compilation only.
#   LD is set to "cc" by default and is used for linking only.
#   ARCH may be useful to force build of 32-bit binary on 64-bit systems
#   CFLAGS is automatically set for the specified CPU and may be overridden.
#   LDFLAGS is automatically set to -g and may be overridden.
#   DEP may be cleared to ignore changes to include files during development
#   SMALL_OPTS may be used to specify some options to shrink memory usage.
#   DEBUG may be used to set some internal debugging options.
#   ERR may be set to non-empty to pass -Werror to the compiler
#   ADDINC may be used to complete the include path in the form -Ipath.
#   ADDLIB may be used to complete the library list in the form -Lpath -llib.
#   DEFINE may be used to specify any additional define, which will be reported
#          by "haproxy -vv" in CFLAGS.
#   SILENT_DEFINE may be used to specify other defines which will not be
#     reported by "haproxy -vv".
#   EXTRA   is used to force building or not building some extra tools.
#   DESTDIR is not set by default and is used for installation only.
#           It might be useful to set DESTDIR if you want to install haproxy
#           in a sandbox.
#   INSTALL is set to "install" by default and is used to provide the name of
#           the install binary used by the install targets and any additional
#           flags.
#   PREFIX  is set to "/usr/local" by default and is used for installation only.
#   SBINDIR is set to "$(PREFIX)/sbin" by default and is used for installation
#           only.
#   MANDIR  is set to "$(PREFIX)/share/man" by default and is used for
#           installation only.
#   DOCDIR  is set to "$(PREFIX)/doc/haproxy" by default and is used for
#           installation only.
#   HLUA_PREPEND_PATH may be used to prepend a folder to Lua's default package.path.
#   HLUA_PREPEND_CPATH may be used to prepend a folder to Lua's default package.cpath.
#
# Other variables :
#   PCRE_CONFIG    : force the binary path to get pcre config (by default
#                                                              pcre-config)
#   PCREDIR        : force the path to libpcre.
#   PCRE_LIB       : force the lib path to libpcre (defaults to $PCREDIR/lib).
#   PCRE_INC       : force the include path to libpcre ($PCREDIR/inc)
#   PCRE2_CONFIG   : force the binary path to get pcre2 config (by default
#                                                               pcre2-config)
#   SSL_LIB        : force the lib path to libssl/libcrypto
#   SSL_INC        : force the include path to libssl/libcrypto
#   WOLFSSL_INC    : force the include path to wolfSSL
#   WOLFSSL_LIB    : force the lib path to wolfSSL
#   LUA_LIB        : force the lib path to lua
#   LUA_INC        : force the include path to lua
#   LUA_LIB_NAME   : force the lib name (or automatically evaluated, by order of
#                                        priority : lua5.4, lua54, lua5.3, lua53, lua).
#   OT_DEBUG       : compile the OpenTracing filter in debug mode
#   OT_INC         : force the include path to libopentracing-c-wrapper
#   OT_LIB         : force the lib path to libopentracing-c-wrapper
#   OT_RUNPATH     : add RUNPATH for libopentracing-c-wrapper to haproxy executable
#   OT_USE_VARS    : allows the use of variables for the OpenTracing context
#   IGNOREGIT      : ignore GIT commit versions if set.
#   VERSION        : force haproxy version reporting.
#   SUBVERS        : add a sub-version (eg: platform, model, ...).
#   EXTRAVERSION   : local version string to append (e.g. build number etc)
#   VERDATE        : force haproxy's release date.
#   VTEST_PROGRAM  : location of the vtest program to run reg-tests.
#   DEBUG_USE_ABORT: use abort() for program termination, see include/haproxy/bug.h for details

include include/make/verbose.mk
include include/make/compiler.mk
include include/make/options.mk

#### Installation options.
DESTDIR =
INSTALL = install
PREFIX = /usr/local
SBINDIR = $(PREFIX)/sbin
MANDIR = $(PREFIX)/share/man
DOCDIR = $(PREFIX)/doc/haproxy

#### TARGET system
# Use TARGET=<target_name> to optimize for a specific target OS among the
# following list (use the default "generic" if uncertain) :
#    linux-glibc, linux-glibc-legacy, linux-musl, solaris, freebsd, freebsd-glibc,
#    dragonfly, openbsd, netbsd, cygwin, haiku, aix51, aix52, aix72-gcc, osx, generic,
#    custom
TARGET =

#### TARGET CPU
# Use CPU=<cpu_name> to optimize for a particular CPU, among the following
# list :
#    generic, native, i586, i686, ultrasparc, power8, power9, custom,
#    a53, a72, armv81, armv8-auto
CPU = generic

#### Architecture, used when not building for native architecture
# Use ARCH=<arch_name> to force build for a specific architecture. Known
# architectures will lead to "-m32" or "-m64" being added to CFLAGS and
# LDFLAGS. This can be required to build 32-bit binaries on 64-bit targets.
# Currently, only 32, 64, x86_64, i386, i486, i586 and i686 are understood.
ARCH =

#### Toolchain options.
CC = cc
LD = $(CC)

#### Debug flags (typically "-g").
# Those flags only feed CFLAGS so it is not mandatory to use this form.
DEBUG_CFLAGS = -g

#### Add -Werror when set to non-empty
ERR =

#### May be used to force running a specific set of reg-tests
REG_TEST_FILES =
REG_TEST_SCRIPT=./scripts/run-regtests.sh

#### Compiler-specific flags that may be used to disable some negative over-
# optimization or to silence some warnings.
# We rely on signed integer wraparound on overflow, however clang think it
# can do whatever it wants since it's an undefined behavior, so use -fwrapv
# to be sure we get the intended behavior.
WARN_CFLAGS := -Wtype-limits -Wshift-negative-value -Wshift-overflow=2 \
               -Wduplicated-cond -Wnull-dereference
SPEC_CFLAGS := -Wall -Wextra -Wundef -Wdeclaration-after-statement -Wfatal-errors
SPEC_CFLAGS += $(call cc-all-fast,$(WARN_CFLAGS))

SPEC_CFLAGS += $(call cc-opt-alt,-fwrapv,-fno-strict-overflow)
SPEC_CFLAGS += $(cc-wnouwo)
SPEC_CFLAGS += $(call cc-nowarn,address-of-packed-member)
SPEC_CFLAGS += $(call cc-nowarn,unused-label)
SPEC_CFLAGS += $(call cc-nowarn,sign-compare)
SPEC_CFLAGS += $(call cc-nowarn,unused-parameter)
SPEC_CFLAGS += $(call cc-nowarn,clobbered)
SPEC_CFLAGS += $(call cc-nowarn,missing-field-initializers)
SPEC_CFLAGS += $(call cc-nowarn,cast-function-type)
SPEC_CFLAGS += $(call cc-nowarn,string-plus-int)
SPEC_CFLAGS += $(call cc-nowarn,atomic-alignment)

ifneq ($(ERR),)
  SPEC_CFLAGS += -Werror
endif

#### Memory usage tuning
# If small memory footprint is required, you can reduce the buffer size. There
# are 2 buffers per concurrent session, so 16 kB buffers will eat 32 MB memory
# with 1000 concurrent sessions. Putting it slightly lower than a page size
# will prevent the additional parameters to go beyond a page. 8030 bytes is
# exactly 5.5 TCP segments of 1460 bytes and is generally good. Useful tuning
# macros include :
#    SYSTEM_MAXCONN, BUFSIZE, MAXREWRITE, REQURI_LEN, CAPTURE_LEN.
# Example: SMALL_OPTS = -DBUFSIZE=8030 -DMAXREWRITE=1030 -DSYSTEM_MAXCONN=1024
SMALL_OPTS =

#### Debug settings
# You can enable debugging on specific code parts by setting DEBUG=-DDEBUG_xxx.
# Use quotes and spaces if multiple options are needed (the DEBUG variables is
# passed as-is to CFLAGS). Please check sources for their exact meaning or do
# not use them at all. Some even more obscure ones might also be available
# without appearing here. Currently defined DEBUG macros include DEBUG_FULL,
# DEBUG_MEM_STATS, DEBUG_DONT_SHARE_POOLS, DEBUG_FD, DEBUG_POOL_INTEGRITY,
# DEBUG_NO_POOLS, DEBUG_FAIL_ALLOC, DEBUG_STRICT_ACTION=[0-3], DEBUG_HPACK,
# DEBUG_AUTH, DEBUG_SPOE, DEBUG_UAF, DEBUG_THREAD, DEBUG_STRICT, DEBUG_DEV,
# DEBUG_TASK, DEBUG_MEMORY_POOLS, DEBUG_POOL_TRACING, DEBUG_QPACK.
DEBUG = -DDEBUG_STRICT -DDEBUG_MEMORY_POOLS

#### Trace options
# Use TRACE=1 to trace function calls to file "trace.out" or to stderr if not
# possible.
TRACE =

#### Additional include and library dirs
# Redefine this if you want to add some special PATH to include/libs
ADDINC =
ADDLIB =

#### Specific macro definitions
# Use DEFINE=-Dxxx to set any tunable macro. Anything declared here will appear
# in the build options reported by "haproxy -vv". Use SILENT_DEFINE if you do
# not want to pollute the report with complex defines.
# The following settings might be of interest when SSL is enabled :
#   LISTEN_DEFAULT_CIPHERS is a cipher suite string used to set the default SSL
#           ciphers on "bind" lines instead of using OpenSSL's defaults.
#   CONNECT_DEFAULT_CIPHERS is a cipher suite string used to set the default
#           SSL ciphers on "server" lines instead of using OpenSSL's defaults.
DEFINE =
SILENT_DEFINE =

#### extra programs to build
# Force this to enable building extra programs or to disable them.
# It's automatically appended depending on the targets.
EXTRA =

#### CPU dependent optimizations
# Some CFLAGS are set by default depending on the target CPU. Those flags only
# feed CPU_CFLAGS, which in turn feed CFLAGS, so it is not mandatory to use
# them. You should not have to change these options. Better use CPU_CFLAGS or
# even CFLAGS instead.
CPU_CFLAGS.generic    = -O2
CPU_CFLAGS.native     = -O2 -march=native
CPU_CFLAGS.i586       = -O2 -march=i586
CPU_CFLAGS.i686       = -O2 -march=i686
CPU_CFLAGS.ultrasparc = -O6 -mcpu=v9 -mtune=ultrasparc
CPU_CFLAGS.power8     = -O2 -mcpu=power8 -mtune=power8
CPU_CFLAGS.power9     = -O2 -mcpu=power9 -mtune=power9
CPU_CFLAGS.a53        = -O2 -mcpu=cortex-a53
CPU_CFLAGS.a72        = -O2 -mcpu=cortex-a72
CPU_CFLAGS.armv81     = -O2 -march=armv8.1-a
CPU_CFLAGS.armv8-auto = -O2 -march=armv8-a+crc -moutline-atomics
CPU_CFLAGS            = $(CPU_CFLAGS.$(CPU))

#### ARCH dependent flags, may be overridden by CPU flags
ARCH_FLAGS.32     = -m32
ARCH_FLAGS.64     = -m64
ARCH_FLAGS.i386   = -m32 -march=i386
ARCH_FLAGS.i486   = -m32 -march=i486
ARCH_FLAGS.i586   = -m32 -march=i586
ARCH_FLAGS.i686   = -m32 -march=i686
ARCH_FLAGS.x86_64 = -m64 -march=x86-64
ARCH_FLAGS        = $(ARCH_FLAGS.$(ARCH))

#### Common CFLAGS
# These CFLAGS contain general optimization options, CPU-specific optimizations
# and debug flags. They may be overridden by some distributions which prefer to
# set all of them at once instead of playing with the CPU and DEBUG variables.
CFLAGS = $(ARCH_FLAGS) $(CPU_CFLAGS) $(DEBUG_CFLAGS) $(SPEC_CFLAGS)

#### Common LDFLAGS
# These LDFLAGS are used as the first "ld" options, regardless of any library
# path or any other option. They may be changed to add any linker-specific
# option at the beginning of the ld command line.
LDFLAGS = $(ARCH_FLAGS) -g

#### list of all "USE_*" options. These ones must be updated if new options are
# added, so that the relevant options are properly added to the CFLAGS and to
# the reported build options.
use_opts = USE_EPOLL USE_KQUEUE USE_NETFILTER                                 \
           USE_PCRE USE_PCRE_JIT USE_PCRE2 USE_PCRE2_JIT USE_POLL             \
           USE_THREAD USE_PTHREAD_EMULATION USE_BACKTRACE                     \
           USE_STATIC_PCRE USE_STATIC_PCRE2 USE_TPROXY USE_LINUX_TPROXY       \
           USE_LINUX_SPLICE USE_LIBCRYPT USE_CRYPT_H USE_ENGINE               \
           USE_GETADDRINFO USE_OPENSSL USE_OPENSSL_WOLFSSL USE_LUA            \
           USE_ACCEPT4 USE_CLOSEFROM USE_ZLIB USE_SLZ USE_CPU_AFFINITY        \
           USE_TFO USE_NS USE_DL USE_RT USE_LIBATOMIC USE_MATH                \
           USE_DEVICEATLAS USE_51DEGREES USE_51DEGREES_V4                     \
           USE_WURFL USE_SYSTEMD USE_OBSOLETE_LINKER USE_PRCTL USE_PROCCTL    \
           USE_THREAD_DUMP USE_EVPORTS USE_OT USE_QUIC USE_PROMEX             \
           USE_MEMORY_PROFILING USE_SHM_OPEN

# preset all variables for all supported build options among use_opts
$(reset_opts_vars)

#### Target system options

# poll() is always supported, unless explicitly disabled by passing USE_POLL=""
# on the make command line.
USE_POLL   = default

# SLZ is always supported unless explicitly disabled by passing USE_SLZ=""
# or disabled by enabling ZLIB using USE_ZLIB=1
ifeq ($(USE_ZLIB),)
  USE_SLZ    = default
endif

# generic system target has nothing specific
ifeq ($(TARGET),generic)
  set_target_defaults = $(call default_opts,USE_POLL USE_TPROXY)
endif

# Haiku
ifeq ($(TARGET),haiku)
  TARGET_LDFLAGS = -lnetwork
  set_target_defaults = $(call default_opts,USE_POLL USE_TPROXY USE_OBSOLETE_LINKER)
endif

# For linux >= 2.6.28 and glibc
ifeq ($(TARGET),linux-glibc)
  set_target_defaults = $(call default_opts, \
    USE_POLL USE_TPROXY USE_LIBCRYPT USE_DL USE_RT USE_CRYPT_H USE_NETFILTER  \
    USE_CPU_AFFINITY USE_THREAD USE_EPOLL USE_LINUX_TPROXY                    \
    USE_ACCEPT4 USE_LINUX_SPLICE USE_PRCTL USE_THREAD_DUMP USE_NS USE_TFO     \
    USE_GETADDRINFO USE_BACKTRACE USE_SHM_OPEN)
  INSTALL = install -v
endif

# For linux >= 2.6.28, glibc without new features
ifeq ($(TARGET),linux-glibc-legacy)
  set_target_defaults = $(call default_opts, \
    USE_POLL USE_TPROXY USE_LIBCRYPT USE_DL USE_RT USE_CRYPT_H USE_NETFILTER  \
    USE_CPU_AFFINITY USE_THREAD USE_EPOLL USE_LINUX_TPROXY                    \
    USE_ACCEPT4 USE_LINUX_SPLICE USE_PRCTL USE_THREAD_DUMP USE_GETADDRINFO)
  INSTALL = install -v
endif

# For linux >= 2.6.28 and musl
ifeq ($(TARGET),linux-musl)
  set_target_defaults = $(call default_opts, \
    USE_POLL USE_TPROXY USE_LIBCRYPT USE_DL USE_RT USE_CRYPT_H USE_NETFILTER  \
    USE_CPU_AFFINITY USE_THREAD USE_EPOLL USE_LINUX_TPROXY                    \
    USE_ACCEPT4 USE_LINUX_SPLICE USE_PRCTL USE_THREAD_DUMP USE_NS USE_TFO     \
    USE_GETADDRINFO USE_SHM_OPEN)
  INSTALL = install -v
endif

# Solaris 10 and above
ifeq ($(TARGET),solaris)
  set_target_defaults = $(call default_opts, \
    USE_POLL USE_TPROXY USE_LIBCRYPT USE_CRYPT_H USE_GETADDRINFO USE_THREAD \
    USE_RT USE_OBSOLETE_LINKER USE_EVPORTS USE_CLOSEFROM)
  TARGET_CFLAGS  = -DFD_SETSIZE=65536 -D_REENTRANT -D_XOPEN_SOURCE=600 -D__EXTENSIONS__
  TARGET_LDFLAGS = -lnsl -lsocket
endif

# FreeBSD 10 and above
ifeq ($(TARGET),freebsd)
  set_target_defaults = $(call default_opts, \
    USE_POLL USE_TPROXY USE_LIBCRYPT USE_THREAD USE_CPU_AFFINITY USE_KQUEUE   \
    USE_ACCEPT4 USE_CLOSEFROM USE_GETADDRINFO USE_PROCCTL USE_SHM_OPEN)
endif

# kFreeBSD glibc
ifeq ($(TARGET),freebsd-glibc)
  set_target_defaults = $(call default_opts, \
    USE_POLL USE_TPROXY USE_LIBCRYPT USE_THREAD USE_CPU_AFFINITY USE_KQUEUE   \
    USE_ACCEPT4 USE_GETADDRINFO USE_CRYPT_H USE_DL)
endif

# DragonFlyBSD 4.3 and above
ifeq ($(TARGET),dragonfly)
  set_target_defaults = $(call default_opts, \
    USE_POLL USE_TPROXY USE_LIBCRYPT USE_THREAD USE_CPU_AFFINITY USE_KQUEUE   \
    USE_ACCEPT4 USE_CLOSEFROM USE_GETADDRINFO)
endif

# Mac OS/X
ifeq ($(TARGET),osx)
  set_target_defaults = $(call default_opts, \
    USE_POLL USE_TPROXY USE_LIBCRYPT USE_THREAD USE_CPU_AFFINITY USE_KQUEUE   \
    USE_GETADDRINFO)
  EXPORT_SYMBOL  = -export_dynamic
endif

# OpenBSD 6.3 and above
ifeq ($(TARGET),openbsd)
  set_target_defaults = $(call default_opts, \
    USE_POLL USE_TPROXY USE_LIBCRYPT USE_THREAD USE_KQUEUE USE_ACCEPT4        \
    USE_CLOSEFROM USE_GETADDRINFO)
endif

# NetBSD 8 and above
ifeq ($(TARGET),netbsd)
  set_target_defaults = $(call default_opts, \
    USE_POLL USE_TPROXY USE_LIBCRYPT USE_THREAD USE_KQUEUE USE_ACCEPT4        \
    USE_CLOSEFROM USE_GETADDRINFO)
endif

# AIX 5.1 only
ifeq ($(TARGET),aix51)
  set_target_defaults = $(call default_opts, \
    USE_POLL USE_LIBCRYPT USE_OBSOLETE_LINKER)
  TARGET_CFLAGS   = -Dss_family=__ss_family -Dip6_hdr=ip6hdr -DSTEVENS_API -D_LINUX_SOURCE_COMPAT -Dunsetenv=my_unsetenv
  DEBUG_CFLAGS    =
endif

# AIX 5.2
ifeq ($(TARGET),aix52)
  set_target_defaults = $(call default_opts, \
    USE_POLL USE_LIBCRYPT USE_OBSOLETE_LINKER)
  TARGET_CFLAGS   = -D_MSGQSUPPORT
  DEBUG_CFLAGS    =
endif

# AIX 7.2 and above
ifeq ($(TARGET),aix72-gcc)
  set_target_defaults = $(call default_opts, \
    USE_POLL USE_THREAD USE_LIBCRYPT USE_OBSOLETE_LINKER USE_GETADDRINFO)
  TARGET_CFLAGS   = -D_H_XMEM -D_H_VAR
  USE_LIBATOMIC   = implicit
endif

# Cygwin
ifeq ($(TARGET),cygwin)
  set_target_defaults = $(call default_opts, \
    USE_POLL USE_TPROXY USE_OBSOLETE_LINKER)
  # Cygwin adds IPv6 support only in version 1.7 (in beta right now).
  TARGET_CFLAGS  = $(if $(filter 1.5.%, $(shell uname -r)), -DUSE_IPV6 -DAF_INET6=23 -DINET6_ADDRSTRLEN=46, )
endif

# set the default settings according to the target above
$(set_target_defaults)

# Some architectures require to link with libatomic for atomics of certain
# sizes. These ones are reported as value 1 in the *_LOCK_FREE macros. Value
# 2 indicates that the builtin is native thus doesn't require libatomic. Hence
# any occurrence of 1 indicates libatomic is necessary. It's better to avoid
# linking with it by default as it's not always available nor deployed
# (especially on archs which do not need it).
ifneq ($(USE_THREAD),)
  ifneq ($(shell $(CC) $(CFLAGS) -dM -E -xc - </dev/null 2>/dev/null | grep -c 'LOCK_FREE.*1'),0)
    USE_LIBATOMIC   = implicit
  endif
endif

#### Determine version, sub-version and release date.
# If GIT is found, and IGNOREGIT is not set, VERSION, SUBVERS and VERDATE are
# extracted from the last commit. Otherwise, use the contents of the files
# holding the same names in the current directory.

ifeq ($(IGNOREGIT),)
  VERSION := $(shell [ -d .git/. ] && (git describe --tags --match 'v*' --abbrev=0 | cut -c 2-) 2>/dev/null)
  ifneq ($(VERSION),)
    # OK git is there and works.
    SUBVERS := $(shell comms=`git log --format=oneline --no-merges v$(VERSION).. 2>/dev/null | wc -l | tr -d '[:space:]'`; commit=`(git log -1 --pretty=%h --abbrev=6) 2>/dev/null`; [ $$comms -gt 0 ] && echo "-$$commit-$$comms")
    VERDATE := $(shell git log -1 --pretty=format:%ci | cut -f1 -d' ' | tr '-' '/')
  endif
endif

# Last commit version not found, take it from the files.
ifeq ($(VERSION),)
  VERSION := $(shell cat VERSION 2>/dev/null || touch VERSION)
endif
ifeq ($(SUBVERS),)
  SUBVERS := $(shell (grep -v '\$$Format' SUBVERS 2>/dev/null || touch SUBVERS) | head -n 1)
endif
ifeq ($(VERDATE),)
  VERDATE := $(shell (grep -v '^\$$Format' VERDATE 2>/dev/null || touch VERDATE) | head -n 1 | cut -f1 -d' ' | tr '-' '/')
endif

# this one is always empty by default and appended verbatim
EXTRAVERSION =

#### Build options
# Do not change these ones, enable USE_* variables instead.
OPTIONS_CFLAGS  =
OPTIONS_LDFLAGS =
OPTIONS_OBJS    =

#### Extra objects to be built and integrated (used only for development)
EXTRA_OBJS =

# This variable collects all USE_* values except those set to "implicit". This
# is used to report a list of all flags which were used to build this version.
# Do not assign anything to it.
BUILD_OPTIONS  := $(call build_options)

# All USE_* options have their equivalent macro defined in the code (some might
# possibly be unused though)
OPTIONS_CFLAGS += $(call opts_as_defines)

ifneq ($(USE_LIBCRYPT),)
  ifneq ($(TARGET),openbsd)
    ifneq ($(TARGET),osx)
      LIBCRYPT_LDFLAGS = -lcrypt
    endif
  endif
endif

ifneq ($(USE_ZLIB),)
  # Use ZLIB_INC and ZLIB_LIB to force path to zlib.h and libz.{a,so} if needed.
  ZLIB_CFLAGS      = $(if $(ZLIB_INC),-I$(ZLIB_INC))
  ZLIB_LDFLAGS     = $(if $(ZLIB_LIB),-L$(ZLIB_LIB)) -lz
endif

ifneq ($(USE_SLZ),)
  OPTIONS_OBJS   += src/slz.o
endif

ifneq ($(USE_POLL),)
  OPTIONS_OBJS   += src/ev_poll.o
endif

ifneq ($(USE_EPOLL),)
  OPTIONS_OBJS   += src/ev_epoll.o
endif

ifneq ($(USE_KQUEUE),)
  OPTIONS_OBJS   += src/ev_kqueue.o
endif

ifneq ($(USE_EVPORTS),)
  OPTIONS_OBJS   += src/ev_evports.o
endif

ifneq ($(USE_RT),)
  RT_LDFLAGS = -lrt
endif

ifneq ($(USE_THREAD),)
  THREAD_LDFLAGS = -lpthread
endif

ifneq ($(USE_BACKTRACE),)
  BACKTRACE_LDFLAGS = -Wl,$(if $(EXPORT_SYMBOL),$(EXPORT_SYMBOL),--export-dynamic)
endif

ifneq ($(USE_CPU_AFFINITY),)
  OPTIONS_OBJS   += src/cpuset.o
endif

ifneq ($(USE_OPENSSL),)
  # OpenSSL is packaged in various forms and with various dependencies.
  # In general -lssl is enough, but on some platforms, -lcrypto may be needed,
  # reason why it's added by default. Some even need -lz, then you'll need to
  # pass it in the "ADDLIB" variable if needed. If your SSL libraries are not
  # in the usual path, use SSL_INC=/path/to/inc and SSL_LIB=/path/to/lib.
  ifeq ($(USE_OPENSSL_WOLFSSL),)
    OPENSSL_CFLAGS   = $(if $(SSL_INC),-I$(SSL_INC))
    OPENSSL_LDFLAGS  = $(if $(SSL_LIB),-L$(SSL_LIB)) -lssl -lcrypto
  endif
  OPTIONS_OBJS  += src/ssl_sock.o src/ssl_ckch.o src/ssl_sample.o src/ssl_crtlist.o src/cfgparse-ssl.o src/ssl_utils.o src/jwt.o src/ssl_ocsp.o
endif

ifneq ($(USE_OPENSSL_WOLFSSL),)
  WOLFSSL_CFLAGS    = $(if $(WOLFSSL_INC),-I$(WOLFSSL_INC) -I$(WOLFSSL_INC)/wolfssl)
  WOLFSSL_LDFLAGS   = $(if $(WOLFSSL_LIB),-L$(WOLFSSL_LIB)) -lwolfssl
  OPTIONS_CFLAGS   += $(WOLFSSL_CFLAGS)
  OPTIONS_LDFLAGS  += $(WOLFSSL_LDFLAGS)
endif

ifneq ($(USE_ENGINE),)
  # OpenSSL 3.0 emits loud deprecation warnings by default when building with
  # engine support, and this option is made to silence them. Better use it
  # only when absolutely necessary, until there's a viable alternative to the
  # engine API.
  ENGINE_CFLAGS   = -DOPENSSL_SUPPRESS_DEPRECATED
endif

ifneq ($(USE_QUIC),)
OPTIONS_OBJS += src/quic_conn.o src/mux_quic.o src/h3.o src/xprt_quic.o    \
                src/quic_frame.o src/quic_tls.o src/quic_tp.o              \
                src/quic_stats.o src/quic_sock.o src/proto_quic.o          \
                src/qmux_trace.o src/quic_loss.o src/qpack-enc.o           \
                src/quic_cc_newreno.o src/quic_cc_cubic.o src/qpack-tbl.o  \
                src/qpack-dec.o src/hq_interop.o src/quic_stream.o         \
                src/h3_stats.o src/qmux_http.o src/cfgparse-quic.o         \
                src/cbuf.o src/quic_cc.o
endif

ifneq ($(USE_LUA),)
  check_lua_inc = $(shell if [ -d $(2)$(1) ]; then echo $(2)$(1); fi;)
  LUA_INC      := $(firstword $(foreach lib,lua5.4 lua54 lua5.3 lua53 lua,$(call check_lua_inc,$(lib),"/usr/include/")))

  check_lua_lib = $(shell echo "int main(){}" | $(CC) -o /dev/null -x c - $(2) -l$(1) 2>/dev/null && echo $(1))
  LUA_LD_FLAGS := -Wl,$(if $(EXPORT_SYMBOL),$(EXPORT_SYMBOL),--export-dynamic) $(if $(LUA_LIB),-L$(LUA_LIB))

  # Try to automatically detect the Lua library if not set
  ifeq ($(LUA_LIB_NAME),)
    LUA_LIB_NAME := $(firstword $(foreach lib,lua5.4 lua54 lua5.3 lua53 lua,$(call check_lua_lib,$(lib),$(LUA_LD_FLAGS))))
  endif

  # Lua lib name must be set now (forced/detected above)
  ifeq ($(LUA_LIB_NAME),)
    $(error unable to automatically detect the Lua library name, you can enforce its name with LUA_LIB_NAME=<name> (where <name> can be lua5.4, lua54, lua, ...))
  endif

  ifneq ($(HLUA_PREPEND_PATH),)
    LUA_CFLAGS      += -DHLUA_PREPEND_PATH=$(HLUA_PREPEND_PATH)
    BUILD_OPTIONS   += HLUA_PREPEND_PATH=$(HLUA_PREPEND_PATH)
  endif # HLUA_PREPEND_PATH

  ifneq ($(HLUA_PREPEND_CPATH),)
    LUA_CFLAGS      += -DHLUA_PREPEND_CPATH=$(HLUA_PREPEND_CPATH)
    BUILD_OPTIONS   += HLUA_PREPEND_CPATH=$(HLUA_PREPEND_CPATH)
  endif # HLUA_PREPEND_CPATH

  USE_MATH         = implicit
  LUA_CFLAGS      += $(if $(LUA_INC),-I$(LUA_INC))
  LUA_LDFLAGS      = $(LUA_LD_FLAGS) -l$(LUA_LIB_NAME)
  OPTIONS_OBJS    += src/hlua.o src/hlua_fcn.o
endif # USE_LUA

ifneq ($(USE_PROMEX),)
  OPTIONS_OBJS    += addons/promex/service-prometheus.o
endif

ifneq ($(USE_DEVICEATLAS),)
  # Use DEVICEATLAS_SRC and possibly DEVICEATLAS_INC and DEVICEATLAS_LIB to force path
  # to DeviceAtlas headers and libraries if needed.
  DEVICEATLAS_INC = $(DEVICEATLAS_SRC)
  DEVICEATLAS_LIB = $(DEVICEATLAS_SRC)
  ifeq ($(DEVICEATLAS_SRC),)
    DEVICEATLAS_LDFLAGS += -lda
  else
    ifeq ($(USE_PCRE),)
      ifeq ($(USE_PCRE2),)
        $(error the DeviceAtlas module needs the PCRE or the PCRE2 library in order to compile)
      endif
    endif
    ifneq ($(USE_PCRE2),)
      DEVICEATLAS_CFLAGS += -DDA_REGEX_HDR=\"dac_pcre2.c\" -DDA_REGEX_TAG=2
    endif
    OPTIONS_OBJS += $(DEVICEATLAS_LIB)/Os/daunix.o
    OPTIONS_OBJS += $(DEVICEATLAS_LIB)/dadwcom.o
    OPTIONS_OBJS += $(DEVICEATLAS_LIB)/dasch.o
    OPTIONS_OBJS += $(DEVICEATLAS_LIB)/json.o
    OPTIONS_OBJS += $(DEVICEATLAS_LIB)/dac.o
  endif
  OPTIONS_OBJS += addons/deviceatlas/da.o
  DEVICEATLAS_CFLAGS += $(if $(DEVICEATLAS_INC),-I$(DEVICEATLAS_INC))
endif

# Use 51DEGREES_SRC and possibly 51DEGREES_INC and 51DEGREES_LIB to force path
# to 51degrees v3/v4 headers and libraries if needed.
51DEGREES_INC = $(51DEGREES_SRC)
51DEGREES_LIB = $(51DEGREES_SRC)

ifneq ($(USE_51DEGREES_V4),)  # v4 here
  ifneq ($(USE_51DEGREES),)
    $(error cannot compile both 51Degrees V3 and V4 engine support)
  endif
  _51DEGREES_SRC   = $(shell find $(51DEGREES_LIB) -maxdepth 2 -name '*.c')
  OPTIONS_OBJS    += $(_51DEGREES_SRC:%.c=%.o)
  OPTIONS_CFLAGS  += -DUSE_51DEGREES_V4
  ifeq ($(USE_THREAD),)
    OPTIONS_CFLAGS  += -DFIFTYONEDEGREES_NO_THREADING -DFIFTYONE_DEGREES_NO_THREADING
  endif
  OPTIONS_OBJS    += addons/51degrees/51d.o
  OPTIONS_CFLAGS  += $(if $(51DEGREES_INC),-I$(51DEGREES_INC))
  OPTIONS_LDFLAGS += $(if $(51DEGREES_LIB),-L$(51DEGREES_LIB))
  USE_ATOMIC       = implicit
  USE_MATH         = implicit
endif # USE_51DEGREES_V4

ifneq ($(USE_51DEGREES),) # v3 here
  OPTIONS_OBJS    += $(51DEGREES_LIB)/../cityhash/city.o
  OPTIONS_OBJS    += $(51DEGREES_LIB)/51Degrees.o
  ifeq ($(USE_THREAD),)
    OPTIONS_CFLAGS  += -DFIFTYONEDEGREES_NO_THREADING
  else
    OPTIONS_OBJS    += $(51DEGREES_LIB)/../threading.o
  endif
  OPTIONS_OBJS    += addons/51degrees/51d.o
  OPTIONS_CFLAGS  += $(if $(51DEGREES_INC),-I$(51DEGREES_INC))
  OPTIONS_LDFLAGS += $(if $(51DEGREES_LIB),-L$(51DEGREES_LIB))
  USE_MATH         = implicit
endif # USE_51DEGREES

ifneq ($(USE_WURFL),)
  # Use WURFL_SRC and possibly WURFL_INC and WURFL_LIB to force path
  # to WURFL headers and libraries if needed.
  WURFL_INC = $(WURFL_SRC)
  WURFL_LIB = $(WURFL_SRC)
  OPTIONS_OBJS    += addons/wurfl/wurfl.o
  OPTIONS_CFLAGS  += $(if $(WURFL_INC),-I$(WURFL_INC))
  ifneq ($(WURFL_DEBUG),)
    OPTIONS_CFLAGS  += -DWURFL_DEBUG
  endif
  ifneq ($(WURFL_HEADER_WITH_DETAILS),)
    OPTIONS_CFLAGS  += -DWURFL_HEADER_WITH_DETAILS
  endif
  OPTIONS_LDFLAGS += $(if $(WURFL_LIB),-L$(WURFL_LIB)) -lwurfl
endif

ifneq ($(USE_SYSTEMD),)
  SYSTEMD_LDFLAGS = -lsystemd
endif

ifneq ($(USE_PCRE)$(USE_STATIC_PCRE)$(USE_PCRE_JIT),)
  ifneq ($(USE_PCRE2)$(USE_STATIC_PCRE2)$(USE_PCRE2_JIT),)
    $(error cannot compile both PCRE and PCRE2 support)
  endif
  # PCREDIR is used to automatically construct the PCRE_INC and PCRE_LIB paths,
  # by appending /include and /lib respectively. If your system does not use the
  # same sub-directories, simply force these variables instead of PCREDIR. It is
  # automatically detected but can be forced if required (for cross-compiling).
  # Forcing PCREDIR to an empty string will let the compiler use the default
  # locations.

  # in case only USE_STATIC_PCRE/USE_PCRE_JIT were set
  USE_PCRE    := $(if $(USE_PCRE),$(USE_PCRE),implicit)
  PCRE_CONFIG := pcre-config
  PCREDIR     := $(shell $(PCRE_CONFIG) --prefix 2>/dev/null || echo /usr/local)
  ifneq ($(PCREDIR),)
    PCRE_INC := $(PCREDIR)/include
    PCRE_LIB := $(PCREDIR)/lib
  endif

  PCRE_CFLAGS := $(if $(PCRE_INC),-I$(PCRE_INC))
  ifeq ($(USE_STATIC_PCRE),)
    PCRE_LDFLAGS := $(if $(PCRE_LIB),-L$(PCRE_LIB)) -lpcreposix -lpcre
  else
    PCRE_LDFLAGS := $(if $(PCRE_LIB),-L$(PCRE_LIB)) -Wl,-Bstatic -lpcreposix -lpcre -Wl,-Bdynamic
  endif
endif # USE_PCRE

ifneq ($(USE_PCRE2)$(USE_STATIC_PCRE2)$(USE_PCRE2_JIT),)
  # in case only USE_STATIC_PCRE2/USE_PCRE2_JIT were set
  USE_PCRE2    := $(if $(USE_PCRE2),$(USE_PCRE2),implicit)
  PCRE2_CONFIG := pcre2-config
  PCRE2DIR     := $(shell $(PCRE2_CONFIG) --prefix 2>/dev/null || echo /usr/local)
  ifneq ($(PCRE2DIR),)
    PCRE2_INC := $(PCRE2DIR)/include
    PCRE2_LIB := $(PCRE2DIR)/lib

    ifeq ($(PCRE2_WIDTH),)
      PCRE2_WIDTH = 8
    endif

    ifneq ($(PCRE2_WIDTH),8)
      ifneq ($(PCRE2_WIDTH),16)
        ifneq ($(PCRE2_WIDTH),32)
          $(error PCRE2_WIDTH needs to be set to either 8,16 or 32)
        endif
      endif
    endif

    PCRE2_CFLAGS  := -DPCRE2_CODE_UNIT_WIDTH=$(PCRE2_WIDTH) $(if $(PCRE2_INC), -I$(PCRE2_INC))
    PCRE2_LDFLAGS := $(shell $(PCRE2_CONFIG) --libs$(PCRE2_WIDTH) 2>/dev/null || echo -L/usr/local/lib -lpcre2-$(PCRE2_WIDTH))

    ifeq ($(PCRE2_LDFLAGS),)
      $(error libpcre2-$(PCRE2_WIDTH) not found)
    else
      ifeq ($(PCRE2_WIDTH),8)
        PCRE2_LDFLAGS += -lpcre2-posix
      endif
    endif

    ifneq ($(USE_STATIC_PCRE2),)
      PCRE2_LDFLAGS := $(if $(PCRE2_LIB),-L$(PCRE2_LIB)) -Wl,-Bstatic -L$(PCRE2_LIB) $(PCRE2_LDFLAGS) -Wl,-Bdynamic
    else
      PCRE2_LDFLAGS := $(if $(PCRE2_LIB),-L$(PCRE2_LIB)) -L$(PCRE2_LIB) $(PCRE2_LDFLAGS)
    endif
  endif # PCRE2DIR
endif # USE_PCRE2

ifneq ($(USE_NS),)
  OPTIONS_OBJS  += src/namespace.o
endif

ifneq ($(USE_OT),)
  include addons/ot/Makefile
endif

# better keep this one close to the end, as several libs above may need it
ifneq ($(USE_DL),)
  DL_LDFLAGS = -ldl
endif

ifneq ($(USE_MATH),)
  MATH_LDFLAGS = -lm
endif

ifneq ($(USE_LIBATOMIC),)
  LIBATOMIC_LDFLAGS = -latomic
endif

#### End of the USE_* options handling, any such option that would be added
#### below could be silently ignored.

# appends all foo_{C,LD}FLAGS to OPTIONS_{C,LD}FLAGS
$(collect_opts_flags)

#### Global compile options
VERBOSE_CFLAGS = $(CFLAGS) $(TARGET_CFLAGS) $(SMALL_OPTS) $(DEFINE)
COPTS  = -Iinclude

COPTS += $(CFLAGS) $(TARGET_CFLAGS) $(SMALL_OPTS) $(DEFINE) $(SILENT_DEFINE)
COPTS += $(DEBUG) $(OPTIONS_CFLAGS) $(ADDINC)

ifneq ($(VERSION)$(SUBVERS)$(EXTRAVERSION),)
  COPTS += -DCONFIG_HAPROXY_VERSION=\"$(VERSION)$(SUBVERS)$(EXTRAVERSION)\"
endif

ifneq ($(VERDATE),)
  COPTS += -DCONFIG_HAPROXY_DATE=\"$(VERDATE)\"
endif

ifneq ($(TRACE),)
  # if tracing is enabled, we want it to be as fast as possible
  TRACE_COPTS := $(filter-out -O0 -O1 -O2 -pg -finstrument-functions,$(COPTS)) -O3 -fomit-frame-pointer
  COPTS += -finstrument-functions
endif

#### Global link options
# These options are added at the end of the "ld" command line. Use LDFLAGS to
# add options at the beginning of the "ld" command line if needed.
LDOPTS = $(TARGET_LDFLAGS) $(OPTIONS_LDFLAGS) $(ADDLIB)

ifeq ($(TARGET),)
all:
	@echo "Building HAProxy without specifying a TARGET is not supported."
	@echo
	@echo "Usage:"
	@echo
	@echo "    $ make help                       # To print a full explanation."
	@echo "    $ make TARGET=xxx USE_<feature>=1 # To build HAProxy."
	@echo
	@echo "The most commonly used targets are:"
	@echo
	@echo "    linux-glibc    - Modern Linux with glibc"
	@echo "    linux-musl     - Modern Linux with musl"
	@echo "    freebsd        - FreeBSD"
	@echo "    openbsd        - OpenBSD"
	@echo "    netbsd         - NetBSD"
	@echo "    osx            - macOS"
	@echo "    solaris        - Solaris"
	@echo
	@echo "Choose the target which matches your OS the most in order to"
	@echo "gain the maximum performance out of it."
	@echo
	@echo "Common features you might want to include in your build are:"
	@echo
	@echo "    USE_OPENSSL=1 - Support for TLS encrypted connections"
	@echo "    USE_ZLIB=1    - Support for HTTP response compression"
	@echo "    USE_PCRE=1    - Support for PCRE regular expressions"
	@echo "    USE_LUA=1     - Support for dynamic processing using Lua"
	@echo
	@echo "Use 'make help' to print a full explanation of supported targets"
	@echo "and features."
	@echo
	@exit 1
else
ifneq ($(filter $(TARGET), linux linux22 linux24 linux24e linux26 linux2628),)
all:
	@echo
	@echo "Target '$(TARGET)' was removed from HAProxy 2.0 due to being irrelevant and"
	@echo "often wrong. Please use 'linux-glibc' instead or define your custom target"
	@echo "by checking available options using 'make help TARGET=<your-target>'."
	@echo
	@exit 1
else
all: haproxy dev/flags/flags $(EXTRA)
endif # obsolete targets
endif # TARGET

OBJS =

ifneq ($(EXTRA_OBJS),)
  OBJS += $(EXTRA_OBJS)
endif

OBJS += src/mux_h2.o src/mux_fcgi.o src/mux_h1.o src/tcpcheck.o               \
        src/stream.o src/stats.o src/http_ana.o src/server.o                  \
        src/stick_table.o src/sample.o src/flt_spoe.o src/tools.o             \
        src/log.o src/cfgparse.o src/peers.o src/backend.o src/resolvers.o    \
        src/cli.o src/connection.o src/proxy.o src/http_htx.o                 \
        src/cfgparse-listen.o src/pattern.o src/check.o src/haproxy.o         \
        src/cache.o src/stconn.o src/http_act.o src/http_fetch.o              \
        src/http_client.o src/listener.o src/dns.o src/vars.o src/debug.o     \
        src/tcp_rules.o src/sink.o src/h1_htx.o src/task.o src/mjson.o        \
        src/h2.o src/filters.o src/server_state.o src/payload.o               \
        src/fcgi-app.o src/map.o src/htx.o src/h1.o src/pool.o                \
        src/cfgparse-global.o src/trace.o src/tcp_sample.o                    \
        src/flt_http_comp.o src/mux_pt.o src/flt_trace.o src/mqtt.o           \
        src/acl.o src/sock.o src/mworker.o src/tcp_act.o src/ring.o           \
        src/session.o src/proto_tcp.o src/fd.o src/channel.o src/activity.o   \
        src/queue.o src/lb_fas.o src/http_rules.o src/extcheck.o              \
        src/flt_bwlim.o src/thread.o src/http.o src/lb_chash.o src/applet.o   \
        src/compression.o src/raw_sock.o src/ncbuf.o src/frontend.o           \
        src/errors.o src/uri_normalizer.o src/http_conv.o src/lb_fwrr.o       \
        src/sha1.o src/proto_sockpair.o src/mailers.o src/lb_fwlc.o           \
        src/ebmbtree.o src/cfgcond.o src/action.o src/xprt_handshake.o        \
        src/protocol.o src/proto_uxst.o src/proto_udp.o src/lb_map.o          \
        src/fix.o src/ev_select.o src/arg.o src/sock_inet.o src/event_hdl.o   \
        src/mworker-prog.o src/hpack-dec.o src/cfgparse-tcp.o                 \
        src/sock_unix.o src/shctx.o src/proto_uxdg.o src/fcgi.o               \
        src/eb64tree.o src/clock.o src/chunk.o src/cfgdiag.o src/signal.o     \
        src/regex.o src/lru.o src/eb32tree.o src/eb32sctree.o                 \
        src/cfgparse-unix.o src/hpack-tbl.o src/ebsttree.o src/ebimtree.o     \
        src/base64.o src/auth.o src/uri_auth.o src/time.o src/ebistree.o      \
        src/dynbuf.o src/wdt.o src/pipe.o src/init.o src/http_acl.o           \
        src/hpack-huff.o src/hpack-enc.o src/dict.o src/freq_ctr.o            \
        src/ebtree.o src/hash.o src/dgram.o src/version.o

ifneq ($(TRACE),)
  OBJS += src/calltrace.o
endif

# Used only for forced dependency checking. May be cleared during development.
INCLUDES = $(wildcard include/*/*.h)
DEP = $(INCLUDES) .build_opts

help:
	@sed -ne "/^[^#]*$$/q;s/^# \{0,1\}\(.*\)/\1/;p" Makefile
	@echo; \
	   if [ -n "$(TARGET)" ]; then \
	     if [ -n "$(set_target_defaults)" ]; then \
	        echo "Current TARGET: $(TARGET)"; \
	     else \
	        echo "Current TARGET: $(TARGET) (custom target)"; \
	     fi; \
	   else \
	     echo "TARGET not set, you may pass 'TARGET=xxx' to set one among :";\
	     echo "  linux-glibc, linux-glibc-legacy, solaris, freebsd, dragonfly, netbsd,"; \
	     echo "  osx, openbsd, aix51, aix52, aix72-gcc, cygwin, haiku, generic,"; \
	     echo "  custom"; \
	   fi
	@echo;echo "Enabled features for TARGET '$(TARGET)' (disable with 'USE_xxx=') :"
	@set -- $(enabled_opts); echo "  $$*" | (fmt || cat) 2>/dev/null
	@echo;echo "Disabled features for TARGET '$(TARGET)' (enable with 'USE_xxx=1') :"
	@set -- $(disabled_opts); echo "  $$*" | (fmt || cat) 2>/dev/null

# Used only to force a rebuild if some build options change, but we don't do
# it for certain targets which take no build options
ifneq (reg-tests, $(firstword $(MAKECMDGOALS)))
build_opts = $(shell rm -f .build_opts.new; echo \'$(TARGET) $(BUILD_OPTIONS) $(VERBOSE_CFLAGS) $(DEBUG)\' > .build_opts.new; if cmp -s .build_opts .build_opts.new; then rm -f .build_opts.new; else mv -f .build_opts.new .build_opts; fi)
.build_opts: $(build_opts)
else
.build_opts:
endif # reg-tests

haproxy: $(OPTIONS_OBJS) $(OBJS)
	$(cmd_LD) $(LDFLAGS) -o $@ $^ $(LDOPTS)

objsize: haproxy
	$(Q)objdump -t $^|grep ' g '|grep -F '.text'|awk '{print $$5 FS $$6}'|sort

%.o:	%.c $(DEP)
	$(cmd_CC) $(COPTS) -c -o $@ $<

admin/halog/halog: admin/halog/halog.o admin/halog/fgets2.o src/ebtree.o src/eb32tree.o src/eb64tree.o src/ebmbtree.o src/ebsttree.o src/ebistree.o src/ebimtree.o
	$(cmd_LD) $(LDFLAGS) -o $@ $^ $(LDOPTS)

admin/dyncookie/dyncookie: admin/dyncookie/dyncookie.o
	$(cmd_LD) $(LDFLAGS) -o $@ $^ $(LDOPTS)

dev/flags/flags: dev/flags/flags.o
	$(cmd_LD) $(LDFLAGS) -o $@ $^ $(LDOPTS)

dev/haring/haring: dev/haring/haring.o
	$(cmd_LD) $(LDFLAGS) -o $@ $^ $(LDOPTS)

dev/hpack/%: dev/hpack/%.o
	$(cmd_LD) $(LDFLAGS) -o $@ $^ $(LDOPTS)

dev/poll/poll:
	$(cmd_MAKE) -C dev/poll poll CC='$(CC)' OPTIMIZE='$(COPTS)' V='$(V)'

dev/qpack/decode: dev/qpack/decode.o
	$(cmd_LD) $(LDFLAGS) -o $@ $^ $(LDOPTS)

dev/tcploop/tcploop:
	$(cmd_MAKE) -C dev/tcploop tcploop CC='$(CC)' OPTIMIZE='$(COPTS)' V='$(V)'

dev/udp/udp-perturb: dev/udp/udp-perturb.o
	$(cmd_LD) $(LDFLAGS) -o $@ $^ $(LDOPTS)

# rebuild it every time
.PHONY: src/version.c dev/poll/poll dev/tcploop/tcploop

src/calltrace.o: src/calltrace.c $(DEP)
	$(cmd_CC) $(TRACE_COPTS) -c -o $@ $<

src/haproxy.o:	src/haproxy.c $(DEP)
	$(cmd_CC) $(COPTS) \
	      -DBUILD_TARGET='"$(strip $(TARGET))"' \
	      -DBUILD_ARCH='"$(strip $(ARCH))"' \
	      -DBUILD_CPU='"$(strip $(CPU))"' \
	      -DBUILD_CC='"$(strip $(CC))"' \
	      -DBUILD_CFLAGS='"$(strip $(VERBOSE_CFLAGS))"' \
	      -DBUILD_OPTIONS='"$(strip $(BUILD_OPTIONS))"' \
	      -DBUILD_DEBUG='"$(strip $(DEBUG))"' \
	      -DBUILD_FEATURES='"$(strip $(build_features))"' \
	       -c -o $@ $<

install-man:
	$(Q)$(INSTALL) -d "$(DESTDIR)$(MANDIR)"/man1
	$(Q)$(INSTALL) -m 644 doc/haproxy.1 "$(DESTDIR)$(MANDIR)"/man1

EXCLUDE_DOCUMENTATION = lgpl gpl coding-style
DOCUMENTATION = $(filter-out $(EXCLUDE_DOCUMENTATION),$(patsubst doc/%.txt,%,$(wildcard doc/*.txt)))

install-doc:
	$(Q)$(INSTALL) -d "$(DESTDIR)$(DOCDIR)"
	$(Q)for x in $(DOCUMENTATION); do \
		$(INSTALL) -m 644 doc/$$x.txt "$(DESTDIR)$(DOCDIR)" ; \
	done

install-bin:
	$(Q)for i in haproxy $(EXTRA); do \
		if ! [ -e "$$i" ]; then \
			echo "Please run 'make' before 'make install'."; \
			exit 1; \
		fi; \
	done
	$(Q)$(INSTALL) -d "$(DESTDIR)$(SBINDIR)"
	$(Q)$(INSTALL) haproxy $(EXTRA) "$(DESTDIR)$(SBINDIR)"

install: install-bin install-man install-doc

uninstall:
	$(Q)rm -f "$(DESTDIR)$(MANDIR)"/man1/haproxy.1
	$(Q)for x in $(DOCUMENTATION); do \
		rm -f "$(DESTDIR)$(DOCDIR)"/$$x.txt ; \
	done
	$(Q)-rmdir "$(DESTDIR)$(DOCDIR)"
	$(Q)rm -f "$(DESTDIR)$(SBINDIR)"/haproxy

clean:
	$(Q)rm -f *.[oas] src/*.[oas] haproxy test .build_opts .build_opts.new
	$(Q)for dir in . src dev/* admin/* addons/* include/* doc; do rm -f $$dir/*~ $$dir/*.rej $$dir/core; done
	$(Q)rm -f haproxy-$(VERSION).tar.gz haproxy-$(VERSION)$(SUBVERS)$(EXTRAVERSION).tar.gz
	$(Q)rm -f haproxy-$(VERSION) haproxy-$(VERSION)$(SUBVERS)$(EXTRAVERSION) nohup.out gmon.out
	$(Q)rm -f addons/promex/*.[oas]
	$(Q)rm -f addons/51degrees/*.[oas] addons/51degrees/dummy/*.[oas] addons/51degrees/dummy/*/*.[oas]
	$(Q)rm -f addons/deviceatlas/*.[oas] addons/deviceatlas/dummy/*.[oas] addons/deviceatlas/dummy/*.o
	$(Q)rm -f addons/deviceatlas/dummy/Os/*.o
	$(Q)rm -f addons/ot/src/*.[oas]
	$(Q)rm -f addons/wurfl/*.[oas] addons/wurfl/dummy/*.[oas]
	$(Q)rm -f admin/*/*.[oas] admin/*/*/*.[oas]
	$(Q)rm -f admin/iprange/iprange admin/iprange/ip6range admin/halog/halog
	$(Q)rm -f admin/dyncookie/dyncookie
	$(Q)rm -f dev/*/*.[oas]
	$(Q)rm -f dev/flags/flags dev/haring/haring dev/poll/poll dev/tcploop/tcploop
	$(Q)rm -f dev/hpack/decode dev/hpack/gen-enc dev/hpack/gen-rht
	$(Q)rm -f dev/qpack/decode

tags:
	$(Q)find src include \( -name '*.c' -o -name '*.h' \) -print0 | \
	   xargs -0 etags --declarations --members

cscope:
	$(Q)find src include -name "*.[ch]" -print | cscope -q -b -i -

tar:	clean
	$(Q)ln -s . haproxy-$(VERSION)$(SUBVERS)$(EXTRAVERSION)
	$(Q)tar --exclude=haproxy-$(VERSION)$(SUBVERS)$(EXTRAVERSION)/.git \
	    --exclude=haproxy-$(VERSION)$(SUBVERS)$(EXTRAVERSION)/haproxy-$(VERSION)$(SUBVERS)$(EXTRAVERSION) \
	    --exclude=haproxy-$(VERSION)$(SUBVERS)$(EXTRAVERSION)/haproxy-$(VERSION)$(SUBVERS)$(EXTRAVERSION).tar.gz \
	    -cf - haproxy-$(VERSION)$(SUBVERS)$(EXTRAVERSION)/* | gzip -c9 >haproxy-$(VERSION)$(SUBVERS)$(EXTRAVERSION).tar.gz
	$(Q)echo haproxy-$(VERSION)$(SUBVERS)$(EXTRAVERSION).tar.gz
	$(Q)rm -f haproxy-$(VERSION)$(SUBVERS)$(EXTRAVERSION)

git-tar:
	$(Q)git archive --format=tar --prefix="haproxy-$(VERSION)$(SUBVERS)$(EXTRAVERSION)/" HEAD | gzip -9 > haproxy-$(VERSION)$(SUBVERS)$(EXTRAVERSION).tar.gz
	$(Q)echo haproxy-$(VERSION)$(SUBVERS)$(EXTRAVERSION).tar.gz

version:
	@echo "VERSION: $(VERSION)"
	@echo "SUBVERS: $(SUBVERS)"
	@echo "VERDATE: $(VERDATE)"

# never use this one if you don't know what it is used for.
update-version:
	@echo "Ready to update the following versions :"
	@echo "VERSION: $(VERSION)"
	@echo "SUBVERS: $(SUBVERS)"
	@echo "VERDATE: $(VERDATE)"
	@echo "Press [ENTER] to continue or Ctrl-C to abort now.";read
	echo "$(VERSION)" > VERSION
	echo "$(SUBVERS)" > SUBVERS
	echo "$(VERDATE)" > VERDATE

# just display the build options
opts:
	@echo -n 'Using: '
	@echo -n 'TARGET="$(strip $(TARGET))" '
	@echo -n 'ARCH="$(strip $(ARCH))" '
	@echo -n 'CPU="$(strip $(CPU))" '
	@echo -n 'CC="$(strip $(CC))" '
	@echo -n 'ARCH_FLAGS="$(strip $(ARCH_FLAGS))" '
	@echo -n 'CPU_CFLAGS="$(strip $(CPU_CFLAGS))" '
	@echo -n 'DEBUG_CFLAGS="$(strip $(DEBUG_CFLAGS))" '
	@echo "$(strip $(BUILD_OPTIONS))"
	@echo 'COPTS="$(strip $(COPTS))"'
	@echo 'LDFLAGS="$(strip $(LDFLAGS))"'
	@echo 'LDOPTS="$(strip $(LDOPTS))"'
	@echo 'OPTIONS_OBJS="$(strip $(OPTIONS_OBJS))"'
	@echo 'OBJS="$(strip $(OBJS))"'

ifeq (reg-tests, $(firstword $(MAKECMDGOALS)))
  REGTEST_ARGS := $(wordlist 2, $(words $(MAKECMDGOALS)), $(MAKECMDGOALS))
  $(eval $(REGTEST_ARGS):;@true)
endif

# Target to run the regression testing script files.
reg-tests:
	$(Q)$(REG_TEST_SCRIPT) --type "$(REGTESTS_TYPES)" $(REGTEST_ARGS) $(REG_TEST_FILES)
.PHONY: $(REGTEST_ARGS)

reg-tests-help:
	@echo
	@echo "To launch the reg tests for haproxy, first export to your environment "
	@echo "VTEST_PROGRAM variable to point to your vtest program:"
	@echo "    $$ export VTEST_PROGRAM=/opt/local/bin/vtest"
	@echo "or"
	@echo "    $$ setenv VTEST_PROGRAM /opt/local/bin/vtest"
	@echo
	@echo "The same thing may be done to set your haproxy program with HAPROXY_PROGRAM "
	@echo "but with ./haproxy as default value."
	@echo
	@echo "To run all the tests:"
	@echo "    $$ make reg-tests"
	@echo
	@echo "You can also set the programs to be used on the command line:"
	@echo "    $$ VTEST_PROGRAM=<...> HAPROXY_PROGRAM=<...> make reg-tests"
	@echo
	@echo "To run tests with specific types:"
	@echo "    $$ REGTESTS_TYPES=slow,default make reg-tests"
	@echo
	@echo "with 'default,bug,devel,slow' as default value for REGTESTS_TYPES variable."
	@echo
	@echo "About the reg test types:"
	@echo "    any         : all the tests without distinction (this is the default"
	@echo "                  value of REGTESTS_TYPES."
	@echo "    default     : dedicated to pure haproxy compliance tests."
	@echo "    slow        : scripts which take non negligible time to run."
	@echo "    bug         : scripts in relation with bugs they help to reproduce."
	@echo "    broken      : scripts triggering known broken behaviors for which"
	@echo "                  there is still no fix."
	@echo "    experimental: for scripts which are experimental, typically used to"
	@echo "                  develop new scripts."
	@echo
	@echo "Note that 'reg-tests' target run '"$(REG_TEST_SCRIPT)"' script"
	@echo "(see --help option of this script for more information)."

.PHONY: reg-tests reg-tests-help
