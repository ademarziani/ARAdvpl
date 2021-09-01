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

    Reclock(cTabla, .T.)
    For nX := 1 to Len(aStru)
        If aStru[nX,2] != 'M'
            cTmpCpo := Alltrim(aStru[nX][1])

            If (nPos := aScan(aDatos, {|x| x[1] == cTmpCpo})) > 0
                &(cTabla+"->"+cTmpCpo) := aDatos[nPos][2]
            Else
                &(cTabla+"->"+cTmpCpo) := CriaVar(cTmpCpo)
            EndIf
        EndIf
    Next        
    MsUnLock()        

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
                cKey    += IIf(!Empty(cKey), "/", "")+cValToChar(aDatos[nPos][2])
                cWhere  += "AND "+cTmpCpo+" = '"+cValToChar(aDatos[nPos][2])+"' "
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
