	AREA	AsmTemplate, CODE, READONLY
	IMPORT	main

; sample program makes the 4 LEDs P1.16, P1.17, P1.18, P1.19 go on and off in sequence
; (c) Mike Brady, 2011 -- 2019.

	EXPORT	start
start

IO1DIR	EQU	0xE0028018
IO1SET	EQU	0xE0028014
IO1CLR	EQU	0xE002801C
	
;	TODO
; 	get decimal representation from hex
;   get binary representation using TABLE
; 	calls flash subroutine
	
	mov r0,#3
	BL flash

;
;	flash subroutine
;	Show the binary representation with LED flashing	
;	parameter: 
;	 R0: binary representation
;	output:
;	 none

flash   PUSH {r3-r6,pc}
		ldr	r1,=IO1DIR
		ldr	r2,=0x000f0000	;select P1.19--P1.16
		str	r2,[r1]		;make them outputs
		ldr	r1,=IO1SET
		str	r2,[r1]		;set them to turn the LEDs off
		ldr	r2,=IO1CLR
; r1 points to the SET register
; r2 points to the CLEAR register

	
	ldr	r5,=0x000170000	; end when the mask reaches this value
	ldr r6,=0
		
		ldr	r3,=0x000080000	; start with P1.16.
floop	cmp r0,#0
		beq ds 
		movs r0,r0,lsr #1
		adc r6,r6,#0
		cmp r6,#0
		beq nset
		str	r3,[r2]	   	; clear the bit -> turn on the LED
nset	mov r3,r3,lsr #1
		b floop

;delay for about a half second
ds	ldr	r4,=4000000
dloop	subs	r4,r4,#1
	bne	dloop
	
offs	str	r3,[r1]		;set the bit -> turn off the LED
		mov	r3,r3,lsl #1	;shift up to next bit. P1.16 -> P1.17 etc.
		cmp	r3,r5
		blt	offs
		
		POP {r3-r6,lr}
stop	B	stop

TABLE   DCB 0xF, 0x1, 0x2, 0x3 ; 0-3
		DCB 0x4, 0x5, 0x6, 0x7 ; 4-7
		DCB 0x8, 0x9  		   ; 8-9
		DCB 0xA				   ; - sign
		


	END