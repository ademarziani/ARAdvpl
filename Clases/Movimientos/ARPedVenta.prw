#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'RWMAKE.CH'
	
/*=====================================================================
|---------------------------------------------------------------------|
| Programa | ARPedVenta | Autor: Andres Demarziani | Fecha: 27/04/20  |
|---------------------------------------------------------------------|
| Descripcion: Carga docuemntos de Pedidos de venta                   |
|---------------------------------------------------------------------|
======================================================================*/
CLASS ARPedVenta FROM ARDocumento
	
	DATA oCliente
	DATA cNum
	DATA aProd
	DATA nMoneda
	
	DATA lGrabo
	DATA cError

	METHOD New() CONSTRUCTOR
	METHOD setCab()
	METHOD setDet()
	METHOD setItem()
	METHOD guardar()

ENDCLASS

/*=====================================================================
|---------------------------------------------------------------------|
| Programa | ARPedVenta | Autor: Demarziani | Fecha: 29/10/2021       |
|---------------------------------------------------------------------|
======================================================================*/
METHOD New(oCliente, aProd, nMoneda) CLASS ARPedVenta
	
	_Super:New()
	::setTipo("2")

	If ValType(oCliente) == "O"
		::oCliente	:= oCliente
		::aProd		:= aProd
		::cError	:= ""
		::nMoneda	:= nMoneda

		::setCab()
		::setDet()
	EndIf

RETURN SELF

/*=====================================================================
|---------------------------------------------------------------------|
| Programa | ARPedVenta | Autor: Demarziani | Fecha: 29/10/2021       |
|---------------------------------------------------------------------|
======================================================================*/
METHOD setCab() CLASS ARPedVenta

	If ValType(oCliente) == "O"
		aAdd(::aCab, {"C5_EMISSAO", dDataBase, Nil})
		aAdd(::aCab, {"C5_TIPO", "N", Nil})		
		aAdd(::aCab, {"C5_CLIENTE", ::oCliente:cCod, Nil})
		aAdd(::aCab, {"C5_LOJACLI", ::oCliente:cLoja, Nil})
		aAdd(::aCab, {"C5_CLIENT" , ::oCliente:cCod, Nil})
		aAdd(::aCab, {"C5_LOJAENT", ::oCliente:cLoja, Nil})
		aAdd(::aCab, {"C5_CONDPAG", ::oCliente:cCond, Nil})
		aAdd(::aCab, {"C5_NATUREZ", ::oCliente:cNatur, Nil})
		aAdd(::aCab, {"C5_TIPOREM", "0", Nil})
		aAdd(::aCab, {"C5_MOEDA", ::nMoneda, Nil})
	EndIf
	
RETURN Nil

/*=====================================================================
|---------------------------------------------------------------------|
| Programa | ARPedVenta | Autor: Demarziani | Fecha: 29/10/2021       |
|---------------------------------------------------------------------|
======================================================================*/
METHOD setDet() CLASS ARPedVenta

	Local nP
		
	If ::aProd <> Nil
		For nP := 1 To Len(::aProd)		
			::setItem(::aProd[nP])
		Next nP
	EndIf
	
RETURN Nil

/*=====================================================================
|---------------------------------------------------------------------|
| Programa | ARPedVenta | Autor: Demarziani | Fecha: 29/10/2021       |
|---------------------------------------------------------------------|
======================================================================*/
METHOD setItem(oProd) CLASS ARPedVenta

	Local nItem		:= Len(::aDet1)+1
	Local aItem		:= {}
	Local nDecTot	:= TamSX3("C6_VALOR")[2]
	
	aAdd(aItem, {"C6_ITEM", StrZero(nItem, TamSX3("C6_ITEM")[1]), Nil})
	aAdd(aItem, {"C6_PRODUTO", oProd:cCod, Nil})
	aAdd(aItem, {"C6_QTDVEN", oProd:nQtd, Nil})
	aAdd(aItem, {"C6_PRCVEN", oProd:nPrc, Nil})
	aAdd(aItem, {"C6_VALOR", Round(oProd:nQtd*oProd:nPrc, nDecTot), Nil})				
	aAdd(aItem, {"C6_TES", oProd:cTS, Nil})
	
	aAdd(::aDet1, aItem)

Return Nil

/*=====================================================================
|---------------------------------------------------------------------|
| Programa | ARPedVenta | Autor: Demarziani | Fecha: 29/10/2021       |
|---------------------------------------------------------------------|
======================================================================*/
METHOD guardar() CLASS ARPedVenta
	
	Local cFunBkp 	:= FunName()
	Local lNumer	:= Empty(::getValEncab("C5_NUM"))
	Local nSaveSX8

	If lNumer
		nSaveSX8 := If(Type('nSaveSx8')=='U', GetSX8Len(), nSaveSX8)    
	EndIf

	Private lMsErroAuto := .F.
	
	SetFunName("MATA410")

	MSExecAuto({|a,b,c| Mata410(a,b,c)}, ::aCab, ::aDet1, 3)
	
	::lGrabo := !lMsErroAuto

	If !::lGrabo
		// Revierto numeración
		If lNumer
    		While ( GetSX8Len() > nSaveSX8 )
				RollBackSX8()
			EndDo
		EndIf

		::cError := MostraErro("PEDVTA")
	Else
		::cNum		:= SC5->C5_NUM
		::cError 	:= ""

		If lNumer
			ConfirmSX8()
		EndIf
	EndIf

	SetFunName(cFunBkp)

RETURN Nil 
