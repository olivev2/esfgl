SESSION:DATE-FORMAT = "dmy".
{include/i-prgvrs.i ESFGL0001xA 2.00.00.009 } /*** 010009 ***/

{cdp/cdcfgmat.i}

DEF TEMP-TABLE tt-movto-ctbl-ce NO-UNDO
    &IF '{&bf_mat_versao_ems}' >= '2.071' &THEN
        FIELD ep-codigo             AS CHAR
    &ELSE
        FIELD ep-codigo             AS INTEGER
    &ENDIF
    FIELD num-seq-movto-ctbl-ce AS INTEGER
    FIELD num-id-movto-ctbl-ce  AS INTEGER
    FIELD cod-estabel           AS CHARACTER
    FIELD referencia            AS CHARACTER
    FIELD sequencia             AS INTEGER
    FIELD ge-codigo             AS INTEGER
    field conta-contabil        as char         format "x(17)"
    FIELD dt-trans              AS DATE         FORMAT "99/99/9999" 
    FIELD cod-depos             AS CHARACTER
    FIELD esp-docto             AS INTEGER
	FIELD nr-trans				AS INT
    FIELD transacao             AS INTEGER
    FIELD historico             AS CHARACTER
    FIELD valor-cont            AS DECIMAL
    FIELD vl-cont-fasb          AS DECIMAL EXTENT 2
    FIELD char-1                AS CHARACTER
    FIELD char-2                AS CHARACTER
    FIELD dec-1                 AS DECIMAL
    FIELD dec-2                 AS DECIMAL
    FIELD int-1                 AS INTEGER
    FIELD int-2                 AS INTEGER
    FIELD log-1                 AS LOGICAL
    FIELD log-2                 AS LOGICAL
    FIELD data-1                AS DATE FORMAT "99/99/9999"
    FIELD data-2                AS DATE FORMAT "99/99/9999"
    FIELD check-sum             AS CHARACTER
    FIELD cod-unid-negoc        AS CHARACTER FORMAT "x(3)"
    FIELD it-codigo             AS CHARACTER FORMAT "x(16)"
    FIELD nro-docto             AS CHARACTER FORMAT "x(16)"
    FIELD cod-emitente          AS INTEGER   FORMAT ">>>>>>>>9"
    FIELD serie-docto           AS CHARACTER FORMAT "x(5)"
    FIELD nat-operacao          AS CHARACTER FORMAT "x(06)"
    FIELD desc-item             AS CHARACTER FORMAT "x(60)"
    FIELD narrativa             AS CHARACTER FORMAT "x(2000)"
    FIELD unidade               AS CHARACTER
    FIELD qtde                  AS DECIMAL
    FIELD numero-ordem          AS INTEGER
    FIELD num-pedido            AS INTEGER
    FIELD mo-codigo             AS INTEGER

    field ttv_val_lancto_ctbl_contra       as decimal format ">>>>>,>>>,>>9.99" decimals 2 initial 0 label "Movto Contra" column-label "Movto Contra"
    FIELD tta_cod_cta_ctbl_contra          as CHARACTER    format "x(20)"

    INDEX num-id                IS PRIMARY
          num-id-movto-ctbl-ce  ASCENDING.
		  
/* evolucao */
DEF TEMP-TABLE tt-movto-ctbl-ce-new NO-UNDO
&IF '{&bf_mat_versao_ems}' >= '2.071' &THEN
	FIELD ep-codigo             AS CHAR
&ELSE
	FIELD ep-codigo             AS INTEGER
&ENDIF
	FIELD num-seq-movto-ctbl-ce AS INTEGER
	FIELD num-id-movto-ctbl-ce  AS INTEGER
	FIELD cod-estabel           AS CHARACTER
	FIELD referencia            AS CHARACTER
	FIELD sequencia             AS INTEGER
	FIELD ge-codigo             AS INTEGER
	FIELD conta-contabil        AS CHARACTER FORMAT "x(17)"
	FIELD dt-trans              AS DATE FORMAT "99/99/9999"
	FIELD cod-depos             AS CHARACTER
	FIELD esp-docto             AS INTEGER
	FIELD nr-trans				AS INT
	FIELD transacao             AS INTEGER
	FIELD historico             AS CHARACTER
	FIELD valor-cont            AS DECIMAL
	FIELD vl-cont-fasb          AS DECIMAL EXTENT 2
	FIELD char-1                AS CHARACTER
	FIELD char-2                AS CHARACTER
	FIELD dec-1                 AS DECIMAL
	FIELD dec-2                 AS DECIMAL
	FIELD int-1                 AS INTEGER
	FIELD int-2                 AS INTEGER
	FIELD log-1                 AS LOGICAL
	FIELD log-2                 AS LOGICAL
	FIELD data-1                AS DATE FORMAT "99/99/9999"
	FIELD data-2                AS DATE FORMAT "99/99/9999"
	FIELD check-sum             AS CHARACTER
	FIELD cod-unid-negoc        AS CHARACTER FORMAT "x(3)"
	FIELD it-codigo             AS CHARACTER FORMAT "x(16)"
	FIELD nro-docto             AS CHARACTER FORMAT "x(16)"
	FIELD cod-emitente          AS INTEGER   FORMAT ">>>>>>>>9"
	FIELD serie-docto           AS CHARACTER FORMAT "x(5)"
	FIELD nat-operacao          AS CHARACTER FORMAT "x(06)"
	FIELD desc-item             AS CHARACTER FORMAT "x(60)"
	FIELD narrativa             AS CHARACTER FORMAT "x(2000)"
	FIELD unidade               AS CHARACTER
	FIELD qtde                  AS DECIMAL 
	FIELD numero-ordem          AS INTEGER 
	FIELD num-pedido            AS INTEGER
	FIELD mo-codigo             AS INTEGER
	FIELD cod-cta               AS CHAR FORMAT "X(20)"
	FIELD cod-ccusto            AS CHAR FORMAT "X(20)"
    field ttv_val_lancto_ctbl_contra       as decimal format ">>>>>,>>>,>>9.99" decimals 2 initial 0 label "Movto Contra" column-label "Movto Contra"
    FIELD tta_cod_cta_ctbl_contra          as CHARACTER    format "x(20)"

	INDEX num-id                IS PRIMARY
		  num-id-movto-ctbl-ce  ASCENDING.

def shared temp-table tt_aprop_lancto_ctbl_aux2 no-undo
    field tta_ind_natur_lancto_ctbl        as character format "X(02)" initial "DB" label "Natureza" column-label "Natureza"
    field tta_cod_plano_cta_ctbl           as character format "x(8)" label "Plano Contas" column-label "Plano Contas"
    field tta_cod_cta_ctbl                 as character format "x(20)" label "Conta Cont bil" column-label "Conta Cont bil"
    field tta_des_tit_ctbl                 as character format "x(40)" label "T¡tulo Cont bil" column-label "T¡tulo Cont bil"
    field tta_cod_plano_ccusto             as character format "x(8)" label "Plano Centros Custo" column-label "Plano Centros Custo"
    field tta_cod_ccusto                   as Character format "x(11)" label "Centro Custo" column-label "Centro Custo"
    field tta_cod_unid_negoc               as character format "x(3)" label "Unid Neg¢cio" column-label "Un Neg"
    field tta_val_aprop                    as decimal   format "->>,>>>,>>>,>>9.99" decimals 2 initial 0 label "Apropriado" column-label "Apropriado"
    field ttv_des_chave_lancto             as character format "x(200)"
    index tt_id                            is primary
          ttv_des_chave_lancto             ascending.

DEF INPUT   PARAM           p-num-id-movto-ctbl-ce  AS INTEGER NO-UNDO.
def input   param           v_des_modul_select      as character format "x(40)":U no-undo.
DEF OUTPUT  PARAM TABLE FOR tt-movto-ctbl-ce-new.

/* RASTREABILIDADE */
DEF VAR de-valor-cont     LIKE contab-est.valor-cont   	  EXTENT 8 NO-UNDO.
DEF VAR c-transacao       LIKE movto-ctbl-ce.transacao    EXTENT 8 NO-UNDO.
DEF VAR de-valor-fasb     LIKE contab-est.valor-cont      EXTENT 8 NO-UNDO.
DEF VAR de-valor-cmi      LIKE contab-est.valor-cont      EXTENT 8 NO-UNDO.
DEF VAR l-fasb            AS LOGICAL                               NO-UNDO.
DEF VAR l-cmi             AS LOGICAL                               NO-UNDO.
DEF VAR i-mo-fasb         AS INTEGER                               NO-UNDO.
DEF VAR i-mo-cmi          AS INTEGER                               NO-UNDO.
DEF VAR l-movto-estoq     AS LOGICAL                               NO-UNDO.

