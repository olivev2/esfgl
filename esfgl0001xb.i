SESSION:DATE-FORMAT = "dmy".
/*********************************************************************
** ftapi066.i - Defini‡Æo temp-table utilizada para retornar as     **
**              informa‡äes da tabela SUMAR-FT .                    **
**********************************************************************/ 

def temp-table {1} no-undo
    field ep-codigo             LIKE param-globa.empresa-prin
    field num-seq-movto-ctbl 	as integer
    field num-id-movto-ctbl  	as integer
    field cod-estabel           as character

    field nro-docto             as character
    field cod-emitente          as integer
    field serie-docto           as character
    field nat-operacao          as char
/*                                                      */
/*     FIELD ge-codigo             LIKE ITEM.ge-codigo  */
/*     FIELD it-codigo             LIKE ITEM.it-codigo  */
/*                                                      */
    field referencia           	as character
    field sequencia             as integer
    field ge-codigo             as integer
    field conta-contabil        as character
    field dt-trans              as date FORMAT "99/99/9999"
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
    FIELD cod_cta_ctbl_contra       as CHARACTER format "x(20)"
    FIELD val_lancto_ctbl_contra    as decimal format ">>>>>,>>>,>>9.99" decimals 2 initial 0 label "Movto Contra" column-label "Movto Contra"
    index num-id                is primary
          num-id-movto-ctbl     ascending.

  
