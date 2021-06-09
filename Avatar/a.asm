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

PILHA	SEGMENT PARA STACK 'STACK'
		db 2048 dup(?)
PILHA	ENDS

dseg	segment para public 'data'


		STR12	 		DB 		"            "	; String para 12 digitos
		DDMMAAAA 		db		"                     "
		NUMERO			DB		"                    $" 	; String destinada a guardar o número lido
		NUM_SP			db		"                    $" 	; PAra apagar zona de ecran

		
		Horas			dw		0				; Vai guardar a HORA actual
		Minutos			dw		0				; Vai guardar os minutos actuais
		Segundos		dw		0				; Vai guardar os segundos actuais
		Old_seg			dw		0				; Guarda os �ltimos segundos que foram lidos
		Tempo_init		dw		0				; Guarda O Tempo de inicio do jogo
		Tempo_j			dw		0				; Guarda O Tempo que decorre o  jogo
		Tempo_limite	dw		100				; tempo m�ximo de Jogo
		String_TJ		db		"  /100$"
		Nivel			dw		48				;48 ascii = 0 | 49 = 1 | 50 = 2 ....
		Nivel_str		db      " $"

		String_num 		db 		"  0 $"
        String_nome  	db	    "ISEC$"	
		Construir_nome	db	    "____$"
		Dim_nome		dw		5	; Comprimento do Nome
		indice_nome		dw		0	; indice que aponta para Construir_nome
		
		Fim_Ganhou		db	    " Ganhou $"	
		Fim_Perdeu		db	    " Perdeu $"
		Fim_Nivel		db	    " Passou de nivel $"	
		Proximo_Nivel	db	    " Prima uma tecla para avancar para o proximo nivel $"	
		Nivel_atual		db	    " Esta no nivel $"

		Jogar			db	    " (1)Jogar $"
		Top10			db	    " (2)Top 10 $"
		Sair			db	    " (3)Sair $"

		Erro			db      'Top 10 nao implementado $'

        Erro_Open       db      'Erro ao tentar abrir o ficheiro$'
        Erro_Ler_Msg    db      'Erro ao tentar ler do ficheiro$'
        Erro_Close      db      'Erro ao tentar fechar o ficheiro$'
        Fich         	db      'labi.TXT',0
        HandleFich      dw      0
        car_fich        db      ?

		string			db	"Teste pratico de T.I $"
		Car				db	32	; Guarda um caracter do Ecran 
		Cor				db	7	; Guarda os atributos de cor do caracter
		POSy			db	3	; a linha pode ir de [1 .. 25]
		POSx			db	3	; POSx pode ir [1..80]
		POSya			db	3	; Posi��o anterior de y
		POSxa			db	3	; Posi��o anterior de x
dseg	ends

cseg	segment para public 'code'
assume		cs:cseg, ds:dseg

;********************************************************************************
;********************************************************************************
; HORAS  - LE Hora DO SISTEMA E COLOCA em tres variaveis (Horas, Minutos, Segundos)
; CH - Horas, CL - Minutos, DH - Segundos
;********************************************************************************	

Ler_TEMPO PROC	
 
		PUSH AX
		PUSH BX
		PUSH CX
		PUSH DX
	
		PUSHF
		
		MOV AH, 2CH             ; Buscar a hORAS
		INT 21H                 
		
		XOR AX,AX
		MOV AL, DH              ; segundos para al
		mov Segundos, AX		; guarda segundos na variavel correspondente
		
		XOR AX,AX
		MOV AL, CL              ; Minutos para al
		mov Minutos, AX         ; guarda MINUTOS na variavel correspondente
		
		XOR AX,AX
		MOV AL, CH              ; Horas para al
		mov Horas,AX			; guarda HORAS na variavel correspondente
 
		POPF
		POP DX
		POP CX
		POP BX
		POP AX
 		RET 
Ler_TEMPO   ENDP 

