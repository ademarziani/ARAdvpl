#include "Protheus.ch"

#define X3DESCRI	01
#define X3CAMPO		02
#define X3PICTURE	03
#define X3TAMANHO	04
#define X3DECIMAL	05
#define X3VALID		06
#define X3USADO		07
#define X3TIPO		08
#define X3F3		09
#define X3CONTEXT	10
#define X3CBOX		11
#define X3RELACAO	12
#define X3WHEN		13
#define X3VISUAL	14
#define X3VLDUSER	15
#define X3PICTVAR	16
#define X3OBRIGA	17

Static oBMPOK 	:= LoadBitmap( GetResources(), "WFCHK" )
Static oBMPNO 	:= LoadBitmap( GetResources(), "WFUNCHK" )

/*=========================================================================
=|=======================================================================|=
=|Programa: ArGetDados     | Autor: Microsiga       | Fecha: 03/05/2019  |=
=|=======================================================================|=
=|Desc: Arma un listbox segun los array que envie el demandante.         |=
=|=======================================================================|=
=========================================================================*/
CLASS ArGetDados
	
	DATA cTitulo
	DATA nAlto
	DATA nAncho
	
	DATA oDlg
	
	DATA cTabla
	DATA cPref
	DATA cSucursal
	DATA nIndice
	DATA aCposClave
	DATA bDblClick
	
	DATA oGetDados
	DATA aHeader	
	DATA aCols
	DATA aRecnos

	DATA nSuperior
	DATA nEsquerda
	DATA nInferior
	DATA nDireita
	DATA nOpc
	DATA cLinhaOk
	DATA cTudoOk
	DATA cIniCpos
	DATA aAlter
	DATA nFreeze
	DATA nMax
	DATA cCampoOk
	DATA cSuperApagar
	DATA cApagaOk
	DATA lDelVacio
	
	DATA lOk
	DATA lMark
	DATA lData
	
	METHOD New() CONSTRUCTOR 
	METHOD setTam()
	METHOD setCampos()
	METHOD setTabla()
	METHOD setQuery()
	METHOD setHeader()
	METHOD setAlter()
	METHOD setCols()
	METHOD setColsVacio()
	METHOD propHeader()
	METHOD verDatos()
	METHOD getGetDados()
	METHOD getDatosTabla()
	METHOD grabaDatosTabla()
	METHOD getValCpo()
	METHOD getSumCpo()
	METHOD setValCpo()
	METHOD getOk()	
	METHOD refresh()
	METHOD checkDel()
	METHOD btnOk()

ENDCLASS

/*=========================================================================
=|=======================================================================|=
=|Programa: New          | Autor: Microsiga         | Fecha: 03/05/2019  |=
=|=======================================================================|=
=========================================================================*/
METHOD New(cTitulo, nPorcAncho, nPorcAlto, lOk) CLASS ArGetDados

	Local aSize 	:= MsAdvSize()
	
	nPorcAncho	:= IIf(nPorcAncho==Nil,1,nPorcAncho/100)
	nPorcAlto	:= IIf(nPorcAlto==Nil,1,nPorcAlto/100)
	::cTitulo	:= cTitulo
	::aHeader	:= {}
	::aCols		:= {}
	::aRecnos	:= {}

	::nSuperior	:= 000
	::nEsquerda	:= 000
	::nInferior	:= 000
	::nDireita	:= 000

	::nOpc		:= GD_INSERT+GD_DELETE+GD_UPDATE
	::cLinhaOk	:= "AllwaysTrue"
	::cTudoOk	:= "AllwaysTrue"
	::cIniCpos	:= ""
	
	::aAlter		:= {}
	::nFreeze	:= 0		// Campos estaticos na GetDados.
	::nMax		:= 1				// Numero maximo de linhas permitidas. Valor padrao 99
	::cCampoOk	:= "AllwaysTrue"	// Funcao executada na validacao do campo
	::cSuperApagar:= ""				// Funcao executada quando pressionada as teclas <Ctrl>+<Delete>
	::cApagaOk	:= "AllwaysTrue"	// Funcao executada para validar a exclusao de uma linha do aCols
	
	::lOk		:= IIf(lOk==Nil,.F.,lOk)
	::lMark		:= .F.
	::lData		:= .F.
	::lDelVacio	:= .F.
	
	If Type("oMainWnd")#"U"
		::setTam(aSize[5]*nPorcAncho, aSize[6]*nPorcAlto)
	Else
		::setTam(600,600)
	EndIf	

