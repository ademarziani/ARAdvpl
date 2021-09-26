#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'RWMAKE.CH'
	
/*=====================================================================
|---------------------------------------------------------------------|
| Programa | ARReciboCobro | Autor:  Demarziani | Fecha: 17/12/2019   |
|---------------------------------------------------------------------|
| Descripcion: Clase para definir la forma de cobro.                  |
|---------------------------------------------------------------------|
======================================================================*/
CLASS ARReciboCobro

	DATA cTipo
	DATA cPref
	DATA cNum
	DATA nMoneda
	DATA cMoneda
	DATA nValor		
	DATA dFecha
	DATA dVcto	
	DATA oBanco
	DATA cBcoChq
	DATA cAgeChq
	DATA cCtaChq
	DATA cCuit
	
	DATA aRet
	DATA nValBase
	DATA nAliq
	DATA cProv
	DATA cCFO	
	
	DATA nSigno
	DATA nVlrPesos
	DATA cDesTipo
	DATA cDesBco
	
	METHOD New() CONSTRUCTOR
	METHOD setRetenc()

ENDCLASS

/*=====================================================================
|---------------------------------------------------------------------|
| Programa | ARReciboCobro | Autor: Demarziani | Fecha: 17/12/2019    |
|---------------------------------------------------------------------|
======================================================================*/
METHOD New(cTipo, cPref, cNum, nMoneda, dFecha, dVcto, oBanco, cBcoChq, cAgeChq, cCtaChq, cCuit, nValor, nTxMoneda, nAliq, cProv, cCFO) CLASS ARReciboCobro
				
	::cTipo 	:= cTipo
	::cPref		:= cPref
	::cNum		:= cNum	
	::nMoneda	:= nMoneda
	::cMoneda	:= cValToChar(nMoneda)
	::dFecha	:= dFecha
	::dVcto		:= dVcto
	::oBanco	:= IIF(oBanco!=Nil, oBanco, ARBanco():New())
	::cBcoChq	:= IIf(cBcoChq!=Nil, cBcoChq, Space(TamSX3("EL_BCOCHQ")[1])) 
	::cAgeChq	:= IIf(cAgeChq!=Nil, cAgeChq, Space(TamSX3("EL_AGECHQ")[1])) 
	::cCtaChq	:= IIf(cCtaChq!=Nil, cCtaChq, Space(TamSX3("EL_CTACHQ")[1])) 
	::cCuit		:= IIf(cCuit!=Nil, cCuit, Space(TamSX3("EL_CGC")[1]))
	
	::nValBase	:= IIf(nAliq!=Nil, Round(nValor/(nAliq/100), 2), 0)
	::nAliq		:= IIf(nAliq!=Nil, nAliq, 0)
	::cProv		:= IIf(cProv!=Nil, cProv, "")	
	::cCFO		:= IIf(cCFO!=Nil, cCFO, "")

	::nSigno	:= IIf(::cTipo$"RA", -1, 1)	
	::nValor	:= nValor*::nSigno
	::nVlrPesos	:= nValor*nTxMoneda*::nSigno
	
	::aRet		:= {}
		
	Do Case
		Case ::cTipo == "CHD"		
			::cDesTipo	:= "Cheque"
			::cDesBco	:= Posicione("FJO",1,xFilial("FJO")+cBcoChq+cAgeChq+cCtaChq,"FJO_NOME")	
		Case ::cTipo == "CH"		
			::cDesTipo	:= "Cheque"
			::cDesBco	:= Posicione("FJO",1,xFilial("FJO")+cBcoChq+cAgeChq+cCtaChq,"FJO_NOME")
		Case ::cTipo == "EF"
			::cDesTipo	:= "Efectivo"
			::cDesBco	:= ""
		Case ::cTipo == "TF"
			::cDesTipo	:= "Transferencia"
			If oBanco <> Nil
				::cDesBco	:= oBanco:cNombre
			Else
				::cDesBco	:= ""
			EndIf
		Case ::cTipo == "RI"
			::cDesTipo	:= "Retención IVA"
			::cDesBco	:= ""
		Case ::cTipo == "RS"
			::cDesTipo	:= "Retención SUSS"
			::cDesBco	:= ""
		Case ::cTipo == "RG"
			::cDesTipo	:= "Retención Ganancias"
			::cDesBco	:= ""
		Case ::cTipo == "RB"
			::cDesTipo	:= "Retención IIBB"
			::cDesBco	:= ""
		Case ::cTipo == "RA"
			::cDesTipo	:= "Valor a cuenta"
			::cDesBco	:= ""	
		OtherWise
			::cDesTipo	:= "Otros"
			::cDesBco	:= ""			
	EndCase
	
RETURN SELF

/*=====================================================================
|---------------------------------------------------------------------|
| Programa | ARReciboCobro | Autor: Demarziani | Fecha: 17/12/2019    |
|---------------------------------------------------------------------|
======================================================================*/
METHOD setRetenc(cSer, cNum, cCli, cLoja) CLASS ARReciboCobro
	
	aAdd(::aRet, {"FE_SERIE"	, cSer, Nil})
	aAdd(::aRet, {"FE_RECIBO"	, cNum, Nil})
	aAdd(::aRet, {"FE_CLIENTE"	, cCli, Nil})
	aAdd(::aRet, {"FE_LOJCLI"	, cLoja, Nil})	
	aAdd(::aRet, {"FE_NROCERT"	, ::cNum, Nil})
	aAdd(::aRet, {"FE_EMISSAO"	, ::dFecha, Nil})
	aAdd(::aRet, {"FE_TIPO"		, Right(::cTipo,1), Nil})
	aAdd(::aRet, {"FE_VALBASE"	, ::nValBase, Nil})
	aAdd(::aRet, {"FE_FILIAL"	, xFilial("SFE"), Nil})		
	aAdd(::aRet, {"FE_ALIQ"		, ::nAliq, Nil})
	aAdd(::aRet, {"FE_RETENC"	, ::nValor, Nil})
	aAdd(::aRet, {"FE_CFO"		, ::cCFO, Nil})			
	aAdd(::aRet, {"FE_EST"		, ::cProv, Nil})
	
RETURN Nil