;********************************************************************************
;********************************************************************************	
;-------------------------------------------------------------------
; HOJE - LE DATA DO SISTEMA E COLOCA NUMA STRING NA FORMA DD/MM/AAAA
; CX - ANO, DH - MES, DL - DIA
;-------------------------------------------------------------------
HOJE PROC	

		PUSH AX
		PUSH BX
		PUSH CX
		PUSH DX
		PUSH SI
		PUSHF
		
		MOV AH, 2AH             ; Buscar a data
		INT 21H                 
		PUSH CX                 ; Ano-> PILHA
		XOR CX,CX              	; limpa CX
		MOV CL, DH              ; Mes para CL
		PUSH CX                 ; Mes-> PILHA
		MOV CL, DL				; Dia para CL
		PUSH CX                 ; Dia -> PILHA
		XOR DH,DH                    
		XOR	SI,SI
; DIA ------------------ 
; DX=DX/AX --- RESTO DX   
		XOR DX,DX               ; Limpa DX
		POP AX                  ; Tira dia da pilha
		MOV CX, 0               ; CX = 0 
		MOV BX, 10              ; Divisor
		MOV	CX,2
DD_DIV:                         
		DIV BX                  ; Divide por 10
		PUSH DX                 ; Resto para pilha
		MOV DX, 0               ; Limpa resto
		loop dd_div
		MOV	CX,2
DD_RESTO:
		POP DX                  ; Resto da divisao
		ADD DL, 30h             ; ADD 30h (2) to DL
		MOV DDMMAAAA[SI],DL
		INC	SI
		LOOP DD_RESTO            
		MOV DL, '/'             ; Separador
		MOV DDMMAAAA[SI],DL
		INC SI
; MES -------------------
; DX=DX/AX --- RESTO DX
		MOV DX, 0               ; Limpar DX
		POP AX                  ; Tira mes da pilha
		XOR CX,CX               
		MOV BX, 10				; Divisor
		MOV CX,2
MM_DIV:                         
		DIV BX                  ; Divisao or 10
		PUSH DX                 ; Resto para pilha
		MOV DX, 0               ; Limpa resto
		LOOP MM_DIV
		MOV CX,2 
MM_RESTO:
		POP DX                  ; Resto
		ADD DL, 30h             ; SOMA 30h
		MOV DDMMAAAA[SI],DL
		INC SI		
		LOOP MM_RESTO
		
		MOV DL, '/'             ; Character to display goes in DL
		MOV DDMMAAAA[SI],DL
		INC SI
 
;  ANO ----------------------
		MOV DX, 0               
		POP AX                  ; mes para AX
		MOV CX, 0               ; 
		MOV BX, 10              ; 
 AA_DIV:                         
		DIV BX                   
		PUSH DX                 ; Guarda resto
		ADD CX, 1               ; Soma 1 contador
		MOV DX, 0               ; Limpa resto
		CMP AX, 0               ; Compara quotient com zero
		JNE AA_DIV              ; Se nao zero
AA_RESTO:
		POP DX                  
		ADD DL, 30h             ; ADD 30h (2) to DL
		MOV DDMMAAAA[SI],DL
		INC SI
		LOOP AA_RESTO
		POPF
		POP SI
		POP DX
		POP CX
		POP BX
		POP AX
 		RET 
HOJE   ENDP 

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


