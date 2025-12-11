org 100h

; programa principal
start:

; imprime prompt e le a1
mov dx, offset msg_a1
mov ah, 9
int 21h

; leitura de inteiro -> cx
call SCAN_NUM

; salva a1
mov a1, cx

; quebra linha
PUTC 0Dh
PUTC 0Ah

; imprime prompt e le an
mov dx, offset msg_an
mov ah, 9
int 21h

; leitura de inteiro -> cx
call SCAN_NUM

; salva an
mov an, cx
  
; quebra linha  
PUTC 0Dh
PUTC 0Ah


; imprime prompt e le n
mov dx, offset msg_n
mov ah, 9
int 21h

; leitura de inteiro -> cx
call SCAN_NUM

; salva n
mov n, cx

; quebra linha
PUTC 0Dh
PUTC 0Ah

; prepara registradores p/ chamada do procedimento
mov ax, a1
mov bx, an
mov cx, n

; chama procedimento que calcula soma da pa
call calc_pa

; salva resultado
mov res, ax

; imprime mensagem do resultado
mov dx, offset msg_res
mov ah, 9
int 21h

; imprime valor em ax
mov ax, res
call PRINT_NUM

; encerra programa
ret  
     
     
; mensagens 
msg_a1  db "Digite o primeiro termo (a1): $"
msg_an  db "Digite o ultimo termo (an): $"
msg_n   db "Digite o numero de termos (n): $"
msg_res db "Soma da PA = $"
  
  
; variaveis
a1  dw ?
an  dw ?
n   dw ?
res dw ?
  
   
; macros
PUTC    MACRO   char
        PUSH    AX
        MOV     AL, char
        MOV     AH, 0Eh
        INT     10h
        POP     AX
ENDM
  
  
; procedimento para calcular soma da pa
; sn = (a1 + an) * n / 2
calc_pa proc near
add ax, bx
xor dx, dx
mul cx
shr dx, 1
rcr ax, 1
ret
calc_pa endp


; rotinas de i/o
SCAN_NUM        PROC    NEAR
PUSH    DX
PUSH    AX
PUSH    SI

MOV     CX, 0

; resetar flag
MOV     CS:make_minus, 0

next_digit:
MOV     AH, 00h
INT     16h

MOV     AH, 0Eh
INT     10h

CMP     AL, '-'
JE      set_minus

CMP     AL, 0Dh
JNE     not_cr
JMP     stop_input
not_cr:

CMP     AL, 8
JNE     backspace_checked
MOV     DX, 0
MOV     AX, CX
DIV     CS:ten
MOV     CX, AX
PUTC    ' '
PUTC    8
JMP     next_digit
backspace_checked:

CMP     AL, '0'
JAE     ok_AE_0
JMP     remove_not_digit
ok_AE_0:
CMP     AL, '9'
JBE     ok_digit
remove_not_digit:
PUTC    8
PUTC    ' '
PUTC    8
JMP     next_digit
ok_digit:

PUSH    AX
MOV     AX, CX
MUL     CS:ten
MOV     CX, AX
POP     AX

CMP     DX, 0
JNE     too_big

SUB     AL, 30h

MOV     AH, 0
MOV     DX, CX
ADD     CX, AX
JC      too_big2

JMP     next_digit

set_minus:
MOV     CS:make_minus, 1
JMP     next_digit

too_big2:
MOV     CX, DX
MOV     DX, 0
too_big:
MOV     AX, CX
DIV     CS:ten
MOV     CX, AX
PUTC    8
PUTC    ' '
PUTC    8
JMP     next_digit

stop_input:
CMP     CS:make_minus, 0
JE      not_minus
NEG     CX
not_minus:

POP     SI
POP     AX
POP     DX
RET
make_minus      DB      ?
SCAN_NUM        ENDP


PRINT_NUM       PROC    NEAR
PUSH    DX
PUSH    AX

CMP     AX, 0
JNZ     not_zero

PUTC    '0'
JMP     printed

not_zero:
CMP     AX, 0
JNS     positive
NEG     AX

PUTC    '-'

positive:
CALL    PRINT_NUM_UNS
printed:
POP     AX
POP     DX
RET
PRINT_NUM       ENDP


PRINT_NUM_UNS   PROC    NEAR
PUSH    AX
PUSH    BX
PUSH    CX
PUSH    DX

MOV     CX, 1
MOV     BX, 10000

CMP     AX, 0
JZ      print_zero

begin_print:
CMP     BX,0
JZ      end_print

CMP     CX, 0
JE      calc
CMP     AX, BX
JB      skip
calc:
MOV     CX, 0

MOV     DX, 0
DIV     BX

ADD     AL, 30h
PUTC    AL

MOV     AX, DX

skip:
PUSH    AX
MOV     DX, 0
MOV     AX, BX
DIV     CS:ten
MOV     BX, AX
POP     AX

JMP     begin_print

print_zero:
PUTC    '0'

end_print:
POP     DX
POP     CX
POP     BX
POP     AX
RET
PRINT_NUM_UNS   ENDP

ten             DW      10


