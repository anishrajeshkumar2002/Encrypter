	////////////////////////////
	// version 1.3 11/22/2021 //
	////////////////////////////
	.arch armv6				// armv6 architecture
	.arm					// arm 32-bit instruction set
	.fpu vfp				// floating point co-processor
	.syntax unified				// modern sytax

	// function import
	.extern encrypt
	.extern decrypt
	.extern stderr
	.extern fprintf
	.extern fclose
	.extern setup
	.extern encryptdelete

	// global constants
	.include "encrypter.h"

	.section .rodata
.Lmsg1:	.string "Write failed on output\n"
.Lmsg2:	.string "Bookfile is too short for message\n"
	.text

	//////////////////////////////////////////////////////
	// int main(int argc, char **argv)                  //
	// encrypter [-d | -e] -b bookfile encryption_file  //
	//////////////////////////////////////////////////////

	.global main				// main global for linking to
	.type	main, %function			// define as a function
	.equ	FP_OFF,		32		// fp offset in main stack frame
	.equ 	BUFSZ,		1024		// max for assignment is 4096 min is 1024

	//////////////////////////////////////////////////////////////////////////////
	// automatics (local variable) frame layout
	// NOTICE! odd # of regs pushed, Not 8-byte aligned at FP_OFF; add 4 bytes pad
	// 
	// local stack frame name are used with fp as base
	// format is .equ VAR_NAME, NAME_OF_PREVIOUS_VARIABLE + <size of variable>
	// first variable should use  FP_OFF as the previous variable
	//////////////////////////////////////////////////////////////////////////////
	.equ	FPBOOK,		FP_OFF+4	// FILE * to book file
	.equ	FPIN,		FPBOOK+4	// FILE * to input file
	.equ	FPOUT,		FPIN+4		// FILE * to output file
	.equ	MODE,		FPOUT+4		// decrypt or encrypt mode
       // .equ    EXTRA,          MODE +4
       // .equ    READCNT,        EXTRA +4
	.equ	IOBUF,		MODE+BUFSZ	// buffer for input file
	.equ	BOOKBUF,	IOBUF+BUFSZ	// buffer for book file
	// add local variables here: Then adjust PAD or comment out pad line as needed 
	.equ	PAD,		BOOKBUF+4
        .equ    EXTRA,           PAD + 4
        .equ    READCNT,         EXTRA + 4                                 	
	.equ	OUT6,		READCNT+4		// output arg6
	.equ	OUT5,		OUT6+4		// output arg5 must be at bottom
	.equ	FRAMESZ,	OUT5-FP_OFF	// total space for automatics
	//////////////////////////////////////////////////////////////////////////////
	// make sure that FRAMESZ + FP_OFF + 4 divides by 8 EVENLY!
	//////////////////////////////////////////////////////////////////////////////
	
	//////////////////////////////////////////////////////////////////////////////
	// passed arg offsets used with sp as the base
	//////////////////////////////////////////////////////////////////////////////
	.equ	OARG6,		4		// Outgoing arg 6		
	.equ	OARG5,		0		// Outgoing arg 5		

main:
	// function prologue
	push	{r4-r10, fp, lr}		// WARNING! odd count register save!
	add	fp, sp, FP_OFF			// set frame pointer to frame base
	LDR	r4,=FRAMESZ			// if frame size is too big, use pseudo ldr
        sub     sp,sp,r4
        sub     r2,fp,MODE                   	// allocate space for locals and passed args
        sub     r3,fp,FPBOOK
        sub     r4,fp,FPIN
        str     r4,[sp,OARG5]
        sub     r4,fp,FPOUT
        str     r4,[sp,OARG6]
        bl      setup
        str     r0,[fp,-EXTRA]
        cmp     r0,#1
        bne     .Lloop
        b       .Ldone
.Lloop:
        ldr     r0, =IOBUF
        sub     r0,fp,r0
        mov     r1,#1
        mov     r2,BUFSZ
        ldr     r3,[fp,-FPIN]
        bl      fread
        str     r0,[fp,-READCNT]
        ldr     r4,[fp,-READCNT]
        cmp     r4,#0
        ble     .Ldone
        ldr     r0, =BOOKBUF
        sub     r0,fp,r0
        mov     r1,#1 
        ldr     r2,[fp,-READCNT]
        ldr     r3,[fp,-FPBOOK]
        bl      fread
        cmp     r0,r4
        beq     endif
        ldr     r5,=stderr
        ldr     r0,[r5]
        ldr     r1,=.Lmsg2
        bl      fprintf
        b       .Ldone
endif:
        ldr     r8,[fp,-MODE]
        cmp     r8,#1
        bne     sub1
        mov     r6,#0
        cmp     r6,r4
        bge     endfr
for:
        sub     r5,fp,IOBUF
        ldrb    r7,[r5,r6]
        mov     r0,r7
        sub     r5,fp,BOOKBUF
        ldrb    r7,[r5,r6]
        mov     r1,r7
        bl      encrypt
        sub     r5,fp,IOBUF
        strb    r0,[r5,r6]
        add     r6,r6,#1
        cmp     r6,r4
        blt     for
endfr:
        b       endif2
sub1:
        mov     r6,#0
        cmp     r6,r4
        bge     endfr2
for2:   
        sub     r5,fp,IOBUF
        ldrb    r7,[r5,r6]
        mov     r0,r7
        sub     r5,fp,BOOKBUF
        ldrb    r7,[r5,r6]
        mov     r1,r7
        bl      decrypt
        sub     r5,fp,IOBUF
        strb    r0,[r5,r6]
        add     r6,r6,#1
        cmp     r6,r4
        blt     for2
endfr2:
        b       endif2
endif2:
        sub     r0,fp,IOBUF
        mov     r1,#1
        mov     r2,r4
        ldr     r3,[fp,-FPOUT]
        bl      fwrite
        cmp     r0,r4
        beq     endif3
        ldr     r5, =stderr
        ldr     r0,[r5]
        ldr     r1,=.Lmsg2
        bl      fprintf
        b       .Ldone
endif3:
        cmp     r4,0
        bgt     .Lloop
.Ldone:
        ldr     r0,[fp,-FPIN]
        bl       fclose
        ldr     r0,[fp,-FPOUT]
        bl       fclose
        ldr     r0,[fp,-FPBOOK]
        bl       fclose
        ldr     r3,[fp,-EXTRA]
        cmp     r8,#1
        bne     skipif
        cmp     r3,#1
        bne     skipif
        bl      encryptdelete
        b       endprog
skipif:
        ldr     r0,[fp,-EXTRA]
endprog:
        ldr     r0,[fp,-EXTRA]
	// close the files using fclose()

	// if encrypt failed to finish all input remove the incomplete encrypt file

	// function epilogue
	sub	sp, fp, FP_OFF			// restore stack frame top
	pop	{r4-r10,fp,lr}			// remove frame and restore
	bx	lr				// return to caller

	// function footer
	.size	main, (. - main)		// set size for function

	// file footer
	.section .note.GNU-stack,"",%progbits // set executable (linker)
.end
