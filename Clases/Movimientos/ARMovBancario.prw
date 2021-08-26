#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'RWMAKE.CH'
	
/*=====================================================================
|---------------------------------------------------------------------|
| Programa | DSMOVBCO | Autor: Andres Demarziani | Fecha: 20/12/2019  |
|---------------------------------------------------------------------|
| Descripcion: Movimiento bancario.                                   |
|---------------------------------------------------------------------|
======================================================================*/
CLASS DSMOVBCO
		
	DATA aCab
	
	DATA cFil
	DATA oBanco	
	DATA cRecPag
	DATA nValor	
	DATA dFecha
	DATA cNaturez
	DATA oCliFor
	DATA nRecno
	
	DATA cError
	DATA lGrabo
		
	METHOD New() CONSTRUCTOR
	METHOD setEncabezado()
	METHOD setValEncab()
	METHOD getValEncab()
	
	METHOD guardar()
	METHOD borrar()

ENDCLASS

/*=====================================================================
|---------------------------------------------------------------------|
| Programa | DSMOVBCO | Autor: Andres Demarziani | Fecha: 20/12/2019  |
|---------------------------------------------------------------------|
======================================================================*/
METHOD New(oBanco, cRecPag, nValor, dFecha, cNaturez, oCliFor, nRecno) CLASS DSMOVBCO

	::cFil 		:= xFilial("SE5")
	::oBanco	:= oBanco
	::cRecPag	:= cRecPag
	::nValor	:= nValor
	::dFecha	:= dFecha
	::cNaturez	:= cNaturez
	::oCliFor	:= oCliFor
	::nRecno	:= IIf(nRecno!=Nil, nRecno, 0)
	
	::setEncabezado()
	
	If ::nRecno <> 0
		SE5->(dbGoTo(::nRecno))
	EndIf
	
	::cError	:= ""
	::lGrabo	:= .F.
	
RETURN SELF

/*=====================================================================
|---------------------------------------------------------------------|
| Programa | DSMOVBCO | Autor: Andres Demarziani | Fecha: 20/12/2019  |
|---------------------------------------------------------------------|
======================================================================*/
METHOD setEncabezado() CLASS DSMOVBCO

	::aCab := {	{"E5_FILIAL",::cFil, Nil},;
				{"E5_DATA", ::dFecha, Nil},;
				{"E5_MOEDA", StrZero(::oBanco:nMoneda, 2), Nil},;				
				{"E5_NATUREZ",::cNaturez , Nil},;
				{"E5_VALOR", ::nValor, Nil},;
				{"E5_BANCO", ::oBanco:cCod, Nil},;
				{"E5_AGENCIA", ::oBanco:cAgencia, Nil},;
				{"E5_CONTA", ::oBanco:cCuenta, Nil},;
				{"E5_TERCEIR", "1", Nil},;
				{"E5_TIPOMOV","02", Nil}}

	If SE5->(FieldPos("E5_RG104")) > 0
		aAdd(::aCab, {"E5_RG104", "N", Nil})
	EndIf

	If ::oCliFor <> Nil
		aAdd(::aCab, {"E5_CLIFOR", ::oCliFor:cCod, Nil})
		aAdd(::aCab, {"E5_LOJA", ::oCliFor:cLoja, Nil})
		aAdd(::aCab, {"E5_BENEF", ::oCliFor:cNombre, Nil})
	EndIf

	If ::cRecPag == "P"
		aAdd(::aCab, {"E5_CREDITO", ::oBanco:cCtaCont, Nil})	
	Else
		aAdd(::aCab, {"E5_DEBITO", ::oBanco:cCtaCont, Nil})
	EndIf

RETURN Nil

/*=====================================================================
|---------------------------------------------------------------------|
| Programa | DSMOVBCO | Autor: Andres Demarziani | Fecha: 20/12/2019  |
|---------------------------------------------------------------------|
======================================================================*/
METHOD setValEncab(cCampo, xVal) CLASS DSMOVBCO

	Local nPos := aScan(::aCab, {|x| x[1] == cCampo})
	
	If nPos > 0
		::aCab[nPos][2] := xVal
	Else
		aAdd(::aCab, {cCampo, xVal, Nil})
	EndIf

Return Nil

/*=====================================================================
|---------------------------------------------------------------------|
| Programa | DSMOVBCO | Autor: Andres Demarziani | Fecha: 20/12/2019  |
|---------------------------------------------------------------------|
======================================================================*/
METHOD getValEncab(cCampo) CLASS DSMOVBCO

	Local nPos := aScan(::aCab, {|x| x[1] == cCampo})
	Local xRet := 0
	
	If nPos > 0
		xRet := ::aCab[nPos][2]
	EndIf

Return xRet

/*=====================================================================
|---------------------------------------------------------------------|
| Programa | DSMOVBCO | Autor: Andres Demarziani | Fecha: 20/12/2019  |
|---------------------------------------------------------------------|
======================================================================*/
METHOD guardar() CLASS DSMOVBCO

	Local cFunBkp 	:= FunName()
	Local nTipo		:= IIf(::cRecPag == "P", 3, 4)

	Private lMsErroAuto := .F.

	SetFunName("FINA100")

	MSExecAuto({|x,y,z| Fina100(x,y,z)}, 0, ::aCab, nTipo)
	
	If lMsErroAuto
		::cError := MostraErro("MOVBCO")
	Else
		::lGrabo := .T.
	EndIf
	
	SetFunName(cFunBkp)
	
RETURN Nil

/*=====================================================================
|---------------------------------------------------------------------|
| Programa | DSMOVBCO | Autor: Andres Demarziani | Fecha: 20/12/2019  |
|---------------------------------------------------------------------|
======================================================================*/
METHOD borrar() CLASS DSMOVBCO

	Private lMsErroAuto := .F.

	MSExecAuto({|x,y,z| Fina100(x,y,z)}, 0, ::aCab, 5)

	If lMsErroAuto
		::cError := MostraErro("MOVBCO")
		::lGrabo := .F.
	ElseIf ::nRecno <> 0
		SE5->(dbGoTo(::nRecno))
		If !SE5->(Eof()) .And. Empty(SE5->E5_SITUACA)
			::cError := "El movimiento bancario no ha sido borrado."	
			::lGrabo := .F.
		Else
			::lGrabo := .T.
		EndIf
	Else
		::lGrabo := .T.
	EndIf	
	
RETURN Nil