Trata_Horas PROC

		PUSHF
		PUSH AX
		PUSH BX
		PUSH CX
		PUSH DX		

		CALL 	Ler_TEMPO				; Horas MINUTOS e segundos do Sistema
		
		MOV		AX, Segundos
		cmp		AX, Old_seg			; VErifica se os segundos mudaram desde a ultima leitura
		je		fim_horas			; Se a hora não mudou desde a última leitura sai.
		mov		Old_seg, AX			; Se segundos são diferentes actualiza informação do tempo 
		
		mov 	ax,Horas
		MOV		bl, 10     
		div 	bl
		add 	al, 30h				; Caracter Correspondente às dezenas
		add		ah,	30h				; Caracter Correspondente às unidades
		MOV 	STR12[0],al			; 
		MOV 	STR12[1],ah
		MOV 	STR12[2],'h'		
		MOV 	STR12[3],'$'
		GOTO_XY 2,0 				;localizacao horas
		MOSTRA STR12 		
        
		mov 	ax,Minutos
		MOV 	bl, 10     
		div 	bl
		add 	al, 30h				; Caracter Correspondente às dezenas
		add		ah,	30h				; Caracter Correspondente às unidades
		MOV 	STR12[0],al			; 
		MOV 	STR12[1],ah
		MOV 	STR12[2],'m'		
		MOV 	STR12[3],'$'
		GOTO_XY	6,0
		MOSTRA	STR12 		
		
		mov 	ax,Segundos
		MOV 	bl, 10     
		div 	bl
		add 	al, 30h				; Caracter Correspondente às dezenas
		add		ah,	30h				; Caracter Correspondente às unidades
		MOV 	STR12[0],al			; 
		MOV 	STR12[1],ah
		MOV 	STR12[2],'s'		
		MOV 	STR12[3],'$'
		GOTO_XY	10,0
		MOSTRA	STR12 

		mov 	ax, Tempo_j			; Contador
		inc 	Tempo_j
		MOV 	bl, 10     
		div 	bl
		add 	al, 30h				; Caracter Correspondente às dezenas
		add		ah,	30h				; Caracter Correspondente às unidades
		MOV 	String_TJ[0],al			; 
		MOV 	String_TJ[1],ah		
		goto_xy	58,0
		MOSTRA	String_TJ		
        
		CALL 	HOJE				; Data de HOJE
		MOV 	al ,DDMMAAAA[0]	
		MOV 	STR12[0], al	
		MOV 	al ,DDMMAAAA[1]	
		MOV 	STR12[1], al	
		MOV 	al ,DDMMAAAA[2]	
		MOV 	STR12[2], al	
		MOV 	al ,DDMMAAAA[3]	
		MOV 	STR12[3], al	
		MOV 	al ,DDMMAAAA[4]	
		MOV 	STR12[4], al	
		MOV 	al ,DDMMAAAA[5]	
		MOV 	STR12[5], al	
		MOV 	al ,DDMMAAAA[6]	
		MOV 	STR12[6], al	
		MOV 	al ,DDMMAAAA[7]	
		MOV 	STR12[7], al	
		MOV 	al ,DDMMAAAA[8]	
		MOV 	STR12[8], al
		MOV 	al ,DDMMAAAA[9]	
		MOV 	STR12[9], al		
		MOV 	STR12[10],'$'
		GOTO_XY	67,0
		MOSTRA	STR12 	
		
						
fim_horas:		
		goto_xy	POSx,POSy			; Volta a colocar o cursor onde estava antes de actualizar as horas
		
		POPF
		POP DX		
		POP CX
		POP BX
		POP AX
		RET		
			
Trata_Horas ENDP



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

sem_tecla:
		call Trata_Horas
		MOV AH, 0BH
		INT 21h
		CMP AL,0
		JE sem_tecla

		mov		ah,08h
		int		21h      ;le a tecla q pressionas
		mov		ah,0
		cmp		al,0
		jne		SAI_TECLA ;saltar para sai_tecla se nao zero
		mov		ah, 08h
		int		21h
		mov		ah,1
		call WIN ;ve se ganhaste e se sim limpa o contador e as letras q ja encontraste
		

SAI_TECLA:	RET
LE_TECLA	endp


MENU	PROC

	goto_xy 27,8
	MOSTRA 	string

	goto_xy 29,10
	MOSTRA Nivel_atual
	goto_xy 44,10
	mov CX, Nivel ;passar o numero do nivel para a string e imprimir
	mov Nivel_str[0], CL
	MOSTRA 	Nivel_str


	goto_xy 31,12
	MOSTRA 	Jogar
	goto_xy 31,13
	MOSTRA 	Top10
	goto_xy 31,14
	MOSTRA 	Sair


	AVANCAR:	mov		ah,08h
				int		21h      
				cmp		al, 0
				je		AVANCAR
				cmp 	al, '1'
				je		SAI_MENU
				cmp 	al,	'2'
				je		ERROTOP10
				cmp		al, '3'
				je 		FIM
				jmp		AVANCAR


	ERROTOP10: 		call	apaga_ecran
					goto_xy 27,8
					MOSTRA Erro
					mov		ah,08h
					int		21h      
					cmp		al, 0
					je		ERROTOP10
					call	apaga_ecran
					jmp		MENU


	FIM:	mov			ah,4CH
			INT			21H

