SESSION:DATE-FORMAT = "dmy".
/****************************************************************************
**
**  Programa: ESFGL0001XRP.P
**     Autor: TOTVS - DRG-SP-Campinas
**  Objetivo: Relat¢rio Raz∆o 
**    Versao: 1.00.00.000
**      Data: 18/05/2016
**
****************************************************************************/
{include/i-prgvrs.i ESFGL0001XRP 1.00.00.000}
{fnd/utp/ut-glob.i}

DEF STREAM s-csv.

def buffer histor_exec_especial for emsbas.histor_exec_especial.
DEF BUFFER b_item_lancto_ctbl   FOR item_lancto_ctbl.
def buffer b-nota-fiscal        for nota-fiscal.
def buffer b-docum-est          for docum-est.
DEF BUFFER b_aprop_ctbl_acr     FOR aprop_ctbl_acr.
DEF BUFFER b_aprop_ctbl_ap      FOR aprop_ctbl_ap.

def temp-table tt-raw-digita
    field raw-digita as raw.

def input parameter raw-param as raw no-undo.
def input parameter table for tt-raw-digita.

DEF VAR c-calc-fim     AS DEC  FORMAT "->>,>>>,>>9.99" NO-UNDO.
DEF VAR c-calc-ctbl    AS DEC  FORMAT "->>,>>>,>>9.99" NO-UNDO.
DEF VAR c-valor-ini    AS DEC  FORMAT "->>,>>>,>>9.99" NO-UNDO.
DEF VAR c-dia          AS INT  NO-UNDO.
DEF VAR c-ultimo-dia   AS INT  NO-UNDO.
DEF VAR c-data-ini     AS DATE NO-UNDO.
DEF VAR c-data-fim     AS DATE NO-UNDO.
DEF VAR c-data-entrada AS DATE NO-UNDO.

def var h-acomp     AS handle no-undo.
DEF VAR DATANOVA    AS CHAR FORMAT "X(10)".

def temp-table tt-param no-undo
    field rs-execucao      as int
    field destino          as integer
    field arquivo          as char format "x(35)"
    field usuario          as char format "x(12)"
    field data-exec        as date  FORMAT "99/99/9999"
    field hora-exec        as integer
    FIELD lot-i            AS INT
    FIELD lot-f            AS INT
    FIELD est-i            AS CHAR FORMAT "x(3)"
    FIELD est-f            AS CHAR FORMAT "x(3)"
    FIELD neg-i            AS CHAR FORMAT "x(3)"
    FIELD neg-f            AS CHAR FORMAT "x(3)"
    FIELD mod-i            AS CHAR FORMAT "x(3)"
    FIELD mod-f            AS CHAR FORMAT "x(3)"
    FIELD cta-i            AS CHAR FORMAT "x(20)"
    FIELD cta-f            AS CHAR FORMAT "x(20)"

    FIELD ccusto-i         AS CHAR FORMAT "x(20)"
    FIELD ccusto-f         AS CHAR FORMAT "x(20)"

    FIELD per-i            AS DATE FORMAT "99/99/9999"
    FIELD per-f            AS DATE FORMAT "99/99/9999"
    field arquivo-saida    AS CHAR
    FIELD cod-plano        AS CHAR FORMAT "x(8)"
    FIELD cod-cenar        AS CHAR FORMAT "x(8)"
    FIELD imp-ctpart       AS LOG INIT YES
    FIELD con-ct-int       AS LOG INIT NO
    FIELD con-res          AS LOG INIT NO
    FIELD fin-base         AS CHAR FORMAT "x(8)"
    FIELD fin-conv         AS CHAR FORMAT "x(8)"
    FIELD dt-cot           AS DATE FORMAT "99/99/9999"
    FIELD i-forma          AS INT
    FIELD l-param          AS LOG
    FIELD rs-cep           AS INT.

create tt-param.
raw-transfer raw-param to tt-param.

    ASSIGN tt-param.i-forma  = 1.

find param-global no-lock no-error.

/*********************************************************************/
def new global shared var v_cod_usuar_corren    as character format "x(12)":U label "Usuˇrio Corrente" column-label "Usuˇrio Corrente" no-undo.
def new global shared var v_cod_empres_usuar    as character format "x(3)":U label "Empresa" column-label "Empresa" no-undo.
def new global shared var v_hdl_func_padr_glob  as HANDLE format ">>>>>>9":U label "Funá‰es Pad Glob" column-label "Funá‰es Pad Glob" no-undo.

def new global shared var c-dir-spool-servid-exec as char no-undo.
def new global shared var i-num-ped-exec-rpw      as int  no-undo.

/*********************************************************************/
if not valid-handle(v_hdl_func_padr_glob) then run prgint/utb/utb925za.py persistent set v_hdl_func_padr_glob no-error.
function FnAjustDec returns dec (p_val_movto as decimal, p_cod_moed_finalid as character) in v_hdl_func_padr_glob.

/*********************************************************************/
DEF VAR i-ct                   AS INT INIT 0 NO-UNDO.
DEF VAR c-arq-rel              AS CHAR FORMAT "x(80)" NO-UNDO.
DEF VAR c-arq-txt              AS CHAR FORMAT "x(80)" NO-UNDO.

def var c-histor               as char no-undo.
def var c-hst                  as char no-undo.
DEF VAR idx                    AS INTEGER INIT 0.
/*********************************************************************/

    DEF VARIABLE chExcelApplication  AS COM-HANDLE.
    DEF VARIABLE chWorkbook          AS COM-HANDLE.
    DEF VARIABLE chWorksheet         AS COM-HANDLE.

DEF VAR i-linha                  AS INT INIT 1 NO-UNDO.
DEF VAR i-coluna                 AS INT INIT 1 NO-UNDO.
DEF VAR i-plan                   AS INT INIT 1 NO-UNDO.

/*********************************************************************/
DEF VAR v_val_lancto_ctbl               LIKE aprop_lancto_ctbl.val_lancto_ctbl INIT 0 NO-UNDO.                                                          
DEF VAR v_cod_espec_docto                 AS CHAR FORMAT "x(3)" NO-UNDO.                                                                              
def var c-narrativa                       as char no-undo.                                                                                            
def var c-emitente                        as char no-undo.                                                                                            
def var v_val_cotac_indic_econ            as DECIMAL format "->>,>>>,>>>,>>9.9999999999":U decimals 10 label "Cotaá∆o" column-label "Cotaá∆o" no-undo.
def var v_val_current_value               as DECIMAL format "->>,>>>,>>>,>>9.99":U decimals 2 no-undo.                                                
def var v_cod_indic_econ_base             as CHARACTER format "x(8)":U label "Moeda Base" column-label "Moeda Base" no-undo.                          
def var v_cod_indic_econ_apres            as character no-undo.                                                                                       
def var v_cod_return                      as CHARACTER format "x(40)":U no-undo.                                                                      
def var v_cod_moed_finalid                as CHARACTER format "x(10)":U label "Moeda/Finalidade"  column-label "Mo/Finalid" no-undo.                  
def var v_log_funcao_armaz_val_finalid    as LOGICAL format "Sim/N∆o" initial NO no-undo.
def var v_val_aprop_ctbl                  as DECIMAL format "->>>,>>>,>>9.99":U decimals 2 label "Valor Aprop Ctbl" column-label "Vl Aprop Ctbl" no-undo.
def new shared var v_val_sdo_ctbl_fim     as DECIMAL format "->>,>>>,>>>,>>9.99":U decimals 2 label "Saldo Final" column-label "Saldo Final" no-undo.
def new shared var v_val_sdo_ctbl_inic_ant   as DECIMAL format "->>,>>>,>>>,>>9.99":U decimals 2 label "Sdo Inicial Ant" column-label "Sdo Inicial Ant" no-undo.
def new shared var v_val_sdo_ctbl_cr    as DECIMAL format "->>,>>>,>>>,>>9.99":U decimals 2 label "CrÇditos" column-label "CrÇditos" no-undo.
def new shared var v_val_sdo_ctbl_db    as DECIMAL format "->>,>>>,>>>,>>9.99":U decimals 2 label "DÇbitos" column-label "DÇbitos" no-undo.  

def new global shared var v_log_cta_restdo_acum as LOGICAL format "Sim/N∆o" initial NO no-undo. 
def new global shared var v_cod_cenar_ctbl_ini  as CHARACTER format "x(8)":U label "Inicial" column-label "Inicial" no-undo.
def new global shared var v_cod_finalid_econ_ini    as CHARACTER format "x(10)":U label "Inicial" column-label "Inicial" no-undo.
def new global shared var v_cod_unid_organ      as CHARACTER format "x(3)":U no-undo.
def new global shared var v_log_consid_apurac_restdo    as LOGICAL format "Sim/N∆o" initial yes view-as TOGGLE-BOX label "Consid Apurac Restdo" column-label "Apurac Restdo" no-undo.
def new shared var v_dat_inic_period_ctbl_pri   as DATE format "99/99/9999":U label "In°cio Per°odo" column-label "In°cio Per°odo" no-undo.                     
def var v_log_restric_estab as LOGICAL format "Sim/N∆o" initial NO view-as TOGGLE-BOX label "Usa Segur Estab" column-label "Usa Segur Estab" no-undo.
def new global shared var v_log_estab_unid_negoc as LOGICAL format "Sim/N∆o" initial NO view-as TOGGLE-BOX label "Inclui Unid Neg¢cio" column-label "Inclui Unid Neg¢cio" no-undo.

def var v_cdn_quant_db          as INTEGER      format ">>>,>>9":U no-undo.
def var v_cdn_quant_cr          as INTEGER      format ">>>,>>9":U no-undo.
def var v_cod_cta_ctbl_contra   as CHARACTER    format "x(20)":U    label "Contra Partida" column-label "Contra Partida" no-undo.

DEF BUFFER  bf-item_lancto_ctbl FOR item_lancto_ctbl.
DEF VAR     c-db-cr LIKE item_lancto_ctbl.ind_natur_lancto_ctbl.

/*********************************************************************/
def new global shared temp-table tt_aprop_lancto_ctbl_aux2 no-undo
    field tta_ind_natur_lancto_ctbl        as character format "X(02)" initial "DB" label "Natureza" column-label "Natureza"
    field tta_cod_plano_cta_ctbl           as character format "x(8)" label "Plano Contas" column-label "Plano Contas"
    field tta_cod_cta_ctbl                 as character format "x(20)" label "Conta Contòbil" column-label "Conta Contòbil"
    field tta_des_tit_ctbl                 as character format "x(40)" label "Ttulo Contòbil" column-label "Ttulo Contòbil"
    field tta_cod_plano_ccusto             as character format "x(8)" label "Plano Centros Custo" column-label "Plano Centros Custo"
    field tta_cod_ccusto                   as Character format "x(11)" label "Centro Custo" column-label "Centro Custo"
    field tta_cod_unid_negoc               as character format "x(3)" label "Unid Neg´cio" column-label "Un Neg"
    field tta_val_aprop                    as decimal   format "->>,>>>,>>>,>>9.99" decimals 2 initial 0 label "Apropriado" column-label "Apropriado"
    field ttv_des_chave_lancto             as character format "x(200)"
    index tt_id                            is primary
          ttv_des_chave_lancto             ascending.

def temp-table tt_rpt_razao no-undo
    field tta_cod_ccusto                   as Character format "x(11)" label "Centro Custo" column-label "Centro Custo"
    field tta_cod_plano_cta_ctbl           as character format "x(8)" label "Plano Contas" column-label "Plano Contas"
    field tta_cod_cta_ctbl                 as character format "x(20)" label "Conta Cont†bil" column-label "Conta Cont†bil"
    field tta_num_lote_ctbl                as integer   format ">>>,>>>,>>9" initial 1 label "Lote Cont†bil" column-label "Lote Cont†bil"
    field tta_num_lancto_ctbl              as integer   format ">>,>>>,>>9" initial 10 label "Lanáamento Cont†bil" column-label "Lanáamento Cont†bil"
    field tta_num_seq_lancto_ctbl          as integer   format ">>>>9" initial 0 label "Sequància Lanáto" column-label "Sequància Lanáto"
    field tta_num_seq_lancto_ctbl_cpart    as integer   format ">>>9" initial 0 label "Sequància CPartida" column-label "Sequància CP"
    field tta_cod_modul_dtsul              as character format "x(3)" label "M¢dulo" column-label "M¢dulo"
    field tta_cod_estab                    as character format "x(3)" label "Estabelecimento" column-label "Estab"
    field tta_cod_unid_negoc               as character format "x(3)" label "Unid Neg¢cio" column-label "Un Neg"
    field tta_dat_lancto_ctbl              as date      format "99/99/9999" initial ? label "Data Lanáamento" column-label "Data Lanáto"
    field ttv_val_lancto_ctbl_db           as decimal   format ">>>>>,>>>,>>9.99" decimals 2 initial 0 label "Movto DÇbito" column-label "Movto DÇbito"
    field ttv_val_lancto_ctbl_cr           as decimal   format ">>>>>,>>>,>>9.99" decimals 2 initial 0 label "Movto CrÇdito" column-label "Movto CrÇdito"
    field tta_val_sdo_ctbl_fim             as decimal   format "->>,>>>,>>>,>>9.99" decimals 2 initial 0 label "Saldo Cont†bil Final" column-label "Saldo Cont†bil Final"
    field tta_des_histor_lancto_ctbl       as character format "x(2000)" label "Hist¢rico Cont†bil" column-label "Hist¢rico Cont†bil"
    field tta_des_tit_ctbl                 as character format "x(40)" label "T°tulo Cont†bil" column-label "T°tulo Cont†bil"
    field tta_cod_cta_ctbl_padr_internac   as character format "x(30)" label "Padr∆o Internacional" column-label "Padr∆o Internac"
    field tta_cod_emitente                 as int       format ">>>>>>>>9" label "Emitente" column-label "Emitente"
    field tta_cod_espec_docto              as char      format "x(3)" label "Especie" column-label "Esp"
    field tta_cod_ser_docto                as char      format "x(3)" label "Serie" column-label "Serie"
    field tta_nro_docto                    as char      format "x(10)" label "Docto" column-label "Docto"
    field tta_cod_parcela                  as char      format "x(2)" label "Parcela" column-label "/P"
    FIELD tta_cod_usuario                  like lote_ctbl.cod_usuar_ult_atualiz
    field tta_dat_emissao                    as date    format "99/99/9999" initial ? label "Data Emiss∆o" column-label "Data Emiss∆o"
	FIELD tta_v_val_sdo_ctbl_ini           as decimal   format ">>>>>,>>>,>>9.99"
	FIELD tta_v_val_sdo_ctbl_fim           as decimal   format ">>>>>,>>>,>>9.99"
	field ttv_val_lancto_ctbl_contra       as decimal   format ">>>>>,>>>,>>9.99" decimals 2 initial 0 label "Movto Contra" column-label "Movto Contra"
        
    FIELD tta_cod_cta_ctbl_contra          as CHARACTER format "x(20)"
    FIELD cod_cta_ctbl_contra_Lancto       as CHARACTER format "x(20)"
    FIELD des_tit_ctbl_Contra              as character format "x(40)" column-label "Contra Cont†bil"
	FIELD tta_nome-emit                    LIKE emitente.nome-emit
    FIELD Seq-Excel                        AS INTEGER
    FIELD ge-codigo                        LIKE ITEM.ge-codigo
    FIELD it-codigo                        LIKE ITEM.it-codigo
    index tt_rpt_razao                     is primary 
          tta_num_lote_ctbl                ascending
          tta_num_lancto_ctbl              ascending
          tta_num_seq_lancto_ctbl          ASCENDING.

DEF TEMP-TABLE t_tt_rpt_razao   LIKE tt_rpt_razao.
DEF TEMP-TABLE tt_rpt_razao_cep LIKE tt_rpt_razao.

def temp-table tt_relac_aprop_lancto_ctbl_apl no-undo
    field tta_ind_tip_trans_apl            as character format "X(20)" initial "Aplicacao" label "Tipo Transacao" column-label "Tipo Transacao"
    field tta_dat_transacao                as date format "99/99/9999" initial today label "Data Transacao" column-label "Dat Transac"
    field tta_cod_banco                    as character format "x(8)" label "Banco" column-label "Banco"
    field tta_cod_produt_financ            as character format "x(8)" label "Produto Financeiro" column-label "Produto Financeiro"
    field tta_cod_operac_financ            as character format "x(10)" label "Operacao Financeira" column-label "Operacao Financeira"
    field tta_val_aprop_ctbl               as decimal format "->>>,>>>,>>9.99" decimals 2 initial 0 label "Valor Aprop Ctbl" column-label "Vl Aprop Ctbl"
    field ttv_rec_movto_operac_financ      as recid format ">>>>>>9" initial ?.

DEF TEMP-TABLE tt-movto-ctbl-ce NO-UNDO
    FIELD ep-codigo             AS CHAR
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
    FIELD unidade               as char
    FIELD qtde                  as dec
    FIELD numero-ordem          as int
    FIELD num-pedido            as int
    FIELD mo-codigo             as int
    FIELD cod-cta               as char format "x(20)"
    FIELD cod-ccusto            as char format "x(20)"

    field ttv_val_lancto_ctbl_contra       as decimal format ">>>>>,>>>,>>9.99" decimals 2 initial 0 label "Movto Contra" column-label "Movto Contra"
    FIELD tta_cod_cta_ctbl_contra          as CHARACTER    format "x(20)"

    INDEX num-id                IS PRIMARY
          num-id-movto-ctbl-ce  ASCENDING.    

def temp-table tt-movto-ctbl-ft no-undo
    field ep-codigo             LIKE param-globa.empresa-prin
    field num-seq-movto-ctbl 	as integer
    field num-id-movto-ctbl  	as integer
    field cod-estabel           as character
    field nro-docto             as character
    field cod-emitente          as integer
    field serie-docto           as character
    field nat-operacao          as char
    field referencia           	as character
    field sequencia             as integer
    field ge-codigo             as integer
    field conta-contabil        as character
    field dt-trans              as DATE FORMAT "99/99/9999"
    field cod-depos             as character
    field esp-docto             as integer
    field transacao             as integer
    field historico             as character
    field valor-cont            as decimal
    field vl-cont-fasb          as decimal extent 2
    field char-1                as character
    field char-2                as character
    field dec-1                 as decimal
    field dec-2                 as decimal
    field int-1                 as integer
    field int-2                 as integer
    field log-1                 as logical
    field log-2                 as logical
    field data-1                as DATE FORMAT "99/99/9999"
    field data-2                as DATE FORMAT "99/99/9999"
    field check-sum             as character
    field cod-unid-negoc        as character format "x(3)"
    FIELD cod_cta_ctbl_contra   as CHARACTER format "x(20)"
    FIELD val_lancto_ctbl_contra AS DECIMAL format "->>,>>>,>>>,>>9.99" decimals 2 initial 0 
/*     FIELD IT-CODIGO             LIKE ITEM.it-codigo  */
    index num-id                is primary
          num-id-movto-ctbl     ascending.

def temp-table tt_erro_relatorio_razao no-undo
    field tta_num_lote_ctbl                as integer format ">>>,>>>,>>9" initial 1 label "Lote Cont†bil" column-label "Lote Cont†bil"
    field tta_num_lancto_ctbl              as integer format ">>,>>>,>>9" initial 10 label "Lanáamento Cont†bil" column-label "Lanáamento Cont†bil"
    field tta_num_seq_lancto_ctbl          as integer format ">>>>9" initial 0 label "Sequància Lanáto" column-label "Sequància Lanáto"
    field ttv_des_ajuda                    as character format "x(50)" label "Ajuda" column-label "Ajuda"
    index tt_                              is primary
          tta_num_lote_ctbl                ascending
          tta_num_lancto_ctbl              ascending
          tta_num_seq_lancto_ctbl          ascending.

def new shared temp-table tt_sdo_ctbl        
    field tta_dat_sdo_ctbl                 as date format "99/99/9999" initial ? label "Data Saldo Cont†bil" column-label "Data Saldo Cont†bil"
    field tta_val_sdo_ctbl_db              as decimal format "->>,>>>,>>>,>>9.99" decimals 2 initial 0 label "Movto Debito" column-label "Movto DÇbito"
    field tta_val_sdo_ctbl_cr              as decimal format "->>,>>>,>>>,>>9.99" decimals 2 initial 0 label "Movto Credito" column-label "Movto CrÇdito"
    field tta_val_sdo_ctbl_fim             as decimal format "->>,>>>,>>>,>>9.99" decimals 2 initial 0 label "Saldo Cont†bil Final" column-label "Saldo Cont†bil Final"
    index tt_id                            is primary unique
          tta_dat_sdo_ctbl                 ascending.
          

def new shared temp-table tt_estab_unid_negoc_select         like estab_unid_negoc
    index tt_estab_unid_negoc_select_id    is primary unique
          cod_estab                        ascending
          cod_unid_negoc                   ascending.


def new shared temp-table tt_unid_organ    like emscad.unid_organ
    field ttv_rec_unid_organ               as recid format ">>>>>>9" initial ?
    .

def new shared temp-table tt_unid_negoc    like emscad.unid_negoc
    field ttv_rec_unid_negoc               as recid format ">>>>>>9" initial ?
    .

EMPTY TEMP-TABLE tt_rpt_razao NO-ERROR.
EMPTY TEMP-TABLE tt-movto-ctbl-ce NO-ERROR.
EMPTY TEMP-TABLE tt-movto-ctbl-ft NO-ERROR.
EMPTY TEMP-TABLE tt_rpt_razao NO-ERROR.
EMPTY TEMP-TABLE tt_relac_aprop_lancto_ctbl_apl NO-ERROR.

/*********************************************************************/
{include/i-rpvar.i}

assign c-titulo-relat = "Relat¢rio Raz∆o Contabil"
       c-sistema      = "FGL"
       c-programa     = "ESFGL0001X" 
       c-empresa      = (if avail param-global then param-global.grupo else "").

/*********************************************************************/
run utp/ut-acomp.p persistent set h-acomp.
run pi-inicializar in h-acomp (input "Processando").

/*********************************************************************/
/* --- Criaá∆o dos unid_organ_usuar ---*/
RUN pi_criar_unid_organ_usuar.
/* --- Criaá∆o dos tt_unid_negoc ---*/
run pi_criar_unid_negoc_faixa /*pi_criar_unid_negoc_faixa*/.
/* --- Criaá∆o dos tt_estab_unid_negoc ---*/
run pi_criar_tt_estab_unid_negoc_select.

ASSIGN c-arq-txt  = tt-param.arquivo-saida + 
                    "ESFGL0001X" + "_" + 
                    STRING(YEAR(TODAY),"9999") +            
                    STRING(MONTH(TODAY),"99") +             
                    STRING(DAY(TODAY),"99") +               
                    "_" +                                   
                    REPLACE(STRING(TIME,"hh:mm:ss"),":","")
                    + ".CSV".

