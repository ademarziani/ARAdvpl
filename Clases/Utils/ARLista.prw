#include "Protheus.ch"

/*=========================================================================
=|=======================================================================|=
=|Programa: ARLista      | Autor: Microsiga         | Fecha: 03/05/2019  |=
=|=======================================================================|=
=|Desc: Arma un listbox segun los array que envie el demandante.         |=
=|=======================================================================|=
=|Marca: VldSolicitudDevolucion                                          |=
=|=======================================================================|=
=========================================================================*/
CLASS ARLista
	
	DATA cTitulo
	DATA nAlto
	DATA nAncho
	
	DATA oDlg
	DATA oTwbr
	DATA aCampos	
	DATA aDatos
	DATA lDatos
	DATA cBLine
	DATA aPicture
	DATA bFDblClick

	DATA lOk
	
	DATA cCodigos
	DATA nPosCol
	DATA cCarSep
	
	METHOD New() CONSTRUCTOR 
	METHOD setTam()
	METHOD setFDblClick()
	METHOD setArray()
	METHOD setArrayNoCampos()
	METHOD setQuery()
	METHOD setCampos()
	METHOD setDatos()
	METHOD setBLine()
	METHOD setConfCodigo()
	METHOD canSetCodigo()
	METHOD setCodigos()
	METHOD verDatos()
	METHOD getTwBrowse()
	METHOD refreshTwbr()

ENDCLASS

/*=========================================================================
=|=======================================================================|=
=|Programa: New          | Autor: Microsiga         | Fecha: 03/05/2019  |=
=|=======================================================================|=
=========================================================================*/
METHOD New(cTitulo, nPorcAncho, nPorcAlto) CLASS ARLista

	Local aSize 	:= MsAdvSize()
	
	nPorcAncho	:= IIf(nPorcAncho==Nil,1,nPorcAncho/100)
	nPorcAlto	:= IIf(nPorcAlto==Nil,1,nPorcAlto/100)
	::cTitulo	:= cTitulo
	::aCampos	:= {}
	::aDatos	:= {}
	::aPicture	:= {}
	::nPosCol	:= 0
	::cCarSep	:= ""
	::lDatos	:= .T.
	::lOk		:= .F.

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
METHOD setTam(nAncho, nAlto) CLASS ARLista

	::nAncho	:= nAncho
	::nAlto		:= nAlto

RETURN Nil

/*=========================================================================
=|=======================================================================|=
=|Programa: setTam       | Autor: Microsiga         | Fecha: 03/05/2019  |=
=|=======================================================================|=
=========================================================================*/
METHOD setFDblClick(bFDblClick) CLASS ARLista

	::bFDblClick := bFDblClick

RETURN Nil

/*=========================================================================
=|=======================================================================|=
=|Programa: setArray     | Autor: Microsiga         | Fecha: 03/05/2019  |=
=|=======================================================================|=
=========================================================================*/
METHOD setArray(aCampos, aDatos) CLASS ARLista
	
	::setCampos(aCampos)
	::setDatos(aDatos)
	::setBLine()
	
RETURN Nil

/*=========================================================================
=|=======================================================================|=
=|Programa: setArray     | Autor: Microsiga         | Fecha: 03/05/2019  |=
=|=======================================================================|=
=========================================================================*/
METHOD setArrayNoCampos(aDatos) CLASS ARLista
	
	Local aCampos := {}
	Local nX
	
	For nX := 1 To Len(aDatos[1])
		aAdd(aCampos, "CAMPO"+StrZero(nX,3))
	Next nX
	
	::setCampos(aCampos)
	::setDatos(aDatos)
	::setBLine()
	
RETURN Nil

