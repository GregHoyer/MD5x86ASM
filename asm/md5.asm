;=============================================================================+
;  MD5.asm - by Greg Hoyer 7-20-2003            |                             |
;-----------------------------------------------+                             |
;                                                                             |
;   MASM source file for the MD5x86ASM library.                               |
;                                                                             |
;=============================================================================+
; *****************************************************************************
                                                                            ;**
  .386P                                                                     ;**
  .387                                                                      ;**
  .MODEL FLAT, STDCALL                                                      ;**
  OPTION CASEMAP :NONE                                                      ;**
  OPTION PROLOGUE:NONE                                                      ;**
  OPTION EPILOGUE:NONE                                                      ;**
                                                                            ;**
; *****************************************************************************

  INCLUDE MD5.inc

; *****************************************************************************
                                                                            ;**
.data                                                                       ;**
                                                                            ;**
  MD5InternalData \                                                         ;**
                DB       0,1,1,5,5,3,0,7, \                                 ;**
                         7,5,5,5,5,4,5,6, \                                 ;**
                         4,7,5,7,6,4,5,6                                    ;**
                                                                            ;**
.data?                                                                      ;**
                                                                            ;**
  MD5SineTable  DD       65 dup (?)                                         ;**
                                                                            ;**
    ;The 65th dword is needed because of the way MD5_Startup                ;**
    ;writes overlapping -Q-words directly to the buffer.                    ;**
                                                                            ;**
; *****************************************************************************



.code

; *****************************************************************************
                                                                            ;**
  MD5_Startup   PROC PUBLIC                                                 ;**
                                                                            ;**
; *****************************************************************************
                                                                            ;**
        xor     eax, eax                                                    ;**
        finit                                                               ;**
        push    4F800000h                                                   ;**
        push    0                                                           ;**
        fstcw   word ptr [esp+2]                                            ;**
 g          fstcw   word ptr [esp]                                              ;**
        or      word ptr [esp], 0F3Fh                                       ;**
        fldcw   word ptr [esp]                                              ;**
        push    1                                                           ;**
    @@: fild    dword ptr [esp]                                             ;**
        fsin                                                                ;**
        fabs                                                                ;**
        fmul    dword ptr [esp+8]                                           ;**
        fistp   qword ptr [eax*4+MD5SineTable]                              ;**
        inc     dword ptr [esp]                                             ;**
        inc     eax                                                         ;**
        test    al, 40h                                                     ;**
        jz      @b                                                          ;**
        fldcw   word ptr [esp+6]                                            ;**
        add     esp, 12                                                     ;**
        ret                                                                 ;**
                                                                            ;**
  MD5_Startup   ENDP                                                        ;**
                                                                            ;**
; *****************************************************************************




; *****************************************************************************
                                                                            ;**
  MD5_Init      PROC PUBLIC lpMD5CTXT:DWORD                                 ;**
                                                                            ;**
; *****************************************************************************
                                                                            ;**
        push    edi                                                         ;**
        mov     edi, dword ptr [esp+8]                                      ;**
        mov     al, 01h                                                     ;**
    @@: stosb                                                               ;**
        add     al, 22h                                                     ;**
        jnc     @b                                                          ;**
        mov     al, 0FEh                                                    ;**
    @@: stosb                                                               ;**
        sub     al, 22h                                                     ;**
        jnc     @b                                                          ;**
        xor     eax, eax                                                    ;**
        stosd                                                               ;**
        stosd                                                               ;**
        pop     edi                                                         ;**
        ret     4                                                           ;**
                                                                            ;**
  MD5_Init      ENDP                                                        ;**
                                                                            ;**
; *****************************************************************************




; *****************************************************************************
                                                                            ;**
  MD5_Read      PROC PUBLIC lpMD5CTXT:DWORD, lpBuf:DWORD, bufLen:DWORD      ;**
                                                                            ;**