RETURN SELF

/*=========================================================================
=|=======================================================================|=
=|Programa: setTam       | Autor: Microsiga         | Fecha: 03/05/2019  |=
=|=======================================================================|=
=========================================================================*/
METHOD setTam(nAncho, nAlto) CLASS ArGetDados

	::nAncho	:= nAncho
	::nAlto	:= nAlto

RETURN Nil

/*=========================================================================
=|=======================================================================|=
=|Programa: setCampos    | Autor: Microsiga         | Fecha: 03/05/2019  |=
=|=======================================================================|=
=========================================================================*/
METHOD setCampos(aCpoGDa, cItem, aCposClave, cLinOK, lVisual) CLASS ArGetDados
	
	Local aHeader	:= {}
	Local aCols		:= {}
	Local aLin		:= {}
	Local nX		:= 1

	::nMax			:= 999
		
	dbSelectArea("SX3")
	dbSetOrder(2) // Campo
	For nX := 1 to Len(aCpoGDa)
		If AllTrim(aCpoGDa[nX]) == "BMPOK"
			::lMark := .T.

			aAdd(aHeader,{"",;							// X3_DESCRI		01
						aCpoGDa[nX],;					// X3_CAMPO			02
						"@BMP",;						// X3_PICTURE		03
						2,;								// X3_TAMANHO		04
						0,;								// X3_DECIMAL		05
						.T.,;							// X3_VALID			06
						"",;							// X3_USADO			07
						"C",;							// X3_TIPO			08
						"",;							// X3_F3			09
						"R",;							// X3_CONTEXT		10
						"",;							// X3_CBOX			11
						"",;							// X3_RELACAO		12
						.F.,;							// X3_WHEN			13
						"",;							// X3_VISUAL		14
						"",;							// X3_VLDUSER		15
						"",;							// X3_PICTVAR		16
						""})							// X3_OBRIGA		17

		ElseIf SX3->(DbSeek(aCpoGDa[nX]))
			aAdd(aHeader,{	AllTrim(X3Titulo()),;
							SX3->X3_CAMPO	,;
							SX3->X3_PICTURE,;
							SX3->X3_TAMANHO,;
							SX3->X3_DECIMAL,;
							SX3->X3_VLDUSER,;
							SX3->X3_USADO,;
							SX3->X3_TIPO,;
							SX3->X3_F3,;
							SX3->X3_CONTEXT,;
							X3CBox(),;
							SX3->X3_RELACAO})

			If AllTrim(SX3->X3_CAMPO) == cItem
				aAdd(aLin, StrZero(1,SX3->X3_TAMANHO))
			Else
				aAdd(aLin, CriaVar(SX3->X3_CAMPO))
			EndIf
		
			If SX3->X3_VISUAL <> "V" .And. !lVisual
				aAdd(::aAlter, SX3->X3_CAMPO)
			EndIf					
		Endif
	Next nX

	aAdd(aLin,.F.)
	aAdd(aCols,aLin)
	
	::setHeader(aHeader)
	::setCols(aCols)
	
Return Nil

