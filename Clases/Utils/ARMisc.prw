#include "Protheus.ch"
#include "Topconn.ch"

/*=====================================================================
|---------------------------------------------------------------------|
| Programa | DSFILTRO | Autor: Andres Demarziani | Fecha: 03/02/2020  |
|---------------------------------------------------------------------|
| Descripcion: Clase de Para Filtro por sucursal y usuario            |
|---------------------------------------------------------------------|
| Cliente: DESAB                                                      |
|---------------------------------------------------------------------|
======================================================================*/
CLASS ARMisc

	STATIC METHOD Str2Arr()
    STATIC METHOD InsertReg()
    STATIC METHOD ValidReg()
    STATIC METHOD ValToQry()
    STATIC METHOD EnviaEMail()
	
END CLASS

/*=========================================================================
=|=======================================================================|=
=|Programa: creaVars     | Autor: Microsiga         | Fecha: 03/05/2019  |=
=|=======================================================================|=
=========================================================================*/
METHOD Str2Arr(cString, cSep) CLASS ARMisc

    Local aReturn := { },;
        cAux    := cString,;
        nPos    := 0,;
        nX

    While At( cSep, cAux ) > 0
        nPos  := At( cSep, cAux )
        cVal  := SubStr( cAux, 1, nPos-1 )
        Aadd( aReturn,  cVal )
        cAux  := SubStr( cAux, nPos+1 )
    EndDo

    Aadd( aReturn, cAux )

    For nX := 1 To Len( aReturn )
        aReturn[nX] := StrTran( aReturn[nX], '"', '' )
    Next

Return aReturn

/*=====================================================================
|---------------------------------------------------------------------|
| Programa | insertTabla | Autor: Demarziani | Fecha: 19/12/2021      |
|---------------------------------------------------------------------|
======================================================================*/
METHOD InsertReg(cTabla, aDatos, cError) CLASS ARMisc
	
    Local lRet      := .T.
	Local cTmpCpo
    Local nPos
    Local nX
	Local aStru

    aStru := (cTabla)->(dbStruct())

    bError	:= ErrorBlock({|e| fChecErro(e, @cError)})

    Reclock(cTabla, .T.)
    For nX := 1 to Len(aStru)
        If aStru[nX,2] != 'M'
            cTmpCpo := Alltrim(aStru[nX][1])

            BEGIN SEQUENCE

                If (nPos := aScan(aDatos, {|x| x[1] == cTmpCpo})) > 0
                    &(cTabla+"->"+cTmpCpo) := aDatos[nPos][2]
                Else
                    &(cTabla+"->"+cTmpCpo) := CriaVar(cTmpCpo)
                EndIf                

			END SEQUENCE
        EndIf
    Next        
    MsUnLock()        

    ErrorBlock(bError)

    If !Empty(cError)
        lRet := .F.
    EndIf
    
RETURN lRet 

/*=====================================================================
|---------------------------------------------------------------------|
| Programa | insertTabla | Autor: Demarziani | Fecha: 19/12/2021      |
|---------------------------------------------------------------------|
======================================================================*/
METHOD ValidReg(cTabla, cUnico, aDatos, cError, cKey) CLASS ARMisc

    Local lRet          := .T.
    Local aArea         := GetArea()
    Local aAreaSX2      := SX2->(GetArea())
    Local cQuery        := ""
    Local cWhere        := ""    
    Local aCpoUniqCab
    Local cUnico
    Local cTmpCpo
    Local nPos
    Local nX

    dbSelectArea("SX2")
	dbSetOrder(1)
	If dbSeek(cTabla)
        If cUnico == Nil .Or. Empty(cUnico)
		    cUnico	:= AllTrim(X2_UNICO)
        Else
            cUnico  := AllTrim(cUnico)
        EndIf
    Else
        lRet    := .F.
        cError  += "La tabla informada no existe en el diccionario de datos."+CRLF
    EndIf

	If cUnico <> Nil .And. !Empty(cUnico)
		aCpoUniqCab := ARMisc():Str2Arr(cUnico,"+")
        cKey        := ""

		For nX := 1 To Len(aCpoUniqCab)
            cTmpCpo := AllTrim(aCpoUniqCab[nX])

			If (nPos := aScan(aDatos, {|x| AllTrim(x[1]) == cTmpCpo})) == 0
				lRet	:= .F.
				cError	:= "El campo '"+cTmpCpo+"' es necesario para determinar la clave única y no ha sido informado."+CRLF
			Else
                cKey    += IIf(!Empty(cKey), " | ", "")+cValToChar(aDatos[nPos][2])
                cWhere  += "AND "+cTmpCpo+" = '"+ARMisc():ValToQry(aDatos[nPos][2])+"' "
            EndIf
		Next nX

        If lRet
            cQuery := "SELECT COUNT(*) AS CANTREG "
            cQuery += "FROM "+RetSqlName(cTabla)+" "
            cQuery += "WHERE D_E_L_E_T_ <> '*' "
            cQuery += cWhere

            TcQuery cQuery New Alias "TMPTAB"

            If !TMPTAB->(Eof()) .And. CANTREG > 0
                lRet	:= .F.
                cError	:= "Ya existe 1 registro en la base de datos con la clave única. (Clave única: "+cUnico+")"+CRLF
            EndIf

            TMPTAB->(dbCloseArea())
        EndIf        
	EndIf
    
    RestArea(aAreaSX2)
    RestArea(aArea)