; *****************************************************************************
                                                                            ;**
        pushad                                                              ;**
        mov     esi, dword ptr [esp+40]                                     ;**
        mov     ebp, dword ptr [esp+36]                                     ;**
        lea     edi, [ebp+24]                                               ;**
        mov     edx, dword ptr [esp+44]                                     ;**
        mov     ebx, edi                                                    ;**
        mov     eax, edx                                                    ;**
        shl     eax, 3                                                      ;**
        mov     ecx, edx                                                    ;**
        shr     ecx, 29                                                     ;**
        push    dword ptr [ebp+16]                                          ;**
        add     dword ptr [ebp+16], eax                                     ;**
        adc     dword ptr [ebp+20], ecx                                     ;**
        pop     eax                                                         ;**
        shr     eax, 3                                                      ;**
        and     eax, 3Fh                                                    ;**
   @mn: xor     ecx, ecx                                                    ;**
        mov     cl, 40h                                                     ;**
        sub     ecx, eax                                                    ;**
        cmp     ecx, edx                                                    ;**
        jbe     @f                                                          ;**
        mov     ecx, edx                                                    ;**
    @@: sub     edx, ecx                                                    ;**
        add     edi, eax                                                    ;**
        add     eax, ecx                                                    ;**
        rep     movsb                                                       ;**
        mov     edi, ebx                                                    ;**
        cmp     eax, 40h                                                    ;**
        jb      @f                                                          ;**
        push    edi                                                         ;**
        push    ebp                                                         ;**
        call    MD5_BTrnsf                                                  ;**
    @@: xor     eax, eax                                                    ;**
        or      edx, edx                                                    ;**
        jnz     @mn                                                         ;**
        popad                                                               ;**
        ret     12                                                          ;**
                                                                            ;**
  MD5_Read      ENDP                                                        ;**
                                                                            ;**
; *****************************************************************************




; *****************************************************************************
                                                                            ;**
  MD5_Digest    PROC PUBLIC lpMD5CTXT:DWORD, lpMD5HASH:DWORD                ;**
                                                                            ;**
; *****************************************************************************
                                                                            ;**
        pushad                                                              ;**
        mov     esi, dword ptr [esp+36]                                     ;**
        mov     edi, dword ptr [esp+40]                                     ;**
        lea     ebp, [esi+16]                                               ;**
        mov     ebx, edi                                                    ;**
        sub     esp, 64                                                     ;**
        movsd                                                               ;**
        movsd                                                               ;**
        movsd                                                               ;**
        movsd                                                               ;**
        lodsd                                                               ;**
        shr     eax, 3                                                      ;**
        add     esi, 4                                                      ;**
        and     eax, 3Fh                                                    ;**
        mov     edi, esp                                                    ;**
        mov     ecx, eax                                                    ;**
        rep     movsb                                                       ;**
        inc     eax                                                         ;**
        sub     ecx, eax                                                    ;**
        mov     al, 80h                                                     ;**
        stosb                                                               ;**
        xor     eax, eax                                                    ;**
        cmp     ecx, -56                                                    ;**
        jae     @f                                                          ;**
        xor     eax, eax                                                    ;**
        add     ecx, 64                                                     ;**
        rep     stosb                                                       ;**
        mov     edi, esp                                                    ;**
        push    edi                                                         ;**
        push    ebx                                                         ;**
        call    MD5_BTrnsf                                                  ;**
    @@: xor     eax, eax                                                    ;**
        add     ecx, 56                                                     ;**
        rep     stosb                                                       ;**
        mov     esi, ebp                                                    ;**
        movsd                                                               ;**
        movsd                                                               ;**
        push    esp                                                         ;**
        push    ebx                                                         ;**
        call    MD5_BTrnsf                                                  ;**
        add     esp, 64                                                     ;**
        popad                                                               ;**
        ret     8                                                           ;**
                                                                            ;**
  MD5_Digest    ENDP                                                        ;**
                                                                            ;**
