// Author: Erwin Ouyang
// Date  : 13 Dec 2018

#include <stdio.h>
#include <stdint.h>
#include <sleep.h>

uint32_t *shift_reg_p;

int main()
{
	// Pointer to AXI shift register
	shift_reg_p = (uint32_t *)0x40000000;

	// *** Shift left 1001 ***
	*(shift_reg_p+0) = 0x3;		// DIR = 0, DIN = 1, EN = 1
	sleep(1);
	*(shift_reg_p+0) = 0x1;		// DIR = 0, DIN = 0, EN = 1
	sleep(1);
	*(shift_reg_p+0) = 0x1;		// DIR = 0, DIN = 0, EN = 1
	sleep(1);
	*(shift_reg_p+0) = 0x3;		// DIR = 0, DIN = 1, EN = 1
	sleep(1);

	// Read shift register data
	printf("Data: 0x%X\n", (unsigned int)*(shift_reg_p+1));

	// *** Shift right 1100 ***
	*(shift_reg_p+0) = 0x5;		// DIR = 1, DIN = 0, EN = 1
	sleep(1);
	*(shift_reg_p+0) = 0x5;		// DIR = 1, DIN = 0, EN = 1
	sleep(1);
	*(shift_reg_p+0) = 0x7;		// DIR = 1, DIN = 1, EN = 1
	sleep(1);
	*(shift_reg_p+0) = 0x7;		// DIR = 1, DIN = 1, EN = 1
	sleep(1);

	// Read shift register data
	printf("Data: 0x%X\n", (unsigned int)*(shift_reg_p+1));

    return 0;
}
