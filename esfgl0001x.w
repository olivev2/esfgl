&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI ADM1
&ANALYZE-RESUME
&Scoped-define WINDOW-NAME w-relat
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS w-relat 
/****************************************************************************
**
**  Programa: ESFGL0001x.W
**     Autor: TOTVS - DRG-SP-Campinas
**  Objetivo: Relat¢rio Raz∆o 
**    Versao: 1.00.00.000
**      Data: 18/05/2016
**
****************************************************************************/
{include/i-prgvrs.i ESFGL0001x 1.00.00.000}

&IF "{&EMSFND_VERSION}" >= "1.00" &THEN
    {include/i-license-manager.i ESFGL0001x FGL}
&ENDIF

/* Create an unnamed pool to store all the widgets created 
     by this procedure. This is a good default which assures
     that this procedure's triggers and internal procedures 
     will execute in this procedure's storage, and that proper
     cleanup will occur on deletion of the procedure. */

CREATE WIDGET-POOL.

/* ***************************  Definitions  ************************** */

/*:T Preprocessadores do Template de Relat¢rio                            */
/*:T Obs: Retirar o valor do preprocessador para as p†ginas que n∆o existirem  */

&GLOBAL-DEFINE PGSEL f-pg-sel
&GLOBAL-DEFINE PGCLA 
&GLOBAL-DEFINE PGPAR f-pg-par
&GLOBAL-DEFINE PGDIG 
&GLOBAL-DEFINE PGIMP f-pg-imp

&GLOBAL-DEFINE RTF   NO
  
/* Parameters Definitions ---                                           */

/* Temporary Table Definitions ---                                      */

def temp-table tt-param no-undo
    field rs-execucao      as int
    field destino          as integer
    field arquivo          as char format "x(35)"
    field usuario          as char format "x(12)"
    field data-exec        as DATE FORMAT "99/99/9999"
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

define temp-table tt-digita no-undo
    field ordem            as integer   format ">>>>9"
    field exemplo          as character format "x(30)"
    index id ordem.

define buffer b-tt-digita for tt-digita.

/* Transfer Definitions */

def var raw-param        as raw no-undo.

def temp-table tt-raw-digita
   field raw-digita      as raw.
                    
/* Local Variable Definitions ---                                       */

def var l-ok               as logical no-undo.
def var c-arq-digita       as char    no-undo.
def var c-terminal         as char    no-undo.
def var c-rtf              as char    no-undo.
def var c-modelo-default   as char    no-undo.

/*15/02/2005 - tech1007 - Variavel definida para tratar se o programa est† rodando no WebEnabler*/
DEFINE SHARED VARIABLE hWenController AS HANDLE NO-UNDO.

def new global shared var v_cod_usuar_corren as character format "x(12)":U label "Usuˇrio Corrente" column-label "Usuˇrio Corrente" no-undo.
def new global shared var v_cod_empres_usuar as character format "x(3)":U label "Empresa" column-label "Empresa" no-undo.

def new global shared var v_rec_plano_cta_ctbl as recid format ">>>>>>9" initial ? no-undo.
def new global shared var v_rec_cenar_ctbl     as recid format ">>>>>>9" initial ? no-undo.
def new global shared var v_rec_finalid_econ   as recid format ">>>>>>9" initial ? no-undo.

def var v_rec_table           as recid format ">>>>>>9" initial ?  no-undo.
def var v_cod_return          as CHARACTER format "x(40)":U no-undo.

DEF BUFFER b_finalid_econ FOR finalid_econ.

{include/i-plano_ctbl.i}

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE w-relat
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME f-pg-imp

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS rect-rtf RECT-7 RECT-9 bt-arquivo ~
rs-execucao text-rtf text-modelo-rtf 
&Scoped-Define DISPLAYED-OBJECTS rs-destino c-arquivo l-habilitaRtf ~
c-modelo-rtf rs-execucao text-rtf text-modelo-rtf 

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */
&Scoped-define List-1 bt-plano bt-cenario bt-finalid-1 bt-finalid-2 

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define the widget handle for the window                              */
DEFINE VAR w-relat AS WIDGET-HANDLE NO-UNDO.

/* Definitions of the field level widgets                               */
DEFINE BUTTON bt-arquivo 
     IMAGE-UP FILE "image\im-sea":U
     IMAGE-INSENSITIVE FILE "image\ii-sea":U
     LABEL "" 
     SIZE 4 BY 1.

DEFINE BUTTON bt-config-impr 
     IMAGE-UP FILE "image\im-cfprt":U
     LABEL "" 
     SIZE 4 BY 1.

DEFINE BUTTON bt-modelo-rtf 
     IMAGE-UP FILE "image\im-sea":U
     IMAGE-INSENSITIVE FILE "image\ii-sea":U
     LABEL "" 
     SIZE 4 BY 1.

DEFINE VARIABLE c-arquivo AS CHARACTER 
     VIEW-AS EDITOR MAX-CHARS 256
     SIZE 40 BY .88
     BGCOLOR 15  NO-UNDO.

DEFINE VARIABLE c-modelo-rtf AS CHARACTER 
     VIEW-AS EDITOR MAX-CHARS 256
     SIZE 40 BY .88
     BGCOLOR 15  NO-UNDO.

DEFINE VARIABLE text-destino AS CHARACTER FORMAT "X(256)":U INITIAL " Destino" 
      VIEW-AS TEXT 
     SIZE 8.57 BY .63 NO-UNDO.

DEFINE VARIABLE text-modelo-rtf AS CHARACTER FORMAT "X(256)":U INITIAL "Modelo:" 
      VIEW-AS TEXT 
     SIZE 10.86 BY .63 NO-UNDO.

DEFINE VARIABLE text-modo AS CHARACTER FORMAT "X(256)":U INITIAL "Execuá∆o" 
      VIEW-AS TEXT 
     SIZE 10.86 BY .63 NO-UNDO.

DEFINE VARIABLE text-rtf AS CHARACTER FORMAT "X(256)":U INITIAL "Rich Text Format(RTF)" 
      VIEW-AS TEXT 
     SIZE 20.86 BY .63 NO-UNDO.

DEFINE VARIABLE rs-destino AS INTEGER INITIAL 2 
     VIEW-AS RADIO-SET HORIZONTAL
     RADIO-BUTTONS 
          "Impressora", 1,
"Arquivo", 2,
"Terminal", 3
     SIZE 44 BY 1.08 NO-UNDO.

DEFINE VARIABLE rs-execucao AS INTEGER INITIAL 1 
     VIEW-AS RADIO-SET HORIZONTAL
     RADIO-BUTTONS 
          "On-Line", 1,
"Batch", 2
     SIZE 27.72 BY .92 NO-UNDO.

DEFINE RECTANGLE RECT-7
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
     SIZE 46.29 BY 2.79.

DEFINE RECTANGLE RECT-9
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
     SIZE 46.29 BY 1.71.

DEFINE RECTANGLE rect-rtf
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
     SIZE 46.29 BY 3.54.

DEFINE VARIABLE l-habilitaRtf AS LOGICAL INITIAL no 
     LABEL "RTF" 
     VIEW-AS TOGGLE-BOX
     SIZE 44 BY 1.08 NO-UNDO.

DEFINE BUTTON bt-cenario 
     IMAGE-UP FILE "image/im-zoo":U
     IMAGE-INSENSITIVE FILE "image\ii-zoo":U
     LABEL "" 
     SIZE 4 BY 1.

DEFINE BUTTON bt-finalid-1 
     IMAGE-UP FILE "image/im-zoo":U
     IMAGE-INSENSITIVE FILE "image\ii-zoo":U
     LABEL "" 
     SIZE 4 BY 1.

DEFINE BUTTON bt-finalid-2 
     IMAGE-UP FILE "image/im-zoo":U
     IMAGE-INSENSITIVE FILE "image\ii-zoo":U
     LABEL "" 
     SIZE 4 BY 1.

DEFINE BUTTON bt-plano 
     IMAGE-UP FILE "image/im-zoo":U
     IMAGE-INSENSITIVE FILE "image\ii-zoo":U
     LABEL "" 
     SIZE 4 BY 1.