/*=========================================================================
=|=======================================================================|=
=|Programa: setQuery     | Autor: Microsiga         | Fecha: 03/05/2019  |=
=|=======================================================================|=
=========================================================================*/
METHOD setQuery(cQuery) CLASS ARLista

	Local cTabla 	:= GetNextAlias()
	Local aArea		:= GetArea()
	Local aStru		:= {}
	Local aCampos	:= {}
	Local aDatos	:= {}
	Local aLin		:= {}
	Local aLinVacia	:= {}
	Local nC

	::aPicture := {}
	
	dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQuery),cTabla,.F.,.T.)
	aStru := dbStruct()

	dbSelectArea("SX3")
	dbSetOrder(2)

	For nC := 1 to Len(aStru)
		If SX3->(dbSeek(aStru[nC,1]))		
			aAdd(aCampos, AllTrim(X3Titulo()))
			
			If SX3->X3_TIPO != "C"				
				aStru[nC,2] := SX3->X3_TIPO
				aStru[nC,3] := SX3->X3_TAMANHO
				aStru[nC,4] := SX3->X3_DECIMAL
						
				TCSetField(cTabla, aStru[nC,1], aStru[nC,2], aStru[nC,3], aStru[nC,4])				
			Endif

			If !Empty(SX3->X3_PICTURE)
				aAdd(::aPicture, {nC, SX3->X3_PICTURE})
			EndIf
			
			aAdd(aLinVacia, fCreaVar(aStru[nC,2]))
		Else		
			If nC == 1 .And. "OK" $ aStru[nC,1]			
				aAdd(aCampos, "")
				TCSetField(cTabla, aStru[nC,1], "L", 1, 0)
				aAdd(aLinVacia, fCreaVar("L"))
			Else			
				aAdd(aCampos, Capital(aStru[nC,1]))
				aAdd(aLinVacia, fCreaVar(aStru[nC,2]))
			EndIf			
		EndIf
	Next nC

	dbSelectArea(cTabla)
	dbGoTop()
	While !Eof()
		For nC := 1 To Len(aStru)
			aAdd(aLin, &(aStru[nC][1]))
		Next nC
		
		aAdd(aDatos, aLin)
		aLin := {}
		
		dbSkip()
	EndDo

	dbCloseArea()
	RestArea(aArea)
	
	If Empty(aDatos)
		aAdd(aDatos, aLinVacia)
		::lDatos := .F.
	EndIf
	
	::setArray(aCampos, aDatos)
	
RETURN Nil

/*=========================================================================
=|=======================================================================|=
=|Programa: setCampos    | Autor: Microsiga         | Fecha: 03/05/2019  |=
=|=======================================================================|=
=========================================================================*/
METHOD setCampos(aCampos) CLASS ARLista

	::aCampos := aCampos

RETURN Nil

/*=========================================================================
=|=======================================================================|=
=|Programa: setDatos     | Autor: Microsiga         | Fecha: 03/05/2019  |=
=|=======================================================================|=
=========================================================================*/
METHOD setDatos(aDatos) CLASS ARLista

	::aDatos	:= aDatos
	
RETURN Nil

/*=========================================================================
=|=======================================================================|=
=|Programa: setBLine     | Autor: Microsiga         | Fecha: 03/05/2019  |=
=|=======================================================================|=
=========================================================================*/
METHOD setBLine(cBLine) CLASS ARLista

	Local cRet	:= ""
	Local aArray
	Local nPos
	Local nX

	If Type("oBMPOK")=="U"
		Public oBMPOK := LoadBitmap( GetResources(), "WFCHK" )
		Public oBMPNO := LoadBitmap( GetResources(), "WFUNCHK" )
		Public oBMPVER := LoadBitmap( GetResources(), "ENABLE" )
		Public oBMPROJ := LoadBitmap( GetResources(), "DISABLE" )
	EndIf
	
	If cBLine == Nil
		aArray := aClone(::aDatos[1])
		
		For nX := 1 To Len(aArray)
			If Len(cRet) > 0
				cRet += " , "
			EndIf

			Do Case
				Case nX == 1 .And. ValType(aArray[nX]) == "L"
					cRet += "IIF(aDatos[oTwbr:nAt,1],oBMPOK,oBMPNO)"
				Case !Empty(::aPicture) .And. (nPos := aScan(::aPicture, {|x| x[1] == nX})) > 0
					cRet += "Transform(aDatos[oTwbr:nAt,"+AllTrim(Str(nX))+"],'"+::aPicture[nPos][2]+"')"
				Otherwise
					cRet += "aDatos[oTwbr:nAt,"+AllTrim(Str(nX))+"]"
			EndCase
		Next
		
		::cBLine := "{|| {" + cRet + " } }" 
	Else	
		::cBLine := "{|| {" + cBLine + " } }" 
	EndIf
	
RETURN Nil

/*=========================================================================
=|=======================================================================|=
=|Programa: setConfCodigo| Autor: Microsiga         | Fecha: 03/05/2019  |=
=|=======================================================================|=
=========================================================================*/
METHOD setConfCodigo(nPosCol,cCarSep) CLASS ARLista

	If ::canSetCodigo(nPosCol,cCarSep)
		::cCodigos	:= ""
		::nPosCol	:= nPosCol
		::cCarSep	:= cCarSep		
	EndIf
	
RETURN Nil

/*=========================================================================
=|=======================================================================|=
=|Programa: canSetCodigo | Autor: Microsiga         | Fecha: 03/05/2019  |=
=|=======================================================================|=
=========================================================================*/
METHOD canSetCodigo(nPosCol,cCarSep)	 CLASS ARLista

Local lRet := nPosCol >= 1 .And. nPosCol <= Len(::aCampos) .And. ;
			Len(::aDatos) > 0 .And. ;
			ValType(::aDatos[1][1]) == "L" .And. ;
			ValType(::aDatos[1][nPosCol]) == "C" .And.;
			ValType(cCarSep) == "C"
		
RETURN lRet

