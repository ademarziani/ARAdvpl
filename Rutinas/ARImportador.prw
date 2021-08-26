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

    Local oPanel        := ARPanel():New()
    Local aLineas       := {17,83}
    Local aColumnas     := {}

    Local cArch         := Space(100)
    Local oArch

    Local cFormat       := Space(6)
    Local oFormat

    Local bOk           := {|| IIf(MsgYesNo("¿Confirma la carga de datos?"), Processa({|| fCargaDatos(oPanel)}),) }
    Local bCancel       := {|| IIf(MsgYesNo("¿Desea salir del programa?"), oDlg:End(),)}

    Private oMigrador   := ARMigrador():New()

    dbSelectArea("SX3")
    dbSetOrder(2)

    dbSelectArea("ZIZ")
    dbSetOrder(1)

    aAdd(aColumnas, {015,1,"Formato","FORM"})
    aAdd(aColumnas, {070,1,"Archivo","ARC"})
    aAdd(aColumnas, {015,1,"Confirmación","CONF"})

    aAdd(aColumnas, {020,2,"Campos","CPOS"})
    aAdd(aColumnas, {080,2,"Log","LOG"})

    DEFINE MSDIALOG oDlg FROM 000,000 TO nAlto, nAncho TITLE cTitulo PIXEL
	
        oPanel:setPaneles(oDlg, aLineas, aColumnas)

	    @ 004,005 MSGET oFormat VAR cFormat SIZE 50,007 OF oPanel:getPanel("FORM") PIXEL VALID fVldFor(cFormat, oPanel)
        
	    @ 004,005 MSGET oArch VAR cArch SIZE 200,007 OF oPanel:getPanel("ARC") PIXEL WHEN .F.
        TBtnBmp2():New(004,430,026,026,"SDUOPEN",,,, {|| fProcesa(@cArch)}, oPanel:getPanel("ARC"), "Archivo...")
        
		oBtnOk     := SButton():New(004,005, 1, bOk, oPanel:getPanel("CONF"), Nil, Nil, Nil)
		oBtnCancel := SButton():New(004,040, 2, bCancel, oPanel:getPanel("CONF"), Nil, Nil, Nil)	

	ACTIVATE MSDIALOG oDlg CENTERED

Return Nil

/*=====================================================================
|---------------------------------------------------------------------|
| Programa | DESCRISX | Autor: Andres Demarziani | Fecha: 15/02/2019  |
|---------------------------------------------------------------------|
======================================================================*/
Static Function fCargaDatos(oPanel)

    Local nTotDocs      := Len(oMigrador:aDocumentos)
    Local aDocumentos   := oMigrador:aDocumentos
    Local oListaLog
    Local aCab
    Local aDet
    Local nX
	Local oBMPVER       := LoadBitmap( GetResources(), "ENABLE" )
	Local oBMPROJ       := LoadBitmap( GetResources(), "DISABLE" )    

    If nTotDocs > 0
        oListaLog     := ARLista():New("")
        aCab          := {"","Documento","Detalle"}
        aDet          := {}

        For nX := 1 To nTotDocs
            aDocumentos[nX]:guardar()
            aAdd(aDet, {IIf(aDocumentos[nX]:lGrabo, oBMPVER, oBMPROJ), nX, aDocumentos[nX]:cError})
        Next nX

        oListaLog:setArray(aCab, aDet)
        oListaLog:getTwBrowse(oPanel:getPanel("LOG"))
        oListaLog:refreshTwbr()
    EndIf

Return Nil

/*=====================================================================
|---------------------------------------------------------------------|
| Programa | DESCRISX | Autor: Andres Demarziani | Fecha: 15/02/2019  |
|---------------------------------------------------------------------|
======================================================================*/
Static Function fProcesa(cArch)
					
    cPath := cGetFile("Archivo CSV|*.csv",;
                "Seleccione el archivo",;
                Nil,;
                Nil,;
                .F.,;
                GETF_LOCALHARD,;
                .T.)
                
    If !Empty(cPath) .And. File(cPath)
        Processa({|| fCSVDesc(cPath)})
    EndIf

Return Nil

/*=====================================================================
|---------------------------------------------------------------------|
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

    Private oArchivo    := ARArchivo():New() 

    If !oMigrador:lOk
        lRet    := .F.
        cError  := oMigrador:cError
    EndIf

	If lRet .And. (lRet := oArchivo:AbreCSV(cPath, @cError, oMigrador:aTotCpos))
		oMigrador:aDocumentos := {}
        ProcRegua(oArchivo:CantTotLinTxt())	

		While !oArchivo:EOFTxt()
            If oMigrador:cTipo == "1"
                tipo1()
            ElseIf oMigrador:cTipo == "2"
                tipo2()
            ElseIf oMigrador:cTipo == "3"
                tipo3()
            EndIf
		EndDo
	EndIf

    If !lRet .And. !Empty(cError)
		U_FVerLog(cError)
    EndIf
	
Return Nil

/*=====================================================================
|---------------------------------------------------------------------|
| Programa | DESCRISX | Autor: Andres Demarziani | Fecha: 15/02/2019  |
|---------------------------------------------------------------------|
======================================================================*/
Static Function tipo1()

    Local oDocumento := &(oMigrador:cObjRut+"():New()")
    
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
Static Function tipo2()

    Local oDocumento := &(oMigrador:cObjRut+"():New()")
    Local aDet1         := {}
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
Static Function tipo3()

    Local oDocumento := &(oMigrador:cObjRut+"():New()")
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
