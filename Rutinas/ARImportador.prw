#include "protheus.ch"

/*=====================================================================
|---------------------------------------------------------------------|
| Programa | ARImportador | Autor: Demarziani | Fecha: 29/04/2021     |
|---------------------------------------------------------------------|
| Descripcion: Programa Principal para importación de movimientos.    |
|---------------------------------------------------------------------|
======================================================================*/
User Function ARImportador()

    Local oDlg
    Local cTitulo       := "Importador"
	Local aSize		    := MsAdvSize()
	Local nAlto		    := aSize[6] * 0.85
	Local nAncho	    := aSize[5] * 0.90
    Local aButtons      := {}

    Local oPanel        := ARPanel():New()
    Local aLineas       := {}
    Local aColumnas     := {}

    Local cArch         := Space(100)
    Local oArch

    Local cFormat       := Space(6)
    Local oFormat

    Local bOk           := {|| IIf(MsgYesNo("¿Confirma la carga de datos?", "Confirme"), Processa({|| fCargaDatos(oPanel, cFormat)}),) }
    Local bCancel       := {|| IIf(MsgYesNo("¿Desea salir del programa?", "Confirme"), oDlg:End(),)}

    Private oMigrador   := ARMigrador():New()
    Private oGDLog

    dbSelectArea("SX3")
    dbSetOrder(2)

    dbSelectArea("ZIZ")
    dbSetOrder(1)

    aAdd(aLineas, 18)   // Linea 1
    aAdd(aLineas, 77)   // Linea 2

    aAdd(aColumnas, {15,1,"Formato","FORM"})
    aAdd(aColumnas, {85,1,"Archivo","ARC"})

    aAdd(aColumnas, {20,2,"Campos","CPOS"})
    aAdd(aColumnas, {80,2,"Log","LOG"})

    aAdd(aButtons, {"RELATORIO", {|| U_ARImp001() }, "Config.Mig"})
    aAdd(aButtons, {"RELATORIO", {|| Processa({|lFin| fVerLogs(@lFin, cFormat) }, "Cargando Logs",,.T.)}, "Ver Logs"})
    aAdd(aButtons, {"EXCEL", {|| Processa({|lFin| fExpExcel(@lFin, cFormat) }, "Bajando a Excel...",,.T.)}, "Log a Excel"})

    DEFINE MSDIALOG oDlg FROM 000,000 TO nAlto, nAncho TITLE cTitulo PIXEL
	
        oPanel:setPaneles(oDlg, aLineas, aColumnas)

	    @ 004,005 MSGET oFormat VAR cFormat SIZE 50,007 OF oPanel:getPanel("FORM") PIXEL VALID fVldFor(cFormat, oPanel) F3 "ZIZ"
        
	    @ 004,005 MSGET oArch VAR cArch SIZE 200,007 OF oPanel:getPanel("ARC") PIXEL WHEN .F.
        TBtnBmp2():New(004,430,026,026,"SDUOPEN",,,, {|| fProcesa(@oArch, @cArch)}, oPanel:getPanel("ARC"), "Archivo...")
        
	ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg, bOK, bCancel,, aButtons) CENTERED

Return Nil

/*=====================================================================
|---------------------------------------------------------------------|
| Programa | DESCRISX | Autor: Andres Demarziani | Fecha: 15/02/2019  |
|---------------------------------------------------------------------|
======================================================================*/
Static Function fCargaDatos(oPanel, cFormat)

    Local nTotDocs      := Len(oMigrador:aDocumentos)
    Local aDocumentos   := oMigrador:aDocumentos
    Local aDet          := {}
    Local nTamLog       := TamSX3("ZIY_LOGBRE")[1]
    Local cTimeSt       := DToS(MsDate())+"_"+StrTran(Time(),":","")
    Local cLog
    Local nX

    ProcRegua(nTotDocs)	

    If nTotDocs > 0        
        For nX := 1 To nTotDocs
            If aDocumentos[nX]:validar()
                aDocumentos[nX]:guardar()
            EndIf

            cLog := IIf(aDocumentos[nX]:lGrabo, "Ok", aDocumentos[nX]:cError)

            aAdd(aDet, {cFormat,;
                    cTimeSt,;
                    __cUserId,;
                    aDocumentos[nX]:cKeyCab,;
                    Left(cLog, nTamLog),; 
                    cLog,;
                    .F.})
            
            IncProc("Procesando "+cValToChar(nX)+" de "+cValToChar(nTotDocs)+" documentos.")
        Next nX

        oGDLog := ArGetDados():New("")
        oGDLog:setTabla("ZIY")
        oGDLog:setCols(aDet)
        oGDLog:aAlter := {"ZIY_DOCUME","ZIY_LOG"}
        oGDLog:getGetDados(oPanel:getPanel("LOG"))
        oGDLog:grabaDatosTabla(.F.)
    EndIf

