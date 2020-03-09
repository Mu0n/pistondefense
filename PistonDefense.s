ENPOSITION = $00  ;current address for the position of the enemy
ENSTARTPOSITION = $4f  ;start position (right edge of 2nd LCD line)
ENCOUNTER = $01  ;address for the enemy movement delay value
PISTONSTATUS = $02 ;if 0, piston is up, if 1, it is down
ENCURRENTSPEED = $05  ;enemy current delay speed, is meant to decrement as levels go up
FASTESTSPEED = $01 ;fastest speed

EMOVEDELAY = $05  ;counter limit before an enemy moves. starts at 0 and goes up to this value

PORTB = $6000
PORTA = $6001
DDRB = $6002
DDRA = $6003
EN = %00000100  ;LCD enable (PB2)
RW = %00000010  ;LCD read or write (PB1)
RS = %00000001  ;LCD register select (PB0)
; LCD D4-7 connected to PB4-7


  .org $8000

reset:
  ;set port B as output which will latch
  lda #%11111111
  sta DDRB

  ; Set port A as inout which will latch
  lda #%00000000  
  sta DDRA

  jsr lcd_init 

  lda #%00101000  ; Set 4bit, 2line, 5x8 font
  jsr lcdcmd
   
screensetup:
;Clear display
   lda #%00000001 ; clear display
   jsr lcdcmd
;Display on control
   lda #%00001110 ; display on, cursor on, no blink
   jsr lcdcmd
;Entry mode set
   lda #%00000110 ; increment by 1, don't shift
   jsr lcdcmd 
   
;Text to send out
   lda #"P"
   jsr write
 ;Text to send out
   lda #"i"  ; é
   jsr write
 ;Text to send out
   lda #"s"
   jsr write
 ;Text to send out
   lda #"t"
   jsr write
 ;Text to send out
   lda #"o"
   jsr write
 ;Text to send out
   lda #"n"
   jsr write
   
 ;Text to send out
   lda #%00100000  ;space
   jsr write
   
 ;Text to send out
   lda #"D"
   jsr write
;Text to send out
   lda #"e"
   jsr write
;Text to send out
   lda #"f"
   jsr write
;Text to send out
   lda #"e"
   jsr write
;Text to send out
   lda #"n"
   jsr write
;Text to send out
   lda #"s"
   jsr write
;Text to send out
   lda #"e"
   jsr write
   
;Go to the other line=
   lda #%11000000 ; set DDRAM Address to $40, highest byte means DDRAM address change
   jsr lcdcmd  
   
;Text to send out
   lda #"P"
   jsr write
;Text to send out
   lda #"u"
   jsr write
;Text to send out
   lda #"s"
   jsr write
 ;Text to send out
   lda #"h"
   jsr write
   
  ;Text to send out
   lda #%00100000  ;space
   jsr write
   
 ;Text to send out
   lda #"t"
   jsr write
 ;Text to send out
   lda #"o"
   jsr write
  
  ;Text to send out
   lda #%00100000  ;space
   jsr write
 
;Text to send out
   lda #"S"
   jsr write
;Text to send out
   lda #"t"
   jsr write
;Text to send out
   lda #"a"
   jsr write
;Text to send out
   lda #"r"
   jsr write
;Text to send out
   lda #"t"
   jsr write
   jmp splashloop

lcd_init:
  lda #%10101010 ; debug line
  lda #(%00100000 | EN)  ; 4-bit operation
  sta PORTB
  lda #0
  sta PORTB       ; Clear EN
  rts 

lcdcmd:
  tax           ; transfer A to X
  ora #EN       ; set enable flag
  sta PORTB     ; send to lcd
  lda #0
  sta PORTB     
  txa           ; transfer X to X
  asl           ; shift left
  asl           ; shift left
  asl           ; shift left
  asl           ; shift left
  ora #EN       ; set enable flag
  sta PORTB
  lda #0
  sta PORTB
  rts

write:
  tax             ; transfer A to X
  ora #(EN | RS)  ; set enable flag
  sta PORTB       ; send to lcd
  lda #0
  sta PORTB     
  txa             ; transfer X to A
  asl             ; shift left
  asl             ; shift left
  asl             ; shift left
  asl             ; shift left
  ora #(EN | RS)  ; set enable flag
  sta PORTB
  lda #0
  sta PORTB
  rts
   
