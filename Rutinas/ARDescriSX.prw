#INCLUDE 'PROTHEUS.CH'

#DEFINE STR0001 "Algunos de los siguientes campos no se encuentra en el archivo."
#DEFINE STR0002 "-------------------------------------------------------------------"

/*=====================================================================
|---------------------------------------------------------------------|
| Programa | DESCRISX | Autor: Andres Demarziani | Fecha: 15/02/2020  |
|---------------------------------------------------------------------|
| Descripcion: Rutina para modif. descripciones en SX1 y SX3.         |
|---------------------------------------------------------------------|
======================================================================*/
CLASS TABDICC

	DATA cTabla
	DATA cDescri
	DATA nFolder
	
	DATA cArchivo
	DATA oArchivo
	
	DATA nRegTotal
	DATA oRegTotal
	
	DATA nRegDif
	DATA oRegDif
	
	DATA nRegNoFind
	DATA oRegNoFind

	DATA nPosGru
	DATA nPosOrd
	DATA nPosCpo
	DATA nPosDcr
	DATA nPosDSpa
	DATA nPosDEng
	
	DATA oLista
	DATA aEncab
	DATA aDetalle
	DATA nRegUpd

	METHOD New() CONSTRUCTOR
	METHOD armaVentana()	
	METHOD validar()
	METHOD cargar()
	METHOD limpiar()
	METHOD refrescar()
	METHOD actualizar()
	
ENDCLASS

/*=====================================================================
|---------------------------------------------------------------------|
| Programa | DESCRISX | Autor: Andres Demarziani | Fecha: 15/02/2019  |
|---------------------------------------------------------------------|
======================================================================*/
METHOD New(cTabla, cDescri) CLASS TABDICC

	::cTabla		:= cTabla
	::cDescri		:= cDescri
	
	::cArchivo		:= Space(100)
	
	::nRegTotal		:= 0
	::nRegDif		:= 0
	::nRegNoFind	:= 0
	::nRegUpd		:= 0
	
	If cTabla == "SX1"
		::nFolder	:= 1
		::aEncab	:= {"Pregunta","Orden","POR.Actual","SPA.Actual","ENG.Actual","POR.Nueva","SPA.Nueva","ENG.Nueva"}
		::aDetalle	:= {{Space(10),Space(02),Space(25),Space(25),Space(25),Space(25),Space(25),Space(25)}}		
		
		dbSelectArea("SX1")
		dbSetOrder(1)
	EndIf
	
	If cTabla == "SX3"
		::nFolder	:= 2
		::aEncab	:= {"Campo","POR.Actual","SPA.Actual","ENG.Actual","POR.Nueva","SPA.Nueva","ENG.Nueva"}
		::aDetalle	:= {{Space(10),Space(12),Space(12),Space(12),Space(12),Space(12),Space(12)}}	

		dbSelectArea("SX3")
		dbSetOrder(2)
	EndIf

	::oLista := ARLista():New(cTabla)		
	::oLista:setArray(::aEncab, ::aDetalle)
	
RETURN SELF

