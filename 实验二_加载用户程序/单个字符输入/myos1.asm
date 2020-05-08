;程序源代码（myos1.asm）
org  7c00h    ;引导扇区这行有效
;org  100h         ;.com这行有效   bin则这行去掉
;org 0h

		; BIOS将把引导扇区加载到0:7C00h处，并开始执行
OffSetOfUserPrg1 equ 8100h
Start:
	mov	ax, cs	        ; 置其他段寄存器值与CS相同
	mov	ds, ax	       ; 数据段
	mov	bp, Message		  ; BP=当前串的偏移地址
	mov	ax, ds		  ; ES:BP = 串地址
	mov	es, ax		  ; 置ES=DS
	mov	cx, MessageLength   ; CX = 串长（=9）
	mov	ax, 1301h		 ; AH = 13h（功能号）、AL = 01h（光标置于串尾）-
	mov	bx, 0007h		  ; 页号为0(BH = 0) 黑底白字(BL = 07h)
      mov dh, 0		        ; 行号=0
	mov	dl, 0			  ; 列号=0
	int	10h			  ; BIOS的10h功能：显示一行字符

      ;读入键盘输入
      mov ah,0
      int 16h
      cmp al,'a'
      je  A
      cmp al,'b'
      je B
      cmp al,'c'
      je C
      cmp al,'d'
      je D

A: 
      mov cl,2    ;起始扇区号 ,起始编号为1
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
      jmp Start

AfterRun:
      jmp $                      ;ÎÞÏÞÑ­»·
Message:
      db 'Hello, type a,b,c,d choose for user program¡­'        
MessageLength  equ ($-Message)
RecordMsg：
      db 'name    sector'  
ProgramA:
      db ' a         2  '   
ProgramB:
      db ' b         3  '    
ProgramC:
      db ' c         4  '      
ProgramD:
      db ' d         5  '  
      times 510-($-$$) db 0
      db 0x55,0xaa

