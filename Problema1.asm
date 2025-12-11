org 100h

start:               
; ler peso usando scan_num 
 
mov dx, offset msgPeso
mov ah, 09h
int 21h              

call SCAN_NUM     ; CX possui o numero lido
mov peso, cx

; quebra linha
PUTC 0Dh
PUTC 0Ah

; ler altura usando scan_num
 
mov dx, offset msgAltura
mov ah, 09h
int 21h

call SCAN_NUM     ; novamente CX possui o numero lido
mov altura, cx

; quebra linha
PUTC 0Dh
PUTC 0Ah

; IMC = (peso * 10000) / (altura^2)

; numerador = peso * 10000 

mov ax, peso
mov bx, 10000
mul bx               ; DX:AX = peso * 10000
push dx
push ax

; denominador = altura^2 

mov ax, altura
mul ax               ; DX:AX = altura^2
mov bx, ax           ; denominador em BX 
mov cx, dx           ; salva parte alta 

; recuperar numerador
pop ax               ; parte baixa do numerador
pop dx               ; parte alta do numerador

; verifica se precisamos nos preocupar com overflow
cmp cx, 0            ; se altura^2 tem parte alta
jne altura_grande    ; tratamento especial

; divisao normal
div bx               ; AX = IMC
jmp armazena_imc

altura_grande:
    ; Para alturas muito grandes, simplificamos
    ; dividindo numerador e denominador por 256
    mov al, ah       ; shift right 8 bits do numerador
    mov ah, dl
    mov dl, dh
    xor dh, dh
    mov bx, cx       ; usa parte alta como divisor
    div bx

armazena_imc:
mov imc, ax
                     
; quebra linha
PUTC 0Dh
PUTC 0Ah

; mostrar imc 

mov dx, offset msgIMC
mov ah, 09h
int 21h

mov ax, imc
call print_num
                     
; quebra linha
PUTC 0Dh
PUTC 0Ah

; classificacao

mov ax, imc
cmp ax, 18
jl abaixo
cmp ax, 25
jle normal
jmp sobrepeso

abaixo:
mov dx, offset msgAbaixo
mov ah, 09h
int 21h
jmp fim

normal:
mov dx, offset msgNormal
mov ah, 09h
int 21h
jmp fim

sobrepeso:
mov dx, offset msgSobre
mov ah, 09h
int 21h

fim:
mov ah, 4Ch
int 21h    

; mensagens

msgPeso     db "Digite o peso (kg, ex: 75): $"
msgAltura   db "Digite a altura (cm, ex: 170): $"
msgIMC      db "IMC = $"
msgAbaixo   db "Abaixo do peso$"
msgNormal   db "Peso normal$"
msgSobre    db "Sobrepeso$"

peso   dw ?
altura dw ?
imc    dw ?

; print_num 

print_num:
mov bx, 10
xor cx, cx
pn_loop1:
xor dx, dx
div bx
push dx
inc cx
cmp ax, 0
jne pn_loop1
pn_loop2:
pop dx
add dl, '0'
mov ah, 02h
int 21h
loop pn_loop2
ret
      
PUTC    MACRO   char
        PUSH    AX
        MOV     AL, char
        MOV     AH, 0Eh
        INT     10h     
        POP     AX
ENDM

; scan_num
SCAN_NUM        PROC    NEAR
        PUSH    DX
        PUSH    AX
        PUSH    SI
        
        MOV     CX, 0

        ; reset flag:
        MOV     CS:make_minus, 0

next_digit:

        ; get char from keyboard
        ; into AL:
        MOV     AH, 00h
        INT     16h
        ; and print it:
        MOV     AH, 0Eh
        INT     10h

        ; check for MINUS:
        CMP     AL, '-'
        JE      set_minus

        ; check for ENTER key:
        CMP     AL, 13  ; carriage return?
        JNE     not_cr
        JMP     stop_input
not_cr:


        CMP     AL, 8                   ; 'BACKSPACE' pressed?
        JNE     backspace_checked
        MOV     DX, 0                   ; remove last digit by
        MOV     AX, CX                  ; division:
        DIV     CS:ten                  ; AX = DX:AX / 10 (DX-rem).
        MOV     CX, AX
        PUTC    ' '                     ; clear position.
        PUTC    8                       ; backspace again.
        JMP     next_digit
backspace_checked:


        ; allow only digits:
        CMP     AL, '0'
        JAE     ok_AE_0
        JMP     remove_not_digit
ok_AE_0:        
        CMP     AL, '9'
        JBE     ok_digit
remove_not_digit:       
        PUTC    8       ; backspace.
        PUTC    ' '     ; clear last entered not digit.
        PUTC    8       ; backspace again.        
        JMP     next_digit ; wait for next input.       
ok_digit:


        ; multiply CX by 10 (first time the result is zero)
        PUSH    AX
        MOV     AX, CX
        MUL     CS:ten                  ; DX:AX = AX*10
        MOV     CX, AX
        POP     AX

        ; check if the number is too big
        ; (result should be 16 bits)
        CMP     DX, 0
        JNE     too_big

        ; convert from ASCII code:
        SUB     AL, 30h

        ; add AL to CX:
        MOV     AH, 0
        MOV     DX, CX      ; backup, in case the result will be too big.
        ADD     CX, AX
        JC      too_big2    ; jump if the number is too big.

        JMP     next_digit

set_minus:
        MOV     CS:make_minus, 1
        JMP     next_digit

too_big2:
        MOV     CX, DX      ; restore the backuped value before add.
        MOV     DX, 0       ; DX was zero before backup!
too_big:
        MOV     AX, CX
        DIV     CS:ten  ; reverse last DX:AX = AX*10, make AX = DX:AX / 10
        MOV     CX, AX
        PUTC    8       ; backspace.
        PUTC    ' '     ; clear last entered digit.
        PUTC    8       ; backspace again.        
        JMP     next_digit ; wait for Enter/Backspace.
        
        
stop_input:
        ; check flag:
        CMP     CS:make_minus, 0
        JE      not_minus
        NEG     CX
not_minus:

        POP     SI
        POP     AX
        POP     DX
        RET
make_minus      DB      ?       ; used as a flag.
ten             DW      10      ; used as multiplier.
SCAN_NUM        ENDP                                             