/*=========================================================================
=|=======================================================================|=
=|Programa: setCodigos   | Autor: Microsiga         | Fecha: 03/05/2019  |=
=|=======================================================================|=
=========================================================================*/
METHOD setCodigos() CLASS ARLista

	If ::canSetCodigo(::nPosCol,::cCarSep)
		::cCodigos := ""		
		aEval(::aDatos, {|x| ::cCodigos += IIf(x[1], x[::nPosCol]+::cCarSep, "")})
		
		If !Empty(::cCodigos)
			::cCodigos := SubStr(::cCodigos,1,Len(::cCodigos)-1)
		EndIf	
	EndIf
	
	If ::bFDblClick <> Nil
		Eval(::bFDblClick, ::aDatos)
	EndIf	
	
RETURN Nil

/*=========================================================================
=|=======================================================================|=
=|Programa: verDatos     | Autor: Microsiga         | Fecha: 03/05/2019  |=
=|=======================================================================|=
=========================================================================*/
METHOD verDatos(bDblClick, bHeaderClick) CLASS ARLista

	Local oDlg		:= Nil
	Local nOpcA		:= 0

	If Len(::aDatos) > 0 .And. ::lDatos
		DEFINE MSDIALOG oDlg FROM 000,000 TO ::nAlto,::nAncho TITLE ::cTitulo PIXEL

		::getTwBrowse(oDlg, bDblClick, bHeaderClick)
		
		ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{ || nOpcA:=1,oDlg:End() },{|| nOpcA:=0,oDlg:End()},,) CENTERED
		
		::lOk := nOpcA == 1		
	EndIf

Return Nil

/*=========================================================================
=|=======================================================================|=
=|Programa: getTwBrowse  | Autor: Microsiga         | Fecha: 03/05/2019  |=
=|=======================================================================|=
=========================================================================*/
METHOD getTwBrowse(oVentana, bDblClick, bHeaderClick) CLASS ARLista

	Local aDatos
	Local oTwbr
	Local oSelf := Self
	
	bDblClick 		:= IIf(bDblClick==Nil, {|| fSelOne(@oTwbr, oSelf)}, bDblClick)
	bHeaderClick	:= IIf(bHeaderClick==Nil, {|oObj,nCol| fSelAll(@oTwbr, nCol, oSelf)}, bHeaderClick)

	If Len(::aDatos) > 0		
		aDatos	:= ::aDatos

		oTwbr:= TwBrowse():New(0,0,0,0,,::aCampos,,oVentana,,,,,,,,,,,,.F.,,.T.,,.F.,,,)		
		oTwbr:Align := CONTROL_ALIGN_ALLCLIENT
		oTwbr:SetArray(aDatos)
		oTwbr:bLine := &(oSelf:cBLine)
		oTwbr:bLDblClick := bDblClick
		oTwbr:bHeaderClick := bHeaderClick
	EndIf
	
	::oTwbr := oTwbr
	
Return oTwbr


/*=========================================================================
=|=======================================================================|=
=|Programa: fSelOne      | Autor: Microsiga         | Fecha: 03/05/2019  |=
=|=======================================================================|=
=========================================================================*/
Static Function fSelOne(oTwbr, oSelf)

	Local aDatos	:= oTwbr:aArray

	If ValType(aDatos[oTwbr:nAt,1]) == "L"
		aDatos[oTwbr:nAt,1] := !aDatos[oTwbr:nAt,1]		
		oTwbr:Refresh()
		oSelf:setCodigos()
	EndIf

Return Nil

/*=========================================================================
=|=======================================================================|=
=|Programa: fSelAll      | Autor: Microsiga         | Fecha: 03/05/2019  |=
=|=======================================================================|=
=========================================================================*/
Static Function fSelAll(oTwbr, nCol, oSelf)

	Local lMarca	:= .F.
	Local aDatos	:= oTwbr:aArray
	Local nX		:= 1

	If nCol == 1
		lMarca := !aDatos[oTwbr:nAt,nCol]
		
		For nX := 1 To Len(aDatos)
			aDatos[nX,nCol] := lMarca
		Next nX
	EndIf

	oTwbr:Refresh()
	oSelf:setCodigos()
	
Return Nil

/*=========================================================================
=|=======================================================================|=
=|Programa: refreshTwbr  | Autor: Microsiga         | Fecha: 03/05/2019  |=
=|=======================================================================|=
=========================================================================*/
METHOD refreshTwbr(lRefAll) CLASS ARLista
	
	Local oTwbr
	Local aDatos
	
	If lRefAll <> Nil .And. lRefAll
		aDatos	:= ::aDatos
		oTwbr	:= ::oTwbr
		
		oTwbr:SetArray(aDatos)
		oTwbr:bLine := &(::cBLine)
	EndIf
	
	::oTwbr:Refresh()
	::setCodigos()
	
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