/*=====================================================================
|---------------------------------------------------------------------|
| Programa | DESCRISX | Autor: Andres Demarziani | Fecha: 15/02/2019  |
|---------------------------------------------------------------------|
======================================================================*/
METHOD armaVentana(oFWLayer, oDialog) CLASS TABDICC

	Local oPanel1
	Local oPanel2

	oFWLayer := FWLayer():New()
	oFWLayer:init(oDialog, .F.)
		
	oFWLayer:addLine('Linha1',015,.T.)
	oFWLayer:addLine('Linha2',085,.T.)

	oFWLayer:addCollumn( "Col01", 100, .F.,"Linha1")
	oFWLayer:addCollumn( "Col02", 100, .F.,"Linha2")

	oFWLayer:addWindow( "Col01" , "Win01"	, "Archivo"		,100, .F., .F., ,"Linha1" )
	oFWLayer:addWindow( "Col02" , "Win02"	, "Comparacion"	,100, .F., .F., ,"Linha2" )

	oPanel1	:= oFWLayer:getWinPanel("Col01", "Win01", "Linha1")
	oPanel2	:= oFWLayer:getWinPanel("Col02", "Win02", "Linha2")

	@ 005,005 SAY ::cDescri SIZE 100,007 OF oPanel1 PIXEL FONT oFont
	@ 004,050 MSGET ::oArchivo VAR ::cArchivo SIZE 200,007 OF oPanel1 PIXEL WHEN .F.

	TBtnBmp2():New(004,500,026,026,"SDUOPEN",,,, {|| fProcesa()}, oPanel1, "Archivo...")

	@ 005,280 SAY "Registros:" SIZE 100,007 OF oPanel1 PIXEL FONT oFont
	@ 005,380 SAY "Diferencias:" SIZE 100,007 OF oPanel1 PIXEL FONT oFont
	@ 005,480 SAY "No encontrados:" SIZE 100,007 OF oPanel1 PIXEL FONT oFont

	@ 005,340 SAY ::oRegTotal VAR ::nRegTotal SIZE 200,007 OF oPanel1 FONT oFont PIXEL
	@ 005,440 SAY ::oRegDif VAR ::nRegDif SIZE 200,007 OF oPanel1 FONT oFont PIXEL
	@ 005,540 SAY ::oRegNoFind VAR ::nRegNoFind SIZE 200,007 OF oPanel1 FONT oFont PIXEL

	::oLista:getTwBrowse(oPanel2)

Return Nil

/*=====================================================================
|---------------------------------------------------------------------|
| Programa | DESCRISX | Autor: Andres Demarziani | Fecha: 15/02/2019  |
|---------------------------------------------------------------------|
======================================================================*/
METHOD validar(aArray) CLASS TABDICC

	Local cLog := ""
	Local lRet := .T.

	If ::cTabla == "SX1"
		If aArray <> Nil
			::nPosGru 	:= aScan(aArray, {|x| AllTrim(x) == "X1_GRUPO"})
			::nPosOrd 	:= aScan(aArray, {|x| AllTrim(x) == "X1_ORDEM"})
			::nPosDcr	:= aScan(aArray, {|x| AllTrim(x) == "X1_PERGUNT"})
			::nPosDSpa	:= aScan(aArray, {|x| AllTrim(x) == "X1_PERSPA"})
			::nPosDEng	:= aScan(aArray, {|x| AllTrim(x) == "X1_PERENG"})
		Else
			::nPosGru 	:= DESX->(FieldPos("X1_GRUPO"))
			::nPosOrd 	:= DESX->(FieldPos("X1_ORDEM"))
			::nPosDcr	:= DESX->(FieldPos("X1_PERGUNT"))
			::nPosDSpa	:= DESX->(FieldPos("X1_PERSPA"))
			::nPosDEng	:= DESX->(FieldPos("X1_PERENG"))
		EndIf
		
		If ::nPosGru * ::nPosOrd * ::nPosDcr * ::nPosDSpa * ::nPosDEng == 0
			cLog += STR0001+CRLF
			cLog += STR0002+CRLF
			cLog += "X1_GRUPO"+CRLF
			cLog += "X1_ORDEM"+CRLF
			cLog += "X1_PERGUNT"+CRLF
			cLog += "X1_PERSPA"+CRLF
			cLog += "X1_PERENG"+CRLF
		EndIf
	EndIf	
	
	If ::cTabla == "SX3"
		If aArray <> Nil
			::nPosCpo 	:= aScan(aArray, {|x| AllTrim(x) == "X3_CAMPO"})
			::nPosDcr	:= aScan(aArray, {|x| AllTrim(x) == "X3_TITULO"})
			::nPosDSpa	:= aScan(aArray, {|x| AllTrim(x) == "X3_TITSPA"})
			::nPosDEng	:= aScan(aArray, {|x| AllTrim(x) == "X3_TITENG"})			
		Else
			::nPosCpo 	:= DESX->(FieldPos("X3_CAMPO"))
			::nPosDcr	:= DESX->(FieldPos("X3_TITULO"))
			::nPosDSpa	:= DESX->(FieldPos("X3_TITSPA"))
			::nPosDEng	:= DESX->(FieldPos("X3_TITENG"))
		EndIf
		
		If ::nPosCpo * ::nPosDcr * ::nPosDSpa * ::nPosDEng == 0
			cLog += STR0001+CRLF
			cLog += STR0002+CRLF
			cLog += "X3_CAMPO"+CRLF
			cLog += "X3_TITULO"+CRLF
			cLog += "X3_TITSPA"+CRLF
			cLog += "X3_TITENG"+CRLF
		EndIf
	EndIf
	
	If !Empty(cLog)
		lRet := .F.
		FVerLog(cLog)
	EndIf	