DEFINE VARIABLE c-arquivo-2 AS CHARACTER FORMAT "X(256)":U 
     VIEW-AS FILL-IN 
     SIZE 67 BY .88 NO-UNDO.

DEFINE VARIABLE fi-base AS CHARACTER FORMAT "x(8)" INITIAL "Corrente" 
     LABEL "Finalidade Base" 
     VIEW-AS FILL-IN 
     SIZE 12 BY .88 NO-UNDO.

DEFINE VARIABLE fi-cenar AS CHARACTER FORMAT "x(8)" INITIAL "Fiscal" 
     LABEL "Cen†rio Contabil" 
     VIEW-AS FILL-IN 
     SIZE 12 BY .88 NO-UNDO.

DEFINE VARIABLE fi-conv AS CHARACTER FORMAT "x(8)" INITIAL "Corrente" 
     LABEL "Finalid Converte" 
     VIEW-AS FILL-IN 
     SIZE 12 BY .88 NO-UNDO.

DEFINE VARIABLE fi-dt-conv AS DATE FORMAT "99/99/9999" INITIAL 01/01/00 
     LABEL "Data Cotaá∆o" 
     VIEW-AS FILL-IN 
     SIZE 12 BY .88 NO-UNDO.

DEFINE VARIABLE fi-plano AS CHARACTER FORMAT "x(8)" 
     LABEL "Plano Contas" 
     VIEW-AS FILL-IN 
     SIZE 12 BY .88 NO-UNDO.

DEFINE VARIABLE rs-forma AS INTEGER INITIAL 1 
     VIEW-AS RADIO-SET VERTICAL
     RADIO-BUTTONS 
          "Excel", 1
     SIZE 23.43 BY 2.25 NO-UNDO.

DEFINE RECTANGLE RECT-13
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
     SIZE 27 BY 3.13.

DEFINE RECTANGLE RECT-8
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
     SIZE 72.86 BY 1.5.

DEFINE VARIABLE tg-con-ct-int AS LOGICAL INITIAL no 
     LABEL "Considera Conta Internacional?" 
     VIEW-AS TOGGLE-BOX
     SIZE 25.29 BY .83 NO-UNDO.

DEFINE VARIABLE tg-con-res AS LOGICAL INITIAL no 
     LABEL "Considera Apuraá∆o Resultado?" 
     VIEW-AS TOGGLE-BOX
     SIZE 25.43 BY .83 NO-UNDO.

DEFINE VARIABLE tg-ct-part AS LOGICAL INITIAL no 
     LABEL "Imprime Contra Partida" 
     VIEW-AS TOGGLE-BOX
     SIZE 25.29 BY .83 NO-UNDO.

DEFINE VARIABLE tg-parametros AS LOGICAL INITIAL yes 
     LABEL "Imprime ParÉmetros?" 
     VIEW-AS TOGGLE-BOX
     SIZE 22.86 BY .83 NO-UNDO.

DEFINE VARIABLE fi-bu-f AS CHARACTER FORMAT "X(3)":U INITIAL "ZZZ" 
     VIEW-AS FILL-IN 
     SIZE 5 BY .88 NO-UNDO.

DEFINE VARIABLE fi-bu-i AS CHARACTER FORMAT "X(3)":U 
     LABEL "Unidade Neg¢cio" 
     VIEW-AS FILL-IN 
     SIZE 5 BY .88 NO-UNDO.

DEFINE VARIABLE fi-ccusto-fim AS CHARACTER FORMAT "X(20)":U INITIAL "ZZZZZZZZZZZZZZZZZZZZ" 
     VIEW-AS FILL-IN 
     SIZE 22 BY .88 NO-UNDO.

DEFINE VARIABLE fi-ccusto-ini AS CHARACTER FORMAT "X(20)":U 
     LABEL "Centro de Custo" 
     VIEW-AS FILL-IN 
     SIZE 22 BY .88 NO-UNDO.

DEFINE VARIABLE fi-ct-f AS CHARACTER FORMAT "X(20)":U INITIAL "ZZZZZZZZZZZZZZZZZZZZ" 
     VIEW-AS FILL-IN 
     SIZE 22 BY .88 NO-UNDO.

DEFINE VARIABLE fi-ct-i AS CHARACTER FORMAT "X(20)":U 
     LABEL "Conta Cont†bil" 
     VIEW-AS FILL-IN 
     SIZE 22 BY .88 NO-UNDO.

DEFINE VARIABLE fi-est-f AS CHARACTER FORMAT "X(3)":U INITIAL "ZZZ" 
     VIEW-AS FILL-IN 
     SIZE 5 BY .88 NO-UNDO.

DEFINE VARIABLE fi-est-i AS CHARACTER FORMAT "X(3)":U 
     LABEL "Estabelecimento" 
     VIEW-AS FILL-IN 
     SIZE 5 BY .88 NO-UNDO.

DEFINE VARIABLE fi-lot-f AS INT64 FORMAT ">>>>>>>>9":U INITIAL 999999999 
     VIEW-AS FILL-IN 
     SIZE 12 BY .88 NO-UNDO.

DEFINE VARIABLE fi-lot-i AS INT64 FORMAT ">>>>>>>>9":U INITIAL 0 
     LABEL "Lote Contabil" 
     VIEW-AS FILL-IN 
     SIZE 11 BY .88 NO-UNDO.

DEFINE VARIABLE fi-mod-f AS CHARACTER FORMAT "X(3)":U INITIAL "ZZZ" 
     VIEW-AS FILL-IN 
     SIZE 5 BY .88 NO-UNDO.

DEFINE VARIABLE fi-mod-i AS CHARACTER FORMAT "X(3)":U 
     LABEL "M¢dulo" 
     VIEW-AS FILL-IN 
     SIZE 5 BY .88 NO-UNDO.

DEFINE VARIABLE fi-per-f AS DATE FORMAT "99/99/9999":U INITIAL 12/31/9999 
     VIEW-AS FILL-IN 
     SIZE 12 BY .88 NO-UNDO.

DEFINE VARIABLE fi-per-i AS DATE FORMAT "99/99/9999":U INITIAL 01/01/10 
     LABEL "Per°odo" 
     VIEW-AS FILL-IN 
     SIZE 12 BY .88 NO-UNDO.

DEFINE IMAGE IMAGE-1
     FILENAME "image\im-fir":U
     SIZE 3 BY .88.

DEFINE IMAGE IMAGE-10
     FILENAME "image\im-las":U
     SIZE 3 BY .88.

DEFINE IMAGE IMAGE-11
     FILENAME "image\im-fir":U
     SIZE 3 BY .88.

DEFINE IMAGE IMAGE-12
     FILENAME "image\im-las":U
     SIZE 3 BY .88.

DEFINE IMAGE IMAGE-15
     FILENAME "image\im-fir":U
     SIZE 3 BY .88.

DEFINE IMAGE IMAGE-16
     FILENAME "image\im-las":U
     SIZE 3 BY .88.

DEFINE IMAGE IMAGE-2
     FILENAME "image\im-las":U
     SIZE 3 BY .88.

DEFINE IMAGE IMAGE-3
     FILENAME "image\im-fir":U
     SIZE 3 BY .88.

DEFINE IMAGE IMAGE-4
     FILENAME "image\im-las":U
     SIZE 3 BY .88.

DEFINE IMAGE IMAGE-5
     FILENAME "image\im-fir":U
     SIZE 3 BY .88.

DEFINE IMAGE IMAGE-6
     FILENAME "image\im-las":U
     SIZE 3 BY .88.

DEFINE IMAGE IMAGE-7
     FILENAME "image\im-fir":U
     SIZE 3 BY .88.

DEFINE IMAGE IMAGE-8
     FILENAME "image\im-las":U
     SIZE 3 BY .88.

DEFINE IMAGE IMAGE-9
     FILENAME "image\im-fir":U
     SIZE 3 BY .88.

