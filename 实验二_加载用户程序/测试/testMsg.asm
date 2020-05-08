;程序源代码（myos1.asm）
org  7c00h    ;引导扇区这行有效
;org  100h         ;.com这行有效   bin则这行去掉
;org 0h

		; BIOS将把引导扇区加载到0:7C00h处，并开始执行
OffSetOfUserPrg1 equ 8100h
Start:
	mov	ax, cs	        ; 置其他段寄存器值与CS相同
	mov	ds, ax	       ; 数据段
      mov   ax,0b800h
      mov es,ax
	mov	bp, Message		  ; BP=当前串的偏移地址
	mov	ax, ds		  ; ES:BP = 串地址
	mov	es, ax		  ; 置ES=DS
	mov	cx, MessageLength   ; CX = 串长（=9）
	mov	ax, 1301h		 ; AH = 13h（功能号）、AL = 01h（光标置于串尾）-
	mov	bx, 0007h		  ; 页号为0(BH = 0) 黑底白字(BL = 07h)
      mov dh, 0		        ; 行号=0
	mov	dl, 0			  ; 列号=0
	int	10h			  ; BIOS的10h功能：显示一行字符

      ;读入键盘输入字符串
      call getstr

getchar:
      mov ah,3
      call charstack
      inc word[cnt]
      cmp al,'a'
      je  A
      cmp al,'b'
      je B
      cmp al,'c'
      je C
      cmp al,'d'
      je D
      cmp al,'0'
      jne getchar
      mov word[cnt],0
      mov word[top],0
      jmp Start


A: 
      mov cl,2    ;起始扇区号 ; 起始编号为1
      jmp LoadnEx
B:
      mov cl,3
      jmp LoadnEx
C:
      mov cl,4
      jmp LoadnEx
D:
      mov cl,5            

LoadnEx:
     ;读软盘或硬盘上的若干物理扇区到内存的ES:BX处：
      mov ax,cs                 ;段地址 ; 存放数据的内存基地址
      mov es,ax                ;设置段地址（不能直接mov es,段地址）
      mov bx, OffSetOfUserPrg1  ;偏移地址; 存放数据的内存偏移地址
      mov ah,2                 ; 功能号
      mov al,1                 ;扇区数
      mov dl,0                  ;驱动器号 ; 软盘为0，硬盘和U盘为80H
      mov dh,0                ;磁头号 ; 起始编号为0
      mov ch,0                 ;柱面号 ; 起始编号为0
      int 13H ;               调用读磁盘BIOS的13h功能
       ; 用户程序a.com已加载到指定内存区域中
      mov bx,0b800h
      mov es,bx
      mov bx,0                      
      mov cx,2000

s1:
      mov byte [es:bx],' '
      inc bx
      mov byte [es:bx],00000000b
      inc bx
      loop s1
      call 800h:100h
      mov ax,cs
      mov ds,ax               ;注意ds!!!
      ;清屏
      mov bx,0                      
      mov cx,2000

s:
      mov byte [es:bx],' '
      inc bx
      mov byte [es:bx],00000000b
      inc bx
      loop s
      jmp getchar


getstr:
      push ax

getstrs:
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

table dw charpush,charpop,charshow,charget
top   dw 0
cnt   dw 0 

charstart:
      push bx
      push dx
      push di
      push es

      cmp ah,3
      ja sret
      mov bl,ah
      mov bh,0
      add bx,bx
      jmp word[table+bx]

charpush:
      mov bx,[top]
      mov [bx],al
      inc word[top]
      jmp sret

charpop:
      cmp word[top],0
      je sret
      dec word[top]
      mov bx,[top]
      mov al,[bx]
      jmp sret

charshow:
      mov bx,0b800h
      mov es,bx
      mov di,184
      mov bx,0 

charshows:  
      cmp bx,[top]
      jne noempty
      mov byte[es:di],' '
      jmp sret

noempty:
      mov al,[bx]
      mov [es:di],al
      mov byte[es:di+1],07h
      mov byte[es:di+2],' '
      inc bx
      add di,2
      jmp charshows

charget:
      mov bx,word[cnt]
      cmp bx,[top]
      jne none
      mov al,'0'
      jmp sret
none:
      mov al,[bx]      
      jmp sret

sret:
      pop es
      pop di
      pop dx
      pop bx
      ret


AfterRun:
      jmp $                      ;ÎÞÏÞÑ­»·

     
Message:
      db 'Hello, type a,b,c,d choose for user program¡­'
      db 'name    sector'  
      db ' a         2  '   
      db ' b         3  '    
      db ' c         4  '      
      db ' d         5  '      
      db 'Enter:'
MessageLength  equ ($-Message)
            
      times 510-($-$$) db 0
      db 0x55,0xaa