Return lRet


/*=====================================================================
|---------------------------------------------------------------------|
| Programa | DESCRISX | Autor: Andres Demarziani | Fecha: 15/02/2019  |
|---------------------------------------------------------------------|
======================================================================*/
METHOD cargar(cLog, aArray) CLASS TABDICC

	Local cGrupo, cOrden
	
	Local aLin		:= {}
	
	Local cNewDPor	
	Local cNewDSpa
	Local cNewDEng
		
	If ::cTabla == "SX1" 
		If aArray <> Nil
			cGrupo		:= PadR(Alltrim(aArray[::nPosGru]), 10)
			cOrden		:= StrZer(Val(aArray[::nPosOrd]), 2)			
			cNewDPor	:= aArray[::nPosDcr]
			cNewDSpa	:= aArray[::nPosDSpa]
			cNewDEng	:= aArray[::nPosDEng]
		Else
			cGrupo 		:= DESX->X1_GRUPO
			cOrden 		:= DESX->X1_ORDEM			
			cNewDPor	:= DESX->X1_PERGUNT
			cNewDSpa	:= DESX->X1_PERSPA
			cNewDEng	:= DESX->X1_PERENG
		EndIf
			
		If SX1->(dbSeek(cGrupo+cOrden))
			If fDescDif(SX1->X1_PERGUNT, SX1->X1_PERSPA, SX1->X1_PERENG, cNewDPor, cNewDSpa, cNewDEng)
				aAdd(aLin, cGrupo)
				aAdd(aLin, cOrden)				
				aAdd(aLin, SX1->X1_PERGUNT)
				aAdd(aLin, SX1->X1_PERSPA)
				aAdd(aLin, SX1->X1_PERENG)
				aAdd(aLin, cNewDPor)
				aAdd(aLin, cNewDSpa)
				aAdd(aLin, cNewDEng)

				aAdd(::aDetalle, aLin)
				aLin := {}
				
				::nRegDif++
			EndIf
		Else
			If Empty(cLog)
				cLog += "No se encontraron las siguientes preguntas:"+CRLF
				cLog += "-------------------------------------------"+CRLF
			EndIf
			
			cLog += AllTrim(cGrupo)+"-"+AllTrim(cOrden)+CRLF
			
			::nRegNoFind++
		EndIf
	EndIf
	
	If ::cTabla == "SX3"
		If aArray <> Nil
			cCampo 		:= PadR(Alltrim(aArray[::nPosCpo]), 10)
			cNewDPor	:= aArray[::nPosDcr]
			cNewDSpa	:= aArray[::nPosDSpa]
			cNewDEng	:= aArray[::nPosDEng]
		Else
			cCampo 		:= DESX->X3_CAMPO
			cNewDPor	:= DESX->X3_TITULO
			cNewDSpa	:= DESX->X3_TITSPA
			cNewDEng	:= DESX->X3_TITENG
		EndIf
			
		If SX3->(dbSeek(cCampo))
			If fDescDif(SX3->X3_TITULO, SX3->X3_TITSPA, SX3->X3_TITENG, cNewDPor, cNewDSpa, cNewDEng)								
				aAdd(aLin, cCampo)				
				aAdd(aLin, SX3->X3_TITULO)
				aAdd(aLin, SX3->X3_TITSPA)
				aAdd(aLin, SX3->X3_TITENG)
				aAdd(aLin, cNewDPor)
				aAdd(aLin, cNewDSpa)
				aAdd(aLin, cNewDEng)
				
				aAdd(::aDetalle, aLin)
				aLin := {}
			
				::nRegDif++
			EndIf
		Else
			If Empty(cLog)
				cLog += "No se encontraron los siguientes campos:"+CRLF
				cLog += "----------------------------------------"+CRLF
			EndIf
			
			cLog += AllTrim(cCampo)+CRLF
						
			::nRegNoFind++
		EndIf
	EndIf

	::nRegTotal++
	
