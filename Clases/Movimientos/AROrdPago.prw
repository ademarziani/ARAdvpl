#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'RWMAKE.CH'
	
/*=====================================================================
|---------------------------------------------------------------------|
| Programa | AROrdPago | Autor: Andres Demarziani | Fecha: 18/12/2019 |
|---------------------------------------------------------------------|
| Descripcion: Carga de OrdPagos de cobranzas (FJR, SEK).             |
|---------------------------------------------------------------------|
======================================================================*/
CLASS AROrdPago

	DATA cFil
	DATA dFecha		
	DATA oProveedor
	DATA cNumero
	DATA cNaturez

	DATA aTxOrdPago
	DATA aTxMonedas
	
	DATA aPagos
	DATA aDocumentos	
	DATA aErrores
	
	DATA aDatFJR
	DATA aDatSEK
	DATA aDatSE2
	
	DATA lMuestra
	DATA lAgrupa
	
	DATA lGrabo
	DATA cError
	
	METHOD New() CONSTRUCTOR
	METHOD setNumero()
	METHOD setPago()
	METHOD setDocumento()
	METHOD setPropAsto()
	METHOD armaPagos()
	
	METHOD guardar()
	METHOD graboDatos()
	METHOD borrar()

ENDCLASS

/*=====================================================================
|---------------------------------------------------------------------|
| Programa | AROrdPago | Autor: Andres Demarziani | Fecha: 18/12/2019 |
|---------------------------------------------------------------------|
======================================================================*/
METHOD New(dFecha, oProveedor, cNumero, cNaturez) CLASS AROrdPago
	
	Local aArea		:= GetArea()

	::setNumero(cNumero)
	
	::cFil			:= xFilial("FJR")
	::dFecha		:= dFecha
	::oProveedor	:= oProveedor
	::cNaturez		:= IIf(cNaturez!=Nil, cNaturez, "")
	::cVersion		:= IIf(cVersion!=Nil, cVersion, "00")

	::aTxMonedas	:= {}
	
	::lMuestra		:= .F.
	::lAgrupa		:= .T.

	::lUpdNumSX5	:= .F.
	
	aAdd(::aTxMonedas, 1)
	aAdd(::aTxMonedas, RecMoeda(dFecha, 2))
	aAdd(::aTxMonedas, RecMoeda(dFecha, 3))
	aAdd(::aTxMonedas, RecMoeda(dFecha, 4))
	aAdd(::aTxMonedas, RecMoeda(dFecha, 5))	

	::aTxOrdPago 	:= {}
	
	aAdd(::aTxOrdPago, {::aTxMonedas[1], 0, 0})
	aAdd(::aTxOrdPago, {::aTxMonedas[2], 0, 0})
	aAdd(::aTxOrdPago, {::aTxMonedas[3], 0, 0})
	aAdd(::aTxOrdPago, {::aTxMonedas[4], 0, 0})
	aAdd(::aTxOrdPago, {::aTxMonedas[5], 0, 0})			
	
	::aPagos		:= {}
	::aDocumentos	:= {}	
	::aErrores		:= {}
	
	::lGrabo		:= .F.
	::cError		:= ""
	
	::aDatFJR		:= {}
	::aDatSEK		:= {}
	::aDatSE2		:= {}
	
	dbSelectArea("FJR")
	dbSetOrder(1)
	If dbSeek(::cFil+::cNumero)
		aAdd(::aErrores, {"La Orden de pago numero '"+AllTrim(::cNumero)+"' ya existe."})
	EndIf
	
	RestArea(aArea)
	
Return SELF

/*=====================================================================
|---------------------------------------------------------------------|
| Programa | AROrdPago | Autor: Andres Demarziani | Fecha: 18/12/2019 |
|---------------------------------------------------------------------|
======================================================================*/
METHOD setNumero(cNumero) CLASS AROrdPago

	Local nTamDoc := TamSX3("FJR_ORDPAGO")[1]

	If cNumero != Nil
		::cNumero := PadR(Right(cNumero, nTamDoc), nTamDoc)
	Else
		::cNumero := DToS(dDataBase)+Right(StrTran(Time(),":",""),4)
	EndIf
	
