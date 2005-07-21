/*===========================================================================
 *  FileName : main.c
 *  About    : main function
 *
 *  Copyright (C) 2005      by Kazuki Ohta (mover@hct.zaq.ne.jp)
 *
 *  All rights reserved.
 *
 *  Redistribution and use in source and binary forms, with or without
 *  modification, are permitted provided that the following conditions
 *  are met:
 *
 *  1. Redistributions of source code must retain the above copyright
 *     notice, this list of conditions and the following disclaimer.
 *  2. Redistributions in binary form must reproduce the above copyright
 *     notice, this list of conditions and the following disclaimer in the
 *     documentation and/or other materials provided with the distribution.
 *  3. Neither the name of authors nor the names of its contributors
 *     may be used to endorse or promote products derived from this software
 *     without specific prior written permission.
 *
 *  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS ``AS IS''
 *  AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 *  IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
 *  ARE DISCLAIMED.  IN NO EVENT SHALL THE COPYRIGHT HOLDERS OR CONTRIBUTORS BE
 *  LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
 *  CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE
 *  GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
 *  HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
 *  LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY
 *  OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF
 *  SUCH DAMAGE.
===========================================================================*/
/*=======================================
  System Include
=======================================*/

/*=======================================
  Local Include
=======================================*/
#include "sigscheme.h"

/*=======================================
  File Local Struct Declarations
=======================================*/

/*=======================================
  Variable Declarations
=======================================*/

/*=======================================
  File Local Function Declarations
=======================================*/

/* Very simple repl, please rewrite. */
static void repl(void)
{
    ScmObj stdin_port  = Scm_NewPort(stdin,  PORT_INPUT, PORT_FILE);
    ScmObj stdout_port = Scm_NewPort(stdout, PORT_INPUT, PORT_FILE);
    ScmObj s_exp, result;

    printf("sscm> ");

    for( s_exp = SigScm_Read(stdin_port);
	 !EQ(s_exp, SCM_EOF);
	 s_exp = SigScm_Read(stdin_port))
    {
	result = ScmOp_eval(s_exp, SCM_NIL);
	SigScm_DisplayToPort(stdout_port, result);
	printf("\nsscm> ");
    }
    
    ScmOp_close_input_port(stdin_port);
    ScmOp_close_input_port(stdout_port);
}

/*=======================================
  Function Implementations
=======================================*/
int main(int argc, char **argv)
{
    char *filename = argv[1];

    SigScm_Initialize();

    if (argc < 2) {
      repl();
      /*	SigScm_Error("usage : sscm <filename>\n"); */
    } else {
      SigScm_load(filename);
    }

    SigScm_Finalize();
    return 0;
}