def var l-ifrs-contab-estoq as log NO-UNDO.
DEF VAR l-moed-ifrs-2       AS LOG NO-UNDO.
DEF VAR l-moed-ifrs-1       AS LOG NO-UNDO.

def var v-log-verif-ct-sdo as log no-undo.

def var i-seq-destino as integer no-undo.
def var v-log-file as char no-undo initial "c:\temp\xa_seq_trace.log".

def var h-acomp as handle no-undo.

for each tt_aprop_lancto_ctbl_aux2:
    delete tt_aprop_lancto_ctbl_aux2.
end.

define buffer bf-ordem-compra for ordem-compra.
def buffer b_movto-ctbl-ce for movto-ctbl-ce.
define buffer bf-movto-estoq for movto-estoq.
define buffer bf-item for item.

FIND FIRST param-global NO-LOCK NO-ERROR.
FIND FIRST param-estoq  NO-LOCK NO-ERROR.

run utp/ut-acomp.p persistent set h-acomp.
run pi-inicializar in h-acomp (input "EsFgl0001Xa").

IF NOT l-ifrs-contab-estoq THEN DO:
    ASSIGN l-movto-estoq = NO.
    FOR EACH movto-ctbl-ce USE-INDEX num-id  NO-LOCK
        WHERE movto-ctbl-ce.num-id-movto-ctbl-ce = p-num-id-movto-ctbl-ce:
        RUN pi-gerar.
    END.
    /** Se nÆo encontra movimento de estoque, cria a tt-movto-ctbl-ce-new conforme era
    realizado no programa ceapi010.p **/
    IF NOT l-movto-estoq THEN DO:
        FOR EACH movto-ctbl-ce USE-INDEX num-id  NO-LOCK
            WHERE movto-ctbl-ce.num-id-movto-ctbl-ce = p-num-id-movto-ctbl-ce:
            CREATE tt-movto-ctbl-ce-new.
            BUFFER-COPY movto-ctbl-ce TO tt-movto-ctbl-ce-new.

            IF tt-movto-ctbl-ce-new.tta_cod_cta_ctbl_contra = "" THEN
            FIND first contabiliza USE-INDEX estabelec
                        where contabiliza.cod-estabel = movto-ctbl-ce.cod-estabel
                          and contabiliza.cod-depos   = movto-ctbl-ce.cod-depos
                          and contabiliza.ge-codigo   = movto-ctbl-ce.ge-codigo NO-ERROR.
            IF AVAIL contabiliza THEN DO:
                ASSIGN tt-movto-ctbl-ce-new.tta_cod_cta_ctbl_contra = contabiliza.ct-codigo.
            END.
        END.
    END.
END.

for each tt-movto-ctbl-ce-new:

    create tt-movto-ctbl-ce.
    buffer-copy tt-movto-ctbl-ce-new to tt-movto-ctbl-ce.
    
    find item where item.it-codigo = tt-movto-ctbl-ce.it-codigo no-lock no-error.
    
/*         FIND first contabiliza USE-INDEX estabelec                                                                                    */
/*                 where contabiliza.cod-estabel = tt-movto-ctbl-ce.cod-estabel                                                          */
/*                   and contabiliza.cod-depos   = tt-movto-ctbl-ce.cod-depos                                                            */
/*                   and contabiliza.ge-codigo   = tt-movto-ctbl-ce.ge-codigo NO-ERROR.                                                  */
/*                   IF AVAIL contabiliza and tt-movto-ctbl-ce.tta_cod_cta_ctbl_contra = tt-movto-ctbl-ce.tta_cod_cta_ctbl THEN          */

/*     IF tt-movto-ctbl-ce.tta_cod_cta_ctbl_contra = "" THEN                                      */
/*     FIND first contabiliza USE-INDEX estabelec                                                 */
/*                 where contabiliza.cod-estabel = tt-movto-ctbl-ce.cod-estabel                   */
/*                   and contabiliza.cod-depos   = tt-movto-ctbl-ce.cod-depos                     */
/*                   and contabiliza.ge-codigo   = tt-item.ge-codigo NO-ERROR.           		  */
/*                   IF AVAIL contabiliza THEN DO:                                                */
/*                      ASSIGN tt-movto-ctbl-ce.tta_cod_cta_ctbl_contra = contabiliza.ct-codigo.  */
/*                   END.                                                                         */

end.


for each tt_aprop_lancto_ctbl_aux2:

    assign tt_aprop_lancto_ctbl_aux2.tta_ind_natur_lancto_ctbl = if tt_aprop_lancto_ctbl_aux2.tta_val_aprop > 0 then
                                                                    (if tt_aprop_lancto_ctbl_aux2.tta_cod_plano_cta = "1" then "CR" else "DB")
                                                                 else
                                                                    (if tt_aprop_lancto_ctbl_aux2.tta_cod_plano_cta = "1" then "DB" else "CR")
           tt_aprop_lancto_ctbl_aux2.tta_val_aprop = if tt_aprop_lancto_ctbl_aux2.tta_val_aprop < 0 then
                                                        (tt_aprop_lancto_ctbl_aux2.tta_val_aprop * -1)
                                                      else
                                                         tt_aprop_lancto_ctbl_aux2.tta_val_aprop
           tt_aprop_lancto_ctbl_aux2.tta_cod_plano_cta = "".
		   
end.


run pi-finalizar in h-acomp.
return "OK":U.