Return Nil

/*=====================================================================
|---------------------------------------------------------------------|
| Programa | AROrdPago | Autor: Andres Demarziani | Fecha: 18/12/2019  |
|---------------------------------------------------------------------|
======================================================================*/
METHOD setPago(cTipo, cPref, cNum, nMoneda, dFecha, dVcto, oBanco, nValor, nAliq, cCFO, cProv) CLASS AROrdPago
	
	Local oPago
	Local nTxMoneda	:= ::aTxOrdPago[nMoneda][1]
	
	If nTxMoneda > 0
		oPago := AROrdPagoPago():New(cTipo, cPref, cNum, nMoneda, dFecha, dVcto, cCtaChq, cCuit, nValor, nTxMoneda, nAliq, cCFO, cProv)
		
		If cTipo $ "RS|RL|RB|RI|RG"
			oPago:setRetenc(::cSerie, ::cNumero, ::oProveedor:cCod, ::oProveedor:cLoja)
		EndIf
		
		aAdd(::aPagos, oPago)

		::aTxOrdPago[nMoneda][2] += nValor
		::aTxOrdPago[nMoneda][3] += nValor	
	Else
		aAdd(::aErrores, {"No existe tipo de cambio informado en moneda '"+cValToChar(nMoneda)+"' para la fecha del OrdPago."})
	EndIf
	
Return Nil

/*=====================================================================
|---------------------------------------------------------------------|
| Programa | AROrdPago | Autor: Andres Demarziani | Fecha: 18/12/2019  |
|---------------------------------------------------------------------|
======================================================================*/
METHOD setDocumento(cTipo, cCuota, cSerie, cDoc, oDoc) CLASS AROrdPago

	Local oDocumento
	
	If ValType(oDoc)=="O"
		aAdd(::aDocumentos, oDoc)
	Else
		oDocumento := AROrdPagoTitulo():New(::oProveedor, cTipo, cCuota, cSerie, cDoc)

		If Empty(oDocumento:nRecno)
			aAdd(::aErrores, {"No se encontró el título informado (Serie: "+AllTrim(cSerie)+" / Numero: "+cDoc+")"})
		Else
			aAdd(::aDocumentos, oDocumento)
		EndIf
	EndIf

Return Nil

/*=====================================================================
|---------------------------------------------------------------------|
| Programa | AROrdPago | Autor: Andres Demarziani | Fecha: 18/12/2019  |
|---------------------------------------------------------------------|
======================================================================*/
METHOD setPropAsto(lMuestra, lAgrupa) CLASS AROrdPago

	::lMuestra 	:= lMuestra
	::lAgrupa	:= lAgrupa
	
