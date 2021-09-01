#INCLUDE 'PROTHEUS.CH'
	
/*=====================================================================
|---------------------------------------------------------------------|
| Programa | ARTitXPagar | Autor: Demarziani | Fecha: 31/08/2020      |
|---------------------------------------------------------------------|
| Descripcion: Carga docuemntos de Titulos por cobrar.                |
|---------------------------------------------------------------------|
======================================================================*/
CLASS ARTitXPagar FROM ARDocumento

	DATA cNum
	
	METHOD New() CONSTRUCTOR
	METHOD guardar()

ENDCLASS

/*=====================================================================
|---------------------------------------------------------------------|
| Programa | ARTitXPagar | Autor: Demarziani | Fecha: 31/08/2020      |
|---------------------------------------------------------------------|
======================================================================*/
METHOD New() CLASS ARTitXPagar
	
	_Super:New()	
	::setTipo("2")

RETURN SELF

/*=====================================================================
|---------------------------------------------------------------------|
| Programa | ARTitXPagar | Autor: Demarziani | Fecha: 31/08/2020      |
|---------------------------------------------------------------------|
======================================================================*/
METHOD guardar() CLASS ARTitXPagar
	
	Local cFunBkp 	:= FunName()

	Private lMsErroAuto := .F.
	
	SetFunName("FINA050")

	MsExecAuto({|x,y| FINA050(x,y)}, ::aCab, 3)
	
	::lGrabo := !lMsErroAuto

	If !::lGrabo
		// Revierto numeración
		::cError := MostraErro("TITXPAG")
	Else
		::cNum		:= SE2->E2_NUM
		::cError 	:= ""
	EndIf

	SetFunName(cFunBkp)

RETURN Nil 
