#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'RWMAKE.CH'
	
/*=====================================================================
|----------------------------------------------------------------------
| Programa | ARProducto | Autor: Andres Demarziani
|----------------------------------------------------------------------
| Descripcion: Clase de Producto.
|----------------------------------------------------------------------
======================================================================*/
CLASS ARProducto FROM ARDocumento

	DATA cFil
	DATA cCod
	DATA cTE
	DATA cTS
	DATA cDepo
	DATA cUM
	DATA cSegUM
	DATA nQtdStock
	DATA nQtd
	DATA nPrc
	DATA lExiste

	METHOD New() CONSTRUCTOR
	METHOD setProdu()

ENDCLASS

/*=====================================================================
|----------------------------------------------------------------------
| Programa | ARProducto | Autor: Andres Demarziani
|----------------------------------------------------------------------
======================================================================*/
METHOD New(cCod) CLASS ARProducto

	Local cAlias := Alias()

	_Super:New()
	::setTipo("1")
	
	::cCod	:= IIf(cCod==Nil, Space(TamSX3("B1_COD")[1]), cCod)
		
	dbSelectArea("SB1")
	dbSetOrder(1)
	If dbSeek(xFilial("SB1")+::cCod)
		::setProdu()
	Else
		::lExiste := .F.
	EndIf
	
	dbSelectArea(cAlias)

RETURN SELF

/*=====================================================================
|----------------------------------------------------------------------
| Programa | ARProducto | Autor: Andres Demarziani
|----------------------------------------------------------------------
======================================================================*/
METHOD setProdu() CLASS ARProducto
	
	::cFil 		:= SB1->B1_FILIAL
	::cCod		:= SB1->B1_COD
	::cTE		:= SB1->B1_TE
	::cTS		:= SB1->B1_TS
	::cDepo		:= SB1->B1_LOCPAD
	::cUM		:= SB1->B1_UM
	::cSegUM	:= SB1->B1_SEGUM
	::lExiste	:= .T.
	::nQtd		:= 0
	::nPrc		:= 0

	dbSelectArea("SB2")
	dbSetOrder(1)
	If SB2->(dbSeek(xFilial("SB2")+::cCod+::cDepo))
		::nQtdStock := SB2->B2_QATU
	Else
		::nQtdStock := 0
	EndIf
		
RETURN Nil