DEFINE VARIABLE RS-CEP AS INTEGER INITIAL 1 
     VIEW-AS RADIO-SET VERTICAL
     RADIO-BUTTONS 
          "CEP - SintÇtico", 1,
"CEP - An†litico", 2
     SIZE 21.86 BY 1.54 NO-UNDO.

DEFINE BUTTON bt-ajuda 
     LABEL "Ajuda" 
     SIZE 10 BY 1.

DEFINE BUTTON bt-cancelar AUTO-END-KEY 
     LABEL "Fechar" 
     SIZE 10 BY 1.

DEFINE BUTTON bt-executar 
     LABEL "Executar" 
     SIZE 10 BY 1.

DEFINE IMAGE im-pg-imp
     FILENAME "image\im-fldup":U
     SIZE 15.72 BY 1.21.

DEFINE IMAGE im-pg-par
     FILENAME "image\im-fldup":U
     SIZE 15.72 BY 1.21.

DEFINE IMAGE im-pg-sel
     FILENAME "image\im-fldup":U
     SIZE 15.72 BY 1.21.

DEFINE RECTANGLE RECT-1
     EDGE-PIXELS 2 GRAPHIC-EDGE    
     SIZE 79 BY 1.42
     BGCOLOR 7 .

DEFINE RECTANGLE RECT-6
     EDGE-PIXELS 0    
     SIZE 78.72 BY .13
     BGCOLOR 7 .

DEFINE RECTANGLE rt-folder
     EDGE-PIXELS 1 GRAPHIC-EDGE  NO-FILL   
     SIZE 79 BY 11.38
     FGCOLOR 0 .

DEFINE RECTANGLE rt-folder-left
     EDGE-PIXELS 0    
     SIZE .43 BY 11.21
     BGCOLOR 15 .

DEFINE RECTANGLE rt-folder-right
     EDGE-PIXELS 0    
     SIZE .43 BY 11.17
     BGCOLOR 7 .

DEFINE RECTANGLE rt-folder-top
     EDGE-PIXELS 0    
     SIZE 78.72 BY .13
     BGCOLOR 15 .


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME f-relat
     bt-executar AT ROW 14.54 COL 3 HELP
          "Dispara a execuá∆o do relat¢rio"
     bt-cancelar AT ROW 14.54 COL 14 HELP
          "Fechar"
     bt-ajuda AT ROW 14.54 COL 70 HELP
          "Ajuda"
     RECT-1 AT ROW 14.29 COL 2
     RECT-6 AT ROW 13.75 COL 2.14
     rt-folder-top AT ROW 2.54 COL 2.14
     rt-folder-right AT ROW 2.67 COL 80.43
     rt-folder-left AT ROW 2.54 COL 2.14
     rt-folder AT ROW 2.5 COL 2
     im-pg-imp AT ROW 1.5 COL 33.57
     im-pg-par AT ROW 1.5 COL 17.86
     im-pg-sel AT ROW 1.5 COL 2.14
    WITH 1 DOWN NO-BOX KEEP-TAB-ORDER OVERLAY 
         SIDE-LABELS NO-UNDERLINE THREE-D 
         AT COL 1 ROW 1
         SIZE 81 BY 15
         DEFAULT-BUTTON bt-executar WIDGET-ID 100.

DEFINE FRAME f-pg-imp
     rs-destino AT ROW 1.63 COL 3.29 HELP
          "Destino de Impress∆o do Relat¢rio" NO-LABEL
     bt-config-impr AT ROW 2.67 COL 43.29 HELP
          "Configuraá∆o da impressora"
     bt-arquivo AT ROW 2.71 COL 43.29 HELP
          "Escolha do nome do arquivo"
     c-arquivo AT ROW 2.75 COL 3.29 HELP
          "Nome do arquivo de destino do relat¢rio" NO-LABEL
     l-habilitaRtf AT ROW 4.83 COL 3.29
     c-modelo-rtf AT ROW 6.63 COL 3 HELP
          "Nome do arquivo de modelo do relat¢rio" NO-LABEL
     bt-modelo-rtf AT ROW 6.63 COL 43 HELP
          "Escolha do nome do arquivo"
     rs-execucao AT ROW 8.88 COL 2.86 HELP
          "Modo de Execuá∆o" NO-LABEL
     text-destino AT ROW 1.04 COL 3.86 NO-LABEL
     text-rtf AT ROW 4.17 COL 1.14 COLON-ALIGNED NO-LABEL
     text-modelo-rtf AT ROW 5.96 COL 1.14 COLON-ALIGNED NO-LABEL
     text-modo AT ROW 8.13 COL 1.14 COLON-ALIGNED NO-LABEL
     rect-rtf AT ROW 4.46 COL 2
     RECT-7 AT ROW 1.33 COL 2.14
     RECT-9 AT ROW 8.33 COL 2
    WITH 1 DOWN NO-BOX KEEP-TAB-ORDER OVERLAY 
         SIDE-LABELS NO-UNDERLINE THREE-D 
         AT COL 3 ROW 3
         SIZE 73.72 BY 10.5 WIDGET-ID 100.

DEFINE FRAME f-pg-par
     bt-plano AT ROW 1.42 COL 31 HELP
          "Escolha do local do arquivo" WIDGET-ID 52
     fi-plano AT ROW 1.46 COL 16.86 COLON-ALIGNED HELP
          "C¢digo Plano Contas" WIDGET-ID 78
     tg-ct-part AT ROW 1.54 COL 45.57 WIDGET-ID 92
     tg-con-ct-int AT ROW 2.38 COL 45.57 WIDGET-ID 90
     bt-cenario AT ROW 2.42 COL 31 HELP
          "Escolha do local do arquivo" WIDGET-ID 102
     fi-cenar AT ROW 2.5 COL 16.86 COLON-ALIGNED HELP
          "Cen†rio Contabil" WIDGET-ID 80
     tg-con-res AT ROW 3.21 COL 45.57 WIDGET-ID 94
     bt-finalid-1 AT ROW 3.42 COL 31 HELP
          "Escolha do local do arquivo" WIDGET-ID 104
     fi-base AT ROW 3.5 COL 16.86 COLON-ALIGNED HELP
          "Finalidade Base" WIDGET-ID 96
     bt-finalid-2 AT ROW 4.42 COL 31 HELP
          "Escolha do local do arquivo" WIDGET-ID 106
     fi-conv AT ROW 4.5 COL 16.86 COLON-ALIGNED HELP
          "Finalidade Converte" WIDGET-ID 98
     rs-forma AT ROW 5.25 COL 49.43 NO-LABEL WIDGET-ID 110
     fi-dt-conv AT ROW 5.46 COL 16.86 COLON-ALIGNED HELP
          "Finalidade Converte" WIDGET-ID 100
     tg-parametros AT ROW 8 COL 48 WIDGET-ID 116
     c-arquivo-2 AT ROW 9.63 COL 3 NO-LABEL WIDGET-ID 54
     "Local de Geraá∆o do Arquivo" VIEW-AS TEXT
          SIZE 27.14 BY .67 AT ROW 8.88 COL 3.43 WIDGET-ID 22
     "Gera relatorio no formato" VIEW-AS TEXT
          SIZE 24.43 BY .67 AT ROW 4.42 COL 49.57 WIDGET-ID 114
     RECT-8 AT ROW 9.21 COL 2.14 WIDGET-ID 58
     RECT-13 AT ROW 4.75 COL 47.86 WIDGET-ID 108
    WITH 1 DOWN NO-BOX KEEP-TAB-ORDER OVERLAY 
         SIDE-LABELS NO-UNDERLINE THREE-D 
         AT COL 3 ROW 3
         SIZE 75 BY 10.25 WIDGET-ID 100.

