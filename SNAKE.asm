droit equ colonne+10
bas equ haut+ligne+10
gauche equ 5
haut equ 5
ligne equ 25
colonne equ 25


.model small


.data 


;--------------------------menu-----------------------------------------     
    menu db "Boukada Adel & Riviere Anthony ",13,10
     db " SnaKE",13,10
     db "Que souhaitez vous faire ?",13,10
     db " 1- Jouer",13,10,'$'
     
     
     
     ;---------------------jeu----------------------------------
    delaitemps db 10
    quitmsg db "Au revoir",0
    corps db '_',10,11 
    enplace db 1
    x db 10
	y db 10
    tete db '^',10,10
    gameover db 0
    quitter db 0   

;---------------------------------------------------------------------
  
SSEG	SEGMENT		STACK
		DB			32 DUP("STACK---")
SSEG ENDS

.code


	call fond 

main proc far
	call lmenu
	
fond proc
	mov     al,15           
	mov     bx, 0A000h      
	mov     es, bx
	mov     di, 0           
	mov     cx, 64000      
	rep     stosb  
fond endp	     
 ;a ne pas prendre en compte cela est un code pour amérliorer l'aspect graphique par la suite il n'est pas fonction
 pixel_fruit proc
mov cx, 4dh
    mov dx,cx
    push dx
    push cx
    mov ax,0C07H
    mov bh,0
    int 10h
    add cx,1
    mov ax,0C07H
    MOV BH,0
    int 10h
    ADD DX,1
    mov ax,0C07H
    mov bh,0
    pop cx
    pop dx 
    push dx
    push cx
    add dx,1
    mov ax,0C07H
    mov bh,0
    int 10h 
pixel_fruit endp
      
jeu: 
	
    call delai           
    lea bx, menu
    mov dx, 00
    
    call mouvement_snake
    cmp gameover,1
    je gameover_jeu
    
    call clavierfonction
    cmp quitter, 1
    je quitpress_mainloop
    call creerf
    call dessin
    jmp jeu
    
gameover_jeu: 
    mov ax, 0003H
	int 10H
    mov delaitemps, 100
    mov dx, 0000H
  
    call delai    
    jmp quit_mainloop    
    
quitpress_mainloop:
    mov ax, 0003H
	int 10H    
    mov delaitemps, 100
    mov dx, 0000H
    lea bx, quitmsg

    call delai   
    jmp quit_mainloop    

	quit_mainloop:
	mov ax, 0003H
	int 10h    
	mov ax, 4c00h
	int 21h  


delai proc 
    
    mov ah, 00
    int 1Ah
    mov bx, dx
    
jmp_delai:
    int 1Ah
    sub dx, bx
    cmp dl, delaitemps                                                     
    jl jmp_delai   
    ret
    
delai endp
   
creerf proc
    mov ch, y
    mov cl, x
regenerate:
    
    cmp enplace, 1
    je ret_enplace
    mov ah, 00
    int 1Ah
    push dx
    mov ax, dx
    xor dx, dx
    xor bh, bh
    mov bl, ligne
    dec bl
    div bx
    mov y, dl
    inc y
    
    
    pop ax
    mov bl, colonne
    dec dl
    xor bh, bh
    xor dx, dx
    div bx
    mov x, dl
    inc x
    
    cmp x, cl
    jne rien
    cmp y, ch
    jne rien
    jmp regenerate             
rien:
    mov al, x
    ror al,1
    jc regenerate    
    
    add y, haut
    add x, gauche 
    
    mov dh, y
    mov dl, x
    call lirecharat
    cmp bl, '*'
    je regenerate
    cmp bl, '^'
    je regenerate
    cmp bl, '<'
    je regenerate
    cmp bl, '>'
    je regenerate
    cmp bl, 'v'
    je regenerate    
    
ret_enplace:
    ret
creerf endp




positcurseur proc
    mov ah, 02H
    push bx
    mov bh,0
    int 10h
    pop bx
    ret
positcurseur endp

dessin proc
    
    
      
    add dx, 7
    call positcurseur

    dec al
    xor ah, ah
    
        
    lea si, tete
dessin_loop:
    mov bl, ds:[si]
    test bl, bl
    jz out_dessin
    mov dx, ds:[si+1]
    call ecrirecharat
    add si,3   
    jmp dessin_loop 

out_dessin:
    mov bl, '*'
    mov dh, y
    mov dl, x
    call ecrirecharat
    mov enplace, 1
    ret     
dessin endp

lirechar proc
    mov ah, 01H
    int 16H
    jnz clavierpress
    xor dl, dl
    ret
clavierpress:
    mov ah, 00H
    int 16H
    mov dl,al
    ret


lirechar endp                    
                      


