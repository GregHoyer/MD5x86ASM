# MD5x86ASM
MD5x86ASM is an MD5 hashing library written in x86 assembly.
### Version
1.0.0
### About
Back in 2003 I wrote this library with size in mind, not speed. The size of the code and data for the main non-utility procedures totals 510 bytes. If you make use of all procedures the size comes to 598 bytes. The reduction is accomplished first by using MD5_Startup to generate the sine table at runtime.  Then the block transform is greatly reduced by stuffing all 64 different transformations into one loop. And then, of course, it's written in assembly, which accounts for most of its compact size.

I posted it to the Win32 ASM Community forums, and it was extensively tested by the users there.  However, that was 2003 and unit testing wasn't as big as it is these days.  At some point I aim to create unit tests for this project.
### About MD5
MD5 is a cryptographic hashing algorithm that produces a 128-bit hash value. It is used in a wide variety of protocols and applications. Please note however that MD5 is not cryptographically secure, and its usage should be relegated to processes where application security is not a concern. Do not use MD5 to hash sensitive data, or things that might give access to sensitive data, such as passwords.

---
## C/C++ usage:

* Link your project with MD5.lib and include MD5.h in your source.
* Usage is very similar to most MD5 hashing libraries. However before you can do anything, you must initialize the sine table by calling MD5_Startup().
* Create a temporary MD5CTXT structure and pass it to the MD5_Init() routine.
* Call MD5_Read, passing a pointer to your initialized MD5CTXT structure and a pointer to the data to read in. This can be done as many times as necessary until all the data has been read.
* Call MD5_Digest, passing a pointer to the MD5CTXT structure and a pointer to a MD5HASH structure. On return, the MD5HASH structure will contain the MD5 hash.
* Use the MD5_Compare function to compare two MD5 hashes.
* To convert the MD5 hash to a string, use the MD52String function, passing a pointer to the MD5HASH structure and a pointer to a buffer at least 33 characters in length.

#### C Example:

    MD5CTXT ctxt;
    MD5HASH hash;
    char str[33]; /* use wchar_t for unicode */
    char data[3] = { 'a', 'b', 'c' };
    
    MD5_Startup();
    MD5_Init( &ctxt );
    MD5_Read( &ctxt, data, 3 );
    MD5_Digest( &ctxt, &hash );
    MD52String( &hash, str, true );
    printf( "MD5(\"abc\") = %s\n", str );  /* 900150983CD24FB0D6963F7D28E17F72 */

#### MASM Example:

    .data?
    ctxt MD5CTXT <>
    hash MD5HASH <>
    strn db 33 dup(?) ; use dw for unicode
    .data
    bdata db "abc"
    .code
    ; Later ...
    invoke MD5_Startup
    invoke MD5_init, offset ctxt
    invoke MD5_Read, offset ctxt, offset bdata, 3
    invoke MD5_Digest, offset ctxt, offset hash
    invoke MD52String, offset hash, offset strn, 1 ; strn = "900150983CD24FB0D6963F7D28E17F72"