DEFINE FRAME f-pg-sel
     fi-lot-i AT ROW 2.5 COL 25.86 COLON-ALIGNED WIDGET-ID 112
     fi-lot-f AT ROW 2.5 COL 46.29 COLON-ALIGNED NO-LABEL WIDGET-ID 110
     fi-est-i AT ROW 3.5 COL 32 COLON-ALIGNED WIDGET-ID 108
     fi-est-f AT ROW 3.5 COL 46.29 COLON-ALIGNED NO-LABEL WIDGET-ID 106
     fi-bu-i AT ROW 4.5 COL 32 COLON-ALIGNED WIDGET-ID 100
     fi-bu-f AT ROW 4.5 COL 46.29 COLON-ALIGNED NO-LABEL WIDGET-ID 98
     fi-mod-i AT ROW 5.5 COL 32 COLON-ALIGNED WIDGET-ID 116
     fi-mod-f AT ROW 5.5 COL 46.29 COLON-ALIGNED NO-LABEL WIDGET-ID 114
     fi-ct-i AT ROW 6.46 COL 15 COLON-ALIGNED WIDGET-ID 104
     fi-ct-f AT ROW 6.46 COL 46.29 COLON-ALIGNED NO-LABEL WIDGET-ID 102
     fi-ccusto-ini AT ROW 7.42 COL 15 COLON-ALIGNED WIDGET-ID 146
     fi-ccusto-fim AT ROW 7.42 COL 46.29 COLON-ALIGNED NO-LABEL WIDGET-ID 144
     fi-per-i AT ROW 8.42 COL 25 COLON-ALIGNED WIDGET-ID 120
     fi-per-f AT ROW 8.42 COL 46.29 COLON-ALIGNED NO-LABEL WIDGET-ID 118
     RS-CEP AT ROW 9.63 COL 17.29 NO-LABEL WIDGET-ID 152
     IMAGE-1 AT ROW 8.42 COL 39.14 WIDGET-ID 122
     IMAGE-2 AT ROW 8.42 COL 45.29 WIDGET-ID 128
     IMAGE-3 AT ROW 6.46 COL 39.14 WIDGET-ID 130
     IMAGE-4 AT ROW 6.46 COL 45.29 WIDGET-ID 132
     IMAGE-5 AT ROW 5.5 COL 39.14 WIDGET-ID 134
     IMAGE-6 AT ROW 5.5 COL 45.29 WIDGET-ID 136
     IMAGE-7 AT ROW 4.5 COL 39.14 WIDGET-ID 138
     IMAGE-8 AT ROW 4.5 COL 45.29 WIDGET-ID 140
     IMAGE-9 AT ROW 3.5 COL 39.14 WIDGET-ID 142
     IMAGE-10 AT ROW 3.5 COL 45.29 WIDGET-ID 74
     IMAGE-11 AT ROW 2.5 COL 39.14 WIDGET-ID 124
     IMAGE-12 AT ROW 2.5 COL 45.29 WIDGET-ID 126
     IMAGE-15 AT ROW 7.42 COL 39.14 WIDGET-ID 148
     IMAGE-16 AT ROW 7.42 COL 45.29 WIDGET-ID 150
    WITH 1 DOWN NO-BOX KEEP-TAB-ORDER OVERLAY 
         SIDE-LABELS NO-UNDERLINE THREE-D 
         AT COL 3 ROW 2.85
         SIZE 76.86 BY 10.62 WIDGET-ID 100.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: w-relat
   Allow: Basic,Browse,DB-Fields,Window,Query
   Add Fields to: Neither
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS

/* *************************  Create Window  ************************** */

&ANALYZE-SUSPEND _CREATE-WINDOW
IF SESSION:DISPLAY-TYPE = "GUI":U THEN
  CREATE WINDOW w-relat ASSIGN
         HIDDEN             = YES
         TITLE              = "Raz∆o Contabil"
         HEIGHT             = 15
         WIDTH              = 81.14
         MAX-HEIGHT         = 22.33
         MAX-WIDTH          = 114.29
         VIRTUAL-HEIGHT     = 22.33
         VIRTUAL-WIDTH      = 114.29
         RESIZE             = yes
         SCROLL-BARS        = no
         STATUS-AREA        = yes
         BGCOLOR            = ?
         FGCOLOR            = ?
         KEEP-FRAME-Z-ORDER = yes
         THREE-D            = yes
         MESSAGE-AREA       = no
         SENSITIVE          = yes.
ELSE {&WINDOW-NAME} = CURRENT-WINDOW.
/* END WINDOW DEFINITION                                                */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _INCLUDED-LIB w-relat 
/* ************************* Included-Libraries *********************** */

{src/adm/method/containr.i}
{include/w-relat.i}
{utp/ut-glob.i}

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME




/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR WINDOW w-relat
  VISIBLE,,RUN-PERSISTENT                                               */
/* SETTINGS FOR FRAME f-pg-imp
   FRAME-NAME                                                           */
/* SETTINGS FOR BUTTON bt-config-impr IN FRAME f-pg-imp
   NO-ENABLE                                                            */
/* SETTINGS FOR BUTTON bt-modelo-rtf IN FRAME f-pg-imp
   NO-ENABLE                                                            */
/* SETTINGS FOR EDITOR c-arquivo IN FRAME f-pg-imp
   NO-ENABLE                                                            */
/* SETTINGS FOR EDITOR c-modelo-rtf IN FRAME f-pg-imp
   NO-ENABLE                                                            */
/* SETTINGS FOR TOGGLE-BOX l-habilitaRtf IN FRAME f-pg-imp
   NO-ENABLE                                                            */
/* SETTINGS FOR RADIO-SET rs-destino IN FRAME f-pg-imp
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN text-destino IN FRAME f-pg-imp
   NO-DISPLAY NO-ENABLE ALIGN-L                                         */
ASSIGN 
       text-destino:PRIVATE-DATA IN FRAME f-pg-imp     = 
                "Destino".

ASSIGN 
       text-modelo-rtf:PRIVATE-DATA IN FRAME f-pg-imp     = 
                "Modelo:".

/* SETTINGS FOR FILL-IN text-modo IN FRAME f-pg-imp
   NO-DISPLAY NO-ENABLE                                                 */
ASSIGN 
       text-modo:PRIVATE-DATA IN FRAME f-pg-imp     = 
                "Execuá∆o".

ASSIGN 
       text-rtf:PRIVATE-DATA IN FRAME f-pg-imp     = 
                "Rich Text Format(RTF)".

/* SETTINGS FOR FRAME f-pg-par
                                                                        */
/* SETTINGS FOR BUTTON bt-cenario IN FRAME f-pg-par
   1                                                                    */
/* SETTINGS FOR BUTTON bt-finalid-1 IN FRAME f-pg-par
   1                                                                    */
/* SETTINGS FOR BUTTON bt-finalid-2 IN FRAME f-pg-par
   1                                                                    */
/* SETTINGS FOR BUTTON bt-plano IN FRAME f-pg-par
   1                                                                    */
/* SETTINGS FOR FILL-IN c-arquivo-2 IN FRAME f-pg-par
   ALIGN-L                                                              */
ASSIGN 
       c-arquivo-2:PRIVATE-DATA IN FRAME f-pg-par     = 
                "Informe somente o nome do Arquivo".

/* SETTINGS FOR FILL-IN fi-base IN FRAME f-pg-par
   NO-ENABLE                                                            */
ASSIGN 
       fi-base:READ-ONLY IN FRAME f-pg-par        = TRUE.

/* SETTINGS FOR FILL-IN fi-cenar IN FRAME f-pg-par
   NO-ENABLE                                                            */
ASSIGN 
       fi-cenar:READ-ONLY IN FRAME f-pg-par        = TRUE.

/* SETTINGS FOR FILL-IN fi-conv IN FRAME f-pg-par
   NO-ENABLE                                                            */
ASSIGN 
       fi-conv:READ-ONLY IN FRAME f-pg-par        = TRUE.

/* SETTINGS FOR FILL-IN fi-dt-conv IN FRAME f-pg-par
   NO-ENABLE                                                            */
/* SETTINGS FOR TOGGLE-BOX tg-con-ct-int IN FRAME f-pg-par
   NO-DISPLAY NO-ENABLE                                                 */
ASSIGN 
       tg-con-ct-int:HIDDEN IN FRAME f-pg-par           = TRUE.

/* SETTINGS FOR TOGGLE-BOX tg-con-res IN FRAME f-pg-par
   NO-DISPLAY NO-ENABLE                                                 */
