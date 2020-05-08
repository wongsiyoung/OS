org 7c00h

getstr:
 	push ax

getstrs:
	mov dh,2
	mov dl,40
	mov ah,0
	int 16h
	cmp al,20h
	jb nochar
	mov ah,0
	call charstack
	mov ah,2
	call charstack
	jmp getstrs

nochar:
	cmp ah,0eh
	je backspace
	cmp ah,1ch
	je en
	jmp getstrs

backspace:
	mov ah,1
	call charstack
	mov ah,2
	call charstack
	jmp getstrs

en:
	mov al,0
	mov ah,0
	call charstack
	mov ah,2
	call charstack
	pop ax
	ret	

charstack:
	jmp short charstart

table dw charpush,charpop,charshow
top   dw 0

charstart:
	push bx
	push dx
	push di
	push es

	cmp ah,2
	ja sret
	mov bl,ah
	mov bh,0
	add bx,bx
	jmp word[table+bx]

charpush:
	mov bx,[top]
	mov [si+bx],al
	inc word[top]
	jmp sret

charpop:
	cmp word[top],0
	je sret
	dec word[top]
	mov bx,[top]
	mov al,[si+bx]
	jmp sret

charshow:
	mov bx,0b800h
	mov es,bx
	mov al,160
	mov ah,0
	mul dh
	mov di,ax
	add dl,dl
	mov dh,0
	add di,ax
	mov bx,0


charshows:	
	cmp bx,[top]
	jne noempty
	mov byte[es:di],' '
	jmp sret

noempty:
	mov al,[si+bx]
	mov [es:di],al
	mov byte[es:di+2],' '
	inc bx
	add di,2
	jmp charshows

sret:
	pop es
	pop di
	pop dx
	pop bx
	ret

times 510-($-$$) db 0
db 0x55,0xaa