Return lRet


/*=====================================================================
|---------------------------------------------------------------------|
| Programa | insertTabla | Autor: Demarziani | Fecha: 19/12/2021      |
|---------------------------------------------------------------------|
======================================================================*/
METHOD ValToQry(xVal) CLASS ARMisc
Return IIf(ValType(xVal)=="D", DToS(xVal), cValToChar(xVal))

/*=====================================================================
|---------------------------------------------------------------------|
| Programa | fChecErro | Autor: Andres Demarziani | Fecha: 18/12/2019 |
|---------------------------------------------------------------------|
======================================================================*/
Static Function fChecErro(e, cError)

	cError := e:ErrorStack

	BREAK

Return Nil


#include "Protheus.ch"

/*=====================================================================
|---------------------------------------------------------------------|
| Programa | INFEMAIL | Autor: Andres Demarziani | Fecha: 18/12/2019  |
|---------------------------------------------------------------------|
======================================================================*/
METHOD EnviaEMail(cTo, cAssunto, cMensagem, aArquivos, cCC, cBCC, cMailConta, cMailSenha, cMailServer, nPort) CLASS ARMisc

    Local nArq
	Local oServer
    Local oMessage
	Local cMsg 		:= ""
	Local xRet      := 0
	Local lMailAuth	:= .F.
				
	Default aArquivos := {}

	cMailConta 	:= IIf(cMailConta == Nil, GetNewPar("MS_RELACNT", ""), cMailConta)                      // Conta utilizada para envio do email
	cMailSenha 	:= IIf(cMailSenha == Nil, GetNewPar("MS_RELPSW", ""), cMailSenha)                       // Senha da conta de e-mail utilizada para envio
	cMailServer	:= IIf(cMailServer == Nil, GetNewPar("MS_RELSERV","smtp.gmail.com"), cMailServer)       // Servidor SMTP
	nPort	    := IIf(nPort == Nil, GetNewPar("MS_RELPORT", 465), nPort)                               // Puerta de salida
	
   	oMessage:= TMailMessage():New()
	oMessage:Clear()
   
	oMessage:cDate	    := cValToChar(Date())
	oMessage:cFrom 	    := cMailConta
	oMessage:cTo 	    := cTo
	oMessage:cSubject   := cAssunto
	oMessage:cBody 	    := cMensagem

	If cCC <> Nil .And. !Empty(cCC)
		oMessage:cCC := cCC
	EndIf
	
	If cBCC <> Nil .And. !Empty(cBCC)
		oMessage:cBCC := cBCC
	EndIf

	If Len(aArquivos) > 0
		For nArq := 1 To Len(aArquivos)
			xRet := oMessage:AttachFile(aArquivos[nArq])
			If xRet != 0
				cMsg := "El archivo " + aArquivos[nArq] + " no se adjunto."
			EndIf
		Next nArq
	EndIf		

	If xRet == 0
        oServer := TMailManager():New()
        
        If nPort == 465
            lMailAuth := .T.
            oServer:SetUseSSL(.T.)
        ElseIf nPort = 587
            lMailAuth := .T.
            oServer:SetUseTLS(.T.)
        EndIf

		xRet := oServer:Init("", cMailServer, cMailConta, cMailSenha, 0, nPort) //inicilizar o servidor
		If xRet != 0
			cMsg := "El servidor SMTP no pudo inicializarse: " + oServer:GetErrorString( xRet )
		EndIf
	EndIf
   
	If xRet == 0
		xRet := oServer:SetSMTPTimeout(40) //Indica o tempo de espera em segundos.
		If xRet != 0
			cMsg := "No fue posible definir el tiempo limite para " + cValToChar( nTimeout )
		EndIf
	EndIf

	If xRet == 0
		xRet := oServer:SMTPConnect()
		If xRet != 0
			cMsg := "No fue posible conectar al servidor SMTP: " + oServer:GetErrorString( xRet )
		EndIf
	EndIf
   
	If xRet == 0 .And. lMailAuth
		xRet := oServer:SmtpAuth(cMailConta, cMailSenha)
		If xRet != 0
			cMsg := "Could not authenticate on SMTP server: " + oServer:GetErrorString( xRet )
			oServer:SMTPDisconnect()
		EndIf
   	EndIf
	
	If xRet == 0
		xRet := oMessage:Send( oServer )
		If xRet != 0
			cMsg := "No fue posible enviar el correo: " + oServer:GetErrorString( xRet )
		EndIf
	EndIf
	
	If xRet == 0
		xRet := oServer:SMTPDisconnect()
		If xRet != 0
			cMsg := "No fue posible desconectar al servidor SMTP: " + oServer:GetErrorString( xRet )
		EndIf
	EndIf
	
Return {xRet == 0, cMsg}
