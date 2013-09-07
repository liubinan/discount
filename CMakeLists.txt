cmake_minimum_required(VERSION 2.6)
project(discount)

OPTION(ENABLE_AMALLOC	"Enable memory allocation debugging" ON)
OPTION(WITH_FENCED_CODE	"Allow fenced code blocks" ON)
OPTION(WITH_ID_ANCHOR	"Use id= anchors for table-of-contents links" ON)
OPTION(WITH_GITHUB_TAGS	"Allow `_` and `-` in <> tags" ON)
OPTION(ENABLE_ALL_FEATURES	"Turn on all stable optional features" ON)
SET(WITH_DL "DISCOUNT" CACHE STRING 	"Use Discount, Extra, or Both types of definition list")
SET(TABSTOP 4 CACHE STRING 	"Set tabstops to N characters (default is 4)")

IF(ENABLE_AMALLOC)
	SET(USE_AMALLOC 1)
ENDIF(ENABLE_AMALLOC)

IF(WITH_PANDOC_HEADER)
	SET(PANDOC_HEADER 1)
ENDIF(WITH_PANDOC_HEADER)

STRING(TOUPPER "${WITH_DL}" WITH_DL)
IF(WITH_DL STREQUAL "DISCOUNT" OR WITH_DL STREQUAL "1")
	SET(USE_DISCOUNT_DL 1)
ELSE()
	IF(WITH_DL STREQUAL "EXTRA")
		SET(USE_EXTRA_DL 1)
	ELSE()
		IF(WITH_DL STREQUAL "BOTH")
			SET(USE_DISCOUNT_DL 1)
			SET(USE_EXTRA_DL 1)
		ELSE()
			MESSAGE(FATAL_ERROR "Unknown value <$WITH_DL> for WITH_DL (want 'discount', 'extra', or 'both')")
		ENDIF()
	ENDIF()
ENDIF()

INCLUDE(CheckFunctionExists)
INCLUDE(CheckTypeSize)
INCLUDE(CheckIncludeFile)
INCLUDE(CheckIncludeFileCXX)
INCLUDE(CheckCXXSourceRuns)

CHECK_INCLUDE_FILE("malloc.h" HAVE_MALLOC_H)
CHECK_INCLUDE_FILE("sys/types.h" HAVE_SYS_TYPES_H)
CHECK_INCLUDE_FILE("pwd.h" HAVE_PWD_H)
CHECK_FUNCTION_EXISTS("getpwuid" HAVE_GETPWUID)

CHECK_FUNCTION_EXISTS("srandom" HAVE_SRANDOM)
IF(HAVE_SRANDOM)
	SET(INITRNG_MACRO "srandom((unsigned int)x)")
ELSE(HAVE_SRANDOM)
	CHECK_FUNCTION_EXISTS("srand" HAVE_SRAND)
	IF(HAVE_SRAND)
		SET(INITRNG_MACRO "srand((unsigned int)x)")
	ELSE(HAVE_SRAND)
		SET(INITRNG_MACRO "(void)1")
	ENDIF(HAVE_SRAND)
ENDIF(HAVE_SRANDOM)

CHECK_FUNCTION_EXISTS("bzero" HAVE_BZERO)
CHECK_FUNCTION_EXISTS("memset" HAVE_MEMSET)
IF(NOT HAVE_BZERO AND NOT HAVE_MEMSET)
	MESSAGE(FATAL_ERROR "can not find function bzero nor memset")
ENDIF()

CHECK_FUNCTION_EXISTS("random" HAVE_RANDOM)
IF(HAVE_RANDOM)
	SET(COINTOSS_MACRO "(random()&1)")
ELSE(HAVE_RANDOM)
	CHECK_FUNCTION_EXISTS("rand" HAVE_RAND)
	IF(HAVE_RAND)
		SET(COINTOSS_MACRO "(rand()&1)")
	ELSE(HAVE_RAND)
		SET(COINTOSS_MACRO "1")
	ENDIF(HAVE_RAND)
ENDIF(HAVE_RANDOM)

CHECK_FUNCTION_EXISTS("strcasecmp" HAVE_STRCASECMP)
CHECK_FUNCTION_EXISTS("stricmp" HAVE_STRICMP)
IF(NOT HAVE_STRCASECMP AND NOT HAVE_STRICMP)
	MESSAGE(FATAL_ERROR "can not find function strcasecmp nor stricmp")