procedure pi-gerar:

	/*put unformatted
		"PI-GERAR|seq=" movto-ctbl-ce.sequencia
		"|ge=" movto-ctbl-ce.ge-codigo
		"|dt=" string(movto-ctbl-ce.dt-trans,"99/99/9999")
		"|est=" movto-ctbl-ce.cod-estabel
		"|dep=" movto-ctbl-ce.cod-depos
		"|un=" movto-ctbl-ce.cod-unid-negoc
		"|esp=" movto-ctbl-ce.esp-docto
		"|trans=" movto-ctbl-ce.transacao
		"|cta=" movto-ctbl-ce.cod-cta
		"|cc=" movto-ctbl-ce.cod-ccusto
		"|numid=" movto-ctbl-ce.num-id-movto-ctbl-ce skip.
	output close.*/

    for first estabelec
       fields(cod-estabel
              ct-icm
              sc-icm
              ct-ipi
              sc-ipi
              cod-cta-pis-recup
              cod-ccusto-pis-recup
              cod-cta-cofins-recup
              cod-ccusto-cofins-recup)
        where estabelec.cod-estabel = movto-ctbl-ce.cod-estabel no-lock:
		    
        if can-find(first contabiliza USE-INDEX estabelec
                    where contabiliza.cod-estabel = movto-ctbl-ce.cod-estabel
                      and contabiliza.cod-depos   = movto-ctbl-ce.cod-depos
                      and contabiliza.ge-codigo   = movto-ctbl-ce.ge-codigo
                      and contabiliza.ct-codigo   = movto-ctbl-ce.cod-cta
                      and contabiliza.sc-codigo   = movto-ctbl-ce.cod-ccusto) 
                      then do:
						  
            for each movto-estoq USE-INDEX data-saldo no-lock
               where movto-estoq.dt-trans           = movto-ctbl-ce.dt-trans
                 and movto-estoq.ct-saldo           = movto-ctbl-ce.cod-cta
                 and movto-estoq.sc-saldo           = movto-ctbl-ce.cod-ccusto
                 and movto-estoq.cod-estabel        = movto-ctbl-ce.cod-estabel
                 and movto-estoq.cod-unid-negoc-sdo = movto-ctbl-ce.cod-unid-negoc
                 and movto-estoq.cod-depos          = movto-ctbl-ce.cod-depos
                 and movto-estoq.esp-docto          = movto-ctbl-ce.esp-docto
                 and movto-estoq.tipo-trans         = movto-ctbl-ce.transacao
                 and movto-estoq.contabilizado      = yes
                 and movto-estoq.dt-contab          = movto-ctbl-ce.dt-trans
                 and movto-estoq.refer-contab       = movto-ctbl-ce.referencia:
            /*   first item                                                            */
            /*  fields(it-codigo                                                       */
            /*         ge-codigo                                                       */
            /*         desc-item                                                       */
            /*         tipo-contr) no-lock                                             */
            /*   where item.it-codigo                 = movto-estoq.it-codigo          */
            /*     and item.ge-codigo                 = item.ge-codigo:       */
			
				find item where item.it-codigo = movto-estoq.it-codigo.
				
                RUN pi-acompanhar IN h-acomp ("CEP_Conta_Saldo" + string(movto-estoq.dt-trans) + " " +
                                                                         movto-estoq.ct-saldo + " " +
                                                                         movto-estoq.cod-estabel +
                                                                  STRING(movto-estoq.nr-trans)).

                assign de-valor-cont = 0
                       de-valor-fasb = 0
                       de-valor-cmi  = 0
                       l-movto-estoq = yes.

				output to value(v-log-file) append.
				put unformatted
					"CALL-SALDO[A]|seq_origem=" movto-ctbl-ce.sequencia
					"|mov_nr_trans=" movto-estoq.nr-trans
					"|doc=" movto-estoq.nro-docto
					"|serie=" movto-estoq.serie-docto
					"|emit=" movto-estoq.cod-emitente
					"|nat=" movto-estoq.nat-operacao
					"|esp=" movto-estoq.esp-docto
					"|tipo=" movto-estoq.tipo-trans
					"|it=" movto-estoq.it-codigo
					"|p_cta=" movto-estoq.ct-saldo
					"|p_cc=" movto-estoq.sc-saldo
					"|p_un=" movto-estoq.cod-unid-negoc-sdo skip.
				output close.

                run pi-cria-tt-saldo (input movto-estoq.ct-saldo,
                                      input movto-estoq.sc-saldo,
                                      input movto-estoq.cod-unid-negoc-sdo,
                                      input 1,
                                      input 1).
            end.
        end.
        else do:

            for each movto-estoq USE-INDEX estab-dep no-lock
               where movto-estoq.cod-estabel        = movto-ctbl-ce.cod-estabel
                 and movto-estoq.dt-trans           = movto-ctbl-ce.dt-trans
                 and movto-estoq.cod-depos          = movto-ctbl-ce.cod-depos
                 and movto-estoq.cod-unid-negoc     = movto-ctbl-ce.cod-unid-negoc
                 and movto-estoq.esp-docto          = movto-ctbl-ce.esp-docto
                 and movto-estoq.tipo-trans         = movto-ctbl-ce.transacao:
             /*  first item                                                           */
             /* fields(it-codigo                                                      */
             /*        ge-codigo                                                      */
             /*        desc-item                                                      */
             /*        tipo-contr) no-lock                                            */
             /*  where item.it-codigo                 = movto-estoq.it-codigo         */
             /*    and item.ge-codigo                 = item.ge-codigo:      */
				
				find item where item.it-codigo = movto-estoq.it-codigo.

                RUN pi-acompanhar IN h-acomp ("CEP_Movtos" + string(movto-estoq.dt-trans)   + " " +
                                                                    movto-estoq.ct-saldo    + " " +
                                                                    movto-estoq.cod-estabel + " " +
                                                             STRING(movto-estoq.it-codigo)).

                assign de-valor-cont     = 0
                       de-valor-fasb     = 0
                       de-valor-cmi      = 0
                       l-movto-estoq     = yes.

				/*output to value(v-log-file) append.
				put unformatted
					"CALL-SALDO[B]|seq_origem=" movto-ctbl-ce.sequencia
					"|mov_nr_trans=" movto-estoq.nr-trans
					"|doc=" movto-estoq.nro-docto
					"|serie=" movto-estoq.serie-docto
					"|emit=" movto-estoq.cod-emitente
					"|nat=" movto-estoq.nat-operacao
					"|esp=" movto-estoq.esp-docto
					"|tipo=" movto-estoq.tipo-trans
					"|it=" movto-estoq.it-codigo
					"|p_cta=" movto-estoq.ct-codigo
					"|p_cc=" movto-estoq.sc-codigo
					"|p_un=" movto-estoq.cod-unid-negoc skip.
				output close.*/

                if movto-estoq.ct-codigo = movto-ctbl-ce.cod-cta
               and movto-estoq.sc-codigo = movto-ctbl-ce.cod-ccusto then 
                    run pi-cria-tt-saldo(input movto-estoq.ct-codigo,
                                         input movto-estoq.sc-codigo,
                                         input movto-estoq.cod-unid-negoc,
                                         input 2,
                                         input 1).

                /*Detalha IPI*/
                if movto-estoq.valor-ipi    > 0
               and movto-ctbl-ce.cod-cta    = estabelec.ct-ipi
               and movto-ctbl-ce.cod-ccusto = estabelec.sc-ipi then
                    run pi-cria-tt-movto-ctbl-ce-new(input 1,
                                                     input movto-ctbl-ce.cod-cta,
                                                     input movto-ctbl-ce.cod-ccusto,
                                                     input 1).
                /*Detalha ICM*/
                if movto-estoq.valor-icm    > 0
               and movto-ctbl-ce.cod-cta    = estabelec.ct-icm
               and movto-ctbl-ce.cod-ccusto = estabelec.sc-icm then
                    run pi-cria-tt-movto-ctbl-ce-new(input 2,
                                                     input movto-ctbl-ce.cod-cta,
                                                     input movto-ctbl-ce.cod-ccusto,
                                                     input 1).
                /*Detalha Valor PIS a Recuperar*/
                if movto-estoq.valor-pis    > 0
               and movto-ctbl-ce.cod-cta    = estabelec.cod-cta-pis-recup
               and movto-ctbl-ce.cod-ccusto = estabelec.cod-ccusto-pis-recup then
                    run pi-cria-tt-movto-ctbl-ce-new(input 3,
                                                     input movto-ctbl-ce.cod-cta,
                                                     input movto-ctbl-ce.cod-ccusto,
                                                     input 1).
                /*Detalha Valor COFINS a Recuperar*/
                if movto-estoq.val-cofins   > 0
               and movto-ctbl-ce.cod-cta    = estabelec.cod-cta-cofins-recup
               and movto-ctbl-ce.cod-ccusto = estabelec.cod-ccusto-cofins-recup then
                    run pi-cria-tt-movto-ctbl-ce-new (input 4,
                                                      input movto-ctbl-ce.cod-cta,
                                                      input movto-ctbl-ce.cod-ccusto,
                                                      input 1).
            end.
        end.
    end.
end procedure.

