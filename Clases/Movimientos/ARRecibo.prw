#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'RWMAKE.CH'
	
/*=====================================================================
|---------------------------------------------------------------------|
| Programa | ARRecibo | Autor: Andres Demarziani | Fecha: 18/12/2019  |
|---------------------------------------------------------------------|
| Descripcion: Carga de recibos de cobranzas (FJT, SEL).              |
|---------------------------------------------------------------------|
======================================================================*/
CLASS ARRecibo

	DATA cFil
	DATA dFecha		
	DATA oCliente
	DATA cSerie
	DATA cNumero
	DATA cNaturez
	DATA cCobrad
	DATA cNumProv
	DATA cVersion
	DATA cLiqTjta
	DATA cNroAplc
	DATA lUpdNumSX5

	DATA aTxRecibo
	DATA aTxMonedas
	
	DATA aCobros
	DATA aDocumentos	
	DATA aErrores
	
	DATA aDatFJT
	DATA aDatSEL
	DATA aDatSE1
	
	DATA lMuestra
	DATA lAgrupa
	
	DATA lGrabo
	DATA cError
	
	METHOD New() CONSTRUCTOR
	METHOD setSerie()
	METHOD setNumero()
	METHOD setCobro()
	METHOD setDocumento()
	METHOD setPropAsto()
	METHOD armaCobros()
	METHOD actNumSX5()
	
	METHOD guardar()
	METHOD graboDatos()
	METHOD borrar()

ENDCLASS

/*=====================================================================
|---------------------------------------------------------------------|
| Programa | ARRecibo | Autor: Andres Demarziani | Fecha: 18/12/2019  |
|---------------------------------------------------------------------|
======================================================================*/
METHOD New(dFecha, oCliente, cSerie, cNumero, cNaturez, cCobrad, cNumProv, cVersion, cLiqTjta) CLASS ARRecibo
	
	Local aArea		:= GetArea()

	::setSerie(cSerie)
	::setNumero(cNumero)
	
	::cFil			:= xFilial("FJT")
	::dFecha		:= dFecha
	::oCliente		:= oCliente
	::cNaturez		:= IIf(cNaturez!=Nil, cNaturez, "")
	::cCobrad		:= IIf(cCobrad!=Nil, cCobrad, "")
	::cNumProv		:= IIf(cNumProv!=Nil, cNumProv, "")
	::cVersion		:= IIf(cVersion!=Nil, cVersion, "00")
	::cLiqTjta		:= cLiqTjta

	::aTxMonedas	:= {}
	
	::lMuestra		:= .F.
	::lAgrupa		:= .T.

	::lUpdNumSX5	:= .F.
	
	aAdd(::aTxMonedas, 1)
	aAdd(::aTxMonedas, RecMoeda(dFecha, 2))
	aAdd(::aTxMonedas, RecMoeda(dFecha, 3))
	aAdd(::aTxMonedas, RecMoeda(dFecha, 4))
	aAdd(::aTxMonedas, RecMoeda(dFecha, 5))	

	::aTxRecibo 	:= {}
	
	aAdd(::aTxRecibo, {::aTxMonedas[1], 0, 0})
	aAdd(::aTxRecibo, {::aTxMonedas[2], 0, 0})
	aAdd(::aTxRecibo, {::aTxMonedas[3], 0, 0})
	aAdd(::aTxRecibo, {::aTxMonedas[4], 0, 0})
	aAdd(::aTxRecibo, {::aTxMonedas[5], 0, 0})			
	
	::aCobros		:= {}
	::aDocumentos	:= {}	
	::aErrores		:= {}
	
	::lGrabo		:= .F.
	::cError		:= ""
	
	::aDatFJT		:= {}
	::aDatSEL		:= {}
	::aDatSE1		:= {}
	
	dbSelectArea("FJT")
	dbSetOrder(1)
	If dbSeek(::cFil+::cSerie+::cNumero)
		aAdd(::aErrores, {"El recibo serie: '"+AllTrim(::cSerie)+"' y numero '"+AllTrim(::cNumero)+"' ya existe."})
	EndIf
	
	RestArea(aArea)
	