; *****************************************************************************




; *****************************************************************************
                                                                            ;**
  MD5_BTrnsf    PROC PRIVATE phash:DWORD, lpBlock:DWORD                     ;**
                                                                            ;**
; *****************************************************************************
                                                                            ;**
        pushad                                                              ;**
        mov     eax, dword ptr [esp+36]                                     ;**
        xor     ecx, ecx                                                    ;**
        mov     cl, 4                                                       ;**
    @@: push    dword ptr [eax]                                             ;**
        add     eax, 4                                                      ;**
        loop    @b                                                          ;**
   @mn: mov     ebp, ecx                                                    ;**
        shr     ebp, 12                                                     ;**
        add     dl, dh                                                      ;**
        and     dl, 0Fh                                                     ;**
        test    ch, 03h                                                     ;**
        jnz     @f                                                          ;**
        xor     cl, cl                                                      ;**
        test    ch, 0Fh                                                     ;**
        jnz     @f                                                          ;**
        mov     esi, offset MD5InternalData                                 ;**
        mov     edx, dword ptr [esi+ebp*2]                                  ;**
        mov     ebx, dword ptr [esi+ebp*4+8]                                ;**
    @@: add     cl, bl                                                      ;**
        ror     ebx, 8                                                      ;**
        push    edx                                                         ;**
        push    ecx                                                         ;**
        push    ebx                                                         ;**
        mov     ebx, dword ptr [esp+20]                                     ;**
        mov     ecx, dword ptr [esp+16]                                     ;**
        mov     edx, dword ptr [esp+12]                                     ;**
        test    ebp, 02h                                                    ;**
        jnz     @hi                                                         ;**
        test    ebp, 01h                                                    ;**
        jnz     @f                                                          ;**
        mov     eax, ebx                                                    ;**
        and     ebx, ecx                                                    ;**
        not     eax                                                         ;**
        and     eax, edx                                                    ;**
        or      eax, ebx                                                    ;**
        jmp     @fghi                                                       ;**
    @@: mov     eax, edx                                                    ;**
        and     edx, ebx                                                    ;**
        not     eax                                                         ;**
        and     eax, ecx                                                    ;**
        or      eax, edx                                                    ;**
        jmp     @fghi                                                       ;**
   @hi: test    ebp, 01h                                                    ;**
        jnz     @f                                                          ;**
        mov     eax, ebx                                                    ;**
        xor     eax, ecx                                                    ;**
        xor     eax, edx                                                    ;**
        jmp     @fghi                                                       ;**
    @@: mov     eax, edx                                                    ;**
        not     eax                                                         ;**
        or      eax, ebx                                                    ;**
        xor     eax, ecx                                                    ;**
 @fghi: pop     ebx                                                         ;**
        pop     ecx                                                         ;**
        pop     edx                                                         ;**
        add     eax, dword ptr [esp+12]                                     ;**
        mov     esi, dword ptr [esp+56]                                     ;**
        movzx   edi, dl                                                     ;**
        add     eax, dword ptr [esi+edi*4]                                  ;**
        movzx   esi, ch                                                     ;**
        add     eax, dword ptr [MD5SineTable+esi*4]                         ;**
        rol     eax, cl                                                     ;**
        add     eax, dword ptr [esp+8]                                      ;**
        mov     dword ptr [esp+12], eax                                     ;**
        mov     esi, esp                                                    ;**
        mov     edi, esp                                                    ;**
        lodsd                                                               ;**
        movsd                                                               ;**
        movsd                                                               ;**
        movsd                                                               ;**
        stosd                                                               ;**
        inc     ch                                                          ;**
        test    ch, 40h                                                     ;**
        jz      @mn                                                         ;**
        mov     eax, dword ptr [esp+52]                                     ;**
        xor     ecx, ecx                                                    ;**
        mov     cl, 4                                                       ;**
        sub     eax, ecx                                                    ;**
    @@: pop     edx                                                         ;**
        add     dword ptr [eax+ecx*4], edx                                  ;**
        loop    @b                                                          ;**
        popad                                                               ;**
        ret     8                                                           ;**
                                                                            ;**
  MD5_BTrnsf    ENDP                                                        ;**
                                                                            ;**
