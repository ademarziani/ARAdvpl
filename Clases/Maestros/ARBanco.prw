#INCLUDE 'PROTHEUS.CH'
	
/*=====================================================================
|----------------------------------------------------------------------
| Programa | ARBanco | Autor: Andres Demarziani
|----------------------------------------------------------------------
| Descripcion: Clase de Banco.
|----------------------------------------------------------------------
======================================================================*/
CLASS ARBanco

	DATA cFil
	DATA cCod
	DATA cAgencia
	DATA cCuenta
	DATA cCtaCont
	DATA cNombre
	DATA nMoneda
	DATA nRecno
	DATA lExiste

	METHOD New() CONSTRUCTOR
	METHOD setBanco()

ENDCLASS

/*=====================================================================
|----------------------------------------------------------------------
| Programa | ARBanco | Autor: Andres Demarziani
|----------------------------------------------------------------------
======================================================================*/
METHOD New(cCod,cAgencia,cCuenta) CLASS ARBanco	

	Local cAlias := Alias()

	::cCod		:= IIf(cCod==Nil, Space(TamSX3("A6_COD")[1]), cCod)
	::cAgencia	:= IIf(cAgencia==Nil, Space(TamSX3("A6_AGENCIA")[1]), cAgencia)
	::cCuenta	:= IIf(cCuenta==Nil, Space(TamSX3("A6_NUMCON")[1]), cCuenta)

	dbSelectArea("SA6")
	dbSetOrder(1)
	If dbSeek(xFilial("SA6")+::cCod+::cAgencia+::cCuenta)
		::setBanco()
	Else
		::lExiste := .F.
	EndIf
	
	dbSelectArea(cAlias)
	
RETURN SELF

/*=====================================================================
|----------------------------------------------------------------------
| Programa | ARBanco | Autor: Andres Demarziani
|----------------------------------------------------------------------
======================================================================*/
METHOD setBanco() CLASS ARBanco
	
	::cFil 		:= SA6->A6_FILIAL
	::cCod		:= SA6->A6_COD
	::cAgencia	:= SA6->A6_AGENCIA
	::cCuenta	:= SA6->A6_NUMCON
	::cNombre	:= SA6->A6_NOME
	::nMoneda	:= SA6->A6_MOEDA
	::cCtaCont	:= SA6->A6_CONTA
	::nRecno	:= SA6->(Recno())	
	::lExiste	:= .T.
	
RETURN Nil

