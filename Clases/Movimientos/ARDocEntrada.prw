#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'RWMAKE.CH'
	
/*=====================================================================
|---------------------------------------------------------------------|
| Programa | ARDocEntrada | Autor: Demarziani | Fecha: 19/12/2019     |
|---------------------------------------------------------------------|
| Descripcion: Carga documentos de Entrada (SF1,SD1).                 |
|---------------------------------------------------------------------|
======================================================================*/
CLASS ARDocEntrada FROM ARDocumento
	
	DATA cEsp
	DATA oCliFor
	DATA cPDV
	DATA cCodPDV
	DATA cSerie
	DATA cDoc
	DATA cTPDoc
	DATA aProd
	DATA nMoneda
	DATA nValBrut
	DATA nValMerc

	METHOD New() CONSTRUCTOR
	METHOD setCab()
	METHOD setDet()
	METHOD setSerie()
	METHOD getSerie()
	METHOD setNumero()
	METHOD getNumero()
	METHOD getTipoDoc()
	METHOD verDocOk()
	METHOD guardar()
	METHOD borrar()

ENDCLASS

/*=====================================================================
|---------------------------------------------------------------------|
| Programa | ARDocEntrada | Autor: Andres Demarziani | Fecha: 19/12/2019   |
|---------------------------------------------------------------------|
======================================================================*/
METHOD New(cEsp, oCliFor, aProd, nMoneda) CLASS ARDocEntrada
	
	_Super:New()
	::setTipo("2")

	If ValType(oCliFor) == "O"
		::cEsp		:= AllTrim(cEsp)	
		::oCliFor	:= oCliFor
		::aProd		:= aProd
		::cError	:= ""
		::nMoneda	:= nMoneda
		
		If oCliFor:lEsCli
			::cPDV		:= IIf(oCliFor:cPDV=="","0001",oCliFor:cPDV)
			::cCodPDV	:= POSICIONE("CFH",1,xFilial("CFH")+::cPDV,"CFH_IDPV")
		Else
			::cPDV		:= ""
			::cCodPDV	:= ""
		EndIf
		::cSerie		:= IIf(oCliFor:cSerie=="", ::getSerie(), oCliFor:cSerie)
		::cDoc			:= IIf(oCliFor:cDoc="", ::getNumero(), oCliFor:cDoc)
		::cTPDoc		:= ::getTipoDoc()	
		
		::setCab()
		::setDet()
	EndIf

RETURN SELF

/*=====================================================================
|---------------------------------------------------------------------|
| Programa | ARDocEntrada | Autor: Andres Demarziani | Fecha: 19/12/2019   |
|---------------------------------------------------------------------|
======================================================================*/
METHOD setCab() CLASS ARDocEntrada
	
	::aCab 		:= {}
	
	aAdd(::aCab, {"F1_FORNECE"	, ::oCliFor:cCod	,Nil}) //Codigo Cliente
	aAdd(::aCab, {"F1_LOJA"		, ::oCliFor:cLoja 	,Nil}) //Tienda Cliente
	aAdd(::aCab, {"F1_SERIE"	, ::cSerie	    	,Nil}) //Serie del documento
	aAdd(::aCab, {"F1_DOC"		, ::cDoc			,Nil}) //Numero de documento		
	aAdd(::aCab, {"F1_TIPODOC"	, ::cTPDoc			,Nil}) //Tipo de Documento
	aAdd(::aCab, {"F1_EMISSAO"	, dDatabase			,Nil}) //Fecha de Emision
	aAdd(::aCab, {"F1_DTDIGIT"	, dDatabase			,Nil}) //Fecha de Digitacion		
	aAdd(::aCab, {"F1_NATUREZ"	, ""		     	,Nil}) //Naturaleza (Financiero)
	aAdd(::aCab, {"F1_COND"		, ::oCliFor:cCond  	,Nil}) //Naturaleza (Financiero)
	aAdd(::aCab, {"F1_ESPECIE"	, ::cEsp   			,Nil}) //Tipo de Documento 
	aAdd(::aCab, {"F1_MOEDA"	, ::nMoneda			,Nil}) //Moneda
	If ::nMoneda == 1
		aAdd(::aCab, {"F1_TXMOEDA"	, 1				,Nil}) //Tasa de moneda
	EndIf
	If ::oCliFor:lEsCli .And. !Empty(::cCodPDV) .And. CFH->(FieldPos("CFH_XZOFIS")) > 0
		aAdd(::aCab, {"F1_PROVENT"	, CFH->CFH_XZOFIS		,Nil}) //Tipo de venta			
	EndIf
	
RETURN Nil

