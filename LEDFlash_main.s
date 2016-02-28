;****************** main.s ***************
; Program written by: Connor Widder
; Date Created: 1/22/2016 
; Last Modified: 1/22/2016 
; Section: Wednessday 4-5
; Instructor: Ramesh Yerraballi
; Lab number: 3
; Brief description of the program
;   If the switch is presses, the LED toggles at 8 Hz
; Hardware connections
;  PE1 is switch input  (1 means pressed, 0 means not pressed)
;  PE0 is LED output (1 activates external LED on protoboard) 
;Overall functionality of this system is the similar to Lab 2, with six changes:
;1-  the pin to which we connect the switch is moved to PE1, 
;2-  you will have to remove the PUR initialization because pull up is no longer needed. 
;3-  the pin to which we connect the LED is moved to PE0, 
;4-  the switch is changed from negative to positive logic, and 
;5-  you should increase the delay so it flashes about 8 Hz.
;6-  the LED should be on when the switch is not pressed
; Operation
;   1) Make PE0 an output and make PE1 an input. 
;   2) The system starts with the LED on (make PE0 =1). 
;   3) Wait about 62 ms
;   4) If the switch is pressed (PE1 is 1), then toggle the LED once, else turn the LED on. 
;   5) Steps 3 and 4 are repeated over and over


GPIO_PORTE_DATA_R       EQU   0x400243FC
GPIO_PORTE_DIR_R        EQU   0x40024400
GPIO_PORTE_AFSEL_R      EQU   0x40024420
GPIO_PORTE_DEN_R        EQU   0x4002451C
GPIO_PORTE_AMSEL_R      EQU   0x40024528
GPIO_PORTE_PCTL_R       EQU   0x4002452C
SYSCTL_RCGCGPIO_R       EQU   0x400FE608
COUNT                   EQU   0x0012EBC0
       IMPORT  TExaS_Init
       AREA    |.text|, CODE, READONLY, ALIGN=2
       THUMB
       EXPORT  Start
Start
 ; TExaS_Init sets bus clock at 80 MHz
    BL  TExaS_Init ; voltmeter, scope on PD3


	LDR R0,=SYSCTL_RCGCGPIO_R  ; R0 points to SYSCTL_RCGCGPIO_R
	LDR R1,[R0]    ; LOAD SYSCTL_RCGCGPIO_R INTO R1
	ORR R1,#0x10   ; TURN ON CLOCK
	STR R1,[R0]    ; WRITE BACK INTO SYSCTL_RCGCGPIO_R
	NOP            ; ALLOWS THE CLOCK TO SEETTLE
	NOP
	
	LDR R0,=GPIO_PORTE_DIR_R ; set R0 to location of port E IO
	LDR R1,[R0]
	ORR R1,#0X01
	BIC R1,#0X02
	STR R1,[R0]
		
	LDR R0,=GPIO_PORTE_AFSEL_R	; TURN OFF ALTERNATE SELECT FUNCTION FOR BOTH PINS
	LDR R1,[R0]
	BIC R0,#0X03
	STR R1,[R0]
	
	LDR R0,=GPIO_PORTE_DEN_R	; ENABLE PF3 AND PF4
	LDR R1,[R0]
	ORR R1,#0x03   ;Sets all ports to digital pins, enable PE1,PE0
	STR R1,[R0]
		
	LDR R0,=GPIO_PORTE_DATA_R  ;R0 = 0x400243FC data address for PE
   					   
	LDR R1,[R0]				   
	ORR R1,#0x01

    CPSIE  I    ; TExaS voltmeter, scope runs on interrupts


loop  

	BL 	delay
	LDR R0, =GPIO_PORTE_DATA_R
	LDR R1, [R0]
	
	MOV	R2, R1
	AND R2, #0x02				; R2 <-- PE1
	
	EOR R1, #0x01				; TOGGLE LED PE0
	ADDS R2, #0					
	BNE	skip					; if PF4 on, skip to store. otherwise, turn off the led by clearing bit 3 and then storing
	ORR R1, #0x01
	
skip	
	STR R1, [R0]
	
      B    loop


delay
    LDR R5, =COUNT              ; COUNT DOWN FROM 400000
again
    SUBS R5, #1
    BNE again
    BX  LR



      ALIGN      ; make sure the end of this section is aligned
      END        ; end of file
       