#INCLUDE 'PROTHEUS.CH'
	
/*=====================================================================
|----------------------------------------------------------------------
| Programa | ARCliente | Autor: Andres Demarziani                     
|----------------------------------------------------------------------
| Descripcion: Clase de Cliente.                                      
|----------------------------------------------------------------------
======================================================================*/
CLASS ARCliente FROM ARDocumento

	DATA cFil
	DATA cCod
	DATA cLoja
	DATA cRazon
	DATA cTipo
	DATA cCuit
	DATA cCond
	DATA cNatur
	DATA lGenDC
	DATA lEsCli
	DATA nRecno
	DATA lExiste
	
	DATA cPDV
	DATA cSerie
	DATA cDoc

	METHOD New() CONSTRUCTOR
	METHOD setClien()

ENDCLASS

/*=====================================================================
|----------------------------------------------------------------------
| Programa | ARCliente | Autor: Andres Demarziani 
|----------------------------------------------------------------------
======================================================================*/
METHOD New(cCod,cLoja) CLASS ARCliente	

	Local cAlias := Alias()

	_Super:New()
	::setTipo("1")
	
	::cCod	:= IIf(cCod==Nil, Space(TamSX3("A1_COD")[1]), cCod)
	::cLoja	:= IIf(cLoja==Nil, Space(TamSX3("A1_LOJA")[1]), cLoja)

	dbSelectArea("SA1")
	dbSetOrder(1)
	If dbSeek(xFilial("SA1")+::cCod+::cLoja)
		::setClien()
	Else
		::lExiste := .F.
	EndIf

	dbSelectArea(cAlias)

RETURN SELF

/*=====================================================================
|---------------------------------------------------------------------|
| Programa | ARCliente | Autor: Andres Demarziani | Fecha: 20/12/2019  |
|---------------------------------------------------------------------|
======================================================================*/
METHOD setClien() CLASS ARCliente
	
	::cFil 		:= SA1->A1_FILIAL
	::cCod		:= SA1->A1_COD
	::cLoja		:= SA1->A1_LOJA
	::cRazon	:= SA1->A1_NOME
	::cTipo		:= SA1->A1_TIPO
	::cCuit		:= SA1->A1_CGC
	::cCond		:= SA1->A1_COND
	::cNatur	:= SA1->A1_NATUREZ
	::lGenDC	:= IIf(SA1->(FieldPos("A1_XDIFCAM"))>0, SA1->A1_XDIFCAM=="1", .F.)
	::lExiste	:= .T.
	::lEsCli	:= .T.
	::nRecno	:= SA1->(Recno())
	
	::cPDV		:= ""
	::cSerie	:= ""
	::cDoc		:= ""
	
RETURN Nil