Return SELF

/*=====================================================================
|---------------------------------------------------------------------|
| Programa | ARRecibo | Autor: Andres Demarziani | Fecha: 18/12/2019  |
|---------------------------------------------------------------------|
======================================================================*/
METHOD setSerie(cSerie) CLASS ARRecibo
	
	Local nTamSer := TamSX3("FJT_SERIE")[1]

	If cSerie != Nil
		::cSerie := PadR(Right(cSerie, nTamSer), nTamSer)
	Else
		::cSerie := "R  "
	EndIf

Return Nil

/*=====================================================================
|---------------------------------------------------------------------|
| Programa | ARRecibo | Autor: Andres Demarziani | Fecha: 18/12/2019  |
|---------------------------------------------------------------------|
======================================================================*/
METHOD setNumero(cNumero) CLASS ARRecibo

	Local nTamDoc := TamSX3("FJT_RECIBO")[1]

	If cNumero != Nil
		::cNumero := PadR(Right(cNumero, nTamDoc), nTamDoc)
	Else
		::cNumero := DToS(dDataBase)+Right(StrTran(Time(),":",""),4)
	EndIf
	
Return Nil

/*=====================================================================
|---------------------------------------------------------------------|
| Programa | ARRecibo | Autor: Andres Demarziani | Fecha: 18/12/2019  |
|---------------------------------------------------------------------|
======================================================================*/
METHOD setCobro(cTipo, cPref, cNum, nMoneda, dFecha, dVcto, oBanco, cBcoChq, cAgeChq, cCtaChq, cCuit, nValor, nAliq, cCFO, cProv) CLASS ARRecibo
	
	Local oCobro
	Local nTxMoneda	:= ::aTxRecibo[nMoneda][1]
	
	If nTxMoneda > 0
		oCobro := ARReciboCobro():New(cTipo, cPref, cNum, nMoneda, dFecha, dVcto, oBanco, cBcoChq, cAgeChq, cCtaChq, cCuit, nValor, nTxMoneda, nAliq, cCFO, cProv)
		
		If cTipo $ "RS|RL|RB|RI|RG"
			oCobro:setRetenc(::cSerie, ::cNumero, ::oCliente:cCod, ::oCliente:cLoja)
		EndIf
		
		aAdd(::aCobros, oCobro)

		::aTxRecibo[nMoneda][2] += nValor
		::aTxRecibo[nMoneda][3] += nValor	
	Else
		aAdd(::aErrores, {"No existe tipo de cambio informado en moneda '"+cValToChar(nMoneda)+"' para la fecha del recibo."})
	EndIf
	
Return Nil

/*=====================================================================
|---------------------------------------------------------------------|
| Programa | ARRecibo | Autor: Andres Demarziani | Fecha: 18/12/2019  |
|---------------------------------------------------------------------|
======================================================================*/
METHOD setDocumento(cTipo, cCuota, cSerie, cDoc, oDoc) CLASS ARRecibo

	Local oDocumento
	
	If ValType(oDoc)=="O"
		aAdd(::aDocumentos, oDoc)
	Else
		oDocumento := ARReciboTitulo():New(::oCliente, cTipo, cCuota, cSerie, cDoc)

		If Empty(oDocumento:nRecno)
			aAdd(::aErrores, {"No se encontró el título informado (Serie: "+AllTrim(cSerie)+" / Numero: "+cDoc+")"})
		Else
			aAdd(::aDocumentos, oDocumento)
		EndIf
	EndIf

Return Nil

/*=====================================================================
|---------------------------------------------------------------------|
| Programa | ARRecibo | Autor: Andres Demarziani | Fecha: 18/12/2019  |
|---------------------------------------------------------------------|
======================================================================*/
METHOD setPropAsto(lMuestra, lAgrupa) CLASS ARRecibo

	::lMuestra 	:= lMuestra
	::lAgrupa	:= lAgrupa
	