if i-num-ped-exec-rpw <> 0 then
   assign tt-param.arquivo-saida = c-dir-spool-servid-exec + "~/".

ASSIGN c-arq-rel  = tt-param.arquivo-saida + 
                    "ESFGL0001X" + "_" + 
                    STRING(YEAR(TODAY),"9999") +            
                    STRING(MONTH(TODAY),"99") +             
                    STRING(DAY(TODAY),"99") +               
                    "_" +                                   
                    REPLACE(STRING(TIME,"hh:mm:ss"),":","").

IF tt-param.i-forma = 1 THEN
   ASSIGN c-arq-rel = c-arq-rel + ".xlsx".
/* ELSE IF tt-param.i-forma = 2 THEN               */
/*         ASSIGN c-arq-rel = c-arq-rel + ".pdf".  */
/*      ELSE                                       */
/*         ASSIGN c-arq-rel = c-arq-rel + ".csv".  */
       
/*********************************************************************/
run pi_retornar_indic_econ_finalid (Input tt-param.fin-base,          
                                    Input tt-param.dt-cot,            
                                    output v_cod_indic_econ_base).    
if tt-param.fin-base <> tt-param.fin-conv then                        
do:                                                                   
   run pi_retornar_indic_econ_finalid (Input tt-param.fin-conv,       
                                       Input tt-param.dt-cot,         
                                       output v_cod_indic_econ_apres).
                                                                      
   run pi_achar_cotac_indic_econ (Input v_cod_indic_econ_base,        
                                  Input v_cod_indic_econ_apres,       
                                  Input tt-param.dt-cot,              
                                  Input "Real",                       
                                  output tt-param.dt-cot,             
                                  output v_val_cotac_indic_econ,      
                                  output v_cod_return).               
end.                                                                  
else do:                                                              
    assign v_val_cotac_indic_econ = 1.                                
end.                           

ASSIGN v_cod_moed_finalid = tt-param.fin-conv.

/*********************************************************************/
&if defined(BF_FIN_ARMAZENAR_VALOR_FINALID) &then
    assign v_log_funcao_armaz_val_finalid = yes.
&else
    find first histor_exec_especial no-lock
        where histor_exec_especial.cod_modul_dtsul = "UFN" /*l_ufn*/  
        and histor_exec_especial.cod_prog_dtsul  = "spp_" /*l_spp*/  + 'armazenar_valor_finalid' no-error.
    if  avail histor_exec_especial then
        assign v_log_funcao_armaz_val_finalid = yes.
&endif

/*********************************************************************/
/*v_cod_empres_usuar */

RUN pi-acompanhar IN h-acomp ("Gerando Arquivo").   

                                                                                                                                             
            FOR EACH /*item_lancto_ctbl OF lancto_ctbl NO-LOCK                                                                                 */
                      item_lancto_ctbl NO-LOCK USE-INDEX tmlnctcb_data_lancto
                WHERE item_lancto_ctbl.cod_empresa         = v_cod_empres_usuar         AND  
                      item_lancto_ctbl.dat_lancto_ctbl    >= tt-param.per-i             AND
                      item_lancto_ctbl.dat_lancto_ctbl    <= tt-param.per-f             AND

                      item_lancto_ctbl.num_lote_ctbl      >= tt-param.lot-i             AND
                      item_lancto_ctbl.num_lote_ctbl      <= tt-param.lot-f             AND

                      item_lancto_ctbl.ind_sit_lancto_Ctbl = "Ctbz"                     AND
                      item_lancto_ctbl.cod_plano_cta_ctbl  = tt-param.cod-plano         AND 

                      item_lancto_ctbl.cod_cta_ctbl       >= tt-param.cta-i             AND                                                              
                      item_lancto_ctbl.cod_cta_ctbl       <= tt-param.cta-f             ,

                EACH  tt_estab_unid_negoc_select NO-LOCK WHERE
                      tt_estab_unid_negoc_select.cod_estab      = item_lancto_ctbl.cod_estab       AND
                      tt_estab_unid_negoc_select.cod_unid_negoc = item_lancto_ctbl.cod_unid_negoc  ,

                FIRST lancto_ctbl NO-LOCK OF item_lancto_ctbl WHERE
                      lancto_ctbl.cod_modul_dtsul     >= tt-param.mod-i     AND 
                      lancto_ctbl.cod_modul_dtsul     <= tt-param.mod-f,

                first lote_ctbl of lancto_ctbl:

                RUN pi-acompanhar IN h-acomp ("Item_Lancto_Ctbl "                           + 
                                       STRING(lancto_ctbl.cod_modul_dtsul)                  + " " +
                                       STRING(item_lancto_ctbl.num_lote_ctbl)               + " " +
                                       STRING(item_lancto_ctbl.num_lancto_ctbl)             + " " +
                                       STRING(item_lancto_ctbl.num_seq_lancto_ctbl)         + " " +
                                       STRING(item_lancto_ctbl.dat_lancto_ctbl,"99/99/9999")+ " " +
                                       string(item_lancto_ctbl.log_lancto_apurac_restdo)).

                IF item_lancto_ctbl.log_lancto_apurac_restdo = YES AND
                   tt-param.con-res = NO THEN
                   NEXT.
                
                   ASSIGN c-narrativa = item_lancto_ctbl.des_histor_lancto_ctbl.

                FIND cta_ctbl OF item_lancto_ctbl NO-LOCK NO-ERROR.          

                FIND FIRST aprop_lancto_ctbl                                                 
                   WHERE aprop_lancto_ctbl.num_lote_ctbl       = item_lancto_ctbl.num_lote_ctbl      
                     AND aprop_lancto_ctbl.num_lancto_ctbl     = item_lancto_ctbl.num_lancto_ctbl    
                     AND aprop_lancto_ctbl.num_seq_lancto_ctbl = item_lancto_ctbl.num_seq_lancto_ctbl
                     AND aprop_lancto_ctbl.cod_finalid_econ    = tt-param.fin-base NO-LOCK NO-ERROR.   

                IF AVAIL aprop_lancto_ctbl THEN                                                      
                DO: 

                   case lancto_ctbl.cod_modul_dtsul:                                     
                      when "FAS" then do:                                               
                          /* n∆o possui dados de origem a origem Ç o proprio lancto */ 
                          CREATE tt_rpt_razao.                                                                                                  
                          ASSIGN tt_rpt_razao.tta_cod_ccusto                 = item_lancto_ctbl.cod_ccusto
                                 tt_rpt_razao.tta_num_lote_ctbl              = item_lancto_ctbl.num_lote_ctbl                                   
                                 tt_rpt_razao.tta_num_lancto_ctbl            = item_lancto_ctbl.num_lancto_ctbl                                 
                                 tt_rpt_razao.tta_num_seq_lancto_ctbl        = item_lancto_ctbl.num_seq_lancto_ctbl                             
                                 tt_rpt_razao.tta_num_seq_lancto_ctbl_cpart  = item_lancto_ctbl.num_seq_lancto_ctbl_cpart                       
                                 tt_rpt_razao.tta_cod_modul_dtsul            = lancto_ctbl.cod_modul_dtsul                                      
                                 tt_rpt_razao.tta_cod_plano_cta_ctbl         = item_lancto_ctbl.cod_plano_cta_ctbl                              
                                 tt_rpt_razao.tta_cod_cta_ctbl               = item_lancto_ctbl.cod_cta_ctbl                                    
                                 tt_rpt_razao.tta_cod_estab                  = item_lancto_ctbl.cod_estab                                       
                                 tt_rpt_razao.tta_cod_unid_negoc             = item_lancto_ctbl.cod_unid_negoc                                  
                                 tt_rpt_razao.tta_dat_lancto_ctbl            = item_lancto_ctbl.dat_lancto_ctbl                                 
                                 tt_rpt_razao.tta_des_histor_lancto_ctbl     = item_lancto_ctbl.des_histor_lancto_ctbl                          
                                 tt_rpt_razao.tta_cod_cta_ctbl_padr_internac = cta_ctbl.cod_cta_ctbl_padr_internac                              
                                 tt_rpt_razao.tta_des_tit_ctbl               = cta_ctbl.des_tit_ctbl.                                           

                          ASSIGN v_val_lancto_ctbl = fnAjustDec(item_lancto_ctbl.val_lancto_ctbl / v_val_cotac_indic_econ, v_cod_moed_finalid). 

                          If v_val_lancto_ctbl = ? THEN                                                                                         
                             ASSIGN v_val_lancto_ctbl = 0.                                                                                      

                          IF item_lancto_ctbl.ind_natur_lancto_ctbl = "DB" THEN                                                                 
                             ASSIGN tt_rpt_razao.ttv_val_lancto_ctbl_db = ABS(v_val_lancto_ctbl).                                                    
                          ELSE                                                                                                                  
                             ASSIGN tt_rpt_razao.ttv_val_lancto_ctbl_cr = ABS(v_val_lancto_ctbl).   

                             RUN Pi-Contra-Partida-Lancto.

                      end.       
                      when "FGL" then do:                                               
                          /* nao possui dados de origem a origem e o proprio lancto */ 
                          CREATE tt_rpt_razao.                                                                                                  
                          ASSIGN tt_rpt_razao.tta_cod_ccusto                 = item_lancto_ctbl.cod_ccusto
                                 tt_rpt_razao.tta_num_lote_ctbl              = item_lancto_ctbl.num_lote_ctbl                                   
                                 tt_rpt_razao.tta_num_lancto_ctbl            = item_lancto_ctbl.num_lancto_ctbl                                 
                                 tt_rpt_razao.tta_num_seq_lancto_ctbl        = item_lancto_ctbl.num_seq_lancto_ctbl                             
                                 tt_rpt_razao.tta_num_seq_lancto_ctbl_cpart  = item_lancto_ctbl.num_seq_lancto_ctbl_cpart                       
                                 tt_rpt_razao.tta_cod_modul_dtsul            = lancto_ctbl.cod_modul_dtsul                                      
                                 tt_rpt_razao.tta_cod_plano_cta_ctbl         = item_lancto_ctbl.cod_plano_cta_ctbl                              
                                 tt_rpt_razao.tta_cod_cta_ctbl               = item_lancto_ctbl.cod_cta_ctbl                                    
                                 tt_rpt_razao.tta_cod_estab                  = item_lancto_ctbl.cod_estab                                       
                                 tt_rpt_razao.tta_cod_unid_negoc             = item_lancto_ctbl.cod_unid_negoc                                  
                                 tt_rpt_razao.tta_dat_lancto_ctbl            = item_lancto_ctbl.dat_lancto_ctbl                                 
                                 tt_rpt_razao.tta_des_histor_lancto_ctbl     = item_lancto_ctbl.des_histor_lancto_ctbl                          
                                 tt_rpt_razao.tta_cod_cta_ctbl_padr_internac = cta_ctbl.cod_cta_ctbl_padr_internac                              
                                 tt_rpt_razao.tta_des_tit_ctbl               = cta_ctbl.des_tit_ctbl
                                 tt_rpt_razao.tta_cod_usuario                = lote_ctbl.cod_usuar_ult_atualiz.                                           

                          ASSIGN v_val_lancto_ctbl = fnAjustDec(item_lancto_ctbl.val_lancto_ctbl / v_val_cotac_indic_econ, v_cod_moed_finalid). 

                          If v_val_lancto_ctbl = ? THEN                                                                                         
                             ASSIGN v_val_lancto_ctbl = 0.                                                                                      

                          IF item_lancto_ctbl.ind_natur_lancto_ctbl = "DB" THEN                                                                 
                             ASSIGN tt_rpt_razao.ttv_val_lancto_ctbl_db = ABS(v_val_lancto_ctbl).                                                    
                          ELSE                                                                                                                  
                             ASSIGN tt_rpt_razao.ttv_val_lancto_ctbl_cr = ABS(v_val_lancto_ctbl).   
							 
						  ASSIGN tt_rpt_razao.ttv_val_lancto_ctbl_contra = (tt_rpt_razao.ttv_val_lancto_ctbl_db - tt_rpt_razao.ttv_val_lancto_ctbl_cr).
						  						  
                             RUN Pi-Contra-Partida-Lancto.

                      end.                                                             
                      when "CMG" then do:                                               
                          /* n∆o possui dados de origem a origem Ç o proprio lancto */ 
                          CREATE tt_rpt_razao.                                                                                                  
                          ASSIGN tt_rpt_razao.tta_cod_ccusto                 = item_lancto_ctbl.cod_ccusto
                                 tt_rpt_razao.tta_num_lote_ctbl              = item_lancto_ctbl.num_lote_ctbl                                   
                                 tt_rpt_razao.tta_num_lancto_ctbl            = item_lancto_ctbl.num_lancto_ctbl                                 
                                 tt_rpt_razao.tta_num_seq_lancto_ctbl        = item_lancto_ctbl.num_seq_lancto_ctbl                             
                                 tt_rpt_razao.tta_num_seq_lancto_ctbl_cpart  = item_lancto_ctbl.num_seq_lancto_ctbl_cpart                       
                                 tt_rpt_razao.tta_cod_modul_dtsul            = lancto_ctbl.cod_modul_dtsul                                      
                                 tt_rpt_razao.tta_cod_plano_cta_ctbl         = item_lancto_ctbl.cod_plano_cta_ctbl                              
                                 tt_rpt_razao.tta_cod_cta_ctbl               = item_lancto_ctbl.cod_cta_ctbl                                    
                                 tt_rpt_razao.tta_cod_estab                  = item_lancto_ctbl.cod_estab                                       
                                 tt_rpt_razao.tta_cod_unid_negoc             = item_lancto_ctbl.cod_unid_negoc                                  
                                 tt_rpt_razao.tta_dat_lancto_ctbl            = item_lancto_ctbl.dat_lancto_ctbl                                 
                                 tt_rpt_razao.tta_des_histor_lancto_ctbl     = item_lancto_ctbl.des_histor_lancto_ctbl                          
                                 tt_rpt_razao.tta_cod_cta_ctbl_padr_internac = cta_ctbl.cod_cta_ctbl_padr_internac                              
                                 tt_rpt_razao.tta_des_tit_ctbl               = cta_ctbl.des_tit_ctbl.                                           

                          ASSIGN v_val_lancto_ctbl = fnAjustDec(item_lancto_ctbl.val_lancto_ctbl / v_val_cotac_indic_econ, v_cod_moed_finalid). 

                          If v_val_lancto_ctbl = ? THEN                                                                                         
                             ASSIGN v_val_lancto_ctbl = 0.                                                                                      

                          IF item_lancto_ctbl.ind_natur_lancto_ctbl = "DB" THEN                                                                 
                             ASSIGN tt_rpt_razao.ttv_val_lancto_ctbl_db = ABS(v_val_lancto_ctbl).                                                    
                          ELSE                                                                                                                  
                             ASSIGN tt_rpt_razao.ttv_val_lancto_ctbl_cr = ABS(v_val_lancto_ctbl).   

                             RUN Pi-Contra-Partida-Lancto.

                      end.                                                             
                      when "APB" then do:                                               
                          run pi_gera_tt_relacto_aprop_lancto_ctbl_apb.                
                      end.                                                             
                      when "ACR" then do:                                               
                          run pi_gera_tt_relacto_aprop_lancto_ctbl_acr.                
                      end.                                                              
                      when "APL" then do:                                               
                         run pi_gera_tt_relacto_aprop_lancto_ctbl_apl.                  
                      end.                                                             
                      when "CEP" then do:                                               
                         run pi_gera_tt_movto_ctbl_ce.                                  
                      end.                                                             
                      when "FTP" then do:                                               
                         run pi_gera_tt_movto_ctbl_ft.                                  
                      end.                                                              
                   end.
                END.  /* IF AVAIL aprop_lancto_ctbl THEN */
                ELSE DO:

/*                     MESSAGE "N∆o Encontrado Apropriaá∆o..."        */
/*                         VIEW-AS ALERT-BOX INFORMATION BUTTONS OK.  */

                   CREATE tt_rpt_razao.                                                                           
                   ASSIGN tt_rpt_razao.tta_num_lote_ctbl              = item_lancto_ctbl.num_lote_ctbl            
                          tt_rpt_razao.tta_num_lancto_ctbl            = item_lancto_ctbl.num_lancto_ctbl          
                          tt_rpt_razao.tta_num_seq_lancto_ctbl        = item_lancto_ctbl.num_seq_lancto_ctbl      
                          tt_rpt_razao.tta_num_seq_lancto_ctbl_cpart  = item_lancto_ctbl.num_seq_lancto_ctbl_cpart
                          tt_rpt_razao.tta_cod_modul_dtsul            = lancto_ctbl.cod_modul_dtsul               
                          tt_rpt_razao.tta_cod_plano_cta_ctbl         = item_lancto_ctbl.cod_plano_cta_ctbl       
                          tt_rpt_razao.tta_cod_cta_ctbl               = item_lancto_ctbl.cod_cta_ctbl             
                          tt_rpt_razao.tta_cod_estab                  = item_lancto_ctbl.cod_estab                
                          tt_rpt_razao.tta_cod_unid_negoc             = item_lancto_ctbl.cod_unid_negoc           
                          tt_rpt_razao.tta_dat_lancto_ctbl            = item_lancto_ctbl.dat_lancto_ctbl          
                          tt_rpt_razao.tta_des_histor_lancto_ctbl     = item_lancto_ctbl.des_histor_lancto_ctbl   
                          tt_rpt_razao.tta_cod_cta_ctbl_padr_internac = cta_ctbl.cod_cta_ctbl_padr_internac       
                          tt_rpt_razao.tta_des_tit_ctbl               = cta_ctbl.des_tit_ctbl.                    

                   ASSIGN v_val_lancto_ctbl = fnAjustDec(item_lancto_ctbl.val_lancto_ctbl / v_val_cotac_indic_econ, v_cod_moed_finalid).                                  

                   If v_val_lancto_ctbl = ? THEN                                                                   
                      ASSIGN v_val_lancto_ctbl = 0.                                                               

                   IF item_lancto_ctbl.ind_natur_lancto_ctbl = "DB" THEN 
                      ASSIGN tt_rpt_razao.ttv_val_lancto_ctbl_db = ABS(v_val_lancto_ctbl).                             
                   ELSE                                                                                           
                      ASSIGN tt_rpt_razao.ttv_val_lancto_ctbl_cr = ABS(v_val_lancto_ctbl).    

                      RUN Pi-Contra-Partida-Lancto. 

                END.

            END.   /* FOR EACH item_lancto_ctbl OF lancto_ctbl NO-LOCK */                                                                                                            

/*         END.   /* FOR EACH lancto_ctbl WHERE */  */
        


/*********************************************************************/
/* ASSIGN tt-param.arquivo = c-arq-rel. */


FIND FIRST tt_rpt_razao NO-LOCK NO-ERROR.
IF AVAIL tt_rpt_razao THEN DO:

    RUN Pi_atu_rpt_razao.

/*
    CREATE "excel.application" chExcelApplication.

    IF ERROR-STATUS:ERROR THEN DO:
        MESSAGE "[" ERROR-STATUS:GET-NUMBER(ERROR-STATUS:NUM-MESSAGES) "] - "
                "ê necess†rio que esteja instalado o Microsoft Excel" SKIP
                "que este relat¢rio seja processado, Sera Gerado um Arquivo .CSV no Diretorio de Trabago." VIEW-AS ALERT-BOX ERROR.
                RUN Pi_Gera_Txt.        
    END.
    ELSE DO: 
     
*/
        run pi-inverte-sinal.
        RUN Pi_Gera_TXT.
        RUN Pi_Gera_Planilha.
 /*   END.*/


/* /*         IF v_cod_usuar_corren <> "super" THEN  */  */
/*            RUN Pi_Gera_Planilha.                      */
/* /*         ELSE                 */                    */
/* /*            RUN Pi_Gera_Txt.  */                    */

END.
ELSE DO:
    MESSAGE "N∆o Foram Encontrados Dados Com os Parametros Selecionados..."
        VIEW-AS ALERT-BOX INFO BUTTONS OK.
END.

run pi-finalizar in h-acomp.

return "OK":U.

/** fim do programa */

/********************************************************************************/
PROCEDURE pi_sem_lancto_origem:

    CREATE tt_rpt_razao.                                                                                                  
    ASSIGN tt_rpt_razao.tta_cod_ccusto                 = item_lancto_ctbl.cod_ccusto
           tt_rpt_razao.tta_num_lote_ctbl              = item_lancto_ctbl.num_lote_ctbl                                   
           tt_rpt_razao.tta_num_lancto_ctbl            = item_lancto_ctbl.num_lancto_ctbl                                 
           tt_rpt_razao.tta_num_seq_lancto_ctbl        = item_lancto_ctbl.num_seq_lancto_ctbl                             
           tt_rpt_razao.tta_num_seq_lancto_ctbl_cpart  = item_lancto_ctbl.num_seq_lancto_ctbl_cpart                       
           tt_rpt_razao.tta_cod_modul_dtsul            = lancto_ctbl.cod_modul_dtsul                                      
           tt_rpt_razao.tta_cod_plano_cta_ctbl         = item_lancto_ctbl.cod_plano_cta_ctbl                              
           tt_rpt_razao.tta_cod_cta_ctbl               = item_lancto_ctbl.cod_cta_ctbl                                    
           tt_rpt_razao.tta_cod_estab                  = item_lancto_ctbl.cod_estab                                       
           tt_rpt_razao.tta_cod_unid_negoc             = item_lancto_ctbl.cod_unid_negoc                                  
           tt_rpt_razao.tta_dat_lancto_ctbl            = item_lancto_ctbl.dat_lancto_ctbl                                 
           tt_rpt_razao.tta_des_histor_lancto_ctbl     = item_lancto_ctbl.des_histor_lancto_ctbl                          
           tt_rpt_razao.tta_cod_cta_ctbl_padr_internac = cta_ctbl.cod_cta_ctbl_padr_internac                              
           tt_rpt_razao.tta_des_tit_ctbl               = cta_ctbl.des_tit_ctbl.                                           

    ASSIGN v_val_lancto_ctbl = fnAjustDec(item_lancto_ctbl.val_lancto_ctbl / v_val_cotac_indic_econ, v_cod_moed_finalid). 

    If v_val_lancto_ctbl = ? THEN                                                                                         
       ASSIGN v_val_lancto_ctbl = 0.                                                                                      

    IF item_lancto_ctbl.ind_natur_lancto_ctbl = "DB" THEN                                                                 
       ASSIGN tt_rpt_razao.ttv_val_lancto_ctbl_db = ABS(v_val_lancto_ctbl).                                                    
    ELSE                                                                                                                  
       ASSIGN tt_rpt_razao.ttv_val_lancto_ctbl_cr = ABS(v_val_lancto_ctbl).   
       
       RUN Pi-Contra-Partida-Lancto.

