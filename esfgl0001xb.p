SESSION:DATE-FORMAT = "dmy".
/********************************************************************************
** Copyright DATASUL S.A. (1997)
** Todos os Direitos Reservados.
**
** Este fonte e de propriedade exclusiva da DATASUL, sua reproducao
** parcial ou total por qualquer meio, so podera ser feita mediante
** autorizacao expressa.
*******************************************************************************/
{include/i-prgvrs.i ESFGL0001XB 2.00.00.000}  /*** 010000 ***/

/* &IF "{&EMSFND_VERSION}" >= "1.00" &THEN       */
/* {include/i-license-manager.i ESFGL0001B MFT}  */
/* &ENDIF                                        */

/**********************************************************************************/
/** Programa: ftapi068.p                                                         **/             
/** Objetivo: Consultar o ID do movimento cont bil da tabela SUMAR-FT            **/
/**********************************************************************************/
{esp/esfgl0001xb.i tt-movto-ctbl} 
{cdp/cdcfgdis.i}
{utp/ut-glob.i}

define input  parameter i-num-id-movto-ctbl as integer no-undo.
define output parameter table for tt-movto-ctbl.

DEFINE VARIABLE     i-empresa   LIKE param-global.empresa-prin     NO-UNDO.

DEFINE TEMP-TABLE   tt-sumar-ft LIKE sumar-ft
       FIELD pos-valor AS DECIMAL.
DEFINE BUFFER       bf-sumar-ft FOR sumar-ft.

for first param-global no-lock:
    assign i-empresa = param-global.empresa-prin.
end.

EMPTY TEMP-TABLE tt-sumar-ft.
for each sumar-ft no-lock
    where &IF "{&bf_dis_versao_ems}" >= "2.08" &THEN                                                  
              sumar-ft.num-id-movto-ctbl   = i-num-id-movto-ctbl 
          &ELSE                                                                                       
              sumar-ft.int-1               = i-num-id-movto-ctbl 
          &ENDIF:
          
/*     each nota-fiscal no-lock                                */
/*     where nota-fiscal.cod-estabel = sumar-ft.cod-estabel    */
/*     and   nota-fiscal.serie       = sumar-ft.serie          */
/*     and   nota-fiscal.nr-nota-fis = sumar-ft.nr-nota-fis :  */
          
    FOR EACH bf-sumar-ft NO-LOCK USE-INDEX ch-nota WHERE
             bf-sumar-ft.cod-estabel = sumar-ft.cod-estabel AND
             bf-sumar-ft.serie       = sumar-ft.serie       AND
             bf-sumar-ft.nr-nota-fis = sumar-ft.nr-nota-fis AND
             bf-sumar-ft.tp-imposto  = sumar-ft.tp-imposto  AND
             bf-sumar-ft.vl-contab   < 0 .

        FIND tt-sumar-ft WHERE
             tt-sumar-ft.cod-estabel        = sumar-ft.cod-estabel      AND
             tt-sumar-ft.dt-movto           = sumar-ft.dt-movto         AND
             tt-sumar-ft.ct-conta           = sumar-ft.ct-conta         AND
             tt-sumar-ft.sc-conta           = sumar-ft.sc-conta         AND
             tt-sumar-ft.serie              = sumar-ft.serie            AND
             tt-sumar-ft.nr-nota-fis        = sumar-ft.nr-nota-fis      AND
             tt-sumar-ft.tp-imposto         = sumar-ft.tp-imposto       AND
             tt-sumar-ft.cod-unid-negoc     = sumar-ft.cod-unid-negoc   AND
             tt-sumar-ft.idi-modul-orig     = sumar-ft.idi-modul-orig   NO-ERROR.
        IF NOT AVAIL tt-sumar-ft THEN DO:
            CREATE tt-sumar-ft.
            BUFFER-COPY bf-sumar-ft TO tt-sumar-ft.

            IF tt-sumar-ft.vl-contab > 0 THEN
               ASSIGN tt-sumar-ft.pos-valor = tt-sumar-ft.vl-contab.
            ELSE
               ASSIGN tt-sumar-ft.pos-valor = (tt-sumar-ft.vl-contab * -1).
        END.
    END.

END.