clavierfonction proc
    
    call lirechar
    cmp dl, 0
    je suivant_14
    
    cmp dl, 'z'
    jne suivant_11
    cmp tete, 'v'
    je suivant_14
    mov tete, '^'
    ret
suivant_11:
    cmp dl, 's'
    jne suivant_12
    cmp tete, '^'
    je suivant_14
    mov tete, 'v'
    ret
suivant_12:
    cmp dl, 'q'
    jne suivant_13
    cmp tete, '>'
    je suivant_14
    mov tete, '<'
    ret
suivant_13:
    cmp dl, 'd'
    jne suivant_14
    cmp tete, '<'
    je suivant_14
    mov tete,'>'
suivant_14:    
    cmp dl, 'p'
    je quitte
    ret    
quitte:   
    inc quitter
    ret
    
clavierfonction endp
                  
                    
mouvement_snake proc     
    mov bx, offset tete
    
    xor ax, ax
    mov al, [bx]
    push ax
    inc bx
    mov ax, [bx]
    inc bx    
    inc bx
    xor cx, cx

l:      
    mov si, [bx]
    test si, [bx]
    jz sorti_limite
    inc cx     
    inc bx
    mov dx,[bx]
    mov [bx], ax
    mov ax,dx
    inc bx
    inc bx
    jmp l

sorti_limite:    

    pop ax
    push dx
    
    lea bx, tete
    inc bx
    mov dx, [bx]
    
    cmp al, '<'
    jne deplace_gauche
    dec dl
    dec dl
    jmp verifie_tete
    
deplace_gauche:
    cmp al, '>'
    jne suivant_2                
    inc dl 
    inc dl
    jmp verifie_tete
    
suivant_2:
    cmp al, '^'
    jne suivant_3 
    dec dh               
                   
    
    jmp verifie_tete
    
suivant_3:
    inc dh
    
verifie_tete:    
    mov [bx],dx
    call lirecharat 
    
    cmp bl, '*'
    je mange_fruit
    
    mov cx, dx
    pop dx 
    cmp bl, '*'    
    je game_over
    mov bl, 0
    call ecrirecharat
    mov dx, cx
    
    cmp dh, haut
    je game_over
    cmp dh, bas
    je game_over
    cmp dl,gauche
    je game_over
    cmp dl, droit
    je game_over   
    
    ret
game_over:
    inc gameover
    ret
mange_fruit:    

    xor ah, ah
    
    
    lea bx, corps
    mov cx, 3
    mul cx
    
    pop dx
    add bx, ax
    mov bx, '*'
    mov [bx+1], dx
    
    mov dh, y
    mov dl, x
    mov bl, 0
    call ecrirecharat
    mov enplace, 0   
    ret 
mouvement_snake endp
   
   
	
terrain proc
    mov dh, haut
    mov dl, gauche
    mov cx, colonne
    mov bl, '='

l1:                 
    call ecrirecharat
    inc dl
    loop l1
    
    mov cx, ligne
    
l2:
    call ecrirecharat
    inc dh
    loop l2
    
    mov cx, colonne
l3:
    call ecrirecharat
    dec dl
    loop l3

    mov cx, ligne     
l4:
    call ecrirecharat    
    dec dh 
    loop l4    
    
    ret
terrain endp
              
 
ecrirecharat proc

    push dx
    mov ax, dx
    and ax, 0FF00H
    shr ax,1
    shr ax,1
    shr ax,1
    shr ax,1
    shr ax,1
    shr ax,1
    shr ax,1  
    shr ax,1  
    
    push bx
    mov bh, 160
    mul bh 
    pop bx
    and dx, 0FFH
    shl dx,1
    add ax, dx
    mov di, ax
    mov es:[di], bl
    pop dx
    ret    
ecrirecharat endp
                       
lirecharat proc
    push dx
    mov ax, dx
    and ax, 0FF00H
    shr ax,1
    shr ax,1
    shr ax,1
    shr ax,1
    shr ax,1
    shr ax,1  
    shr ax,1 
    shr ax,1    
    push bx
    mov bh, 160
    mul bh 
    pop bx
    and dx, 0FFH
    shl dx,1
    add ax, dx
    mov di, ax
    mov bl,es:[di]
    pop dx
    ret
lirecharat endp        

;---------------------------------------------

lmenu  proc 

  mov  ax, @data
  mov  ds, ax
	
  call effacer_ecran
  call afficher_menu      
  call afficher_jeu   
   
  
    
  mov  ah, 7
  int  21h


;---------------------------------------------

afficher_menu:
  mov  dx, offset menu
  mov  ah, 9
  int  21h
  ret

effacer_ecran:
	
  mov  ah, 0
  mov  al, 3
  int  10H
  ret
afficher_jeu:
		mov ax, 0b800H
	mov es, ax
	mov ax, 0003H
	int 10H
    call terrain
    ret

lmenu endp
     
main endp
          
end main
