/* This is an -*- asm -*- file.  ********************************************
 *                                                                          *
 *                GNAT RUN-TIME LIBRARY (GNARL) COMPONENTS                  *
 *                                                                          *
 *                            S T A R T - R A M                             *
 *                                                                          *
 *                              Assembly File                               *
 *                                                                          *
 *                     Copyright (C) 2011 AdaCore                           *
 *                                                                          *
 * GNAT is free software;  you can  redistribute it  and/or modify it under *
 * terms of the  GNU General Public License as published  by the Free Soft- *
 * ware  Foundation;  either version 3,  or (at your option) any later ver- *
 * sion.  GNAT is distributed in the hope that it will be useful, but WITH- *
 * OUT ANY WARRANTY;  without even the  implied warranty of MERCHANTABILITY *
 * or FITNESS FOR A PARTICULAR PURPOSE.                                     *
 *                                                                          *
 * As a special exception under Section 7 of GPL version 3, you are granted *
 * additional permissions described in the GCC Runtime Library Exception,   *
 * version 3.1, as published by the Free Software Foundation.               *
 *                                                                          *
 * You should have received a copy of the GNU General Public License and    *
 * a copy of the GCC Runtime Library Exception along with this program;     *
 * see the files COPYING3 and COPYING.RUNTIME respectively.  If not, see    *
 * <http://www.gnu.org/licenses/>.                                          *
 *                                                                          *
 ****************************************************************************/

/* Define this variable if the ivpr needs to be saved so that you could use
   sc to return to a monitor.  */
#undef NEED_SAVE_IVPR

	.section ".text"
        .global _start_ram

_start_ram:
  	# Load the new stack pointer
        lis	%r11,(__stack_end - 16)@h
        ori	%r11,%r11,(__stack_end - 16)@l
        # back-link to the previous one.
        stw	%r1,0(%r11)
        # Set the stack.
        mr      %r1,%r11
        # Save lr
        mflr	%r0
        stw	%r0,4(%r1)

        # Setup: set r2, r13, clear bss
        bl	_setup

#ifdef NEED_SAVE_IVPR
        # Save IVPR
        mfspr   %r0, 63
        lis	%r11,__gnat_saved_ivpr@h
        ori	%r11,%r11,__gnat_saved_ivpr@l
        stw     %r0,0(%r11)
#endif

#ifdef CALL__init
	# Call constructors
	bl    __init
#endif

        # Run the program
        bl	main

        # Reset the board.
        # Comment out the following line if you want to return to the monitor
        # (assuming that this is possible).
        bl      _exit

	# Return to the monitor

        # Restore lr.
        lwz	%r0,4(%r1)
        # Restore sp.
        lwz	%r1,0(%r1)
        # Return.
        mtlr	%r0
        blr

	.size _start_ram, . - _start_ram

#ifdef NEED_SAVE_IVPR
        .globl __gnat_saved_ivpr
        .section        ".sbss","aw",@nobits
        .align 2
__gnat_saved_ivpr:
        .zero   4
        .size   __gnat_saved_ivpr, 4
        .type   __gnat_saved_ivpr, @object
#endif