END PROCEDURE.

/********************************************************************************/
PROCEDURE pi_gera_tt_relacto_aprop_lancto_ctbl_apb:
/*     MESSAGE "APB"                                  */
/*         VIEW-AS ALERT-BOX INFORMATION BUTTONS OK.  */

    FIND FIRST val_aprop_ctbl_ap WHERE 
               val_aprop_ctbl_ap.num_id_aprop_lancto_ctbl = aprop_lancto_ctbl.num_id_aprop_lancto_ctbl NO-LOCK NO-ERROR.
    IF AVAIL val_aprop_ctbl_ap THEN
    DO:
       for each val_aprop_ctbl_ap no-lock                                                                                                   
           where val_aprop_ctbl_ap.num_id_aprop_lancto_ctbl = aprop_lancto_ctbl.num_id_aprop_lancto_ctbl:  

               RUN pi-acompanhar IN h-acomp ("Aprop_Ctbl_Ap " + string(aprop_lancto_ctbl.num_id_aprop_lancto_ctbl) + " " +                                                       
                                                                string(val_aprop_ctbl_ap.cod_estab)).                                                  

                                                                                                                                            
           find aprop_ctbl_ap where                                                                                                         
               aprop_ctbl_ap.cod_estab            = val_aprop_ctbl_ap.cod_estab and                                                         
               aprop_ctbl_ap.num_id_aprop_ctbl_ap = val_aprop_ctbl_ap.num_id_aprop_ctbl_ap no-lock no-error.                                
                                                                                                                                            
           find first movto_tit_ap where                                                                                                          
               movto_tit_ap.cod_estab           = aprop_ctbl_ap.cod_estab and                                                               
               movto_tit_ap.num_id_movto_tit_ap = aprop_ctbl_ap.num_id_movto_tit_ap no-lock no-error.                                       

           assign c-histor = ""
                  c-hst    = "". 
 
           for each histor_tit_movto_ap no-lock
              where histor_tit_movto_ap.cod_estab           = movto_tit_ap.cod_estab
                and histor_tit_movto_ap.num_id_tit_ap       = movto_tit_ap.num_id_tit_ap
                and histor_tit_movto_ap.num_id_movto_tit_ap = movto_tit_ap.num_id_movto_tit_ap:

              RUN pi-acompanhar IN h-acomp ("His_Tit_Mov_Ap " + string( histor_tit_movto_ap.num_id_tit_ap) + " " +                                                       
                                                                string(histor_tit_movto_ap.num_id_tit_ap)).                                                  

                
                if histor_tit_movto_ap.ind_orig_histor_ap <> "ERRO" and 
                   histor_tit_movto_ap.des_text_histor <> "" and 
                   histor_tit_movto_ap.des_text_histor <> c-hst then
                   assign c-histor = c-histor + histor_tit_movto_ap.des_text_histor + " "
                          c-hst    = histor_tit_movto_ap.des_text_histor.
                
           end.
                                                                                                                                            
           CREATE tt_rpt_razao.                                                                                                             
           ASSIGN tt_rpt_razao.tta_cod_ccusto                 = item_lancto_ctbl.cod_ccusto
                  tt_rpt_razao.tta_num_lote_ctbl              = item_lancto_ctbl.num_lote_ctbl                                              
                  tt_rpt_razao.tta_num_lancto_ctbl            = item_lancto_ctbl.num_lancto_ctbl                                            
                  tt_rpt_razao.tta_num_seq_lancto_ctbl        = item_lancto_ctbl.num_seq_lancto_ctbl                                        
                  tt_rpt_razao.tta_num_seq_lancto_ctbl_cpart  = item_lancto_ctbl.num_seq_lancto_ctbl_cpart                                  
                  tt_rpt_razao.tta_cod_modul_dtsul            = lancto_ctbl.cod_modul_dtsul                                                 
                  tt_rpt_razao.tta_cod_plano_cta_ctbl         = item_lancto_ctbl.cod_plano_cta_ctbl                                         
                  tt_rpt_razao.tta_cod_cta_ctbl               = item_lancto_ctbl.cod_cta_ctbl                                               
                  tt_rpt_razao.tta_cod_estab                  = item_lancto_ctbl.cod_estab                                                  
                  tt_rpt_razao.tta_cod_unid_negoc             = item_lancto_ctbl.cod_unid_negoc                                             
                  tt_rpt_razao.tta_dat_lancto_ctbl            = item_lancto_ctbl.dat_lancto_ctbl                                            
                  tt_rpt_razao.tta_des_histor_lancto_ctbl     = item_lancto_ctbl.des_histor_lancto_ctbl                                     
                  tt_rpt_razao.tta_cod_cta_ctbl_padr_internac = cta_ctbl.cod_cta_ctbl_padr_internac                                         
                  tt_rpt_razao.tta_des_tit_ctbl               = cta_ctbl.des_tit_ctbl.                                                      
                                                                                                                                            
           ASSIGN v_val_lancto_ctbl = fnAjustDec(val_aprop_ctbl_ap.val_aprop_ctbl / v_val_cotac_indic_econ, v_cod_moed_finalid).            
                                                                                                                                                                                                                                                          
           If v_val_lancto_ctbl = ? THEN                                                                                                    
              ASSIGN v_val_lancto_ctbl = 0.                                                                                                 
                                                                                                                                            
           IF item_lancto_ctbl.ind_natur_lancto_ctbl = "DB" THEN                                                                            
              ASSIGN tt_rpt_razao.ttv_val_lancto_ctbl_db = ABS(v_val_lancto_ctbl).                                                               
           ELSE                                                                                                                             
              ASSIGN tt_rpt_razao.ttv_val_lancto_ctbl_cr = ABS(v_val_lancto_ctbl).                                                               
                  
           if c-histor <> "" and 
              c-histor <> item_lancto_ctbl.des_histor_lancto_ctbl then 
              assign c-narrativa = movto_tit_ap.ind_trans_ap + " - " + /* item_lancto_ctbl.des_histor_lancto_ctbl + " - " + */ c-histor.
           else
              assign c-narrativa = movto_tit_ap.ind_trans_ap + " - " + item_lancto_ctbl.des_histor_lancto_ctbl.
                                                                                                                                            
           ASSIGN tt_rpt_razao.tta_des_histor_lancto_ctbl = replace(c-narrativa, chr(10), " ").                                             
                                                                                                                                            
           if movto_tit_ap.ind_trans_ap <> "Pagto Extra Fornecedor" AND                                                                     
              movto_tit_ap.ind_trans_ap <> "Pagto Extra Fornecedor CR" then                                                                 
           do:                                                                                                                              
              find tit_ap where                                                                                                             
                  tit_ap.cod_estab     = movto_tit_ap.cod_estab and                                                                         
                  tit_ap.num_id_tit_ap = movto_tit_ap.num_id_tit_ap no-lock no-error.                                                       
                                                                                                                                            
              ASSIGN tt_rpt_razao.tta_cod_emitente    = tit_ap.cdn_fornecedor                                                               
                     tt_rpt_razao.tta_cod_espec_docto = tit_ap.cod_espec_docto                                                              
                     tt_rpt_razao.tta_cod_ser_docto   = tit_ap.cod_ser_docto                                                                
                     tt_rpt_razao.tta_nro_docto       = tit_ap.cod_tit_ap                                                                   
                     tt_rpt_razao.tta_cod_parcela     = tit_ap.cod_parcela
                     tt_rpt_razao.tta_dat_emissao     = tit_ap.dat_emis_docto
                     tt_rpt_razao.seq-excel           = 1.


              RUN Pi-Contra-Partida-Lancto.
              /*Contra Partida da Conta do apb*/
              RUN pi_busca_contra_partida_apb.
              
              if tt_rpt_razao.tta_cod_cta_ctbl = "21301001" then
                    RUN Pi-Contra-Partida-Lancto.

              FIND FIRST t_tt_rpt_razao.
               IF AVAIL t_tt_rpt_razao THEN DO:
                   ASSIGN idx = 0.
                   FOR EACH t_tt_rpt_razao:
                       IF idx > 0 THEN DO:
                           CREATE tt_rpt_razao.
                           BUFFER-COPY t_tt_rpt_razao TO tt_rpt_razao.
                           IF item_lancto_ctbl.ind_natur_lancto_ctbl = "CR" THEN
                              ASSIGN tt_rpt_razao.ttv_val_lancto_ctbl_contra = tt_rpt_razao.ttv_val_lancto_ctbl_contra  * -1.

                       END.
                       ELSE DO:
                           ASSIGN tt_rpt_razao.ttv_val_lancto_ctbl_contra    =  (t_tt_rpt_razao.ttv_val_lancto_ctbl_contra)
                                  tt_rpt_razao.tta_cod_cta_ctbl_contra       =  t_tt_rpt_razao.tta_cod_cta_ctbl_contra
                                  tt_rpt_razao.Seq-Excel                     =  t_tt_rpt_razao.Seq-Excel.
                           IF item_lancto_ctbl.ind_natur_lancto_ctbl = "CR" THEN
                              ASSIGN tt_rpt_razao.ttv_val_lancto_ctbl_contra = tt_rpt_razao.ttv_val_lancto_ctbl_contra  * -1.
                       END.
                       ASSIGN idx = idx + 1.
                   END.
               END.
               EMPTY TEMP-TABLE t_tt_rpt_razao.

           end.                                                                                                                             
       end.                                                                                                                                 
    END.
    ELSE DO:                    
       RUN pi_sem_lancto_origem.
    END.                        

END PROCEDURE. /* pi_gera_tt_relacto_aprop_lancto_ctbl_apb */

/********************************************************************************/
PROCEDURE pi_gera_tt_relacto_aprop_lancto_ctbl_acr:

    FIND FIRST val_aprop_ctbl_acr WHERE 
               val_aprop_ctbl_acr.num_id_aprop_lancto_ctbl = aprop_lancto_ctbl.num_id_aprop_lancto_ctbl NO-LOCK NO-ERROR.
    IF AVAIL val_aprop_ctbl_acr THEN DO:
       for each val_aprop_ctbl_acr no-lock                                                                                                               
           where val_aprop_ctbl_acr.num_id_aprop_lancto_ctbl = aprop_lancto_ctbl.num_id_aprop_lancto_ctbl: 

           RUN pi-acompanhar IN h-acomp ("Aprop_Ctbl_ACR " + string(val_aprop_ctbl_acr.cod_estab) + " " +                                                       
                                                             string(val_aprop_ctbl_acr.num_id_aprop_ctbl_acr)).                                                  
                                                                                                                                                         
           find aprop_ctbl_acr where                                                                                                                     
                aprop_ctbl_acr.cod_estab             = val_aprop_ctbl_acr.cod_estab and                                                                   
                aprop_ctbl_acr.num_id_aprop_ctbl_acr = val_aprop_ctbl_acr.num_id_aprop_ctbl_acr no-lock no-error.                                         
                                                                                                                                                         
           find first movto_tit_acr where                                                                                                                      
                      movto_tit_acr.cod_estab            = aprop_ctbl_acr.cod_estab and                                                                         
                      movto_tit_acr.num_id_movto_tit_acr = aprop_ctbl_acr.num_id_movto_tit_acr no-lock no-error.  
               
           assign c-histor = ""
                  c-hst    = "".
 
           for each histor_movto_tit_acr no-lock
              where histor_movto_tit_acr.cod_estab            = movto_tit_acr.cod_estab
                and histor_movto_tit_acr.num_id_tit_acr       = movto_tit_acr.num_id_tit_acr
                and histor_movto_tit_acr.num_id_movto_tit_acr = movto_tit_acr.num_id_movto_tit_acr:
                
                if histor_movto_tit_acr.ind_orig_histor_acr <> "ERRO" and 
                   histor_movto_tit_acr.des_text_histor <> "" and 
                   histor_movto_tit_acr.des_text_histor <> c-hst then
                   assign c-histor = c-histor + histor_movto_tit_acr.des_text_histor + " "
                          c-hst    = histor_movto_tit_acr.des_text_histor.
           end.
                                                                                                                                                         
           CREATE tt_rpt_razao.                                                                                                                          
           ASSIGN tt_rpt_razao.tta_cod_ccusto                 = item_lancto_ctbl.cod_ccusto
                  tt_rpt_razao.tta_num_lote_ctbl              = item_lancto_ctbl.num_lote_ctbl                                                           
                  tt_rpt_razao.tta_num_lancto_ctbl            = item_lancto_ctbl.num_lancto_ctbl                                                         
                  tt_rpt_razao.tta_num_seq_lancto_ctbl        = item_lancto_ctbl.num_seq_lancto_ctbl                                                     
                  tt_rpt_razao.tta_num_seq_lancto_ctbl_cpart  = item_lancto_ctbl.num_seq_lancto_ctbl_cpart                                               
                  tt_rpt_razao.tta_cod_modul_dtsul            = lancto_ctbl.cod_modul_dtsul                                                              
                  tt_rpt_razao.tta_cod_plano_cta_ctbl         = item_lancto_ctbl.cod_plano_cta_ctbl                                                      
                  tt_rpt_razao.tta_cod_cta_ctbl               = item_lancto_ctbl.cod_cta_ctbl                                                            
                  tt_rpt_razao.tta_cod_estab                  = item_lancto_ctbl.cod_estab                                                               
                  tt_rpt_razao.tta_cod_unid_negoc             = item_lancto_ctbl.cod_unid_negoc                                                          
                  tt_rpt_razao.tta_dat_lancto_ctbl            = item_lancto_ctbl.dat_lancto_ctbl                                                         
                  tt_rpt_razao.tta_des_histor_lancto_ctbl     = item_lancto_ctbl.des_histor_lancto_ctbl                                                  
                  tt_rpt_razao.tta_cod_cta_ctbl_padr_internac = cta_ctbl.cod_cta_ctbl_padr_internac                                                      
                  tt_rpt_razao.tta_des_tit_ctbl               = cta_ctbl.des_tit_ctbl.                                                                   
                                                                                                                                                         
           ASSIGN v_val_lancto_ctbl = fnAjustDec(val_aprop_ctbl_acr.val_aprop_ctbl / v_val_cotac_indic_econ, v_cod_moed_finalid).                        
                                                                                                                                                                                                                                                           
           If v_val_lancto_ctbl = ? THEN                                                                                                                 
              ASSIGN v_val_lancto_ctbl = 0.                                                                                                              
                                                                                                                                                         
           IF item_lancto_ctbl.ind_natur_lancto_ctbl = "DB" THEN                                                                                         
              ASSIGN tt_rpt_razao.ttv_val_lancto_ctbl_db = ABS(v_val_lancto_ctbl).                                                                            
           ELSE                                                                                                                                          
              ASSIGN tt_rpt_razao.ttv_val_lancto_ctbl_cr = ABS(v_val_lancto_ctbl).                                                                          
              
           if c-histor <> "" and 
              c-histor <> item_lancto_ctbl.des_histor_lancto_ctbl then
              ASSIGN c-narrativa = movto_tit_acr.ind_trans_acr + " - " + /* item_lancto_ctbl.des_histor_lancto_ctbl + " - " + */ c-histor.
           else
              ASSIGN c-narrativa = movto_tit_acr.ind_trans_acr + " - " + item_lancto_ctbl.des_histor_lancto_ctbl.
                  
           assign tt_rpt_razao.tta_des_histor_lancto_ctbl = replace(c-narrativa, chr(10), " ").                                                          
                                                                                                                                                         
           find tit_acr where                                                                                                                            
                tit_acr.cod_estab      = movto_tit_acr.cod_estab and                                                                                      
                tit_acr.num_id_tit_acr = movto_tit_acr.num_id_tit_acr no-lock no-error.                                                                   
                                                                                                                                                         
           ASSIGN tt_rpt_razao.tta_cod_emitente    = tit_acr.cdn_cliente                                                                                 
                  tt_rpt_razao.tta_cod_espec_docto = tit_acr.cod_espec_docto                                                                             
                  tt_rpt_razao.tta_cod_ser_docto   = tit_acr.cod_ser_docto                                                                               
                  tt_rpt_razao.tta_nro_docto       = tit_acr.cod_tit_acr                                                                                 
                  tt_rpt_razao.tta_cod_parcela     = tit_acr.cod_parcela
                  tt_rpt_razao.tta_dat_emissao     = tit_acr.dat_emis_docto
                  tt_rpt_razao.seq-excel           = 1.

           RUN Pi-Contra-Partida-Lancto.
           /*Contra Partida da Conta do ACR*/
           RUN pi_busca_contra_partida_acr.
           FIND FIRST t_tt_rpt_razao.
            IF AVAIL t_tt_rpt_razao THEN DO:
                ASSIGN idx = 0.

                FOR EACH t_tt_rpt_razao:
                    IF idx > 0 THEN DO:
                        CREATE tt_rpt_razao.
                        BUFFER-COPY t_tt_rpt_razao TO tt_rpt_razao.
                        IF item_lancto_ctbl.ind_natur_lancto_ctbl = "CR" THEN
                           ASSIGN tt_rpt_razao.ttv_val_lancto_ctbl_contra = tt_rpt_razao.ttv_val_lancto_ctbl_contra  * -1.
                        
                    END.
                    ELSE DO:
                        ASSIGN tt_rpt_razao.ttv_val_lancto_ctbl_contra    =  (t_tt_rpt_razao.ttv_val_lancto_ctbl_contra)
                               tt_rpt_razao.tta_cod_cta_ctbl_contra       =  t_tt_rpt_razao.tta_cod_cta_ctbl_contra
                               tt_rpt_razao.Seq-Excel                     =  t_tt_rpt_razao.Seq-Excel.

                        IF item_lancto_ctbl.ind_natur_lancto_ctbl = "CR" THEN
                           ASSIGN tt_rpt_razao.ttv_val_lancto_ctbl_contra = tt_rpt_razao.ttv_val_lancto_ctbl_contra  * -1.
                    END.
                    ASSIGN idx = idx + 1.

                END.
            END.
            EMPTY TEMP-TABLE t_tt_rpt_razao.
       END.
    END.
    ELSE DO:
       RUN pi_sem_lancto_origem.
    END.

END PROCEDURE. /* pi_gera_tt_relacto_aprop_lancto_ctbl_acr */

/********************************************************************************/
PROCEDURE pi_gera_tt_relacto_aprop_lancto_ctbl_apl:

    for each tt_relac_aprop_lancto_ctbl_apl:
        delete tt_relac_aprop_lancto_ctbl_apl.
    end.

    &if '{&emsuni_version}' >= '5.04' &then
        if  v_log_funcao_armaz_val_finalid = yes
        then do:
            &if '{&emsuni_version}' < '5.06' &then
                for each tab_livre_emsfin no-lock
                    where tab_livre_emsfin.cod_modul_dtsul = "APL" /*l_apl*/ 
                      and tab_livre_emsfin.cod_tab_dic_dtsul = "Val_aprop_ctbl_apl" /*l_val_aprop_ctbl_apl*/ 
                      and tab_livre_emsfin.num_livre_1 = aprop_lancto_ctbl.num_id_aprop_lancto_ctbl:
                    find first movto_operac_financ no-lock
                        where movto_operac_financ.num_id_movto_operac_financ = int(tab_livre_emsfin.cod_compon_1_idx_tab) no-error.
                    assign v_val_aprop_ctbl = tab_livre_emsfin.val_livre_1.
            &else
                for each val_aprop_ctbl_apl no-lock
                    where val_aprop_ctbl_apl.num_id_aprop_lancto_ctbl = aprop_lancto_ctbl.num_id_aprop_lancto_ctbl:
                    find first movto_operac_financ no-lock
                        where movto_operac_financ.num_id_movto_operac_financ = val_aprop_ctbl_apl.num_id_movto_operac_financ no-error.
                    assign v_val_aprop_ctbl = val_aprop_ctbl_apl.val_aprop_ctbl.
            &endif
                    
                    RUN pi-acompanhar IN h-acomp ("Aprop_Ctbl_APL " +  string(movto_operac_financ.dat_transacao) + " " +                                                       
                                                                       string(movto_operac_financ.ind_tip_trans_apl)).                                                  
                    find first operac_financ no-lock
                        where operac_financ.num_id_operac_financ = movto_operac_financ.num_id_operac_financ no-error.

                    create tt_relac_aprop_lancto_ctbl_apl.
                    assign tt_relac_aprop_lancto_ctbl_apl.tta_ind_tip_trans_apl       = movto_operac_financ.ind_tip_trans_apl
                           tt_relac_aprop_lancto_ctbl_apl.tta_dat_transacao           = movto_operac_financ.dat_transacao
                           tt_relac_aprop_lancto_ctbl_apl.tta_cod_banco               = operac_financ.cod_banco
                           tt_relac_aprop_lancto_ctbl_apl.tta_cod_produt_financ       = operac_financ.cod_produt_financ
                           tt_relac_aprop_lancto_ctbl_apl.tta_cod_operac_financ       = operac_financ.cod_operac_financ
                           tt_relac_aprop_lancto_ctbl_apl.tta_val_aprop_ctbl          = v_val_aprop_ctbl
                           tt_relac_aprop_lancto_ctbl_apl.ttv_rec_movto_operac_financ = recid(movto_operac_financ).
                end.
        end.

        /* Para contabilizaá‰es antigas busca da aprop_ctbl_apl, como fazia antes da funá∆o armazenar_valor_finalid */
        find first tt_relac_aprop_lancto_ctbl_apl no-lock no-error.
        if  not avail tt_relac_aprop_lancto_ctbl_apl
        then do:

            for each aprop_ctbl_apl no-lock
                where aprop_ctbl_apl.num_id_aprop_lancto_ctbl = aprop_lancto_ctbl.num_id_aprop_lancto_ctbl:

                find movto_operac_financ no-lock
                    where movto_operac_financ.num_id_movto_operac_financ = aprop_ctbl_apl.num_id_movto_operac_financ no-error.
                find operac_financ no-lock
                    where operac_financ.num_id_operac_financ = movto_operac_financ.num_id_operac_financ no-error.    


                RUN pi-acompanhar IN h-acomp ("Aprop_Ctbl_APL " +  string(movto_operac_financ.dat_transacao) + " " +                                                       
                                                                   string(movto_operac_financ.ind_tip_trans_apl)).                                                  

                create tt_relac_aprop_lancto_ctbl_apl.

                assign tt_relac_aprop_lancto_ctbl_apl.tta_ind_tip_trans_apl       = movto_operac_financ.ind_tip_trans_apl
                       tt_relac_aprop_lancto_ctbl_apl.tta_dat_transacao           = movto_operac_financ.dat_transacao
                       tt_relac_aprop_lancto_ctbl_apl.tta_cod_banco               = operac_financ.cod_banco
                       tt_relac_aprop_lancto_ctbl_apl.tta_cod_produt_financ       = operac_financ.cod_produt_financ 
                       tt_relac_aprop_lancto_ctbl_apl.tta_cod_operac_financ       = operac_financ.cod_operac_financ
                       tt_relac_aprop_lancto_ctbl_apl.tta_val_aprop_ctbl          = aprop_ctbl_apl.val_aprop_ctbl
                       tt_relac_aprop_lancto_ctbl_apl.ttv_rec_movto_operac_financ = recid(movto_operac_financ).
            end.
        end.
    &endif
    
    FIND FIRST tt_relac_aprop_lancto_ctbl_apl NO-LOCK NO-ERROR.
    IF AVAIL tt_relac_aprop_lancto_ctbl_apl THEN
    DO:
       FOR EACH tt_relac_aprop_lancto_ctbl_apl:                                                                                                   
                                                                                                                                                  
           CREATE tt_rpt_razao.                                                                                                                   
           ASSIGN tt_rpt_razao.tta_cod_ccusto                 = item_lancto_ctbl.cod_ccusto
                  tt_rpt_razao.tta_num_lote_ctbl              = item_lancto_ctbl.num_lote_ctbl                                                    
                  tt_rpt_razao.tta_num_lancto_ctbl            = item_lancto_ctbl.num_lancto_ctbl                                                  
                  tt_rpt_razao.tta_num_seq_lancto_ctbl        = item_lancto_ctbl.num_seq_lancto_ctbl                                              
                  tt_rpt_razao.tta_num_seq_lancto_ctbl_cpart  = item_lancto_ctbl.num_seq_lancto_ctbl_cpart                                        
                  tt_rpt_razao.tta_cod_modul_dtsul            = lancto_ctbl.cod_modul_dtsul                                                       
                  tt_rpt_razao.tta_cod_plano_cta_ctbl         = item_lancto_ctbl.cod_plano_cta_ctbl                                               
                  tt_rpt_razao.tta_cod_cta_ctbl               = item_lancto_ctbl.cod_cta_ctbl                                                     
                  tt_rpt_razao.tta_cod_estab                  = item_lancto_ctbl.cod_estab                                                        
                  tt_rpt_razao.tta_cod_unid_negoc             = item_lancto_ctbl.cod_unid_negoc                                                   
                  tt_rpt_razao.tta_dat_lancto_ctbl            = item_lancto_ctbl.dat_lancto_ctbl                                                  
                  tt_rpt_razao.tta_des_histor_lancto_ctbl     = item_lancto_ctbl.des_histor_lancto_ctbl                                           
                  tt_rpt_razao.tta_cod_cta_ctbl_padr_internac = cta_ctbl.cod_cta_ctbl_padr_internac                                               
                  tt_rpt_razao.tta_des_tit_ctbl               = cta_ctbl.des_tit_ctbl.                                                            
                                                                                                                                                  
           ASSIGN v_val_lancto_ctbl = fnAjustDec(tt_relac_aprop_lancto_ctbl_apl.tta_val_aprop_ctbl / v_val_cotac_indic_econ, v_cod_moed_finalid). 
                                                                                                                                                                
           If v_val_lancto_ctbl = ? THEN                                                                                                                                                                                                                   
              ASSIGN v_val_lancto_ctbl = 0.                                                                                                       
                                                                                                                                                  
           IF item_lancto_ctbl.ind_natur_lancto_ctbl = "DB" THEN                                                                                  
              ASSIGN tt_rpt_razao.ttv_val_lancto_ctbl_db = ABS(v_val_lancto_ctbl).                                                                     
           ELSE                                                                                                                                   
              ASSIGN tt_rpt_razao.ttv_val_lancto_ctbl_cr = ABS(v_val_lancto_ctbl).                                                                     
                                                                                                                                                  
           ASSIGN c-narrativa                             = item_lancto_ctbl.des_histor_lancto_ctbl + " / " +                                     
                                                            movto_operac_financ.ind_tip_trans_apl +                                               
                                                            "Banco:" + tt_relac_aprop_lancto_ctbl_apl.tta_cod_banco + " / " +                                          
                                                            "Produto:" + tt_relac_aprop_lancto_ctbl_apl.tta_cod_produt_financ + " / " +                                
                                                            "Operaá∆o:" + tt_relac_aprop_lancto_ctbl_apl.tta_cod_operac_financ                                          
                  tt_rpt_razao.tta_des_histor_lancto_ctbl = replace(c-narrativa, chr(10), " ").      


           RUN Pi-Contra-Partida-Lancto.
       END.             
    END.
    ELSE DO:
       RUN pi_sem_lancto_origem.
    END.

