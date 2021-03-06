;-----------------------------------------------------------------------------;
;	Base para TRABALHO PRATICO - TECNOLOGIAS e ARQUITECTURAS de COMPUTADORES  ;
;                                                                             ;   
;	ANO LECTIVO 2020/2021                                                     ;
;-----------------------------------------------------------------------------;
;Trabalho realizado por:                                                      ;
;                       Gustavo Mateus - 2020138902                           ;
;                       Hugo Gil - 2020130870                                 ;
;                                                                             ;
;		arrow keys to move                                                    ;
;		press ESC to exit                                                     ;
;                                                                             ;
;-----------------------------------------------------------------------------;

.8086
.model small
.stack 2048

PILHA	SEGMENT PARA STACK 'STACK'
	db 2048 dup(?)
PILHA	ENDS

dseg	segment para public 'data'
		
	;DATAS / HORAS
	Horas			dw		0				; Vai guardar a HORA actual
	Minutos			dw		0				; Vai guardar os minutos actuais
	Segundos		dw		0				; Vai guardar os segundos actuais
	Old_seg			dw		0				; Guarda os ultimos segundos que foram lidos
	Tempo_init		dw		0				; Guarda O Tempo de inicio do jogo
	Tempo_j			dw		0				; Guarda O Tempo que decorre o  jogo
	Tempo_limite	dw		101				; tempo maximo de Jogo
	String_TJ		db		"  /100$"
	STR12	 		DB 		"            "	; String para 12 digitos
	DDMMAAAA 		db		"                     "

	;PALAVRAS
	String_num 		db 		"  0 $"
	String_nome  	db	    "ISEC    $"	
	Construir_nome	db	    "____    $"
	Dim_nome		dw		5				; Comprimento do Nome
	indice_nome		dw		0				; indice que aponta para Construir_nome

	;NIVEIS
	Fim_Ganhou		db	    " Parabens, Ganhou o Jogo$"	
	Fim_Perdeu		db	    " Perdeu o jogo $"
	Fim_Reiniciar	db		" Quer reiniciar o jogo? $"
	Fim_Escolha		db		" (1)Sim	(2)Nao $"
	Fim_Nivel		db	    " Passou de nivel $"	
	Proximo_Nivel	db	    " Prima uma tecla para avancar para o proximo nivel $"	
	Mensagem_sair	db	    " Prima uma tecla para sair $"
	Nivel_atual		db	    " Esta no nivel $"
	Nivel			dw		49				;48 ascii = 0 | 49 = 1 | 50 = 2 ....
	Nivel_str		db      " $"

	;PONTUACAO
	Pontos			dw		100
	String_pontos	db		"Pontuacao:   $"
	Pontuacao_n1	db		"Pontuacao Nivel 1:   $"	
	Pontuacao_n2	db		"Pontuacao Nivel 2:   $"
	Pontuacao_n3	db		"Pontuacao Nivel 3:   $"
	Pontuacao_n4	db		"Pontuacao Nivel 4:   $"
	Pontuacao_n5	db		"Pontuacao Nivel 5:   $"	

	;MENU
	Jogar			db	    " (1)Jogar $"
	Top10			db	    " (2)Top 10 $"
	Sair			db	    " (3)Sair $"
	Erro			db      'Top 10 nao implementado $'
	string			db	"Teste pratico de T.I $"

	;FICHEIROS
	Erro_Open       db      'Erro ao tentar abrir o ficheiro$'
	Erro_Ler_Msg    db      'Erro ao tentar ler do ficheiro$'
	Erro_Close      db      'Erro ao tentar fechar o ficheiro$'
	Fich         	db      'labi.TXT',0
	Ficht         	db      'titulo.TXT',0
	HandleFich      dw      0
	car_fich        db      ?

	;AVATAR
	Car				db	32	; Guarda um caracter do Ecran 
	Cor				db	7	; Guarda os atributos de cor do caracter
	POSy			db	3	; a linha pode ir de [1 .. 25]
	POSx			db	3	; POSx pode ir [1..80]
	POSya			db	3	; Posicao anterior de y
	POSxa			db	3	; Posicao anterior de x