Return Nil
/*=====================================================================
|---------------------------------------------------------------------|
| Programa | AROrdPago | Autor: Andres Demarziani | Fecha: 18/12/2019  |
|---------------------------------------------------------------------|
======================================================================*/
METHOD guardar() CLASS AROrdPago

	Local nX
	Local aAuxSEK
	Local aAuxSE2
	LOcal cFNameBkp		:= FunName()

	Private lMsErroAuto := .F.
			
	::armaPagos()

	If Empty(::aDatFJR)
		aAdd(::aDatFJR, {"FJR_FILIAL"	, ::cFil, Nil})
		aAdd(::aDatFJR, {"FJR_ORDPAGO"	, ::cNumero, Nil})
		aAdd(::aDatFJR, {"FJR_EMISSA"	, ::dFecha, Nil})
		aAdd(::aDatFJR, {"FJR_NATURE"	, ::cNaturez, Nil})
		aAdd(::aDatFJR, {"FJR_FORNEC"	, ::oProveedor:cCod, Nil})
		aAdd(::aDatFJR, {"FJR_LOJA"		, ::oProveedor:cLoja, Nil})
		aAdd(::aDatFJR, {"FJR_CANCEL"	, .F., Nil})
		aAdd(::aDatFJR, {"FJR_MSFIL"	, cFilAnt, Nil})
	EndIf

	If Empty(::aDatSEK)
		For nX := 1 To Len(::aPagos)
			aAuxSEK := {}

			aAdd(aAuxSEK, {"EK_FILIAL"	, ::cFil, Nil})
			aAdd(aAuxSEK, {"EK_ORDPAGO"	, ::cNumero, Nil})
			aAdd(aAuxSEK, {"EK_TIPODOC"	, ::aPagos[nX]:cTipo, Nil})
			aAdd(aAuxSEK, {"EK_PREFIXO"	, ::aPagos[nX]:cPref, Nil})
			aAdd(aAuxSEK, {"EK_NUMERO"	, ::aPagos[nX]:cNum, Nil})
			aAdd(aAuxSEK, {"EK_PARCELA"	, ::aPagos[nX]:cCuota, Nil})
			aAdd(aAuxSEK, {"EK_TIPO"	, ::aPagos[nX]:cTipo, Nil})
			aAdd(aAuxSEK, {"EK_MOEDA"	, ::aPagos[nX]:cMoneda, Nil})
			aAdd(aAuxSEK, {"EK_FORNECE"	, ::oProveedor:cCod, Nil})
			aAdd(aAuxSEK, {"EK_LOJA"	, ::oProveedor:cLoja, Nil})
			aAdd(aAuxSEK, {"EK_FORNEPG"	, ::oProveedor:cCod, Nil})
			aAdd(aAuxSEK, {"EK_LOJAPG"	, ::oProveedor:cLoja, Nil})
			aAdd(aAuxSEK, {"EK_VALOR"	, ::aPagos[nX]:nValor, Nil})
			aAdd(aAuxSEK, {"EK_VLMOED1"	, Round(::aPagos[nX]:nValor * ::aTxMonedas[::aPagos[nX]:nMoneda], MsDecimais(1)), Nil})
			aAdd(aAuxSEK, {"EK_DTDIGIT"	, dDataBase, Nil})
			aAdd(aAuxSEK, {"EK_EMISSAO"	, ::aPagos[nX]:dFecha, Nil})
			aAdd(aAuxSEK, {"EK_VENCTO"	, ::aPagos[nX]:dVcto, Nil})
			aAdd(aAuxSEK, {"EK_BANCO"	, ::aPagos[nX]:oBanco:cCod, Nil})
			aAdd(aAuxSEK, {"EK_AGENCIA"	, ::aPagos[nX]:oBanco:cAgencia, Nil})
			aAdd(aAuxSEK, {"EK_CONTA"	, ::aPagos[nX]:oBanco:cCuenta, Nil})		
			aAdd(aAuxSEK, {"EK_TXMOE02"	, ::aTxOrdPago[2][1], Nil})
			aAdd(aAuxSEK, {"EK_TXMOE03"	, ::aTxOrdPago[3][1], Nil})
			aAdd(aAuxSEK, {"EK_TXMOE04"	, ::aTxOrdPago[4][1], Nil})
			aAdd(aAuxSEK, {"EK_TXMOE05"	, ::aTxOrdPago[5][1], Nil})

			If !Empty(::aPagos[nX]:aRet)
				aAdd(aAuxSEK, {"RET", ::aPagos[nX]:aRet, Nil})
			EndIf		
			
			aAdd(::aDatSEK, aClone(aAuxSEK))
		Next nX
	EndIf

	If Empty(::aDatSE2)
		For nX := 1 To Len(::aDocumentos)
			aAuxSE2 := {}
			
			aAdd(aAuxSE2, {"E2_PREFIXO"	, ::aDocumentos[nX]:cSerie, Nil})
			aAdd(aAuxSE2, {"E2_PARCELA"	, ::aDocumentos[nX]:cCuota, Nil})
			aAdd(aAuxSE2, {"E2_TIPO"	, ::aDocumentos[nX]:cTipo, Nil})
			aAdd(aAuxSE2, {"E2_NUM"		, ::aDocumentos[nX]:cDoc, Nil})
			aAdd(aAuxSE2, {"E2_MOEDA"	, cValToChar(::aDocumentos[nX]:nMoneda), Nil})
			aAdd(aAuxSE2, {"nBaixar"	, ::aDocumentos[nX]:nVlrCanc, Nil})
			aAdd(aAuxSE2, {"nBxMoeda1"	, ::aDocumentos[nX]:aVlrCanc[1], Nil})
			aAdd(aAuxSE2, {"nBxMoeda2"	, ::aDocumentos[nX]:aVlrCanc[2], Nil})
			aAdd(aAuxSE2, {"nBxMoeda3"	, ::aDocumentos[nX]:aVlrCanc[3], Nil})
			aAdd(aAuxSE2, {"nBxMoeda4"	, ::aDocumentos[nX]:aVlrCanc[4], Nil})
			aAdd(aAuxSE2, {"nBxMoeda5"	, ::aDocumentos[nX]:aVlrCanc[5], Nil})	
			aAdd(aAuxSE2, {"E2_DESCONT"	, 0, Nil})
			aAdd(aAuxSE2, {"E2_JUROS"	, 0, Nil})
			aAdd(aAuxSE2, {"E2_MULTA"	, 0, Nil})
			aAdd(aAuxSE2, {"cMotBxSE2"	, "NOR", Nil})
			aAdd(aAuxSE2, {"nImpRetSE2"	, 0, Nil})
			aAdd(aAuxSE2, {"E2_SALDO"	, ::aDocumentos[nX]:nVlrCanc, Nil})	
			aAdd(aAuxSE2, {"R_E_C_N_O_"	, ::aDocumentos[nX]:nRecno, Nil})
			
			aAdd(::aDatSE2, aClone(aAuxSE2))
		Next nX
	EndIf

	SetFunName("FINA846")

	If Empty(::aErrores)		
		//MSExecAuto({|w,x,y,z| FINA846(w,x,y,z)}, ::aDatFJR, ::aDatSE2, ::aDatSEL, 3)
		//
		//If lMsErroAuto
		//	::cError := MOSTRAERRO("OrdPago")
		//Else
		//	::lGrabo := .T.
		//EndIf
		
		::lGrabo := ::graboDatos()
		
		If !::lGrabo
			RollbackSX8()
			::cError := "No se guardo el OrdPago '"+::cNumero+"', serie '"+::cSerie+"'"
		Else
			ConfirmSX8()
		EndIf
	Else
		For nX := 1 To Len(::aErrores)
			::cError += ::aErrores[nX][1] + CRLF // Marca: PREIMPCXC
		Next nX
	EndIf

	SetFunName(cFNameBkp)

