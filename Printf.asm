section	.text
    global Printf

;====================================================================================================
;====================================================================================================
;========================== Uncomment next lines for using in asm ===================================
;====================================================================================================
;====================================================================================================

;    global _start    ; необходимо для линкера (ld)
  

; section .data
; msg db 'POLTORASHKA %%z %b %d %o %c %s %b RULEZ $', 0xa, 0      ; Our string
; string1 db 'THIS is COOL!!!', 0xa, 0

; section .text

; _start:
; push r11
; mov r15, string1
; push r15
; push r11
; push 120
; push 120
; push 120
; mov r10, msg
; push r10
; call Printf
; pop rbx 
; pop rbx 
; pop rbx 
; pop rbx 
; pop rbx 
; pop rbx 
; pop rbx

; mov	rax, 1       ; номер системного вызова (sys_exit)
; int	0x80         ; вызов ядра 


;====================================================================================================
;====================================================================================================
;========================================== PRINTF ==================================================
;====================================================================================================
;====================================================================================================

;------------------------------------------------------
; My printf on asm
; Entry: First six arguments located in rdi, rsi, rdx, rcx, r8, r9 (in accordance with "System V ABI" agreement)
;        Other arguments located in stack. RDI(C) order. 
;        
;
; Destr: rax, r11, r10
;------------------------------------------------------
Printf:
    pop  rax    ; save ret address
    push r9
    push r8
    push rcx    ; Push first six arguments
    push rdx
    push rsi
    push rdi
   
    push rbx
    push rbp
    push r12    ; Save this registers (in accordance with "System V ABI" agreement)
    push r13 
    push r14
    push r15
    
    mov r15, rax    ; Save ret address in r15
    mov rbp, rsp
    add rbp, 8 * 6  ; Skip saved value registers

    mov r8, Buffer  ; Address to print buffer

    mov rsi, 0      ; buffer offset 
    mov rdx, 0      ; JMP table offset
    
    mov rdi, [rbp]  ; string offset

Print_next: 
    mov dl, byte [rdi] ; New char

    cmp dl, 0          ; End 
    je END_PRINTF

    cmp dl, '%'        ; Modificator %
    je SPECIFIER

    mov byte [r8 + rsi], dl ; Just print this char
    inc rsi
    
    cmp rsi, Size_buff
    jne AFTER_PRINT_BUFFER1
    call Print_buffer   ; Overflow

AFTER_PRINT_BUFFER1:

    inc rdi
    jmp Print_next  ; Next char

SPECIFIER:
    mov dl, byte [rdi + 1] ; Char after %

    cmp dl, '%'            ; Double %
    je PERCENT_PRINT

    cmp dl, 0              ; End
    je PRINT_AND_END


    mov r9, qword [Jump_table + 8 * (rdx - 97) ] ; 97 = 'a'
    jmp r9  ; go to JMP TABLE

Spec_a: jmp SKIP_CHAR
Spec_b: jmp BIN_PRINT
Spec_c: jmp CHAR_PRINT
Spec_d: jmp DEC_PRINT
Spec_e: jmp SKIP_CHAR
Spec_f: jmp SKIP_CHAR
Spec_g: jmp SKIP_CHAR
Spec_h: jmp SKIP_CHAR
Spec_i: jmp SKIP_CHAR
Spec_j: jmp SKIP_CHAR
Spec_k: jmp SKIP_CHAR
Spec_l: jmp SKIP_CHAR
Spec_m: jmp SKIP_CHAR
Spec_n: jmp SKIP_CHAR
Spec_o: jmp OCTAL_PRINT
Spec_p: jmp SKIP_CHAR
Spec_q: jmp SKIP_CHAR
Spec_r: jmp SKIP_CHAR
Spec_s: jmp STRING_PRINT
Spec_t: jmp SKIP_CHAR
Spec_u: jmp SKIP_CHAR
Spec_v: jmp SKIP_CHAR
Spec_w: jmp SKIP_CHAR
Spec_x: jmp HEX_PRINT
Spec_y: jmp SKIP_CHAR
Spec_z: jmp SKIP_CHAR

SKIP_CHAR:    ; Just skip char '%' !!!!!!!WARNING!!!!!!! IT's YOUR MISTAKE
    add rdi, 1
    jmp Print_next

PRINT_AND_END: ; Add to print '%'

    mov dl, '%'
    mov [r8 + rsi], dl  
    inc rsi

    jmp END_PRINTF
    

CHAR_PRINT: ; Add to print next arg how char (%c)
    add rbp, 8
    mov dl, [rbp]

    mov [r8 + rsi], dl
    inc rsi

    cmp rsi, Size_buff
    jne AFTER_PRINT_BUFFER2
    call Print_buffer

    jmp AFTER_PRINT_BUFFER2

AFTER_PRINT_BUFFER2:

    add rdi, 2  ; Skip % and specificator
    jmp Print_next

STRING_PRINT: ; Add to print next arg how string

    add rbp, 8
    mov rbx, [rbp]

    call Print_str 
    jmp AFTER_PRINT_BUFFER2

