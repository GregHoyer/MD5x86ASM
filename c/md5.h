/*=====================================================================+
|   MD5.h - by Greg Hoyer 7-20-2003              |                     |
|------------------------------------------------+                     |
|                                                                      |
|    C/C++ include file for use with the MD5x86ASM library.            |
|                                                                      |
|    Link with MD5.lib                                                 |
+=====================================================================*/

#ifndef _MD5_H_
#define _MD5_H_

/* DEFINES **********************************************/

#ifdef UNICODE
#define MD52String MD52StringW
#else
#define MD52String MD52StringA
#endif

/* STRUCTURES *******************************************/

/* The MD5HASH structure is used both internally and by */
/* the calling program to contain an MD5 message digest */

typedef struct _MD5HASH
{
    unsigned int    _a;
    unsigned int    _b;
    unsigned int    _c;
    unsigned int    _d;

} MD5HASH;


/* The MD5CTXT structure is used to store intermediate  */
/* contextual information about the working hash.       */

typedef struct _MD5CTXT
{
    char            data[88];

} MD5CTXT;




/* PROCEDURES *******************************************/

#ifdef __cplusplus
extern "C" {
#endif /* __cplusplus */



extern void _stdcall MD5_Startup( void );
/*--------------------------------------------------------------------+
| MD5_Startup   initializes   internal   structures   necessary   for |
| successful hashing.  It needs only to be called once, but it *MUST* |
| be   called   before  invoking  either   MD5_Read   or  MD5_Digest. |
|                                                                     |
| Arguments: None                                                     |
| Return Value: None                                                  |
+--------------------------------------------------------------------*/



extern void _stdcall MD5_Init( MD5CTXT          *lpMD5CTXT );
/*--------------------------------------------------------------------+
| MD5_Init is  used to initialize  an MD5CTXT  structure for use with |
| subsequent processing.   It *MUST* be  called for each  instance of |
| an MD5CTXT  structure, and  can optionally  be called  again on the |
| same structure to reset it for reuse.                               |
|                                                                     |
| Arguments:                                                          |
|   lpMD5CTXT - pointer to an uninitialized MD5CTXT structure         |
|                                                                     |
| Return Value: None                                                  |
+--------------------------------------------------------------------*/



extern void _stdcall MD5_Read( MD5CTXT          *lpMD5CTXT,
                               char             *lpBuf,
                               unsigned int     bufLen      );
/*--------------------------------------------------------------------+
| MD5_Read  scans a  block of  data and  updates the  working context |
| Call it once on  a single block of data, or  call it multiple times |
| on multiple  pieces of  data, before  retrieving the  MD5 signature |
| with MD5_Digest.                                                    |
|                                                                     |
| Arguments:                                                          |
|   lpMD5CTXT - pointer to an initialized MD5CTXT structure           |
|   lpBuf     - pointer to a contiguous block of data                 |
|   bufLen    - the size, in bytes, of the block of data              |
|                                                                     |
| Return Value: None                                                  |
+--------------------------------------------------------------------*/



extern void _stdcall MD5_Digest( MD5CTXT        *lpMD5CTXT,
                                 MD5HASH        *lpMD5HASH  );
/*--------------------------------------------------------------------+
| MD5_Digest  is  used  to  retrieve the  MD5  hash  for the  working |
| context.  It may be called at any point during a buffer read to get |
| the current  MD5 hash  for the data  scanned up to  that point.  It |
| does not  modify the  contextual  data,  so this  procedure may  be |
| called as many times as needed.                                     |
|                                                                     |
| Arguments:                                                          |
|   lpMD5CTXT - pointer to an MD5CTXT structure                       |
|   lpMD5HASH - pointer to an MD5HASH structure which to store the    |
|               message digest.                                       |
|                                                                     |
| Return Value: None                                                  |
+--------------------------------------------------------------------*/



extern int _stdcall MD5_Compare( MD5HASH        *lpHash1,
                                 MD5HASH        *lpHash2    );
/*--------------------------------------------------------------------+
| MD5_Compare compares  two MD5 message  digests for inequality.  The |
| MD5HASH structure  referenced by lpHash1  is subtracted  by that of |
| lpHash2  without storing the  result.  The return value is the sign |
| result of the compare.                                              |
|                                                                     |
| Arguments:                                                          |
|   lpHash1 - pointer to the first MD5HASH structure to be compared   |
|   lpHash2 - pointer to the second MD5HASH structure to be compared  |
|                                                                     |
| Return Values: -1 if Hash1  <  Hash2                                |
|                 0 if Hash1 ==  Hash2                                |
|                 1 if Hash1  >  Hash2                                |
+--------------------------------------------------------------------*/



extern char * _stdcall MD52StringA( MD5HASH     *lpMD5HASH,
                                    char        *lpBuffer,
                                    bool        bUpperCase  );

extern wchar_t * _stdcall MD52StringW( MD5HASH  *lpMD5HASH,
                                       wchar_t  *lpBuffer,
                                       bool     bUpperCase  );
/*--------------------------------------------------------------------+
| MD52String  converts  an  MD5  digest to  a  hexidecimal  character |
| string.   MD52StringA works  with  ASCII  strings  and  MD52StringW |
| works with  UNICODE  strings.  The  buffer referenced  by lpxBuffer |
| must be  large enough to  contain  the string.  33 bytes/words is   |
| sufficient.  (bytes for ASCII, words for UNICODE)                   |
|                                                                     |
| Arguments:                                                          |
|   lpMD5HASH  - pointer to an MD5HASH structure containing an MD5    |
|                message digest.                                      |
|   lpxBuffer  - pointer to a buffer to hold the string.              |
|   bUpperCase - if this parameter is true, the output string will    |
|                contain uppercase letters.  Otherwise the output     |
|                string will be in lowercase.                         |
|                                                                     |
| Return Value: MD52String returns a pointer to the buffer passed to  |
|               the procedure.                                        |
+--------------------------------------------------------------------*/




#ifdef __cplusplus
}
#endif /* __cplusplus */


#endif /* _MD5_H_ */
