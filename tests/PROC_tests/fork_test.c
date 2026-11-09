/*
 * fork_test.c
 * 
 * Test de creacion de procesos (fork), aislamiento de memoria (COW)
 * y recoleccion de estado mediante waitpid().
 * Parte de la Fase 3 del proyecto foundry.
 */

#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <sys/types.h>
#include <sys/wait.h>
#include <errno.h>
#include "tst_test.h"

#define EXPECTED_EXIT_CODE 42
#define INITIAL_VAL 100
#define MODIFIED_VAL 200

static int shared_var = INITIAL_VAL;

static void run(void)
{
	pid_t pid;
	int status;

	tst_res(TINFO, "Iniciando prueba de fork() con aislamiento de memoria...");

	pid = fork();

	if (pid < 0) {
		tst_brk(TBROK | TERRNO, "fork() fallo inesperadamente");
		return;
	}

	if (pid == 0) {
		/* --- Proceso Hijo --- */
		tst_res(TINFO, "Proceso hijo en ejecucion (PID: %d, PPID: %d)", getpid(), getppid());

		/* Modificacion de variable local para validar Copy-On-Write (COW) */
		shared_var = MODIFIED_VAL;

		tst_res(TINFO, "Proceso hijo modifico shared_var a %d", shared_var);

		/* Finalizar el hijo enviando un código de salida predecible */
		exit(EXPECTED_EXIT_CODE);
	}

	/* --- Proceso Padre --- */
	tst_res(TINFO, "Proceso padre esperando al hijo (PID: %d)...", pid);

	if (waitpid(pid, &status, 0) == -1) {
		tst_brk(TBROK | TERRNO, "waitpid() fallo al esperar al proceso hijo");
		return;
	}

	/* 1. Verificación del estado de salida del hijo */
	if (WIFEXITED(status)) {
		int exit_code = WEXITSTATUS(status);
		if (exit_code == EXPECTED_EXIT_CODE) {
			tst_res(TINFO, "Proceso hijo finalizo correctamente con codigo de salida %d", exit_code);
		} else {
			tst_res(TFAIL, "Proceso hijo retornó el codigo %d, se esperaba %d", exit_code, EXPECTED_EXIT_CODE);
			return;
		}
	} else {
		tst_res(TFAIL, "El proceso hijo no finalizo de manera normal");
		return;
	}

	/* 2. Verificación del aislamiento Copy-On-Write */
	if (shared_var == INITIAL_VAL) {
		tst_res(TPASS, "Memoria aislada correctamente (COW): shared_var permanece en %d en el proceso padre", shared_var);
	} else {
		tst_res(TFAIL, "Fallo en el aislamiento de memoria: shared_var fue alterada a %d en el proceso padre", shared_var);
	}
}

static struct tst_test test = {
	.test_all = run,
	.forks_child = 1,
};