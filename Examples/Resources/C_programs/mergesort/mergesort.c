#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <stdbool.h>

#include "riscv_counters.h"

#define min(x,y)  (((x) < (y)) ? (x) : (y))

// ================================================================
// merge_engine()
// Merge p1[i0 .. i0+span-1] and p1[i0+span .. i0+2*span-1]
// into  p2[i0 .. i0+2*span]

void merge_engine (uint64_t *p1, uint64_t *p2, uint64_t i0, uint64_t span, uint64_t n)
{
    uint64_t i1 = i0 + span;
    uint64_t i0_lim = min (i1, n);
    uint64_t i1_lim = min (i1 + span, n);
    uint64_t j = i0;
    while (true) {
	if ((i0 < i0_lim) && (i1 < i1_lim))
	    if (p1 [i0] < p1 [i1])
		p2 [j++] = p1 [i0++];
	    else
		p2 [j++] = p1 [i1++];
	else if (i0 < i0_lim)
	    p2 [j++] = p1 [i0++];
	else if (i1 < i1_lim)
	    p2 [j++] = p1 [i1++];
	else
	    break;
    }
}

// ================================================================
// mergesort()
// Repeatedly merge longer and longer spans (length 1, 2, 4, 8, ...)
// back and forth between pA and pB until span length > n.
// If final array is in pB, copy it back to pA.

void mergesort (uint64_t *pA, uint64_t *pB, uint64_t n)
{
    uint64_t span = 1;
    uint64_t *p1 = pA;
    uint64_t *p2 = pB;

    while (span < n) {
	for (uint64_t i0 = 0; i0 < n; i0 += 2 * span) {
	    merge_engine (p1, p2, i0, span, n);
	}
	uint64_t *tmp = p1;
	p1 = p2;
	p2 = tmp;
	span = span * 2;
    }
    // If final result is in pB; copy it back to pA
    if (p1 == pB)
	merge_engine (p1, p2, 0, n, n);
}

// ================================================================
// Since the accelerator IP block reads/writes directly to memory we
// use 'fence' to ensure that caches are empty, i.e., memory contains
// definitive data and caches will be reloaded.

static void fence (void)
{
    asm volatile ("fence");
}

// ================================================================

uint64_t *accel_0_addr_base = (uint64_t *) 0xC0002000l;

void mergesort_accelerated (uint64_t *pA, uint64_t *pB, uint64_t n)
{
    fence ();

    // Write configs into accelerator
    accel_0_addr_base [1] = (uint64_t)  pA;
    accel_0_addr_base [2] = (uint64_t)  pB;
    accel_0_addr_base [3] = (uint64_t)  n;
    // "Go!"
    accel_0_addr_base [0] = (uint64_t)  1;

    // Wait for completion
    while (true) {
	uint64_t status = accel_0_addr_base [0];
	if (status == 0) break;
    }

    fence ();
}

// ================================================================

void dump_array (uint64_t *p, uint64_t n, char *title)
{
    fprintf (stdout, "%s\n", title);
    for (uint64_t j = 0; j < n; j++)
	fprintf (stdout, "%0d: %0d\n", j, p [j]);
}

void run (bool accelerated, uint64_t *pA, uint64_t *pB, uint64_t n)
{
    // Load array in descending order, to be sorted
    for (uint64_t j = 0; j < n; j++)
	pA [j] = n - 1 - j;

    if (n < 32)
	dump_array (pA, n, "Unsorted array");

    uint64_t c0 = read_cycle();

    if (! accelerated)
	mergesort (pA, pB, n);
    else
	mergesort_accelerated (pA, pB, n);

    uint64_t c1 = read_cycle();

    if (n < 32)
	dump_array (pA, n, "Sorted array");

    // Verify that it's sorted
    bool sorted = true;
    for (uint64_t j = 0; j < (n-1); j++)
	if (pA [j] > pA [j+1]) {
	    fprintf (stdout, "ERROR: adjacent elements not in sorted order\n", j, j+1);
	    fprintf (stdout, "    A [%0d] = %0d", j,   pA [j]);
	    fprintf (stdout, "    A [%0d] = %0d\n", j+1, pA [j+1]);
	    sorted = false;
	}
    if (sorted)
	fprintf (stdout, "Verified %0d words sorted\n", n);

    fprintf (stdout, "    Sorting took %8d cycles\n", c1 - c0);
}

// ================================================================

uint64_t A [4096], B [4096];
// uint64_t n = 29;
uint64_t n = 3000;

int main (int argc, char *argv[])
{
    bool accelerated = true;

    fprintf (stdout, "Running C function for mergesort\n");
    run (! accelerated, A, B, n);
    fprintf (stdout, "Done\n");

    fprintf (stdout, "Running hardware-accelerated mergesort\n");
    run (accelerated, A, B, n);
    fprintf (stdout, "Done\n");
    TEST_PASS
}