Return Nil

/*=====================================================================
|---------------------------------------------------------------------|
| Programa | DESCRISX | Autor: Andres Demarziani | Fecha: 15/02/2019  |
|---------------------------------------------------------------------|
======================================================================*/
METHOD limpiar() CLASS TABDICC
	
	::aDetalle		:= {}
	::nRegTotal 	:= 0
	::nRegDif		:= 0
	::nRegNoFind	:= 0

RETURN Nil

/*=====================================================================
|---------------------------------------------------------------------|
| Programa | DESCRISX | Autor: Andres Demarziani | Fecha: 15/02/2019  |
|---------------------------------------------------------------------|
======================================================================*/
METHOD refrescar() CLASS TABDICC
	
	::oRegTotal:SetText(::nRegTotal)
	::oRegDif:SetText(::nRegDif)
	::oRegNoFind:SetText(::nRegNoFind)
	
	::oLista:setDatos(::aDetalle)
	::oLista:refreshTwbr(.T.)	

RETURN Nil


/*=====================================================================
|---------------------------------------------------------------------|
| Programa | DESCRISX | Autor: Andres Demarziani | Fecha: 15/02/2019  |
|---------------------------------------------------------------------|
======================================================================*/
METHOD actualizar() CLASS TABDICC

	Local nX 
	Local nTamDatos	:= Len(::aDetalle)

	If ::nRegDif > 0
		ProcRegua(nTamDatos)

		For nX := 1 To nTamDatos
			IncProc("Actualizando registros en "+::cTabla+"...")
			
			If ::cTabla == "SX1" .And. SX1->(dbSeek(::aDetalle[nX][1]+::aDetalle[nX][2]))
				::nRegUpd++
								
				RecLock("SX1", .F.)
				SX1->X1_PERGUNT	:= ::aDetalle[nX][6]
				SX1->X1_PERSPA	:= ::aDetalle[nX][7]
				SX1->X1_PERENG	:= ::aDetalle[nX][8]
				MsUnLock()
			EndIf		

			If ::cTabla == "SX3" .And. SX3->(dbSeek(::aDetalle[nX][1]))
				::nRegUpd++
				
				RecLock("SX3", .F.)
				SX3->X3_TITULO := ::aDetalle[nX][5]
				SX3->X3_TITSPA := ::aDetalle[nX][6]
				SX3->X3_TITENG := ::aDetalle[nX][7]
				MsUnLock()
			EndIf 			
		Next nX		
	EndIf

Return Nil

/*=====================================================================
|---------------------------------------------------------------------|
| Programa | DESCRISX | Autor: Andres Demarziani | Fecha: 15/02/2019  |
|---------------------------------------------------------------------|
======================================================================*/
User function ARDescriSX()

	MsApp():New("SIGAESP1")
	oApp:CreateEnv()

	oApp:cStartProg := 'U_UPDDESSX()'

	//Seta Atributos 
	__lInternet := .T.
		 
	//Inicia a Janela 
	oApp:Activate()
	
