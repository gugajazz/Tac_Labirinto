

.MODEL SMALL
.STACK 100H

.DATA
cur_seconds     db    0

.CODE
HOUR:
MOV AH,2CH    ; To get System Time
INT 21H
MOV AL,CH     ; Hour is in CH
AAM
MOV BX,AX
CALL DISP

MOV DL,':'
MOV AH,02H    ; To Print : in DOS
INT 21H

;Minutes Part
MINUTES:
MOV AH,2CH    ; To get System Time
INT 21H
MOV AL,CL     ; Minutes is in CL
AAM
MOV BX,AX
CALL DISP

MOV DL,':'    ; To Print : in DOS
MOV AH,02H
INT 21H

;Seconds Part
Seconds:
MOV AH,2CH    ; To get System Time
INT 21H
MOV AL,DH     ; Seconds is in DH

AAM
MOV BX,AX
CALL DISP


;To terminate the Program

;MOV AH,4CH     ; To Terminate the Program
;INT 21H


;««««««««««««««««««««««
WAITING:
MOV AH,2CH    ; To get System Time
INT 21H         ; Seconds is in DH

cmp  dh, cur_seconds  ;◄■■ IF SECONDS ARE THE SAME...
je   WAITING     ;    ...WE ARE STILL IN THE SAME SECONDS.
mov  cur_seconds, dh  ;◄■■ SECONDS CHANGED. PRESERVE NEW SECONDS.


jmp Hour


;jmp Hour


;To terminate the Program
MOV AH,4CH     ; To Terminate the Program
INT 21H


;Display Part
DISP PROC
MOV DL,BH      ; Since the values are in BX, BH Part
ADD DL,30H     ; ASCII Adjustment
MOV AH,02H     ; To Print in DOS
INT 21H
MOV DL,BL      ; BL Part 
ADD DL,30H     ; ASCII Adjustment
MOV AH,02H     ; To Print in DOS
INT 21H
RET
DISP ENDP      ; End Disp Procedure

FIM:
ret

END      ; End of MAIN