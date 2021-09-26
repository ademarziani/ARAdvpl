#INCLUDE 'PROTHEUS.CH'

#define TAMSX3      10
#define EXCEPSX3    "AUTBANCO/AUTAGENCIA/AUTCONTA/AUTMOED/AUTCHEQUE/CBCOAUTO/CAGEAUTO/CCTAAUTO/MOEDAUTO"

/*=====================================================================
|----------------------------------------------------------------------
| Programa | ARBanco | Autor: Andres Demarziani
|----------------------------------------------------------------------
| Descripcion: Clase de Banco.
|----------------------------------------------------------------------
======================================================================*/
CLASS ARMigrador

	DATA cFil
	DATA cCod
	DATA cTipo
	DATA cDescripcion
    DATA cTabCab
    DATA cTabDt1
    DATA cTabDt2
    DATA cObjRut
	DATA cUnico1
	DATA cUnico2
	DATA aUnico1
	DATA aUnico2
	DATA aCposCab
	DATA aCposDt1
	DATA aCposDt2
    DATA aTotCpos
    DATA aTotDetCpos
    DATA aDocumentos
    DATA nRecno

    DATA lExiste
    DATA lOk
    DATA cError

	METHOD New() CONSTRUCTOR
    METHOD setMigrador()
    METHOD ValidaCampos()
    METHOD ValidaCpoSX3()
    METHOD setDocumento()

ENDCLASS

/*=====================================================================
|----------------------------------------------------------------------
| Programa | ARBanco | Autor: Andres Demarziani
|----------------------------------------------------------------------
======================================================================*/
METHOD New(cCod) CLASS ARMigrador	

	Local cAlias := Alias()

	::cCod		    := IIf(cCod==Nil, Space(TamSX3("ZIZ_CODIGO")[1]), cCod)
    ::aTotCpos      := {}
    ::aTotDetCpos   := {}
    ::aDocumentos   := {}

	dbSelectArea("ZIZ")
	dbSetOrder(1)
	If dbSeek(xFilial("ZIZ")+::cCod)
		::setMigrador()
	Else
        ::cUnico1   := {}
        ::cUnico2   := {}
        ::aUnico1   := {}
        ::aUnico2   := {}
	    ::aCposCab  := {}
	    ::aCposDt1  := {}
	    ::aCposDt2  := {}
		::lExiste   := .F.
	EndIf
	
    ::ValidaCampos()

	dbSelectArea(cAlias)
	
RETURN SELF

/*=====================================================================
|----------------------------------------------------------------------
| Programa | ARBanco | Autor: Andres Demarziani
|----------------------------------------------------------------------
======================================================================*/
METHOD setMigrador() CLASS ARMigrador
	
    ::cFil          := ZIZ->ZIZ_FILIAL
	::cCod          := ZIZ->ZIZ_CODIGO
	::cTipo         := ZIZ->ZIZ_TIPO
	::cDescripcion  := ZIZ->ZIZ_DESC
    ::cTabCab       := ZIZ->ZIZ_TABCAB
    ::cTabDt1       := ZIZ->ZIZ_TABDT1
    ::cTabDt2       := ZIZ->ZIZ_TABDT2
    ::cObjRut       := IIf(!Empty(ZIZ->ZIZ_RUTINA), AllTrim(ZIZ->ZIZ_RUTINA), "ARDocumento")
    ::cUnico1       := ZIZ->ZIZ_UNICO
    ::cUnico2       := ZIZ->ZIZ_UNICO2
	::aUnico1       := IIf(!Empty(ZIZ->ZIZ_UNICO), ARMisc():Str2Arr(AllTrim(ZIZ->ZIZ_UNICO), "+"), {})
	::aUnico2       := IIf(!Empty(ZIZ->ZIZ_UNICO2), ARMisc():Str2Arr(AllTrim(ZIZ->ZIZ_UNICO2), "+"), {})
	::aCposCab      := IIf(!Empty(ZIZ->ZIZ_CPOCAB), ARMisc():Str2Arr(AllTrim(ZIZ->ZIZ_CPOCAB), ";"), {})
	::aCposDt1      := IIf(!Empty(ZIZ->ZIZ_CPODT1), ARMisc():Str2Arr(AllTrim(ZIZ->ZIZ_CPODT1), ";"), {})
	::aCposDt2      := IIf(!Empty(ZIZ->ZIZ_CPODT2), ARMisc():Str2Arr(AllTrim(ZIZ->ZIZ_CPODT2), ";"), {})
	::nRecno	    := ZIZ->(Recno())
	::lExiste	    := .T.
	