Return Nil

/*=====================================================================
|---------------------------------------------------------------------|
| Programa | DESCRISX | Autor: Andres Demarziani | Fecha: 15/02/2019  |
|---------------------------------------------------------------------|
======================================================================*/
Static Function fProcesa(oArch, cArch)

    Local lRet  := .T.			
    Local cPath := cGetFile("Archivo CSV|*.csv",;
                "Seleccione el archivo",;
                Nil,;
                Nil,;
                .F.,;
                GETF_LOCALHARD,;
                .T.)
                
    If !Empty(cPath) .And. File(cPath)
        Processa({|| (lRet := fCSVDesc(cPath))})

        If lRet 
            cArch := cPath
            oArch:Refresh()

            MsgInfo("El archivo se procesó correctamente. Para comenzar la migración de los documentos, por favor confirme los cambios.", "Verifique")
        EndIf
    EndIf

Return Nil

/*=====================================================================
|--------------------------------------------------------------- ------|
| Programa | DESCRISX | Autor: Andres Demarziani | Fecha: 15/02/2019  |
|---------------------------------------------------------------------|
======================================================================*/
Static Function fVldFor(cFormat, oPanel)
					
    Local oListaCpos    := ARLista():New("")
    Local aCab          := {"Tipo","Campos"}
    Local aDet          := {{"",""}}
    Local lRet          := .T.

    oMigrador := ARMigrador():New(cFormat)

    If oMigrador:lOk
        aDet := aClone(oMigrador:aTotDetCpos)
    Else     
        U_FVerLog(oMigrador:cError)
    EndIf

    oListaCpos:setArray(aCab, aDet)
    oListaCpos:getTwBrowse(oPanel:getPanel("CPOS"))
    oListaCpos:refreshTwbr()

Return lRet

/*=====================================================================
|---------------------------------------------------------------------|
| Programa | DESCRISX | Autor: Andres Demarziani | Fecha: 15/02/2019  |
|---------------------------------------------------------------------|
======================================================================*/
Static Function fCSVDesc(cPath)

    Local lRet          := .T.
    Local cError        := ""
    Local oDocumento

    Private oArchivo    := ARArchiv2():New() 

    If !oMigrador:lOk
        lRet    := .F.
        cError  := oMigrador:cError
    EndIf

	If lRet .And. (lRet := oArchivo:AbreCSV(cPath, @cError, oMigrador:aTotCpos))
		oMigrador:aDocumentos := {}
        ProcRegua(oArchivo:CantTotLinTxt())	

		While !oArchivo:EOFTxt()
            oDocumento := &(oMigrador:cObjRut+"():New()")
            oDocumento:setTipo(oMigrador:cTipo)
            oDocumento:setTablas(oMigrador:cTabCab, oMigrador:cTabDt1, oMigrador:cTabDt2)
            oDocumento:setClaveUnica(oMigrador:cUnico1, oMigrador:cUnico2)

            If oMigrador:cTipo == "1"
                tipo1(@oDocumento)
            ElseIf oMigrador:cTipo == "2"
                tipo2(@oDocumento)
            ElseIf oMigrador:cTipo == "3"
                tipo3(@oDocumento)
            EndIf
		EndDo
	EndIf

    If !lRet .And. !Empty(cError)
		U_FVerLog(cError)
    EndIf
	
Return lRet

/*=====================================================================
|---------------------------------------------------------------------|
| Programa | DESCRISX | Autor: Andres Demarziani | Fecha: 15/02/2019  |
|---------------------------------------------------------------------|
======================================================================*/
Static Function tipo1(oDocumento)

    //------------
    // Encabezado
    //------------
    oDocumento:setEncabezado(arrayDoc(oMigrador:aCposCab))
    oMigrador:setDocumento(oDocumento)

    skipLin()

Return Nil