for each sumar-ft no-lock
    where &IF "{&bf_dis_versao_ems}" >= "2.08" &THEN                                                  
              sumar-ft.num-id-movto-ctbl   = i-num-id-movto-ctbl 
          &ELSE                                                                                       
              sumar-ft.int-1               = i-num-id-movto-ctbl 
          &ENDIF,
    each nota-fiscal NO-LOCK USE-INDEX ch-nota
    where nota-fiscal.cod-estabel = sumar-ft.cod-estabel
    and   nota-fiscal.serie       = sumar-ft.serie
    and   nota-fiscal.nr-nota-fis = sumar-ft.nr-nota-fis :

    create tt-movto-ctbl.
    assign tt-movto-ctbl.ep-codigo              = i-empresa

           tt-movto-ctbl.nro-docto              = sumar-ft.nr-nota-fis
           tt-movto-ctbl.cod-emitente           = nota-fiscal.cod-emitente
           tt-movto-ctbl.serie-docto            = sumar-ft.serie
           tt-movto-ctbl.nat-operacao           = nota-fiscal.nat-operacao
           
           &IF "{&bf_dis_versao_ems}" >= "2.08" &THEN                                                  
              tt-movto-ctbl.num-id-movto-ctbl   = sumar-ft.num-id-movto-ctbl
              tt-movto-ctbl.sequencia           = sumar-ft.sequencia
           &ELSE                                                                                       
              tt-movto-ctbl.num-id-movto-ctbl   = sumar-ft.int-1
              tt-movto-ctbl.sequencia           = sumar-ft.int-2
           &ENDIF
           
           tt-movto-ctbl.cod-estabel            = sumar-ft.cod-estabel
           tt-movto-ctbl.referencia             = sumar-ft.refer-ct
           tt-movto-ctbl.conta-contabil         = sumar-ft.ct-conta
           tt-movto-ctbl.dt-trans               = sumar-ft.dt-movto
           tt-movto-ctbl.esp-docto              = nota-fiscal.esp-docto
           tt-movto-ctbl.valor-cont             = sumar-ft.vl-contab
           tt-movto-ctbl.vl-cont-fasb           = sumar-ft.valor-fasb
           tt-movto-ctbl.char-1                 = sumar-ft.char-1
           tt-movto-ctbl.char-2                 = sumar-ft.char-2
           tt-movto-ctbl.dec-1                  = sumar-ft.dec-1
           tt-movto-ctbl.dec-2                  = sumar-ft.dec-2
           tt-movto-ctbl.int-1                  = sumar-ft.tp-imposto //sumar-ft.int-1
           tt-movto-ctbl.int-2                  = sumar-ft.int-2
           tt-movto-ctbl.log-1                  = sumar-ft.log-1
           tt-movto-ctbl.log-2                  = sumar-ft.log-2
           tt-movto-ctbl.data-1                 = sumar-ft.data-1
           tt-movto-ctbl.data-2                 = sumar-ft.data-2
           tt-movto-ctbl.check-sum              = sumar-ft.check-sum
           &IF "{&bf_dis_versao_ems}" >= "2.062" &THEN
               tt-movto-ctbl.cod-unid-negoc         = sumar-ft.cod-unid-negoc 
           &ENDIF .
           
            IF sumar-ft.vl-contab < 0 THEN
            FIND FIRST tt-sumar-ft WHERE
                       tt-sumar-ft.cod-estabel = sumar-ft.cod-estabel           AND
                       tt-sumar-ft.serie       = sumar-ft.serie                 AND
                       tt-sumar-ft.nr-nota-fis = sumar-ft.nr-nota-fis           AND
                       tt-sumar-ft.tp-imposto  = sumar-ft.tp-imposto            NO-ERROR.
/*                        tt-sumar-ft.vl-contab   = (sumar-ft.vl-contab * -1)      NO-ERROR.  */
                       IF AVAIL tt-sumar-ft THEN
                          ASSIGN tt-movto-ctbl.cod_cta_ctbl_contra      = tt-sumar-ft.ct-conta      
                                 tt-movto-ctbl.val_lancto_ctbl_contra   = (sumar-ft.vl-contab * -1). 
end.


return "OK":U.
