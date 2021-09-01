#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'RWMAKE.CH'
	
/*=====================================================================
|----------------------------------------------------------------------
| Programa | ARProveedor | Autor: Andres Demarziani
|----------------------------------------------------------------------
| Descripcion: Clase de Producto.
|----------------------------------------------------------------------
======================================================================*/
CLASS ARProveedor FROM ARDocumento

	DATA cFil
	DATA cCod
	DATA cLoja
	DATA cNombre
	DATA cTipo
	DATA cCond
	DATA lEsCli
	DATA lExiste
	
	DATA cPDV
	DATA cSerie
	DATA cDoc
	
	METHOD New() CONSTRUCTOR
	METHOD setProve()

ENDCLASS

/*=====================================================================
|----------------------------------------------------------------------
| Programa | ARProveedor | Autor: Andres Demarziani
|----------------------------------------------------------------------
======================================================================*/
METHOD New(cCod,cLoja) CLASS ARProveedor	

	Local cAlias := Alias()

	_Super:New()
	::setTipo("1")
	
	::cCod	:= IIf(cCod==Nil, Space(TamSX3("A2_COD")[1]), cCod)
	::cLoja	:= IIf(cLoja==Nil, Space(TamSX3("A2_LOJA")[1]), cLoja)
	
	dbSelectArea("SA2")
	dbSetOrder(1)
	If dbSeek(xFilial("SA2")+::cCod+::cLoja)
		::setProve()
	Else
		::lExiste := .F.
	EndIf

	dbSelectArea(cAlias)

RETURN SELF

/*=====================================================================
|----------------------------------------------------------------------
| Programa | ARProveedor | Autor: Andres Demarziani
|----------------------------------------------------------------------
======================================================================*/
METHOD setProve() CLASS ARProveedor
	
	::cFil 		:= SA2->A2_FILIAL
	::cCod		:= SA2->A2_COD
	::cLoja		:= SA2->A2_LOJA
	::cNombre	:= SA2->A2_NOME
	::cTipo		:= SA2->A2_TIPO
	::cCond		:= SA2->A2_COND
	::lEsCli	:= .F.
	::lExiste	:= .T.

	::cPDV		:= ""
	::cSerie	:= ""
	::cDoc		:= ""	
	
RETURN Nil