splashloop:
    lda PORTA    ; get the data from porta
    and #%00000001  ; get only the lowest byte, the one tied to PA0 and the switch
    cmp #%00000001
    bne gamesetup     ; the button made porta bit-0 go low, so erase and set up the game
    jmp splashloop        ; keep reading on


;
; GAME SETUP
;
   lda EMOVEDELAY  ;initial delay value for enemy speed
   sta ENCURRENTSPEED
   
gamesetup:
;Clear display
   lda #%00000001 ; clear display
   jsr lcdcmd
;Display on control
   lda #%00001100 ; display on, cursor on, no blink
   jsr lcdcmd
;Draw the initial piston position
   lda #%10000111 ; set DDRAM Address to $07, highest byte means DDRAM address change
   jsr lcdcmd 
   lda #"U"
   jsr write
;Piston status set to up, value 0
   lda #$00
   sta PISTONSTATUS
;Spawn first projectile
   lda #ENSTARTPOSITION  ;position $4f (right edge of second row)
   sta ENPOSITION   ;store current enemy position in zp address
   ora #%10000000  ;add first bit for lcd address command
   jsr lcdcmd
   lda #"o"
   jsr write
;Set the move delay counter
   lda #$00
   sta ENCOUNTER
   
   jmp gameloop
   
gameloop:
;increment the move counter
   inc ENCOUNTER
   lda ENCOUNTER
   cmp #ENCURRENTSPEED
   beq moveleft   ;it is time to move left
   
checkcrushbutton:
   lda PORTA
   and #%00000010 ;check if the crush button is pressed
   cmp #%00000010
   bne pistondown
checkreleasebutton:
   lda PORTA
   and #%00000001 ;check if the release button is pressed
   cmp #%00000001
   bne pistonup
   
   jmp gameloop
   
   
   
;
; SUBROUTINES
;

pistonup:
   lda #$00   ;set the piston status to up, value 0
   sta PISTONSTATUS
;Draw the piston up after you release it
   lda #%11000111 ; set DDRAM Address to $47, highest byte means DDRAM address change
   jsr lcdcmd 
   lda #%00100000  ;space
   jsr write
   jmp gameloop
   
pistondown:
   lda #$01   ;set the piston status to down, value 1
   sta PISTONSTATUS
;Draw the piston in crush position
   lda #%11000111 ; set DDRAM Address to $47, highest byte means DDRAM address change
   jsr lcdcmd 
   lda #"U"
   jsr write
;
;TODO add code for crush detection
;
   lda ENPOSITION
   cmp #$47  ;is the winning condition met?
   beq win
;END code for crush detection
   jmp gameloop

moveleft:
;reset the counter
  lda #$00
  sta ENCOUNTER   
;move the projectile left
  lda ENPOSITION
  ora #%10000000  ;make it into a LCD address-command
  jsr lcdcmd
  lda #%00100000  ;space
  jsr write   ;erase old position
 
  dec ENPOSITION  ;decrease position by 1
  lda ENPOSITION
  cmp #$3F  ;has it reached outside the end of the screen?
  beq death
  
  lda ENPOSITION
  cmp #$47  ;has it reached under the piston position?
  beq pistonintegritycheck
  
pistonintegrityok:
  
  ;write the projectile in the new position
  lda ENPOSITION
  ora #%10000000  ;add the first bit for lcd address setting command
  jsr lcdcmd
  lda #"o"
  jsr write
  
  jmp gameloop

pistonintegritycheck:
;check if the piston is down while the projectile reaches it
   lda PISTONSTATUS
   cmp #$01 ;oh no piston is down
   beq death
   jmp pistonintegrityok  ;phew, it is alright

win:
   ;lda ENCURRENTSPEED
   ;cmp #FASTESTSPEED
   ;beq goback
   dec ENCURRENTSPEED
   jmp gamesetup
   
goback:
   jmp gamesetup
   
death:
;
;TODO add death routine
;
;Draw the initial piston position
   lda #%10000111 ; set DDRAM Address to $07, highest byte means DDRAM address change
   jsr lcdcmd 
   lda #"X"
   jsr write
   
   lda #%11000111 ; set DDRAM Address to $47, highest byte means DDRAM address change
   jsr lcdcmd 
   lda #"X"
   jsr write
  nop
  jmp death
  
;text data for the game splash screensetup
  .org $ff00
  .byte "Piston Defense v0.1"
  .org $ff20
  .byte "Push a button to start playing"
  
;set the program counter vector (last 2 bytes) 
  .org $fffc
  .word $8000
  .word $0000
   