Return Nil
/*=====================================================================
|---------------------------------------------------------------------|
| Programa | ARRecibo | Autor: Andres Demarziani | Fecha: 18/12/2019  |
|---------------------------------------------------------------------|
======================================================================*/
METHOD guardar() CLASS ARRecibo

	Local nX
	Local aAuxSEL
	Local aAuxSE1
	LOcal cFNameBkp		:= FunName()

	Private lMsErroAuto := .F.
			
	::armaCobros()

	If Empty(::aDatFJT)
		aAdd(::aDatFJT, {"FJT_FILIAL"	, ::cFil, Nil})
		aAdd(::aDatFJT, {"FJT_DTDIGI"	, ::dFecha, Nil})
		aAdd(::aDatFJT, {"FJT_SERIE"	, ::cSerie, Nil})	
		aAdd(::aDatFJT, {"FJT_RECIBO"	, ::cNumero, Nil})
		aAdd(::aDatFJT, {"FJT_VERSAO"	, ::cVersion, Nil})
		aAdd(::aDatFJT, {"FJT_EMISSA"	, ::dFecha, Nil})
		aAdd(::aDatFJT, {"FJT_NATURE"	, ::cNaturez, Nil})
		aAdd(::aDatFJT, {"FJT_CLIENT"	, ::oCliente:cCod, Nil})
		aAdd(::aDatFJT, {"FJT_LOJA"		, ::oCliente:cLoja, Nil})
		aAdd(::aDatFJT, {"FJT_COBRAD"	, ::cCobrad, Nil})
		aAdd(::aDatFJT, {"FJT_RECPRV"	, ::cNumProv, Nil})
		aAdd(::aDatFJT, {"FJT_VERATU"	, "1", Nil})
		
		If ::cLiqTjta <> Nil
			aAdd(::aDatFJT, {"FJT_XLIQTJ"	, ::cLiqTjta, Nil})
		EndIf

		If ::cNroAplc <> Nil
			aAdd(::aDatFJT, {"FJT_XAPLIC"	, ::cNroAplc, Nil})
		EndIf
	EndIf

	If Empty(::aDatSEL)
		For nX := 1 To Len(::aCobros)
			aAuxSEL := {}

			aAdd(aAuxSEL, {"EL_FILIAL"	, ::cFil, Nil})
			aAdd(aAuxSEL, {"EL_CLIENTE"	, ::oCliente:cCod, Nil})
			aAdd(aAuxSEL, {"EL_LOJA"	, ::oCliente:cLoja, Nil})
			aAdd(aAuxSEL, {"EL_SERIE"	, ::cSerie, Nil})
			aAdd(aAuxSEL, {"EL_RECIBO"	, ::cNumero, Nil})
			aAdd(aAuxSEL, {"EL_VERSAO"	, ::cVersion, Nil})
			aAdd(aAuxSEL, {"EL_RECPROV"	, ::cNumProv, Nil})
			aAdd(aAuxSEL, {"EL_NATUREZ"	, ::cNaturez, Nil})
			aAdd(aAuxSEL, {"EL_COBRAD"	, ::cCobrad, Nil})			
			aAdd(aAuxSEL, {"EL_RECPROV"	, ::cNumProv, Nil})
			aAdd(aAuxSEL, {"EL_CLIORIG"	, ::oCliente:cCod, Nil})
			aAdd(aAuxSEL, {"EL_LOJORIG"	, ::oCliente:cLoja, Nil})
			aAdd(aAuxSEL, {"EL_TIPO"	, ::aCobros[nX]:cTipo, Nil})
			aAdd(aAuxSEL, {"EL_TIPODOC"	, ::aCobros[nX]:cTipo, Nil})
			aAdd(aAuxSEL, {"EL_PREFIXO"	, ::aCobros[nX]:cPref, Nil})
			aAdd(aAuxSEL, {"EL_NUMERO"	, ::aCobros[nX]:cNum, Nil})
			aAdd(aAuxSEL, {"EL_VALOR"	, ::aCobros[nX]:nValor, Nil})
			aAdd(aAuxSEL, {"EL_VLMOED1"	, Round(::aCobros[nX]:nValor * ::aTxMonedas[::aCobros[nX]:nMoneda], MsDecimais(1)), Nil})
			aAdd(aAuxSEL, {"EL_MOEDA"	, ::aCobros[nX]:cMoneda, Nil})
			aAdd(aAuxSEL, {"EL_DTDIGIT"	, dDataBase, Nil})
			aAdd(aAuxSEL, {"EL_EMISSAO"	, ::aCobros[nX]:dFecha, Nil})
			aAdd(aAuxSEL, {"EL_DTVCTO"	, ::aCobros[nX]:dVcto, Nil})
			aAdd(aAuxSEL, {"EL_BANCO"	, ::aCobros[nX]:oBanco:cCod, Nil})
			aAdd(aAuxSEL, {"EL_AGENCIA"	, ::aCobros[nX]:oBanco:cAgencia, Nil})
			aAdd(aAuxSEL, {"EL_CONTA"	, ::aCobros[nX]:oBanco:cCuenta, Nil})
			aAdd(aAuxSEL, {"EL_BCOCHQ"	, ::aCobros[nX]:cBcoChq, Nil})
			aAdd(aAuxSEL, {"EL_AGECHQ"	, ::aCobros[nX]:cAgeChq, Nil})
			aAdd(aAuxSEL, {"EL_CTACHQ"	, ::aCobros[nX]:cCtaChq, Nil})		
			aAdd(aAuxSEL, {"EL_TRANSIT"	, "2", Nil})
			aAdd(aAuxSEL, {"EL_TERCEIR"	, "1", Nil})
			aAdd(aAuxSEL, {"EL_ENDOSSA"	, "2", Nil})
			aAdd(aAuxSEL, {"EL_TXMOE02"	, ::aTxRecibo[2][1], Nil})
			aAdd(aAuxSEL, {"EL_TXMOE03"	, ::aTxRecibo[3][1], Nil})
			aAdd(aAuxSEL, {"EL_TXMOE04"	, ::aTxRecibo[4][1], Nil})
			aAdd(aAuxSEL, {"EL_TXMOE05"	, ::aTxRecibo[5][1], Nil})

			If !Empty(::aCobros[nX]:aRet)
				aAdd(aAuxSEL, {"RET", ::aCobros[nX]:aRet, Nil})
			EndIf		
			
			aAdd(::aDatSEL, aClone(aAuxSEL))
		Next nX
	EndIf

	If Empty(::aDatSE1)
		For nX := 1 To Len(::aDocumentos)
			aAuxSE1 := {}
			
			aAdd(aAuxSE1, {"E1_PREFIXO"	, ::aDocumentos[nX]:cSerie, Nil})
			aAdd(aAuxSE1, {"E1_PARCELA"	, ::aDocumentos[nX]:cCuota, Nil})
			aAdd(aAuxSE1, {"E1_TIPO"	, ::aDocumentos[nX]:cTipo, Nil})
			aAdd(aAuxSE1, {"E1_NUM"		, ::aDocumentos[nX]:cDoc, Nil})
			aAdd(aAuxSE1, {"E1_MOEDA"	, cValToChar(::aDocumentos[nX]:nMoneda), Nil})
			aAdd(aAuxSE1, {"nBaixar"	, ::aDocumentos[nX]:nVlrCanc, Nil})
			aAdd(aAuxSE1, {"nBxMoeda1"	, ::aDocumentos[nX]:aVlrCanc[1], Nil})
			aAdd(aAuxSE1, {"nBxMoeda2"	, ::aDocumentos[nX]:aVlrCanc[2], Nil})
			aAdd(aAuxSE1, {"nBxMoeda3"	, ::aDocumentos[nX]:aVlrCanc[3], Nil})
			aAdd(aAuxSE1, {"nBxMoeda4"	, ::aDocumentos[nX]:aVlrCanc[4], Nil})
			aAdd(aAuxSE1, {"nBxMoeda5"	, ::aDocumentos[nX]:aVlrCanc[5], Nil})	
			aAdd(aAuxSE1, {"E1_DESCONT"	, 0, Nil})
			aAdd(aAuxSE1, {"E1_JUROS"	, 0, Nil})
			aAdd(aAuxSE1, {"E1_MULTA"	, 0, Nil})
			aAdd(aAuxSE1, {"cMotBxSE1"	, "NOR", Nil})
			aAdd(aAuxSE1, {"nImpRetSE1"	, 0, Nil})
			aAdd(aAuxSE1, {"E1_SALDO"	, ::aDocumentos[nX]:nVlrCanc, Nil})	
			aAdd(aAuxSE1, {"R_E_C_N_O_"	, ::aDocumentos[nX]:nRecno, Nil})
			
			aAdd(::aDatSE1, aClone(aAuxSE1))
		Next nX
	EndIf

	SetFunName("FINA846")

	If Empty(::aErrores)		
		//MSExecAuto({|w,x,y,z| FINA846(w,x,y,z)}, ::aDatFJT, ::aDatSE1, ::aDatSEL, 3)
		//
		//If lMsErroAuto
		//	::cError := MOSTRAERRO("RECIBO")
		//Else
		//	::lGrabo := .T.
		//EndIf
		
		::lGrabo := ::graboDatos()
		
		If !::lGrabo
			::cError := "No se guardo el recibo '"+::cNumero+"', serie '"+::cSerie+"'"
		ElseIf ::lUpdNumSX5
			::actNumSX5()
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
| Programa | ARRecibo | Autor: Andres Demarziani | Fecha: 18/12/2019  |
|---------------------------------------------------------------------|
======================================================================*/
METHOD borrar() CLASS ARRecibo

	Local cFNameBkp		:= FunName()
	
	Private lMsErroAuto := .F.
	
	aAdd(::aDatFJT, {"FJT_FILIAL"	, ::cFil, Nil})	
	aAdd(::aDatFJT, {"FJT_RECIBO"	, ::cNumero, Nil})
	aAdd(::aDatFJT, {"FJT_SERIE"	, ::cSerie, Nil})
	aAdd(::aDatFJT, {"FJT_CLIENT"	, ::oCliente:cCod, Nil})
	aAdd(::aDatFJT, {"FJT_LOJA"		, ::oCliente:cLoja, Nil})
	aAdd(::aDatFJT, {"FJT_NATURE"	, ::cNaturez, Nil})
	aAdd(::aDatFJT, {"FJT_DTDIGI"	, ::dFecha, Nil})
	aAdd(::aDatFJT, {"FJT_EMISSAO"	, ::dFecha, Nil})
	aAdd(::aDatFJT, {"FJT_COBRAD"	, ::cCobrad, Nil})
	aAdd(::aDatFJT, {"FJT_RECPRV"	, ::cNumProv, Nil})

	SetFunName("FINA846")
	
	MSExecAuto({|w,x,y,z| FINA846(w,x,y,z)}, ::aDatFJT, {}, {}, 5)
	
	If lMsErroAuto
		aAdd(::aErrores, {MOSTRAERRO("RECIBO")})
		::cError := ::aErrores[Len(::aErrores)]
	Else
		::lGrabo := .T.
	EndIf

	SetFunName(cFNameBkp)

