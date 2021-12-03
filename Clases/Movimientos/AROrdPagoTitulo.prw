#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'RWMAKE.CH'
	
/*=====================================================================
|---------------------------------------------------------------------|
| Programa | AROrdPagoTitulo | Autor:  Demarziani | Fecha: 29/10/2021 |
|---------------------------------------------------------------------|
| Descripcion: Titulo cuentas por Pagar.                              |
|---------------------------------------------------------------------|
======================================================================*/
CLASS AROrdPagoTitulo

	DATA cFil
	DATA cTipo
	DATA cDesTipo
	DATA oFornece
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
| Programa | AROrdPagoTitulo | Autor: Demarziani | Fecha: 29/10/2021  |
|---------------------------------------------------------------------|
======================================================================*/
METHOD New(oFornece, cTipo, cCuota, cSerie, cDoc) CLASS AROrdPagoTitulo

	Local aArea 	:= GetArea()
	Local aAreaSE2	:= SE2->(GetArea())
	
	If oFornece == Nil .And. cDoc == Nil 
		::cFil 			:= xFilial("SE2")
		::oFornece		:= ARProveedor():New(SE2->E2_FORNECE, SE2->E2_LOJA)
		::cTipo			:= AllTrim(SE2->E2_TIPO)
		::cCuota		:= SE2->E2_PARCELA
		::cSerie		:= SE2->E2_PREFIXO
		::cDoc			:= SE2->E2_NUM
		::aVlrCanc		:= {0,0,0,0,0}	
		::cDesTipo		:= Capital(Posicione("SES", 1, xFilial("SES")+::cTipo, "ES_DESC"))
		::nSigno		:= IIf(::cTipo$"NCP/PA", -1, 1)
		::nMoneda		:= SE2->E2_MOEDA
		::nTxMoneda		:= SE2->E2_TXMOEDA
		::dEmissao		:= SE2->E2_EMISSAO
		::dVcto			:= SE2->E2_VENCTO		
		::nValor		:= SE2->E2_VALOR
		::nSldOrig		:= SE2->E2_SALDO
		::nSaldo		:= SE2->E2_SALDO
		::nVlrCanc		:= 0
		::nRecno		:= SE2->(Recno())
	Else
		::cFil 		:= xFilial("SE2")
		::oFornece	:= oFornece
		::cTipo		:= cTipo
		::cCuota	:= cCuota
		::cSerie	:= cSerie
		::cDoc		:= cDoc
		::aVlrCanc	:= {0,0,0,0,0}
			
		dbSelectArea("SE2")
		dbSetOrder(6)
		//E2_FILIAL, E2_FORNECE, E2_LOJA, E2_PREFIXO, E2_NUM, E2_PARCELA, E2_TIPO
		If dbSeek(::cFil+oFornece:cCod+oFornece:cLoja+cSerie+cDoc+cCuota+cTipo)
			::cDesTipo		:= Capital(Posicione("SES", 1, xFilial("SES")+::cTipo, "ES_DESC"))
			::nSigno		:= IIf(::cTipo$"NCP/PA", -1, 1)
			::nMoneda		:= SE2->E2_MOEDA
			::nTxMoneda		:= SE2->E2_TXMOEDA
			::dEmissao		:= SE2->E2_EMISSAO
			::dVcto			:= SE2->E2_VENCTO		
			::nValor		:= SE2->E2_VALOR
			::nSldOrig		:= SE2->E2_SALDO
			::nSaldo		:= SE2->E2_SALDO
			::nVlrCanc		:= 0
			::nRecno		:= SE2->(Recno())
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
	
	RestArea(aAreaSE2)
	RestArea(aArea)
	
RETURN SELF

/*=====================================================================
|---------------------------------------------------------------------|
| Programa | AROrdPagoTitulo | Autor: Demarziani | Fecha: 29/10/2021  |
|---------------------------------------------------------------------|
======================================================================*/
METHOD cancela(nMoneda, nTxMoneda, nVlrRecibido) CLASS AROrdPagoTitulo

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
| Programa | AROrdPagoTitulo | Autor: Demarziani | Fecha: 29/10/2021  |
|---------------------------------------------------------------------|
======================================================================*/
METHOD updateCampo(cCampo, xVal) CLASS AROrdPagoTitulo

	SE2->(dbGoTo(::nRecno))
	If SE2->(Eof())
		RecLock("SE2", .F.)
		&("SE2->E2_"+cCampo) := xVal
		MsUnLock()	
	EndIf

Return Nil

