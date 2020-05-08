org 7c00h
     delay equ 50000					; 延时计数器
     ddelay equ 850					; 延时计数器
start: 
	mov ah,0
	int 16h

	mov ah,1
	cmp al,'r'
	je red
	cmp al,'g'
	je green
	cmp al,'b'
	je blue

red: 
	shl ah,1
green:
	shl ah,1
blue:
	mov bx,0b800h
	mov es,bx
	mov bx,0
	mov cx,2000

s:
	mov byte [es:bx],'t'
	inc bx
	and byte [es:bx],11111000b
	or  [es:bx],ah
	inc bx
	loop s
	mov bx,0b800h
	mov es,bx
	mov bx,0
	mov cx,2000

loop1:

	dec word[count]				; 数了50000次
	jnz loop1					; 
	mov word[count],delay
	dec word[dcount]				;数了580次，一共数了50000*580次,太慢了
    jnz loop1
d:
	mov byte [es:bx],' '
	inc bx
	mov byte [es:bx],00000000b
	inc bx
	loop d

AfterRun:
      jmp $ 
datadef:	
    count dw delay
    dcount dw ddelay
          
times 510-($-$$) db 0
db 0x55,0xaa