END PROCEDURE. /* pi_gera_tt_relacto_aprop_lancto_ctbl_apl */

/*****************************************************************************/
PROCEDURE pi_gera_tt_movto_ctbl_ce:
   
   EMPTY TEMP-TABLE tt-movto-ctbl-ce NO-ERROR.

   RUN esp/ESFGL0001Xa.p (input aprop_lancto_ctbl.num_id_aprop_lancto_ctbl,                                                                   
                         INPUT "CEP",
                         output table tt-movto-ctbl-ce).  

   FIND FIRST tt-movto-ctbl-ce NO-LOCK NO-ERROR.
   IF AVAIL tt-movto-ctbl-ce THEN
   DO:
      FOR EACH tt-movto-ctbl-ce NO-LOCK WHERE tt-movto-ctbl-ce.valor-cont <> 0:  

          RUN pi-acompanhar IN h-acomp ("Movto_Ctbl_Ce " +  string(item_lancto_ctbl.dat_lancto_ctbl) + " " +                                                       
                                                            string(item_lancto_ctbl.num_lote_ctbl)).                                                  
                                                                                                                                            
          CREATE tt_rpt_razao.                                                                                                              
          ASSIGN tt_rpt_razao.tta_cod_ccusto                 = item_lancto_ctbl.cod_ccusto
                 tt_rpt_razao.tta_num_lote_ctbl              = item_lancto_ctbl.num_lote_ctbl                                               
                 tt_rpt_razao.tta_num_lancto_ctbl            = item_lancto_ctbl.num_lancto_ctbl                                             
                 tt_rpt_razao.tta_num_seq_lancto_ctbl        = item_lancto_ctbl.num_seq_lancto_ctbl                                         
                 tt_rpt_razao.tta_num_seq_lancto_ctbl_cpart  = item_lancto_ctbl.num_seq_lancto_ctbl_cpart                                   
                 tt_rpt_razao.tta_cod_modul_dtsul            = lancto_ctbl.cod_modul_dtsul                                                  
                 tt_rpt_razao.tta_cod_plano_cta_ctbl         = item_lancto_ctbl.cod_plano_cta_ctbl                                          
                 tt_rpt_razao.tta_cod_cta_ctbl               = item_lancto_ctbl.cod_cta_ctbl                                                
                 tt_rpt_razao.tta_cod_estab                  = item_lancto_ctbl.cod_estab                                                   
                 tt_rpt_razao.tta_cod_unid_negoc             = item_lancto_ctbl.cod_unid_negoc                                              
                 tt_rpt_razao.tta_dat_lancto_ctbl            = item_lancto_ctbl.dat_lancto_ctbl                                             
                 tt_rpt_razao.tta_des_histor_lancto_ctbl     = item_lancto_ctbl.des_histor_lancto_ctbl                                      
                 tt_rpt_razao.tta_cod_cta_ctbl_padr_internac = cta_ctbl.cod_cta_ctbl_padr_internac                                          
                 tt_rpt_razao.tta_des_tit_ctbl               = cta_ctbl.des_tit_ctbl
                 tt_rpt_razao.tta_cod_cta_ctbl_contra        = tt-movto-ctbl-ce.tta_cod_cta_ctbl_contra
                 tt_rpt_razao.ge-codigo                      = tt-movto-ctbl-ce.ge-codigo
                 tt_rpt_razao.it-codigo                      = tt-movto-ctbl-ce.it-codigo.
				 
          ASSIGN v_val_lancto_ctbl = fnAjustDec(tt-movto-ctbl-ce.valor-cont / v_val_cotac_indic_econ, v_cod_moed_finalid).                               
		  
          IF v_val_lancto_ctbl = ? THEN                                                                                                     
             ASSIGN v_val_lancto_ctbl = 0.  


          find first cta_ctbl_integr where 
               cta_ctbl_integr.cod_modul_dtsul     = lancto_ctbl.cod_modul_dtsul and
			   cta_ctbl_integr.cod_plano_cta_ctbl  = item_lancto_ctbl.cod_plano_cta_ctbl and	
			   cta_ctbl_integr.cod_cta_ctbl	       = item_lancto_ctbl.cod_cta_ctbl and 
               cta_ctbl_integr.dat_inic_valid      <= today and
               cta_ctbl_integr.dat_fim_valid       >= today no-lock no-error.

          if avail cta_ctbl_integr and cta_ctbl_integr.ind_finalid_ctbl = "Saldo por grupo de estoque" then do:
              IF tt-movto-ctbl-ce.transacao = 1 then
                  ASSIGN tt_rpt_razao.ttv_val_lancto_ctbl_db     = ABS(v_val_lancto_ctbl).
              else
                  ASSIGN tt_rpt_razao.ttv_val_lancto_ctbl_cr     = ABS(v_val_lancto_ctbl).
              
          
              assign tt_rpt_razao.ttv_val_lancto_ctbl_contra = (tt_rpt_razao.ttv_val_lancto_ctbl_db - tt_rpt_razao.ttv_val_lancto_ctbl_cr).
			  
          end.
          else do:
		  
              IF item_lancto_ctbl.ind_natur_lancto_ctbl = "DB" THEN DO:
    		    IF tt-movto-ctbl-ce.transacao = 1 then
    				ASSIGN tt_rpt_razao.ttv_val_lancto_ctbl_db     = ABS(v_val_lancto_ctbl) * (-1).
    	    	ELSE
    				ASSIGN tt_rpt_razao.ttv_val_lancto_ctbl_db     = ABS(v_val_lancto_ctbl) .
    		  END.
              ELSE DO:
    			IF tt-movto-ctbl-ce.transacao = 1 THEN
    				ASSIGN tt_rpt_razao.ttv_val_lancto_ctbl_cr     = ABS(v_val_lancto_ctbl).
    			ELSE
    				ASSIGN tt_rpt_razao.ttv_val_lancto_ctbl_cr     = ABS(v_val_lancto_ctbl) * (-1).
    		  END.
          
              assign tt_rpt_razao.ttv_val_lancto_ctbl_contra = (tt_rpt_razao.ttv_val_lancto_ctbl_db - tt_rpt_razao.ttv_val_lancto_ctbl_cr).

              if tt_rpt_razao.ttv_val_lancto_ctbl_cr < 0 then
                  assign tt_rpt_razao.ttv_val_lancto_ctbl_cr = tt_rpt_razao.ttv_val_lancto_ctbl_cr * (-1).

              if tt_rpt_razao.ttv_val_lancto_ctbl_db < 0 then
                  assign tt_rpt_razao.ttv_val_lancto_ctbl_cr = tt_rpt_razao.ttv_val_lancto_ctbl_cr  * (-1).
				  
          end.
          
                   
          
          /* Excecoes --- */ 
          
          
          
          /*if item_lancto_ctbl.cod_cta_ctbl = "11310001" and tt-movto-ctbl-ce.tta_cod_cta_ctbl_contra = "81000001" then do:
                assign tt_rpt_razao.tta_cod_cta_ctbl_contra = "91000001".
          end.
          
          if item_lancto_ctbl.cod_cta_ctbl = "11310001" and tt-movto-ctbl-ce.tta_cod_cta_ctbl_contra = "41101005" then do:
                assign tt_rpt_razao.tta_cod_cta_ctbl_contra = "91000018".
          end.
          
          if tt_rpt_razao.tta_des_tit_ctbl begins "ICMS" and tt_rpt_razao.cod_cta_ctbl_contra_Lancto <> "" and item_lancto_ctbl.cod_cta_ctbl <> "11310001" then do:
                assign tt_rpt_razao.tta_cod_cta_ctbl_contra = tt_rpt_razao.cod_cta_ctbl_contra_Lancto.
          end.
          
          if item_lancto_ctbl.cod_cta_ctbl = "11502004" and tt_rpt_razao.ttv_val_lancto_ctbl_cr = 0 then do:
                assign tt_rpt_razao.ttv_val_lancto_ctbl_cr = tt_rpt_razao.ttv_val_lancto_ctbl_db
                       tt_rpt_razao.ttv_val_lancto_ctbl_db = 0.
          end.
          
          if item_lancto_ctbl.cod_cta_ctbl = "31101001" and tt-movto-ctbl-ce.tta_cod_cta_ctbl_contra = "31101002" then do:
                assign tt_rpt_razao.tta_cod_cta_ctbl_contra = "91000002".
          end.
                    
          if item_lancto_ctbl.cod_cta_ctbl = "32101001" and tt-movto-ctbl-ce.tta_cod_cta_ctbl_contra = "11310005" then
                assign tt_rpt_razao.tta_cod_cta_ctbl_contra = "11310001".
                
          if item_lancto_ctbl.cod_cta_ctbl = "51104011" and tt-movto-ctbl-ce.tta_cod_cta_ctbl_contra = "11310001" then
                assign tt_rpt_razao.tta_cod_cta_ctbl_contra = "11310005".*/		  
				
		  
		  run pi_converte_especie_numerica_ems2_para_char (Input tt-movto-ctbl-ce.esp-docto,                                                
                                                           output v_cod_espec_docto).
		  		         
						 
          if tt-movto-ctbl-ce.narrativa <> "" then
             ASSIGN c-narrativa = tt-movto-ctbl-ce.narrativa.
          else 
             ASSIGN c-narrativa = item_lancto_ctbl.des_histor_lancto_ctbl.
             
          find first b-docum-est where
                     b-docum-est.serie-docto  = tt-movto-ctbl-ce.serie-docto  and
                     b-docum-est.nro-docto    = tt-movto-ctbl-ce.nro-docto    and
                     b-docum-est.cod-emitente = tt-movto-ctbl-ce.cod-emitente and
                     b-docum-est.nat-operacao = tt-movto-ctbl-ce.nat-operacao no-lock no-error.

          assign tt_rpt_razao.tta_des_histor_lancto_ctbl = replace(c-narrativa, chr(10), " ")                                               
                 tt_rpt_razao.tta_cod_emitente           = tt-movto-ctbl-ce.cod-emitente                                                    
                 tt_rpt_razao.tta_cod_espec_docto        = v_cod_espec_docto                                                                
                 tt_rpt_razao.tta_cod_ser_docto          = tt-movto-ctbl-ce.serie-docto                                                     
                 tt_rpt_razao.tta_nro_docto              = tt-movto-ctbl-ce.nro-docto
                 tt_rpt_razao.tta_dat_emissao            = if avail b-docum-est then b-docum-est.dt-emissao else tt-movto-ctbl-ce.dt-trans.
        
		
		if tt_rpt_razao.ttv_val_lancto_ctbl_contra < 0 and tt_rpt_razao.ttv_val_lancto_ctbl_db <> 0 
													   and tt_rpt_razao.ttv_val_lancto_ctbl_cr = 0 then 
			assign tt_rpt_razao.ttv_val_lancto_ctbl_cr = tt_rpt_razao.ttv_val_lancto_ctbl_db
				   tt_rpt_razao.ttv_val_lancto_ctbl_db = 0.
		
		if tt_rpt_razao.ttv_val_lancto_ctbl_contra > 0 and tt_rpt_razao.ttv_val_lancto_ctbl_cr <> 0 
													   and tt_rpt_razao.ttv_val_lancto_ctbl_db = 0 then 
			assign tt_rpt_razao.ttv_val_lancto_ctbl_db = tt_rpt_razao.ttv_val_lancto_ctbl_cr
				   tt_rpt_razao.ttv_val_lancto_ctbl_cr = 0.


        /*CEP*/

/*  RUN Pi-Contra-Partida-Lancto.  */
                                    
      END.                                                                                                                                  
   END.
   ELSE DO:   
      RUN pi_sem_lancto_origem. 
   END.                         

END PROCEDURE.  /* pi_gera_tt_movto_ctbl_ce */

/*****************************************************************************/
PROCEDURE pi_gera_tt_movto_ctbl_ft:

        RUN pi-acompanhar IN h-acomp ("Gerando Movto_Ctbl_FT - EsFgl0001Xb ").


   EMPTY TEMP-TABLE tt-movto-ctbl-ft NO-ERROR.

   RUN esp/ESFGL0001Xb.p (INPUT aprop_lancto_ctbl.num_id_aprop_lancto_ctbl,                                                                   
                         OUTPUT TABLE tt-movto-ctbl-ft).                                                                                     
                                                                                                                                           
   FIND FIRST tt-movto-ctbl-ft NO-LOCK NO-ERROR.
   IF AVAIL tt-movto-ctbl-ft THEN
   DO:
      
      FOR EACH tt-movto-ctbl-ft NO-LOCK WHERE                                                                                                 
               tt-movto-ctbl-ft.valor-cont <> 0:                                                                                                    
                                                                                                                                              
          CREATE tt_rpt_razao.                                                                                                                
          ASSIGN tt_rpt_razao.tta_cod_ccusto                 = item_lancto_ctbl.cod_ccusto
                 tt_rpt_razao.tta_num_lote_ctbl              = item_lancto_ctbl.num_lote_ctbl                                                 
                 tt_rpt_razao.tta_num_lancto_ctbl            = item_lancto_ctbl.num_lancto_ctbl                                               
                 tt_rpt_razao.tta_num_seq_lancto_ctbl        = item_lancto_ctbl.num_seq_lancto_ctbl                                           
                 tt_rpt_razao.tta_num_seq_lancto_ctbl_cpart  = item_lancto_ctbl.num_seq_lancto_ctbl_cpart                                     
                 tt_rpt_razao.tta_cod_modul_dtsul            = lancto_ctbl.cod_modul_dtsul                                                    
                 tt_rpt_razao.tta_cod_plano_cta_ctbl         = item_lancto_ctbl.cod_plano_cta_ctbl                                            
                 tt_rpt_razao.tta_cod_cta_ctbl               = item_lancto_ctbl.cod_cta_ctbl                                                  
                 tt_rpt_razao.tta_cod_estab                  = item_lancto_ctbl.cod_estab                                                     
                 tt_rpt_razao.tta_cod_unid_negoc             = item_lancto_ctbl.cod_unid_negoc                                                
                 tt_rpt_razao.tta_dat_lancto_ctbl            = item_lancto_ctbl.dat_lancto_ctbl                                               
                 tt_rpt_razao.tta_des_histor_lancto_ctbl     = item_lancto_ctbl.des_histor_lancto_ctbl                                        
                 tt_rpt_razao.tta_cod_cta_ctbl_padr_internac = cta_ctbl.cod_cta_ctbl_padr_internac                                            
                 tt_rpt_razao.tta_des_tit_ctbl               = cta_ctbl.des_tit_ctbl  
                 tt_rpt_razao.tta_cod_cta_ctbl_contra        = tt-movto-ctbl-ft.cod_cta_ctbl_contra
                 tt_rpt_razao.ttv_val_lancto_ctbl_contra     = tt-movto-ctbl-ft.val_lancto_ctbl_contra.
/*                  tt_rpt_razao.ge-codigo                      = tt-movto-ctbl-ft.ge-codigo   */
/*                  tt_rpt_razao.it-codigo                      = tt-movto-ctbl-ft.it-codigo.  */
                                                                                                                                              
          ASSIGN v_val_lancto_ctbl = fnAjustDec(tt-movto-ctbl-ft.valor-cont / v_val_cotac_indic_econ, v_cod_moed_finalid).                    
                                                                                                                                                         
          IF v_val_lancto_ctbl = ? THEN                                                                                                       
             ASSIGN v_val_lancto_ctbl = 0.                                                                                                    
                                                                                                                                              
          IF item_lancto_ctbl.ind_natur_lancto_ctbl = "DB" THEN                                                                               
             ASSIGN tt_rpt_razao.ttv_val_lancto_ctbl_db = ABS(v_val_lancto_ctbl).                                                                      
          ELSE                                                                                                                                
             ASSIGN tt_rpt_razao.ttv_val_lancto_ctbl_cr = ABS(v_val_lancto_ctbl).                                                             
                                                                                                                                              
          run pi_converte_especie_numerica_ems2_para_char (Input tt-movto-ctbl-ft.esp-docto,                                                  
                                                           output v_cod_espec_docto).                                                         
                 
          if tt-movto-ctbl-ft.historico <> "" then
             ASSIGN c-narrativa = tt-movto-ctbl-ft.historico.
          else
             ASSIGN c-narrativa = item_lancto_ctbl.des_histor_lancto_ctbl.
             
          find first b-nota-fiscal where
                     b-nota-fiscal.cod-estabel = tt-movto-ctbl-ft.cod-estabel and
                     b-nota-fiscal.serie       = tt-movto-ctbl-ft.serie-docto and
                     b-nota-fiscal.nr-nota-fis = tt-movto-ctbl-ft.nro-docto   no-lock no-error.
          
          assign tt_rpt_razao.tta_des_histor_lancto_ctbl = REPLACE(c-narrativa, CHR(10), " ")                                                 
                 tt_rpt_razao.tta_cod_emitente           = tt-movto-ctbl-ft.cod-emitente                                                      
                 tt_rpt_razao.tta_cod_espec_docto        = v_cod_espec_docto                                                                  
                 tt_rpt_razao.tta_cod_ser_docto          = tt-movto-ctbl-ft.serie-docto                                                       
                 tt_rpt_razao.tta_nro_docto              = tt-movto-ctbl-ft.nro-docto
                 tt_rpt_razao.tta_dat_emissao            = if avail b-nota-fiscal then b-nota-fiscal.dt-emis-nota else tt-movto-ctbl-ft.dt-trans.

         /* Pegando a conta de contra-partida do sumar-ft */
         FIND FIRST sumar-ft WHERE
                       sumar-ft.cod-estabel = tt-movto-ctbl-ft.cod-estabel   AND
                       sumar-ft.serie       = tt-movto-ctbl-ft.serie-docto   AND
                       sumar-ft.nr-nota-fis = tt-movto-ctbl-ft.nro-docto     AND
                       sumar-ft.tp-imposto  = tt-movto-ctbl-ft.int-1         and 
                       sumar-ft.ct-conta    <> tt-movto-ctbl-ft.conta-contabil and
                       sumar-ft.num-id-movto-ctbl = tt-movto-ctbl-ft.num-id-movto-ctbl no-lock NO-ERROR.

        if avail sumar-ft then
            assign tt_rpt_razao.tta_cod_cta_ctbl_contra  = sumar-ft.ct-conta.
        
        RUN Pi-Contra-Partida-Lancto. //Alteracao 04/09/2024

/*        run pi_gera_tt_movto_ctbl_ft.  */
                                                                                                                                              
      END.                                                                                                                                    
   END.
   ELSE DO:                     
      RUN pi_sem_lancto_origem. 
   END.                         