dseg	ends

cseg	segment para public 'code'
assume		cs:cseg, ds:dseg


Ler_TEMPO PROC	
	;**************************************************************************************
	; Ler_tempo  - LE Hora DO SISTEMA E COLOCA em tres variaveis (Horas, Minutos, Segundos)
	; CH - Horas, CL - Minutos, DH - Segundos
	;**************************************************************************************

	PUSH AX
	PUSH BX
	PUSH CX
	PUSH DX

	PUSHF
	
	MOV AH, 2CH             ; Buscar a HORAS
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


HOJE PROC	
	;*********************************************************************
	; HOJE - LE DATA DO SISTEMA E COLOCA NUMA STRING NA FORMA DD/MM/AAAA
	; CX - ANO, DH - MES, DL - DIA
	;*********************************************************************
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


goto_xy	macro		POSx,POSy
		mov		ah,02h
		mov		bh,0		; numero da p???gina
		mov		dl,POSx
		mov		dh,POSy
		int		10h 		;INT 10h 2 -> set cursor position | DH = row | DL = column | BH = page number (0..7)
endm


MOSTRA MACRO STR 
	;MOSTRA - Faz o display de uma string terminada em $
	MOV AH,09H
	LEA DX,STR 
	INT 21H
ENDM


Trata_Horas PROC

	PUSHF
	PUSH AX
	PUSH BX
	PUSH CX
	PUSH DX		

	CALL 	Ler_TEMPO			; Horas MINUTOS e segundos do Sistema
	
	MOV		AX, Segundos
	cmp		AX, Old_seg			; Verifica se os segundos mudaram desde a ultima leitura
	je		fim_horas			; Se a hora n??o mudou desde a ??ltima leitura sai.
	mov		Old_seg, AX			; Se segundos s??o diferentes actualiza informa????o do tempo 
	
	mov 	ax,Horas
	MOV		bl, 10     
	div 	bl
	add 	al, 30h				; Caracter Correspondente ??s dezenas
	add		ah,	30h				; Caracter Correspondente ??s unidades
	MOV 	STR12[0],al			; 
	MOV 	STR12[1],ah
	MOV 	STR12[2],'h'		
	MOV 	STR12[3],'$'
	GOTO_XY 2,0 				;localizacao horas
	MOSTRA STR12 		
	
	mov 	ax,Minutos
	MOV 	bl, 10     
	div 	bl
	add 	al, 30h				; Caracter Correspondente ??s dezenas
	add		ah,	30h				; Caracter Correspondente ??s unidades
	MOV 	STR12[0],al			
	MOV 	STR12[1],ah
	MOV 	STR12[2],'m'		
	MOV 	STR12[3],'$'
	GOTO_XY	6,0
	MOSTRA	STR12 		
	
	mov 	ax,Segundos
	MOV 	bl, 10     
	div 	bl
	add 	al, 30h				; Caracter Correspondente ??s dezenas
	add		ah,	30h				; Caracter Correspondente ??s unidades
	MOV 	STR12[0],al			
	MOV 	STR12[1],ah
	MOV 	STR12[2],'s'		
	MOV 	STR12[3],'$'
	GOTO_XY	10,0
	MOSTRA	STR12 


	mov 	ax, Pontos					; Contador para pontos
	dec		Pontos
	mov		bl, 10
	div		bl					
	add 	al, 30h						; Caracter Correspondente ??s dezenas
	add 	ah, 30h						; Caracter Correspondente ??s unidades
	mov 	String_pontos[11], al		
	mov 	String_pontos[12], ah
	goto_xy	34,0
	MOSTRA	String_pontos

	mov 	ax, Tempo_j			; Contador
	inc 	Tempo_j
	MOV 	bl, 10     
	div 	bl
	add 	al, 30h				; Caracter Correspondente ??s dezenas
	add		ah,	30h				; Caracter Correspondente ??s unidades
	MOV 	String_TJ[0],al			; 
	MOV 	String_TJ[1],ah		
	goto_xy	58,0
	MOSTRA	String_TJ		
	call	VERIFICA_DERROTA
	
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


