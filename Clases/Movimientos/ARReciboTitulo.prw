#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'RWMAKE.CH'
	
/*=====================================================================
|---------------------------------------------------------------------|
| Programa | ARReciboTitulo | Autor:  Demarziani | Fecha: 29/10/2017  |
|---------------------------------------------------------------------|
| Descripcion: Titulo cuentas por cobrar.                             |
|---------------------------------------------------------------------|
======================================================================*/
CLASS ARReciboTitulo

	DATA cFil
	DATA cTipo
	DATA cDesTipo
	DATA oCliente
	DATA cCuota
	DATA cSerie
	DATA cDoc
	DATA nSigno	
	DATA nMoneda
	DATA nTxMoneda
	DATA nValor
	DATA nVlrCanc
	DATA nSldOrig
	DATA nSaldo
	DATA dEmissao
	DATA dVcto
	DATA nRecno
	DATA aVlrCanc
		
	METHOD New() CONSTRUCTOR
	METHOD cancela()
	METHOD updateCampo()

ENDCLASS

/*=====================================================================
|---------------------------------------------------------------------|
| Programa | ARReciboTitulo | Autor: Demarziani | Fecha: 29/10/2017   |
|---------------------------------------------------------------------|
======================================================================*/
METHOD New(oCliente, cTipo, cCuota, cSerie, cDoc) CLASS ARReciboTitulo

	Local aArea 	:= GetArea()
	Local aAreaSE1	:= SE1->(GetArea())
	
	If oCliente == Nil .And. cDoc == Nil 
		::cFil 			:= xFilial("SE1")
		::oCliente		:= ARCliente():New(SE1->E1_CLIENTE, SE1->E1_LOJA)
		::cTipo			:= AllTrim(SE1->E1_TIPO)
		::cCuota		:= SE1->E1_PARCELA
		::cSerie		:= SE1->E1_PREFIXO
		::cDoc			:= SE1->E1_NUM
		::aVlrCanc		:= {0,0,0,0,0}	
		::cDesTipo		:= Capital(Posicione("SES", 1, xFilial("SES")+::cTipo, "ES_DESC"))
		::nSigno		:= IIf(::cTipo$"NCC/RA", -1, 1)
		::nMoneda		:= SE1->E1_MOEDA
		::nTxMoneda		:= SE1->E1_TXMOEDA
		::dEmissao		:= SE1->E1_EMISSAO
		::dVcto			:= SE1->E1_VENCTO		
		::nValor		:= SE1->E1_VALOR
		::nSldOrig		:= SE1->E1_SALDO
		::nSaldo		:= SE1->E1_SALDO
		::nVlrCanc		:= 0
		::nRecno		:= SE1->(Recno())
	Else
		::cFil 		:= xFilial("SE1")
		::oCliente	:= oCliente
		::cTipo		:= cTipo
		::cCuota	:= cCuota
		::cSerie	:= cSerie
		::cDoc		:= cDoc
		::aVlrCanc	:= {0,0,0,0,0}
			
		dbSelectArea("SE1")
		dbSetOrder(2)
		//E1_FILIAL, E1_CLIENTE, E1_LOJA, E1_PREFIXO, E1_NUM, E1_PARCELA, E1_TIPO
		If dbSeek(::cFil+oCliente:cCod+oCliente:cLoja+cSerie+cDoc+cCuota+cTipo)
			::cDesTipo		:= Capital(Posicione("SES", 1, xFilial("SES")+::cTipo, "ES_DESC"))
			::nSigno		:= IIf(::cTipo$"NCC/RA", -1, 1)
			::nMoneda		:= SE1->E1_MOEDA
			::nTxMoneda		:= SE1->E1_TXMOEDA
			::dEmissao		:= SE1->E1_EMISSAO
			::dVcto			:= SE1->E1_VENCTO		
			::nValor		:= SE1->E1_VALOR
			::nSldOrig		:= SE1->E1_SALDO
			::nSaldo		:= SE1->E1_SALDO
			::nVlrCanc		:= 0
			::nRecno		:= SE1->(Recno())
		Else
			::cDesTipo		:= ""
			::nSigno		:= 1
			::nMoneda		:= 1
			::nTxMoneda		:= 1
			::dEmissao		:= CToD("")
			::dVcto			:= CToD("")
			::nValor		:= 0
			::nSldOrig		:= 0
			::nSaldo		:= 0
			::nVlrCanc		:= 0
			::nRecno		:= 0
		EndIf
	EndIf
	
	RestArea(aAreaSE1)
	RestArea(aArea)
	
RETURN SELF

/*=====================================================================
|---------------------------------------------------------------------|
| Programa | ARReciboTitulo | Autor: Demarziani | Fecha: 29/10/2017   |
|---------------------------------------------------------------------|
======================================================================*/
METHOD cancela(nMoneda, nTxMoneda, nVlrRecibido) CLASS ARReciboTitulo

Local nVueltoMRec := 0
Local nReciMTit
Local nCancMTit
Local nCancMRec
	
nMoneda		:= IIf(nMoneda==Nil, ::nMoneda, nMoneda)
nTxMoneda	:= IIf(nTxMoneda==Nil, ::nTxMoneda, nTxMoneda)

If nVlrRecibido > 0
	//-----------------------------------------------------------------------------
	//- nReciMTit = Valor recibido en la moneda del titulo
	//- nCancMTit = Valor que voy a cancelar segun la moneda del titulo
	//				Puede que el valor recibido sea mayor a lo que voy a cancelar
	//				Por este motivo, tomo el valor minimo.
	//- nCancMTit = Valor que voy a cancelar en la moneda del recibo
	//-				Esto lo hago para luego devolver un vuelto
	//-----------------------------------------------------------------------------
	nReciMTit := xMoeda(nVlrRecibido, nMoneda, ::nMoneda, dDataBase, 2, Nil, nTxMoneda)
	nCancMTit := Min(nReciMTit, ::nSaldo)
	nCancMRec := xMoeda(nCancMTit, ::nMoneda, nMoneda, dDataBase, 2, Nil, nTxMoneda)

	// Guardo el valor que cancelo del titulo en moneda del titulo
	::nVlrCanc += nCancMTit

	// Resto el valor al saldo
	::nSaldo -= nCancMTit
	
	// Guardo el valor que cancelo del titulo en moneda del recibo
	::aVlrCanc[nMoneda] += nCancMRec
	
	// Guardo el vuelto para luego devolverlo
	nVueltoMRec := nVlrRecibido - nCancMRec
EndIf

Return nVueltoMRec

/*=====================================================================
|---------------------------------------------------------------------|
| Programa | ARReciboTitulo | Autor: Demarziani | Fecha: 29/10/2017   |
|---------------------------------------------------------------------|
======================================================================*/
METHOD updateCampo(cCampo, xVal) CLASS ARReciboTitulo

	SE1->(dbGoTo(::nRecno))
	If SE1->(Eof())
		RecLock("SE1", .F.)
		&("SE1->E1_"+cCampo) := xVal
		MsUnLock()	
	EndIf

Return Nil

