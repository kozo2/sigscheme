/*===========================================================================
 *  FileName : operations-srfi1.c
 *  About    : srfi1 procedures
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

/*=======================================
  File Local Struct Declarations
=======================================*/

/*=======================================
  File Local Macro Declarations
=======================================*/

/*=======================================
  Variable Declarations
=======================================*/

/*=======================================
  File Local Function Declarations
=======================================*/
static ScmObj compare_list(ScmObj eqproc, ScmObj lst1, ScmObj lst2);

/*=======================================
  Function Implementations
=======================================*/
/*==============================================================================
  SRFI1 : The procedures : Constructors
==============================================================================*/
ScmObj ScmOp_SRFI1_xcons(ScmObj a, ScmObj b)
{
    return CONS(b, a);
}

ScmObj ScmOp_SRFI1_cons_star(ScmObj args)
{
    ScmObj tail_cons = SCM_NULL;
    ScmObj prev_last = args;

    if (NULLP(CDR(args)))
        return CAR(args);

    for (tail_cons = CDR(args); !NULLP(tail_cons); tail_cons = CDR(tail_cons)) {
        /* check tail cons cell */
        if (NULLP(CDR(tail_cons))) {
            SET_CDR(prev_last, CAR(tail_cons));
        }

        prev_last = tail_cons;
    }

    return args;
}

ScmObj ScmOp_SRFI1_make_list(ScmObj length, ScmObj args)
{
    ScmObj filler = SCM_FALSE;
    ScmObj head   = SCM_FALSE;
    int len = 0;
    int i   = 0;

    /* sanity check */
    if (FALSEP(ScmOp_numberp(length)))
        SigScm_ErrorObj("make-list : number required but got ", CAR(length));

    len = SCM_INT_VALUE(length);

    /* get filler if available */
    if (!NULLP(args))
        filler = CAR(args);
    else
        filler = SCM_FALSE;

    /* then create list */
    for (i = len; 0 < i; i--) {
        head = CONS(filler, head);
    }

    return head;
}

ScmObj ScmOp_SRFI1_list_tabulate(ScmObj scm_n, ScmObj args)
{
    ScmObj proc  = SCM_FALSE;
    ScmObj head  = SCM_NULL;
    ScmObj num   = SCM_FALSE;
    int n = 0;
    int i = 0;

    /* sanity check */
    if (FALSEP(ScmOp_numberp(scm_n)))
        SigScm_ErrorObj("list-tabulate : number required but got ", scm_n);

    /* get n */
    n = SCM_INT_VALUE(scm_n);

    /* get init_proc if available */
    if (!NULLP(args))
        proc = CAR(args);

    /* then create list */
    for (i = n; 0 < i; i--) {
        num = Scm_NewInt(i - 1);

        if (!NULLP(proc))
            num = Scm_call(proc, LIST_1(num));

        head = CONS(num, head);
    }

    return head;
}

ScmObj ScmOp_SRFI1_list_copy(ScmObj lst)
{
    ScmObj head = SCM_NULL;
    ScmObj tail = SCM_NULL;
    ScmObj obj  = SCM_NULL;

    if (FALSEP(ScmOp_listp(lst)))
        SigScm_ErrorObj("list-copy : list required but got ", lst);

    for (; !NULLP(lst); lst = CDR(lst)) {
        obj = CAR(lst);

        /* further copy */
        if (CONSP(obj))
            obj = ScmOp_SRFI1_list_copy(obj);

        /* then create new cons */
        obj = CONS(obj, SCM_NULL);
        if (!NULLP(tail)) {
            SET_CDR(tail, obj);
            tail = obj;
        } else {
            head = obj;
            tail = head;
        }
    }

    return head;
}

ScmObj ScmOp_SRFI1_circular_list(ScmObj args)
{
    ScmObj lastcons = SCM_NULL;

    if (FALSEP(ScmOp_listp(args)))
        SigScm_ErrorObj("circular-list : list required but got ", args);

    lastcons = ScmOp_SRFI1_last_pair(args);
    SET_CDR(lastcons, args);

    return args;
}

