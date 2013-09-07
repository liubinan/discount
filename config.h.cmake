#ifndef DISCOUNT_MARKDOWN_H_
#define DISCOUNT_MARKDOWN_H_

#cmakedefine USE_EXTRA_DL 1
#cmakedefine USE_DISCOUNT_DL 1
#cmakedefine WITH_FENCED_CODE 1
#cmakedefine WITH_ID_ANCHOR 1
#cmakedefine WITH_GITHUB_TAGS 1
#cmakedefine HAVE_SYS_TYPES_H 1
#cmakedefine HAVE_PWD_H 1
#cmakedefine GETPWUID 1
#define INITRNG(x) ${INITRNG_MACRO}

// basename function
#cmakedefine HAVE_BASENAME 1
// libgen.h
#cmakedefine HAVE_LIBGEN_H 1

#cmakedefine HAVE_BZERO	1
#cmakedefine HAVE_MEMSET 1
#if !HAVE_BZERO && HAVE_MEMSET
#define bzero(p,s) memset(p,s,0)
#endif

#define COINTOSS() ${COINTOSS_MACRO}

#cmakedefine HAVE_STRCASECMP 1
#cmakedefine HAVE_STRICMP 1
#if !HAVE_STRCASECMP && HAVE_STRICMP
#define strcasecmp stricmp
#endif

#cmakedefine HAVE_STRNCASECMP 1
#cmakedefine HAVE_STRNICMP 1
#if !HAVE_STRNCASECMP && HAVE_STRNICMP
#define strncasecmp strnicmp
#endif

#define TABSTOP ${TABSTOP}
#cmakedefine USE_AMALLOC 1
#cmakedefine HAVE_MALLOC_H 1
#cmakedefine PANDOC_HEADER 1

// function fchdir
#cmakedefine HAVE_FCHDIR 1
// function getcwd
#cmakedefine HAVE_GETCWD 1

#define BYTE unsigned char
#define DWORD ${DWORD}

#endif //DISCOUNT_MARKDOWN_H_
