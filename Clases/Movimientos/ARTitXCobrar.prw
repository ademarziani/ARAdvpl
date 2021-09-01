#INCLUDE 'PROTHEUS.CH'
	
/*=====================================================================
|---------------------------------------------------------------------|
| Programa | ARTitXCobrar | Autor: Demarziani | Fecha: 31/08/2020     |
|---------------------------------------------------------------------|
| Descripcion: Carga docuemntos de Titulos por cobrar.                |
|---------------------------------------------------------------------|
======================================================================*/
CLASS ARTitXCobrar FROM ARDocumento

	DATA cNum
	
	METHOD New() CONSTRUCTOR
	METHOD guardar()

ENDCLASS

/*=====================================================================
|---------------------------------------------------------------------|
| Programa | ARTitXCobrar | Autor: Demarziani | Fecha: 31/08/2020     |
|---------------------------------------------------------------------|
======================================================================*/
METHOD New() CLASS ARTitXCobrar
	
	_Super:New()	
	::setTipo("1")

RETURN SELF

/*=====================================================================
|---------------------------------------------------------------------|
| Programa | ARTitXCobrar | Autor: Demarziani | Fecha: 31/08/2020     |
|---------------------------------------------------------------------|
======================================================================*/
METHOD guardar() CLASS ARTitXCobrar
	
	Local cFunBkp 	:= FunName()

	Private lMsErroAuto := .F.
	
	SetFunName("FINA040")

	MsExecAuto({|x,y| FINA040(x,y)}, ::aCab, 3)
	
	::lGrabo := !lMsErroAuto

	If !::lGrabo
		// Revierto numeración
		::cError := MostraErro("TITXCOB")
	Else
		::cNum		:= SE1->E1_NUM
		::cError 	:= ""
	EndIf

	SetFunName(cFunBkp)

RETURN Nil 