/*=====================================================================
|---------------------------------------------------------------------|
| Programa | ARDocEntrada   Autor: Demarziani | Fecha: 19/12/19       |
|---------------------------------------------------------------------|
======================================================================*/
METHOD setDet() CLASS ARDocEntrada

	Local aItem 	:= {}
	Local nP		:= 1
	Local nCant		:= 0
	Local nPrcUnt	:= 0
	Local nDecTot	:= TamSX3("D1_TOTAL")[2]

	::aDet1 		:= {}
	
	For nP := 1 To Len(::aProd)
		nCant	:= ::aProd[nP]:nQtd
		nPrcUnt	:= ::aProd[nP]:nPrc

		aAdd(aItem, {"D1_COD"		, ::aProd[nP]:cCod				,Nil}) //Codigo de producto
		aAdd(aItem, {"D1_UM"		, ::aProd[nP]:cUM				,Nil}) //Unidad de medida						
		aAdd(aItem, {"D1_QUANT"		, nCant							,Nil}) //Cantidad
		aAdd(aItem, {"D1_VUNIT"		, nPrcUnt						,Nil}) //Precio de Venta		
		aAdd(aItem, {"D1_TOTAL"		, Round(nCant*nPrcUnt,nDecTot)	,Nil}) //Total		
		aAdd(aItem, {"D1_TES"		, ::aProd[nP]:cTE				,Nil}) //TES									
		aAdd(aItem, {"D1_LOCAL"		, ::aProd[nP]:cDepo				,Nil}) //Deposito		

		aAdd(::aDet1, aItem)
		aItem:={} 
	Next nP

RETURN Nil

/*=====================================================================
|---------------------------------------------------------------------|
| Programa | ARDocEntrada | Autor: Andres Demarziani | Fecha: 19/12/2019   |
|---------------------------------------------------------------------|
======================================================================*/
METHOD setSerie(cSerie) CLASS ARDocEntrada

	::cSerie := cSerie
	::setValEncab("F1_SERIE", cSerie)

RETURN Nil

/*=====================================================================
|---------------------------------------------------------------------|
| Programa | ARDocEntrada | Autor: Andres Demarziani | Fecha: 19/12/2019   |
|---------------------------------------------------------------------|
======================================================================*/
METHOD getSerie() CLASS ARDocEntrada

Local cCodSerie := ""
Local cCodEsp

If ::oCliFor:lEsCli
	Do Case
		Case ::cEsp == "RFN"
			cCodSerie := "R"
		Case ::oCliFor:cTipo $ "N|I"
			cCodSerie := "A"
		Case ::oCliFor:cTipo $ "F|S|M|X"
			cCodSerie := "B"
		Case ::oCliFor:cTipo $ "D|E"    		
			cCodSerie := "E"
	EndCase

	Do Case
		Case ::cEsp == "NF"
			cCodEsp := "1"
		Case ::cEsp == "NCC"
			cCodEsp := "4"
		Case ::cEsp == "NDC"
			cCodEsp := "5"
		Case ::cEsp == "RCN"
			cCodEsp := "6"
	EndCase

	BEGINSQL ALIAS "TSER"

	SELECT ISNULL(MAX(FP_SERIE),'') AS FPSERIE
	FROM %Table:SFP%
	WHERE FP_PV = %Exp:Self:cPDV%
	AND FP_ESPECIE = %Exp:cCodEsp%
	AND LEFT(FP_SERIE,1) = %Exp:cCodSerie%
	AND D_E_L_E_T_ <> '*'

	ENDSQL

	If !TSER->(Eof()) .And. !Empty(TSER->FPSERIE)
		cCodSerie := TSER->FPSERIE
	ENDIF

	TSER->(dbCloseArea())
Else

	Do Case
		Case ::oCliFor:cTipo $ "N|I"
			cCodSerie := "A  "
		Case ::oCliFor:cTipo $ "F|S"
			cCodSerie := "B  "
		Case ::oCliFor:cTipo $ "M|X"
			cCodSerie := "C  "
		Case ::oCliFor:cTipo $ "E"    		
			cCodSerie := "E  "
	EndCase
EndIf

RETURN cCodSerie

/*=====================================================================
|---------------------------------------------------------------------|
| Programa | ARDocEntrada | Autor: Andres Demarziani | Fecha: 19/12/2019   |
|---------------------------------------------------------------------|
======================================================================*/
METHOD setNumero(cDoc) CLASS ARDocEntrada

	::cDoc := cDoc
	::setValEncab("F1_DOC", cDoc)

RETURN Nil

/*=====================================================================
|---------------------------------------------------------------------|
| Programa | ARDocEntrada | Autor: Andres Demarziani | Fecha: 19/12/2019   |
|---------------------------------------------------------------------|
======================================================================*/
METHOD getNumero() CLASS ARDocEntrada

Local cNum 	:= ""
Local aArea	:= GetArea()
Local nTam	:= TamSX3("F1_DOC")[1]

If !Empty(::cCodPDV)
	dbSelectArea("SX5")
	dbSetOrder(1)
	If dbSeek(xFilial("SX5")+"01"+AllTrim(::cSerie)+::cCodPDV)
		cNum := Left(SX5->X5_DESCSPA, nTam)
	EndIf
Else
	cNum := Right(DToS(dDataBase)+StrTran(Time(),":",""), nTam)
EndIf

RestArea(aArea)

RETURN cNum