ScmObj ScmOp_SRFI1_iota(ScmObj scm_count, ScmObj args)
{
    ScmObj scm_start = SCM_NULL;
    ScmObj scm_step  = SCM_NULL;
    ScmObj head      = SCM_NULL;
    int count = 0;
    int start = 0;
    int step  = 0;
    int i = 0;

    /* get params */
    if (!NULLP(args))
        scm_start = CAR(args);

    if (!NULLP(scm_start) && !NULLP(CDR(args)))
        scm_step = CAR(CDR(args));

    /* param type check */
    if (FALSEP(ScmOp_numberp(scm_count)))
        SigScm_ErrorObj("iota : number required but got ", scm_count);

    if (!NULLP(scm_start) && FALSEP(ScmOp_numberp(scm_start)))
        SigScm_ErrorObj("iota : number required but got ", scm_start);

    if (!NULLP(scm_step)  && FALSEP(ScmOp_numberp(scm_step)))
        SigScm_ErrorObj("iota : number required but got ", scm_step);

    /* now create list */
    count = SCM_INT_VALUE(scm_count);
    start = NULLP(scm_start) ? 0 : SCM_INT_VALUE(scm_start);
    step  = NULLP(scm_step)  ? 1 : SCM_INT_VALUE(scm_step);
    for (i = count - 1; 0 <= i; i--) {
        head = CONS(Scm_NewInt(start + i*step), head);
    }

    return head;
}

/*==============================================================================
  SRFI1 : The procedures : Predicates
==============================================================================*/
ScmObj ScmOp_SRFI1_proper_listp(ScmObj lst)
{
    return ScmOp_listp(lst);
}

ScmObj ScmOp_SRFI1_circular_listp(ScmObj obj)
{
    ScmObj slow = obj;
    int len = 0;

    for (;;) {
        if (NULLP(obj)) break;
        if (!CONSP(obj)) return SCM_FALSE;
        if (len != 0 && obj == slow) return SCM_TRUE; /* circular */

        obj = CDR(obj);
        len++;
        if (NULLP(obj)) break;
        if (!CONSP(obj)) return SCM_FALSE;
        if (obj == slow) return SCM_TRUE; /* circular */

        obj = CDR(obj);
        slow = CDR(slow);
        len++;
    }

    return SCM_FALSE;
}

ScmObj ScmOp_SRFI1_dotted_listp(ScmObj obj)
{
    ScmObj slow = obj;
    int len = 0;

    for (;;) {
        if (NULLP(obj)) break;
        if (!CONSP(obj)) return SCM_TRUE;
        if (len != 0 && obj == slow) return SCM_FALSE; /* circular */

        obj = CDR(obj);
        len++;
        if (NULLP(obj)) break;
        if (!CONSP(obj)) return SCM_TRUE;
        if (obj == slow) return SCM_FALSE; /* circular */

        obj = CDR(obj);
        slow = CDR(slow);
        len++;
    }

    return SCM_FALSE;
}

ScmObj ScmOp_SRFI1_not_pairp(ScmObj pair)
{
    return CONSP(pair) ? SCM_FALSE : SCM_TRUE;
}

ScmObj ScmOp_SRFI1_null_listp(ScmObj lst)
{
    /* TODO : check circular list */
    return NULLP(lst) ? SCM_TRUE : SCM_FALSE;
}

ScmObj ScmOp_SRFI1_listequal(ScmObj eqproc, ScmObj args)
{
    ScmObj first_lst = SCM_FALSE;

    if (NULLP(args))
        return SCM_TRUE;

    first_lst = CAR(args);
    args = CDR(args);

    if (NULLP(args))
        return SCM_TRUE;

    for (; !NULLP(args); args = CDR(args)) {
        if (FALSEP(compare_list(eqproc, first_lst, CAR(args))))
            return SCM_FALSE;
    }

    return SCM_TRUE;
}