/*=========================================================================
=|=======================================================================|=
=|Programa: setQuery     | Autor: Microsiga         | Fecha: 03/05/2019  |=
=|=======================================================================|=
=========================================================================*/
METHOD setTabla(cTabla, nIndice, cItem, aCposClave, cLinOK, lVisual) CLASS ArGetDados
	
	Local aCpoGDa	:= {}
	Local aHeader	:= {}
	Local aCols		:= {}
	Local aLin		:= {}
	Local nX		:= 1
	
	::cTabla 		:= cTabla
	::cPref			:= IIf(Left(cTabla,1)=="S", Right(cTabla,2), cTabla)
	::cSucursal		:= IIf(Left(cTabla,2)=="SX", "", xFilial(cTabla))
	::nIndice		:= IIf(nIndice==Nil, 1, nIndice)
	::cIniCpos		:= IIf(cItem==Nil, "", "+"+cItem)
	::cLinhaOk 		:= IIf(cLinOK==Nil, ::cLinhaOk, cLinOK)
	::aCposClave	:= IIf(aCposClave==Nil, {}, aCposClave)
	::nMax			:= 999
		
	dbSelectArea("SX3")
	dbSetOrder(1)
	dbSeek(cTabla)

	While !Eof() .and. X3_ARQUIVO == cTabla
		If X3Uso(X3_USADO)
			aAdd(aCpoGDa, X3_CAMPO)
		Endif
		dbSkip()
	EndDo

	// Carrega aHeader e a Montagem da sua aCol
	SX3->(dbSetOrder(2)) // Campo
	For nX := 1 to Len(aCpoGDa)
		If SX3->(DbSeek(aCpoGDa[nX]))
			aAdd(aHeader,{	AllTrim(X3Titulo()),;
							SX3->X3_CAMPO	,;
							SX3->X3_PICTURE,;
							SX3->X3_TAMANHO,;
							SX3->X3_DECIMAL,;
							SX3->X3_VLDUSER,;
							SX3->X3_USADO,;
							SX3->X3_TIPO,;
							SX3->X3_F3,;
							SX3->X3_CONTEXT,;
							X3CBox(),;
							SX3->X3_RELACAO})

			If AllTrim(SX3->X3_CAMPO) == cItem
				aAdd(aLin, StrZero(1,SX3->X3_TAMANHO))
			Else
				aAdd(aLin, CriaVar(SX3->X3_CAMPO))
			EndIf
		
			If SX3->X3_VISUAL <> "V" .And. !lVisual
				aAdd(::aAlter, SX3->X3_CAMPO)
			EndIf
		Endif
	Next nX

	aAdd(aLin,.F.)
	aAdd(aCols,aLin)
	
	::setHeader(aHeader)
	::setCols(aCols)
	
Return Nil

/*=========================================================================
=|=======================================================================|=
=|Programa: getDatosTabla| Autor: Microsiga         | Fecha: 03/05/2019  |=
=|=======================================================================|=
=========================================================================*/
METHOD getDatosTabla() CLASS ArGetDados

	Local aCols
	Local aLin
	Local nX
	Local aArea
	Local aAreaTab
	Local cLlave		:= ""
	Local cCodLlave	:= ""
	
	::aRecnos := {}
	
	For nX := 1 To Len(::aCposClave)
		cLlave		+= IIf(cLlave=="", ::aCposClave[nX][1], "+"+::aCposClave[nX][1])
		cCodLlave	+= IIf(cCodLlave=="", &(::aCposClave[nX][2]), &("+"+::aCposClave[nX][2]))
	Next nX	

	If !Empty(cLlave)
		aCols		:= {}
		aLin		:= {}
		nX			:= 1
		aArea		:= GetArea()
		aAreaTab	:= (Self:cTabla)->(GetArea())

		dbSelectArea(::cTabla)
		dbSetOrder(::nIndice)
		dbSeek(::cSucursal+cCodLlave)

		While !Eof() .And. ::cSucursal+cCodLlave == ::cSucursal+&(cLlave)
			aAdd(::aRecnos, Recno())
				
			For nX := 1 To Len(::aHeader)
				If ::aHeader[nX][10] <> "V"
					aAdd(aLin, &(::cTabla+"->"+::aHeader[nX][2]))
				Else
					aAdd(aLin, fCreaVar(::aHeader[nX][8]))
				EndIf
			Next
			
			Aadd(aLin,.F.)
			Aadd(aCols,aLin)
			aLin := {}
			
			dbSkip()
		EndDo

		If !Empty(aCols)
			::lData := .T.
			::setCols(aCols)
		Else
			::setColsVacio()
		EndIf
		
		RestArea(aAreaTab)
		RestArea(aArea)
	EndIf

