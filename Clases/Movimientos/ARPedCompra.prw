#INCLUDE 'PROTHEUS.CH'
	
/*=====================================================================
|---------------------------------------------------------------------|
| Programa | ARPedCompra | Autor: Andres Demarziani | Fecha: 27/04/2020  |
|---------------------------------------------------------------------|
| Descripcion: Carga docuemntos de Pedidos de venta                   |
|---------------------------------------------------------------------|
======================================================================*/
CLASS ARPedCompra FROM ARDocumento

	METHOD New() CONSTRUCTOR
	METHOD guardar()

ENDCLASS

/*=====================================================================
|---------------------------------------------------------------------|
| Programa | ARPedCompra | Autor: Andres Demarziani | Fecha: 29/10/2017  |
|---------------------------------------------------------------------|
======================================================================*/
METHOD New() CLASS ARPedCompra
	
	_Super:New("2")

RETURN SELF

/*=====================================================================
|---------------------------------------------------------------------|
| Programa | ARPedCompra | Autor: Andres Demarziani | Fecha: 29/10/2017  |
|---------------------------------------------------------------------|
======================================================================*/
METHOD guardar() CLASS ARPedCompra
	
	Local cFunBkp 	:= FunName()
	Local lNumer	:= Empty(::getValEncab("C7_NUM"))
	Local nSaveSX8

	If lNumer
		nSaveSX8	:= If(Type('nSaveSx8')=='U', GetSX8Len(), nSaveSX8)    
	EndIf

	Private lMsErroAuto := .F.
	
	SetFunName("MATA120")

	MSExecAuto({|a,b,c| MATA120(a,b,c)}, ::aCab, ::aDet1, 3)
	
	::lGrabo := !lMsErroAuto

	If !::lGrabo
		// Revierto numeración
		If lNumer
    		While ( GetSX8Len() > nSaveSX8 )
				RollBackSX8()
			EndDo
		EndIf

		::cError := MostraErro("PEDCOM")
	Else
		::cNum	:= SC7->C7_NUM

		If lNumer
			ConfirmSX8()
		EndIf
	EndIf

	SetFunName(cFunBkp)

RETURN Nil 