SAI_MENU:	RET
MENU	endp


;########################################################################
; Avatar

AVATAR	PROC
	mov		ax,0B800h
	mov		es,ax


	goto_xy	POSx,POSy		; Vai para nova possi��o
	mov 	ah, 08h		; Guarda o Caracter que est� na posi��o do Cursor
	mov		bh,0			; numero da p�gina
	int		10h			
	mov		Car, al			; Guarda o Caracter que est� na posi��o do Cursor
	mov		Cor, ah			; Guarda a cor que est� na posi��o do Cursor	


	IMPRIME_PALAVRA:	;imprime a palavra q temos de procurar
						goto_xy 10,20
						MOSTRA 	String_nome
						
						
	;trata:
	;call Trata_Horas

	CICLO:		
				goto_xy	POSxa,POSya		; Vai para a posi��o anterior do cursor
				mov		ah, 02h
				mov		dl, Car			; Repoe Caracter guardado 
				int		21H		; Repoe o Caracte onde o boneco esteve p impedir um rasto	; write character to standard output | DL = character to write | after execution AL = DL

				goto_xy	POSx,POSy		; Vai para nova possi��o
				mov 	ah, 08h
				mov		bh,0			; numero da p�gina
				int		10h		;guarda o caracter onde o boneco pisa		; read character and attribute at cursor position | BH = page number | return: AH = attribute AL = character.
				mov		Car, al			; Guarda o Caracter que est� na posi��o do Cursor
				mov		Cor, ah			; Guarda a cor que est� na posi��o do Cursor
			
				goto_xy	78,0			; Mostra o caractr que estava na posi��o do AVATAR
				mov		ah, 02h			; IMPRIME caracter da posi��o no canto
				mov		dl, Car	
				int		21H			    ; write character to standard output | DL = character to write | after execution AL = DL
		
				goto_xy	POSx,POSy		; Vai para posi��o do cursor
				xor si, si


	VERIFICA:	mov ah, String_nome[si]
				cmp ah, '$'
				je 	IMPRIME
				cmp	Car, ah		
				je	IMPRIME_GAME
				inc si
				jmp VERIFICA

	IMPRIME:	goto_xy	POSx,POSy
				mov		ah, 02h
				mov		dl, 190	; Coloca AVATAR, sem isto avatar n aparece
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

	IMPRIME_GAME:	
					mov al, Car
					mov Construir_nome[si], al
					goto_xy 10,21
					MOSTRA Construir_nome
					inc  si
					;call WIN
					jmp VERIFICA
					;jmp trata
	fim:				
				RET
AVATAR		endp

WIN	PROC

	xor di, di

	VERIFICA_WIN:	cmp Construir_nome[di], '$'
					je 	PROX_NIVEL
					cmp Construir_nome[di], '_'
					je	FIM
					inc di
					jmp VERIFICA_WIN

	PROX_NIVEL:	call apaga_ecran
				goto_xy 31,10
				MOSTRA Fim_Nivel
				goto_xy 15,12
				MOSTRA Proximo_Nivel

	AVANCAR:	mov		ah,08h
				int		21h      
				cmp		al, 0
				;jne		FIM
				jne 	SAI_PARA_MENU
				jmp		AVANCAR
	FIM:
			RET

	SAI_PARA_MENU: ;sai do loop e vai para o menu
		mov Construir_nome[0], "_"
		mov Construir_nome[1], "_"
		mov Construir_nome[2], "_"
		mov Construir_nome[3], "_" 
		mov Tempo_j, 0
		inc Nivel
		
				
WIN	endp



;########################################################################
Main  proc
		mov			ax, dseg
		mov			ds,ax
		
		mov			ax,0B800h
		mov			es,ax
		
		
		call		apaga_ecran
		call		MENU    ;chama o menu
		call		apaga_ecran
		goto_xy		0,0
		call		IMP_FICH  ;abrir o ficheiro acho
		call 		AVATAR 
   
		goto_xy		0,22
		
		mov			ah,4CH
		INT			21H     ;return control to the operating system (stop program)
Main	endp
Cseg	ends
end	Main


		