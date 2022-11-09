.686
.model flat,c
.stack 100h

.data
;nothing

.code

; important information:
; parameter passing and cdecl/stdcall
; 
; CDECL
; parameters are pushed on the stack from right-to-left
; caller must clean up the stack after the call
;
; STDCALL
; callee must clean the stack
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; uint32_t asm_strlen(const char *arg)
;
; what it does: returns the length of passed in C-string. "fuck" returns 4 (because this function doesnt count the null terminator)
; i guess this is one way to do it
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
asm_strlen proc
    xor eax, eax        ; zero eax
    xor ecx, ecx        ; zero rcx
    mov edi, [esp+4]    ; get arg
    not ecx             ; flip ecx bits (FFFFFFFF)
    cld                 ; Clear Direction Flag (why? apparently its 'good practice', could be left from a previous cpu instruction..)
    repnz scasb         ; repnz scasb / also repnz==repne
    not ecx             ; flip ecx bits
    dec ecx             ; decrease one from ecx (NUL)
    mov eax, ecx        ; ecx into "return register"
    ret                 ; return
asm_strlen endp
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


; char* asm_strchr(const char *str, int ch)
;
; what it does: returns a pointer to the first occurrence of ch in str,
;
asm_strchr proc
    xor eax, eax        ; need to zero eax, because i need the string length
    xor ecx, ecx        ; this needs to be zeroed too
    mov edi, [esp+4]    ; arg1 into edi
    
    ; need string length
    push edi            ; store edi
    not ecx             ;
    cld                 ; again i dont know, but 'good practice'
    repnz scasb         ; looks for *eax in edi
    not ecx             ; 
    dec ecx             ; 
    pop edi             ; get edi from stack

    mov eax, [esp+8]    ; arg2 into eax
    repne scasb         ; looking for EAX in EDI byte -> edi gets incremented automatically
    jnz notfound

    dec edi             ; not the next character
    mov eax, edi        ; return pointer to that character
    ret
notfound:
    xor eax, eax        ; this should be equivelant to NULL
    ret
asm_strchr endp

; void* asm_memcpy(void *dst, const void *src, uint32_t count);
;
; what it does: copies *src to *dst with the size COUNT
;
asm_memcpy proc
    mov edi, dword ptr [esp+4]  ; dst
    mov esi, dword ptr [esp+8]  ; src
    mov ecx, [esp+12]           ; count

    rep movsb                   ; repeat / move 'string' byte

    mov eax, dword ptr [esp+4]  ; returns a copy of dest
    ret
asm_memcpy endp

; void* asm_memset(void *dst, int ch, uint32_t count);
;
; what it does: sets a block of memory to some value
;
asm_memset proc
    ; this is easy mode.
    mov edi, dword ptr [esp+4]  ; destination
    mov eax, [esp+8]            ; ch
    mov ecx, [esp+12]           ; count

    rep stosb                   ; repeat / store as string byte

    mov eax, dword ptr [esp+4]  ; returns a copy of dest
    ret
asm_memset endp

; int asm_strcmp(const char *arg, const char *arg2);
;
; what it does: compares two c-strings and returns 0 if they are the same or 1 if they are different...? or something like that
;
; NOTE:
; i do not care about the 'lexicographical order'
; therefore this function is only good for checking if strings match
;
; returns 0 if strings match, -1 otherwise
asm_strcmp proc
    ; considering this is case-sensitive, i can just literally compare the data
    ; need cmpsb
    xor eax, eax        ; yeap
    xor ecx, ecx        ; test
    mov esi, [esp+4]    ; first arg /my idiot self thought i could do dword ptr [esp+4]
    mov edi, [esp+8]    ; second arg

    ; almost a direct copy of my strlen function
    push edi            ; push these onto the stack
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    not ecx             ; flip ecx bits (FFFFFFFF)
    cld                 ; i dont even know if i need to do this, but 'good practice' so..
    repnz scasb         ; repnz scasb / also repnz==repne
    not ecx             ; flip ecx bits
    dec ecx             ; decrease one from ecx (NUL)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    pop edi             ; pop back from the stack

    repe cmpsb          ; commit comparision... if the length isnt the same they dont match anyway..
    jnz mismatch        ; if zeroflag is not set -> mismatch
    xor eax, eax        ; result is 0
    ret                 ; return
mismatch:
    mov eax, -1         ; -1 if they dont match
    ret                 ; return
asm_strcmp endp

; char* asm_strset(char* str, int ch);
;
; what it does: sets all characters (except the terminating null character) of str to c
; str / Null-terminated string to be set.
; c / Character setting.
; https://docs.microsoft.com/en-us/cpp/c-runtime-library/reference/strset-strset-l-wcsset-wcsset-l-mbsset-mbsset-l?view=msvc-160 
; is this not just movsb
; again need string length..
; char will go in c
asm_strset proc
    xor eax, eax        ; zero eax
    xor ecx, ecx        ; zero ecx
    mov edi, [esp+4]    ; first arg

    ; get string length
    push edi
    not ecx
    cld
    repnz scasb
    not ecx
    dec ecx
    pop edi

    mov eax, [esp+8]    ; second arg

    rep stosb           ; overwrite data..

    dec edi             ; not the NUL character
    mov eax, [esp+4]    ; returns a pointer to the altered string.
    ret
asm_strset endp

;; just experimenting
asm_testfunc proc
;; faster string length. Lol
;; apparently i didnt know what the 'neg' instruction actually does... whoops
    xor eax, eax
    mov edi, [esp+4]
    or ecx, 0FFFFFFFFh
    repne scasb
    add ecx, 2
    neg ecx
    mov eax, ecx
    ret
asm_testfunc endp

asm_strcmp2 proc
    xor ecx, ecx
    xor eax, eax
loop_cmp:
    movzx eax, byte ptr [edi+ecx]
    movzx edx, byte ptr [esi+ecx]
    cmp al, dl
    jne exit_proc
    inc ecx
    test al, al
    jne loop_cmp
exit_proc:
    sub eax, edx
    ret
asm_strcmp2 endp


asm_strncat proc
    mov rbx, rdx
    push rcx
    push rdx
    push r8

    mov rcx, rdx
    call asm_strlen
    add rax, 1

    pop rcx
    pop rsi
    pop rdi
    add rsi, rax
    rep stosb

    mov rax, rbx
    ret
asm_strncat endp
END