END PROCEDURE.  /* pi_gera_tt_movto_ctbl_ft */

/*****************************************************************************/
PROCEDURE pi_converte_especie_numerica_ems2_para_char:

    /************************ Parameter Definition Begin ************************/

    def Input param p_num_espec_ems2       as integer format ">9" no-undo.
    def output param p_cod_espec_docto_tit as character format "x(3)" no-undo.

   /************************* Parameter Definition End *************************/

    CASE p_num_espec_ems2:
        WHEN 1 THEN
            ASSIGN p_cod_espec_docto_tit = 'ACA'.
        WHEN 2 THEN
            ASSIGN p_cod_espec_docto_tit = 'ACT'.
        WHEN 3 THEN
            ASSIGN p_cod_espec_docto_tit = 'NU1':U.
        WHEN 4 THEN
            ASSIGN p_cod_espec_docto_tit = 'DD':U.
        WHEN 5 THEN
            ASSIGN p_cod_espec_docto_tit = 'DEV'.
        WHEN 6 THEN
            ASSIGN p_cod_espec_docto_tit = 'DIV'.
        WHEN 7 THEN
            ASSIGN p_cod_espec_docto_tit = 'DRM'.
        WHEN 8 THEN
            ASSIGN p_cod_espec_docto_tit = 'EAC'.
        WHEN 9 THEN
            ASSIGN p_cod_espec_docto_tit = 'EGF':U.
        WHEN 10 THEN
            ASSIGN p_cod_espec_docto_tit = 'BEM'.
        WHEN 11 THEN
            ASSIGN p_cod_espec_docto_tit = 'NU2':U.
        WHEN 12 THEN
            ASSIGN p_cod_espec_docto_tit = 'NU3':U.
        WHEN 13 THEN
            ASSIGN p_cod_espec_docto_tit = 'NU4':U.
        WHEN 14 THEN
            ASSIGN p_cod_espec_docto_tit = 'ICM'.
        WHEN 15 THEN
            ASSIGN p_cod_espec_docto_tit = 'INV'.
        WHEN 16 THEN
            ASSIGN p_cod_espec_docto_tit = 'IPL':U.
        WHEN 17 THEN
            ASSIGN p_cod_espec_docto_tit = 'MOB'.
        WHEN 18 THEN
            ASSIGN p_cod_espec_docto_tit = 'NC'.
        WHEN 19 THEN
            ASSIGN p_cod_espec_docto_tit = 'NF'.
        WHEN 20 THEN
            ASSIGN p_cod_espec_docto_tit = 'NFD'.
        WHEN 21 THEN
            ASSIGN p_cod_espec_docto_tit = 'NFE'.
        WHEN 22 THEN
            ASSIGN p_cod_espec_docto_tit = 'NFS'.
        WHEN 23 THEN
            ASSIGN p_cod_espec_docto_tit = 'NFT'.
        WHEN 24 THEN
            ASSIGN p_cod_espec_docto_tit = 'NU5':U.
        WHEN 25 THEN
            ASSIGN p_cod_espec_docto_tit = 'REF':U.
        WHEN 26 THEN
            ASSIGN p_cod_espec_docto_tit = 'RCS'.
        WHEN 27 THEN
            ASSIGN p_cod_espec_docto_tit = 'RDD'.
        WHEN 28 THEN
            ASSIGN p_cod_espec_docto_tit = 'REQ'.
        WHEN 29 THEN
            ASSIGN p_cod_espec_docto_tit = 'RFS'.
        WHEN 30 THEN
            ASSIGN p_cod_espec_docto_tit = 'RM'.
        WHEN 31 THEN
            ASSIGN p_cod_espec_docto_tit = 'RRQ'.
        WHEN 32 THEN
            ASSIGN p_cod_espec_docto_tit = 'STR'.
        WHEN 33 THEN
            ASSIGN p_cod_espec_docto_tit = 'TRA':U.
        WHEN 34 THEN
            ASSIGN p_cod_espec_docto_tit = 'ZZZ':U.
        WHEN 35 THEN
            ASSIGN p_cod_espec_docto_tit = 'SOB'.
        WHEN 36 THEN
            ASSIGN p_cod_espec_docto_tit = 'EDD'.
        WHEN 37 THEN
            ASSIGN p_cod_espec_docto_tit = 'VAR':U.
    END CASE.
END PROCEDURE. /* pi_converte_especie_numerica_ems2_para_char */

/*****************************************************************************/
PROCEDURE pi_retornar_indic_econ_finalid:

    /************************ Parameter Definition Begin ************************/

    def Input param p_cod_finalid_econ    as CHARACTER format "x(10)" no-undo.
    def Input param p_dat_transacao       as DATE format "99/99/9999" no-undo.
    def output param p_cod_indic_econ     as CHARACTER format "x(8)" no-undo.

    /************************* Parameter Definition End *************************/

    find first histor_finalid_econ no-lock
         where histor_finalid_econ.cod_finalid_econ = p_cod_finalid_econ
           and histor_finalid_econ.dat_inic_valid_finalid <= p_dat_transacao
           and histor_finalid_econ.dat_fim_valid_finalid > p_dat_transacao
    &if "{&emsuni_version}" >= "5.01" &then
         use-index hstrfnld_id
    &endif
          no-error.
    if avail histor_finalid_econ then
       assign p_cod_indic_econ = histor_finalid_econ.cod_indic_econ.

END PROCEDURE. /* pi_retornar_indic_econ_finalid */

/*****************************************************************************/
PROCEDURE pi_achar_cotac_indic_econ:

    /************************ Parameter Definition Begin ************************/
    def Input param p_cod_indic_econ_base    as CHARACTER format "x(8)" no-undo. 
    def Input param p_cod_indic_econ_idx     as CHARACTER format "x(8)" no-undo.
    def Input param p_dat_transacao          as DATE format "99/99/9999" no-undo.
    def Input param p_ind_tip_cotac_parid    as CHARACTER format "X(09)" no-undo.
    def output param p_dat_cotac_indic_econ  as DATE format "99/99/9999" no-undo.
    def output param p_val_cotac_indic_econ  as DECIMAL format ">>>>,>>9.9999999999" decimals 10 no-undo.
    def output param p_cod_return            as CHARACTER format "x(40)" no-undo.

    /************************* Parameter Definition End *************************/

    /************************* Variable Definition Begin ************************/
    def var v_dat_cotac_mes                  as DATE format "99/99/9999":U no-undo.
    def var v_log_indic                      as LOGICAL format "Sim/N∆o" initial NO no-undo.
    def var v_cod_indic_econ_orig            as character       no-undo.
    def var v_val_cotac_indic_econ_base      as decimal         no-undo.
    def var v_val_cotac_indic_econ_idx       as decimal         no-undo.

    /************************** Variable Definition End *************************/

    /* alteraá∆o sob demanda da atividade 148.681*/
    release cotac_parid.

    if p_cod_indic_econ_base = p_cod_indic_econ_idx then do:
        /* **
         Quando a Base e o ÷ndice forem iguais, significa que a cotaá∆o pode ser percentual,
         portanto n∆o basta apenas retornar 1 e deve ser feita toda a pesquisa abaixo para
         encontrar a taxa da moeda no dia informado.
         Exemplo: D¢lar - D¢lar, poder°amos retornar 1
                  ANBID - ANBID, devemos retornar a taxa do dia.
        ***/
        find indic_econ no-lock
             where indic_econ.cod_indic_econ  = p_cod_indic_econ_base
               and indic_econ.dat_inic_valid <= p_dat_transacao
               and indic_econ.dat_fim_valid  >  p_dat_transacao
             no-error.
        if  avail indic_econ then do:
            if  indic_econ.ind_tip_cotac = "Valor" /*l_valor*/  then do:
                assign p_dat_cotac_indic_econ = p_dat_transacao
                       p_val_cotac_indic_econ = 1
                       p_cod_return           = "OK" /*l_ok*/ .
            end.
            else do:
                find cotac_parid no-lock
                     where cotac_parid.cod_indic_econ_base = p_cod_indic_econ_base
                       and cotac_parid.cod_indic_econ_idx = p_cod_indic_econ_idx
                       and cotac_parid.dat_cotac_indic_econ = p_dat_transacao
                       and cotac_parid.ind_tip_cotac_parid = p_ind_tip_cotac_parid
    &if "{&emsuni_version}" >= "5.01" &then
                     use-index ctcprd_id
    &endif
                      /*cl_acha_cotac of cotac_parid*/ no-error.
                if  not avail cotac_parid
                then do:
                    find parid_indic_econ no-lock
                         where parid_indic_econ.cod_indic_econ_base = p_cod_indic_econ_base
                           and parid_indic_econ.cod_indic_econ_idx = p_cod_indic_econ_idx
    &if "{&emsuni_version}" >= "5.01" &then
                         use-index prdndccn_id
    &endif
                          /*cl_acha_parid_param of parid_indic_econ*/ no-error.
                    /* block: */
                    case parid_indic_econ.ind_criter_busca:
                        when "Anterior" /*l_anterior*/ then find prev cotac_parid no-lock
                              where cotac_parid.cod_indic_econ_base = p_cod_indic_econ_base
                                and cotac_parid.cod_indic_econ_idx = p_cod_indic_econ_idx
                                and cotac_parid.dat_cotac_indic_econ < p_dat_transacao
                                and cotac_parid.ind_tip_cotac_parid = p_ind_tip_cotac_parid
                                and cotac_parid.val_cotac_indic_econ <> 0.0
    &if "{&emsuni_version}" >= "5.01" &then
                              use-index ctcprd_id
    &endif
                               /*cl_acha_cotac_anterior of cotac_parid*/ no-error.
                        when "Pr¢ximo" /*l_proximo*/ then  find next cotac_parid no-lock
                               where cotac_parid.cod_indic_econ_base = p_cod_indic_econ_base
                                 and cotac_parid.cod_indic_econ_idx = p_cod_indic_econ_idx
                                 and cotac_parid.dat_cotac_indic_econ > p_dat_transacao
                                 and cotac_parid.ind_tip_cotac_parid = p_ind_tip_cotac_parid
                                 and cotac_parid.val_cotac_indic_econ <> 0.0
    &if "{&emsuni_version}" >= "5.01" &then
                               use-index ctcprd_id
    &endif
                                /*cl_acha_cotac_posterior of cotac_parid*/ no-error.
                    end /* case block */.
                    if  not avail cotac_parid
                    then do:
                        assign p_cod_return = "358"                   + "," +
                                              p_cod_indic_econ_base   + "," +
                                              p_cod_indic_econ_idx    + "," +
                                              string(p_dat_transacao) + "," +
                                              p_ind_tip_cotac_parid.
                    end /* if */.
                    else do:
                        assign p_dat_cotac_indic_econ = cotac_parid.dat_cotac_indic_econ
                               p_val_cotac_indic_econ = cotac_parid.val_cotac_indic_econ
                               p_cod_return           = "OK" /*l_ok*/ .
                    end /* else */.
                end /* if */.
                else do:
                    assign p_dat_cotac_indic_econ = cotac_parid.dat_cotac_indic_econ
                           p_val_cotac_indic_econ = cotac_parid.val_cotac_indic_econ
                           p_cod_return           = "OK" /*l_ok*/ .
                end /* else */.
            end.
        end.
        else do:
            assign p_cod_return = "335".
        end.
    end /* if */.
    else do:
        find parid_indic_econ no-lock
             where parid_indic_econ.cod_indic_econ_base = p_cod_indic_econ_base
               and parid_indic_econ.cod_indic_econ_idx = p_cod_indic_econ_idx
             use-index prdndccn_id no-error.
        if  avail parid_indic_econ
        then do:


            /* Begin_Include: i_verifica_cotac_parid */
            /* verifica as cotacoes da moeda p_cod_indic_econ_base para p_cod_indic_econ_idx 
              cadastrada na base, de acordo com a periodicidade da cotacao (obtida na 
              parid_indic_econ, que deve estar avail)*/

            /* period_block: */
            case parid_indic_econ.ind_periodic_cotac:
                when "Di†ria" /*l_diaria*/ then
                    diaria_block:
                    do:
                        find cotac_parid no-lock
                            where cotac_parid.cod_indic_econ_base  = p_cod_indic_econ_base
                              and cotac_parid.cod_indic_econ_idx   = p_cod_indic_econ_idx
                              and cotac_parid.dat_cotac_indic_econ = p_dat_transacao
                              and cotac_parid.ind_tip_cotac_parid  = p_ind_tip_cotac_parid
                            use-index ctcprd_id no-error.
                        if  not avail cotac_parid or cotac_parid.val_cotac_indic_econ = 0
                        then do:
                            find parid_indic_econ no-lock
                                where parid_indic_econ.cod_indic_econ_base = p_cod_indic_econ_base
                                  and parid_indic_econ.cod_indic_econ_idx  = p_cod_indic_econ_idx
                                use-index prdndccn_id no-error.
                            /* block: */
                            case parid_indic_econ.ind_criter_busca:
                                when "Anterior" /*l_anterior*/ then 
                                    find prev cotac_parid no-lock
                                        where cotac_parid.cod_indic_econ_base  = p_cod_indic_econ_base
                                          and cotac_parid.cod_indic_econ_idx   = p_cod_indic_econ_idx
                                          and cotac_parid.dat_cotac_indic_econ < p_dat_transacao
                                          and cotac_parid.ind_tip_cotac_parid  = p_ind_tip_cotac_parid
                                          and cotac_parid.val_cotac_indic_econ <> 0.0
                                          &if '{&emsuni_version}' >= '5.01' &then
                                          use-index ctcprd_id
                                          &endif
                                          no-error.
                                when "Pr¢ximo" /*l_proximo*/ then  
                                    find next cotac_parid no-lock
                                        where cotac_parid.cod_indic_econ_base  = p_cod_indic_econ_base
                                          and cotac_parid.cod_indic_econ_idx   = p_cod_indic_econ_idx
                                          and cotac_parid.dat_cotac_indic_econ > p_dat_transacao
                                          and cotac_parid.ind_tip_cotac_parid  = p_ind_tip_cotac_parid
                                          and cotac_parid.val_cotac_indic_econ <> 0.0
                                          &if '{&emsuni_version}' >= '5.01' &then
                                          use-index ctcprd_id
                                          &endif
                                          no-error.
                            end /* case block */.
                        end /* if */.
                    end /* do diaria_block */.
                when "Mensal" /*l_mensal*/ then
                    mensal_block:
                    do:
                        assign v_dat_cotac_mes = date(month(p_dat_transacao), 1, year(p_dat_transacao))
                               &if yes = yes &then 
                               v_log_indic     = yes
                               &endif .
                        find cotac_parid no-lock
                            where cotac_parid.cod_indic_econ_base  = p_cod_indic_econ_base
                              and cotac_parid.cod_indic_econ_idx   = p_cod_indic_econ_idx
                              and cotac_parid.dat_cotac_indic_econ = v_dat_cotac_mes
                              and cotac_parid.ind_tip_cotac_parid  = p_ind_tip_cotac_parid
                            use-index ctcprd_id no-error.
                        if  not avail cotac_parid or cotac_parid.val_cotac_indic_econ = 0
                        then do:
                            /* block: */
                            case parid_indic_econ.ind_criter_busca:
                                when "Anterior" /*l_anterior*/ then
                                    find prev cotac_parid no-lock
                                        where cotac_parid.cod_indic_econ_base  = p_cod_indic_econ_base
                                          and cotac_parid.cod_indic_econ_idx   = p_cod_indic_econ_idx
                                          and cotac_parid.dat_cotac_indic_econ < v_dat_cotac_mes
                                          and cotac_parid.ind_tip_cotac_parid  = p_ind_tip_cotac_parid
                                          and cotac_parid.val_cotac_indic_econ <> 0.0
                                        use-index ctcprd_id no-error.
                                when "Pr¢ximo" /*l_proximo*/ then
                                    find next cotac_parid no-lock
                                        where cotac_parid.cod_indic_econ_base  = p_cod_indic_econ_base
                                          and cotac_parid.cod_indic_econ_idx   = p_cod_indic_econ_idx
                                          and cotac_parid.dat_cotac_indic_econ > v_dat_cotac_mes
                                          and cotac_parid.ind_tip_cotac_parid  = p_ind_tip_cotac_parid
                                          and cotac_parid.val_cotac_indic_econ <> 0.0
                                        use-index ctcprd_id no-error.
                            end /* case block */.
                        end /* if */.
                    end /* do mensal_block */.
                when "Bimestral" /*l_bimestral*/ then
                    bimestral_block:
                    do:
                    end /* do bimestral_block */.
                when "Trimestral" /*l_trimestral*/ then
                    trimestral_block:
                    do:
                    end /* do trimestral_block */.
                when "Quadrimestral" /*l_quadrimestral*/ then
                    quadrimestral_block:
                    do:
                    end /* do quadrimestral_block */.
                when "Semestral" /*l_semestral*/ then
                    semestral_block:
                    do:
                    end /* do semestral_block */.
                when "Anual" /*l_anual*/ then
                    anual_block:
                    do:
                    end /* do anual_block */.
            end /* case period_block */.
            /* End_Include: i_verifica_cotac_parid */


            if  parid_indic_econ.ind_orig_cotac_parid = "Outra Moeda" /*l_outra_moeda*/  and
                 parid_indic_econ.cod_finalid_econ_orig_cotac <> "" and
                 (not avail cotac_parid or cotac_parid.val_cotac_indic_econ = 0)
            then do:
                /* Cotaá∆o Ponte */
                run pi_retornar_indic_econ_finalid (Input parid_indic_econ.cod_finalid_econ_orig_cotac,
                                                    Input p_dat_transacao,
                                                    output v_cod_indic_econ_orig) /*pi_retornar_indic_econ_finalid*/.
                find parid_indic_econ no-lock
                    where parid_indic_econ.cod_indic_econ_base = v_cod_indic_econ_orig
                    and parid_indic_econ.cod_indic_econ_idx = p_cod_indic_econ_base
                    use-index prdndccn_id no-error.
                run pi_achar_cotac_indic_econ_2 (Input v_cod_indic_econ_orig,
                                                 Input p_cod_indic_econ_base,
                                                 Input p_dat_transacao,
                                                 Input p_ind_tip_cotac_parid,
                                                 Input p_cod_indic_econ_base,
                                                 Input p_cod_indic_econ_idx) /*pi_achar_cotac_indic_econ_2*/.

                if  avail cotac_parid and cotac_parid.val_cotac_indic_econ <> 0
                then do:
                    assign v_val_cotac_indic_econ_base = cotac_parid.val_cotac_indic_econ.
                    find parid_indic_econ no-lock
                        where parid_indic_econ.cod_indic_econ_base = v_cod_indic_econ_orig
                        and parid_indic_econ.cod_indic_econ_idx = p_cod_indic_econ_idx
                        use-index prdndccn_id no-error.
                    run pi_achar_cotac_indic_econ_2 (Input v_cod_indic_econ_orig,
                                                     Input p_cod_indic_econ_idx,
                                                     Input p_dat_transacao,
                                                     Input p_ind_tip_cotac_parid,
                                                     Input p_cod_indic_econ_base,
                                                     Input p_cod_indic_econ_idx) /*pi_achar_cotac_indic_econ_2*/.

                    if  avail cotac_parid and cotac_parid.val_cotac_indic_econ <> 0
                    then do:
                        assign v_val_cotac_indic_econ_idx = cotac_parid.val_cotac_indic_econ
                               p_val_cotac_indic_econ = v_val_cotac_indic_econ_idx / v_val_cotac_indic_econ_base
                               p_dat_cotac_indic_econ = cotac_parid.dat_cotac_indic_econ
                               p_cod_return = "OK" /*l_ok*/ .
                        return.
                    end /* if */.
                end /* if */.
            end /* if */.
            if  parid_indic_econ.ind_orig_cotac_parid = "Inversa" /*l_inversa*/  and
                 (not avail cotac_parid or cotac_parid.val_cotac_indic_econ = 0)
            then do:
                find parid_indic_econ no-lock
                    where parid_indic_econ.cod_indic_econ_base = p_cod_indic_econ_idx
                    and parid_indic_econ.cod_indic_econ_idx = p_cod_indic_econ_base
                    use-index prdndccn_id no-error.
                run pi_achar_cotac_indic_econ_2 (Input p_cod_indic_econ_idx,
                                                 Input p_cod_indic_econ_base,
                                                 Input p_dat_transacao,
                                                 Input p_ind_tip_cotac_parid,
                                                 Input p_cod_indic_econ_base,
                                                 Input p_cod_indic_econ_idx) /*pi_achar_cotac_indic_econ_2*/.

                if  avail cotac_parid and cotac_parid.val_cotac_indic_econ <> 0
                then do:
                    assign p_dat_cotac_indic_econ = cotac_parid.dat_cotac_indic_econ
                           p_val_cotac_indic_econ = 1 / cotac_parid.val_cotac_indic_econ
                           p_cod_return = "OK" /*l_ok*/ .
                    return.
                end /* if */.
            end /* if */.
        end /* if */.
        if v_log_indic = yes then do:
           if  not avail cotac_parid or cotac_parid.val_cotac_indic_econ = 0
           then do:
               assign p_cod_return = "358"                 + "," +
                      p_cod_indic_econ_base   + "," +
                      p_cod_indic_econ_idx    + "," +
                      string(v_dat_cotac_mes) + "," +
                      p_ind_tip_cotac_parid.
           end /* if */.
           else do:
               assign p_dat_cotac_indic_econ = cotac_parid.dat_cotac_indic_econ
                      p_val_cotac_indic_econ = cotac_parid.val_cotac_indic_econ
                      p_cod_return           = "OK" /*l_ok*/ .
           end /* else */.
        end.
        else do:   
           if  not avail cotac_parid or cotac_parid.val_cotac_indic_econ = 0
           then do:
               assign p_cod_return = "358"                 + "," +
                      p_cod_indic_econ_base   + "," +
                      p_cod_indic_econ_idx    + "," +
                      string(p_dat_transacao) + "," +
                      p_ind_tip_cotac_parid.
           end /* if */.
           else do:
               assign p_dat_cotac_indic_econ = cotac_parid.dat_cotac_indic_econ
                      p_val_cotac_indic_econ = cotac_parid.val_cotac_indic_econ
                      p_cod_return           = "OK" /*l_ok*/ .
           end /* else */.
        end.
        assign v_log_indic = no.
    end /* else */.
END PROCEDURE. /* pi_achar_cotac_indic_econ */