procedure pi-cria-tt-saldo:

    RUN pi-acompanhar IN h-acomp ("CEP_Cria_Saldo: " + string(movto-estoq.dt-trans)   + " " +
                                                              movto-estoq.ct-saldo    + " " +
                                                              movto-estoq.cod-estabel + " " +
                                                       STRING(movto-estoq.it-codigo)).

    def input param p-cod-cta        as char no-undo.
    def input param p-cod-ccusto     as char no-undo.
    def input param p-cod-unid-negoc as char no-undo.
    def input param i-tipo           as int  no-undo.
    def input param i-cp             as int  no-undo.
				
    def var v_ind_natur as char no-undo.
    def var v_des_chave as char no-undo.
    def var v_val_aprop as dec  no-undo.
	
	assign i-seq-destino = movto-ctbl-ce.sequencia.

	/*output to value(v-log-file) append.
	put unformatted
		"PI-SALDO|seq_origem=" movto-ctbl-ce.sequencia
		"|seq_dest=" i-seq-destino
		"|dt=" string(movto-estoq.dt-trans,"99/99/9999")
		"|est=" movto-estoq.cod-estabel
		"|dep=" movto-estoq.cod-depos
		"|un=" p-cod-unid-negoc
		"|esp=" movto-estoq.esp-docto
		"|tipo=" movto-estoq.tipo-trans
		"|nr_trans=" movto-estoq.nr-trans
		"|it=" movto-estoq.it-codigo
		"|doc=" movto-estoq.nro-docto
		"|serie=" movto-estoq.serie-docto
		"|emit=" movto-estoq.cod-emitente
		"|nat=" movto-estoq.nat-operacao
		"|p_cta=" p-cod-cta
		"|p_cc=" p-cod-ccusto skip.
	output close.*/

    find first tt-movto-ctbl-ce-new
         where tt-movto-ctbl-ce-new.cod-estabel    = movto-estoq.cod-estabel	
           and tt-movto-ctbl-ce-new.cod-cta        = p-cod-cta	
           and tt-movto-ctbl-ce-new.cod-ccusto     = p-cod-ccusto	
           and tt-movto-ctbl-ce-new.cod-unid-negoc = p-cod-unid-negoc	
           and tt-movto-ctbl-ce-new.ge-codigo      = item.ge-codigo	
           and tt-movto-ctbl-ce-new.dt-trans       = movto-estoq.dt-trans	
           and tt-movto-ctbl-ce-new.cod-depos      = movto-estoq.cod-depos	
		   and tt-movto-ctbl-ce-new.nr-trans	   = movto-estoq.nr-trans
           and tt-movto-ctbl-ce-new.esp-docto      = movto-estoq.esp-docto	
           and tt-movto-ctbl-ce-new.transacao      = movto-estoq.tipo-trans	
           and tt-movto-ctbl-ce-new.it-codigo      = movto-estoq.it-codigo
		   and tt-movto-ctbl-ce-new.sequencia	   = i-seq-destino		   
           and tt-movto-ctbl-ce-new.nro-docto      = movto-estoq.nro-docto	
           and tt-movto-ctbl-ce-new.cod-emitente   = movto-estoq.cod-emitente	
           and tt-movto-ctbl-ce-new.serie-docto    = movto-estoq.serie-docto	
           and tt-movto-ctbl-ce-new.nat-operacao   = movto-estoq.nat-operacao no-error.	
	
	/*output to value(v-log-file) append.
	put unformatted
		"FIND-TT|avail=" (if avail tt-movto-ctbl-ce-new then "Y" else "N")
		(if avail tt-movto-ctbl-ce-new then
			"|tt_seq=" + string(tt-movto-ctbl-ce-new.sequencia) +
			"|tt_it=" + tt-movto-ctbl-ce-new.it-codigo +
			"|tt_doc=" + tt-movto-ctbl-ce-new.nro-docto
		 else "")
		skip.
	output close.*/
    
    if not avail tt-movto-ctbl-ce-new then do:
        create tt-movto-ctbl-ce-new.
        buffer-copy movto-ctbl-ce to tt-movto-ctbl-ce-new.
        assign tt-movto-ctbl-ce-new.it-codigo               = item.it-codigo
		       tt-movto-ctbl-ce-new.sequencia				= i-seq-destino
               tt-movto-ctbl-ce-new.nro-docto               = movto-estoq.nro-docto
               tt-movto-ctbl-ce-new.cod-emitente            = movto-estoq.cod-emitente
               tt-movto-ctbl-ce-new.serie-docto             = movto-estoq.serie-docto
               tt-movto-ctbl-ce-new.nat-operacao            = movto-estoq.nat-operacao
			   tt-movto-ctbl-ce-new.nr-trans		        = movto-estoq.nr-trans
               tt-movto-ctbl-ce-new.desc-item               = item.desc-item
               tt-movto-ctbl-ce-new.narrativa               = movto-estoq.descricao-db
               tt-movto-ctbl-ce-new.valor-cont              = 0
               tt-movto-ctbl-ce-new.vl-cont-fasb[1]         = 0
               tt-movto-ctbl-ce-new.vl-cont-fasb[2]         = 0
               tt-movto-ctbl-ce-new.mo-codigo               = 0
               tt-movto-ctbl-ce-new.unidade                 = movto-estoq.un
               tt-movto-ctbl-ce-new.qtde                    = movto-estoq.quantidade
               tt-movto-ctbl-ce-new.numero-ordem            = movto-estoq.numero-ordem
               tt-movto-ctbl-ce-new.tta_cod_cta_ctbl_contra = movto-estoq.ct-saldo
               tt-movto-ctbl-ce-new.ge-codigo               = item.ge-codigo.

				/*output to value(v-log-file) append.
				put unformatted
					"CREATE-TT|seq=" tt-movto-ctbl-ce-new.sequencia
					"|it=" tt-movto-ctbl-ce-new.it-codigo
					"|doc=" tt-movto-ctbl-ce-new.nro-docto
					"|nr_trans=" tt-movto-ctbl-ce-new.nr-trans
					"|cta=" tt-movto-ctbl-ce-new.cod-cta
					"|cc=" tt-movto-ctbl-ce-new.cod-ccusto skip.
				output close.*/
               
               if tt-movto-ctbl-ce-new.tta_cod_cta_ctbl = movto-estoq.ct-saldo then
                    assign tt-movto-ctbl-ce-new.tta_cod_cta_ctbl_contra = movto-estoq.ct-codigo.
                    
                    
               if tt-movto-ctbl-ce-new.tta_cod_cta_ctbl_contra begins "9" then do:	
                   find first bf-movto-estoq where	
                            bf-movto-estoq.serie-docto   = movto-estoq.serie-docto  and	
                            bf-movto-estoq.nro-docto     = movto-estoq.nro-docto    and	
                            bf-movto-estoq.cod-emitente  = movto-estoq.cod-emitente and	
                            bf-movto-estoq.sequen-nf     = movto-estoq.sequen-nf    and	
                            bf-movto-estoq.it-codigo     = movto-estoq.it-codigo    and	
                            bf-movto-estoq.cod-estabel   = movto-estoq.cod-estabel  and	
                            bf-movto-estoq.dt-trans      = movto-estoq.dt-trans     and	
                            bf-movto-estoq.esp-docto     = movto-estoq.esp-docto    and	
                            bf-movto-estoq.tipo-trans    <> movto-estoq.tipo-trans  no-lock no-error.	
                            
                   if avail bf-movto-estoq then
                        assign tt-movto-ctbl-ce-new.tta_cod_cta_ctbl_contra  = if bf-movto-estoq.ct-codigo begins "9" then bf-movto-estoq.ct-saldo else bf-movto-estoq.ct-codigo .
                        
                   else do:
                        FIND first contabiliza USE-INDEX estabelec 
                            where contabiliza.cod-estabel = tt-movto-ctbl-ce.cod-estabel                  
                        and contabiliza.cod-depos   = tt-movto-ctbl-ce.cod-depos                   
                        and contabiliza.ge-codigo   = tt-movto-ctbl-ce.ge-codigo NO-LOCK NO-ERROR.          
                       /*IF AVAIL contabiliza THEN                                                
                          ASSIGN tt-movto-ctbl-ce.tta_cod_cta_ctbl_contra = if contabiliza.ct-codigo begins "9" then contabiliza.ct-var-saldo else contabiliza.ct-codigo.*/
                                          
                   end.
                   
                            
               end.   
                             
               /*if tt-movto-ctbl-ce-new.tta_cod_cta_ctbl_contra begins "9" then
               message "Contra 01 " skip
                       movto-estoq.descricao-db skip
                       "Lancto: " tt-movto-ctbl-ce-new.tta_cod_cta_ctbl skip
                       "Conta Lanc " movto-estoq.ct-codigo skip
                       "Conta Sald " movto-estoq.ct-saldo skip
                       "Item...... " movto-estoq.it-codigo skip
                       "Contra..: " tt-movto-ctbl-ce-new.tta_cod_cta_ctbl_contra skip
                       int(item.tipo-contr) skip
                       view-as alert-box.*/
                       
        /* Quando o item eh do tipo debito direto - buscar a contra-partida no movto relacionado*/              
        /*if item.tipo-contr = 4 then do:
            find first bf-movto-estoq where
                        bf-movto-estoq.serie-docto  = movto-estoq.serie-docto  and
                        bf-movto-estoq.nro-docto    = movto-estoq.nro-docto    and
                        bf-movto-estoq.cod-emitente = movto-estoq.cod-emitente and
                        bf-movto-estoq.sequen-nf    = movto-estoq.sequen-nf    and
                        bf-movto-estoq.it-codigo    = movto-estoq.it-codigo    and
                        bf-movto-estoq.cod-estabel  = movto-estoq.cod-estabel  and
                        bf-movto-estoq.dt-trans     = movto-estoq.dt-trans     and
                        bf-movto-estoq.esp-docto    = movto-estoq.esp-docto    and
                        bf-movto-estoq.tipo-trans   <> movto-estoq.tipo-trans no-lock no-error.
            if avail bf-movto-estoq then
                assign tt-movto-ctbl-ce-new.tta_cod_cta_ctbl_contra  = bf-movto-estoq.ct-codigo.
                
        end.*/  
        
        /* Verificando se a conta encontrada ‚ a mesma da origem do lan‡amento */
        /*if tt-movto-ctbl-ce-new.cod-cta = tt-movto-ctbl-ce-new.tta_cod_cta_ctbl_contra then do:
            
            if movto-estoq.ct-codigo <>  tt-movto-ctbl-ce-new.tta_cod_cta_ctbl_contra then
                assign tt-movto-ctbl-ce-new.tta_cod_cta_ctbl_contra = movto-estoq.ct-codigo.
            else if movto-estoq.ct-saldo <>  tt-movto-ctbl-ce-new.tta_cod_cta_ctbl_contra then
                assign tt-movto-ctbl-ce-new.tta_cod_cta_ctbl_contra = movto-estoq.ct-saldo.
        
            
        end.*/


        assign tt-movto-ctbl-ce-new.num-pedido = 0.
        for first bf-ordem-compra fields(numero-ordem
                                         num-pedido) NO-LOCK USE-INDEX ordem
            where bf-ordem-compra.numero-ordem = movto-estoq.numero-ordem:

            assign tt-movto-ctbl-ce-new.num-pedido = bf-ordem-compra.num-pedido.

        end.

    end.

    FIND FIRST estab-mat NO-LOCK WHERE
               estab-mat.cod-estabel =  movto-estoq.cod-estabel NO-ERROR.
    IF AVAIL estab-mat THEN DO:

       IF i-tipo = 2  THEN DO:

           CASE estab-mat.custo-contab :
              WHEN 1 THEN DO:
                 IF NOT l-ifrs-contab-estoq THEN DO:
                     {esp/ESFGL0001xa.i "1" "-m" "valor-cont" 1}
                 END.
                 ELSE DO:
                     CASE movto-ctbl-cenar.cdn-moeda:
                         WHEN 0 THEN DO: /* moeda corrente */
                             {esp/ESFGL0001xa.i "1" "-m" "valor-cont" 1}
                         END.
                         WHEN 1 THEN DO: /* moeda alternativa 1 IFRS */
                             {esp/ESFGL0001xa.i "1" "-m" "valor-cont" 2}
                         END.
                         WHEN 2 THEN DO:
                             {esp/ESFGL0001xa.i "1" "-m" "valor-cont" 3}
                         END.
                     END CASE.
                 END.
              END.
              WHEN 2 THEN DO:
                  IF NOT l-ifrs-contab-estoq THEN DO:
                      {esp/ESFGL0001xa.i "1" "-o" "valor-cont" 1}
                  END.
                  ELSE DO:
                      CASE movto-ctbl-cenar.cdn-moeda:
                          WHEN 0 THEN DO: /* moeda corrente */
                              {esp/ESFGL0001xa.i "1" "-o" "valor-cont" 1}
                          END.
                          WHEN 1 THEN DO: /* moeda alternativa 1 IFRS */
                              {esp/ESFGL0001xa.i "1" "-o" "valor-cont" 2}
                          END.
                          WHEN 2 THEN DO:
                              {esp/ESFGL0001xa.i "1" "-o" "valor-cont" 3}
                          END.
                      END CASE.
                  END.
              END.
           END CASE.


           IF l-fasb THEN DO:
              CASE estab-mat.custo-contab :
                 WHEN 1 THEN DO:
                    {esp/ESFGL0001xa.i "1" "-m" "vl-cont-fasb" i-mo-fasb}
                 END.
                 WHEN 2 THEN DO:
                    {esp/ESFGL0001xa.i "1" "-o" "vl-cont-fasb" i-mo-fasb}
                 END.
              END CASE.
           END.

           IF l-cmi THEN DO:
              CASE estab-mat.custo-contab :
                 WHEN 1 THEN DO:
                    {esp/ESFGL0001xa.i "2" "-m" "vl-cont-fasb" i-mo-cmi}
                 END.
                 WHEN 2 THEN DO:
                    {esp/ESFGL0001xa.i "2" "-o" "vl-cont-fasb" i-mo-cmi}
                 END.
              END CASE.
           END.
       END.
       ELSE DO:
            CASE estab-mat.custo-contab :
                WHEN 1 THEN DO:
                    IF NOT l-ifrs-contab-estoq THEN DO:
                        {esp/ESFGL0001xa.i1 "1" "-m" "valor-cont" 1}
                    END.
                    ELSE DO:
                        CASE movto-ctbl-cenar.cdn-moeda:
                            WHEN 0 THEN DO: /* moeda corrente */
                                {esp/ESFGL0001xa.i1 "1" "-m" "valor-cont" 1}
                            END.
                            WHEN 1 THEN DO: /* moeda alternativa 1 IFRS */
                                {esp/ESFGL0001xa.i1 "1" "-m" "valor-cont" 2}
                            END.
                            WHEN 2 THEN DO:
                                {esp/ESFGL0001xa.i1 "1" "-m" "valor-cont" 3}
                            END.
                        END CASE.
                    END.
                END.
                WHEN 2 THEN DO:
                    IF NOT l-ifrs-contab-estoq THEN DO:
                        {esp/ESFGL0001xa.i1 "1" "-o" "valor-cont" 1}
                    END.
                    ELSE DO:
                        CASE movto-ctbl-cenar.cdn-moeda:
                            WHEN 0 THEN DO: /* moeda corrente */
                                {esp/ESFGL0001xa.i1 "1" "-o" "valor-cont" 1}
                            END.
                            WHEN 1 THEN DO: /* moeda alternativa 1 IFRS */
                                {esp/ESFGL0001xa.i1 "1" "-o" "valor-cont" 2}
                            END.
                            WHEN 2 THEN DO:
                                {esp/ESFGL0001xa.i1 "1" "-o" "valor-cont" 3}
                            END.
                        END CASE.
                    END.
                END.
            END CASE.

            IF l-fasb THEN DO:
                CASE estab-mat.custo-contab :
                     WHEN 1 THEN DO:
                        {esp/ESFGL0001xa.i1 "1" "-m" "vl-cont-fasb" i-mo-fasb}
                     END.
                     WHEN 2 THEN DO:
                        {esp/ESFGL0001xa.i1 "1" "-o" "vl-cont-fasb" i-mo-fasb}
                     END.
                END CASE.
            END.

            IF l-cmi THEN DO:
                CASE estab-mat.custo-contab :
                     WHEN 1 THEN DO:
                        {esp/ESFGL0001xa.i1 "2" "-m" "vl-cont-fasb" i-mo-cmi}
                     END.
                     WHEN 2 THEN DO:
                        {esp/ESFGL0001xa.i1 "2" "-o" "vl-cont-fasb" i-mo-cmi}
                     END.
                END CASE.
            END.
       END.
    END.
	
 
    if index(v_des_modul_select,"CEP") > 0 then do:

        assign v_val_aprop = tt-movto-ctbl-ce-new.valor-cont
               v_des_chave = string(tt-movto-ctbl-ce-new.num-seq-movto-ctbl-ce) + movto-estoq.it-codigo + movto-estoq.cod-estabel + movto-estoq.nro-docto.

        /*Conta de Saldo*/
        if i-tipo = 1 then do:

            if i-cp = 1 then do:

                find first tt_aprop_lancto_ctbl_aux2
                     where tt_aprop_lancto_ctbl_aux2.tta_cod_cta_ctbl          = movto-estoq.ct-codigo
                       and tt_aprop_lancto_ctbl_aux2.tta_cod_ccusto            = movto-estoq.sc-codigo
                       and tt_aprop_lancto_ctbl_aux2.tta_cod_unid_negoc        = movto-estoq.cod-unid-negoc
                       and tt_aprop_lancto_ctbl_aux2.ttv_des_chave_lancto      = v_des_chave  no-error.
                if not avail tt_aprop_lancto_ctbl_aux2 then do:

                    create tt_aprop_lancto_ctbl_aux2.
                    assign tt_aprop_lancto_ctbl_aux2.tta_cod_plano_cta         = "1"
                           tt_aprop_lancto_ctbl_aux2.tta_cod_cta_ctbl          = movto-estoq.ct-codigo
                           tt_aprop_lancto_ctbl_aux2.tta_des_tit_ctbl          = ""
                           tt_aprop_lancto_ctbl_aux2.tta_cod_plano_ccusto      = ""
                           tt_aprop_lancto_ctbl_aux2.tta_cod_ccusto            = movto-estoq.sc-codigo
                           tt_aprop_lancto_ctbl_aux2.tta_cod_unid_negoc        = movto-estoq.cod-unid-negoc
                           tt_aprop_lancto_ctbl_aux2.ttv_des_chave_lancto      = v_des_chave.

                end.
                assign tt_aprop_lancto_ctbl_aux2.tta_val_aprop             = v_val_aprop.

            end.
            else do:

                find first tt_aprop_lancto_ctbl_aux2
                     where tt_aprop_lancto_ctbl_aux2.tta_cod_cta_ctbl          = p-cod-cta
                       and tt_aprop_lancto_ctbl_aux2.tta_cod_ccusto            = p-cod-ccusto
                       and tt_aprop_lancto_ctbl_aux2.tta_cod_unid_negoc        = p-cod-unid-negoc
                       and tt_aprop_lancto_ctbl_aux2.ttv_des_chave_lancto      = v_des_chave  no-lock no-error.
                if not avail tt_aprop_lancto_ctbl_aux2 then do:

                    create tt_aprop_lancto_ctbl_aux2.
                    assign tt_aprop_lancto_ctbl_aux2.tta_cod_plano_cta         = "2"
                           tt_aprop_lancto_ctbl_aux2.tta_cod_cta_ctbl          = p-cod-cta
                           tt_aprop_lancto_ctbl_aux2.tta_des_tit_ctbl          = ""
                           tt_aprop_lancto_ctbl_aux2.tta_cod_plano_ccusto      = ""
                           tt_aprop_lancto_ctbl_aux2.tta_cod_ccusto            = p-cod-ccusto
                           tt_aprop_lancto_ctbl_aux2.tta_cod_unid_negoc        = p-cod-unid-negoc
                           tt_aprop_lancto_ctbl_aux2.ttv_des_chave_lancto      = v_des_chave
                           tt_aprop_lancto_ctbl_aux2.tta_val_aprop             = v_val_aprop.

                end.
                else
                    assign tt_aprop_lancto_ctbl_aux2.tta_val_aprop             = tt_aprop_lancto_ctbl_aux2.tta_val_aprop + v_val_aprop.

                /*if avail tt-movto-ctbl-ce-new then
                    delete tt-movto-ctbl-ce-new.*/

            end.
        end.  
        
        /*Conta de Código*/
        else do:

            if (movto-ctbl-ce.cod-cta    = estabelec.ct-ipi)
            or (movto-ctbl-ce.cod-cta    = estabelec.ct-icm)
            or (movto-ctbl-ce.cod-cta    = estabelec.cod-cta-pis-recup)
            or (movto-ctbl-ce.cod-cta    = estabelec.cod-cta-cofins-recup)
            or (movto-ctbl-ce.cod-cta    = movto-estoq.ct-saldo) then
                assign v-log-verif-ct-sdo = no.
            else
                assign v-log-verif-ct-sdo = yes.

            if v-log-verif-ct-sdo = yes
               and i-cp = 1 then do:

                movto_block:
                for each b_movto-ctbl-ce USE-INDEX referencia no-lock
                   where b_movto-ctbl-ce.ep-codigo   = movto-ctbl-ce.ep-codigo
                     and b_movto-ctbl-ce.cod-estabel = movto-ctbl-ce.cod-estabel
                     and b_movto-ctbl-ce.referencia  = movto-ctbl-ce.referencia:

                    RUN pi-acompanhar IN h-acomp ("Detalhe_Movto_CE: "         + string(movto-ctbl-ce.dt-trans)   + " " +
                                                                                        movto-ctbl-ce.cod-estabel + " " +
                                                                                 STRING(movto-estoq.it-codigo)    + " " +
                                                                                 STRING(movto-estoq.cod-refer)    + " " +
                                                                                        movto-estoq.nro-docto     + " " +
                                                                                 STRING(movto-ctbl-ce.sequencia)).


                    if recid(b_movto-ctbl-ce)         = recid(movto-ctbl-ce) then
                        next movto_block.

                if b_movto-ctbl-ce.cod-estabel        = movto-estoq.cod-estabel
                  and b_movto-ctbl-ce.cod-unid-negoc  = movto-estoq.cod-unid-negoc
                  and b_movto-ctbl-ce.dt-trans        = movto-estoq.dt-trans
                  and b_movto-ctbl-ce.cod-depos       = movto-estoq.cod-depos
                  and b_movto-ctbl-ce.esp-docto       = movto-estoq.esp-docto
                  and b_movto-ctbl-ce.transacao       = movto-estoq.tipo-trans then do:


                        /*Detalha IPI*/
                        if movto-estoq.valor-ipi    > 0
                       and b_movto-ctbl-ce.cod-cta    = estabelec.ct-ipi
                       and b_movto-ctbl-ce.cod-ccusto = estabelec.sc-ipi then
                            run pi-cria-tt-movto-ctbl-ce-new(input 1,
                                                             input b_movto-ctbl-ce.cod-cta,
                                                             input b_movto-ctbl-ce.cod-ccusto,
                                                             input 2).
                        /*Detalha ICM*/
                        if movto-estoq.valor-icm    > 0
                       and b_movto-ctbl-ce.cod-cta    = estabelec.ct-icm
                       and b_movto-ctbl-ce.cod-ccusto = estabelec.sc-icm then
                            run pi-cria-tt-movto-ctbl-ce-new(input 2,
                                                             input b_movto-ctbl-ce.cod-cta,
                                                             input b_movto-ctbl-ce.cod-ccusto,
                                                             input 2).
                        /*Detalha Valor PIS a Recuperar*/
                        if movto-estoq.valor-pis    > 0
                       and b_movto-ctbl-ce.cod-cta    = estabelec.cod-cta-pis-recup
                       and b_movto-ctbl-ce.cod-ccusto = estabelec.cod-ccusto-pis-recup then
                            run pi-cria-tt-movto-ctbl-ce-new(input 3,
                                                             input b_movto-ctbl-ce.cod-cta,
                                                             input b_movto-ctbl-ce.cod-ccusto,
                                                             input 2).
                        /*Detalha Valor COFINS a Recuperar*/
                        if movto-estoq.val-cofins   > 0
                       and b_movto-ctbl-ce.cod-cta    = estabelec.cod-cta-cofins-recup
                       and b_movto-ctbl-ce.cod-ccusto = estabelec.cod-ccusto-cofins-recup then
                            run pi-cria-tt-movto-ctbl-ce-new (input 4,
                                                              input b_movto-ctbl-ce.cod-cta,
                                                              input b_movto-ctbl-ce.cod-ccusto,
                                                              input 2).
                   end.

                    if can-find(first contabiliza USE-INDEX estabelec
                                where contabiliza.cod-estabel = b_movto-ctbl-ce.cod-estabel
                                  and contabiliza.cod-depos   = b_movto-ctbl-ce.cod-depos
                                  and contabiliza.ge-codigo   = b_movto-ctbl-ce.ge-codigo
                                  and contabiliza.ct-codigo   = b_movto-ctbl-ce.cod-cta
                                  and contabiliza.sc-codigo   = b_movto-ctbl-ce.cod-ccusto) then do:

                        if b_movto-ctbl-ce.cod-estabel    = movto-estoq.cod-estabel
                       and b_movto-ctbl-ce.cod-cta        = movto-estoq.ct-saldo
                       and b_movto-ctbl-ce.cod-ccusto     = movto-estoq.sc-saldo
                       and b_movto-ctbl-ce.cod-unid-negoc = movto-estoq.cod-unid-negoc-sdo
                       and b_movto-ctbl-ce.dt-trans       = movto-estoq.dt-trans
                       and b_movto-ctbl-ce.cod-depos      = movto-estoq.cod-depos
                       and b_movto-ctbl-ce.esp-docto      = movto-estoq.esp-docto
                       and b_movto-ctbl-ce.transacao      = movto-estoq.tipo-trans then do:

                            run pi-cria-tt-saldo (input movto-estoq.ct-saldo,
                                                  //input movto-estoq.sc-saldo,
                                                  input movto-estoq.cod-unid-negoc-sdo,
                                                  input 1,
                                                  input 2).
                        END.
                    end.
                end.
            end.
            else do:

                if i-cp = 2 then
                    return.			

                find first tt_aprop_lancto_ctbl_aux2
                     where tt_aprop_lancto_ctbl_aux2.tta_cod_cta_ctbl          = movto-estoq.ct-saldo
                       and tt_aprop_lancto_ctbl_aux2.tta_cod_ccusto            = movto-estoq.sc-saldo
                       and tt_aprop_lancto_ctbl_aux2.tta_cod_unid_negoc        = movto-estoq.cod-unid-negoc
                       and tt_aprop_lancto_ctbl_aux2.ttv_des_chave_lancto      = v_des_chave  no-error.
                if not avail tt_aprop_lancto_ctbl_aux2 then do:

                    create tt_aprop_lancto_ctbl_aux2.
                    assign tt_aprop_lancto_ctbl_aux2.tta_cod_plano_cta         = "1"
                           tt_aprop_lancto_ctbl_aux2.tta_cod_cta_ctbl          = movto-estoq.ct-saldo
                           tt_aprop_lancto_ctbl_aux2.tta_des_tit_ctbl          = ""
                           tt_aprop_lancto_ctbl_aux2.tta_cod_plano_ccusto      = ""
                           tt_aprop_lancto_ctbl_aux2.tta_cod_ccusto            = movto-estoq.sc-saldo
                           tt_aprop_lancto_ctbl_aux2.tta_cod_unid_negoc        = movto-estoq.cod-unid-negoc
                           tt_aprop_lancto_ctbl_aux2.ttv_des_chave_lancto      = v_des_chave.

                end.
                assign tt_aprop_lancto_ctbl_aux2.tta_val_aprop             = v_val_aprop.
            end.

        END. 

