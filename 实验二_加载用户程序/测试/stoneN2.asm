org 100h

     Dn_Rt equ 1                  ;D-Down,U-Up,R-right,L-Left
     Up_Rt equ 2                  ;
     Up_Lt equ 3                  ;
     Dn_Lt equ 4                  ;
     delay equ 50000					; 延时计数器
     ddelay equ 850					; 延时计数器

start:
	mov ax,cs
	mov ds,ax
	mov ax,0B800h				
	mov es,ax					; ES = B800h，指向显示器

showmeg:
	cld
	mov	di,168
	mov si,number
	mov cx,8
	rep movsw
	mov di,200
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
	inc word[x]	
	inc word[y]	
	mov bx,word[x]
	mov ax,12
	sub ax,bx;ax=16
      jz  dr2ur ;碰到底
	mov bx,word[y];bx=1
	mov ax,80
	sub ax,bx;ax=79
      jz  dr2dl;碰到右边
	jmp show
dr2ur:
      mov word[x],10
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
	mov ax,-1
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
	mov ax,38
	sub ax,bx
      jz  ul2ur
	jmp show

ul2dl:
      mov word[x],1
      mov byte[rdul],Dn_Lt	
      jmp show
ul2ur:
      mov word[y],40
      mov byte[rdul],Up_Rt	
      jmp show

	
	
DnLt:
	inc word[x]
	dec word[y]
	mov bx,word[y]
	mov ax,38
	sub ax,bx
      jz  dl2dr
	mov bx,word[x]
	mov ax,12
	sub ax,bx
      jz  dl2ul
	jmp show

dl2dr:
      mov word[y],40
      mov byte[rdul],Dn_Rt	
      jmp show
	
dl2ul:
      mov word[x],10
      mov byte[rdul],Up_Lt	
      jmp show
	
show:	
    mov ax,word[x]			;word[x]当前行
	mov bx,80
	mul bx;					;word[x]*80
	add ax,word[y]			;行+列=当前位置
	mov bx,2
	mul bx					;2*(行+列),一个字符显示占两个字节
	mov bx,ax				;计算结果ax送给bx

	mov dx,[es:bx]			;获得当前显示屏的字符ascii码
	cmp dl,' '				;如果为空，就显示，否则直接进入下一次循环，跳过本次显示
	jnz loop1				;避开显示的信息

	mov di,[cnt]			;循环显示"learnos"的计数
	mov al,byte[char+di]	;要显示的字符
	mov ah,byte[char+di+1]	;设置字符属性

	cmp al,'0'				;"learnos"末尾标志
	jz s1

	add di,2				;指向下一次要显示的字符，2个字节
	mov [cnt],di			;存储下一次要显示的字符的偏移量
		
con:
	mov [es:bx],ax  		;送入显示器
	inc word[dcnt]
	cmp word[dcnt],100
	jnz loop1				;继续蛇形运动
	retf						;返回操作系统
s1:
	mov word[cnt],0			;重新循环"learnos"
	mov al,byte[char]		;要显示的字符
	mov ah,byte[char+1]		;设置字符属性
	jmp con
	
	
end:
    jmp $                   ; Í£Ö¹»­¿ò£¬ÎÞÏÞÑ­»· 
	
datadef:	
    count dw delay
    dcount dw ddelay
    rdul db Dn_Rt
    x    dw 7		;行
    y    dw 40		;列
    cnt  dw 0
    dcnt dw 0
    char db 'l',40h,'e',20h,'a',14h,'r',48h,'n',40h,'O',20h,'S',14h,'0',0		;要显示的字符
    number  db	'1',09h,'8',09h,'3',09h,'4',09h,'0',09h,'0',09h,'6',09h,'4',09h
    name	db 'h',09h,'u',09h,'a',09h,'n',09h,'g',09h,'s',09h,'i',09h,'r',09h,'o',09h,'n',09h,'g',09h

;code EN
;     END start
times 510-($-$$) db 0
 db 0x55,0xaa	