/*=====================================================================
|---------------------------------------------------------------------|
| Programa | DESCRISX | Autor: Andres Demarziani | Fecha: 15/02/2019  |
|---------------------------------------------------------------------|
======================================================================*/
Static Function tipo2(oDocumento)

    Local aDet1      := {}
    Local cClave1

    //------------
    // Encabezado
    //------------
    oDocumento:setEncabezado(arrayDoc(oMigrador:aCposCab))

    cClave1 := getClave(oMigrador:aUnico1)
    While !oArchivo:EOFTxt() .And. cClave1 == getClave(oMigrador:aUnico1)
        //------------
        // Detalle 1
        //------------
        aAdd(aDet1, arrayDoc(oMigrador:aCposDt1))

        skipLin()
    EndDo

    oDocumento:setDet1(aDet1)
    oMigrador:setDocumento(oDocumento)

Return Nil

/*=====================================================================
|---------------------------------------------------------------------|
| Programa | DESCRISX | Autor: Andres Demarziani | Fecha: 15/02/2019  |
|---------------------------------------------------------------------|
======================================================================*/
Static Function tipo3(oDocumento)

    Local aDet1         := {}
    Local aDet2         := {}
    Local cClave1
    Local cClave2
    
    //------------
    // Encabezado
    //------------
    oDocumento:setEncabezado(arrayDoc(oMigrador:aCposCab))

    cClave1 := getClave(oMigrador:aUnico1)
    While !oArchivo:EOFTxt() .And. cClave1 == getClave(oMigrador:aUnico1)
        //------------
        // Detalle 1
        //------------
        aAdd(aDet1, arrayDoc(oMigrador:aCposDt1))

        cClave2 := getClave(oMigrador:aUnico2)
        While !oArchivo:EOFTxt() .And.;
            cClave1 == getClave(oMigrador:aUnico1) .And.;
            cClave2 == getClave(oMigrador:aUnico2)

            //------------
            // Detalle 2
            //------------
            aAdd(aDet2, arrayDoc(oMigrador:aCposDt2))

            skipLin()            
        EndDo
    EndDo

    oDocumento:setDet1(aDet1)
    oDocumento:setDet2(aDet2)
    oMigrador:setDocumento(oDocumento)

Return Nil

/*=====================================================================
|---------------------------------------------------------------------|
| Programa | DESCRISX | Autor: Andres Demarziani | Fecha: 15/02/2019  |
|---------------------------------------------------------------------|
======================================================================*/
Static Function getClave(aUnico)

    Local cRet := ""
    Local nX

    For nX := 1 To Len(aUnico)
        cRet += cValToChar(oArchivo:DatoCSV(aUnico[nX]))
    Next nX

Return cRet

/*=====================================================================
|---------------------------------------------------------------------|
| Programa | DESCRISX | Autor: Andres Demarziani | Fecha: 15/02/2019  |
|---------------------------------------------------------------------|
======================================================================*/
Static Function skipLin()

    oArchivo:AvLinTxt() 
	IncProc()

Return Nil

/*=====================================================================
|---------------------------------------------------------------------|
| Programa | DESCRISX | Autor: Andres Demarziani | Fecha: 15/02/2019  |
|---------------------------------------------------------------------|
======================================================================*/
Static Function arrayDoc(aCpos)
    
    Local nX
    Local aRet := {} 

    For nX := 1 To Len(aCpos)
        aAdd(aRet, {aCpos[nX], oArchivo:DatoCSV(aCpos[nX]), Nil})
    Next nX

Return aRet

/*=====================================================================
|---------------------------------------------------------------------|
| Programa | fExpExcel | Autor: Andres Demarziani | Fecha: 15/02/2019 |
|---------------------------------------------------------------------|
======================================================================*/
Static Function fExpExcel(lFin, cFormat)

    Local cTitArc   := "importador_"+cFormat+"_log"

    If ValType(oGDLog)=="O"        
        U_FGenXML(@lFin, cTitArc, GetTempPath(), cTitArc+".xml", .T., oGDLog:aHeader, oGDLog:oGetDados:aCols, {}, "Log")
    EndIf

Return Nil

/*=====================================================================
|---------------------------------------------------------------------|
| Programa | fExpExcel | Autor: Andres Demarziani | Fecha: 15/02/2019 |
|---------------------------------------------------------------------|
======================================================================*/
Static Function fVerLogs(lFin, cFormat)

    Private cForMig := cFormat

    U_ESP00001()

Return Nil

/*=====================================================================
|---------------------------------------------------------------------|
| Programa | fExpExcel | Autor: Andres Demarziani | Fecha: 15/02/2019 |
|---------------------------------------------------------------------|
======================================================================*/
User Function ARImp001()

    AxCadastro("ZIZ","Configurador Migrador")

Return Nil