Return Nil

/*=========================================================================
=|=======================================================================|=
=|Programa: setQuery     | Autor: Microsiga         | Fecha: 03/05/2019  |=
=|=======================================================================|=
=========================================================================*/
METHOD setQuery(cQuery) CLASS ArGetDados

	Local cTRB 		:= GetNextAlias()
	Local aStru		:= "" 
	Local nZ		:= 1
	
	Local cCampo	:= ""
	Local aHeader	:= {}
	Local aCols		:= {}
	Local aColsLin	:= {}

	dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQuery),cTRB,.F.,.T.)
	dbSelectArea(cTRB)
	dbGoTop()
	aStru := dbStruct()
	
	dbSelectArea("SX3")
	dbSetOrder(2)
	
	For nZ := 1 To Len(aStru)
		cCampo := aStru[nZ][1]
		aAdd(::aAlter, cCampo)
		
		If AllTrim(cCampo) == "BMPOK"
			::lMark := .T.

			aAdd(aHeader,{"",;							// X3_DESCRI		01
						cCampo,;						// X3_CAMPO			02
						"@BMP",;						// X3_PICTURE		03
						2,;								// X3_TAMANHO		04
						0,;								// X3_DECIMAL		05
						.T.,;							// X3_VALID			06
						"",;							// X3_USADO			07
						"C",;							// X3_TIPO			08
						"",;							// X3_F3			09
						"R",;							// X3_CONTEXT		10
						"",;							// X3_CBOX			11
						"",;							// X3_RELACAO		12
						.F.,;							// X3_WHEN			13
						"",;							// X3_VISUAL		14
						"",;							// X3_VLDUSER		15
						"",;							// X3_PICTVAR		16
						""})							// X3_OBRIGA		17
		ElseIf SX3->(dbSeek(cCampo))
			If SX3->X3_TIPO != "C"				
				aStru[nZ,2] := SX3->X3_TIPO
				aStru[nZ,3] := SX3->X3_TAMANHO
				aStru[nZ,4] := SX3->X3_DECIMAL
						
				TCSetField(cTRB, aStru[nZ,1], aStru[nZ,2], aStru[nZ,3], aStru[nZ,4])				
			Endif

			aAdd(aHeader,{	AllTrim(X3Titulo()),;		// X3_DESCRI		01
							SX3->X3_CAMPO,;				// X3_CAMPO			02
							SX3->X3_PICTURE,;			// X3_PICTURE		03
							SX3->X3_TAMANHO,;			// X3_TAMANHO		04
							SX3->X3_DECIMAL,;			// X3_DECIMAL		05
							"",;						// X3_VALID			06
							"",;						// X3_USADO			07
							SX3->X3_TIPO,;				// X3_TIPO			08
							SX3->X3_F3,;				// X3_F3			09
							"",;						// X3_CONTEXT		10
							X3CBox(),;					// X3_CBOX			11
							SX3->X3_RELACAO,;			// X3_RELACAO		12
							SX3->X3_WHEN,;				// X3_WHEN			13
							SX3->X3_VISUAL,;			// X3_VISUAL		14
							SX3->X3_VLDUSER,;			// X3_VLDUSER		15
							"",;						// X3_PICTVAR		16
							""})						// X3_OBRIGA		17
		Else
			aAdd(aHeader,{	Capital(cCampo),;			// X3_DESCRI		01
							cCampo,;					// X3_CAMPO			02
							"",;						// X3_PICTURE		03
							aStru[nZ][3],;				// X3_TAMANHO		04
							aStru[nZ][4],;				// X3_DECIMAL		05
							"",;						// X3_VALID			06
							"",;						// X3_USADO			07
							aStru[nZ][2],;				// X3_TIPO			08
							"",;						// X3_F3			09
							"",;						// X3_CONTEXT		10
							"",;						// X3_CBOX			11
							"",;						// X3_RELACAO		12
							"",;						// X3_WHEN			13
							"",;						// X3_VISUAL		14
							"",;						// X3_VLDUSER		15
							"",;						// X3_PICTVAR		16
							""})						// X3_OBRIGA		17
		EndIf
	Next

	dbSelectArea(cTRB)
	dbGoTop()
	
	While !Eof()
		For nZ := 1 To Len(aHeader)
			If AllTrim(aHeader[nZ][2]) == "BMPOK"
				aAdd(aColsLin, oBMPNO)
			Else
				aAdd(aColsLin, &(aHeader[nZ][2]))
			EndIf
		Next	
		
		aAdd(aColsLin, .F.)
		aAdd(aCols, aClone(aColsLin))
		
		aColsLin := {}
		dbSkip()
	EndDo		

	::lData := !Empty(aCols)
	
	::setHeader(aHeader)
	::setCols(aCols)
	