/*****************************************************************************/
PROCEDURE pi_achar_cotac_indic_econ_2:

    /************************ Parameter Definition Begin ************************/
    def Input param p_cod_param_1             as CHARACTER format "x(8)" no-undo.
    def Input param p_cod_param_2             as CHARACTER format "x(50)" no-undo.
    def Input param p_dat_transacao           as DATE format "99/99/9999" no-undo.
    def Input param p_ind_tip_cotac_parid     as CHARACTER format "X(09)" no-undo.
    def Input param p_cod_indic_econ_base     as CHARACTER format "x(8)" no-undo.
    def Input param p_cod_indic_econ_idx      as CHARACTER format "x(8)" no-undo.

    /************************* Parameter Definition End *************************/

    /************************* Variable Definition Begin ************************/
    def var v_dat_cotac_mes                  as date            no-undo. /*local*/

    /************************** Variable Definition End *************************/

    /* period_block: */
    case parid_indic_econ.ind_periodic_cotac:
        when "Di†ria" /*l_diaria*/ then
            diaria_block:
            do:
                find cotac_parid no-lock
                     where cotac_parid.cod_indic_econ_base = p_cod_param_1
                       and cotac_parid.cod_indic_econ_idx = p_cod_param_2
                       and cotac_parid.dat_cotac_indic_econ = p_dat_transacao
                       and cotac_parid.ind_tip_cotac_parid = p_ind_tip_cotac_parid
                     use-index ctcprd_id no-error.
                if  not avail cotac_parid or cotac_parid.val_cotac_indic_econ = 0
                then do:
                    find parid_indic_econ no-lock
                         where parid_indic_econ.cod_indic_econ_base = p_cod_param_1
                           and parid_indic_econ.cod_indic_econ_idx = p_cod_param_2
                         use-index prdndccn_id no-error.
                    /* block: */
                    case parid_indic_econ.ind_criter_busca:
                        when "Anterior" /*l_anterior*/  then
                            find prev cotac_parid no-lock
                                where cotac_parid.cod_indic_econ_base   = p_cod_param_1
                                  and cotac_parid.cod_indic_econ_idx    = p_cod_param_2
                                  and cotac_parid.dat_cotac_indic_econ  < p_dat_transacao
                                  and cotac_parid.ind_tip_cotac_parid   = p_ind_tip_cotac_parid
                                  and cotac_parid.val_cotac_indic_econ <> 0.0 use-index ctcprd_id no-error.
                        when "Pr¢ximo" /*l_proximo*/  then
                            find next cotac_parid no-lock
                                where cotac_parid.cod_indic_econ_base   = p_cod_param_1
                                  and cotac_parid.cod_indic_econ_idx    = p_cod_param_2
                                  and cotac_parid.dat_cotac_indic_econ  > p_dat_transacao
                                  and cotac_parid.ind_tip_cotac_parid   = p_ind_tip_cotac_parid
                                  and cotac_parid.val_cotac_indic_econ <> 0.0 use-index ctcprd_id no-error.
                    end /* case block */.
                end /* if */.
            end /* do diaria_block */.
        when "Mensal" /*l_mensal*/ then
            mensal_block:
            do:
                assign v_dat_cotac_mes = date(month(p_dat_transacao), 1, year(p_dat_transacao)).
                find cotac_parid no-lock
                     where cotac_parid.cod_indic_econ_base = p_cod_param_1
                       and cotac_parid.cod_indic_econ_idx = p_cod_param_2
                       and cotac_parid.dat_cotac_indic_econ = v_dat_cotac_mes
                       and cotac_parid.ind_tip_cotac_parid = p_ind_tip_cotac_parid
                     use-index ctcprd_id no-error.
                if  not avail cotac_parid or cotac_parid.val_cotac_indic_econ = 0
                then do:
                    /* block: */
                    case parid_indic_econ.ind_criter_busca:
                        when "Anterior" /*l_anterior*/ then
                        find prev cotac_parid no-lock
                                           where cotac_parid.cod_indic_econ_base = p_cod_param_1
                                             and cotac_parid.cod_indic_econ_idx = p_cod_param_2
                                             and cotac_parid.dat_cotac_indic_econ < v_dat_cotac_mes
                                             and cotac_parid.ind_tip_cotac_parid = p_ind_tip_cotac_parid
                                             and cotac_parid.val_cotac_indic_econ <> 0.0
                                           use-index ctcprd_id no-error.
                        when "Pr¢ximo" /*l_proximo*/ then
                        find next cotac_parid no-lock
                                           where cotac_parid.cod_indic_econ_base = p_cod_param_1
                                             and cotac_parid.cod_indic_econ_idx = p_cod_param_2
                                             and cotac_parid.dat_cotac_indic_econ > v_dat_cotac_mes
                                             and cotac_parid.ind_tip_cotac_parid = p_ind_tip_cotac_parid
                                             and cotac_parid.val_cotac_indic_econ <> 0.0
                                           use-index ctcprd_id no-error.
                    end /* case block */.
                end /* if */.
            end /* do mensal_block */.
        when "Bimestral" /*l_bimestral*/ then
            bimestral_block:
            do:
            end /* do bimestral_block */.
        when "Trimestral" /*l_trimestral*/ then
            trimestral_block:
            do:
            end /* do trimestral_block */.
        when "Quadrimestral" /*l_quadrimestral*/ then
            quadrimestral_block:
            do:
            end /* do quadrimestral_block */.
        when "Semestral" /*l_semestral*/ then
            semestral_block:
            do:
            end /* do semestral_block */.
        when "Anual" /*l_anual*/ then
            anual_block:
            do:
            end /* do anual_block */.
    end /* case period_block */.
END PROCEDURE. /* pi_achar_cotac_indic_econ_2 */

/*****************************************************************************/

PROCEDURE pi_busca_saldo_ini:

    /************************** Buffer Definition Begin *************************/

/*     def buffer btt_item_lancto_ctbl_razao    */
/*         for tt_item_lancto_ctbl_razao.       */
/*     &if "{&emsfin_version}" >= "1.00" &then  */
/*     def buffer b_item_lancto_ctbl            */
/*         for item_lancto_ctbl.                */
/*     &endif                                   */
/*                                              */

    /*************************** Buffer Definition End **************************/

    /************************* Variable Definition Begin ************************/

    def var v_log_busca_sdo
        as logical
        format "Sim/N∆o"
        initial no
        no-undo.


    /************************** Variable Definition End *************************/

    assign v_val_sdo_ctbl_fim = 0
           v_val_sdo_ctbl_db  = 0
           v_val_sdo_ctbl_cr  = 0
           v_val_sdo_ctbl_inic_ant = 0
           v_log_cta_restdo_acum = yes.
    /* --- Saldo Anterior ---*/
    assign v_log_busca_sdo = yes.


ASSIGN v_cod_cenar_ctbl_ini       = tt-param.cod-cenar
       v_dat_inic_period_ctbl_pri = tt-param.per-i
       v_cod_finalid_econ_ini     = v_cod_indic_econ_base
       v_log_consid_apurac_restdo = tt-param.con-res.

find cta_ctbl NO-LOCK USE-INDEX ctactbl_id where 
     cta_ctbl.cod_plano_cta_ctbl = tt-param.cod-plano /*plano_cta_ctbl.cod_plano_cta_ctbl*/ and
     cta_ctbl.cod_cta_ctbl       = tt_rpt_razao.tta_cod_cta_ctbl NO-ERROR.
     IF NOT AVAIL cta_ctbl  THEN DO:
         MESSAGE "Cta_Ctbl N∆o Encontrada "  + " - " + STRING(tt_rpt_razao.tta_cod_cta_ctbl) + " Plano " + STRING(tt-param.cod-plano)
             VIEW-AS ALERT-BOX INFO BUTTONS OK.
         LEAVE.

     END.

    find first period_ctbl
         where period_ctbl.cod_cenar_ctbl  = v_cod_cenar_ctbl_ini
         and   period_ctbl.cod_exerc_ctbl  = string(year(v_dat_inic_period_ctbl_pri),"9999")
         and   period_ctbl.num_period_ctbl = 1
         no-lock no-error.
    if avail period_ctbl then do:
       if month(period_ctbl.dat_inic_period_ctbl) = month(v_dat_inic_period_ctbl_pri) then do:
          find first grp_cta_ctbl
               where grp_cta_ctbl.cod_tip_grp_cta_ctbl     = cta_ctbl.cod_tip_grp_cta_ctbl
               and   grp_cta_ctbl.cod_grp_cta_ctbl         = cta_ctbl.cod_grp_cta_ctbl
               and   grp_cta_ctbl.log_consid_apurac_restdo = yes
               no-lock no-error.
          if avail grp_cta_ctbl then do:
             assign v_log_busca_sdo = no.
          end.
          else do:
              /* 232341 - alteraá∆o j† efetuada no raz∆o (fgl304ad - 219382) */
              /* Quando NaO CONSIDERA APURAcaO de resultados para CONTAS DE RESULTADOS (PL).     */
              /* O valor com apuraªío sempre DEVE ser considerado no SALDO INICIAL (somente em janeiro).  */
              find first grp_cta_ctbl no-lock
                  where grp_cta_ctbl.cod_tip_grp_cta_ctbl     = cta_ctbl.cod_tip_grp_cta_ctbl
                  and   grp_cta_ctbl.cod_grp_cta_ctbl         = cta_ctbl.cod_grp_cta_ctbl
                  and   grp_cta_ctbl.log_consid_apurac_restdo = no no-error.
              if avail grp_cta_ctbl and v_log_consid_apurac_restdo = no and month(v_dat_inic_period_ctbl_pri) = 1 then
                  assign  v_log_cta_restdo_acum = yes.
          end.
          if not v_log_busca_sdo and day(v_dat_inic_period_ctbl_pri) <> 01 then do:
              find first b_item_lancto_ctbl
                   where b_item_lancto_ctbl.cod_cta_ctbl       = cta_ctbl.cod_cta_ctbl
                   and   b_item_lancto_ctbl.cod_plano_cta_ctbl = cta_ctbl.cod_plano_cta_ctbl
                   and   b_item_lancto_ctbl.dat_lancto_ctbl   >= date(month(v_dat_inic_period_ctbl_pri),01,year(v_dat_inic_period_ctbl_pri))
                   and   b_item_lancto_ctbl.dat_lancto_ctbl    < v_dat_inic_period_ctbl_pri no-lock no-error.
                if avail b_item_lancto_ctbl then
                    assign v_log_busca_sdo = yes.
          end.
       end.
    end.
/*     if v_log_busca_sdo then do:  
                                                                                                             */
    ASSIGN v_cod_unid_organ       = i-ep-codigo-usuario
           v_cod_cenar_ctbl_ini   = tt-param.cod-cenar
           v_cod_finalid_econ_ini = tt-param.fin-base.
       	
       run prgfin/fgl/fgl905za.p  (Input 1,
                                   Input v_cod_unid_organ,
                                   Input v_cod_cenar_ctbl_ini,
                                   Input v_cod_finalid_econ_ini,
                                   Input cta_ctbl.cod_plano_cta_ctbl,
                                   Input cta_ctbl.cod_cta_ctbl,
                                   Input "",
                                   Input "",
                                   Input "",
                                   Input "",
                                   Input v_dat_inic_period_ctbl_pri - 1,
                                   Input v_dat_inic_period_ctbl_pri - 1,
                                   Input no,
                                   Input v_log_consid_apurac_restdo,
                                   Input no,
                                   input-output table tt_erro_relatorio_razao) /*prg_api_sdo_cta_ctbl*/.
/*     end.  */
    FIND FIRST tt_erro_relatorio_razao NO-ERROR.
         IF AVAIL tt_erro_relatorio_razao THEN DO:
             MESSAGE "Erro Relatorio Razao..."
                 VIEW-AS ALERT-BOX INFO BUTTONS OK.
         END.
    find first tt_sdo_ctbl exclusive-lock no-error.
    if  avail tt_sdo_ctbl
    then do:
	
        assign v_val_sdo_ctbl_inic_ant = fnAjustDec(tt_sdo_ctbl.tta_val_sdo_ctbl_fim / v_val_cotac_indic_econ, v_cod_moed_finalid).
		
    delete tt_sdo_ctbl.
    END.

END PROCEDURE.



/*****************************************************************************
** Procedure Interna.....: pi_criar_unid_negoc_faixa
** Descricao.............: pi_criar_unid_negoc_faixa
** Criado por............: BRE17264
** Criado em.............: 31/08/1999 15:29:41
** Alterado por..........: fut35059
** Alterado em...........: 27/07/2006 17:34:24
*****************************************************************************/
PROCEDURE pi_criar_unid_negoc_faixa:

    FOR each tt_unid_negoc exclusive-lock:
        delete tt_unid_negoc.
    end /* for delete_block */.

    for each emscad.unid_negoc NO-LOCK WHERE
             emscad.unid_negoc.cod_unid_negoc <> "" :
/*         where emscad.unid_negoc.cod_unid_negoc >= tt-param.neg-i   */
/*         and   emscad.unid_negoc.cod_unid_negoc <= tt-param.neg-f:  */

        if not can-find (first tt_unid_negoc where tt_unid_negoc.ttv_rec_unid_negoc = recid(unid_negoc)) then do:
            create tt_unid_negoc.
            assign tt_unid_negoc.ttv_rec_unid_negoc = recid(emscad.unid_negoc)
                   tt_unid_negoc.cod_unid_negoc     = emscad.unid_negoc.cod_unid_negoc
                   tt_unid_negoc.cdn_unid_negoc     = emscad.unid_negoc.cdn_unid_negoc
                   tt_unid_negoc.des_unid_negoc     = emscad.unid_negoc.des_unid_negoc.
        end.
    end /* for unid_negoc_block */.

END PROCEDURE. /* pi_criar_unid_negoc_faixa */

/*****************************************************************************
** Procedure Interna.....: pi_criar_unid_organ_usuar
** Descricao.............: pi_criar_unid_organ_usuar
** Criado por............: Henke
** Criado em.............: 12/02/1996 15:10:00
** Alterado por..........: si1768
** Alterado em...........: 04/10/2013 11:39:41
*****************************************************************************/
PROCEDURE pi_criar_unid_organ_usuar:

    FOR each tt_unid_organ exclusive-lock:
        delete tt_unid_organ.
    end /* for delete_block */.

        FOR EACH emscad.unid_organ NO-LOCK WHERE
                 emscad.unid_organ.cod_unid_organ >= tt-param.est-i AND
                 emscad.unid_organ.cod_unid_organ <= tt-param.est-f,
            EACH emscad.estrut_unid_organ NO-LOCK WHERE
                 emscad.estrut_unid_organ.cod_unid_organ_pai   = v_cod_empres_usuar             AND
                 emscad.estrut_unid_organ.cod_unid_organ_filho = emscad.unid_organ.cod_unid_organ :


/*     FOR EACH emscad.unid_organ NO-LOCK                                                               */
/*          WHERE emscad.unid_organ.cod_unid_organ >= tt-param.est-i AND                                */
/*                emscad.unid_organ.cod_unid_organ <= tt-param.est-f,                                   */
/*         EACH   emscad.estrut_unid_organ NO-LOCK where                                                */
/*                emscad.estrut_unid_organ.cod_unid_organ_pai   = v_cod_empres_usuar               AND  */
/*                emscad.estrut_unid_organ.cod_unid_organ_filho = emscad.unid_organ.cod_unid_organ AND  */
/*               (emscad.estrut_unid_organ.dat_inic_valid >= tt-param.per-i      OR                     */
/*                emscad.estrut_unid_organ.dat_fim_valid  <= tt-param.per-f):                           */
            find first tt_unid_organ no-lock where tt_unid_Organ.cod_unid_Organ = emscad.unid_organ.cod_unid_organ no-error.
            if not available tt_unid_organ then do:
                create tt_unid_organ.
                assign tt_unid_organ.ttv_rec_unid_organ = recid(unid_organ)
                       tt_unid_organ.cod_unid_organ     = emscad.unid_organ.cod_unid_organ
                       tt_unid_organ.des_unid_organ     = emscad.unid_organ.des_unid_organ
                       tt_unid_organ.cod_tip_unid_organ = emscad.unid_organ.cod_tip_unid_organ
                       tt_unid_organ.num_niv_unid_organ = emscad.unid_organ.num_niv_unid_organ
                       tt_unid_organ.dat_inic_valid     = emscad.unid_organ.dat_inic_valid
                       tt_unid_organ.dat_fim_valid      = emscad.unid_organ.dat_fim_valid.
            end.
    END.
END PROCEDURE. /* pi_criar_unid_organ_usuar */

PROCEDURE pi_criar_tt_estab_unid_negoc_select:
    for each tt_estab_unid_negoc_select exclusive-lock:
        delete tt_estab_unid_negoc_select.
    end /* for estab_un_block */.

    /* --- Criaá∆o dos tt_estab_unid_negoc_select ---*/
    for each tt_unid_organ no-lock
        where /*tt_unid_organ.num_niv_unid_organ = 998*/ /* Estabelecimento */
              tt_unid_organ.cod_unid_organ    >= tt-param.Est-I
          and tt_unid_organ.cod_unid_organ    <= tt-param.Est-F,
        each estab_unid_negoc no-lock
                where estab_unid_negoc.cod_estab       = tt_unid_organ.cod_unid_organ:
/*                   and estab_unid_negoc.cod_unid_negoc >= tt-param.neg-i   */
/*                   and estab_unid_negoc.cod_unid_negoc <= tt-param.neg-f:  */

                find first tt_unid_negoc no-lock
                     where tt_unid_negoc.cod_unid_negoc = estab_unid_negoc.cod_unid_negoc
                      no-error.

                create tt_estab_unid_negoc_select.
                assign tt_estab_unid_negoc_select.cod_estab      = estab_unid_negoc.cod_estab
                       tt_estab_unid_negoc_select.cod_unid_negoc = estab_unid_negoc.cod_unid_negoc.

    end /* for estab_block */.
END PROCEDURE. /* pi_criar_tt_estab_unid_negoc */

PROCEDURE pi_busca_contra_partida_acr:

EMPTY TEMP-TABLE t_tt_rpt_razao.
for each b_aprop_ctbl_acr no-lock
        where b_aprop_ctbl_acr.cod_estab             = movto_tit_acr.cod_estab
          and b_aprop_ctbl_acr.num_id_movto_tit_acr  = movto_tit_acr.num_id_movto_tit_acr 
          and b_aprop_ctbl_acr.ind_natur_lancto_ctbl <> aprop_ctbl_acr.ind_natur_lancto_ctbl:
        
        CREATE t_tt_rpt_razao.
        BUFFER-COPY tt_rpt_razao EXCEPT ttv_val_lancto_ctbl_db ttv_val_lancto_ctbl_cr 
                                     TO t_tt_rpt_razao.

        ASSIGN t_tt_rpt_razao.ttv_val_lancto_ctbl_contra    =  (b_aprop_ctbl_acr.val_aprop_ctbl)
               t_tt_rpt_razao.tta_cod_cta_ctbl_contra       =  b_aprop_ctbl_acr.cod_cta_ctbl
               t_tt_rpt_razao.Seq-Excel                     =  b_aprop_ctbl_acr.num_id_aprop_ctbl_acr.
END.

END PROCEDURE. /* pi_busca_contra_partida_acr */


PROCEDURE pi_busca_contra_partida_apb:

    EMPTY TEMP-TABLE t_tt_rpt_razao.
    for each b_aprop_ctbl_ap no-lock
            where b_aprop_ctbl_ap.cod_estab             = movto_tit_ap.cod_estab
              and b_aprop_ctbl_ap.num_id_movto_tit_ap   = movto_tit_ap.num_id_movto_tit_ap
              and b_aprop_ctbl_ap.ind_natur_lancto_ctbl <> aprop_ctbl_ap.ind_natur_lancto_ctbl:
    
            CREATE t_tt_rpt_razao.
            BUFFER-COPY tt_rpt_razao EXCEPT ttv_val_lancto_ctbl_db ttv_val_lancto_ctbl_cr TO t_tt_rpt_razao.
    
            ASSIGN t_tt_rpt_razao.ttv_val_lancto_ctbl_contra    = (b_aprop_ctbl_ap.val_aprop_ctbl)
                   t_tt_rpt_razao.tta_cod_cta_ctbl_contra       =  b_aprop_ctbl_ap.cod_cta_ctbl
                   t_tt_rpt_razao.Seq-Excel                     =  b_aprop_ctbl_ap.num_id_aprop_ctbl_ap.
    END.

END PROCEDURE. /* pi_busca_contra_partida_apb*/


PROCEDURE Pi-Contra-Partida-Lancto:

    IF item_lancto_ctbl.ind_natur_lancto_ctbl = "CR" THEN
       ASSIGN c-db-cr = "DB".
    ELSE
       ASSIGN c-db-cr = "CR".

       IF ind_natur_lancto_ctbl = "CR" THEN
          ASSIGN c-db-cr = "DB".
       ELSE
          ASSIGN c-db-cr = "CR".

          IF item_lancto_ctbl.num_seq_lancto_ctbl_cpart > 0  THEN
              FIND bf-item_lancto_ctbl NO-LOCK WHERE
                   bf-item_lancto_ctbl.cod_empresa                 = item_lancto_ctbl.cod_empresa                  AND 
                   bf-item_lancto_ctbl.num_lote_ctbl               = item_lancto_ctbl.num_lote_ctbl                AND
                   bf-item_lancto_ctbl.num_lancto_ctbl             = item_lancto_ctbl.num_lancto_ctbl              AND
                   bf-item_lancto_ctbl.num_seq_lancto_ctbl         = item_lancto_ctbl.num_seq_lancto_ctbl_cpart    AND
                   bf-item_lancto_ctbl.ind_natur_lancto_ctbl       = c-db-cr                                       
                   NO-ERROR.
          ELSE DO:
              FIND FIRST bf-item_lancto_ctbl NO-LOCK WHERE
                   bf-item_lancto_ctbl.cod_empresa                 = item_lancto_ctbl.cod_empresa                  AND 
                   bf-item_lancto_ctbl.num_lote_ctbl               = item_lancto_ctbl.num_lote_ctbl                AND
                   bf-item_lancto_ctbl.num_lancto_ctbl             = item_lancto_ctbl.num_lancto_ctbl              AND
                   bf-item_lancto_ctbl.ind_natur_lancto_ctbl       = c-db-cr                                       AND         
                   bf-item_lancto_ctbl.val_lancto_ctbl             = item_lancto_ctbl.val_lancto_ctbl 
                   NO-ERROR.

              IF NOT AVAIL bf-item_lancto_ctbl THEN
                  FIND FIRST bf-item_lancto_ctbl NO-LOCK WHERE
                       bf-item_lancto_ctbl.cod_empresa                 = item_lancto_ctbl.cod_empresa                  AND 
                       bf-item_lancto_ctbl.num_lote_ctbl               = item_lancto_ctbl.num_lote_ctbl                AND
                       bf-item_lancto_ctbl.num_lancto_ctbl             = item_lancto_ctbl.num_lancto_ctbl              AND
                       bf-item_lancto_ctbl.ind_natur_lancto_ctbl       = c-db-cr                                       AND         
                       bf-item_lancto_ctbl.des_histor_lancto_ctbl      = item_lancto_ctbl.des_histor_lancto_ctbl       NO-ERROR.
          END.

  ASSIGN tt_rpt_razao.cod_cta_ctbl_contra_Lancto = bf-item_lancto_ctbl.cod_cta_ctbl  WHEN AVAIL bf-item_lancto_ctbl.
  
  if tt_rpt_razao.tta_cod_cta_ctbl_contra = tt_rpt_razao.tta_cod_cta_ctbl then
        assign tt_rpt_razao.tta_cod_cta_ctbl_contra =  tt_rpt_razao.cod_cta_ctbl_contra_Lancto.
  
  /*
  if tt_rpt_razao.tta_des_tit_ctbl begins "ICMS" and lancto_ctbl.cod_modul_dtsul = "FTP" then do:
      assign tt_rpt_razao.tta_cod_cta_ctbl_contra = tt_rpt_razao.cod_cta_ctbl_contra_Lancto.
  end.
  */
  
  /* Excecoes */
  /*
  if lancto_ctbl.cod_modul_dtsul = "FTP" then do:
        if tt_rpt_razao.tta_cod_cta_ctbl = "51104011" and tt_rpt_razao.tta_cod_cta_ctbl_contra = "51104011" then
                assign tt_rpt_razao.tta_cod_cta_ctbl_contra = "21401005".

        /* Em 10/10/2024 esta regra mudou - Gleice email
        if tt_rpt_razao.tta_cod_cta_ctbl = "21401001" and tt_rpt_razao.tta_cod_cta_ctbl_contra = "32101001" then
                assign tt_rpt_razao.tta_cod_cta_ctbl_contra = "51104004". */
                
                
        if tt_rpt_razao.tta_cod_cta_ctbl = "51104012" and tt_rpt_razao.tta_cod_cta_ctbl_contra = "21401001" then
                assign tt_rpt_razao.tta_cod_cta_ctbl_contra = "21401012".
                
                
        if tt_rpt_razao.tta_cod_cta_ctbl = "32101008" and tt_rpt_razao.tta_cod_cta_ctbl_contra = "21401001" then
               assign tt_rpt_razao.tta_cod_cta_ctbl_contra = "21401012".

                
        
  end.
  */
  