ENDIF()

CHECK_FUNCTION_EXISTS("strncasecmp" HAVE_STRNCASECMP)
CHECK_FUNCTION_EXISTS("strnicmp" HAVE_STRNICMP)
IF(NOT HAVE_STRNCASECMP AND NOT HAVE_STRNICMP)
	MESSAGE(FATAL_ERROR "can not find function strncasecmp nor strnicmp")
ENDIF()

CHECK_CXX_SOURCE_RUNS("
#include <string.h>
extern char *basename(char*);
main()
{
    char *a = basename(\"/a/test\");
    char *b = basename(\"/a/nother\");
    return (strcmp(a,b) == 0) ? 0 : 1;
}
" HAVE_BASENAME)
IF(HAVE_BASENAME)
	CHECK_INCLUDE_FILE("libgen.h" HAVE_LIBGEN_H)
ENDIF(HAVE_BASENAME)

CHECK_TYPE_SIZE("unsigned int" UINT_SIZE)
IF(UINT_SIZE EQUAL 4)
	set(DWORD "unsigned int")
ELSE()
	set(DWORD "unsigned long")
ENDIF()

FILE(STRINGS "VERSION" DISCOUNT_VERSION)

configure_file(${PROJECT_SOURCE_DIR}/config.h.cmake ${PROJECT_SOURCE_DIR}/config.h)
configure_file(${PROJECT_SOURCE_DIR}/version.c.in ${PROJECT_SOURCE_DIR}/version.c)
configure_file(${PROJECT_SOURCE_DIR}/mkdio.h.in ${PROJECT_SOURCE_DIR}/mkdio.h)

SET(LIBMARKDOWN_SOURCES
	mkdio.c 
	markdown.c 
	dumptree.c 
	generate.c
    resource.c
	docheader.c
	version.c
	toc.c
	css.c
    xml.c
	Csio.c
	xmlpage.c
	basename.c
	emmatch.c
    github_flavoured.c
	setup.c
	tags.c
	html5.c
	flags.c
)

IF(USE_AMALLOC)
	SET(LIBMARKDOWN_SOURCES ${LIBMARKDOWN_SOURCES} amalloc.c)
ENDIF(USE_AMALLOC)

INCLUDE_DIRECTORIES(${PROJECT_SOURCE_DIR})

ADD_EXECUTABLE(mktags mktags.c)

ADD_CUSTOM_TARGET(blocktags COMMAND mktags > ${PROJECT_SOURCE_DIR}/blocktags DEPENDS mktags)

ADD_LIBRARY(libmarkdown ${LIBMARKDOWN_SOURCES})

SET_TARGET_PROPERTIES(libmarkdown PROPERTIES OUTPUT_NAME markdown)

ADD_DEFINITIONS(-DVERSION="${DISCOUNT_VERSION}")

ADD_DEPENDENCIES(libmarkdown blocktags)

# example programs
CHECK_FUNCTION_EXISTS("fchdir" HAVE_FCHDIR)
CHECK_FUNCTION_EXISTS("getcwd" HAVE_GETCWD)
IF(HAVE_FCHDIR OR HAVE_GETCWD)
	ADD_EXECUTABLE(theme theme.c pgm_options.c)
	TARGET_LINK_LIBRARIES(theme libmarkdown)
	SET(SAMPLE_PGMS ${SAMPLE_PGMS} theme)
ENDIF()

ADD_EXECUTABLE(mkd2html mkd2html.c)
TARGET_LINK_LIBRARIES(mkd2html libmarkdown)
SET(SAMPLE_PGMS ${SAMPLE_PGMS} mkd2html)

ADD_EXECUTABLE(makepage makepage.c pgm_options.c)
TARGET_LINK_LIBRARIES(makepage libmarkdown)
SET(SAMPLE_PGMS ${SAMPLE_PGMS} makepage)


ADD_EXECUTABLE(markdown main.c pgm_options.c)
TARGET_LINK_LIBRARIES(markdown libmarkdown)

INSTALL(TARGETS libmarkdown markdown ${SAMPLE_PGMS}
        RUNTIME DESTINATION bin
        LIBRARY DESTINATION lib
        ARCHIVE DESTINATION lib)
INSTALL(FILES mkdio.h DESTINATION include)