Return Nil

/*=====================================================================
|---------------------------------------------------------------------|
| Programa | ARRecibo | Autor: Andres Demarziani | Fecha: 18/12/2019  |
|---------------------------------------------------------------------|
======================================================================*/
METHOD armaCobros() CLASS ARRecibo

	Local nX
	Local nM

	For nX := 1 To Len(::aDocumentos)
		For nM := 1 To Len(::aTxRecibo)	
			If ::aTxRecibo[nM][3] > 0 .And. ::aDocumentos[nX]:nSaldo > 0
				::aTxRecibo[nM][3] := ::aDocumentos[nX]:cancela(nM, ::aTxRecibo[nM][1], ::aTxRecibo[1][3])
			EndIf
		Next nM
	Next nX

Return Nil

/*=====================================================================
|---------------------------------------------------------------------|
| Programa | ARRecibo | Autor: Andres Demarziani | Fecha: 18/12/2019  |
|---------------------------------------------------------------------|
======================================================================*/
METHOD graboDatos() CLASS ARRecibo

	Local nX
	Local nPos
	Local aAuxSEL	
	Local aArea		:= GetArea()
	Local cDiario	:= Criavar("EL_DIACTB",.T.)
	Local cMot		:= "NOR"	
	Local cIDProc	:= GetSx8Num('FKA','FKA_IDPROC')
	Local cCredInm	:= "TF /EF /"	
	Local lGrabo	
	
	Local lAsto			:= .T.	
	Local cCodAsto		:= "575"
	Local nHdlPrv		:= 0
	Local cArquivo		:= ""
	Local cLote			:= Tabela("09", "FIN")	
	Local cFuncion		:= "DSAFIN01"

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
	dbSelectArea("FJT")
	RecLock("FJT",.T.)
	aEval(::aDatFJT, {|x| If(FieldPos(x[1])>0, FieldPut(FieldPos(x[1]),x[2]), )})		
	MsUnlock()

	//------------------
	// Medios de cobros
	//------------------
	For nX := 1 To Len(::aDatSEL)
		aAuxSEL := ::aDatSEL[nX]		

		dbSelectArea("SEL")		
		RecLock("SEL",.T.)			
		aEval(aAuxSEL, {|x| If(FieldPos(x[1])>0, FieldPut(FieldPos(x[1]),x[2]), )})		
		MsUnlock()
		
		If lAsto
			nTotal += DetProva(nHdlPrv, cCodAsto, cFuncion, cLote)
			
			RecLock("SEL", .F.)
			SEL->EL_LA := "S"
			MsUnlock()
		EndIf
		
		If (nPos := aScan(aAuxSEL, {|x| x[1] == "RET"})) > 0
			dbSelectArea("SFE")
			RecLock("SFE",.T.)			
			aEval(aAuxSEL[nPos][2], {|x| If(FieldPos(x[1])>0, FieldPut(FieldPos(x[1]),x[2]), )})		
			MsUnlock()		
		EndIf
		
		If AllTrim(SEL->EL_TIPO) $ cCredInm .And. SEL->EL_TRANSIT == "2"
			Fa840GSE5(2, "", ::cNaturez, ::cNumero, ::cSerie, ::aTxMonedas, cDiario, cMot, cIDProc)
		EndIf
	Next nX

	//---------------------------
	// Cancelacion de documentos
	//---------------------------
	For nX := 1 To Len(::aDocumentos)		
		SE1->(dbGoTo(::aDocumentos[nX]:nRecno))
		If !SE1->(Eof())					
			RecLock("SE1",.F.)
			SE1->E1_BAIXA 	:= ::dFecha
			SE1->E1_MOTIVO	:= cMot
			SE1->E1_MOVIMEN	:= ::dFecha
			SE1->E1_SALDO	:= ::aDocumentos[nX]:nSaldo
			SE1->E1_SERREC  := ::cSerie
			SE1->E1_RECIBO	:= ::cNumero
			SE1->E1_DTACRED	:= ::dFecha
			SE1->E1_STATUS	:= IF(::aDocumentos[nX]:nSaldo<=0,"B","A")
			SE1->E1_VALLIQ	:= ::aDocumentos[nX]:nVlrCanc
			MsUnlock()			
		
			RecLock("SEL",.T.)
			SEL->EL_FILIAL	:= ::cFil
			SEL->EL_TIPODOC	:= "TB"
			SEL->EL_PREFIXO	:= SE1->E1_PREFIXO
			SEL->EL_NUMERO	:= SE1->E1_NUM
			SEL->EL_PARCELA	:= SE1->E1_PARCELA
			SEL->EL_TIPO	:= SE1->E1_TIPO  
			SEL->EL_BCOCHQ	:= SE1->E1_BCOCHQ
			SEL->EL_AGECHQ	:= SE1->E1_AGECHQ
			SEL->EL_CTACHQ	:= SE1->E1_CTACHQ
			SEL->EL_EMISSAO	:= SE1->E1_EMISSAO
			SEL->EL_DTDIGIT	:= dDataBase
			SEL->EL_DTVCTO	:= SE1->E1_VENCREA
			SEL->EL_NATUREZ	:= SE1->E1_NATUREZ
			SEL->EL_MOEDA	:= STRZERO(SE1->E1_MOEDA,2)
			SEL->EL_VLMOED1	:= Round((SE1->E1_VALLIQ)*::aTxMonedas[Max(1,SE1->E1_MOEDA)],MsDecimais(1))
			SEL->EL_DESCONT	:= SE1->E1_DESCONT
			SEL->EL_MULTA	:= SE1->E1_MULTA
			SEL->EL_JUROS	:= SE1->E1_JUROS
			SEL->EL_VALOR	:= SE1->E1_VALLIQ
			SEL->EL_CLIENTE	:= SE1->E1_CLIENTE
			SEL->EL_LOJA	:= SE1->E1_LOJA
			SEL->EL_SERIE	:= ::cSerie
			SEL->EL_RECIBO 	:= ::cNumero
			SEL->EL_VERSAO	:= ::cVersion
			SEL->EL_RECPROV	:= ::cNumProv
			SEL->EL_CLIORIG	:= ::oCliente:cCod
			SEL->EL_LOJORIG	:= ::oCliente:cLoja
			F840GrvTx(::aTxMonedas)
			MsUnlock()			
			
			dbSelectArea("SEL")
			If lAsto
				nTotal += DetProva(nHdlPrv, cCodAsto, cFuncion, cLote)
				
				RecLock("SEL", .F.)
				SEL->EL_LA := "S"
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
	
	FJT->(dbSetOrder(1))
	lGrabo := FJT->(dbSeek(::cFil+::cSerie+::cNumero))

