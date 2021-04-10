DEFAULT REL

section .text
    global main
    extern printf 

section .data 
    msg  db `I love %X na %u %%%c \n`, 0
    pam1 dq 3802
    pam2 dq 100
    pam3 db '!'

section .text

main: 
    mov rcx, [pam3]
    mov rdx, [pam2]
    mov rsi, [pam1]
    mov rdi, msg

    mov rax, 0

    call printf 
    
    ret