static ScmObj compare_list(ScmObj eqproc, ScmObj lst1, ScmObj lst2)
{
#define CHECK_LIST_EQUALITY_WITH_EQPROC(eqproc, obj1, obj2)             \
    (Scm_call(eqproc,                                                   \
              LIST_2(obj1, obj2)))

    ScmObj ret_cmp = SCM_FALSE;

    for (; !NULLP(lst1); lst1 = CDR(lst1), lst2 = CDR(lst2)) {
        /* check contents */
        ret_cmp = CHECK_LIST_EQUALITY_WITH_EQPROC(eqproc, CAR(lst1), CAR(lst2));
        if (FALSEP(ret_cmp))
            return SCM_FALSE;

        /* check next cdr's type */
        if (SCM_TYPE(CDR(lst1)) != SCM_TYPE(CDR(lst2)))
            return SCM_FALSE;

        /* check dot pair */
        if (!CONSP(CDR(lst1))) {
            return CHECK_LIST_EQUALITY_WITH_EQPROC(eqproc, CDR(lst1), CDR(lst2));
        }
    }
    return SCM_TRUE;
}

ScmObj ScmOp_SRFI1_first(ScmObj lst)
{
    return ScmOp_car(lst);
}

ScmObj ScmOp_SRFI1_second(ScmObj lst)
{
    return ScmOp_cadr(lst);
}

ScmObj ScmOp_SRFI1_third(ScmObj lst)
{
    return ScmOp_caddr(lst);
}

ScmObj ScmOp_SRFI1_fourth(ScmObj lst)
{
    return ScmOp_cadddr(lst);
}

ScmObj ScmOp_SRFI1_fifth(ScmObj lst)
{
    return ScmOp_car(ScmOp_cddddr(lst));
}

ScmObj ScmOp_SRFI1_sixth(ScmObj lst)
{
    return ScmOp_cadr(ScmOp_cddddr(lst));
}

ScmObj ScmOp_SRFI1_seventh(ScmObj lst)
{
    return ScmOp_caddr(ScmOp_cddddr(lst));
}

ScmObj ScmOp_SRFI1_eighth(ScmObj lst)
{
    return ScmOp_cadddr(ScmOp_cddddr(lst));
}

ScmObj ScmOp_SRFI1_ninth(ScmObj lst)
{
    return ScmOp_car(ScmOp_cddddr(ScmOp_cddddr(lst)));
}

ScmObj ScmOp_SRFI1_tenth(ScmObj lst)
{
    return ScmOp_cadr(ScmOp_cddddr(ScmOp_cddddr(lst)));
}

ScmObj ScmOp_SRFI1_carpluscdr(ScmObj lst)
{
    return ScmOp_values(LIST_2(CAR(lst), CDR(lst)));
}

ScmObj ScmOp_SRFI1_take(ScmObj lst, ScmObj scm_idx)
{
    ScmObj tmp = lst;
    ScmObj ret = SCM_NULL;
    ScmObj ret_tail = SCM_NULL;
    int idx = 0;
    int i;

    /* sanity check */
    if (!INTP(scm_idx))
        SigScm_ErrorObj("drop-right : number required but got ", scm_idx);

    idx = SCM_INT_VALUE(scm_idx);

    for (i = 0; i < idx; i++) {
        if (SCM_NULLP(tmp))
            SigScm_ErrorObj("take : illegal index is specified for ", lst);

        if (i != 0) {
            SET_CDR(ret_tail,  CONS(CAR(tmp), SCM_NULL));
            ret_tail = CDR(ret_tail);
        } else {
            ret = CONS(CAR(tmp), SCM_NULL);
            ret_tail = ret;
        }

        tmp = CDR(tmp);
    }

    return ret;
}

ScmObj ScmOp_SRFI1_drop(ScmObj lst, ScmObj scm_idx)
{
    ScmObj ret = lst;
    int idx = SCM_INT_VALUE(scm_idx);
    int i;

    /* sanity check */
    if (!INTP(scm_idx))
        SigScm_ErrorObj("drop-right : number required but got ", scm_idx);

    for (i = 0; i < idx; i++) {
        if (!CONSP(ret))
            SigScm_ErrorObj("drop : illegal index is specified for ", lst);

        ret = CDR(ret);
    }

    return ret;
}