Return Nil

/*=====================================================================
|---------------------------------------------------------------------|
| Programa | AROrdPago | Autor: Andres Demarziani | Fecha: 18/12/2019  |
|---------------------------------------------------------------------|
======================================================================*/
METHOD borrar() CLASS AROrdPago

	Local cFNameBkp		:= FunName()
	
	Private lMsErroAuto := .F.
	
	aAdd(::aDatFJR, {"FJR_FILIAL"	, ::cFil, Nil})	
	aAdd(::aDatFJR, {"FJR_ORDPAGO"	, ::cNumero, Nil})
	aAdd(::aDatFJR, {"FJR_CLIENT"	, ::oProveedor:cCod, Nil})
	aAdd(::aDatFJR, {"FJR_LOJA"		, ::oProveedor:cLoja, Nil})
	aAdd(::aDatFJR, {"FJR_NATURE"	, ::cNaturez, Nil})
	aAdd(::aDatFJR, {"FJR_DTDIGI"	, ::dFecha, Nil})
	aAdd(::aDatFJR, {"FJR_EMISSAO"	, ::dFecha, Nil})
	aAdd(::aDatFJR, {"FJR_COBRAD"	, ::cCobrad, Nil})
	aAdd(::aDatFJR, {"FJR_RECPRV"	, ::cNumProv, Nil})

	SetFunName("FINA846")
	
	MSExecAuto({|w,x,y,z| FINA846(w,x,y,z)}, ::aDatFJR, {}, {}, 5)
	
	If lMsErroAuto
		aAdd(::aErrores, {MOSTRAERRO("OrdPago")})
		::cError := ::aErrores[Len(::aErrores)]
	Else
		::lGrabo := .T.
	EndIf

	SetFunName(cFNameBkp)