Return Nil

/*=====================================================================
|---------------------------------------------------------------------|
| Programa | DESCRISX | Autor: Andres Demarziani | Fecha: 15/02/2019  |
|---------------------------------------------------------------------|
======================================================================*/
User Function UPDDESSX()

	Local lOk		:= .F.	
	Local cTitulo	:= "Descripciones diccionario - Empresa: "+cEmpAnt+"-"+AllTrim(GetAdvFVal("SM0","M0_NOMECOM",cEmpAnt+cFilAnt,1,""))
	Local oDlg

	Local oFWLSX1
	Local oFWLSX3
	
	Local oBtnOk
	Local oBtnCancel
	
	Local aSize		:= MsAdvSize()
	Local nAlto		:= aSize[6] * 0.85
	Local nAncho	:= aSize[5]
	
	Private oFont
	Private oFolder
	
	Private oTabSX1 := TABDICC():New("SX1", "Archivo SX1")
	Private oTabSX3 := TABDICC():New("SX3", "Archivo SX3")
	
	DEFINE FONT oFont NAME "Courier New" SIZE 6,14
		
	DEFINE MSDIALOG oDlg FROM 000,000 TO nAlto, nAncho TITLE cTitulo PIXEL
	
		@ 002,002 FOLDER oFolder SIZE (nAncho/2)-7, (nAlto/2)-27 OF oDlg ITEMS "SX1", "SX3" COLORS 0, 14215660 PIXEL
	
		oTabSX1:armaVentana(@oFWLSX1, @oFolder:aDialogs[01])
		oTabSX3:armaVentana(@oFWLSX3, @oFolder:aDialogs[02])
		
		oBtnOk     := SButton():New((nAlto/2)-20, (nAncho/2)-080, 1, {|| IIf((lOk := MsgYesNo("¿Confirma la actualización de las descripciones?")), oDlg:End(),) }, oDlg, Nil, Nil, Nil)
		oBtnCancel := SButton():New((nAlto/2)-20, (nAncho/2)-045, 2, {|| IIf(MsgYesNo("¿Desea salir del programa?"), oDlg:End(),)}, oDlg, Nil, Nil, Nil)	
			
	ACTIVATE MSDIALOG oDlg CENTERED
	
	If lOk
		Processa({|| fActRegistros(@oTabSX1, @oTabSX3)})

		If oTabSX1:nRegUpd+oTabSX3:nRegUpd <> 0
			FVerLog("Registros actualizados: "+CRLF+;
					"Descripciones en SX1: "+cValToChar(oTabSX1:nRegUpd)+CRLF+;
					"Descripciones en SX3: "+cValToChar(oTabSX3:nRegUpd))
		EndIf	
	EndIf

Return Nil


/*=====================================================================
|---------------------------------------------------------------------|
| Programa | DESCRISX | Autor: Andres Demarziani | Fecha: 15/02/2019  |
|---------------------------------------------------------------------|
======================================================================*/
Static Function fProcesa()

	Local cDrive, cDir, cNome, cExt, cPath, oTabla, lServer
					
	AjustaSX1("DESCRISX")
			
	If Pergunte("DESCRISX", .T.)
		Do Case
			Case oFolder:nOption == 1
				oTabla := oTabSX1					
			Case oFolder:nOption == 2
				oTabla := oTabSX3
		EndCase
	
		cPath := cGetFile("Archivo CSV|"+oTabla:cTabla+"*.csv | Archivo CTREE|"+oTabla:cTabla+"*.dtc",;
					"Seleccione el archivo",;
					Nil,;
					Nil,;
					.F.,;
					GETF_LOCALHARD,;
					.T.)
					
		If !Empty(cPath) .And. File(cPath)
			SplitPath(cPath, @cDrive, @cDir, @cNome, @cExt )
						
			oTabla:cArchivo := cPath
			oTabla:oArchivo:Refresh()
			
			lServer := Empty(cDrive)
			
			If cExt == ".csv"
				Processa({|| fCSVDesc(lServer, cPath, oTabla)})
			ElseIf cExt == ".dtc"
				Processa({|| fDTCDesc(lServer, cPath, cNome+cExt, oTabla)})
			EndIf
		EndIf
	EndIf

