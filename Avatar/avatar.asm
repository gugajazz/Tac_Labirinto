;------------------------------------------------------------------------
;	Base para TRABALHO PRATICO - TECNOLOGIAS e ARQUITECTURAS de COMPUTADORES
;   
;	ANO LECTIVO 2020/2021
;--------------------------------------------------------------
; Demostra��o da navega��o do Ecran com um avatar
;
;		arrow keys to move 
;		press ESC to exit
;
;--------------------------------------------------------------

.8086
.model small
.stack 2048

dseg	segment para public 'data'


		STR12	 		DB 		"            "	; String para 12 digitos
		DDMMAAAA 		db		"                     "
		
		Horas			dw		0				; Vai guardar a HORA actual
		Minutos			dw		0				; Vai guardar os minutos actuais
		Segundos		dw		0				; Vai guardar os segundos actuais
		Old_seg			dw		0				; Guarda os �ltimos segundos que foram lidos
		Tempo_init		dw		0				; Guarda O Tempo de inicio do jogo
		Tempo_j			dw		0				; Guarda O Tempo que decorre o  jogo
		Tempo_limite	dw		100				; tempo m�ximo de Jogo
		String_TJ		db		"    /100$"

		String_num 		db 		"  0 $"
        String_nome  	db	    "ISEC$"	
		Construir_nome	db	    "  		$"
		Dim_nome		dw		5	; Comprimento do Nome
		indice_nome		dw		0	; indice que aponta para Construir_nome
		
		Fim_Ganhou		db	    " Ganhou $"	
		Fim_Perdeu		db	    " Perdeu $"	

        Erro_Open       db      'Erro ao tentar abrir o ficheiro$'
        Erro_Ler_Msg    db      'Erro ao tentar ler do ficheiro$'
        Erro_Close      db      'Erro ao tentar fechar o ficheiro$'
        Fich         	db      'labi.TXT',0
        HandleFich      dw      0
        car_fich        db      ?

		string			db	"Teste pr�tico de T.I",0
		Car				db	32	; Guarda um caracter do Ecran 
		Cor				db	7	; Guarda os atributos de cor do caracter
		POSy			db	3	; a linha pode ir de [1 .. 25]
		POSx			db	3	; POSx pode ir [1..80]
		POSx2			db	3	; POSx pode ir [1..80]	
		POSya			db	3	; Posi��o anterior de y
		POSxa			db	3	; Posi��o anterior de x
dseg	ends

cseg	segment para public 'code'
assume		cs:cseg, ds:dseg



;########################################################################
goto_xy	macro		POSx,POSy
		mov		ah,02h
		mov		bh,0		; numero da p�gina
		mov		dl,POSx
		mov		dh,POSy
		int		10h ;INT 10h 2 -> set cursor position | DH = row | DL = column | BH = page number (0..7)
endm

;########################################################################
; MOSTRA - Faz o display de uma string terminada em $

MOSTRA MACRO STR 
	MOV AH,09H
	LEA DX,STR 
	INT 21H
ENDM

; FIM DAS MACROS



;ROTINA PARA APAGAR ECRAN

apaga_ecran	proc
			mov		ax,0B800h
			mov		es,ax
			xor		bx,bx
			mov		cx,25*80
		
apaga:		mov		byte ptr es:[bx],' '
			mov		byte ptr es:[bx+1],7
			inc		bx
			inc 	bx
			loop	apaga
			ret
apaga_ecran	endp


;########################################################################
; IMP_FICH

IMP_FICH	PROC

		;abre ficheiro
        mov     ah,3dh
        mov     al,0
        lea     dx,Fich
        int     21h
        jc      erro_abrir
        mov     HandleFich,ax
        jmp     ler_ciclo ;salta para ler_ciclo

erro_abrir:
        mov     ah,09h
        lea     dx,Erro_Open
        int     21h
        jmp     sai_f

ler_ciclo:
        mov     ah,3fh
        mov     bx,HandleFich
        mov     cx,1
        lea     dx,car_fich
        int     21h			;read from file | BX = file handle | CX = number of bytes to read | DS:DX -> buffer for data
		jc		erro_ler
		cmp		ax,0		;EOF?
		je		fecha_ficheiro
        mov     ah,02h
		mov		dl,car_fich
		int		21h
		jmp		ler_ciclo

erro_ler:
        mov     ah,09h
        lea     dx,Erro_Ler_Msg
        int     21h

fecha_ficheiro:
        mov     ah,3eh
        mov     bx,HandleFich
        int     21h
        jnc     sai_f

        mov     ah,09h
        lea     dx,Erro_Close
        Int     21h
sai_f:	
		RET
		
IMP_FICH	endp		


;########################################################################
; LE UMA TECLA	

LE_TECLA	PROC
		
		mov		ah,08h
		int		21h      ;
		mov		ah,0
		cmp		al,0
		jne		SAI_TECLA ;saltar para sai_tecla se nao zero
		mov		ah, 08h
		int		21h
		mov		ah,1
