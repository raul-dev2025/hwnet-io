#include <stdio.h>
#include <unistd.h>
#include <errno.h>
#include "tst_test.h"

struct sysconf_entry {
	int name;
	const char *desc;
};

static struct sysconf_entry config_list[] = {
	{_SC_PAGESIZE, "Page size (bytes)"},
	{_SC_NPROCESSORS_ONLN, "Processors online"},
	{_SC_OPEN_MAX, "Maximum open files per process"},
	{_SC_CLK_TCK, "Clock ticks per second (CLK_TCK)"},
	{_SC_PHYS_PAGES, "Total physical memory pages"},
	{_SC_AVPHYS_PAGES, "Available physical memory pages"}
};

static void run(void)
{
	size_t i;
	int errors = 0;
	long val;

	tst_res(TINFO, "Querying system parameters via sysconf()...");

	for (i = 0; i < ARRAY_SIZE(config_list); i++) {
		errno = 0;
		val = sysconf(config_list[i].name);

		if (val == -1) {
			if (errno != 0) {
				tst_res(TFAIL | TERRNO, "sysconf(%s) failed", config_list[i].desc);
				errors++;
			} else {
				tst_res(TINFO, "%s: Indeterminate / No fixed limit", config_list[i].desc);
			}
		} else {
			if (val > 0) {
				tst_res(TINFO, "%s: %ld", config_list[i].desc, val);
			} else {
				tst_res(TFAIL, "%s reported invalid value: %ld", config_list[i].desc, val);
				errors++;
			}
		}
	}

	if (errors == 0) {
		tst_res(TPASS, "All sysconf() queries succeeded with valid values");
	} else {
		tst_res(TFAIL, "Detected %d errors querying parameters via sysconf()", errors);
	}
}

static struct tst_test test = {
	.test_all = run,
};