/*=====================================================================
|---------------------------------------------------------------------|
| Programa | ARDocEntrada | Autor: Andres Demarziani | Fecha: 19/12/2019   |
|---------------------------------------------------------------------|
======================================================================*/
METHOD getTipoDoc() CLASS ARDocEntrada

Local cTipo := ""

Do Case
	Case ::cEsp == "RCN"	
		cTipo := "60"		
	Case ::cEsp == "NF"	
		cTipo := "10"
	Case ::cEsp == "NDP"		
		cTipo := "09"
	Case ::cEsp == "NCC"	
		cTipo := "04"	
EndCase	
	
RETURN cTipo

/*=====================================================================
|---------------------------------------------------------------------|
| Programa | ARDocEntrada | Autor: Andres Demarziani | Fecha: 19/12/2019   |
|---------------------------------------------------------------------|
======================================================================*/
METHOD guardar() CLASS ARDocEntrada
	
	Private lMsErroAuto := .F.
	Private cNroPV		:= ::cPDV
	Private cCodPV		:= ::cCodPDV	
	Private cLocxNFPV
	Private cIdPVArg
		
	If Empty(::cEsp := Alltrim(::getValEncab("F1_ESPECIE")))
		::cError := "La especie no fue informada en el encabezado."
	Else
		::setValEncab("F1_TIPODOC", ::getTipoDoc())

		Do Case

			Case ::cEsp == "NF"

				MSExecAuto({|x,y,z| MATA101N(x,y,z) }, ::aCab, ::aDet1, 3) 

			Case ::cEsp == "NDP"

				MSExecAuto({|x,y,z| MATA466N(x,y,z) }, ::aCab, ::aDet1, 3) 

			Case ::cEsp == "RCN"

				MSExecAuto({|x,y,z| MATA102N(x,y,z) }, ::aCab, ::aDet1, 3) 

			Case ::cEsp == "NCC"

				MSExecAuto({|x,y,z| MATA465N(x,y,z) }, ::aCab, ::aDet1, 3) 

		EndCase

		::lGrabo := ::verDocOk()

		If ::lGrabo .And. !Empty(::cCodPDV)
			RecLock("SF1",.F.)
			SF1->F1_PV := ::cPDV
			MsUnLock()

			dbSelectArea("SX5")
			dbSetOrder(1)
			If dbSeek(xFilial("SX5")+"01"+AllTrim(::cSerie)+::cCodPDV)			
				RecLock("SX5",.F.)
				SX5->X5_DESCRI	:= Soma1(::cDoc)
				SX5->X5_DESCSPA	:= Soma1(::cDoc)
				SX5->X5_DESCENG	:= Soma1(::cDoc)
				MsUnLock()
			EndIf

			::cError := ""
		EndIf

		If !::lGrabo
			If lMsErroAuto
				::cError := MostraErro("ENTRADA")
			Else
				::cError := "Documento no grabado."
			EndIf	
		EndIf
	EndIf
		
RETURN Nil 

/*=====================================================================
|---------------------------------------------------------------------|
| Programa | ARDocEntrada | Autor: Andres Demarziani | Fecha: 19/12/2019   |
|---------------------------------------------------------------------|
======================================================================*/
METHOD borrar() CLASS ARDocEntrada
	
	Private lMsErroAuto := .F.
	
	If !Empty(::aCab) .And. !Empty(::aDet1)
		Do Case
		
			Case ::cEsp == "NF"
				
				MSExecAuto({|x,y,z| MATA101N(x,y,z) }, ::aCab, ::aDet1, 5) 

			Case ::cEsp == "NDP"
			
				MSExecAuto({|x,y,z| MATA466N(x,y,z) }, ::aCab, ::aDet1, 5) 
				
			Case ::cEsp == "RCN"
			
				MSExecAuto({|x,y,z| MATA102N(x,y,z) }, ::aCab, ::aDet1, 5) 
				
			Case ::cEsp == "NCC"
			
				MSExecAuto({|x,y,z| MATA465N(x,y,z) }, ::aCab, ::aDet1, 5) 
			
		EndCase
		
		If lMsErroAuto
			::cError := MostraErro("SALIDA")
			::lGrabo := .F.
		Else
			::cError := ""
			::lGrabo := .T.
		EndIf
	EndIf
		
RETURN Nil 

/*=====================================================================
|---------------------------------------------------------------------|
| Programa | ARDocEntrada | Autor: Andres Demarziani | Fecha: 19/12/2019   |
|---------------------------------------------------------------------|
======================================================================*/
METHOD verDocOk() CLASS ARDocEntrada

	Local aArea	:= GetArea()
	Local lRet		:= .F.
	Local cClave 	:= xFilial("SF1")+;
					::getValEncab("F1_DOC")+;
					::getValEncab("F1_SERIE")+;
					::getValEncab("F1_FORNECE")+;
					::getValEncab("F1_LOJA")

	dbSelectArea("SF1")
	dbSetOrder(1)
	If SF1->(dbSeek(cClave))
		lRet := .T.
		
		::nValBrut := SF1->F1_VALBRUT
		::nValMerc := SF1->F1_VALMERC
	EndIf
		
	RestArea(aArea)
Return lRet
