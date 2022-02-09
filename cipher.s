	// file header
	.arch armv6                  // armv6 architecture
	.arm                         // arm 32-bit instruction set
	.fpu vfp                     // floating point co-processor
	.syntax unified              // modern syntax

	// constant values you want to use throughout the program
	// could go below like:
	// .equ ONE, 1

	.text                        // start of text segment

	.global encrypt              // make encrypt global for linking to
	.type encrypt, %function     // define encrypt to be a function
	.equ FP_OFFSET, 4            // fp offset distance from sp

encrypt:
	// function prologue
	push {fp, lr}                // stack frame register save
	add fp, sp, FP_OFFSET        // set frame pointer to frame base

	// --- DO NOT EDIT LINES ABOVE ---

	AND r2,r0,0x0F  // r2 = r0 && 15;
        LSL r2,r2,4     // r2 = r2 << 4;
        AND r3,r0,0xF0  // r3 = r0 && 240;
        LSR r3,r3,4     // r3 = r3 >> 4;
        ORR r0,r2,r3    // r0 = r2 || r3;
        EOR r0,r0,r1    // r0 <- r0 xor r1;

	// --- DO NOT EDIT LINES BELOW ---

	// function epilogue
	sub sp, fp, FP_OFFSET        // restore stack frame top
	pop {fp, lr}                 // remove frame and restore registers
	bx lr                        // return to caller

	// function footer
	.size encrypt, (. - encrypt) // set size for function

	.global decrypt              // make encrypt global for linking to
	.type decrypt, %function     // define encrypt to be a function
	.equ FP_OFFSET, 4            // fp offset distance from sp

decrypt:
	// function prologue
	push {fp, lr}                // stack frame register save
	add fp, sp, FP_OFFSET        // set frame pointer to frame base

	// --- DO NOT EDIT LINES ABOVE ---
        EOR r0,r0,r1    // r0 <- r0 xor r1    
        AND r2,r0,0x0F  // r2 = r0 && 15
        LSL r2,r2,4     // r2 = r2 << 4
        AND r3,r0,0xF0  // r3 = r0 && 240
        LSR r3,r3,4     // r3 = r3 >> 4
        ORR r0,r2,r3    // r0 = r2 || r3

	

	// --- DO NOT EDIT LINES BELOW ---
	// function epilogue
	sub sp, fp, FP_OFFSET        // restore stack frame top
	pop {fp, lr}                 // remove frame and restore registers
	bx lr                        // return to caller

	// function footer
	.size decrypt, (. - decrypt) // set size for function

	// file footer
	.section .note.GNU-stack, "", %progbits // stack/data non-exec (linker)
.end
	Template is Arm Procedure Call Standard Compliant (for Linux)
