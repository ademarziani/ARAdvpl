#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'RWMAKE.CH'
	
/*=====================================================================
|---------------------------------------------------------------------|
| Programa | ARDocSalida | Autor: Demarziani | Fecha: 29/10/2021      |
|---------------------------------------------------------------------|
| Descripcion: Carga docuemntos de SALIDA  (SF2,SD2).                 |
|---------------------------------------------------------------------|
======================================================================*/
CLASS ARDocSalida FROM ARDocumento

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
| Programa | ARDocSalida | Autor: Andres Demarziani | Fecha: 29/10/2017  |
|---------------------------------------------------------------------|
======================================================================*/
METHOD New(cEsp, oCliFor, aProd, nMoneda) CLASS ARDocSalida 
	
	_Super:New()

	If cEsp <> Nil
		::cEsp		:= AllTrim(cEsp)	
		::oCliFor	:= oCliFor
		::aProd		:= aProd
		::cError		:= ""
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
| Programa | ARDocSalida | Autor: Andres Demarziani | Fecha: 29/10/2017  |
|---------------------------------------------------------------------|
======================================================================*/
METHOD setCab() CLASS ARDocSalida 

	::aCab 		:= {}

	aAdd(::aCab, {"F2_CLIENTE"	, ::oCliFor:cCod	,Nil}) //Codigo Cliente
	aAdd(::aCab, {"F2_LOJA"		, ::oCliFor:cLoja 	,Nil}) //Tienda Cliente
	aAdd(::aCab, {"F2_SERIE"	, ::cSerie	    	,Nil}) //Serie del documento
	aAdd(::aCab, {"F2_DOC"		, ::cDoc			,Nil}) //Numero de documento		
	aAdd(::aCab, {"F2_TIPODOC"	, ::cTPDoc			,Nil}) //Tipo de Documento
	aAdd(::aCab, {"F2_EMISSAO"	, dDatabase			,Nil}) //Fecha de Emision
	aAdd(::aCab, {"F2_DTDIGIT"	, dDatabase			,Nil}) //Fecha de Digitacion		
	aAdd(::aCab, {"F2_NATUREZ"	, ""		     	,Nil}) //Naturaleza (Financiero)
	aAdd(::aCab, {"F2_COND"		, ::oCliFor:cCond  	,Nil}) //Naturaleza (Financiero)
	aAdd(::aCab, {"F2_ESPECIE"	, ::cEsp   			,Nil}) //Tipo de Documento 
	aAdd(::aCab, {"F2_MOEDA"	, ::nMoneda			,Nil}) //Moneda
	If ::nMoneda == 1
		aAdd(::aCab, {"F2_TXMOEDA"	, 1				,Nil}) //Tasa de moneda
	EndIf
	If ::oCliFor:lEsCli
		aAdd(::aCab, {"F2_TPVENT"	, "1"			,Nil}) //Tipo de venta

		If !Empty(::cCodPDV) .And. CFH->(FieldPos("CFH_XZOFIS")) > 0
			aAdd(::aCab, {"F2_PROVENT"	, CFH->CFH_XZOFIS		,Nil}) //Tipo de venta			
		EndIf
	EndIf
	
RETURN Nil

/*=====================================================================
|---------------------------------------------------------------------|
| Programa | ARDocSalida | Autor: Andres Demarziani | Fecha: 29/10/2017  |
|---------------------------------------------------------------------|
======================================================================*/
METHOD setDet() CLASS ARDocSalida 

	Local aItem 	:= {}
	Local nP		:= 1
	Local nCant	:= 0
	Local nPrcUnt	:= 0
	Local nDecTot	:= TamSX3("D2_TOTAL")[2]

	::aDet1 		:= {}
	
	For nP := 1 To Len(::aProd)
		nCant	:= ::aProd[nP]:nQtd
		nPrcUnt	:= ::aProd[nP]:nPrc

		aAdd(aItem, {"D2_COD"			, ::aProd[nP]:cCod				,Nil}) //Codigo de producto
		aAdd(aItem, {"D2_UM"			, ::aProd[nP]:cUM				,Nil}) //Unidad de medida						
		aAdd(aItem, {"D2_QUANT"			, nCant							,Nil}) //Cantidad
		aAdd(aItem, {"D2_PRCVEN"		, nPrcUnt						,Nil}) //Precio de Venta		
		aAdd(aItem, {"D2_TOTAL"			, Round(nCant*nPrcUnt,nDecTot)	,Nil}) //Total		
		aAdd(aItem, {"D2_TES"			, ::aProd[nP]:cTS				,Nil}) //TES									
		aAdd(aItem, {"D2_LOCAL"			, ::aProd[nP]:cDepo				,Nil}) //Deposito		

		aAdd(::aDet1, aItem)
		aItem:={} 
	Next nP

RETURN Nil