apaga_ecran	proc
	;ROTINA PARA APAGAR ECRAN
	mov		ax,0B800h
	mov		es,ax
	xor		bx,bx
	mov		cx,25*80
		
	apaga:	
		mov		byte ptr es:[bx],' '
		mov		byte ptr es:[bx+1],7
		inc		bx
		inc 	bx
		loop	apaga
		ret
apaga_ecran	endp


IMP_FICH	PROC

	;abre ficheiro
	mov     ah,3dh
	mov     al,0
	lea     dx,Fich
	int     21h
	jc      erro_abrir
	mov     HandleFich,ax
	jmp     ler_ciclo 		;salta para ler_ciclo

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
		cmp		ax,0		
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


IMP_FICHT	PROC ;para o titulo

	;abre ficheiro
	mov     ah,3dh
	mov     al,0
	lea     dx,Ficht
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
		cmp		ax,0		
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
		
IMP_FICHT	endp		
	

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

	SAI_TECLA:	
		RET

LE_TECLA	endp


MENU PROC

	goto_xy 0,0
	call 	IMP_FICHT
	goto_xy 27,8
	MOSTRA 	string
	goto_xy 29,10
	MOSTRA Nivel_atual
	goto_xy 44,10
	mov CX, Nivel 			;passar o numero do nivel para a string e imprimir
	mov Nivel_str[0], CL
	MOSTRA 	Nivel_str

	goto_xy 31,12
	MOSTRA 	Jogar
	goto_xy 31,13
	MOSTRA 	Top10
	goto_xy 31,14
	MOSTRA 	Sair


	AVANCAR:	
		mov		ah,08h
		int		21h      
		cmp 	al, '1'
		je		SAI_MENU
		cmp 	al,	'2'
		je		ERROTOP10
		cmp		al, '3'
		je 		FIM
		jmp		AVANCAR ;se nao houver input continua no loop


	ERROTOP10: 		
		call	apaga_ecran
		goto_xy 27,8
		MOSTRA Erro
		mov		ah,08h
		int		21h      
		cmp		al, 0
		je		ERROTOP10
		call	apaga_ecran
		jmp		MENU


	FIM:	
		mov			ah,4CH
		INT			21H

	SAI_MENU:
		RET

MENU	endp