RETURN Nil

/*=========================================================================
=|=======================================================================|=
=|Programa: setHeader    | Autor: Microsiga         | Fecha: 03/05/2019  |=
=|=======================================================================|=
=========================================================================*/
METHOD setHeader(aHeader) CLASS ArGetDados

	::aHeader := aHeader

RETURN Nil

/*=========================================================================
=|=======================================================================|=
=|Programa: setHeader    | Autor: Microsiga         | Fecha: 03/05/2019  |=
=|=======================================================================|=
=========================================================================*/
METHOD setAlter(lAlter) CLASS ArGetDados

	Local nZ
	Local aArea
	Local aAlter 	:= {}
	Local nMax	:= 1
	
	If lAlter
		aArea	:= GetArea()		
		nMax		:= 999
		
		dbSelectArea("SX3")
		dbSetOrder(2)
		
		For nZ := 1 To Len(::aHeader)
			If SX3->(dbSeek(::aHeader[nZ][2]))
				If SX3->X3_VISUAL <> "V"
					aAdd(aAlter, SX3->X3_CAMPO)
				EndIf
			Else
				aAdd(aAlter, ::aHeader[nZ][2])
			EndIf
		Next nZ

		RestArea(aArea)		
	EndIf
	
	::aAlter := aAlter
	::nMax	:= nMax
	
	If ::oGetDados <> Nil
		::oGetDados:aAlter := aAlter
		::oGetDados:nMax := nMax
	EndIf

RETURN Nil

/*=========================================================================
=|=======================================================================|=
=|Programa: setCols      | Autor: Microsiga         | Fecha: 03/05/2019  |=
=|=======================================================================|=
=========================================================================*/
METHOD setCols(aCols) CLASS ArGetDados

	If Empty(aCols)
		::setColsVacio()
	Else
		::aCols	:= aCols

		If ValType(::oGetDados) == "O"
			::oGetDados:aCols := aCols
		EndIf
	EndIf
		
RETURN Nil

/*=========================================================================
=|=======================================================================|=
=|Programa: setColsVacio | Autor: Microsiga         | Fecha: 03/05/2019  |=
=|=======================================================================|=
=========================================================================*/
METHOD setColsVacio() CLASS ArGetDados

	Local nZ
	Local aCols		:= {}
	Local aColsLin 	:= {}
	Local aArea		:= GetArea()
	
	dbSelectArea("SX3")
	dbSetOrder(2)
	
	For nZ := 1 To Len(::aHeader)
		If SX3->(dbSeek(::aHeader[nZ][2]))
			If AllTrim(SX3->X3_CAMPO) == StrTran(::cIniCpos,"+","")
				aAdd(aColsLin, StrZero(1,SX3->X3_TAMANHO))
			Else
				aAdd(aColsLin, CriaVar(SX3->X3_CAMPO))
			EndIf
		Else			
			aAdd(aColsLin, fCreaVar(::aHeader[nZ][8]))
		EndIf
	Next	
			
	aAdd(aColsLin, ::lDelVacio)
	aAdd(aCols, aClone(aColsLin))
			
	::setCols(aCols)

	RestArea(aArea)
	
