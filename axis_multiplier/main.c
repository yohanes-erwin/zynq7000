// Author: Erwin Ouyang
// Date  : 15 Dec 2018

#include <stdio.h>
#include <stdint.h>

uint32_t *mult_mm2s_p;
uint32_t *mult_s2mm_p;

int main()
{
	// *** Pointer to AXI MM2S and S2MM ***
	mult_mm2s_p = (uint32_t *)0x40000000;
	mult_s2mm_p = (uint32_t *)0x41000000;

	// *** Multiply 1 word ***
	*(mult_mm2s_p+0) = 0x905;	// EN = 1, WORD = 1, CONST = 5
	*(mult_mm2s_p+1) = 0x1;		// DATA0 = 1
	while (!(*(mult_s2mm_p+0) & (1 << 0)));		// Wait until ready flag is set
	printf("Result: %d\n", (unsigned int)*(mult_s2mm_p+3));
	*(mult_s2mm_p+0) = 0x1;		// Clear ready flag

	// *** Multiply 4 words ***
	*(mult_mm2s_p+0) = 0xC08;	// EN = 1, WORD = 4, CONST = 8
	*(mult_mm2s_p+1) = 0x1;		// DATA0 = 1
	*(mult_mm2s_p+2) = 0x2;		// DATA1 = 2
	*(mult_mm2s_p+3) = 0x3;		// DATA2 = 3
	*(mult_mm2s_p+4) = 0x4;		// DATA3 = 4
	while (!(*(mult_s2mm_p+0) & (1 << 0)));		// Wait until ready flag is set
	printf("Result: %d, %d, %d, %d\n",
			(unsigned int)*(mult_s2mm_p+3),
			(unsigned int)*(mult_s2mm_p+4),
			(unsigned int)*(mult_s2mm_p+5),
			(unsigned int)*(mult_s2mm_p+6));
	*(mult_s2mm_p+0) = 0x1;		// Clear ready flag

	// *** Read status ***
	printf("Number of multiplied words : %d\n", (unsigned int)*(mult_s2mm_p+1));
	printf("Number of multiplied frames : %d\n", (unsigned int)*(mult_s2mm_p+2));

    return 0;
}