end.    

END PROCEDURE.

PROCEDURE pi-cria-tt-movto-ctbl-ce-new:

    def input param i-tipo       as int  no-undo.
    def input param p-cod-cta    as char no-undo.
    def input param p-cod-ccusto as char no-undo.
    def input param i-cp         as int  no-undo.

    def var v_ind_natur as char no-undo.
    def var v_des_chave as char no-undo.
    def var v_val_aprop as dec  no-undo.
    
    
    find first tt-movto-ctbl-ce-new 
         where tt-movto-ctbl-ce-new.cod-estabel    = movto-estoq.cod-estabel
           and tt-movto-ctbl-ce-new.cod-cta        = p-cod-cta
           and tt-movto-ctbl-ce-new.cod-ccusto     = p-cod-ccusto
           and tt-movto-ctbl-ce-new.cod-unid-negoc = movto-estoq.cod-unid-negoc
           and tt-movto-ctbl-ce-new.ge-codigo      = movto-ctbl-ce.ge-codigo
           and tt-movto-ctbl-ce-new.dt-trans       = movto-estoq.dt-trans
           and tt-movto-ctbl-ce-new.cod-depos      = movto-estoq.cod-depos
           and tt-movto-ctbl-ce-new.esp-docto      = movto-estoq.esp-docto
           and tt-movto-ctbl-ce-new.transacao      = movto-estoq.tipo-trans
		   and tt-movto-ctbl-ce-new.nr-trans	   = movto-estoq.nr-trans
           and tt-movto-ctbl-ce-new.it-codigo      = movto-estoq.it-codigo
		   and tt-movto-ctbl-ce-new.sequencia	   = movto-ctbl-ce.sequencia
           and tt-movto-ctbl-ce-new.nro-docto      = movto-estoq.nro-docto
           and tt-movto-ctbl-ce-new.cod-emitente   = movto-estoq.cod-emitente
           and tt-movto-ctbl-ce-new.serie-docto    = movto-estoq.serie-docto
           and tt-movto-ctbl-ce-new.nat-operacao   = movto-estoq.nat-operacao no-error.
                    
    if not avail tt-movto-ctbl-ce-new then do:
        create tt-movto-ctbl-ce-new.
        buffer-copy movto-ctbl-ce to tt-movto-ctbl-ce-new.
        assign tt-movto-ctbl-ce-new.it-codigo      = item.it-codigo
			   tt-movto-ctbl-ce-new.sequencia	   = movto-ctbl-ce.sequencia
               tt-movto-ctbl-ce-new.nro-docto      = movto-estoq.nro-docto
               tt-movto-ctbl-ce-new.cod-emitente   = movto-estoq.cod-emitente
               tt-movto-ctbl-ce-new.serie-docto    = movto-estoq.serie-docto
               tt-movto-ctbl-ce-new.nat-operacao   = movto-estoq.nat-operacao
               tt-movto-ctbl-ce-new.desc-item      = item.desc-item  
               tt-movto-ctbl-ce-new.narrativa      = movto-estoq.descricao-db
               tt-movto-ctbl-ce-new.valor-cont      = 0
               tt-movto-ctbl-ce-new.vl-cont-fasb[1] = 0
               tt-movto-ctbl-ce-new.vl-cont-fasb[2] = 0
               tt-movto-ctbl-ce-new.mo-codigo       = 0
               tt-movto-ctbl-ce-new.unidade         = movto-estoq.un
			   tt-movto-ctbl-ce-new.nr-trans		= movto-estoq.nr-trans
               tt-movto-ctbl-ce-new.qtde            = movto-estoq.quantidade
               tt-movto-ctbl-ce-new.numero-ordem    = movto-estoq.numero-ordem
               tt-movto-ctbl-ce-new.ge-codigo       = item.ge-codigo
               tt-movto-ctbl-ce-new.tta_cod_cta_ctbl_contra  = movto-estoq.ct-saldo.
               
               /*
               if tt-movto-ctbl-ce-new.tta_cod_cta_ctbl_contra begins "9" then

               message "Contra 02 " skip
                       movto-estoq.descricao-db skip
                       "Conta Lanc " movto-estoq.ct-codigo skip
                       "Conta Sald " movto-estoq.ct-saldo skip
                       "Item...... " movto-estoq.it-codigo skip
                       "Conta Item " item.ct-codigo skip
                       int(item.tipo-contr) skip
                        view-as alert-box.
                        */
        
        /* Quando o item eh do tipo debito direto - buscar a contra-partida no movto relacionado*/              
        if item.tipo-contr = 4 then do:
              
            find first bf-movto-estoq where
                        bf-movto-estoq.serie-docto  = movto-estoq.serie-docto  and
                        bf-movto-estoq.nro-docto    = movto-estoq.nro-docto    and
                        bf-movto-estoq.cod-emitente = movto-estoq.cod-emitente and
                        bf-movto-estoq.sequen-nf    = movto-estoq.sequen-nf    and
                        bf-movto-estoq.it-codigo    = movto-estoq.it-codigo    and
                        bf-movto-estoq.cod-estabel  = movto-estoq.cod-estabel  and
                        bf-movto-estoq.dt-trans     = movto-estoq.dt-trans     and
                        bf-movto-estoq.esp-docto    = movto-estoq.esp-docto    and
                        bf-movto-estoq.tipo-trans   <> movto-estoq.tipo-trans no-lock no-error.
            if avail bf-movto-estoq  then
                assign tt-movto-ctbl-ce-new.tta_cod_cta_ctbl_contra  = bf-movto-estoq.ct-codigo.
                /*
                message "Contra 02.01 " skip
                       movto-estoq.descricao-db skip
                       "Conta Lanc " movto-estoq.ct-codigo skip
                       "Conta Sald " movto-estoq.ct-saldo skip
                       "Conta Alt  " bf-movto-estoq.ct-codigo
                       view-as alert-box.
                       */
                       
        end.  
        
        /* Verificando se a conta encontrada ‚ a mesma da origem do lan‡amento */
        if tt-movto-ctbl-ce-new.cod-cta = tt-movto-ctbl-ce-new.tta_cod_cta_ctbl_contra then do:
            
            if movto-estoq.ct-codigo <>  tt-movto-ctbl-ce-new.tta_cod_cta_ctbl_contra then
                assign tt-movto-ctbl-ce-new.tta_cod_cta_ctbl_contra = movto-estoq.ct-codigo.
            else if movto-estoq.ct-saldo <>  tt-movto-ctbl-ce-new.tta_cod_cta_ctbl_contra then
                assign tt-movto-ctbl-ce-new.tta_cod_cta_ctbl_contra = movto-estoq.ct-saldo.
        
        end.

        assign tt-movto-ctbl-ce-new.num-pedido = 0.
        for first bf-ordem-compra fields(numero-ordem
                                         num-pedido) NO-LOCK USE-INDEX ordem 
            where bf-ordem-compra.numero-ordem = movto-estoq.numero-ordem:
    
            assign tt-movto-ctbl-ce-new.num-pedido = bf-ordem-compra.num-pedido.
    
        end.

    end.

    CASE i-tipo:
       WHEN 1 THEN DO:  /*IPI*/

           ASSIGN tt-movto-ctbl-ce-new.valor-cont      = ((tt-movto-ctbl-ce-new.valor-cont       + movto-estoq.valor-ipi)      *                    (if movto-estoq.tipo-trans = 1 then 1 else -1))
                  tt-movto-ctbl-ce-new.vl-cont-fasb[1] = ((tt-movto-ctbl-ce-new.vl-cont-fasb[1]  + movto-estoq.vl-ipi-fasb[1]  * INTEGER(l-fasb)) * (if movto-estoq.tipo-trans = 1 then 1 else -1))
                  tt-movto-ctbl-ce-new.vl-cont-fasb[2] = ((tt-movto-ctbl-ce-new.vl-cont-fasb[2]  + movto-estoq.vl-ipi-fasb[2]  * INTEGER(l-cmi))  * (if movto-estoq.tipo-trans = 1 then 1 else -1)).

       END.

       WHEN 2 THEN DO:  /*ICM*/

           ASSIGN tt-movto-ctbl-ce-new.valor-cont      = ((tt-movto-ctbl-ce-new.valor-cont       + movto-estoq.valor-icm)      *                    (if movto-estoq.tipo-trans = 1 then 1 else -1))                    
                  tt-movto-ctbl-ce-new.vl-cont-fasb[1] = ((tt-movto-ctbl-ce-new.vl-cont-fasb[1]  + movto-estoq.vl-icm-fasb[1]  * INTEGER(l-fasb)) * (if movto-estoq.tipo-trans = 1 then 1 else -1))  
                  tt-movto-ctbl-ce-new.vl-cont-fasb[2] = ((tt-movto-ctbl-ce-new.vl-cont-fasb[2]  + movto-estoq.vl-icm-fasb[2]  * INTEGER(l-cmi))  * (if movto-estoq.tipo-trans = 1 then 1 else -1)). 
       END.
       WHEN 3 THEN DO:  /*PIS*/

           ASSIGN tt-movto-ctbl-ce-new.valor-cont      = ((tt-movto-ctbl-ce-new.valor-cont       + movto-estoq.valor-pis)      *                    (if movto-estoq.tipo-trans = 1 then 1 else -1))                    
                  tt-movto-ctbl-ce-new.vl-cont-fasb[1] = ((tt-movto-ctbl-ce-new.vl-cont-fasb[1]  + movto-estoq.vl-pis-fasb     * INTEGER(l-fasb)) * (if movto-estoq.tipo-trans = 1 then 1 else -1))  
                  tt-movto-ctbl-ce-new.vl-cont-fasb[2] = ((tt-movto-ctbl-ce-new.vl-cont-fasb[2]  + movto-estoq.vl-pis-cmi      * INTEGER(l-cmi))  * (if movto-estoq.tipo-trans = 1 then 1 else -1)). 
       END.
       WHEN 4 THEN DO:  /*COFINS*/

           ASSIGN tt-movto-ctbl-ce-new.valor-cont      = ((tt-movto-ctbl-ce-new.valor-cont       + movto-estoq.val-cofins)     *                    (if movto-estoq.tipo-trans = 1 then 1 else -1))                    
                  tt-movto-ctbl-ce-new.vl-cont-fasb[1] = ((tt-movto-ctbl-ce-new.vl-cont-fasb[1]  + movto-estoq.val-cofins-fasb * INTEGER(l-fasb)) * (if movto-estoq.tipo-trans = 1 then 1 else -1))  
                  tt-movto-ctbl-ce-new.vl-cont-fasb[2] = ((tt-movto-ctbl-ce-new.vl-cont-fasb[2]  + movto-estoq.val-cofins-cmi  * INTEGER(l-cmi))  * (if movto-estoq.tipo-trans = 1 then 1 else -1)). 
       END.
    END CASE.  

    if index(v_des_modul_select,"CEP") > 0 then do:   

        assign v_val_aprop = tt-movto-ctbl-ce-new.valor-cont
               v_des_chave = string(tt-movto-ctbl-ce-new.num-seq-movto-ctbl-ce) + movto-estoq.it-codigo + movto-estoq.cod-estabel + movto-estoq.nro-docto.        

        if i-cp = 1 then do:

            find first tt_aprop_lancto_ctbl_aux2
                 where tt_aprop_lancto_ctbl_aux2.tta_cod_cta_ctbl          = movto-estoq.ct-codigo
                   and tt_aprop_lancto_ctbl_aux2.tta_cod_ccusto            = movto-estoq.sc-codigo
                   and tt_aprop_lancto_ctbl_aux2.tta_cod_unid_negoc        = movto-estoq.cod-unid-negoc
                   and tt_aprop_lancto_ctbl_aux2.ttv_des_chave_lancto      = v_des_chave  no-lock no-error.
            if not avail tt_aprop_lancto_ctbl_aux2 then do:
    
                create tt_aprop_lancto_ctbl_aux2.
                assign tt_aprop_lancto_ctbl_aux2.tta_cod_plano_cta         = "1"
                       tt_aprop_lancto_ctbl_aux2.tta_cod_cta_ctbl          = movto-estoq.ct-codigo
                       tt_aprop_lancto_ctbl_aux2.tta_des_tit_ctbl          = ""
                       tt_aprop_lancto_ctbl_aux2.tta_cod_plano_ccusto      = ""
                       tt_aprop_lancto_ctbl_aux2.tta_cod_ccusto            = movto-estoq.sc-codigo
                       tt_aprop_lancto_ctbl_aux2.tta_cod_unid_negoc        = movto-estoq.cod-unid-negoc               
                       tt_aprop_lancto_ctbl_aux2.ttv_des_chave_lancto      = v_des_chave.
            end.          
            assign tt_aprop_lancto_ctbl_aux2.tta_val_aprop             = v_val_aprop.
        end.
        else do:  

            find first tt_aprop_lancto_ctbl_aux2
                 where tt_aprop_lancto_ctbl_aux2.tta_cod_cta_ctbl          = p-cod-cta
                   and tt_aprop_lancto_ctbl_aux2.tta_cod_ccusto            = p-cod-ccusto
                   and tt_aprop_lancto_ctbl_aux2.tta_cod_unid_negoc        = movto-estoq.cod-unid-negoc
                   and tt_aprop_lancto_ctbl_aux2.ttv_des_chave_lancto      = v_des_chave  no-lock no-error.
            if not avail tt_aprop_lancto_ctbl_aux2 then do:
    
                create tt_aprop_lancto_ctbl_aux2.
                assign tt_aprop_lancto_ctbl_aux2.tta_cod_plano_cta         = "2"
                       tt_aprop_lancto_ctbl_aux2.tta_cod_cta_ctbl          = p-cod-cta
                       tt_aprop_lancto_ctbl_aux2.tta_des_tit_ctbl          = ""
                       tt_aprop_lancto_ctbl_aux2.tta_cod_plano_ccusto      = ""
                       tt_aprop_lancto_ctbl_aux2.tta_cod_ccusto            = p-cod-ccusto
                       tt_aprop_lancto_ctbl_aux2.tta_cod_unid_negoc        = movto-estoq.cod-unid-negoc               
                       tt_aprop_lancto_ctbl_aux2.ttv_des_chave_lancto      = v_des_chave
                       tt_aprop_lancto_ctbl_aux2.tta_val_aprop             = v_val_aprop.
            end.
            else
                assign tt_aprop_lancto_ctbl_aux2.tta_val_aprop             = tt_aprop_lancto_ctbl_aux2.tta_val_aprop + v_val_aprop.

            if avail tt-movto-ctbl-ce-new then
                delete tt-movto-ctbl-ce-new.
        end.
    end.
    
END PROCEDURE.