DEC_PRINT: ; Add to print next arg how dec number

    add rbp, 8
    mov rax, [rbp]
 
    mov r11, 10
    call Dec_convert
    jmp AFTER_PRINT_BUFFER2

HEX_PRINT: ; Add to print next arg how hex number

    add rbp, 8
    mov rax, [rbp]

    mov r11, 1111b
    mov r12, 4
    call Hex_convert
    jmp AFTER_PRINT_BUFFER2

OCTAL_PRINT: ; Add to print next arg how octal number

    add rbp, 8
    mov rax, [rbp]

    mov r11, 111b
    mov r12, 3
    call Hex_convert
    add rsi, 2
    jmp AFTER_PRINT_BUFFER2

BIN_PRINT: ; Add to print next arg how bin number

    add rbp, 8
    mov rax, [rbp]

    mov r11, 1b
    mov r12, 1
    call Hex_convert
    jmp AFTER_PRINT_BUFFER2

PERCENT_PRINT: ; Add to print char '%'
    mov dl, '%'
    mov [r8 + rsi], dl
    inc rsi

    cmp rsi, Size_buff
    jne AFTER_PRINT_BUFFER2

    call Print_buffer
    jmp AFTER_PRINT_BUFFER2


END_PRINTF:
    call Print_buffer ; Print the remaining buffer

    mov rax, r15

    pop r15
    pop r14
    pop r13     ; Return value registers (in accordance with "System V ABI" agreement)
    pop r12
    pop rbp
    pop rbx

    pop rdi
    pop rsi
    pop rdx     ; Return value registers (if you need it)
    pop rcx
    pop r8
    pop r9

    push rax    ; Push ret address

    ret


Print_str: ; Copy string to the print buffer and if the buffer overflows, print it 

begin_loop:                          
    mov dl, [rbx]                        
                                          
    cmp dl, 0
    je Print_str_end


    mov [r8 + rsi], dl
    inc rsi
    inc rbx

    cmp rsi, Size_buff
    jne AFTER_PRINT_BUFFER3
    call Print_buffer

AFTER_PRINT_BUFFER3:
    jmp begin_loop                       

Print_str_end:
    ret

;------------------------------------------------------
; Print dec (or other system foundation in register r11) representation of number located in rax
; Use jmp to Print (label in Dec_convert proc)
; Entry: rax - our number
;        r11 - system foundation
;
; Destr: rax, rbx, rcx. r11, r13
; Change value in rsi
;------------------------------------------------------
Dec_convert:

    mov rbx, 0

Deg: 

    mov rdx, 0
    div r11
    push rdx
    inc rbx
   
    cmp rax, 0
    jne Deg

    mov rcx, rbx
    
;------------------------------------------------------
; Print the digits from Stack
; Entry: r13 - number of digits
;
; Destr: rcx, rdi, rbx, r13
; Change value in rsi
;------------------------------------------------------
Print:

    pop r13
    mov dl, byte [System + r13]

    mov [r8 + rsi], dl   
    inc rsi
    cmp rsi, Size_buff
    jne AFTER_PRINT_BUFFER4
    call Print_buffer

AFTER_PRINT_BUFFER4:

    dec rcx
    cmp rcx, 0
    jne Print

    ret
;======================================================

;------------------------------------------------------
; Print hex (or other system foundation pow 2) representation of number located in rax
; Use jmp to Print (label in Dec_convert)
; Entry: rax - our number
;        r11 - byte mask
;        r12 - byte shift 
;
; Destr: rax, rbx, rcx. rdi, rdx, r11, r12
; Change value in rsi
;------------------------------------------------------
Hex_convert:

mov rcx, r12
mov r12, 0

Hex: 
    mov rbx, rax
    and rbx, r11
    push rbx

    shr rax, cl
    inc r12
    
    cmp rax, 0
    jne Hex

    mov rcx, r12
    jmp Print

    ret
;==================================================


;------------------------------------------------------
; Print buffer if print ends or buffer overflows. 

; Destr: rax, rbx, rcx, rdx
; Change value in rsi = 0
;------------------------------------------------------
Print_buffer:
    cmp rsi, 0
    je Skip_print

    mov rdx, rsi
    mov rcx, Buffer
    mov rbx, 1
    mov rax, 4
    int 0x80

    mov rsi, 0

Skip_print:
    ret

;;
;   STRING FOR QUICK CONVERTETION 
;;
section .data

Jump_table dq Spec_a
           dq Spec_b
           dq Spec_c
           dq Spec_d
           dq Spec_e
           dq Spec_f
           dq Spec_g
           dq Spec_h
           dq Spec_i
           dq Spec_j
           dq Spec_k
           dq Spec_l
           dq Spec_m
           dq Spec_n
           dq Spec_o
           dq Spec_p
           dq Spec_q
           dq Spec_r
           dq Spec_s
           dq Spec_t
           dq Spec_u
           dq Spec_v
           dq Spec_w
           dq Spec_x
           dq Spec_y
           dq Spec_z
           

System db '0123456789ABCDEF$'

Size_buff equ 100
Buffer db Size_buff dup(0)