Return Nil

/*=====================================================================
|---------------------------------------------------------------------|
| Programa | DESCRISX | Autor: Andres Demarziani | Fecha: 15/02/2019  |
|---------------------------------------------------------------------|
======================================================================*/
Static Function fActRegistros(oTabSX1, oTabSX3)

	oTabSX1:actualizar()
	oTabSX3:actualizar()
		
Return Nil

/*=====================================================================
|---------------------------------------------------------------------|
| Programa | DESCRISX | Autor: Andres Demarziani | Fecha: 15/02/2019  |
|---------------------------------------------------------------------|
======================================================================*/
Static Function fCSVDesc(lServer, cPath, oTabla)

Local cSep		:= ";"
Local cLog		:= ""
Local cString
Local aArray
	
FT_FUse(cPath)
FT_FGotop()

cString	:= FT_FREADLN()
aArray	:= fStr2Arr(cString, cSep)

If oTabla:validar(aArray)
	FT_FSkip() // Ignoro el primer registro ya que tiene encabezado

	ProcRegua(FT_FLastRec())
	
	oTabla:limpiar()

	While (!FT_FEof())	
		IncProc()
		
		cString	:= FT_FREADLN()
		aArray	:= fStr2Arr(cString, cSep)
		
		oTabla:cargar(@cLog, aArray)
	
		FT_FSkip() 		
	EndDo
	
	oTabla:refrescar()
	
	FVerLog(cLog)	
EndIf
		
FT_FUse()

Return Nil

/*=====================================================================
|---------------------------------------------------------------------|
| Programa | DESCRISX | Autor: Andres Demarziani | Fecha: 15/02/2019  |
|---------------------------------------------------------------------|
======================================================================*/
Static Function fDTCDesc(lServer, cPath, cArchivo, oTabla)

Local cLog		:= ""
Local cPathSrv	:= "\spool\"

If lServer .Or. (!lServer .And. CpyT2S(cPath, cPathSrv))
	cPathSrv := cPathSrv+cArchivo

	dbUseArea(.T., "CTREECDX", cPathSrv, "DESX", .F., .F.)
	dbSelectArea("DESX")
	dbGoTop()
	
	If oTabla:validar()
		ProcRegua(DESX->(RecCount()))
		
		oTabla:limpiar()

		While !DESX->(Eof())
			IncProc()
			
			oTabla:cargar(@cLog)
		
			DESX->(dbSkip())
		EndDo
			
		oTabla:refrescar()
		
		FVerLog(cLog)	
	EndIf

	dbSelectArea("DESX")
	dbCloseArea()	
EndIf

Return Nil

/*=====================================================================
|---------------------------------------------------------------------|
| Programa | DESCRISX | Autor: Andres Demarziani | Fecha: 15/02/2019  |
|---------------------------------------------------------------------|
======================================================================*/
Static Function fStr2Arr(cString, cSep)

Local aReturn := {}			// Armazena o retorno da funcao
Local cAux    := cString 	// Variavel auxiliar
Local nPos    := 0			// Variavel auxiliar

While At( cSep , cAux ) > 0
	nPos := At( cSep , cAux )
	Aadd( aReturn, SubStr( cAux, 1, nPos-1 ) )
	cAux := SubStr( cAux, nPos+1 )
EndDo

Aadd( aReturn, cAux )

Return( aReturn ) 

/*=====================================================================
|---------------------------------------------------------------------|
| Programa | DESCRISX | Autor: Andres Demarziani | Fecha: 15/02/2019  |
|---------------------------------------------------------------------|
======================================================================*/
Static Function FVerLog(cString)

