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
	
	ldr r0, =0x419
	mov r1, r0 ; creates a copy
	ldr r4, =0x40000000	; address
	add r6,r4,#10		; sign address
	ldr r5, =0
	strb r5,[r6] 		; clears memory
	
sign movs r1,r1, lsl #1
	 ldr r2,=0
	 adc r2,r2,#0
	 cmp r2,#1
	 bne startdiv
	 ldr r2, =1		; stores neg bit
	 strb r2,[r6]
	 ldr r2,=0xffffffff
	 eor r0,r0,r2	; flip all bits 
	 add r0,r0,#1 	; +1
	
	
startdiv	ldr r2,=DIVTABLE 
			ldr r8,=0
div		cmp r2,r6			; if still in bounds
		bge leds
		ldr r5,[R2],#4 ; largers number of power's of 10
		cmp r0,#0			; if still have remaining
		beq leds
		
div2 	cmp r0,r5			; if number larger than divisor
		blt small
		sub r0,r0,r5		; numb = numb - divisor
		add r8,r8,#1		; increment count
		b div2
	 
small strb r8,[r4],#1
	  ldr r8,=0			; reset count
	  b div
	 
leds	ldr r4, =0x40000000	; address
fstart	cmp r4,r6			; if the relative value of the count is larger than 0
		bgt	nothing
		ldrb r5,[r4],#1		; find the count and increment
		cmp r5,#0			; if nothing
		bgt startled
		b fstart

nothing ldr r0, =0		;nothing
		bl flash	
		b stop

startled	sub r4,r4,#1 	; return to correct address
			ldrb r5,[r6]		; loads the sign
			cmp r5,#1		; if negative
			bne flashnum
			ldr r0, =0xB		; flash negative sign
			BL flash
		
flashnum	cmp r4,r6
			bge stop
			ldrb r0,[r4],#1	; get count and increment address
			bl flash
			b flashnum
			
stop	B	stop

;
;	flash subroutine
;	Show the binary representation with LED flashing	
;	parameter: 
;	 R0: binary representation
;	output:
;	 none

flash   PUSH {r3-r6,lr}
		ldr	r1,=IO1DIR
		ldr	r2,=0x000f0000	;select P1.19--P1.16
		str	r2,[r1]		;make them outputs
		ldr	r1,=IO1SET
		str	r2,[r1]		;set them to turn the LEDs off
		ldr	r2,=IO1CLR
; r1 points to the SET register
; r2 points to the CLEAR register

	
	ldr	r5,=0x000080000	; end when the mask reaches this value

		cmp r0,#0
		bne fs 
		ldr r0,=0xf
fs		ldr	r3,=0x000080000	; start with P1.16.
floop	ldr r6,=0
		cmp r0,#0
		beq ds 
		movs r0,r0,lsr #1
		adc r6,r6,#0
		cmp r6,#0
		beq nset
		str	r3,[r2]	   	; clear the bit -> turn on the LED
nset	mov r3,r3,lsr #1
		b floop

;delay for about a half second
ds	ldr	r4,=8000000
dloop	subs	r4,r4,#1
	bne	dloop
	
offs	mov	r3,r3,lsl #1	;shift up to next bit. P1.16 -> P1.17 etc.
		str	r3,[r1]		;set the bit -> turn off the LED
		cmp	r3,r5
		blt	offs
		POP {r3-r6,pc}
		


DIVTABLE DCD 1000000000, 100000000, 10000000, 1000000, 100000, 10000, 1000, 100, 10, 1	

	END