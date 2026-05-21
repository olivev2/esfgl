SESSION:DATE-FORMAT = "dmy".
/*******************************************************************************
**
**  Include: CEAPI020.I - Somas dos Valores do Movimento de Estoque
**
**  {1} - Indica FASB ou CMI
**  {2} - -m        - mensal
**        -p        - padrao
**        -o        - on-line
**  {3} - vl-cont-fasb     - Valor referente … moeda FASB ou CMI
**        valor-cont       - Valor na moeda corrente
**  {4} - i-mo-fasb - Moeda Alternativa correspondente ao FASB
**        i-mo-cmi  - Moeda Alternativa correspondente ao CMI
**
*******************************************************************************/
if  "{3}" = "valor-cont" THEN DO:
    assign c-transacao[1]                  =  movto-estoq.tipo-trans
           tt-movto-ctbl-ce-new.valor-cont =  tt-movto-ctbl-ce-new.valor-cont    
                                           -((movto-estoq.valor-mat{2}[{4}]
                                           +  movto-estoq.valor-mob{2}[{4}]
                                           +  movto-estoq.valor-ggf{2}[{4}]
                                           +  movto-estoq.valor-icm
                                           +  movto-estoq.valor-ipi
                                           +  movto-estoq.valor-pis
                                           +  movto-estoq.val-cofins)
                                           *  if movto-estoq.tipo-trans = 1 then 1 else -1).

END.
else do:
    assign c-transacao[1]       = movto-estoq.tipo-trans.
           
    if "{1}" = "1" then /* FASB */
    assign  tt-movto-ctbl-ce-new.vl-cont-fasb[{1}] =  tt-movto-ctbl-ce-new.vl-cont-fasb[{1}] 
                                                   -((movto-estoq.valor-mat{2}[{4}]
                                                   +  movto-estoq.valor-mob{2}[{4}]
                                                   +  movto-estoq.valor-ggf{2}[{4}]
                                                   +  movto-estoq.vl-icm-fasb[{1}]
                                                   +  movto-estoq.vl-ipi-fasb[{1}]
                                                   +  movto-estoq.vl-pis-fasb
                                                   +  movto-estoq.val-cofins-fasb)
                                                   *  if movto-estoq.tipo-trans = 1 then 1 else -1).
    else /* CMI */
    assign tt-movto-ctbl-ce-new.vl-cont-fasb[{1}] =  tt-movto-ctbl-ce-new.vl-cont-fasb[{1}]
                                                  -((movto-estoq.valor-mat{2}[{4}]
                                                  +  movto-estoq.valor-mob{2}[{4}]
                                                  +  movto-estoq.valor-ggf{2}[{4}]
                                                  +  movto-estoq.vl-icm-fasb[{1}]
                                                  +  movto-estoq.vl-ipi-fasb[{1}]
                                                  +  movto-estoq.vl-pis-cmi
                                                  +  movto-estoq.val-cofins-cmi)
                                                  *  if movto-estoq.tipo-trans = 1 then 1 else -1).
           
                                                                                             
end.
/* Fim Include */



