;=============================================================================+
;  MD5.inc - by Greg Hoyer 7-20-2003            |                             |
;-----------------------------------------------+                             |
;                                                                             |
;   MASM include file for use with the MD5x86ASM library.                     |
;                                                                             |
;   Include MD5.asm in your project or link with MD5.lib                      |
;=============================================================================+




;=============================================================================+
;                                 STRUCTURES                                  |
;=============================================================================|
                                                                             ;|
                                                                             ;|
  MD5HASH struct                                                             ;|
    _a          DWORD    ?                                                   ;|
    _b          DWORD    ?                                                   ;|
    _c          DWORD    ?                                                   ;|
    _d          DWORD    ?                                                   ;|
  MD5HASH ends                                                               ;|
;.............................................................................|
; The MD5HASH  structure is  used by  the calling program  to  contain an MD5 |
; message digest.                                                             |
;.............................................................................|
                                                                             ;|
                                                                             ;|
  MD5CTXT struct                                                             ;|
                DB       88 dup (?)                                          ;|
  MD5CTXT ends                                                               ;|
;.............................................................................|
; The MD5CTXT structure is used to  store intermediate contextual information |
; about the working hash.  Its contents are of no importance to the user.     |
;.............................................................................|
                                                                             ;|
                                                                             ;|
;=============================================================================+




;=============================================================================+
;                                 PROCEDURES                                  |
;=============================================================================|
                                                                             ;|
                                                                             ;|
                                                                             ;|
  MD5_Startup   PROTO                                                        ;|
;-----------------------------------------------------------------------------|
; MD5_Startup initializes the internal  sine table necessary for hashing.  It |
; needs  only to  be called  once, but  it *MUST* be called  before  invoking |
; either MD5_Read or MD5_Digest.                                              |
;                                                                             |
; Arguments: None                                                             |
;                                                                             |
; Return Value: None                                                          |
;                                                                             |
; Modifies Registers: EAX, FPU stack                                          |
;.............................................................................|
                                                                             ;|
                                                                             ;|
                                                                             ;|
  MD5_Init      PROTO    lpMD5CTXT:DWORD                                     ;|
;.............................................................................|
; MD5_Init is  used to initialize  an MD5CTXT  structure for use with         |
; subsequent processing.   It *MUST* be  called for each  instance of         |
; an MD5CTXT  structure, and  can optionally  be called  again on the         |
; same structure to reset it for reuse.                                       |
;                                                                             |
; Arguments:                                                                  |
;   lpMD5CTXT - address of an uninitialized MD5CTXT structure                 |
;                                                                             |
; Return Value: None                                                          |
;                                                                             |
; Modifies Registers: EAX                                                     |
;.............................................................................|
                                                                             ;|
                                                                             ;|
                                                                             ;|
  MD5_Read      PROTO    lpMD5CTXT:DWORD, lpBuf:DWORD, bufLen:DWORD          ;|
;.............................................................................|
; MD5_Read scans a  block of data and  updates the  working context.  Call it |
; once on a single  block of data, or  call it multiple  times on consecutive |
; blocks of data, before retrieving the MD5 signature with MD5_Digest         |
;                                                                             |
; Arguments:                                                                  |
;   lpMD5CTXT - address of an initialized MD5CTXT structure                   |
;   lpBuf     - address of a contiguous block of data                         |
;   bufLen    - the size, in bytes, of the block of data                      |
;                                                                             |
; Return Value: None                                                          |
;                                                                             |
; Modifies Registers: None                                                    |
;.............................................................................|
                                                                             ;|
                                                                             ;|
                                                                             ;|
  MD5_Digest    PROTO    lpMD5CTXT:DWORD, lpMD5HASH:DWORD                    ;|
;.............................................................................|
; MD5_Digest is used to retrieve the MD5 hash for the working context. It may |
; be called at any point during a buffer read to get the current MD5 hash for |
; all data scanned up to that point.  It does not modify the contexutal data, |
; so this procedure may be called as many times as needed.                    |
;                                                                             |
; Arguments:                                                                  |
;   lpMD5CTXT - address of an MD5CTXT structure                               |
;   lpMD5HASH - address of an MD5HASH structure in which to store the message |
;               digest                                                        |
;                                                                             |
; Return Value: None                                                          |
;                                                                             |
; Modifies Registers: None                                                    |
;.............................................................................+
                                                                             ;|
                                                                             ;|
                                                                             ;|
  MD5_Compare   PROTO    lpHash1:DWORD, lpHash2:DWORD                        ;|
;.............................................................................|
; MD5_Compare compares  two MD5 message  digests for inequality.  The MD5HASH |
; structure  referenced by lpHash1  is subtracted by that  of lpHash2 without |
; storing the  result.  On return,  the flags register is set in the same way |
; as is for the  CMP instruction.  This is to simplify branching for assembly |
; programs.  In addition, EAX returns the sign result of the compare. This is |
; to aid in sorting algorithms and the like.                                  |
;                                                                             |
; Arguments:                                                                  |
;   lpHash1   - address of the first MD5HASH structure to be compared         |
;   lpHash2   - address of the second MD5HASH structure to be compared        |
;                                                                             |
; Return Values: EAX = -1 if Hash1  <  Hash2                                  |
;                EAX =  0 if Hash1 ==  Hash2                                  |
;                EAX =  1 if Hash1  >  Hash2                                  |
;                                                                             |
; Modifies Registers: EAX                                                     |
;.............................................................................+
                                                                             ;|
                                                                             ;|
                                                                             ;|
  IFDEF UNICODE                                                              ;|
    MD52String  EQU      MD52StringW                                         ;|
  ELSE                                                                       ;|
    MD52String  EQU      MD52StringA                                         ;|
  ENDIF                                                                      ;|
                                                                             ;|
  MD52StringA   PROTO    lpMD5HASH:DWORD, lpaBuffer:DWORD, bUpper:DWORD      ;|
  MD52StringW   PROTO    lpMD5HASH:DWORD, lpwBuffer:DWORD, bUpper:DWORD      ;|
;.............................................................................|
; MD52String  converts  an  MD5  digest to  a  hexidecimal  character string. |
; MD52StringA  works with  ASCII strings and  MD52StringW works with  UNICODE |
; strings. The buffer referenced by lpxBuffer must be large enough to contain |
; the string.  33 bytes/words is sufficient. (bytes - ASCII, words - UNICODE) |
;                                                                             |
; Arguments:                                                                  |
;   lpMD5HASH - address of an MD5HASH structure containing an MD5 message     |
;               digest.                                                       |
;   lpxBuffer - address of a buffer to hold the string.                       |
;   bUpper    - If this argument is zero, the output string will consist of   |
;               lowercase letters, otherwise the letters will be uppercase.   |
;                                                                             |
; Return Value: For convenience with C/C++, EAX contains the address          |
;               of the buffer passed to the procedure.                        |
;                                                                             |
; Modifies Registers: EAX                                                     |
;=============================================================================+