Return lGrabo

/*=====================================================================
|---------------------------------------------------------------------|
| Programa | ARRecibo | Autor: Andres Demarziani | Fecha: 18/12/2019  |
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
| Programa | ARRecibo | Autor: Andres Demarziani | Fecha: 18/12/2019  |
|---------------------------------------------------------------------|
======================================================================*/
Static Function fFinalizaAsiento(nHdlPrv, cArquivo, cLote, lMuestra, lAgrupa, nTotal)

	Local lRet := .F.

	RodaProva(nHdlPrv, nTotal)
	
	lRet := cA100Incl(cArquivo, nHdlPrv, 3, cLote, lMuestra, lAgrupa)

Return lRet

/*=====================================================================
|---------------------------------------------------------------------|
| Programa | ARRecibo | Autor: Andres Demarziani | Fecha: 18/12/2019  |
|---------------------------------------------------------------------|
======================================================================*/
METHOD actNumSX5() CLASS ARRecibo

	Local aArea		:= GetArea()
	Local aAreaSX5	:= SX5->(GetArea())
	Local cNextNum

	dbSelectArea("SX5")
	SX5->(dbSetOrder(1))
	If dbSeek(xFilial("SX5")+"RN"+::cSerie)
		cNextNum := Soma1(::cNumero)

		RecLock("SX5", .F.)
		Replace X5_DESCRI  With cNextNum
		Replace X5_DESCENG With cNextNum
		Replace X5_DESCSPA With cNextNum
		MsUnlock()
	EndIf

	RestArea(aAreaSX5)
	RestARea(aArea)

Return Nil