RETURN Nil

/*=========================================================================
=|=======================================================================|=
=|Programa: verDatos     | Autor: Microsiga         | Fecha: 03/05/2019  |=
=|=======================================================================|=
=========================================================================*/
METHOD verDatos() CLASS ArGetDados

	Local oDlg
	Local bOk		:= {|| ::btnOk(oDlg)}
	Local bCancel	:= {|| oDlg:End()}

	If Len(::aCols) > 0				
		DEFINE MSDIALOG oDlg FROM 000,000 TO ::nAlto,::nAncho TITLE ::cTitulo PIXEL
	
		::getGetDados(oDlg)
		
		ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,bOK,bCancel,,) CENTERED
	EndIf

Return Nil
		
/*=========================================================================
=|=======================================================================|=
=|Programa: verDatos     | Autor: Microsiga         | Fecha: 03/05/2019  |=
=|=======================================================================|=
=========================================================================*/
METHOD btnOk(oDlg) CLASS ArGetDados

	::lOk := .T.

	::aCols := aClone(::oGetDados:aCols)
	
	oDlg:End()

Return Nil

/*=========================================================================
=|=======================================================================|=
=|Programa: propHeader   | Autor: Microsiga         | Fecha: 03/05/2019  |=
=|=======================================================================|=
=========================================================================*/
METHOD propHeader(cCampo, cCpoSX3, xProp) CLASS ArGetDados

	Local nCol		
	Local nFil 		:= aScan(::aHeader, {|x| AllTrim(x[2]) == cCampo})
	Local aCpoSX3	:= {}
	
	aAdd(aCpoSX3, "X3_DESCRI")
	aAdd(aCpoSX3, "X3_CAMPO")		
	aAdd(aCpoSX3, "X3_PICTURE")		
	aAdd(aCpoSX3, "X3_TAMANHO")	
	aAdd(aCpoSX3, "X3_DECIMAL")	
	aAdd(aCpoSX3, "X3_VALID")	
	aAdd(aCpoSX3, "X3_USADO")		
	aAdd(aCpoSX3, "X3_TIPO")		
	aAdd(aCpoSX3, "X3_F3")		
	aAdd(aCpoSX3, "X3_CONTEXT")
	aAdd(aCpoSX3, "X3_CBOX")	
	aAdd(aCpoSX3, "X3_RELACAO")
	aAdd(aCpoSX3, "X3_WHEN")	
	aAdd(aCpoSX3, "X3_VISUAL")
	aAdd(aCpoSX3, "X3_VLDUSER")
	aAdd(aCpoSX3, "X3_PICTVAR")
	aAdd(aCpoSX3, "X3_OBRIGA")
	
	nCol := aScan(aCpoSX3, {|x| x == cCpoSX3})
	
	If nFil > 0 .And. nCol > 0 .And. nCol <= Len(::aHeader[nFil])
		::aHeader[nFil][nCol] := xProp
	EndIf

RETURN Nil

/*=========================================================================
=|=======================================================================|=
=|Programa: getGetDados  | Autor: Microsiga         | Fecha: 03/05/2019  |=
=|=======================================================================|=
=========================================================================*/
METHOD getGetDados(oVentana) CLASS ArGetDados

::oGetDados := MsNewGetDados():New(	::nSuperior,;
								::nEsquerda,;
								::nInferior,;
								::nDireita,;
								::nOpc,;
								::cLinhaOk,;
								::cTudoOk,;
								::cIniCpos,;
								::aAlter,;
								::nFreeze,;
								::nMax,;
								::cCampoOk,;
								::cSuperApagar,;
								::cApagaOk,;
								oVentana,;
								::aHeader,;
								::aCols)

