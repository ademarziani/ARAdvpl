#INCLUDE "PROTHEUS.CH"

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa   ³Archivo   ?Autor ?Alejandro Perret      ?Data ?30/10/10 ³±?
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descrip.   ?Fucionalidades para archivos de texto.                     ³±?
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso        ?VARIOS.                                                    ³±?
±±ÃÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

CLASS ARArchiv2

	DATA oFile			As cObject
	DATA nHnd 			As Numeric
	DATA nTotReg		As Numeric
	DATA lAbierto		As Boolean
	DATA cDisco			As Character
	DATA cDir			As Character
	DATA cNomArch		As Character
	DATA cExtension		As Character
	DATA cNomCompleto	As Character
	DATA cToken			As Character
	DATA lCSV			AS Boolean
	DATA aCabCSV		As Array
	DATA aLinCSV		AS Array
		
	METHOD New() CONSTRUCTOR
	METHOD setToken()
	METHOD CreaArch()
	METHOD AbreTxt()
	METHOD CierraTxt()
	METHOD EOFTxt()
	METHOD LeeLinTxt()
	METHOD AvLinTxt()
	METHOD CantTotLinTxt()
	METHOD IrAlInicioTxt()
	METHOD LinToArr()
	METHOD ArchToArr()
	METHOD MueveArch()
	METHOD Escribir()
	METHOD EscribComp()
	METHOD CierraArch()
	METHOD AbreCSV()
	METHOD DatoCSV()
	METHOD VldCabCSV()
		
ENDCLASS

//---------------------------------------------------------------------------------------------------------------------------------------
METHOD New() CLASS ARArchiv2
	::nHnd		:= 0
	::lAbierto	:= .F.
	::cToken	:= ";"
	::nTotReg	:= 0
	::lCSV		:= .F.
RETURN SELF    

//---------------------------------------------------------------------------------------------------------------------------------------
METHOD setToken(cToken) CLASS ARArchiv2
	::cToken := cToken
RETURN Nil

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿
³Metodo     ?CreaArch ?Autor ?Alejandro Perret      ?Fecha?30/10/13 ?
ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´
³Descrip.   ?Crea un archivo (puede ser de texto o binario).            ?
ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
?     cNom ?Nombre del archivo con la ruta incluida y la extension.    ?
?   nAtrib ?Constante	Valor 	Descripción                            ?
?          ?FC_NORMAL   0 		Creación normal del ARArchiv2 (estándar).?
?          ?FC_READONLY 1 		Crea el archivo protegido para grabación.
?          ?FC_HIDDEN   2 		Crea el archivo como oculto.           ?
?          ?FC_SYSTEM   4 		Crea el archivo como sistema.          ?
ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/ 
METHOD CreaArch(cNom, nAtrib) CLASS ARArchiv2
	
	Local lRet	:= .T.
	
	::nHnd := FCreate(cNom, nAtrib)

	If ::nHnd == -1
		ConOut("Atencion!")
		ConOut("No se pudo crear el ARArchiv2: " + cNom)
		ConOut("Error: " + CValToChar(FError()))
		lRet := .F.
	Else
		::lAbierto := .T.
		::nTotReg  := ::CantTotLinTxt()
		::cNomCompleto := cNom 
		SplitPath (cNom, @::cDisco, @::cDir, @::cNomArch, @::cExtension)
	EndIf
	
RETURN lRet

//--------------------------------------------------------------------------------------------------------------------------------------- 
METHOD AbreTxt(cNombre, cMsgError) CLASS ARArchiv2	// Pasar el parametro @cMsgError por referencia.

	Local lRet	:= .T.

	::oFile	:= ARFile():New()
	::nHnd := ::oFile:FT_FUSE(cNombre)

	If ::nHnd == -1						//Error en apertura.
		lRet 			:= .F.
		cMsgError 		:= "No se pudo abrir el archivo: " + cNombre
	Else
		::lAbierto		:= .T.
		::nTotReg 		:= ::CantTotLinTxt()
		::cNomCompleto	:= cNombre 
		SplitPath (cNombre, @::cDisco, @::cDir, @::cNomArch, @::cExtension)	
	EndIf
	