SAI_TECLA:	RET
LE_TECLA	endp



;########################################################################
; Avatar

AVATAR	PROC
			xor di,di
			mov		ax,0B800h
			mov		es,ax
			mov 	POSx2, 10

			goto_xy	POSx,POSy		; Vai para nova possi��o
			mov 	ah, 08h		; Guarda o Caracter que est� na posi��o do Cursor
			mov		bh,0			; numero da p�gina
			int		10h			
			mov		Car, al			; Guarda o Caracter que est� na posi��o do Cursor
			mov		Cor, ah			; Guarda a cor que est� na posi��o do Cursor	
	


IMPRIME_PALAVRA:	goto_xy 10,20
				lea dx, String_nome
				mov ah, 09h
				int 21h


CICLO:		goto_xy	POSxa,POSya		; Vai para a posi��o anterior do cursor
			mov		ah, 02h
			mov		dl, Car			; Repoe Caracter guardado 
			int		21H				; write character to standard output | DL = character to write | after execution AL = DL
		
			goto_xy	POSx,POSy		; Vai para nova possi��o
			mov 	ah, 08h
			mov		bh,0			; numero da p�gina
			int		10h				; read character and attribute at cursor position | BH = page number | return: AH = attribute AL = character.
			mov		Car, al			; Guarda o Caracter que est� na posi��o do Cursor
			mov		Cor, ah			; Guarda a cor que est� na posi��o do Cursor
		
			goto_xy	78,0			; Mostra o caractr que estava na posi��o do AVATAR
			mov		ah, 02h			; IMPRIME caracter da posi��o no canto
			mov		dl, Car	
			int		21H			    ; write character to standard output | DL = character to write | after execution AL = DL
	
			goto_xy	POSx,POSy		; Vai para posi��o do cursor
			xor si, si
			xor bx, bx

VERIFICA_REP:	mov ah, Construir_nome[bx]
				cmp ah, '$'
				je 	VERIFICA
				cmp	Car, ah		
				je	IMPRIME
				inc bx
				jmp VERIFICA_REP
			

VERIFICA:	mov ah, String_nome[si]
			cmp ah, '$'
			je 	IMPRIME
			cmp	Car, ah		
			je	IMPRIME_GAME
			inc si
			jmp VERIFICA

IMPRIME:	goto_xy	POSx,POSy
			mov		ah, 02h
			mov		dl, 190	; Coloca AVATAR
			int		21H	
			goto_xy	POSx,POSy	; Vai para posi��o do cursor
		
			mov		al, POSx	; Guarda a posi��o do cursor
			mov		POSxa, al
			mov		al, POSy	; Guarda a posi��o do cursor
			mov 	POSya, al
		
LER_SETA:	call 	LE_TECLA
			cmp		ah, 1
			je		ESTEND
			CMP 	AL, 27	 ; ESCAPE  | subtract second from first for flags 
			JE		FIM      ;jump if zero
			jmp		LER_SETA
		
ESTEND:		cmp 	al,48h
			jne		BAIXO
			dec		POSy		;cima
			goto_xy	POSx,POSy			
			mov		ah, 08h
			mov 	bh, 0
			int 	10h
			cmp 	al, 177
			jne 	CICLO  
			inc		POSy
			jmp		CICLO

BAIXO:		cmp		al,50h
			jne		ESQUERDA
			inc 	POSy		;Baixo
			goto_xy	POSx,POSy			
			mov		ah, 08h
			mov 	bh, 0
			int 	10h
			cmp 	al, 177
			jne 	CICLO  
			dec		POSy		
			jmp 	CICLO

ESQUERDA:
			cmp		al,4Bh
			jne		DIREITA
			dec		POSx		;Esquerda
			goto_xy	POSx,POSy			
			mov		ah, 08h
			mov 	bh, 0
			int 	10h
			cmp 	al, 177
			jne 	CICLO  
			inc		POSx
			jmp		CICLO

DIREITA:
			cmp		al,4Dh
			jne		LER_SETA 
			inc		POSx		;Direita
			goto_xy	POSx,POSy			
			mov		ah, 08h
			mov 	bh, 0
			int 	10h
			cmp 	al, 177
			jne 	CICLO  
			dec		POSx
			jmp		CICLO

IMPRIME_GAME:	mov al, Car
				mov Construir_nome[di], al
				goto_xy POSx2,21
				mov ah, 02h	
				mov dl, Construir_nome[di]		
				int 21h
				inc POSx2
				inc di
				jmp IMPRIME
fim:				
			RET
AVATAR		endp


;########################################################################
Main  proc
		mov			ax, dseg
		mov			ds,ax
		
		mov			ax,0B800h
		mov			es,ax
		
		call		apaga_ecran
		goto_xy		0,0
		call		IMP_FICH  ;abrir o ficheiro acho
		call 		AVATAR    ;
		goto_xy		0,22		;macro para mexer o boneco acho
		
		mov			ah,4CH
		INT			21H     ;return control to the operating system (stop program)
Main	endp
Cseg	ends
end	Main


		