Local oString	:= NIL
Local oFont1	:= TFont():New("Courier New",,014,,.F.,,,,,.F.,.F.)
Local oDlg2		:= NIL
Local aSize		:= MsAdvSize()
Local lScroll	:= .T.

If !Empty(cString)
	aSize[5] := aSize[5] * 0.60
	aSize[6] := aSize[6] * 0.80

	DEFINE MSDIALOG oDlg2 TITLE "Log" FROM aSize[7],000 TO aSize[6],aSize[5] PIXEL

	oString := tMultiget():new(0,0,{| u | if( pCount() > 0, cString := u, cString )},oDlg2,0,0,oFont1,Nil,Nil,CLR_BLUE,Nil,.T.,Nil,Nil,Nil,Nil,Nil,Nil,Nil,Nil,Nil,Nil,lScroll)
	oString:Align := CONTROL_ALIGN_ALLCLIENT

	ACTIVATE MSDIALOG oDlg2 CENTERED
EndIf

Return NIL

/*=====================================================================
|---------------------------------------------------------------------|
| Programa | DESCRISX | Autor: Andres Demarziani | Fecha: 15/02/2019  |
|---------------------------------------------------------------------|
======================================================================*/
Static Function fDescDif(cTit, cTitSpa, cTitEng, cNuevo, cNueSpa, cNueEng)

Local lRet 

If mv_par02 == 2
	cTit	:= Lower(cTit)
	cTitSpa	:= Lower(cTitSpa)
	cTitEng	:= Lower(cTitEng)
	cNuevo	:= Lower(cNuevo)
	cNueSpa	:= Lower(cNueSpa)
	cNueEng	:= Lower(cNueEng)
EndIf

Do Case
	Case mv_par01 == 1
		lRet := AllTrim(cTit)!=AllTrim(cNuevo) .Or. AllTrim(cTitSpa)!=AllTrim(cNueSpa) .Or. AllTrim(cTitEng)!=AllTrim(cNueEng)
	Case mv_par01 == 2
		lRet := AllTrim(cTit)!=AllTrim(cNuevo)
	Case mv_par01 == 3
		lRet := AllTrim(cTitSpa)!=AllTrim(cNueSpa)		
	Case mv_par01 == 4
		lRet := AllTrim(cTitEng)!=AllTrim(cNueEng)	
EndCase
						
Return lRet

/*=====================================================================
|---------------------------------------------------------------------|
| Programa | DESCRISX | Autor: Andres Demarziani | Fecha: 15/02/2019  |
|---------------------------------------------------------------------|
======================================================================*/
Static Function AjustaSX1(cPerg)

Local aRegs  := {}, i, j    
Local aArea  := GetArea()

cPerg := PadR(cPerg, 10)

aAdd(aRegs,{cPerg,"01","Tp. Comparacion","Tp. Comparacion","Tp. Comparacion","mv_ch1","N",01,0,0,"C","","MV_PAR01","Todos","Todos","Todos","","","Portugues","Portugues","Portugues","","","Español","Español","Español","","","Inglés","Inglés","Inglés","","","","","","","","",""})
aAdd(aRegs,{cPerg,"02","Cons.Mayúscula?","Cons.Mayúscula?","Cons.Mayúscula?","mv_ch2","N",01,0,0,"C","","MV_PAR02","Si","Si","Si","","","No","No","No","","","","","","","","","","","","","","","","","","",""})

DbSelectArea("SX1")
DbSetOrder(1)

For i:=1 to Len(aRegs)
   If !dbSeek(cPerg+aRegs[i,2])
      RecLock("SX1",.T.)
      For j:=1 to FCount()
         If j <= Len(aRegs[i])
            FieldPut(j,aRegs[i,j])
         Endif
      Next
      MsUnlock()
    Endif
Next

RestArea(aArea)

Return Nil