::oGetDados:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT

If ValType(::bDblClick) == "B"
	::oGetDados:oBrowse:bLDblClick := ::bDblClick
ElseIf ::lMark 
	::oGetDados:oBrowse:bLDblClick := {|| fMarkChk(::oGetDados)}
EndIf

Return ::oGetDados

/*=========================================================================
=|=======================================================================|=
=|Programa: getGetDados  | Autor: Microsiga         | Fecha: 03/05/2019  |=
=|=======================================================================|=
=========================================================================*/
METHOD grabaDatosTabla(lDeleta) CLASS ArGetDados

	Local aHeader	:= ::oGetDados:aHeader
	Local aReg	:= ::aRecnos
	Local cTabla	:= ::cTabla
	Local cPref	:= ::cPref

	Local nMaxCol	:= Len(::oGetDados:aCols)
	Local nMaxReg	:= Len(aReg)
	Local nMaxFor	:= MAX(nMaxCol,nMaxReg)
	Local nY		:= 1
	Local nX	    := 1
	Local nG		:= 1
	Local aArea	:= GetArea()

	If ::lOk
		dbSelectArea(cTabla)
				
		For nX := 1 To nMaxFor
			If nX == nMaxCol .And. ::oGetDados:lNewLine
				Loop		
			EndIf
			
			If nX > nMaxCol
				MsGoto(aReg[nX])
				
				If !Eof()
					RecLock(cTabla,.F.)	
					DbDelete()
					MsUnLock()
				EndIf
				
				Loop
			EndIf
			
			If nX <= nMaxReg
				MsGoto(aReg[nX])
				
				If !Eof()
					RecLock(cTabla,.F.)
					
					If ::oGetDados:aCols[nX][Len(::oGetDados:aCols[nX])] .Or. lDeleta
						DbDelete()
						MsUnLock()
						Loop
					EndIf
				EndIf
			Else
				If ::oGetDados:aCols[nX][Len(::oGetDados:aCols[nX])]
					Loop
				EndIf
				
				RecLock(cTabla,.T.)
			EndIf
			
			For nY := 1 To Len(aHeader)
				If aHeader[nY][10] <> "V"
					(cTabla)->(FieldPut(FieldPos(aHeader[nY][2]),::oGetDados:aCols[nX][nY]))
				EndIf
			Next nY
			
			&(cPref+"_FILIAL") := ::cSucursal
			For nG := 1 To Len(::aCposClave)
				&(::aCposClave[nG][1]) := &(::aCposClave[nG][2])
			Next nG
			
			MsUnLock()	
		Next
	EndIf

	RestArea(aArea)

Return Nil

/*=========================================================================
=|=======================================================================|=
=|Programa: fCreaVar     | Autor: Microsiga         | Fecha: 03/05/2019  |=
=|=======================================================================|=
=========================================================================*/
Static Function fCreaVar(cTipo)

	Local xVar

	If cTipo == "C"
		xVar	:= Space(1)
	ElseIf cTipo == "N"
		xVar	:= 0
	ElseIf cTipo == "L"
		xVar	:= .F.
	ElseIf cTipo == "D"
		xVar	:= Ctod("")
	Else
		xVar	:= ""
	EndIf
	
Return xVar