END PROCEDURE.


PROCEDURE Pi-inverte-sinal:
    for each tt_rpt_razao where tt_rpt_razao.ttv_val_lancto_ctbl_db < 0 or 
                                tt_rpt_razao.ttv_val_lancto_ctbl_cr < 0:
        IF tt_rpt_razao.ttv_val_lancto_ctbl_db < 0 then
            assign tt_rpt_razao.ttv_val_lancto_ctbl_db  = tt_rpt_razao.ttv_val_lancto_ctbl_db * (-1).
            
        IF tt_rpt_razao.ttv_val_lancto_ctbl_cr < 0 then
            assign tt_rpt_razao.ttv_val_lancto_ctbl_cr = tt_rpt_razao.ttv_val_lancto_ctbl_cr * (-1).
    
            
    END.
end procedure.


PROCEDURE Pi_atu_rpt_razao:

    for each tt_rpt_razao:
        IF tt_rpt_razao.tta_cod_ccusto < tt-param.ccusto-i  OR
           tt_rpt_razao.tta_cod_ccusto > tt-param.ccusto-f  THEN DO:
            DELETE tt_rpt_razao.
        END.
    END.

    for each tt_rpt_razao:
        IF tt_rpt_razao.tta_cod_cta_ctbl  < tt-param.cta-i  OR
           tt_rpt_razao.tta_cod_cta_ctbl  > tt-param.cta-f  THEN DO:
            DELETE tt_rpt_razao.
        END.
    END.

    IF tt-param.rs-cep = 1 THEN RUN Pi_Sumar_Cep.


    for each tt_rpt_razao                         BREAK BY
             tt_rpt_razao.tta_cod_cta_ctbl        BY
             tt_rpt_razao.tta_dat_lancto_ctbl     BY
             tt_rpt_razao.tta_num_lote_ctbl       BY   
             tt_rpt_razao.tta_num_seq_lancto_ctbl BY
             tt_rpt_razao.tta_cod_modul_dtsul:
        
         IF FIRST-OF(tt_rpt_razao.tta_cod_cta_ctbl) THEN DO: 
            RUN pi-acompanhar IN h-acomp ("Busca_Saldo_Inicial " + STRING(tt_rpt_razao.tta_cod_cta_ctbl) + " " +                                            
                                                                   STRING(tt_rpt_razao.cod_cta_ctbl_contra_Lancto)).   

             RUN pi_busca_saldo_ini.
             ASSIGN  tt_rpt_razao.tta_v_val_sdo_ctbl_ini = v_val_sdo_ctbl_inic_ant.        
             ASSIGN  tt_rpt_razao.tta_v_val_sdo_ctbl_fim = v_val_sdo_ctbl_inic_ant.
             ASSIGN  v_val_sdo_ctbl_fim                  = tt_rpt_razao.tta_v_val_sdo_ctbl_fim.
         END.
         ELSE DO:
             ASSIGN  tt_rpt_razao.tta_v_val_sdo_ctbl_ini =  v_val_sdo_ctbl_fim.  
         END.

         RUN pi-acompanhar IN h-acomp ("Busca_Saldo_Inicial " + STRING(tt_rpt_razao.tta_cod_plano_cta_ctbl) + " " +                                            
                                                                STRING(tt_rpt_razao.tta_dat_lancto_ctbl,"99/99/9999")).   

         ASSIGN v_val_sdo_ctbl_fim  = v_val_sdo_ctbl_fim  + tt_rpt_razao.ttv_val_lancto_ctbl_contra.
         ASSIGN  tt_rpt_razao.tta_v_val_sdo_ctbl_fim      = v_val_sdo_ctbl_fim.


            if tt_rpt_razao.tta_num_seq_lancto_ctbl_cpart <> 0 THEN DO:                                                                                                                                    
               find first b_item_lancto_ctbl use-index tmlnctcb_id                                                                                 
                    where b_item_lancto_ctbl.num_lote_ctbl       = tt_rpt_razao.tta_num_lote_ctbl                                                  
                      and b_item_lancto_ctbl.num_lancto_ctbl     = tt_rpt_razao.tta_num_lancto_ctbl                                                
                      and b_item_lancto_ctbl.num_seq_lancto_ctbl = tt_rpt_razao.tta_num_seq_lancto_ctbl_cpart no-lock no-error.                                                                         
               if avail b_item_lancto_ctbl then DO: 
                   ASSIGN tt_rpt_razao.tta_cod_cta_ctbl_contra = b_item_lancto_ctbl.cod_cta_ctbl.
               END.
            END.

            /*Removi dia 20/09/2021*/
            IF tt_rpt_razao.tta_cod_cta_ctbl_contra = ""  THEN
               ASSIGN tt_rpt_razao.tta_cod_cta_ctbl_contra = tt_rpt_razao.cod_cta_ctbl_contra_Lancto.

/*             IF tt_rpt_razao.cod_cta_ctbl_contra_Lancto <> "" AND                                       */
/*                tt_rpt_razao.tta_cod_cta_ctbl_contra <> tt_rpt_razao.cod_cta_ctbl_contra_Lancto  THEN   */
/*                ASSIGN tt_rpt_razao.tta_cod_cta_ctbl_contra = tt_rpt_razao.cod_cta_ctbl_contra_Lancto.  */


            find emitente where 
                 emitente.cod-emitente = tt_rpt_razao.tta_cod_emitente no-lock no-error.                                            
                if avail emitente then                                                                                                                 
                   assign tt_rpt_razao.tta_nome-emit = emitente.nome-emit.                                                                                             
                else                                                                                                                                   
                   assign tt_rpt_razao.tta_nome-emit = "".  

            IF tt_rpt_razao.tta_cod_cta_ctbl_contra <> "" THEN
                FIND cta_ctbl NO-LOCK WHERE
                     cta_ctbl.cod_plano_cta_ctbl = tt_rpt_razao.tta_cod_plano_cta_ctbl      AND  
                     cta_ctbl.cod_cta_ctbl       = tt_rpt_razao.tta_cod_cta_ctbl_contra     NO-ERROR.
                     IF AVAIL cta_ctbl THEN
                        ASSIGN tt_rpt_razao.des_tit_ctbl_Contra = cta_ctbl.des_tit_ctbl.
    /*                  IF NOT AVAIL cta_ctbl THEN DO:                               */
    /*                      IF  tt_rpt_razao.cod_cta_ctbl_contra_Lancto  <> "" THEN  */
    /*                          MESSAGE "N∆o Encontrado no Plano de Contas"          */
    /*                                  tt_rpt_razao.tta_cod_plano_cta_ctbl  SKIP    */
    /*                                  tt_rpt_razao.cod_cta_ctbl_contra_Lancto      */
    /*                              VIEW-AS ALERT-BOX INFORMATION BUTTONS OK.        */
    /*                  END.                                                         */
    END.
    
END PROCEDURE.

PROCEDURE Pi_Gera_TXT:

OUTPUT TO VALUE(c-arq-txt).

        PUT "C.Custo"
            ";"
            "Cod.Plano"
            ";"
            "Cod.Conta"
            ";"
            "Nr.Lote"
            ";"
            "Nr.Lancto"
            ";"
            "Nr.Seq.Lancto"
            ";"
            "Nr.Seq.lacnto.CPart"
            ";"
            "Modulo"
            ";"
            "Cod.Est"
            ";"
            "Unid.Neg"
            ";"
            "Dt.Lancto"
            ";"
            "Val.Lancto DB"
            ";"
            "Val.Lancto CR"
            ";"
            "Val.Saldo.Fim"
            ";"
            "Historico"
            ";"
            "Des.Tit.Ctbl"
            ";"
            "Conta Internac"
            ";"
            "Cod.Emitente"
            ";"
            "Cod.Esp.Docto"
            ";"
            "Cod.Ser.Docto"
            ";"
            "Nro.Docto"
            ";"
            "Cod.Parc"
            ";"
            "Cod.Usuar"
            ";"
            "Data Emiss"
            ";"
            "Val.Saldo.Ini"
            ";"
            "Val.Saldo.Fim"
            ";"
            "Val.Lancto.Contra"

            ";"
            "Cod.Conta.Contra"

            ";"
            "Cod.Conta.Contra_AUX"
            ";"
            "Contra.Titulo"
            ";"

            "Nome.Emite"
            ";"
            "Seq.Excel"
            ";"
            "Ge.Codigo"
            ";"
            "It.Codigo"
        SKIP.


    for each tt_rpt_razao                         BREAK BY
             tt_rpt_razao.tta_cod_cta_ctbl        BY
             tt_rpt_razao.tta_dat_lancto_ctbl     BY
             tt_rpt_razao.tta_num_lote_ctbl       BY   
             tt_rpt_razao.tta_num_seq_lancto_ctbl BY
             tt_rpt_razao.tta_cod_modul_dtsul:

     EXPORT DELIMITER ";" tt_rpt_razao.

    END.

OUTPUT CLOSE.

END PROCEDURE.


PROCEDURE Pi_Gera_Planilha:

           RUN pi-acompanhar IN h-acomp ("Criando Planilha de Calculo...").   
        
/*           CREATE "excel.application" chExcelApplication.

           IF ERROR-STATUS:ERROR THEN
           DO:
               MESSAGE "[" ERROR-STATUS:GET-NUMBER(ERROR-STATUS:NUM-MESSAGES) "] - "
                       "ê necess†rio que esteja instalado o Microsoft Excel" SKIP
                       "que este relat¢rio seja processado!" VIEW-AS ALERT-BOX ERROR.
               RETURN.
           END.
*/
      RUN Pi_Gera_TXT.

      CREATE "excel.application" chExcelApplication.
      chExcelApplication:SheetsInNewWorkbook = 1.                                                                                             
      chWorkbook = chExcelApplication:Workbooks:ADD().  
                                                                                                                                                 
      RUN Pi_Excel_Header.
                                                                                                                                                 
      for each tt_rpt_razao                         BREAK BY
               tt_rpt_razao.tta_cod_cta_ctbl        BY
               tt_rpt_razao.tta_dat_lancto_ctbl     BY
               tt_rpt_razao.tta_num_lote_ctbl       BY   
               tt_rpt_razao.tta_num_seq_lancto_ctbl BY
               tt_rpt_razao.tta_cod_modul_dtsul     BY
               tt_rpt_razao.seq-excel:

           
           RUN pi-acompanhar IN h-acomp ("Gerando_Excel " + STRING(tt_rpt_razao.tta_cod_cta_ctbl)       + " " +     
                                                            STRING(tt_rpt_razao.tta_num_lote_ctbl)      + " " +                                            
                                                            STRING(tt_rpt_razao.tta_num_lancto_ctbl)    + " " +                                          
                                                            STRING(tt_rpt_razao.tta_num_seq_lancto_ctbl) + " " +
                                                            STRING(tt_rpt_razao.tta_dat_lancto_ctbl,"99/99/9999") + " " +
                                                            STRING(i-linha) + " " +
                                                            string(tt_rpt_razao.tta_num_seq_lancto_ctbl_cpart)).   

          ASSIGN tt_rpt_razao.tta_des_histor_lancto_ctbl = REPLACE(tt_rpt_razao.tta_des_histor_lancto_ctbl, CHR(10), " ").
          ASSIGN tt_rpt_razao.tta_des_histor_lancto_ctbl = REPLACE(tt_rpt_razao.tta_des_histor_lancto_ctbl, ";", " ").
          ASSIGN tt_rpt_razao.tta_des_histor_lancto_ctbl = REPLACE(tt_rpt_razao.tta_des_histor_lancto_ctbl, CHR(13), " ").          
                                                                                                                                                 
          ASSIGN i-linha = i-linha + 1.   

          ASSIGN i-coluna = 1.

          /* Ajustando a contra-partida dos impostos sobre vendas */
          /*
          if trim(tt_rpt_razao.tta_cod_modul_dtsul) = "FTP" and tt_rpt_razao.tta_cod_espec_docto = "NFS" then do:
              if (tt_rpt_razao.tta_cod_cta_ctbl >= "32101001" and tt_rpt_razao.tta_cod_cta_ctbl <= "32101999") then
                  assign tt_rpt_razao.tta_cod_cta_ctbl_contra = tt_rpt_razao.cod_cta_ctbl_contra_Lancto.

              FIND cta_ctbl NO-LOCK WHERE
                     cta_ctbl.cod_plano_cta_ctbl = tt_rpt_razao.tta_cod_plano_cta_ctbl      AND  
                     cta_ctbl.cod_cta_ctbl       = tt_rpt_razao.tta_cod_cta_ctbl_contra     NO-ERROR.
                     IF AVAIL cta_ctbl THEN
                        ASSIGN tt_rpt_razao.des_tit_ctbl_Contra = cta_ctbl.des_tit_ctbl.

          end.
          */

          chExcelApplication:Cells(i-linha,i-coluna):NumberFormat = "@".
          chExcelApplication:Cells(i-linha,i-coluna):Value = tt_rpt_razao.tta_cod_plano_cta_ctbl.
          RUN Pi-I-Coluna.
          chExcelApplication:Cells(i-linha,i-coluna):NumberFormat = "@".
          chExcelApplication:Cells(i-linha,i-coluna):Value = tt-param.cod-cenar.
          RUN Pi-I-Coluna.
          chExcelApplication:Cells(i-linha,i-coluna):NumberFormat = "@".
          chExcelApplication:Cells(i-linha,i-coluna):Value = tt_rpt_razao.tta_cod_cta_ctbl .
          RUN Pi-I-Coluna.
          chExcelApplication:Cells(i-linha,i-coluna):NumberFormat = "@".
          chExcelApplication:Cells(i-linha,i-coluna):Value = tt_rpt_razao.tta_des_tit_ctbl.
          RUN Pi-I-Coluna.
          chExcelApplication:Cells(i-linha,i-coluna):NumberFormat  = "@".

          ASSIGN DATANOVA =  STRING(DAY(tt_rpt_razao.tta_dat_lancto_ctbl),"99")     + "/" +
                             STRING(MONTH(tt_rpt_razao.tta_dat_lancto_ctbl),"99")   + "/" +
                             STRING(YEAR(tt_rpt_razao.tta_dat_lancto_ctbl),"9999").

          chExcelApplication:Cells(i-linha,i-coluna):VALUE = DATANOVA. /*string(tt_rpt_razao.tta_dat_lancto_ctbl,"99/99/9999").  */
          RUN Pi-I-Coluna.
          chExcelApplication:Cells(i-linha,i-coluna):NumberFormat = "@".                                                                               
          chExcelApplication:Cells(i-linha,i-coluna):Value = tt_rpt_razao.tta_cod_modul_dtsul. 
          RUN Pi-I-Coluna.
          chExcelApplication:Cells(i-linha,i-coluna):NumberFormat = "@".                                                                               
          chExcelApplication:Cells(i-linha,i-coluna):Value = tt_rpt_razao.ge-codigo.
          RUN Pi-I-Coluna.
          chExcelApplication:Cells(i-linha,i-coluna):NumberFormat = "@".                                                                               
          chExcelApplication:Cells(i-linha,i-coluna):Value = STRING(tt_rpt_razao.it-codigo).  
          RUN Pi-I-Coluna.
          chExcelApplication:Cells(i-linha,i-coluna):NumberFormat = "@".                                                                               
          chExcelApplication:Cells(i-linha,i-coluna):Value = tt_rpt_razao.tta_cod_espec_docto.  
          RUN Pi-I-Coluna.
          chExcelApplication:Cells(i-linha,i-coluna):NumberFormat = "@".                                                                               
          chExcelApplication:Cells(i-linha,i-coluna):Value = tt_rpt_razao.tta_cod_ser_docto.
          RUN Pi-I-Coluna.
          chExcelApplication:Cells(i-linha,i-coluna):NumberFormat = "@".                                                                               
          chExcelApplication:Cells(i-linha,i-coluna):Value = tt_rpt_razao.tta_nro_docto .  
          RUN Pi-I-Coluna.
          chExcelApplication:Cells(i-linha,i-coluna):NumberFormat = "@".                                                                               
          chExcelApplication:Cells(i-linha,i-coluna):VALUE = if tt_rpt_razao.tta_cod_parcela <> "" then tt_rpt_razao.tta_cod_parcela  else "".   
          RUN Pi-I-Coluna.
          chExcelApplication:Cells(i-linha,i-coluna):Value = string(tt_rpt_razao.tta_cod_emitente).  
          RUN Pi-I-Coluna.
          chExcelApplication:Cells(i-linha,i-coluna):NumberFormat = "@".                                                                            
          chExcelApplication:Cells(i-linha,i-coluna):Value =(tt_rpt_razao.tta_nome-emit).                                                                           
          RUN Pi-I-Coluna.
          chExcelApplication:Cells(i-linha,i-coluna):Value = STRING(tt_rpt_razao.tta_num_lote_ctbl).     
          RUN Pi-I-Coluna.
          chExcelApplication:Cells(i-linha,i-coluna):VALUE = STRING(tt_rpt_razao.tta_num_lancto_ctbl).   
          RUN Pi-I-Coluna.
          chExcelApplication:Cells(i-linha,i-coluna):Value = STRING(tt_rpt_razao.tta_num_seq_lancto_ctbl).            
          RUN Pi-I-Coluna.
          chExcelApplication:Cells(i-linha,i-coluna):VALUE = "@".                                                                               
          chExcelApplication:Cells(i-linha,i-coluna):Value = tt_rpt_razao.tta_cod_estab.                                                               
          RUN Pi-I-Coluna.
          chExcelApplication:Cells(i-linha,i-coluna):NumberFormat = "@".                                                                               
          chExcelApplication:Cells(i-linha,i-coluna):Value = tt_rpt_razao.tta_cod_unid_negoc.  
          RUN Pi-I-Coluna.
          chExcelApplication:Cells(i-linha,i-coluna):NumberFormat = "@".                                                                               
          chExcelApplication:Cells(i-linha,i-coluna):Value = tt_rpt_razao.tta_cod_ccusto.
          RUN Pi-I-Coluna.
          chExcelApplication:Cells(i-linha,i-coluna):NumberFormat = "#.##0,00".                                                                        
          chExcelApplication:Cells(i-linha,i-coluna):Value = (tt_rpt_razao.tta_v_val_sdo_ctbl_ini). 
          RUN Pi-I-Coluna.
          chExcelApplication:Cells(i-linha,i-coluna):NumberFormat = "#.##0,00".                                                                        
          chExcelApplication:Cells(i-linha,i-coluna):VALUE = (tt_rpt_razao.ttv_val_lancto_ctbl_db).   
          RUN Pi-I-Coluna.
          chExcelApplication:Cells(i-linha,i-coluna):NumberFormat = "#.##0,00".                                                                        
          chExcelApplication:Cells(i-linha,i-coluna):VALUE = (tt_rpt_razao.ttv_val_lancto_ctbl_cr).   
          RUN Pi-I-Coluna.       
          chExcelApplication:Cells(i-linha,i-coluna):NumberFormat = "#.##0,00".                                                                        
          chExcelApplication:Cells(i-linha,i-coluna):VALUE = (ttv_val_lancto_ctbl_contra).
          RUN Pi-I-Coluna.
          chExcelApplication:Cells(i-linha,i-coluna):NumberFormat = "@".                                                                         
          chExcelApplication:Cells(i-linha,i-coluna):VALUE = string(tt_rpt_razao.tta_cod_cta_ctbl_contra).                                
          RUN Pi-I-Coluna.
          chExcelApplication:Cells(i-linha,i-coluna):NumberFormat = "@".                                                                         
          chExcelApplication:Cells(i-linha,i-coluna):VALUE = string(tt_rpt_razao.des_tit_ctbl_Contra).                     
          RUN Pi-I-Coluna.
          chExcelApplication:Cells(i-linha,i-coluna):NumberFormat = "#.##0,00".                                                                        
          chExcelApplication:Cells(i-linha,i-coluna):VALUE = (tt_rpt_razao.tta_v_val_sdo_ctbl_fim).  
          RUN Pi-I-Coluna.     
          chExcelApplication:Cells(i-linha,i-coluna):Value = tt_rpt_razao.tta_des_histor_lancto_ctbl.  
          RUN Pi-I-Coluna.
          chExcelApplication:Cells(i-linha,i-coluna):Value = tt_rpt_razao.cod_cta_ctbl_contra_Lancto.
                 
      END.

      RUN Pi_Excel_Footer.

/*********************************************************************/
/** Fim da logica **/

/* run pi-finalizar in h-acomp.  */

END PROCEDURE.