AVATAR	PROC
	
	mov		ax,0B800h
	mov		es,ax

	goto_xy	POSx,POSy		; Vai para nova possicao
	mov 	ah, 08h			; Guarda o Caracter que esta na posicao do Cursor
	mov		bh,0			; numero da pagina
	int		10h			
	mov		Car, al			; Guarda o Caracter que esta na posicao do Cursor
	mov		Cor, ah			; Guarda a cor que esta na posicao do Cursor	


	IMPRIME_PALAVRA:	;imprime a palavra q temos de procurar
		goto_xy 10,20
		MOSTRA 	String_nome
		
	

	CICLO:		
		goto_xy	POSxa,POSya		; Vai para a posicao anterior do cursor
		mov		ah, 02h
		mov		dl, Car			; Repoe Caracter guardado 
		int		21H		; Repoe o Caracte onde o boneco esteve p impedir um rasto	; write character to standard output | DL = character to write | after execution AL = DL

		goto_xy 3, 3
		mov		ah, 02h
		mov		dl, " "			; Repoe Caracter guardado 
		int		21H

		goto_xy	POSx,POSy		; Vai para nova posicao
		mov 	ah, 08h
		mov		bh,0			; numero da pagina
		int		10h		;guarda o caracter onde o boneco pisa		; read character and attribute at cursor position | BH = page number | return: AH = attribute AL = character.
		mov		Car, al			; Guarda o Caracter que esta na posicao do Cursor
		mov		Cor, ah			; Guarda a cor que esta na posicao do Cursor
	
		goto_xy	78,0			; Mostra o caractr que estava na posicao do AVATAR
		mov		ah, 02h			; IMPRIME caracter da posicao no canto
		mov		dl, Car	
		int		21H			    ; write character to standard output | DL = character to write | after execution AL = DL

		goto_xy	POSx,POSy		; Vai para posicao do cursor
		xor si, si				;si fica a zero

				


	VERIFICA:	;ver se o caracter que estamos a pisar pertence a palavra
		mov ah, String_nome[si]
		cmp ah, '$'
		je 	IMPRIME ;palavra ja acabou
		cmp	Car, ah		
		je	IMPRIME_GAME 
		inc si
		jmp VERIFICA

	IMPRIME:	;print do avatar
		goto_xy	POSx,POSy
		mov		ah, 02h
		mov		dl, 190		; Coloca AVATAR, sem isto avatar n aparece
		int		21H	
		goto_xy	POSx,POSy	; Vai para posicao do cursor
	
		mov		al, POSx	; Guarda a posicao do cursor
		mov		POSxa, al
		mov		al, POSy	; Guarda a posicao do cursor
		mov 	POSya, al
			
	LER_SETA:	
		call 	LE_TECLA 
		call WIN
		cmp		ah, 1
		je		ESTEND
		CMP 	AL, 27	 ; ESCAPE  | subtract second from first for flags 
		JE		FIM      ;jump if zero
		jmp		LER_SETA
			
	ESTEND:	
		cmp 	al,48h
		jne		BAIXO
		dec		POSy		;cima
		goto_xy	POSx,POSy

		mov		ah, 08h 
		mov 	bh, 0
		int 	10h ;ler o caracter q estamos a pisar
		cmp 	al, 177 ;177 ?? a parede
		jne 	CICLO  ;se n estas na parede
		inc		POSy   ;desce um pixel
		jmp		CICLO

	BAIXO:		
		cmp		al,50h
		jne		ESQUERDA
		inc 	POSy		;Baixo
		goto_xy	POSx,POSy	

		mov		ah, 08h
		mov 	bh, 0
		int 	10h
		cmp 	al, 177
		jne 	CICLO  
		dec		POSy	;sobe um pixel	
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
		inc		POSx   ;um pixel p a direita
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
		dec		POSx    ;um pixel p a esquerda
		jmp		CICLO

	IMPRIME_GAME:	;troca o "_" pela letra que pisamos
		mov al, Car
		mov Construir_nome[si], al
		goto_xy 10,21
		MOSTRA Construir_nome
		inc  si
		jmp VERIFICA

	fim:				
		RET

AVATAR		endp


VERIFICA_DERROTA PROC

	mov 	ax, Tempo_limite
	cmp 	Tempo_j, ax
	je		DERROTA ;compara tempo c tempo limite e se igual vai p derrota
	RET

	DERROTA:	
		call 	apaga_ecran
		goto_xy 31, 10
		MOSTRA 	Fim_Perdeu
		goto_xy 27, 11
		MOSTRA 	Fim_Reiniciar
		goto_xy 30, 13
		MOSTRA 	Fim_Escolha
		mov		ah,08h
		int		21h      
		cmp		al, '2' ;se for dois sai do programa
		je		FIM
		cmp		al, '1' ;se for um vai p o sai menu
		je		SAI_MENU
		jmp		DERROTA

	SAI_MENU: ;se reiniciares poe tudo como no primeiro nivel
		mov 	Construir_nome[0], "_"
		mov 	Construir_nome[1], "_"
		mov 	Construir_nome[2], "_"
		mov 	Construir_nome[3], "_" 
		mov 	Construir_nome[4], "$"
		mov		String_nome[0], "I"
		mov 	String_nome[1], "S"
		mov 	String_nome[2], "E"
		mov 	String_nome[3], "C" 
		mov 	String_nome[4], "$" 
		mov		String_TJ[3], "1"
		mov 	String_TJ[4], "0"
		mov 	String_TJ[5], "0"
		mov 	Tempo_limite, 101
		mov 	Tempo_j, 0
		mov		Pontos, 99 
		mov 	POSy, 3
		mov		Nivel, 49
		mov 	POSx, 3 
		call 	Main

	FIM: 	
		goto_xy	0,22 ;para o path ficar no fundo da consola quando clicamos esc
		mov		ah,4ch
		int		21h  

