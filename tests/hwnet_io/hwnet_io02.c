// SPDX-License-Identifier: GPL-2.0-or-later
/*
 * hwnet_io02.c - Suite de pruebas de validación para hwnet_io
 *
 * Copyright (C) 2026 Raúl Vílchez Ruiz <raulmicrosistemas@gmail.com>
 */
#include <tst_test.h>

void setup(void)
{
  // your setup code goes here

  tst_res(TINFO, "example setup");
}

void cleanup(void)
{
  // your cleanup code goes here

  tst_res(TINFO, "example cleanup");
}

void run(void)
{
  // your test code goes here

  tst_res(TPASS, "Doing hardly anything is easy");
}

static struct tst_test test = {
    .test_all = run,
    .setup = setup,
    .cleanup = cleanup,
};