/*=========================================================================
=|=======================================================================|=
=|Programa: fCreaVar     | Autor: Microsiga         | Fecha: 03/05/2019  |=
=|=======================================================================|=
=========================================================================*/
Static Function fMarkChk(oGD)

	Local nLin 	:= oGD:nAt
	Local nCol	:= oGD:oBrowse:nColPos	
	Local nPOk	:= GdFieldPos("BMPOK", oGD:aHeader)
	Local lCan	:= aScan(oGD:aAlter, {|x| x == "BMPOK" }) > 0
	Local bFunc
	Local oChk	

	If nPOk > 0 .And. nCol == nPOk .And. lCan
		oChk := oGD:aCols[nLin,nPOk]

		If AllTrim(oChk:cName) == AllTrim(oBMPNO:cName)
			oGD:aCols[nLin,nPOk] := oBMPOK
		Else
			oGD:aCols[nLin,nPOk] := oBMPNO
		EndIf

		If !Empty(oGD:aHeader[nPOk][X3VLDUSER])
			bFunc := &("{|| "+oGD:aHeader[nPOk][X3VLDUSER]+"}")
			Eval(bFunc)
		EndIf

		oGD:Refresh()
	EndIf

	If nCol <> nPOk
		oGD:EditCell()
	EndIf

Return Nil

/*=========================================================================
=|=======================================================================|=
=|Programa: getValCpo    | Autor: Microsiga         | Fecha: 03/05/2019  |=
=|=======================================================================|=
=========================================================================*/
METHOD getValCpo(cCpo, nPos) CLASS ArGetDados

	n := ::oGetDados:nAt
	
	If nPos == Nil
		nPos := ::oGetDados:nAt
	EndIf
		
Return GDFieldGet(cCpo, nPos, .T., ::oGetDados:aHeader, ::oGetDados:aCols)

/*========================================================================
=|=======================================================================|=
=|Programa: getValCpo    | Autor: Microsiga         | Fecha: 03/05/2019  |=
=|=======================================================================|=
=========================================================================*/
METHOD getSumCpo(cCpo) CLASS ArGetDados

	Local nX 
	Local xVal
	Local nAnt
	Local nRet := 0
	
	If Type("n")=="N"
		nAnt := n
	EndIf
	
	For nX := 1 To Len(::oGetDados:aCols)
		If !::checkDel(nX)
		xVal := ::getValCpo(cCpo, nX)
		
		If ValType(xVal)=="N"
			nRet += xVal
		EndIf
		EndIf
	Next nX
	
	If Type("n")=="N"
		n := nAnt
	EndIf

Return nRet

/*=========================================================================
=|=======================================================================|=
=|Programa: getValCpo    | Autor: Microsiga         | Fecha: 03/05/2019  |=
=|=======================================================================|=
=========================================================================*/
METHOD setValCpo(cCpo, xVar, nPos) CLASS ArGetDados

	n := ::oGetDados:nAt
	
	If nPos == Nil
		nPos := ::oGetDados:nAt
	EndIf

	GDFieldPut(cCpo, xVar, nPos, ::oGetDados:aHeader, ::oGetDados:aCols)

	::aCols := aClone(::oGetDados:aCols)

Return Nil

/*========================================================================
=|=======================================================================|=
=|Programa: getValCpo    | Autor: Microsiga         | Fecha: 03/05/2019  |=
=|=======================================================================|=
=========================================================================*/
METHOD getOk(nPos) CLASS ArGetDados

	Local lRet		:= .F.
	Local nPosOk 	:= aScan(::aHeader, {|x| AllTrim(x[2]) == "BMPOK"})

	If nPosOk > 0
		lRet := ::getValCpo("BMPOK",nPos):cName == "WFCHK"
	EndIf

Return lRet

/*========================================================================
=|=======================================================================|=
=|Programa: getValCpo    | Autor: Microsiga         | Fecha: 03/05/2019  |=
=|=======================================================================|=
=========================================================================*/
METHOD refresh() CLASS ArGetDados

	If ValType(::oGetDados)=="O"
		::oGetDados:Refresh()
	EndIf

Return Nil

/*========================================================================
=|=======================================================================|=
=|Programa: getValCpo    | Autor: Microsiga         | Fecha: 03/05/2019  |=
=|=======================================================================|=
=========================================================================*/
METHOD checkDel(nPos) CLASS ArGetDados
Return GDDeleted(nPos, ::oGetDados:aHeader, ::oGetDados:aCols)