RETURN lRet

//--------------------------------------------------------------------------------------------------------------------------------------- 
METHOD CierraTxt() CLASS ARArchiv2
	::oFile:FT_FClose()
RETURN 

//--------------------------------------------------------------------------------------------------------------------------------------- 
METHOD EOFTxt() CLASS ARArchiv2
RETURN (::oFile:FT_FEOF())

//--------------------------------------------------------------------------------------------------------------------------------------- 
METHOD LeeLinTxt() CLASS ARArchiv2
RETURN (::oFile:FT_FREADLN())

//--------------------------------------------------------------------------------------------------------------------------------------- 
METHOD AvLinTxt(nLineas) CLASS ARArchiv2
	Local lRet := ::oFile:FT_FSKIP(nLineas)

	If ::lCSV .And. !::EOFTxt()
		::aLinCSV := ::LinToArr()
	EndIf

RETURN lRet

//--------------------------------------------------------------------------------------------------------------------------------------- 
METHOD CantTotLinTxt() CLASS ARArchiv2
RETURN (::oFile:FT_FLASTREC())

//--------------------------------------------------------------------------------------------------------------------------------------- 
METHOD IrAlInicioTxt() CLASS ARArchiv2
RETURN (::oFile:FT_FGOTOP())

//--------------------------------------------------------------------------------------------------------------------------------------- 
METHOD LinToArr() CLASS ARArchiv2
RETURN ARMisc():Str2Arr(::LeeLinTxt(), ::cToken)

//--------------------------------------------------------------------------------------------------------------------------------------- 
METHOD ArchToArr(cCodParse) CLASS ARArchiv2

	Local aArea 	:= GetArea()
	Local aAreaZZX 	:= {}
	Local cClave	:= ""			
	Local aLens		:= {}
	Local cLineaTxt	:= ""
	Local nX		:= 0
	Local aRet		:= {}
	Local nIni		:= 1
	Local aLin		:= {}
	
	Default	cCodParse := ""

	If !Empty(cCodParse)
		aAreaZZX := ZZX->(GetArea())
	
		DbSelectArea("ZZX")		//Tabla de configuraciones
		DbSetOrder(1)
		cClave	:= xFilial("ZZX") + cCodParse 
		If DbSeek(cClave)
			While !Eof() .And. ZZX_FILIAL+ZZX_COD == cClave
				Aadd(aLens,ZZX_LARGO)
				DbSkip()
			EndDo
		EndIf
	EndIf
		
	::oFile:FT_FGOTOP()
	While !::oFile:FT_FEOF()
		cLineaTxt := ::oFile:FT_FREADLN()
		
		If !Empty(cCodParse)
			For nX := 1 To Len(aLens)
				Aadd(aLin,SubStr(cLineaTxt,nIni,aLens[nX]))
				nIni += aLens[nX]
			Next
		Else
			aLin := ARMisc():Str2Arr(cLineaTxt,::cToken)
		EndIf
			
		aAdd(aRet,aLin)
		nIni := 1     
		aLin := {}
		::oFile:FT_FSKIP()
	EndDo
		
	If !Empty(cCodParse)
		RestArea(aAreaZZX)
	EndIf
	RestArea(aArea)
	
RETURN aRet

//--------------------------------------------------------------------------------------------------------------------------------------- 
METHOD MueveArch(cOrig,cDest) CLASS ARArchiv2
	Local lRet	:= .T.

	If lRet := __CopyFile(cOrig,cDest)
		If FErase(cOrig) == -1	
			lRet := .F.
		EndIf
	EndIf
	
RETURN lRet

//--------------------------------------------------------------------------------------------------------------------------------------- 
METHOD Escribir(cLinea, cFinLinea) CLASS ARArchiv2
	
	Default cFinLinea := CRLF
	
	//nHnd vacio
	
	FWrite(::nHnd, cLinea + cFinLinea)
	
	//Error en la escritura
	//FERROR()desc
	
RETURN

