#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'RWMAKE.CH'
	
/*=====================================================================
|---------------------------------------------------------------------|
| Programa | ARDocumento | Autor: Demarziani | Fecha: 19/12/2021      |
|---------------------------------------------------------------------|
| Descripcion: Clase de documento general.                            |
|---------------------------------------------------------------------|
======================================================================*/
CLASS ARDocumento

	DATA aCab
	DATA aDet1
	DATA aDet2
	DATA lGrabo
	DATA cError

	DATA cTipo
	DATA cTabCab
	DATA cTabDet1
	DATA cTabDet2
	DATA cUniqCab
	DATA cUniqDet1
	DATA cUniqDet2
	
	METHOD New() CONSTRUCTOR

	METHOD setTablas()
	METHOD setEncabezado()
	METHOD setDet1()
	METHOD setDet2()

	METHOD setValEncab()
	METHOD getValEncab()

	METHOD setVDt1()
	METHOD getVDt1()

	METHOD setVDt2()
	METHOD getVDt2()
	
	METHOD guardar()
	METHOD borrar()

ENDCLASS

/*=====================================================================
|---------------------------------------------------------------------|
| Programa | ARDocumento | Autor: Demarziani | Fecha: 19/12/2021      |
|---------------------------------------------------------------------|
======================================================================*/
METHOD New(cTipo) CLASS ARDocumento
	
	::cTipo		:= cTipo
	::aCab		:= {}
	::aDet1		:= {}
	::aDet2		:= {}

	::lGrabo	:= .F.
	::cError	:= ""
	
RETURN SELF

/*=====================================================================
|---------------------------------------------------------------------|
| Programa | ARDocumento | Autor: Demarziani | Fecha: 19/12/2021      |
|---------------------------------------------------------------------|
======================================================================*/
METHOD setTablas(cTabCab, cTabDet1, cTabDet2) CLASS ARDocumento

	::cTabCab 	:= cTabCab	
	
	If ::cTipo == "2"
		::cTabDet1	:= cTabDet1
	ElseIf ::cTipo == "3"
		::cTabDet1 	:= cTabDet1
		::cTabDet2 	:= cTabDet2
	EndIf
	
RETURN Nil

/*=====================================================================
|---------------------------------------------------------------------|
| Programa | ARDocumento | Autor: Demarziani | Fecha: 19/12/2021      |
|---------------------------------------------------------------------|
======================================================================*/
METHOD setEncabezado(aCab) CLASS ARDocumento
	
	::aCab := aCab
	
RETURN Nil

/*=====================================================================
|---------------------------------------------------------------------|
| Programa | ARDocumento | Autor: Demarziani | Fecha: 19/12/2021      |
|---------------------------------------------------------------------|
======================================================================*/
METHOD setDet1(aDet1) CLASS ARDocumento

	::aDet1 := aDet1

RETURN Nil

/*=====================================================================
|---------------------------------------------------------------------|
| Programa | ARDocumento | Autor: Demarziani | Fecha: 19/12/2021      |
|---------------------------------------------------------------------|
======================================================================*/
METHOD setDet2(aDet2) CLASS ARDocumento

	::aDet2 := aDet2

RETURN Nil

/*=====================================================================
|---------------------------------------------------------------------|
| Programa | ARDocumento | Autor: Demarziani | Fecha: 19/12/2021      |
|---------------------------------------------------------------------|
======================================================================*/
METHOD setValEncab(cCampo, xVal) CLASS ARDocumento

	Local nPos := aScan(::aCab, {|x| x[1] == cCampo})
	
	If nPos > 0
		::aCab[nPos][2] := xVal
	Else
		aAdd(::aCab, {cCampo, xVal, Nil})
	EndIf

Return Nil

/*=====================================================================
|---------------------------------------------------------------------|
| Programa | ARDocumento | Autor: Demarziani | Fecha: 19/12/2021      |
|---------------------------------------------------------------------|
======================================================================*/
METHOD getValEncab(cCampo) CLASS ARDocumento

	Local nPos := aScan(::aCab, {|x| x[1] == cCampo})
	Local xRet := 0
	
	If nPos > 0
		xRet := ::aCab[nPos][2]
	EndIf

