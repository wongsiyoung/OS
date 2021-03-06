

jmp near start
     Dn_Rt equ 1                  ;D-Down,U-Up,R-right,L-Left
     Up_Rt equ 2                  ;
     Up_Lt equ 3                  ;
     Dn_Lt equ 4                  ;
     delay equ 50000					; 延时计数器
     ddelay equ 850					; 延时计数器
datadef:	
    count dw delay
    dcount dw ddelay
    rdul db Dn_Rt
    x    dw 7		;行
    y    dw 0		;列
    cnt  dw 0
    char db 'l',42h,'e',21h,'a',14h,'r',42h,'n',21h,'O',14h,'S',42h,'0',0		;要显示的字符
    number  db	'1',89h,'8',89h,'3',89h,'4',89h,'0',89h,'0',89h,'6',89h,'4',89h
    name	db 'w',89h,'o',89h,'n',89h,'g',89h,'s',89h,'i',89h,'y',89h,'o',89h,'u',89h,'n',89h,'g',89h

start:
    mov ax,0x7c00
	mov ds,ax					; DS = CS,指向数据段
	mov ax,0B800h				
	mov es,ax					; ES = B800h，指向显示器

showmeg:
	cld
	mov	di,8
	mov si,number
	mov cx,8
	rep movsw
	mov di,28h
	mov si,name
	mov cx,11
	rep movsw
loop1:
	dec word[count]				; 数了50000次
	jnz loop1					; 
	mov word[count],delay
	dec word[dcount]				;数了580次，一共数了50000*580次,太慢了
    jnz loop1
	mov word[dcount],ddelay

    mov al,1
    cmp al,byte[rdul]
	jz  DnRt
    mov al,2
    cmp al,byte[rdul]
	jz  UpRt
      mov al,3
      cmp al,byte[rdul]
	jz  UpLt
      mov al,4
      cmp al,byte[rdul]
	jz  DnLt
      jmp $	

DnRt:
	inc word[x]	;x=9
	inc word[y]	;y=2
	mov bx,word[x];bx=9
	mov ax,25
	sub ax,bx;ax=16
      jz  dr2ur ;碰到底
	mov bx,word[y];bx=1
	mov ax,80
	sub ax,bx;ax=79
      jz  dr2dl;碰到右边
	jmp show
dr2ur:
      mov word[x],23
      mov byte[rdul],Up_Rt	
      jmp show
dr2dl:
      mov word[y],78
      mov byte[rdul],Dn_Lt	
      jmp show

UpRt:
	dec word[x]
	inc word[y]
	mov bx,word[y]
	mov ax,80
	sub ax,bx
      jz  ur2ul
	mov bx,word[x]
	mov ax,-1;？
	sub ax,bx
      jz  ur2dr
	jmp show
ur2ul:
      mov word[y],78
      mov byte[rdul],Up_Lt	
      jmp show
ur2dr:
      mov word[x],1
      mov byte[rdul],Dn_Rt	
      jmp show

	
	
UpLt:
	dec word[x]
	dec word[y]
	mov bx,word[x]
	mov ax,-1
	sub ax,bx
      jz  ul2dl
	mov bx,word[y]
	mov ax,-1
	sub ax,bx
      jz  ul2ur
	jmp show

ul2dl:
      mov word[x],1
      mov byte[rdul],Dn_Lt	
      jmp show
ul2ur:
      mov word[y],1
      mov byte[rdul],Up_Rt	
      jmp show

	
	
DnLt:
	inc word[x]
	dec word[y]
	mov bx,word[y]
	mov ax,-1
	sub ax,bx
      jz  dl2dr
	mov bx,word[x]
	mov ax,25
	sub ax,bx
      jz  dl2ul
	jmp show

dl2dr:
      mov word[y],1
      mov byte[rdul],Dn_Rt	
      jmp show
	
dl2ul:
      mov word[x],23
      mov byte[rdul],Up_Lt	
      jmp show
	
show:	
    mov ax,word[x];ax=8
	mov bx,80
	mul bx;8*80=行*列？
	add ax,word[y];640+列=641
	mov bx,2
	mul bx;ax=2*641=1282
	mov bx,ax

	mov dx,[es:bx]
	cmp dl,' '
	jnz loop1			;避开显示的信息

	mov di,[cnt]
	mov al,byte[char+di]	;  要显示的字符
	mov ah,byte[char+di+1]				;  设置字符属性

	cmp al,'0'
	jz s1

	add di,2
	mov [cnt],di
		
con:
	mov [es:bx],ax  		;  送入显示器
	jmp loop1

s1:
	mov word[cnt],0
	mov al,byte[char]
	mov ah,byte[char+1]
	jmp con
	
	
end:
    jmp $                   ; Í£Ö¹»­¿ò£¬ÎÞÏÞÑ­»· 
	


;code ENDS
;     END start
times 510-($-$$) db 0
 db 0x55,0xaa	