ASSIGN 
       tg-con-res:HIDDEN IN FRAME f-pg-par           = TRUE.

/* SETTINGS FOR TOGGLE-BOX tg-ct-part IN FRAME f-pg-par
   NO-DISPLAY NO-ENABLE                                                 */
ASSIGN 
       tg-ct-part:HIDDEN IN FRAME f-pg-par           = TRUE.

/* SETTINGS FOR TOGGLE-BOX tg-parametros IN FRAME f-pg-par
   NO-ENABLE                                                            */
/* SETTINGS FOR FRAME f-pg-sel
                                                                        */
/* SETTINGS FOR FRAME f-relat
                                                                        */
/* SETTINGS FOR RECTANGLE RECT-1 IN FRAME f-relat
   NO-ENABLE                                                            */
/* SETTINGS FOR RECTANGLE RECT-6 IN FRAME f-relat
   NO-ENABLE                                                            */
/* SETTINGS FOR RECTANGLE rt-folder IN FRAME f-relat
   NO-ENABLE                                                            */
/* SETTINGS FOR RECTANGLE rt-folder-left IN FRAME f-relat
   NO-ENABLE                                                            */
/* SETTINGS FOR RECTANGLE rt-folder-right IN FRAME f-relat
   NO-ENABLE                                                            */
/* SETTINGS FOR RECTANGLE rt-folder-top IN FRAME f-relat
   NO-ENABLE                                                            */
IF SESSION:DISPLAY-TYPE = "GUI":U AND VALID-HANDLE(w-relat)
THEN w-relat:HIDDEN = no.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK FRAME f-pg-imp
/* Query rebuild information for FRAME f-pg-imp
     _Query            is NOT OPENED
*/  /* FRAME f-pg-imp */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _QUERY-BLOCK FRAME f-pg-sel
/* Query rebuild information for FRAME f-pg-sel
     _Query            is NOT OPENED
*/  /* FRAME f-pg-sel */
&ANALYZE-RESUME

 



/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME w-relat
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL w-relat w-relat
ON END-ERROR OF w-relat /* Raz∆o Contabil */
OR ENDKEY OF {&WINDOW-NAME} ANYWHERE DO:
  /* This case occurs when the user presses the "Esc" key.
     In a persistently run window, just ignore this.  If we did not, the
     application would exit. */
   RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL w-relat w-relat
ON WINDOW-CLOSE OF w-relat /* Raz∆o Contabil */
DO:
  /* This event will close the window and terminate the procedure.  */
  APPLY "CLOSE":U TO THIS-PROCEDURE.
  RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define FRAME-NAME f-relat
&Scoped-define SELF-NAME bt-ajuda
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL bt-ajuda w-relat
ON CHOOSE OF bt-ajuda IN FRAME f-relat /* Ajuda */
DO:
   {include/ajuda.i}
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define FRAME-NAME f-pg-imp
&Scoped-define SELF-NAME bt-arquivo
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL bt-arquivo w-relat
ON CHOOSE OF bt-arquivo IN FRAME f-pg-imp
DO:
    {include/i-rparq.i}
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define FRAME-NAME f-relat
&Scoped-define SELF-NAME bt-cancelar
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL bt-cancelar w-relat
ON CHOOSE OF bt-cancelar IN FRAME f-relat /* Fechar */
DO:
   apply "close":U to this-procedure.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define FRAME-NAME f-pg-par
&Scoped-define SELF-NAME bt-cenario
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL bt-cenario w-relat
ON CHOOSE OF bt-cenario IN FRAME f-pg-par
DO:
    assign v_rec_cenar_ctbl = v_rec_table.

    run prgint/utb/utb076ka.p. 

    if  v_rec_cenar_ctbl <> ? then do:

        assign v_rec_table = v_rec_cenar_ctbl.

        FIND cenar_ctbl NO-LOCK WHERE  
            RECID(cenar_ctbl) = v_rec_table NO-ERROR.
        
        IF AVAIL cenar_ctbl THEN
           ASSIGN fi-cenar:SCREEN-VALUE = cenar_ctbl.cod_cenar_ctbl.

     end /* if */.
     else 
        assign v_rec_cenar_ctbl = v_rec_table.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define FRAME-NAME f-pg-imp
&Scoped-define SELF-NAME bt-config-impr
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL bt-config-impr w-relat
ON CHOOSE OF bt-config-impr IN FRAME f-pg-imp
DO:
   {include/i-rpimp.i}
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define FRAME-NAME f-relat
&Scoped-define SELF-NAME bt-executar
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL bt-executar w-relat
ON CHOOSE OF bt-executar IN FRAME f-relat /* Executar */
DO:
   do  on error undo, return no-apply:
       run pi-executar.
   end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define FRAME-NAME f-pg-par
&Scoped-define SELF-NAME bt-finalid-1
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL bt-finalid-1 w-relat
ON CHOOSE OF bt-finalid-1 IN FRAME f-pg-par
DO:
    assign v_rec_finalid_econ = v_rec_table.

    run prgint/utb/utb077ka.p.

    if  v_rec_finalid_econ <> ? then do:

        assign v_rec_table = v_rec_finalid_econ.

        find finalid_econ where recid(finalid_econ) = v_rec_finalid_econ no-lock no-error.
        IF AVAIL finalid_econ THEN
           ASSIGN fi-base:SCREEN-VALUE = finalid_econ.cod_finalid_econ.

     end /* if */.
     else 
        assign v_rec_finalid_econ = v_rec_table.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME bt-finalid-2
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL bt-finalid-2 w-relat
ON CHOOSE OF bt-finalid-2 IN FRAME f-pg-par
DO:
    assign v_rec_finalid_econ = v_rec_table.

    run prgint/utb/utb077ka.p.

    if  v_rec_finalid_econ <> ? then do:

        assign v_rec_table = v_rec_finalid_econ.

        find finalid_econ where recid(finalid_econ) = v_rec_finalid_econ no-lock no-error.
        IF AVAIL finalid_econ THEN
           ASSIGN fi-conv:SCREEN-VALUE = finalid_econ.cod_finalid_econ.

     end /* if */.
     else 
        assign v_rec_finalid_econ = v_rec_table.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define FRAME-NAME f-pg-imp