PROCEDURE Pi_Excel_Header:
      chExcelApplication:VISIBLE        = NO.                                                                                                           
      chExcelApplication:ScreenUpdating = NO.                                                                                                    
      chExcelApplication:WindowState    = -4137.                                                                                                 
                                                                                                                                                 
         ASSIGN i-plan = 1.                                                                                                                      
         chWorkSheet = chExcelApplication:Sheets:ITEM(i-plan).                                                                                   
                                                                                                                                                 
      chExcelApplication:Sheets(i-plan):SELECT.                                                                                                  
      chExcelApplication:Sheets(i-plan):NAME = "Raz∆o".                                                                                          
      chExcelApplication:ActiveSheet:PageSetup:PrintTitleRows     = "$1:$1".                                                                     
      chExcelApplication:ActiveSheet:PageSetup:TopMargin          = chExcelApplication:Application:CentimetersToPoints(0.5).                     
      chExcelApplication:ActiveSheet:PageSetup:BottomMargin       = chExcelApplication:Application:CentimetersToPoints(0.5).                     
      chExcelApplication:ActiveSheet:PageSetup:LeftMargin         = chExcelApplication:Application:CentimetersToPoints(0.5).                     
      chExcelApplication:ActiveSheet:PageSetup:RightMargin        = chExcelApplication:Application:CentimetersToPoints(0.5).                     
      chExcelApplication:ActiveSheet:PageSetup:Orientation        = 2. /** Folha Paisagem **/                                                    
      chExcelApplication:ActiveSheet:PageSetup:Zoom               = 100. /** Zomm impressao **/                                                  
      chExcelApplication:ActiveSheet:PageSetup:CenterHorizontally = TRUE.                                                                        
      chExcelApplication:ActiveSheet:PageSetup:CenterVertically   = FALSE.                                                                       
      chExcelApplication:Cells:Font:Size                          = 9.                                                                           
                                                                                                                                                 

      ASSIGN i-linha  = 2. 
      ASSIGN i-coluna = 1.
                                                                                                                                                 
      /********** COLUNAS ***************/                                                                                                       
      chExcelApplication:Cells(i-linha,i-coluna):NumberFormat = "@".
      chExcelApplication:Cells(i-linha,i-coluna):Value = "Plano Contas".
      chExcelApplication:Cells(i-linha,i-coluna):WrapText = True.
      chExcelApplication:Cells(i-linha,i-coluna):Font:Bold = true.
      RUN Pi-I-Coluna.
      chExcelApplication:Cells(i-linha,i-coluna):NumberFormat = "@".
      chExcelApplication:Cells(i-linha,i-coluna):Value = "Cenario".
      chExcelApplication:Cells(i-linha,i-coluna):WrapText = True.
      chExcelApplication:Cells(i-linha,i-coluna):Font:Bold = true.
      RUN Pi-I-Coluna.
      chExcelApplication:Cells(i-linha,i-coluna):NumberFormat = "@".
      chExcelApplication:Cells(i-linha,i-coluna):Value = "Conta Contabil".
      chExcelApplication:Cells(i-linha,i-coluna):WrapText = True.
      chExcelApplication:Cells(i-linha,i-coluna):Font:Bold = true.
      RUN Pi-I-Coluna.
      chExcelApplication:Cells(i-linha,i-coluna):NumberFormat = "@".
      chExcelApplication:Cells(i-linha,i-coluna):Value = "Descriá∆o Conta".
      chExcelApplication:Cells(i-linha,i-coluna):WrapText = True.
      chExcelApplication:Cells(i-linha,i-coluna):Font:Bold = true.
      RUN Pi-I-Coluna.
      chExcelApplication:Cells(i-linha,i-coluna):NumberFormat = "@".
      chExcelApplication:Cells(i-linha,i-coluna):Value = "Data".
      chExcelApplication:Cells(i-linha,i-coluna):WrapText = True.
      chExcelApplication:Cells(i-linha,i-coluna):Font:Bold = true.
      RUN Pi-I-Coluna.
      chExcelApplication:Cells(i-linha,i-coluna):NumberFormat = "@".
      chExcelApplication:Cells(i-linha,i-coluna):Value = "M¢dulo".
      chExcelApplication:Cells(i-linha,i-coluna):WrapText = True.
      chExcelApplication:Cells(i-linha,i-coluna):Font:Bold = true.
      RUN Pi-I-Coluna.
      chExcelApplication:Cells(i-linha,i-coluna):NumberFormat = "@".
      chExcelApplication:Cells(i-linha,i-coluna):Value = "G.E.".
      chExcelApplication:Cells(i-linha,i-coluna):WrapText = True.
      chExcelApplication:Cells(i-linha,i-coluna):Font:Bold = true.
      RUN Pi-I-Coluna.
      chExcelApplication:Cells(i-linha,i-coluna):NumberFormat = "@".
      chExcelApplication:Cells(i-linha,i-coluna):Value = "Item".
      chExcelApplication:Cells(i-linha,i-coluna):WrapText = True.
      chExcelApplication:Cells(i-linha,i-coluna):Font:Bold = true.
      RUN Pi-I-Coluna.
      chExcelApplication:Cells(i-linha,i-coluna):NumberFormat = "@".
      chExcelApplication:Cells(i-linha,i-coluna):Value = "Esp".
      chExcelApplication:Cells(i-linha,i-coluna):WrapText = True.
      chExcelApplication:Cells(i-linha,i-coluna):Font:Bold = true.
      RUN Pi-I-Coluna.
      chExcelApplication:Cells(i-linha,i-coluna):NumberFormat = "@".
      chExcelApplication:Cells(i-linha,i-coluna):Value = "SÇrie".
      chExcelApplication:Cells(i-linha,i-coluna):WrapText = True.
      chExcelApplication:Cells(i-linha,i-coluna):Font:Bold = true.
      RUN Pi-I-Coluna.
      chExcelApplication:Cells(i-linha,i-coluna):NumberFormat = "@".
      chExcelApplication:Cells(i-linha,i-coluna):Value = "Docto".
      chExcelApplication:Cells(i-linha,i-coluna):WrapText = True.
      chExcelApplication:Cells(i-linha,i-coluna):Font:Bold = true.
      RUN Pi-I-Coluna.
      chExcelApplication:Cells(i-linha,i-coluna):NumberFormat = "@".
      chExcelApplication:Cells(i-linha,i-coluna):Value = "Parc".
      chExcelApplication:Cells(i-linha,i-coluna):WrapText = True.
      chExcelApplication:Cells(i-linha,i-coluna):Font:Bold = true.
      RUN Pi-I-Coluna.
      chExcelApplication:Cells(i-linha,i-coluna):NumberFormat = "@".
      chExcelApplication:Cells(i-linha,i-coluna):Value = "Emitente".
      chExcelApplication:Cells(i-linha,i-coluna):WrapText = True.
      chExcelApplication:Cells(i-linha,i-coluna):Font:Bold = true.
      RUN Pi-I-Coluna.
      chExcelApplication:Cells(i-linha,i-coluna):NumberFormat = "@".
      chExcelApplication:Cells(i-linha,i-coluna):Value = "Raz∆o Social".
      chExcelApplication:Cells(i-linha,i-coluna):WrapText = True.
      chExcelApplication:Cells(i-linha,i-coluna):Font:Bold = true.
      RUN Pi-I-Coluna.
      chExcelApplication:Cells(i-linha,i-coluna):NumberFormat = "@".
      chExcelApplication:Cells(i-linha,i-coluna):Value = "Lote".
      chExcelApplication:Cells(i-linha,i-coluna):WrapText = True.
      chExcelApplication:Cells(i-linha,i-coluna):Font:Bold = true.
      RUN Pi-I-Coluna.
      chExcelApplication:Cells(i-linha,i-coluna):NumberFormat = "@".
      chExcelApplication:Cells(i-linha,i-coluna):Value = "Lancto".
      chExcelApplication:Cells(i-linha,i-coluna):WrapText = True.
      chExcelApplication:Cells(i-linha,i-coluna):Font:Bold = true.
      RUN Pi-I-Coluna.
      chExcelApplication:Cells(i-linha,i-coluna):NumberFormat = "@".
      chExcelApplication:Cells(i-linha,i-coluna):Value = "Seq".
      chExcelApplication:Cells(i-linha,i-coluna):WrapText = True.
      chExcelApplication:Cells(i-linha,i-coluna):Font:Bold = true.
      RUN Pi-I-Coluna.
      chExcelApplication:Cells(i-linha,i-coluna):NumberFormat = "@".
      chExcelApplication:Cells(i-linha,i-coluna):Value = "Estab".
      chExcelApplication:Cells(i-linha,i-coluna):WrapText = True.
      chExcelApplication:Cells(i-linha,i-coluna):Font:Bold = true.
      RUN Pi-I-Coluna.
      chExcelApplication:Cells(i-linha,i-coluna):NumberFormat = "@".
      chExcelApplication:Cells(i-linha,i-coluna):Value = "Unidade de Neg¢cio".
      chExcelApplication:Cells(i-linha,i-coluna):WrapText = True.
      chExcelApplication:Cells(i-linha,i-coluna):Font:Bold = true.
      RUN Pi-I-Coluna.
      chExcelApplication:Cells(i-linha,i-coluna):NumberFormat = "@".
      chExcelApplication:Cells(i-linha,i-coluna):Value = "Centro Custo".
      chExcelApplication:Cells(i-linha,i-coluna):WrapText = True.
      chExcelApplication:Cells(i-linha,i-coluna):Font:Bold = true.
      RUN Pi-I-Coluna.
      chExcelApplication:Cells(i-linha,i-coluna):NumberFormat = "@".
      chExcelApplication:Cells(i-linha,i-coluna):Value = "S.Anterior".
      chExcelApplication:Cells(i-linha,i-coluna):WrapText = True.
      chExcelApplication:Cells(i-linha,i-coluna):Font:Bold = true.
      RUN Pi-I-Coluna.
      chExcelApplication:Cells(i-linha,i-coluna):NumberFormat = "@".
      chExcelApplication:Cells(i-linha,i-coluna):Value = "Movto Debito".
      chExcelApplication:Cells(i-linha,i-coluna):WrapText = True.
      chExcelApplication:Cells(i-linha,i-coluna):Font:Bold = true.
      RUN Pi-I-Coluna.
      chExcelApplication:Cells(i-linha,i-coluna):NumberFormat = "@".
      chExcelApplication:Cells(i-linha,i-coluna):Value = "Movto Credito".
      chExcelApplication:Cells(i-linha,i-coluna):WrapText = True.
      chExcelApplication:Cells(i-linha,i-coluna):Font:Bold = true.
      RUN Pi-I-Coluna.
      chExcelApplication:Cells(i-linha,i-coluna):NumberFormat = "@".
      chExcelApplication:Cells(i-linha,i-coluna):Value = "Movto Contra_P".
      chExcelApplication:Cells(i-linha,i-coluna):WrapText = True.
      chExcelApplication:Cells(i-linha,i-coluna):Font:Bold = true.
      RUN Pi-I-Coluna.
      chExcelApplication:Cells(i-linha,i-coluna):NumberFormat = "@".
      chExcelApplication:Cells(i-linha,i-coluna):Value = "Contra Partida".
      chExcelApplication:Cells(i-linha,i-coluna):WrapText = True.
      chExcelApplication:Cells(i-linha,i-coluna):Font:Bold = true.
      RUN Pi-I-Coluna.
      chExcelApplication:Cells(i-linha,i-coluna):NumberFormat = "@".
      chExcelApplication:Cells(i-linha,i-coluna):Value = "Contra Titulo".
      chExcelApplication:Cells(i-linha,i-coluna):WrapText = True.
      chExcelApplication:Cells(i-linha,i-coluna):Font:Bold = true.
      RUN Pi-I-Coluna.
      chExcelApplication:Cells(i-linha,i-coluna):NumberFormat = "@".
      chExcelApplication:Cells(i-linha,i-coluna):Value = "Saldo Final".
      chExcelApplication:Cells(i-linha,i-coluna):WrapText = True.
      chExcelApplication:Cells(i-linha,i-coluna):Font:Bold = true.
      RUN Pi-I-Coluna.
      chExcelApplication:Cells(i-linha,i-coluna):NumberFormat = "@".
      chExcelApplication:Cells(i-linha,i-coluna):Value = "Historico".
      chExcelApplication:Cells(i-linha,i-coluna):WrapText = True.
      chExcelApplication:Cells(i-linha,i-coluna):Font:Bold = true.
      RUN Pi-I-Coluna.
      chExcelApplication:Cells(i-linha,i-coluna):NumberFormat = "@".
      chExcelApplication:Cells(i-linha,i-coluna):Value = "CP.Item_Lancto".
      chExcelApplication:Cells(i-linha,i-coluna):WrapText = True.
      chExcelApplication:Cells(i-linha,i-coluna):Font:Bold = true.

      chexcelapplication:range("A01:U01"):HorizontalAlignment = 3.  

END PROCEDURE.

PROCEDURE Pi_Excel_Footer:

        chWorkSheet = chExcelApplication:Sheets:ITEM(1).
        chWorkSheet:Activate().
        chExcelApplication:Range("A2"):Select.
        chExcelApplication:Cells:EntireRow:AutoFit.

       /*Para AutoFiltro: */
        chWorksheet:Range("A2:Z2"):SELECT. /* Comando RANGE(CL:CL) = Seleciona a Coluna e a Linha especificada */
        chExcelApplication:SELECTION:AutoFilter(,,,).
        
        /*Congelar Paineis*/
        chExcelApplication:Range("A3"):SELECT.              /* Comando RANGE(CL:CL) = Seleciona a Coluna e a Linha especificada */
        chExcelApplication:ActiveWindow:FreezePanes = TRUE. /* Ativa o congelamento da linha/coluna na cÇlula informada */

        chWorkSheet:Range("V1"):value = '= subtotal(9,V3:V65000)':U.
        chWorkSheet:Range("W1"):value = '= subtotal(9,W3:W65000)':U.

        chWorksheet:Range("V1:V1"):NumberFormat = "#.##0,00".
        chWorksheet:Range("W1:W1"):NumberFormat = "#.##0,00".

        chWorksheet:Range("V3:V65000"):numberformat = "#.##0,00".
        chWorksheet:Range("W3:W65000"):numberformat = "#.##0,00".
                                                                                                                                             
        chExcelApplication:Cursor =-4143.                                                                                                          
        chExcelApplication:WindowState = -4137.                                                                                                    
                                                                                                                                             
        chExcelApplication:ScreenUpdating = YES.                                                                                                   
                                                                                                                                                 
        chExcelApplication:VISIBLE = TRUE.                                                                                                   
        chexcelapplication:activeworkbook:SAVED = YES.

         RELEASE OBJECT chWorkbook.
/*          RELEASE OBJECT chDesktop.  */
         RELEASE OBJECT chWorksheet.

      RELEASE OBJECT chExcelApplication.

END PROCEDURE.


PROCEDURE Pi-I-Coluna:
    ASSIGN i-coluna = i-coluna + 1.
END PROCEDURE.


PROCEDURE Pi_Sumar_Cep:
    EMPTY TEMP-TABLE tt_rpt_razao_cep.
/*     wsa  */
    for each tt_rpt_razao WHERE
             tt_rpt_razao.tta_cod_modul_dtsul = "CEP":

        FIND tt_rpt_razao_cep WHERE
             tt_rpt_razao_cep.tta_cod_ccusto            = tt_rpt_razao.tta_cod_ccusto           AND
             tt_rpt_razao_cep.tta_cod_plano_cta_ctbl    = tt_rpt_razao.tta_cod_plano_cta_ctbl   AND
             tt_rpt_razao_cep.tta_cod_cta_ctbl          = tt_rpt_razao.tta_cod_cta_ctbl         AND
             tt_rpt_razao_cep.tta_num_lote_ctbl         = tt_rpt_razao.tta_num_lote_ctbl        AND
             tt_rpt_razao_cep.tta_num_lancto_ctbl       = tt_rpt_razao.tta_num_lancto_ctbl      AND
             tt_rpt_razao_cep.tta_cod_modul_dtsul       = tt_rpt_razao.tta_cod_modul_dtsul      AND
             tt_rpt_razao_cep.tta_cod_estab             = tt_rpt_razao.tta_cod_estab            AND
             tt_rpt_razao_cep.tta_cod_unid_negoc        = tt_rpt_razao.tta_cod_unid_negoc       AND
             tt_rpt_razao_cep.tta_dat_lancto_ctbl       = tt_rpt_razao.tta_dat_lancto_ctbl      AND
             tt_rpt_razao_cep.tta_cod_emitente          = tt_rpt_razao.tta_cod_emitente         AND
             tt_rpt_razao_cep.tta_cod_espec_docto       = tt_rpt_razao.tta_cod_espec_docto      AND
             tt_rpt_razao_cep.tta_cod_ser_docto         = tt_rpt_razao.tta_cod_ser_docto        AND
             tt_rpt_razao_cep.tta_nro_docto             = tt_rpt_razao.tta_nro_docto            AND
             tt_rpt_razao_cep.tta_dat_emissao           = tt_rpt_razao.tta_dat_emissao          AND
             tt_rpt_razao_cep.tta_cod_cta_ctbl_contra   = tt_rpt_razao.tta_cod_cta_ctbl_contra  AND
             tt_rpt_razao_cep.ge-codigo                 = tt_rpt_razao.ge-codigo  
             NO-ERROR.
             IF NOT AVAIL tt_rpt_razao_cep THEN DO:
                 CREATE  tt_rpt_razao_cep.
                 BUFFER-COPY  tt_rpt_razao TO  tt_rpt_razao_cep.
                 ASSIGN tt_rpt_razao_cep.it-codigo = "".
             END.
             ELSE DO:
                 ASSIGN tt_rpt_razao_cep.ttv_val_lancto_ctbl_db     = tt_rpt_razao_cep.ttv_val_lancto_ctbl_db       + tt_rpt_razao.ttv_val_lancto_ctbl_db 
                        tt_rpt_razao_cep.ttv_val_lancto_ctbl_cr     = tt_rpt_razao_cep.ttv_val_lancto_ctbl_cr       + tt_rpt_razao.ttv_val_lancto_ctbl_cr
                        tt_rpt_razao_cep.tta_val_sdo_ctbl_fim       = tt_rpt_razao_cep.tta_val_sdo_ctbl_fim         + tt_rpt_razao.tta_val_sdo_ctbl_fim
                        tt_rpt_razao_cep.ttv_val_lancto_ctbl_contra = tt_rpt_razao_cep.ttv_val_lancto_ctbl_contra   + tt_rpt_razao.ttv_val_lancto_ctbl_contra   
                        tt_rpt_razao_cep.tta_v_val_sdo_ctbl_fim     = tt_rpt_razao_cep.tta_v_val_sdo_ctbl_fim       + tt_rpt_razao.tta_v_val_sdo_ctbl_fim
                        tt_rpt_razao_cep.tta_v_val_sdo_ctbl_ini     = tt_rpt_razao_cep.tta_v_val_sdo_ctbl_ini       + tt_rpt_razao.tta_v_val_sdo_ctbl_ini.
             END.

    DELETE tt_rpt_razao.
    END.

    FOR EACH tt_rpt_razao_cep:
        CREATE tt_rpt_razao.
        BUFFER-COPY tt_rpt_razao_cep TO tt_rpt_razao.
    END.

    EMPTY TEMP-TABLE tt_rpt_razao_cep.

END PROCEDURE.

/* AlteraÁ„o para correÁ„o do valor anterior, solicitada por Guilherme Fabiano - TSA em mar/26 por VinÌcius Oliveira - TSA */
PROCEDURE pi_busca_valor_ini.
   
   ASSIGN c-data-entrada = tt_rpt_razao.tta_dat_lancto_ctbl.
   ASSIGN c-data-ini = DATE(MONTH(c-data-entrada), 1, YEAR(c-data-entrada)).
   ASSIGN c-dia = DAY(c-data-entrada). 
   ASSIGN c-ultimo-dia = DAY(DATE(MONTH(c-data-entrada) + 1, 1, YEAR(c-data-entrada)) - 1).
       
   IF c-dia = 1 OR c-dia = c-ultimo-dia THEN 
       ASSIGN   c-data-ini = c-data-entrada
                c-data-fim = c-data-entrada.
   ELSE 
       ASSIGN c-data-fim = c-data-entrada - 1.
          
   FOR EACH lancto_ctbl where lancto_ctbl.dat_lancto_ctbl >= c-data-ini
                          and lancto_ctbl.dat_lancto_ctbl <= c-data-fim
                          and lancto_ctbl.cod_empresa = tt_rpt_razao_cep.tta_cod_estab,
       EACH aprop_lancto_ctbl OF lancto_ctbl,
       EACH item_lancto_ctbl OF aprop_lancto_ctbl WHERE item_lancto_ctbl.cod_cta_ctbl = tt_rpt_razao.tta_cod_cta_ctbl
                                                    AND item_lancto_ctbl.dat_lancto_ctbl = tt_rpt_razao.tta_dat_lancto_ctbl 
													BREAK BY lancto_ctbl.num_lancto_ctbl.
      
       IF item_lancto_ctbl.ind_natur_lancto_ctbl = "DB" THEN ASSIGN c-calc-fim = c-calc-fim + aprop_lancto_ctbl.val_lancto_ctbl.
       
	   IF item_lancto_ctbl.ind_natur_lancto_ctbl = "CR" THEN ASSIGN c-calc-fim = c-calc-fim - aprop_lancto_ctbl.val_lancto_ctbl.
          
       IF LAST-OF(lancto_ctbl.num_lancto_ctbl) THEN RUN pi_calcula_fim.    
       
	   IF LAST-OF(lancto_ctbl.num_lancto_ctbl) THEN DO:
	   
           IF c-dia = 1 THEN 
               ASSIGN c-valor-ini = c-calc-ctbl.
           ELSE IF c-dia = c-ultimo-dia THEN 
               ASSIGN c-valor-ini = c-calc-ctbl - c-calc-fim.
           ELSE IF c-dia > 1 AND c-dia < c-ultimo-dia THEN 
               ASSIGN c-valor-ini = c-calc-ctbl + c-calc-fim.
			   
       END.
   
   END.

END PROCEDURE.

PROCEDURE pi_calcula_fim.

    FOR EACH sdo_ctbl NO-LOCK WHERE sdo_ctbl.dat_sdo_ctbl     <= c-data-entrada 
                                AND sdo_ctbl.dat_sdo_ctbl     >= c-data-entrada - 30
                                AND sdo_ctbl.cod_empresa      = item_lancto_ctbl.cod_empresa
                                AND sdo_ctbl.cod_cta_ctbl     = item_lancto_ctbl.cod_cta_ctbl.                
    
        ASSIGN c-calc-ctbl = c-calc-ctbl + sdo_ctbl.val_sdo_ctbl_fim.  

    END.  
    
END PROCEDURE.
/* Fim alteraÁ„o */