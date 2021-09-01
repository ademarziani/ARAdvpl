#INCLUDE "PROTHEUS.CH"
	
/*=====================================================================
|---------------------------------------------------------------------|
| Programa | ARAsiento | Autor: Andres Demarziani | Fecha: 27/04/2021 |
|---------------------------------------------------------------------|
| Descripcion: Carga docuemntos de Asientos contables.                |
|---------------------------------------------------------------------|
======================================================================*/
CLASS ARAsiento FROM ARDocumento
	
	METHOD New() CONSTRUCTOR
	METHOD guardar()

ENDCLASS

/*=====================================================================
|---------------------------------------------------------------------|
| Programa | ARAsiento | Autor: Andres Demarziani | Fecha: 29/10/2017  |
|---------------------------------------------------------------------|
======================================================================*/
METHOD New() CLASS ARAsiento
	
	_Super:New()	
	::setTipo("2")

RETURN SELF

/*=====================================================================
|---------------------------------------------------------------------|
| Programa | ARAsiento | Autor: Andres Demarziani | Fecha: 29/10/2017  |
|---------------------------------------------------------------------|
======================================================================*/
METHOD guardar() CLASS ARAsiento
	
	Local cFunBkp 	:= FunName()
    Local dFecha    := ::getValEncab("CT2_DATA")
    Local cLote     := ::getValEncab("CT2_LOTE")
    Local cSBLote   := ::getValEncab("CT2_SBLOTE")
    Local cDoc      := ::getValEncab("CT2_DOC")
    Local aCab      := {}

	Private lMsErroAuto := .F.

    If Empty(dFecha) .Or. Empty(cLote) .Or. Empty(cSBLote) .Or. Empty(cDoc)
        ::lGrabo    := .F.
        ::cError    := "La fecha, lote, sublote o documento no fueron informados en el asiento."
    Else
        aAdd(aCab,  {"DDATALANC"    ,dFecha     ,NIL} )
        aAdd(aCab,  {"CLOTE"        ,cLote      ,NIL} )
        aAdd(aCab,  {"CSUBLOTE"     ,cSBLote    ,NIL} )
        aAdd(aCab,  {"CDOC"         ,cDoc       ,NIL} )

	    SetFunName("CTBA102")

	    MSExecAuto({|x, y,z| CTBA102(x,y,z)}, aCab, ::aDet1, 3)
    
	    ::lGrabo := !lMsErroAuto

	    If !::lGrabo
	    	::cError := MostraErro("ASIENTO")
	    Else
	    	::cError := ""
	    EndIf

	    SetFunName(cFunBkp)
    EndIf

RETURN Nil 
