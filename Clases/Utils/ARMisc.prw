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
	
END CLASS

/*=========================================================================
=|=======================================================================|=
=|Programa: creaVars     | Autor: Microsiga         | Fecha: 03/05/2019  |=
=|=======================================================================|=
=========================================================================*/
METHOD Str2Arr() CLASS ARMisc

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
	
    Local lRet          := .T.
    Local aArea         := GetArea()
    Local aAreaSX2      := SX2->(GetArea())
	Local aStru
    Local aCpoUniqCab
	Local cTmpCpo
    Local cUnico
    Local nX

	dbSelectArea("SX2")
	dbSetOrder(1)
	If dbSeek(cTabla)
		cUnico	:= AllTrim(X2_UNICO)
    Else
        lRet    := .F.
        cError  += "La tabla informada no existe en el diccionario de datos."+CRLF
    EndIf

	If cUnico <> Nil .And. !Empty(cUnico)
		aCpoUniqCab := ARMisc():Str2Arr(cUnico,"+")

		For nX := 1 To Len(aCpoUniqCab)
            cTmpCpo := AllTrim(aCpoUniqCab[nX])

			If (aScan(aDatos, {|x| AllTrim(x[1]) == cTmpCpo})) == 0
				lRet	:= .F.
				cError	:= "El campo '"+cTmpCpo+"' es necesario para determinar la clave única y no ha sido informado."+CRLF
			EndIf
		Next nX
	EndIf

    If lRet 
        aStru := (cTabla)->(dbStruct())

        Reclock(cTabla, .T.)
        For nI := 1 to Len(aStru)
            If aStru[nI,2] != 'M'
                cTmpCpo := Alltrim(aStru[nI][1])

                If (nPos := aScan(aDatos, {|x| x[1] == cTmpCpo})) > 0
                    &(cTabla+"->"+cTmpCpo) := aDatos[nPos][2]
                Else
                    &(cTabla+"->"+cTmpCpo) := CriaVar(cTmpCpo)
                EndIf
            EndIf
        Next        
        MsUnLock()        
    EndIf

RETURN lRet 