Return Nil

/*=====================================================================
|---------------------------------------------------------------------|
| Programa | AROrdPago | Autor: Andres Demarziani | Fecha: 18/12/2019  |
|---------------------------------------------------------------------|
======================================================================*/
METHOD armaPagos() CLASS AROrdPago

	Local nX
	Local nM

	For nX := 1 To Len(::aDocumentos)
		For nM := 1 To Len(::aTxOrdPago)	
			If ::aTxOrdPago[nM][3] > 0 .And. ::aDocumentos[nX]:nSaldo > 0
				::aTxOrdPago[nM][3] := ::aDocumentos[nX]:cancela(nM, ::aTxOrdPago[nM][1], ::aTxOrdPago[1][3])
			EndIf
		Next nM
	Next nX

Return Nil

/*=====================================================================
|---------------------------------------------------------------------|
| Programa | AROrdPago | Autor: Andres Demarziani | Fecha: 18/12/2019  |
|---------------------------------------------------------------------|
======================================================================*/
METHOD graboDatos() CLASS AROrdPago

	Local nX
	Local nPos
	Local aAuxSEK	
	Local aArea		:= GetArea()
	Local cDiario	:= Criavar("EK_DIACTB",.T.)
	Local cMot		:= "NOR"	
	Local cIDProc	:= GetSx8Num('FKA','FKA_IDPROC')
	Local cCredInm	:= "TF /EF /"	
	Local lGrabo	
	
	Local lAsto			:= .T.	
	Local cCodAsto		:= "570"
	Local nHdlPrv		:= 0
	Local cArquivo		:= ""
	Local cLote			:= Tabela("09", "FIN")	
	Local cFuncion		:= FunName()

	Local nTotal 		:= 0
	
	Private cMotBx		:= cMot
	Private nTotAbat	:= 0
	Private lCarga		:= .F.
	
	If lAsto
		fEncabezado(@nHdlPrv, @cArquivo, cLote, cFuncion)
	EndIf
	
	//------------
	// Encabezado
	//------------
	dbSelectArea("FJR")
	RecLock("FJR",.T.)
	aEval(::aDatFJR, {|x| If(FieldPos(x[1])>0, FieldPut(FieldPos(x[1]),x[2]), )})		
	MsUnlock()

	//------------------
	// Medios de Pagos
	//------------------
	For nX := 1 To Len(::aDatSEK)
		aAuxSEK := ::aDatSEK[nX]		

		dbSelectArea("SEK")		
		RecLock("SEK",.T.)			
		aEval(aAuxSEK, {|x| If(FieldPos(x[1])>0, FieldPut(FieldPos(x[1]),x[2]), )})		
		MsUnlock()
		
		If lAsto
			nTotal += DetProva(nHdlPrv, cCodAsto, cFuncion, cLote)
			
			RecLock("SEK", .F.)
			SEK->EK_LA := "S"
			MsUnlock()
		EndIf
		
		If (nPos := aScan(aAuxSEK, {|x| x[1] == "RET"})) > 0
			dbSelectArea("SFE")
			RecLock("SFE",.T.)			
			aEval(aAuxSEK[nPos][2], {|x| If(FieldPos(x[1])>0, FieldPut(FieldPos(x[1]),x[2]), )})		
			MsUnlock()		
		EndIf
		
		If AllTrim(SEK->EK_TIPO) $ cCredInm .And. SEK->EK_TRANSIT == "2"
			Fa840GSE5(2, "", ::cNaturez, ::cNumero, ::cSerie, ::aTxMonedas, cDiario, cMot, cIDProc)
		EndIf
	Next nX

	//---------------------------
	// Cancelacion de documentos
	//---------------------------
	For nX := 1 To Len(::aDocumentos)		
		SE2->(dbGoTo(::aDocumentos[nX]:nRecno))
		If !SE2->(Eof())					
			RecLock("SE2",.F.)
			SE2->E2_BAIXA 	:= ::dFecha
			SE2->E2_MOTIVO	:= cMot
			SE2->E2_MOVIMEN	:= ::dFecha
			SE2->E2_SALDO	:= ::aDocumentos[nX]:nSaldo
			SE2->E2_SERREC  := ::cSerie
			SE2->E2_ORDPAGO	:= ::cNumero
			SE2->E2_DTACRED	:= ::dFecha
			SE2->E2_STATUS	:= IF(::aDocumentos[nX]:nSaldo<=0,"B","A")
			SE2->E2_VALLIQ	:= ::aDocumentos[nX]:nVlrCanc
			MsUnlock()			
		
			RecLock("SEK",.T.)
			SEK->EK_FILIAL	:= ::cFil
			SEK->EK_TIPODOC	:= "TB"
			SEK->EK_PREFIXO	:= SE2->E2_PREFIXO
			SEK->EK_NUMERO	:= SE2->E2_NUM
			SEK->EK_PARCELA	:= SE2->E2_PARCELA
			SEK->EK_TIPO	:= SE2->E2_TIPO  
			SEK->EK_EMISSAO	:= SE2->E2_EMISSAO
			SEK->EK_DTDIGIT	:= dDataBase
			SEK->EK_VENCTO	:= SE2->E2_VENCREA
			SEK->EK_MOEDA	:= STRZERO(SE2->E2_MOEDA,2)
			SEK->EK_VALOR	:= SE2->E2_VALLIQ
			SEK->EK_VLMOED1	:= Round((SE2->E2_VALLIQ)*::aTxMonedas[Max(1,SE2->E2_MOEDA)],MsDecimais(1))
			SEK->EK_FORNECE	:= SE2->E2_FORNECE
			SEK->EK_LOJA	:= SE2->E2_LOJA
			SEK->EK_ORDPAGO	:= ::cNumero
			SEK->EK_FORNEPG	:= ::oProveedor:cCod
			SEK->EK_LOJAPG	:= ::oProveedor:cLoja
			F840GrvTx(::aTxMonedas)
			MsUnlock()			
			
			dbSelectArea("SEK")
			If lAsto
				nTotal += DetProva(nHdlPrv, cCodAsto, cFuncion, cLote)
				
				RecLock("SEK", .F.)
				SEK->EK_LA := "S"
				MsUnlock()
			EndIf
			
			Fa840GSE5(1,, ::cNaturez, ::cNumero, ::cSerie, ::aTxMonedas, cDiario, cMot, cIDProc)
		EndIf
	Next nX
	
	ConfirmSX8()
	
	RestArea(aArea)
	
	If lAsto .And. nTotal > 0
		fFinalizaAsiento(nHdlPrv, cArquivo, cLote, ::lMuestra, ::lAgrupa, nTotal)
	EndIf
	
	FJR->(dbSetOrder(1))
	lGrabo := FJR->(dbSeek(::cFil+::cSerie+::cNumero))

Return lGrabo

/*=====================================================================
|---------------------------------------------------------------------|
| Programa | AROrdPago | Autor: Andres Demarziani | Fecha: 18/12/2019  |
|---------------------------------------------------------------------|
======================================================================*/
Static Function fEncabezado(nHdlPrv, cArquivo, cLote, cFuncion)

	Local lRet := .T.

	nHdlPrv := HeadProva(cLote, cFuncion, Substr(cUsuario,07,15), @cArquivo)
					  
	If nHdlPrv <= 0
		Help(" ",1,"A100NOPROV")
		lRet := .F.
	EndIf

Return lRet 

/*=====================================================================
|---------------------------------------------------------------------|
| Programa | AROrdPago | Autor: Andres Demarziani | Fecha: 18/12/2019  |
|---------------------------------------------------------------------|
======================================================================*/
Static Function fFinalizaAsiento(nHdlPrv, cArquivo, cLote, lMuestra, lAgrupa, nTotal)

	Local lRet := .F.

	RodaProva(nHdlPrv, nTotal)
	
	lRet := cA100Incl(cArquivo, nHdlPrv, 3, cLote, lMuestra, lAgrupa)

Return lRet