Return xRet

/*=====================================================================
|---------------------------------------------------------------------|
| Programa | ARDocumento | Autor: Demarziani | Fecha: 19/12/2021      |
|---------------------------------------------------------------------|
======================================================================*/
METHOD setVDt1(cCampo, xVal, nItem) CLASS ARDocumento

	Local nPos
	
	nItem	:= IIf(nItem==Nil, Len(::aDet1), nItem)	
	nPos	:= aScan(::aDet1[nItem], {|x| x[1] == cCampo})
	
	If nPos > 0
		::aDet1[nItem][nPos][2] := xVal
	Else
		aAdd(::aDet1[nItem], {cCampo, xVal, Nil})
	EndIf

Return Nil

/*=====================================================================
|---------------------------------------------------------------------|
| Programa | ARDocumento | Autor: Demarziani | Fecha: 19/12/2021      |
|---------------------------------------------------------------------|
======================================================================*/
METHOD getVDt1(cCampo, nItem) CLASS ARDocumento

	Local xRet := 0
	Local nPos
	
	nItem	:= IIf(nItem==Nil, Len(::aDet1), nItem)	
	nPos	:= aScan(::aDet1[nItem], {|x| x[1] == cCampo})
	
	If nPos > 0
		xRet := ::aDet1[nItem][nPos][2]
	EndIf

Return xRet

/*=====================================================================
|---------------------------------------------------------------------|
| Programa | ARDocumento | Autor: Demarziani | Fecha: 19/12/2021      |
|---------------------------------------------------------------------|
======================================================================*/
METHOD setVDt2(cCampo, xVal, nItem) CLASS ARDocumento

	Local nPos
	
	nItem	:= IIf(nItem==Nil, Len(::aDet2), nItem)	
	nPos	:= aScan(::aDet2[nItem], {|x| x[1] == cCampo})
	
	If nPos > 0
		::aDet2[nItem][nPos][2] := xVal
	Else
		aAdd(::aDet2[nItem], {cCampo, xVal, Nil})
	EndIf

Return Nil

/*=====================================================================
|---------------------------------------------------------------------|
| Programa | ARDocumento | Autor: Demarziani | Fecha: 19/12/2021      |
|---------------------------------------------------------------------|
======================================================================*/
METHOD getVDt2(cCampo, nItem) CLASS ARDocumento

	Local xRet := 0
	Local nPos
	
	nItem	:= IIf(nItem==Nil, Len(::aDet2), nItem)	
	nPos	:= aScan(::aDet2[nItem], {|x| x[1] == cCampo})
	
	If nPos > 0
		xRet := ::aDet2[nItem][nPos][2]
	EndIf

Return xRet

/*=====================================================================
|---------------------------------------------------------------------|
| Programa | ARDocumento | Autor: Demarziani | Fecha: 19/12/2021      |
|---------------------------------------------------------------------|
======================================================================*/
METHOD guardar() CLASS ARDocumento

	Local nX
	
	::lGrabo := ARMisc():InsertReg(::cTabCab, ::aCab, @::cError)

	If ::lGrabo .And. ::cTipo $ "2/3"
		For nX := 1 To Len(::aDet1)
			::lGrabo := ARMisc():InsertReg(::cTabDet1, ::aDet1[nX], @::cError)

			If !::lGrabo
				Exit
			EndIf
		Next

		If ::lGrabo .And. ::cTipo == "3"
			For nX := 1 To Len(::aDet2)
				::lGrabo := ARMisc():InsertReg(::cTabDet2, ::aDet2[nX], @::cError)

				If !::lGrabo
					Exit
				EndIf
			Next
		EndIf
	EndIf

RETURN Nil 

/*=====================================================================
|---------------------------------------------------------------------|
| Programa | ARDocumento | Autor: Demarziani | Fecha: 19/12/2021      |
|---------------------------------------------------------------------|
======================================================================*/
METHOD borrar() CLASS ARDocumento
	
RETURN Nil 
