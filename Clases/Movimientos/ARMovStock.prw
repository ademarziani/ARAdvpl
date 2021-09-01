#INCLUDE 'PROTHEUS.CH'
	
/*=====================================================================
|---------------------------------------------------------------------|
| Programa | ARMovStock | Autor: Demarziani | Fecha: 27/04/2021       |
|---------------------------------------------------------------------|
| Descripcion: Carga docuemntos de Movimientos de stock.              |
|---------------------------------------------------------------------|
======================================================================*/
CLASS ARMovStock FROM ARDocumento

	DATA cNum
	
	METHOD New() CONSTRUCTOR
	METHOD guardar()

ENDCLASS

/*=====================================================================
|---------------------------------------------------------------------|
| Programa | ARMovStock | Autor: Andres Demarziani | Fecha: 29/10/2017  |
|---------------------------------------------------------------------|
======================================================================*/
METHOD New() CLASS ARMovStock
	
	_Super:New()	
	::setTipo("2")

RETURN SELF

/*=====================================================================
|---------------------------------------------------------------------|
| Programa | ARMovStock | Autor: Andres Demarziani | Fecha: 29/10/2017  |
|---------------------------------------------------------------------|
======================================================================*/
METHOD guardar() CLASS ARMovStock
	
	Local cFunBkp 	:= FunName()

	Private lMsErroAuto := .F.
	
	SetFunName("MATA241")

	MSExecAuto({|x,y,z| MATA241(x,y,z)}, ::aCab, ::aDet1, 3)
	
	::lGrabo := !lMsErroAuto

	If !::lGrabo
		::cError := MostraErro("MOVSTOCK")
	Else
		::cNum		:= SD3->D3_DOC
		::cError 	:= ""
	EndIf

	SetFunName(cFunBkp)

RETURN Nil 