/*=====================================================================
|---------------------------------------------------------------------|
| Programa | ARDocSalida | Autor: Andres Demarziani | Fecha: 29/10/2017  |
|---------------------------------------------------------------------|
======================================================================*/
METHOD getSerie() CLASS ARDocSalida 

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
| Programa | ARDocSalida | Autor: Andres Demarziani | Fecha: 29/10/2017  |
|---------------------------------------------------------------------|
======================================================================*/
METHOD getNumero(cSerie) CLASS ARDocSalida 

Local cNum 	:= ""
Local aArea	:= GetArea()
Local nTam	:= TamSX3("F2_DOC")[1]

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
| Programa | ARDocSalida | Autor: Andres Demarziani | Fecha: 29/10/2017  |
|---------------------------------------------------------------------|
======================================================================*/
METHOD getTipoDoc() CLASS ARDocSalida 

Local cTipo := ""

Do Case
	Case ::cEsp == "RFN"	
		cTipo := "50"
		
	Case ::cEsp == "NF"	
		cTipo := "01"
		
	Case ::cEsp == "NDP"		
		cTipo := "02"
		
	Case ::cEsp == "NCP"	
		cTipo := "07"	
EndCase	
	

RETURN cTipo

/*=====================================================================
|---------------------------------------------------------------------|
| Programa | ARDocSalida | Autor: Andres Demarziani | Fecha: 29/10/2017  |
|---------------------------------------------------------------------|
======================================================================*/
METHOD guardar() CLASS ARDocSalida 
	
	Private lMsErroAuto := .F.
	Private cNroPV		:= ::cPDV
	Private cCodPV		:= ::cCodPDV
	Private cLocxNFPV
	Private cIdPVArg
	
	Do Case
	
		Case ::cEsp == "NF"
			
			MSExecAuto({|x,y,z| MATA467N(x,y,z) }, ::aCab, ::aDet1, 3) 

		Case ::cEsp == "NDC"
		
			MSExecAuto({|x,y,z| MATA465N(x,y,z) }, ::aCab, ::aDet1, 3) 
			
		Case ::cEsp == "RFN"
		
			MSExecAuto({|x,y,z| MATA462N(x,y,z) }, ::aCab, ::aDet1, 3) 
			
		Case ::cEsp == "NCP"
		
			MSExecAuto({|x,y,z| MATA466N(x,y,z) }, ::aCab, ::aDet1, 3) 
		
	EndCase

	::lGrabo := ::verDocOk()
	
	If ::lGrabo .And. !Empty(::cCodPDV)		
		dbSelectArea("SX5")
		dbSetOrder(1)
		If dbSeek(xFilial("SX5")+"01"+AllTrim(::cSerie)+::cCodPDV)			
			RecLock("SX5",.F.)
			SX5->X5_DESCRI	:= Soma1(::cDoc)
			SX5->X5_DESCSPA	:= Soma1(::cDoc)
			SX5->X5_DESCENG	:= Soma1(::cDoc)
			MsUnLock()
		EndIf	
	EndIf
	
	If !::lGrabo
		If lMsErroAuto
			::cError := MostraErro("SALIDA")
		Else
			::cError := "Documento no grabado."
		EndIf	
	EndIf		
		
RETURN Nil 

/*=====================================================================
|---------------------------------------------------------------------|
| Programa | ARDocSalida | Autor: Andres Demarziani | Fecha: 19/12/2019  |
|---------------------------------------------------------------------|
======================================================================*/
METHOD borrar() CLASS ARDocSalida
	
	Private lMsErroAuto := .F.
	
	If !Empty(::aCab) .And. !Empty(::aDet1)
		Do Case
		
			Case ::cEsp == "NF"
				
				MSExecAuto({|x,y,z| MATA467N(x,y,z) }, ::aCab, ::aDet1, 5) 

			Case ::cEsp == "NDC"
			
				MSExecAuto({|x,y,z| MATA465N(x,y,z) }, ::aCab, ::aDet1, 5) 
				
			Case ::cEsp == "RFN"
			
				MSExecAuto({|x,y,z| MATA462N(x,y,z) }, ::aCab, ::aDet1, 5) 
				
			Case ::cEsp == "NCP"
			
				MSExecAuto({|x,y,z| MATA466N(x,y,z) }, ::aCab, ::aDet1, 5) 
			
		EndCase
		
		If lMsErroAuto
			::cError := MostraErro("SALIDA")
			::lGrabo := .F.
		Else
			::lGrabo := .T.
		EndIf
	EndIf
		
RETURN Nil 

/*=====================================================================
|---------------------------------------------------------------------|
| Programa | ARDocSalida | Autor: Andres Demarziani | Fecha: 29/10/2017  |
|---------------------------------------------------------------------|
======================================================================*/
METHOD verDocOk() CLASS ARDocSalida

	Local aArea	:= GetArea()
	Local lRet	:= .F.
	
	dbSelectArea("SF2")
	dbSetOrder(1)
	If SF2->(dbSeek(xFilial("SF2")+::cDoc+::cSerie+::oCliFor:cCod+::oCliFor:cLoja))
		lRet := .T.
		
		RecLock("SF2",.F.)
		SF2->F2_PV := ::cPDV
		MsUnLock()
	EndIf
	
	RestArea(aArea)
	
Return lRet
