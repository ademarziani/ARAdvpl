#INCLUDE 'PROTHEUS.CH'
	
/*=====================================================================
|----------------------------------------------------------------------
| Programa | ARModalidad | Autor: Andres Demarziani
|----------------------------------------------------------------------
| Descripcion: Clase de Banco.
|----------------------------------------------------------------------
======================================================================*/
CLASS ARModalidad FROM ARDocumento

	METHOD New() CONSTRUCTOR
	METHOD guardar()

ENDCLASS

/*=====================================================================
|----------------------------------------------------------------------
| Programa | ARModalidad | Autor: Andres Demarziani
|----------------------------------------------------------------------
======================================================================*/
METHOD New() CLASS ARModalidad	

	_Super:New()
	::setTipo("1")
	
RETURN SELF

/*=====================================================================
|----------------------------------------------------------------------
| Programa | ARModalidad | Autor: Andres Demarziani
|----------------------------------------------------------------------
======================================================================*/
METHOD guardar() CLASS ARModalidad
	
	Local cFunBkp 	:= FunName()

	Private lMsErroAuto := .F.
	
	SetFunName("FINA010")

	MsExecAuto({|x,y| FINA010(x,y)}, ::aCab, 3)
	
	::lGrabo := !lMsErroAuto

	If !::lGrabo
		::cError := MostraErro("MODALIDAD")
	Else
		::cError 	:= ""
	EndIf

	SetFunName(cFunBkp)

RETURN Nil 