VERIFICA_DERROTA	endp


WIN	PROC

	xor di, di ;fazer di=0

	VERIFICA_WIN:
		cmp Construir_nome[di], '$' ;ver se ja temos as letras todas
		je 	PROX_NIVEL
		cmp Construir_nome[di], '_' ;se isto for verdade a palavra nao esta completa e sai
		je	FIM
		inc di 				;se nao for nenhum dos acima incrementa e continua o loop (havia uma letra no espaco)
		jmp VERIFICA_WIN

	PROX_NIVEL:	
		call apaga_ecran
		goto_xy 31,10
		MOSTRA Fim_Nivel
		goto_xy 33,12
		MOSTRA 	String_pontos
		goto_xy 15,14
		MOSTRA Proximo_Nivel

		;guarda a pontuacao na variavel correspondente ao nivel atual
		cmp Nivel, 49 ;49 em ascii = 1
		je n1

		cmp Nivel, 50
		je n2

		cmp Nivel, 51
		je n3

		cmp Nivel, 52
		je n4

		jmp n5

		n1:
		mov BL, String_pontos[11]
		mov Pontuacao_n1[19], BL ;guarda o 1o digito dos pontos no 1o digito da Pontuacao_n1

		mov BH, String_pontos[12]
		mov Pontuacao_n1[20], BH ;guarda o 2o digito dos pontos no 2o digito da Pontuacao_n1

		n2:
		mov BL, String_pontos[11]
		mov Pontuacao_n2[19], BL

		mov BH, String_pontos[12]
		mov Pontuacao_n2[20], BH

		n3:
		mov BL, String_pontos[11]
		mov Pontuacao_n3[19], BL

		mov BH, String_pontos[12]
		mov Pontuacao_n3[20], BH

		n4:
		mov BL, String_pontos[11]
		mov Pontuacao_n4[19], BL

		mov BH, String_pontos[12]
		mov Pontuacao_n4[20], BH

		n5:
		mov BL, String_pontos[11]
		mov Pontuacao_n5[19], BL

		mov BH, String_pontos[12]
		mov Pontuacao_n5[20], BH

	AVANCAR:	;espera que o jogador pressione uma tecla p sair
		mov		ah,08h
		int		21h      
		cmp		al, 0
		jne 	SAI_PARA_MENU
		jmp		AVANCAR

	FIM:
		RET

	SAI_PARA_MENU: ;sai do loop e vai para o menu

		mov Tempo_j, 0 ;cronometro volta a zero
		inc Nivel      ;nivel aumenta

		mov POSy, 3		;mete o avatar nesta posicao
		mov POSx, 3 

		;dependendo do nivel para q vamos altera a palavra e limite de tempo no contador
		cmp	Nivel, 50	;50 em ascii -> 2
		je	NIVEL2
		cmp Nivel, 51	;51 em ascii -> 3
		je NIVEL3
		cmp Nivel, 52	;52 em ascii -> 4
		je NIVEL4
		cmp Nivel, 53 	;53 em ascii -> 5
		je NIVEL5
		cmp Nivel, 54 	;54 em ascii -> 6
		je ECRA_VITORIA
		 
	NIVEL2:	
		mov Construir_nome[0], "_"
		mov Construir_nome[1], "_"
		mov Construir_nome[2], "_"
		mov Construir_nome[3], "_" 
		mov Construir_nome[4], "_"
		mov	String_nome[0], "C"
		mov String_nome[1], "U"
		mov String_nome[2], "R"
		mov String_nome[3], "S" 
		mov String_nome[4], "O" 
		mov	String_TJ[3], "9"
		mov String_TJ[4], "0"
		mov String_TJ[5], "$"
		mov Tempo_limite, 91
		mov	Pontos, 90 
		jmp FIM_WIN

	NIVEL3:	
		mov Construir_nome[0], "_"
		mov Construir_nome[1], "_"
		mov Construir_nome[2], "_"
		mov Construir_nome[3], "_" 
		mov Construir_nome[4], "_"
		mov Construir_nome[5], "_"
		mov	String_nome[0], "M"
		mov String_nome[1], "O"
		mov String_nome[2], "O"
		mov String_nome[3], "D" 
		mov String_nome[4], "L" 
		mov String_nome[5], "E" 
		mov	String_TJ[3], "8"
		mov String_TJ[4], "0"
		mov String_TJ[5], "$"
		mov Tempo_limite, 81
		mov	Pontos, 80
		jmp FIM_WIN

	NIVEL4:	
		mov Construir_nome[0], "_"
		mov Construir_nome[1], "_"
		mov Construir_nome[2], "_"
		mov Construir_nome[3], "_" 
		mov Construir_nome[4], "_"
		mov Construir_nome[5], "_"
		mov Construir_nome[6], "_"
		mov	String_nome[0], "M"
		mov String_nome[1], "E"
		mov String_nome[2], "M"
		mov String_nome[3], "O" 
		mov String_nome[4], "R" 
		mov String_nome[5], "I" 
		mov String_nome[6], "A" 
		mov	String_TJ[3], "7"
		mov String_TJ[4], "0"
		mov String_TJ[5], "$"
		mov Tempo_limite, 71
		mov	Pontos, 70 
		jmp FIM_WIN

	NIVEL5:	
		mov Construir_nome[0], "_"
		mov Construir_nome[1], "_"
		mov Construir_nome[2], "_"
		mov Construir_nome[3], "_" 
		mov Construir_nome[4], "_"
		mov Construir_nome[5], "_"
		mov Construir_nome[6], "_"
		mov Construir_nome[7], "_"
		mov	String_nome[0], "A"
		mov String_nome[1], "S"
		mov String_nome[2], "S"
		mov String_nome[3], "E" 
		mov String_nome[4], "M" 
		mov String_nome[5], "B" 
		mov String_nome[6], "L" 
		mov String_nome[7], "Y" 
		mov	String_TJ[3], "6"
		mov String_TJ[4], "0"
		mov String_TJ[5], "$"
		mov Tempo_limite, 61
		mov	Pontos, 60 
		jmp FIM_WIN
	
	ECRA_VITORIA:
		CALL apaga_ecran
		goto_xy 27,8 ;centro do ecra
		MOSTRA Fim_Ganhou
		goto_xy 26,10 ;centro do ecra
		MOSTRA Mensagem_sair

		goto_xy 28,14
		MOSTRA Pontuacao_n1
		goto_xy 28,15
		MOSTRA Pontuacao_n2
		goto_xy 28,16
		MOSTRA Pontuacao_n3
		goto_xy 28,17
		MOSTRA Pontuacao_n4
		goto_xy 28,18
		MOSTRA Pontuacao_n5

		goto_xy		0,22 ;para o path ficar no fundo da consola quando clicamos esc

		mov	ah,08h
		int	21h      ;le a tecla q pressionas
		mov	ah,0
		cmp	al,0
		jne	SAIR_JOGO ;saltar para sai_tecla se nao zero

		SAIR_JOGO:
		mov	ah,4CH
		INT	21H     ;return control to the operating system (stop program)

			
	FIM_WIN:
						
WIN	endp


Main  proc
	mov			ax, dseg
	mov			ds,ax
	
	mov			ax,0B800h
	mov			es,ax
	
	call		apaga_ecran
	call		MENU    	;chama o menu
	call		apaga_ecran
	goto_xy		0,0
	call		IMP_FICH  ;abrir o ficheiro

	ultimo_caracter: ;Repoe ultimo caracter que o avatar pisou antes de passar para o proximo nivel
	 	goto_xy POSy, POSx
	 	mov		ah, 02h
	 	mov		dl, Car			
	 	int		21H
		jmp voltar_avatar

	voltar_avatar:
		call AVATAR 


	goto_xy	0,22 ;para o path ficar no fundo da consola quando clicamos esc
	
	mov			ah,4CH
	INT			21H     ;return control to the operating system (stop program)

Main	endp

Cseg	ends
end	Main


		