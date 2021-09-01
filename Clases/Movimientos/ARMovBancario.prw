#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'RWMAKE.CH'
	
/*=====================================================================
|---------------------------------------------------------------------|
| Programa | ARMovBancario | Autor: Demarziani | Fecha: 20/09/2021    |
|---------------------------------------------------------------------|
| Descripcion: Movimiento bancario.                                   |
|---------------------------------------------------------------------|
======================================================================*/
CLASS ARMovBancario
			
	DATA cFil
	DATA oBanco	
	DATA cRecPag
	DATA nValor	
	DATA dFecha
	DATA cNaturez
	DATA oCliFor
	DATA nRecno
			
	METHOD New() CONSTRUCTOR
	METHOD setCab()	
	METHOD guardar()
	METHOD borrar()

ENDCLASS

/*=====================================================================
|---------------------------------------------------------------------|
| Programa | ARMovBancario | Autor: Demarziani | Fecha: 20/09/2021    |
|---------------------------------------------------------------------|
======================================================================*/
METHOD New(oBanco, cRecPag, nValor, dFecha, cNaturez, oCliFor, nRecno) CLASS ARMovBancario

	_Super:New()
	::setTipo("1")
	
	If ValType(oBanco) == "O"
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
	EndIf
	
RETURN SELF

/*=====================================================================
|---------------------------------------------------------------------|
| Programa | ARMovBancario | Autor: Demarziani | Fecha: 20/09/2021    |
|---------------------------------------------------------------------|
======================================================================*/
METHOD setCab() CLASS ARMovBancario

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
| Programa | ARMovBancario | Autor: Demarziani | Fecha: 20/09/2021    |
|---------------------------------------------------------------------|
======================================================================*/
METHOD guardar() CLASS ARMovBancario

	Local cFunBkp 	:= FunName()
	Local nTipo

	Private lMsErroAuto := .F.

	If Empty(::cRecPag := Alltrim(::getValEncab("E5_RECPAG")))
		::cError := "La campo E5_RECPAG, para determinar el signo del movimiento, no fue informado."
	Else
		nTipo := IIf(::cRecPag == "P", 3, 4)

		SetFunName("FINA100")

		MSExecAuto({|x,y,z| Fina100(x,y,z)}, 0, ::aCab, nTipo)
		
		If lMsErroAuto
			::cError := MostraErro("MOVBCO")
		Else
			::cError := ""
			::lGrabo := .T.
		EndIf
		
		SetFunName(cFunBkp)
	EndIf

RETURN Nil

/*=====================================================================
|---------------------------------------------------------------------|
| Programa | ARMovBancario | Autor: Demarziani | Fecha: 20/09/2021    |
|---------------------------------------------------------------------|
======================================================================*/
METHOD borrar() CLASS ARMovBancario

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