; *****************************************************************************



; *****************************************************************************
                                                                            ;**
  MD5_Compare   PROC PUBLIC  lpHash1:DWORD, lpHash2:DWORD                   ;**
                                                                            ;**
; *****************************************************************************
                                                                            ;**
        push    esi                                                         ;**
        push    edi                                                         ;**
        push    ecx                                                         ;**
        mov     esi, dword ptr [esp+16]                                     ;**
        mov     edi, dword ptr [esp+20]                                     ;**
        xor     ecx, ecx                                                    ;**
        mov     cl, 16                                                      ;**
        xor     eax, eax                                                    ;**
        repe    cmpsb                                                       ;**
        pushfd                                                              ;**
        setnz   al                                                          ;**
        jnc     @f                                                          ;**
        sbb     eax, eax                                                    ;**
    @@: popfd                                                               ;**
        pop     ecx                                                         ;**
        pop     edi                                                         ;**
        pop     esi                                                         ;**
        ret     8                                                           ;**
                                                                            ;**
  MD5_Compare   ENDP                                                        ;**
                                                                            ;**
; *****************************************************************************



; *****************************************************************************
                                                                            ;**
  MD52StringW   PROC PUBLIC  lpMD5HASH:DWORD, lpwBuffer:DWORD, bUpper:DWORD ;**
        stc                                                                 ;**
        jmp MD52StringWA                                                    ;**
                                                                            ;**
  MD52StringW   ENDP                                                        ;**
                                                                            ;**
  MD52StringA   PROC PUBLIC  lpMD5HASH:DWORD, lpaBuffer:DWORD, bUpper:DWORD ;**
        clc                                                                 ;**
                                                                            ;**
; *****************************************************************************
                                                                            ;**
  MD52StringWA::                                                            ;**
                                                                            ;**
        pushad                                                              ;**
        mov     esi, dword ptr [esp+36]                                     ;**
        mov     edi, dword ptr [esp+40]                                     ;**
        sbb     ebx, ebx                                                    ;**
        xor     ecx, ecx                                                    ;**
        xor     edx, edx                                                    ;**
        mov     cl, 32                                                      ;**
        cmp     dword ptr [esp+44], edx                                     ;**
        jnz     @f                                                          ;**
        mov     edx, ecx                                                    ;**
    @@: add     edx, 7                                                      ;**
   @mn: push    ecx                                                         ;**
        inc     ecx                                                         ;**
        and     ecx, 1                                                      ;**
        lodsb                                                               ;**
        sub     esi, ecx                                                    ;**
        shl     ecx, 2                                                      ;**
        shr     eax, cl                                                     ;**
        and     eax, 0Fh                                                    ;**
        cmp     al, 10                                                      ;**
        jb      @f                                                          ;**
        add     al, dl                                                      ;**
    @@: add     al, 30h                                                     ;**
        stosb                                                               ;**
        xor     eax, eax                                                    ;**
        or      ebx, ebx                                                    ;**
        jz      @f                                                          ;**
        stosb                                                               ;**
    @@: pop     ecx                                                         ;**
        loop    @mn                                                         ;**
        stosb                                                               ;**
        or      ebx, ebx                                                    ;**
        jz      @f                                                          ;**
        stosb                                                               ;**
    @@: popad                                                               ;**
        mov     eax, dword ptr [esp+8]                                      ;**
        ret     12                                                          ;**
                                                                            ;**
  MD52StringA   ENDP                                                        ;**
                                                                            ;**
; *****************************************************************************


  OPTION PROLOGUE:PROLOGUEDEF
  OPTION EPILOGUE:EPILOGUEDEF

  END