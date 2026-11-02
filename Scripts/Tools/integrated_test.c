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

void run_tests(void)
{
  // your test code goes here

  tst_res(TPASS, "Doing hardly anything is easy");
}

static struct tst_test test = {
    .setup = setup,
    .cleanup = cleanup,
    .test_all = run_tests,

    /* Requisitos de entorno y controladores seleccionados */
    .min_kver = "5.10",
    .supported_archs = (const char *const[]){
        "x86_64",
        NULL},
    .min_cpus = 1,
    .needs_drivers = (const char *const[]){"hwnet_io", NULL},

    /* Seguridad y robustez de memoria */
    .taint_check = TST_TAINT_W | TST_TAINT_O,

    /* Opciones personalizadas */
    .options = (struct tst_option[]){{"v", &verbose, "Modo de depuración verboso"}, {}},
};