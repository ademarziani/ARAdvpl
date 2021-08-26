#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'RWMAKE.CH'
	
/*=====================================================================
|---------------------------------------------------------------------|
| Programa | DSPEDVTA | Autor: Andres Demarziani | Fecha: 27/04/2020  |
|---------------------------------------------------------------------|
| Descripcion: Carga docuemntos de Pedidos de venta                   |
|---------------------------------------------------------------------|
======================================================================*/
CLASS DSPEDVTA

	DATA aCab
	DATA aDet
	
	DATA oCliente
	DATA cNum

	DATA aProd
	DATA nMoneda
	
	DATA lGrabo
	DATA cError

	METHOD New() CONSTRUCTOR
	METHOD setEncabezado()
	METHOD setValEncab()
	METHOD getValEncab()
	METHOD setDetalle()
	METHOD setItem()
	METHOD setValDetalle()
	METHOD guardar()

ENDCLASS

/*=====================================================================
|---------------------------------------------------------------------|
| Programa | DSPEDVTA | Autor: Andres Demarziani | Fecha: 29/10/2017  |
|---------------------------------------------------------------------|
======================================================================*/
METHOD New(oCliente, aProd, nMoneda) CLASS DSPEDVTA
	
	::oCliente	:= oCliente
	::aProd		:= aProd
	::cError	:= ""
	::nMoneda	:= nMoneda

	::aCab := {}	
	::aDet := {}

	::setEncabezado()
	::setDetalle()

RETURN SELF

/*=====================================================================
|---------------------------------------------------------------------|
| Programa | DSPEDVTA | Autor: Andres Demarziani | Fecha: 29/10/2017  |
|---------------------------------------------------------------------|
======================================================================*/
METHOD setEncabezado() CLASS DSPEDVTA

	If ::oCliente <> Nil
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
| Programa | DSPEDVTA   Autor: Andres Demarziani | Fecha: 29/10/2017  |
|---------------------------------------------------------------------|
======================================================================*/
METHOD setDetalle() CLASS DSPEDVTA

	Local nP
		
	If ::aProd <> Nil
		For nP := 1 To Len(::aProd)		
			::setItem(::aProd[nP])
		Next nP
	EndIf
	
RETURN Nil

/*=====================================================================
|---------------------------------------------------------------------|
| Programa | DSPEDVTA | Autor: Andres Demarziani | Fecha: 29/10/2017  |
|---------------------------------------------------------------------|
======================================================================*/
METHOD guardar() CLASS DSPEDVTA
	
	Local cFunBkp 	:= FunName()
	Local nSaveSX8	:= If(Type('nSaveSx8')=='U', GetSX8Len(), nSaveSX8)    

	Private lMsErroAuto := .F.
	
	SetFunName("MATA410")

	MSExecAuto({|a,b,c| Mata410(a,b,c)}, ::aCab, ::aDet, 3)
	
	::lGrabo := !lMsErroAuto

	If !::lGrabo
		// Revierto numeración
    	While ( GetSX8Len() > nSaveSX8 )
			RollBackSX8()
		EndDo

		::cError := MostraErro("PEDVTA")
	Else
		::cNum	:= SC5->C5_NUM
	EndIf

	SetFunName(cFunBkp)

RETURN Nil 

/*=====================================================================
|---------------------------------------------------------------------|
| Programa | DSPEDVTA  | Autor: Andres Demarziani | Fecha: 20/12/2019 |
|---------------------------------------------------------------------|
======================================================================*/
METHOD setValEncab(cCampo, xVal) CLASS DSPEDVTA

	Local nPos := aScan(::aCab, {|x| x[1] == cCampo})
	
	If nPos > 0
		::aCab[nPos][2] := xVal
	Else
		aAdd(::aCab, {cCampo, xVal, Nil})
	EndIf

Return Nil

/*=====================================================================
|---------------------------------------------------------------------|
| Programa | DSPEDVTA | Autor: Andres Demarziani | Fecha: 20/12/2019  |
|---------------------------------------------------------------------|
======================================================================*/
METHOD getValEncab(cCampo) CLASS DSPEDVTA

	Local nPos := aScan(::aCab, {|x| x[1] == cCampo})
	Local xRet := 0
	
	If nPos > 0
		xRet := ::aCab[nPos][2]
	EndIf

Return xRet

/*=====================================================================
|---------------------------------------------------------------------|
| Programa | DSPEDVTA  | Autor: Andres Demarziani | Fecha: 20/12/2019 |
|---------------------------------------------------------------------|
======================================================================*/
METHOD setItem(oProd) CLASS DSPEDVTA

	Local nItem		:= Len(::aDet)+1
	Local aItem		:= {}
	Local nDecTot	:= TamSX3("C6_VALOR")[2]
	
	aAdd(aItem, {"C6_ITEM", StrZero(nItem, TamSX3("C6_ITEM")[1]), Nil})
	aAdd(aItem, {"C6_PRODUTO", oProd:cCod, Nil})
	aAdd(aItem, {"C6_QTDVEN", oProd:nQtd, Nil})
	aAdd(aItem, {"C6_PRCVEN", oProd:nPrc, Nil})
	aAdd(aItem, {"C6_VALOR", Round(oProd:nQtd*oProd:nPrc, nDecTot), Nil})				
	aAdd(aItem, {"C6_TES", oProd:cTS, Nil})
	
	aAdd(::aDet, aItem)

Return Nil

/*=====================================================================
|---------------------------------------------------------------------|
| Programa | DSPEDVTA  | Autor: Andres Demarziani | Fecha: 20/12/2019 |
|---------------------------------------------------------------------|
======================================================================*/
METHOD setValDetalle(cCampo, xVal, nItem) CLASS DSPEDVTA

	Local nPos
	
	nItem := IIf(nItem==Nil, Len(::aDet), nItem)
	
	nPos := aScan(::aDet[nItem], {|x| x[1] == cCampo})
	
	If nPos > 0
		::aDet[nItem][nPos][2] := xVal
	Else
		aAdd(::aDet[nItem], {cCampo, xVal, Nil})
	EndIf

Return Nil