ScmObj ScmOp_SRFI1_take_right(ScmObj lst, ScmObj scm_elem)
{
    ScmObj tmp = lst;
    int len = 0;

    /* sanity check */
    if (!INTP(scm_elem))
        SigScm_ErrorObj("drop-right : number required but got ", scm_elem);

    for (; CONSP(tmp); tmp = CDR(tmp))
        len++;

    len -= SCM_INT_VALUE(scm_elem);

    return ScmOp_SRFI1_drop(lst, Scm_NewInt(len));
}

ScmObj ScmOp_SRFI1_drop_right(ScmObj lst, ScmObj scm_elem)
{
    ScmObj tmp = lst;
    int len = 0;

    /* sanity check */
    if (!INTP(scm_elem))
        SigScm_ErrorObj("drop-right : number required but got ", scm_elem);

    for (; CONSP(tmp); tmp = CDR(tmp))
        len++;

    len -= SCM_INT_VALUE(scm_elem);

    return ScmOp_SRFI1_take(lst, Scm_NewInt(len));
}

ScmObj ScmOp_SRFI1_take_d(ScmObj lst, ScmObj scm_idx)
{
    ScmObj tmp = lst;
    int idx = 0;
    int i;

    /* sanity check */
    if (!INTP(scm_idx))
        SigScm_ErrorObj("take! : number required but got ", scm_idx);

    idx = SCM_INT_VALUE(scm_idx);

    for (i = 0; i < idx - 1; i++) {
        tmp = CDR(tmp);
    }

    SET_CDR(tmp, SCM_NULL);

    return lst;
}

ScmObj ScmOp_SRFI1_drop_right_d(ScmObj lst, ScmObj scm_idx)
{
    ScmObj tmp = lst;
    int len = 0;
    int i;

    /* sanity check */
    if (!INTP(scm_idx))
        SigScm_ErrorObj("drop-right! : number required but got ", scm_idx);

    for (; CONSP(tmp); tmp = CDR(tmp))
        len++;

    len -= SCM_INT_VALUE(scm_idx);

    tmp = lst;
    for (i = 0; i < len - 1; i++) {
        tmp = CDR(tmp);
    }

    SET_CDR(tmp, SCM_NULL);

    return lst;
}

ScmObj ScmOp_SRFI1_split_at(ScmObj lst, ScmObj idx)
{
    return ScmOp_values(LIST_2(ScmOp_SRFI1_take(lst, idx),
                               ScmOp_SRFI1_drop(lst, idx)));
}

ScmObj ScmOp_SRFI1_split_at_d(ScmObj lst, ScmObj idx)
{
    ScmObj drop = ScmOp_SRFI1_drop(lst, idx);

    return ScmOp_values(LIST_2(ScmOp_SRFI1_take_d(lst, idx),
                               drop));
}

ScmObj ScmOp_SRFI1_last(ScmObj lst)
{
    /* sanity check */
    if (NULLP(lst))
        SigScm_ErrorObj("last : non-empty, proper list is required but got ", lst);

    return CAR(ScmOp_SRFI1_last_pair(lst));
}

ScmObj ScmOp_SRFI1_last_pair(ScmObj lst)
{
    /* sanity check */
    if (NULLP(lst))
        SigScm_ErrorObj("last-pair : non-empty, proper list is required but got ", lst);

    for (; CONSP(CDR(lst)); lst = CDR(lst))
        ;

    return lst;
}

/*==============================================================================
  SRFI1 : The procedures : Miscellaneous
==============================================================================*/
ScmObj ScmOp_SRFI1_lengthplus(ScmObj lst)
{
    /* FIXME!: remove expensive circular_listp */
    if (NFALSEP(ScmOp_SRFI1_circular_listp(lst)))
        return SCM_FALSE;

    return ScmOp_length(lst);
}

ScmObj ScmOp_SRFI1_concatenate(ScmObj args)
{
    ScmObj lsts_of_lst = CAR(args);

#if SCM_STRICT_ARGCHECK
    if (!NULLP(CDR(args)))
        SigScm_ErrorObj("concatenate : superfluous arguments: ", args);
#endif

    return ScmOp_append(lsts_of_lst);
}