&Scoped-define SELF-NAME bt-modelo-rtf
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL bt-modelo-rtf w-relat
ON CHOOSE OF bt-modelo-rtf IN FRAME f-pg-imp
DO:
    def var c-arq-conv  as char no-undo.
    def var l-ok as logical no-undo.

    assign c-modelo-rtf = replace(input frame {&frame-name} c-modelo-rtf, "/", "~\").
    SYSTEM-DIALOG GET-FILE c-arq-conv
       FILTERS "*.rtf" "*.rtf",
               "*.*" "*.*"
       DEFAULT-EXTENSION "rtf"
       INITIAL-DIR "modelos" 
       MUST-EXIST
       USE-FILENAME
       UPDATE l-ok.
    if  l-ok = yes then
        assign c-modelo-rtf:screen-value in frame {&frame-name}  = replace(c-arq-conv, "~\", "/"). 

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define FRAME-NAME f-pg-par
&Scoped-define SELF-NAME bt-plano
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL bt-plano w-relat
ON CHOOSE OF bt-plano IN FRAME f-pg-par
DO:
    assign v_rec_plano_cta_ctbl = v_rec_table.

    run prgint/utb/utb080ka.p. 

    if  v_rec_plano_cta_ctbl <> ? then do:

        assign v_rec_table = v_rec_plano_cta_ctbl.

        FIND plano_cta_ctbl NO-LOCK WHERE  
            RECID(plano_cta_ctbl) = v_rec_table NO-ERROR.

        IF AVAIL plano_cta_ctbl THEN
           ASSIGN fi-plano:SCREEN-VALUE = plano_cta_ctbl.cod_plano_cta_ctbl.

     end /* if */.
     else 
        assign v_rec_plano_cta_ctbl = v_rec_table.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME fi-dt-conv
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL fi-dt-conv w-relat
ON F5 OF fi-dt-conv IN FRAME f-pg-par /* Data Cotaá∆o */
DO:
   
    assign v_rec_cenar_ctbl = v_rec_table.

    run prgint/utb/utb076ka.p. 

    if  v_rec_cenar_ctbl <> ? then do:

        assign v_rec_table = v_rec_cenar_ctbl.

        FIND cenar_ctbl NO-LOCK WHERE  
            RECID(cenar_ctbl) = v_rec_table NO-ERROR.
        
        IF AVAIL cenar_ctbl THEN
           ASSIGN fi-cenar:SCREEN-VALUE = cenar_ctbl.cod_cenar_ctbl.

     end /* if */.
     else 
        assign v_rec_cenar_ctbl = v_rec_table.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL fi-dt-conv w-relat
ON MOUSE-SELECT-DBLCLICK OF fi-dt-conv IN FRAME f-pg-par /* Data Cotaá∆o */
DO:
   APPLY "F5" TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define FRAME-NAME f-relat
&Scoped-define SELF-NAME im-pg-imp
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL im-pg-imp w-relat
ON MOUSE-SELECT-CLICK OF im-pg-imp IN FRAME f-relat
DO:
    run pi-troca-pagina.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME im-pg-par
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL im-pg-par w-relat
ON MOUSE-SELECT-CLICK OF im-pg-par IN FRAME f-relat
DO:
    run pi-troca-pagina.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME im-pg-sel
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL im-pg-sel w-relat
ON MOUSE-SELECT-CLICK OF im-pg-sel IN FRAME f-relat
DO:
    run pi-troca-pagina.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define FRAME-NAME f-pg-imp
&Scoped-define SELF-NAME l-habilitaRtf
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL l-habilitaRtf w-relat
ON VALUE-CHANGED OF l-habilitaRtf IN FRAME f-pg-imp /* RTF */
DO:
    &IF "{&RTF}":U = "YES":U &THEN
    RUN pi-habilitaRtf.
    &endif
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME rs-destino
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL rs-destino w-relat
ON VALUE-CHANGED OF rs-destino IN FRAME f-pg-imp
DO:
/*Alterado 15/02/2005 - tech1007 - Evento alterado para correto funcionamento dos novos widgets
  utilizados para a funcionalidade de RTF*/
do  with frame f-pg-imp:
    case self:screen-value:
        when "1" then do:
            assign c-arquivo:sensitive    = no
                   bt-arquivo:visible     = no
                   bt-config-impr:visible = YES
                   /*Alterado 17/02/2005 - tech1007 - Realizado teste de preprocessador para
                     verificar se o RTF est† ativo*/
                   &IF "{&RTF}":U = "YES":U &THEN
                   l-habilitaRtf:sensitive  = NO
                   l-habilitaRtf:SCREEN-VALUE IN FRAME f-pg-imp = "No"
                   l-habilitaRtf = NO
                   &endif
                   /*Fim alteracao 17/02/2005*/
                   .
        end.
        when "2" then do:
            assign c-arquivo:sensitive     = yes
                   bt-arquivo:visible      = yes
                   bt-config-impr:visible  = NO
                   /*Alterado 17/02/2005 - tech1007 - Realizado teste de preprocessador para
                     verificar se o RTF est† ativo*/
                   &IF "{&RTF}":U = "YES":U &THEN
                   l-habilitaRtf:sensitive  = YES
                   &endif
                   /*Fim alteracao 17/02/2005*/
                   .
        end.
        when "3" then do:
            assign c-arquivo:sensitive     = no
                   bt-arquivo:visible      = no
                   bt-config-impr:visible  = no
                   /*Alterado 17/02/2005 - tech1007 - Realizado teste de preprocessador para
                     verificar se o RTF est† ativo*/
                   &IF "{&RTF}":U = "YES":U &THEN
                   l-habilitaRtf:sensitive  = YES
                   &endif
                   /*Fim alteracao 17/02/2005*/
                   .
            /*Alterado 15/02/2005 - tech1007 - Teste para funcionar corretamente no WebEnabler*/
            &IF "{&RTF}":U = "YES":U &THEN
            IF VALID-HANDLE(hWenController) THEN DO:
                ASSIGN l-habilitaRtf:sensitive  = NO
                       l-habilitaRtf:SCREEN-VALUE IN FRAME f-pg-imp = "No"
                       l-habilitaRtf = NO.
            END.
            &endif
            /*Fim alteracao 15/02/2005*/
        end.
    end case.
end.
&IF "{&RTF}":U = "YES":U &THEN
RUN pi-habilitaRtf.
&endif
/*Fim alteracao 15/02/2005*/
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME rs-execucao
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL rs-execucao w-relat
ON VALUE-CHANGED OF rs-execucao IN FRAME f-pg-imp
DO:
   {include/i-rprse.i}
   
   if input frame f-pg-imp rs-execucao = 2 then
      assign c-arquivo-2:sensitive in frame f-pg-par = no.
   else
      assign c-arquivo-2:sensitive in frame f-pg-par = yes.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK w-relat 


/* ***************************  Main Block  *************************** */
   
/* Set CURRENT-WINDOW: this will parent dialog-boxes and frames.        */
ASSIGN CURRENT-WINDOW                = {&WINDOW-NAME} 
       THIS-PROCEDURE:CURRENT-WINDOW = {&WINDOW-NAME}.

{utp/ut9000.i "ESFGL0001x" "1.00.00.000"}

/*:T inicializaá‰es do template de relat¢rio */
{include/i-rpini.i}

/* The CLOSE event can be used from inside or outside the procedure to  */
/* terminate it.                                                        */
ON CLOSE OF THIS-PROCEDURE 
   RUN disable_UI.

{include/i-rplbl.i}

/* Best default for GUI applications is...                              */
PAUSE 0 BEFORE-HIDE.

/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO  ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
    ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:

    RUN enable_UI.
    
    ASSIGN fi-plano:SCREEN-VALUE IN FRAME f-pg-par    = v_cod_plano_cta_ctbl
           fi-per-i:SCREEN-VALUE IN FRAME f-pg-sel    = STRING(DATE(MONTH(TODAY),1,YEAR(TODAY)))
           fi-per-f:SCREEN-VALUE IN FRAME f-pg-sel    = STRING(TODAY)
           fi-dt-conv:SCREEN-VALUE IN FRAME f-pg-par  = STRING(TODAY)
           c-arquivo-2:SCREEN-VALUE IN FRAME f-pg-par = session:temp-directory.

    FIND FIRST estabelec NO-ERROR.
         ASSIGN fi-est-i:SCREEN-VALUE IN FRAME f-pg-sel = estabelec.cod-estabel.
    FIND LAST estabelec NO-ERROR.
         ASSIGN fi-est-f:SCREEN-VALUE IN FRAME f-pg-sel = estabelec.cod-estabel.

    {include/i-rpmbl.i}
  
    IF  NOT THIS-PROCEDURE:PERSISTENT THEN
        WAIT-FOR CLOSE OF THIS-PROCEDURE.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE adm-create-objects w-relat  _ADM-CREATE-OBJECTS
PROCEDURE adm-create-objects :
/*------------------------------------------------------------------------------
  Purpose:     Create handles for all SmartObjects used in this procedure.
               After SmartObjects are initialized, then SmartLinks are added.
  Parameters:  <none>
------------------------------------------------------------------------------*/

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE adm-row-available w-relat  _ADM-ROW-AVAILABLE
PROCEDURE adm-row-available :
/*------------------------------------------------------------------------------
  Purpose:     Dispatched to this procedure when the Record-
               Source has a new row available.  This procedure
               tries to get the new row (or foriegn keys) from
               the Record-Source and process it.
  Parameters:  <none>
------------------------------------------------------------------------------*/

  /* Define variables needed by this internal procedure.             */
  {src/adm/template/row-head.i}

  /* Process the newly available records (i.e. display fields,
     open queries, and/or pass records on to any RECORD-TARGETS).    */
  {src/adm/template/row-end.i}

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE disable_UI w-relat  _DEFAULT-DISABLE
PROCEDURE disable_UI :
/*------------------------------------------------------------------------------
  Purpose:     DISABLE the User Interface
  Parameters:  <none>
  Notes:       Here we clean-up the user-interface by deleting
               dynamic widgets we have created and/or hide 
               frames.  This procedure is usually called when
               we are ready to "clean-up" after running.
------------------------------------------------------------------------------*/
  /* Delete the WINDOW we created */
  IF SESSION:DISPLAY-TYPE = "GUI":U AND VALID-HANDLE(w-relat)
  THEN DELETE WIDGET w-relat.
  IF THIS-PROCEDURE:PERSISTENT THEN DELETE PROCEDURE THIS-PROCEDURE.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE enable_UI w-relat  _DEFAULT-ENABLE
PROCEDURE enable_UI :
/*------------------------------------------------------------------------------
  Purpose:     ENABLE the User Interface
  Parameters:  <none>
  Notes:       Here we display/view/enable the widgets in the
               user-interface.  In addition, OPEN all queries
               associated with each FRAME and BROWSE.
               These statements here are based on the "Other 
               Settings" section of the widget Property Sheets.
------------------------------------------------------------------------------*/
  ENABLE im-pg-imp im-pg-par im-pg-sel bt-executar bt-cancelar bt-ajuda 
      WITH FRAME f-relat IN WINDOW w-relat.
  {&OPEN-BROWSERS-IN-QUERY-f-relat}
  DISPLAY fi-lot-i fi-lot-f fi-est-i fi-est-f fi-bu-i fi-bu-f fi-mod-i fi-mod-f 
          fi-ct-i fi-ct-f fi-ccusto-ini fi-ccusto-fim fi-per-i fi-per-f RS-CEP 
      WITH FRAME f-pg-sel IN WINDOW w-relat.
  ENABLE IMAGE-1 IMAGE-2 IMAGE-3 IMAGE-4 IMAGE-5 IMAGE-6 IMAGE-7 IMAGE-8 
         IMAGE-9 IMAGE-10 IMAGE-11 IMAGE-12 IMAGE-15 IMAGE-16 fi-lot-i fi-lot-f 
         fi-est-i fi-est-f fi-bu-i fi-bu-f fi-mod-i fi-mod-f fi-ct-i fi-ct-f 
         fi-ccusto-ini fi-ccusto-fim fi-per-i fi-per-f RS-CEP 
      WITH FRAME f-pg-sel IN WINDOW w-relat.
  {&OPEN-BROWSERS-IN-QUERY-f-pg-sel}
  DISPLAY rs-destino c-arquivo l-habilitaRtf c-modelo-rtf rs-execucao text-rtf 
          text-modelo-rtf 
      WITH FRAME f-pg-imp IN WINDOW w-relat.
  ENABLE rect-rtf RECT-7 RECT-9 bt-arquivo rs-execucao text-rtf text-modelo-rtf 
      WITH FRAME f-pg-imp IN WINDOW w-relat.
  {&OPEN-BROWSERS-IN-QUERY-f-pg-imp}
  DISPLAY fi-plano fi-cenar fi-base fi-conv rs-forma fi-dt-conv tg-parametros 
          c-arquivo-2 
      WITH FRAME f-pg-par IN WINDOW w-relat.
  ENABLE RECT-8 RECT-13 bt-plano fi-plano bt-cenario bt-finalid-1 bt-finalid-2 
         rs-forma c-arquivo-2 
      WITH FRAME f-pg-par IN WINDOW w-relat.
  {&OPEN-BROWSERS-IN-QUERY-f-pg-par}
  VIEW w-relat.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE local-exit w-relat 
PROCEDURE local-exit :
/* -----------------------------------------------------------
  Purpose:  Starts an "exit" by APPLYing CLOSE event, which starts "destroy".
  Parameters:  <none>
  Notes:    If activated, should APPLY CLOSE, *not* dispatch adm-exit.   
-------------------------------------------------------------*/
   APPLY "CLOSE":U TO THIS-PROCEDURE.
   
   RETURN.
       
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE pi-executar w-relat 
PROCEDURE pi-executar :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
define var r-tt-digita as rowid no-undo.

do on error undo, return error on stop  undo, return error:
    {include/i-rpexa.i}
    /*14/02/2005 - tech1007 - Alterada condicao para n∆o considerar mai o RTF como destino*/
    if input frame f-pg-imp rs-destino = 2 and
       input frame f-pg-imp rs-execucao = 1 then do:
        run utp/ut-vlarq.p (input input frame f-pg-imp c-arquivo).
        
        if return-value = "NOK":U then do:
            run utp/ut-msgs.p (input "show":U, input 73, input "").
            
            apply "MOUSE-SELECT-CLICK":U to im-pg-imp in frame f-relat.
            apply "ENTRY":U to c-arquivo in frame f-pg-imp.
            return error.
        end.
    end.

    FIND plano_cta_ctbl NO-LOCK WHERE plano_cta_ctbl.cod_plano_cta_ctbl = INPUT FRAME f-pg-par fi-plano NO-ERROR.
    IF NOT AVAIL plano_cta_ctbl THEN
    DO:
       run utp/ut-msgs.p (input "show":U, 
                          input 17006, 
                          input "Plano de Contas n∆o Existe~~O Plano de Contas informadao n∆o est† cadastrado.").     
       apply "ENTRY":U TO fi-plano in frame f-pg-par.             
       return error.                                               
    END.

    find cenar_ctbl where cenar_ctbl.cod_cenar_ctbl = INPUT FRAME f-pg-par fi-cenar no-lock no-error. 
    IF NOT AVAIL cenar_ctbl THEN
    DO:
       run utp/ut-msgs.p (input "show":U,                                                                         
                          input 17006,                                                                            
                          input "Cen†rio Contabil n∆o existe~~O Cen†rio Contabil informado n∆o est† cadastrado.").      
       apply "ENTRY":U TO fi-plano in frame f-pg-par.                                                             
       return error.                                                                                              
    END.

    FIND finalid_econ WHERE finalid_econ.cod_finalid_econ = INPUT FRAME f-pg-par fi-base NO-LOCK NO-ERROR.                 
    IF  AVAIL finalid_econ THEN DO:                                                                                        
        run pi_validar_finalid_unid_organ (INPUT FRAME f-pg-par fi-base,                                                   
                                           Input v_cod_empres_usuar,                                                       
                                           INPUT FRAME f-pg-par fi-dt-conv,                                                
                                           output v_cod_return).                                                           
        if v_cod_return = "OK" then                                                                                       
        do:                                                                                                                
            IF INPUT FRAME f-pg-par fi-base <> INPUT FRAME f-pg-par fi-conv THEN                                           
            do:                                                                                                            
                find b_finalid_econ where b_finalid_econ.cod_finalid_econ = INPUT FRAME f-pg-par fi-conv NO-LOCK NO-ERROR. 
                if avail b_finalid_econ then                                                                               
                do:                                                                                                        
                   run pi_validar_finalid_unid_organ (Input INPUT FRAME f-pg-par fi-conv,                                  
                                                      Input v_cod_empres_usuar,                                            
                                                      Input INPUT FRAME f-pg-par fi-dt-conv,                               
                                                      output v_cod_return).                                                
                   if v_cod_return = "NOK" then                                                                            
                   do:                                                                                                     
                      /* Finalidade Econìmica corrente n∆o econtrada para U.O ! */                                         
                      RUN utp/ut-msgs.p (input "show",                                                                       
                                         input 17006,                                                                         
                                         input "Finalidade econìmica corrente n∆o encontrada para a U.O.~~Informe uma finalidade econìmica corrente para o pa°s da UO.").                           
                      APPLY "ENTRY":U TO fi-conv IN FRAME f-pg-par.                                                        
                      RETURN ERROR.                                                                                        
                   end.                                                                                                    
                end.                                                                                                       
                else do:                                                                                                   
                    /* Finalidade Econìmica Inexistente ! */                                                               
                    run utp/ut-msgs.p (input "show",                                                                         
                                       input 17006,                                                                             
                                       input "Finalidade econìmica inexistente~~Consulte o cadastro de Finalidades Econìmicas e informe uma finalidade v†lida.").                              
                    APPLY "ENTRY":U TO fi-conv IN FRAME f-pg-par.                                                          
                    RETURN ERROR.                                                                                          
                end.                                                                                                       
            END.                                                                                                           
         end. 
         ELSE DO:
            IF INPUT FRAME f-pg-par fi-base <> INPUT FRAME f-pg-par fi-conv THEN
            DO:                                                                                                            
               /* Finalidade Econìmica corrente n∆o econtrada para U.O ! */                                                
               run utp/ut-msgs.p (input "show",                                                                              
                                  input 17006,                                   
                                  input "Finalidade econìmica corrente n∆o encontrada para a U.O.~~Informe uma finalidade econìmica corrente para o pa°s da UO.").                              
               APPLY "ENTRY":U TO fi-base IN FRAME f-pg-par.                                                               
               RETURN ERROR.                                                                                               
            END.                                                                                                           
         END.
    end /* if */.                                                                                                          
    else do:                                                                                                               
       /* Finalidade Econìmica Inexistente ! */                                                                            
       RUN utp/ut-msgs.p (input "show",                                                                                      
                          input 17006,                                                                                          
                          input "Finalidade econìmica inexistente~~Consulte o cadastro de Finalidades Econìmicas e informe uma finalidade v†lida.").                               
       APPLY "ENTRY":U TO fi-base IN FRAME f-pg-par.                                                                       
       RETURN ERROR.                                                                                                       
    END.                                                                                                                   

    ASSIGN FRAME f-pg-par c-arquivo-2.

    FILE-INFO:FILE-NAME = c-arquivo-2.
    IF FILE-INFO:FILE-TYPE = ? THEN 
    DO:
       RUN utp/ut-msgs.p (INPUT "show",                                              
                          INPUT 17006,                                               
                          INPUT "Local Incorreto!!!~~Certifique-se de que o diret¢rio informado existe."). 
       APPLY "ENTRY":U TO c-arquivo-2 IN FRAME f-pg-par.                             
       RETURN ERROR.                                                                 
    END.

    if substring(c-arquivo-2,length(c-arquivo-2),1) <> '/' and 
       substring(c-arquivo-2,length(c-arquivo-2),1) <> '\' then
        Assign c-arquivo-2 = c-arquivo-2 + '\'.

    create tt-param.
    assign tt-param.usuario         = c-seg-usuario
           tt-param.destino         = input frame f-pg-imp rs-destino
           tt-param.data-exec       = today
           tt-param.hora-exec       = time.

    if tt-param.destino = 1 then 
       assign tt-param.arquivo = "".
    else if tt-param.destino = 2 then 
            assign tt-param.arquivo = input frame f-pg-imp c-arquivo.
         else 
            assign tt-param.arquivo = session:temp-directory + c-programa-mg97 + ".tmp":U.

    ASSIGN tt-param.rs-execucao         = input frame f-pg-imp rs-execucao
           tt-param.lot-i               = INPUT FRAME f-pg-sel fi-lot-i
           tt-param.lot-f               = INPUT FRAME f-pg-sel fi-lot-f   
           tt-param.est-i               = INPUT FRAME f-pg-sel fi-est-i       
           tt-param.est-f               = INPUT FRAME f-pg-sel fi-est-f             
           tt-param.neg-i               = INPUT FRAME f-pg-sel fi-bu-i              
           tt-param.neg-f               = INPUT FRAME f-pg-sel fi-bu-f              
           tt-param.mod-i               = INPUT FRAME f-pg-sel fi-mod-i             
           tt-param.mod-f               = INPUT FRAME f-pg-sel fi-mod-f             
           tt-param.cta-i               = INPUT FRAME f-pg-sel fi-ct-i              
           tt-param.cta-f               = INPUT FRAME f-pg-sel fi-ct-f   
        
           tt-param.ccusto-i            = INPUT FRAME f-pg-sel fi-ccusto-ini              
           tt-param.ccusto-f            = INPUT FRAME f-pg-sel fi-ccusto-fim  

           tt-param.per-i               = INPUT FRAME f-pg-sel fi-per-i             
           tt-param.per-f               = INPUT FRAME f-pg-sel fi-per-f  
           tt-param.rs-cep              = INPUT FRAME f-pg-sel rs-cep
           tt-param.arquivo-saida       = c-arquivo-2  
           tt-param.cod-plano           = INPUT FRAME f-pg-par fi-plano
           tt-param.cod-cenar           = INPUT FRAME f-pg-par fi-cenar
           tt-param.imp-ctpart          = YES   /*INPUT FRAME f-pg-par tg-ct-part      */
           tt-param.con-ct-int          = NO    /*INPUT FRAME f-pg-par tg-con-ct-int   */
           tt-param.con-res             = NO    /*INPUT FRAME f-pg-par tg-con-res      */
           tt-param.fin-base            = INPUT FRAME f-pg-par fi-base
           tt-param.fin-conv            = INPUT FRAME f-pg-par fi-conv
           tt-param.dt-cot              = INPUT FRAME f-pg-par fi-dt-conv
           tt-param.i-forma             = INPUT FRAME f-pg-par rs-forma
           tt-param.l-param             = INPUT FRAME f-pg-par tg-parametros.

    /*:T Executar do programa RP.P que ir† criar o relat¢rio */
    {include/i-rpexb.i}
    
    SESSION:SET-WAIT-STATE("general":U).
    
    {include/i-rprun.i esp/ESFGL0001xrp.p}
    
    {include/i-rpexc.i}
    
    SESSION:SET-WAIT-STATE("":U).
    
/*     {include/i-rptrm.i} */
end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE pi-troca-pagina w-relat 
PROCEDURE pi-troca-pagina :
/*:T------------------------------------------------------------------------------
  Purpose: Gerencia a Troca de P†gina (folder)   
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
assign fi-dt-conv =  INPUT FRAME f-pg-sel fi-per-i.
ASSIGN fi-dt-conv:SCREEN-VALUE IN FRAME f-pg-par  = INPUT FRAME f-pg-sel fi-per-i.
{include/i-rptrp.i}

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE pi_validar_finalid_unid_organ w-relat 
PROCEDURE pi_validar_finalid_unid_organ :
/************************ Parameter Definition Begin ************************/

    def Input param p_cod_finalid_econ as CHARACTER format "x(10)" no-undo.
    def Input param p_cod_unid_organ   as CHARACTER format "x(5)" NO-UNDO.
    def Input param p_dat_transacao    as DATE format "99/99/9999" no-undo.
    def output param p_cod_return      as CHARACTER format "x(40)" no-undo.

    /************************* Parameter Definition End *************************/

    find first finalid_unid_organ no-lock
         where finalid_unid_organ.cod_unid_organ   = p_cod_unid_organ
           and finalid_unid_organ.cod_finalid_econ = p_cod_finalid_econ
           and finalid_unid_organ.dat_inic_valid   <= p_dat_transacao
           and finalid_unid_organ.dat_fim_valid    >= p_dat_transacao no-error.

    if  not avail finalid_unid_organ then do:
        assign p_cod_return = "338".
    end.
    else do:
        assign p_cod_return = "OK".
    end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE send-records w-relat  _ADM-SEND-RECORDS
PROCEDURE send-records :
/*------------------------------------------------------------------------------
  Purpose:     Send record ROWID's for all tables used by
               this file.
  Parameters:  see template/snd-head.i
------------------------------------------------------------------------------*/

  /* SEND-RECORDS does nothing because there are no External
     Tables specified for this w-relat, and there are no
     tables specified in any contained Browse, Query, or Frame. */

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE state-changed w-relat 
PROCEDURE state-changed :
/* -----------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
-------------------------------------------------------------*/
  DEFINE INPUT PARAMETER p-issuer-hdl AS HANDLE NO-UNDO.
  DEFINE INPUT PARAMETER p-state AS CHARACTER NO-UNDO.
  
  run pi-trata-state (p-issuer-hdl, p-state).
  
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