//--------------------------------------------------------------------------------------------------------------------------------------- 
METHOD EscribComp(cLinea, cFinLinea, nQtdBytes) CLASS ARArchiv2	// Pasa todos los parametros a la funcion FWrite.
																// Debido a que no se puede pasar el parametro 
	Default cFinLinea := CRLF									// nQtdBytes vacio o nil o 0 pq no graba la linea.
	
	FWrite(::nHnd, cLinea + cFinLinea, nQtdBytes)

RETURN

//--------------------------------------------------------------------------------------------------------------------------------------- 
METHOD CierraArch() CLASS ARArchiv2
	
	If ::lAbierto
		If !FClose(::nHnd)
			ConOut("Atencion!")
			ConOut("No se pudo cerrar el ARArchiv2: " + ::cNomCompleto)
			ConOut("Error: " + CValToChar(FError()))
		EndIf
	Else
		ConOut("Atencion!")
		ConOut("ARArchiv2: " + ::cNomCompleto + " no abierto. No se efectu?el cierre.")
	EndIf
	
RETURN

//--------------------------------------------------------------------------------------------------------------------------------------- 
METHOD AbreCSV(cNombre, cMsgError, aCposVld) CLASS ARArchiv2	// Pasar el parametro @cMsgError por referencia.

	Local lRet 
	
	If (lRet := ::AbreTxt(cNombre, @cMsgError))
		::lCSV		:= .T.	
		::aCabCSV 	:= ::LinToArr()
		::AvLinTxt()
	EndIf
	
	If lRet .And. ValType(aCposVld)=="A"
		lRet := ::VldCabCSV(aCposVld, @cMsgError)
	EndIf
	
RETURN lRet

//--------------------------------------------------------------------------------------------------------------------------------------- 
METHOD DatoCSV(cCpo) CLASS ARArchiv2

    Local xRet      := ""
    Local nPos      := aScan(::aCabCSV, {|x| AllTrim(x) == cCpo})
    Local cTipo
    Local nTam 
    Local aAreaSX3

    If nPos > 0
        aAreaSX3 := SX3->(GetArea())

        SX3->(dbSetOrder(2))
        If SX3->(dbSeek(cCpo))
            cTipo := SX3->X3_TIPO
            nTam  := SX3->X3_TAMANHO
        Else
            cTipo := "C"
            nTam  := 0
        EndIf

        If cTipo == "N"
            xRet := Val(::aLinCSV[nPos])
        ElseIf cTipo == "D"
            xRet := SToD(::aLinCSV[nPos])
        ElseIf cTipo == "L"
            xRet := StrTran(::aLinCSV[nPos],".","") == "T"
        Else
            xRet := IIf(nTam > 0, PadR(::aLinCSV[nPos], nTam), ::aLinCSV[nPos])
        EndIf

        RestArea(aAreaSX3)
    EndIf

Return xRet

/*=====================================================================
|---------------------------------------------------------------------|
| Programa | GLRCTB01 | Autor: Andres Demarziani | Fecha: 29/04/2021  |
|---------------------------------------------------------------------|
======================================================================*/
METHOD VldCabCSV(aCposVld, cMsgError) CLASS ARArchiv2

    Local lRet  := .T.
    Local cEnc  := ""
	Local aCpos	:= {}
	Local nX

	For nX := 1 To Len(aCposVld)
		aAdd(aCpos, {.T., aCposVld[nX]})
	Next nX
	
    aEval(::aCabCSV, {|x| cEnc += Lower(AllTrim(x))+"/"})

    aEval(aCpos, {|x| x[1] := Lower(AllTrim(x[2]))$cEnc})
    aEval(aCpos, {|x| lRet := lRet .And. x[1]})    

    If !lRet
        cMsgError := "Los siguiente campos no se encuentran en el encabezado del archivo"+CRLF
        cMsgError += "------------------------------------------------------------------"+CRLF

        aEval(aCpos, {|x| cMsgError += IIf(!x[1], AllTrim(x[2])+CRLF, "")})        
    EndIf

Return lRet
