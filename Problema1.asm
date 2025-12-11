org 100h

; ================================
; MENSAGENS
; ================================
msgPeso     db 13,10,"Digite o peso (kg, ex: 75): $"
msgAltura   db 13,10,"Digite a altura (cm, ex: 170): $"
msgIMC      db 13,10,"IMC = $"
msgAbaixo   db 13,10,"Abaixo do peso$"
msgNormal   db 13,10,"Peso normal$"
msgSobre    db 13,10,"Sobrepeso$"

peso   dw ?
altura dw ?
imc    dw ?

; ================================
start:
; ----------- LER PESO usando SCAN_NUM ------------
mov dx, offset msgPeso
mov ah, 09h
int 21h

call SCAN_NUM     ; CX contém o número lido
mov peso, cx

; Pular linha para melhor visualização
mov dl, 13
mov ah, 02h
int 21h
mov dl, 10
mov ah, 02h
int 21h

; ----------- LER ALTURA usando SCAN_NUM ------------
mov dx, offset msgAltura
mov ah, 09h
int 21h

call SCAN_NUM     ; CX contém o número lido
mov altura, cx

; Pular linha para melhor visualização
mov dl, 13
mov ah, 02h
int 21h
mov dl, 10
mov ah, 02h
int 21h

; ======================================
; IMC = (peso * 10000) / (altura^2)
; ======================================

; numerador = peso * 10000
mov ax, peso
mov bx, 10000
mul bx               ; DX:AX = peso * 10000
push dx
push ax

; denominador = altura^2
mov ax, altura
mul ax               ; DX:AX = altura^2
mov bx, ax           ; denominador em BX (assumindo que cabe em 16 bits)
mov cx, dx           ; salva parte alta se necessário

; recuperar numerador
pop ax               ; parte baixa do numerador
pop dx               ; parte alta do numerador

; verifica se precisamos nos preocupar com overflow
cmp cx, 0            ; se altura^2 tem parte alta...
jne altura_grande    ; tratamento especial

; divisão normal
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

; =============== MOSTRAR IMC ===============
mov dx, offset msgIMC
mov ah, 09h
int 21h

mov ax, imc
call print_num

; =============== CLASSIFICAÇÃO ===============
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

; =====================================
; PRINT_NUM — imprime AX sem sinal
; =====================================
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

; =====================================
; SCAN_NUM — lê número do teclado
; =====================================
SCAN_NUM PROC NEAR
    PUSH DX
    PUSH AX
    PUSH SI
    
    MOV CX, 0
    MOV CS:make_minus, 0

next_digit:
    MOV AH, 00h
    INT 16h
    MOV AH, 0Eh
    INT 10h

    CMP AL, '-'
    JE set_minus

    CMP AL, 13
    JNE not_cr
    JMP stop_input
not_cr:

    CMP AL, 8
    JNE backspace_checked
    MOV DX, 0
    MOV AX, CX
    DIV CS:ten
    MOV CX, AX
    ; Limpar caractere na tela
    MOV AL, ' '
    MOV AH, 0Eh
    INT 10h
    MOV AL, 8
    MOV AH, 0Eh
    INT 10h
    JMP next_digit
backspace_checked:

    CMP AL, '0'
    JAE ok_AE_0
    JMP remove_not_digit
ok_AE_0:
    CMP AL, '9'
    JBE ok_digit
remove_not_digit:
    ; Backspace para apagar caractere inválido
    MOV AL, 8
    MOV AH, 0Eh
    INT 10h
    MOV AL, ' '
    MOV AH, 0Eh
    INT 10h
    MOV AL, 8
    MOV AH, 0Eh
    INT 10h
    JMP next_digit
ok_digit:

    PUSH AX
    MOV AX, CX
    MUL CS:ten
    MOV CX, AX
    POP AX

    CMP DX, 0
    JNE too_big

    SUB AL, 30h
    MOV AH, 0
    MOV DX, CX
    ADD CX, AX
    JC too_big2
    JMP next_digit

set_minus:
    MOV CS:make_minus, 1
    JMP next_digit

too_big2:
    MOV CX, DX
    MOV DX, 0
too_big:
    MOV AX, CX
    DIV CS:ten
    MOV CX, AX
    MOV AL, 8
    MOV AH, 0Eh
    INT 10h
    MOV AL, ' '
    MOV AH, 0Eh
    INT 10h
    MOV AL, 8
    MOV AH, 0Eh
    INT 10h
    JMP next_digit

stop_input:
    CMP CS:make_minus, 0
    JE not_minus
    NEG CX
not_minus:
    POP SI
    POP AX
    POP DX
    RET

make_minus DB 0
ten DW 10
SCAN_NUM ENDP