RETURN Nil

/*=====================================================================
|----------------------------------------------------------------------
| Programa | ARBanco | Autor: Andres Demarziani
|----------------------------------------------------------------------
======================================================================*/
METHOD ValidaCampos() CLASS ARMigrador
	
    Local aArea
    Local aAreaSX3

    ::lOk       := .T.
    ::cError    := ""

    If ::lExiste
        aArea     := GetArea()
        aAreaSX3  := SX3->(GetArea())

        If Empty(::aCposCab)
            ::lOk       := .F.
            ::cError    := "No se informaron campos en el encabezado. Verifique la configuración del formato seleccionado."+CRLF
        EndIf

        If ::cTipo $ "2/3"
            If Empty(::aUnico1)
                ::lOk       := .F.
                ::cError    := "No se informaron campos para determinar la clave única del detalle 1."+CRLF
            EndIf

            If Empty(::aCposDt1)
                ::lOk       := .F.
                ::cError    := "No se informaron campos en el primer detalle. Verifique la configuración del formato seleccionado."+CRLF
            EndIf
        EndIf

        If ::cTipo == "3"
            If Empty(::aUnico2)
                ::lOk       := .F.
                ::cError    := "No se informaron campos para determinar la clave única del detalle 2."+CRLF
            EndIf

            If Empty(::aCposDt2)
                ::lOk       := .F.
                ::cError    := "No se informaron campos en el primer detalle. Verifique la configuración del formato seleccionado."+CRLF
            EndIf            
        EndIf

        dbSelectArea("SX3")
        dbSetOrder(2)

        ::ValidaCpoSX3(::aUnico1, "Clave Unica 1")
        ::ValidaCpoSX3(::aUnico2, "Clave Unica 2")
        ::ValidaCpoSX3(::aCposCab, "Cabecera")
        ::ValidaCpoSX3(::aCposDt1, "Detalle 1")
        ::ValidaCpoSX3(::aCposDt2, "Detalle 2")

        RestArea(aAreaSX3)
        RestArea(aArea)
    Else
        ::lOk       := .F.
        ::cError    := "La configuración informada no existe."
    EndIf
                
RETURN Nil

/*=====================================================================
|---------------------------------------------------------------------|
| Programa | DESCRISX | Autor: Andres Demarziani | Fecha: 15/02/2019  |
|---------------------------------------------------------------------|
======================================================================*/
METHOD ValidaCpoSX3(aCpos, cDescDet, lGral) CLASS ARMigrador

    Local nX
    Local cCpo
    
    For nX := 1 To Len(aCpos)
        cCpo := PadR(aCpos[nX], TAMSX3)

        If AllTrim(cCpo) $ EXCEPSX3 .Or. SX3->(dbSeek(cCpo))
            If aScan(::aTotCpos, {|x| x == cCpo})==0
                aAdd(::aTotCpos, cCpo)
            EndIf   

            aAdd(::aTotDetCpos, {cDescDet, cCpo})
        Else
            ::lOk       := .F.
            ::cError    += "No se encontró el campo '"+cCpo+"' en el diccionario de datos."+CRLF
        EndIf
    Next nX

Return Nil

/*=====================================================================
|---------------------------------------------------------------------|
| Programa | DESCRISX | Autor: Andres Demarziani | Fecha: 15/02/2019  |
|---------------------------------------------------------------------|
======================================================================*/
METHOD setDocumento(oDocumento) CLASS ARMigrador

    aAdd(::aDocumentos, oDocumento)

Return Nil

