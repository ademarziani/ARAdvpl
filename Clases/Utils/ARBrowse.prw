
#include 'protheus.ch'
#include 'colors.ch'

#define STR0001 "Buscar"
#define STR0002 "Visualizar"
#define STR0003 "Incluir"
#define STR0004 "Modificar"
#define STR0005 "Borrar"
#define STR0006 "Copiar"
#define STR0007 "Se borrará el registro completo con todos sus ítems. ¿Desea continuar?"
#define STR0008 "Leyenda"
	
#define CRLF CHR(13)+CHR(10)
#define TAB CHR(9)

/*=========================================================================
=|=======================================================================|=
=|Programa: ADBROWSE     | Autor: Microsiga         | Fecha: 03/05/2019  |=
=|=======================================================================|=
=|Desc: Arma un listbox segun los array que envie el demandante.         |=
=|=======================================================================|=
=========================================================================*/
CLASS ADBROWSE

	DATA cTabla
	DATA cPref
	DATA cTitulo	
	DATA cSucursal
	DATA nIndice
	DATA cUnico
	DATA lSetAlter
	
	DATA aGetDados
	DATA aListas
	DATA aRutinas
	DATA aBotones
	DATA aCores
	DATA aCorLey
	DATA bTudoOk
	DATA bDespGrv
	
	METHOD New() CONSTRUCTOR
	METHOD setCores()
	METHOD setRutinas()
	METHOD setTudoOk()
	METHOD setDespGrv()
	METHOD setGetDados()
	METHOD setListas()
	METHOD iniciar()
	
ENDCLASS

/*=========================================================================
=|=======================================================================|=
=|Programa: New          | Autor: Microsiga         | Fecha: 03/05/2019  |=
=|=======================================================================|=
=========================================================================*/
METHOD New(cTabla, cTitulo, nIndice, cUnico, aCores) CLASS ADBROWSE

	::cTabla 	:= cTabla
	::cPref		:= IIf(Left(cTabla,1)=="S", Right(cTabla,2), cTabla)
	::cTitulo	:= cTitulo
	::cSucursal	:= IIf(Left(cTabla,2)=="SX", "", xFilial(cTabla))
	::nIndice	:= IIf(nIndice==Nil,1,nIndice)
	::cUnico		:= IIf(cUnico==Nil,"",cUnico)
	::aBotones	:= {}
	::aGetDados	:= {}
	::aListas	:= {}
	::lSetAlter	:= .T.

	::setCores(aCores)
	::setRutinas ({{ OemToAnsi(STR0001), 'PesqBrw'   , 0, 1, 0, NIL },;	// Buscar
				{ OemToAnsi(STR0002), 'U_ADBROW01', 0, 2, 0, NIL },;		// Visualizar
				{ OemToAnsi(STR0003), 'U_ADBROW01', 0, 3, 0, NIL },;		// Incluir
				{ OemToAnsi(STR0004), 'U_ADBROW01', 0, 4, 2, NIL },;		// Modificar
				{ OemToAnsi(STR0005), 'U_ADBROW01', 0, 5, 1, NIL },;		// Borrar
				{ OemToAnsi(STR0006), 'U_ADBROW02', 0, 4, 0, NIL }})		// Copia
	
	

RETURN Nil

/*=========================================================================
=|=======================================================================|=
=|Programa: setRutinas   | Autor: Microsiga         | Fecha: 03/05/2019  |=
=|=======================================================================|=
=========================================================================*/
METHOD setCores(aCores) CLASS ADBROWSE

	Local aCorTmp	:= {}
	Local aCorLey	:= {}	
	Local nX
	
	If aCores <> Nil
		For nX := 1 To Len(aCores)
			aAdd(aCorTmp, {aCores[nX][1], aCores[nX][2]})
			aAdd(aCorLey, {aCores[nX][2], aCores[nX][3]})
		Next nX
		
		::aCores 	:= aClone(aCorTmp)
		::aCorLey	:= aClone(aCorLey)
	Else
		::aCores 	:= Nil
		::aCorLey	:= Nil
	EndIf
	
RETURN Nil


/*=========================================================================
=|=======================================================================|=
=|Programa: setRutinas   | Autor: Microsiga         | Fecha: 03/05/2019  |=
=|=======================================================================|=
=========================================================================*/
METHOD setRutinas(aRutinas) CLASS ADBROWSE
	
	::aRutinas := aRutinas
	
	If ::aCores <> Nil
		aAdd(::aRutinas, { OemToAnsi(STR0008), 'U_ADLEYE01', 0, 9, 0, NIL })	
	EndIf
	
RETURN Nil

/*=========================================================================
=|=======================================================================|=
=|Programa: setTudoOk    | Autor: Microsiga         | Fecha: 03/05/2019  |=
=|=======================================================================|=
=========================================================================*/
METHOD setTudoOk(bTudoOk) CLASS ADBROWSE
	
	::bTudoOk := bTudoOk
	
RETURN Nil

/*=========================================================================
=|=======================================================================|=
=|Programa: setTudoOk    | Autor: Microsiga         | Fecha: 03/05/2019  |=
=|=======================================================================|=
=========================================================================*/
METHOD setDespGrv(bDespGrv) CLASS ADBROWSE
	
	::bDespGrv := bDespGrv
	
RETURN Nil

/*=========================================================================
=|=======================================================================|=
=|Programa: setGetDados  | Autor: Microsiga         | Fecha: 03/05/2019  |=
=|=======================================================================|=
=========================================================================*/
METHOD setGetDados(aGetDados) CLASS ADBROWSE
	
	::aGetDados := aGetDados
	
RETURN Nil

/*=========================================================================
=|=======================================================================|=
=|Programa: setListas    | Autor: Microsiga         | Fecha: 03/05/2019  |=
=|=======================================================================|=
=========================================================================*/
METHOD setListas(aListas) CLASS ADBROWSE
	
	::aListas := aListas
	
RETURN Nil

/*=========================================================================
=|=======================================================================|=
=|Programa: New          | Autor: Microsiga         | Fecha: 03/05/2019  |=
=|=======================================================================|=
=========================================================================*/
METHOD iniciar() CLASS ADBROWSE

	Private cCadastro	:= ::cTitulo
	Private aRotina	:= ::aRutinas
	Private cAlias	:= ::cTabla
	Private oSelfBr	:= Self

	dbSelectArea(cAlias)
	dbSetOrder(::nIndice)

	mBrowse(06,01,22,75,cAlias,,,,,,::aCores)

RETURN Nil

/*=========================================================================
=|=======================================================================|=
=|Programa: ADBROW01     | Autor: Microsiga         | Fecha: 03/05/2019  |=
=|=======================================================================|=
=|Desc: User Function para el ABM del objeto que creo.                   |=
=|=======================================================================|=
=========================================================================*/
User Function ADBROW01(cAlias, nReg, nOpcX)

	Local cTitulo	:= oSelfBr:cTitulo
	Local cTabla	:= oSelfBr:cTabla
	Local cPref		:= oSelfBr:cPref
	Local cSucursal	:= oSelfBr:cSucursal
	Local aGetDados	:= oSelfBr:aGetDados
	Local aListas	:= oSelfBr:aListas
	Local lSetAlter	:= oSelfBr:lSetAlter
	Local nMaxGD	:= Len(aGetDados)
	Local nMaxList	:= Len(aListas)
	Local aFolders	:= {}
	
	Local nY
	Local lOkEnt	:= .F.
	Local lVirtual	:= .F.
	Local nOpca

	Local nSup		:= 0
	Local nIzq		:= 0
	Local nInf		:= 0
	Local nDer		:= 0
	Local lCopia 	:= IsInCallStack("U_ADBROW02")
	Local nX
	Local oDlg
	Local oFolder
	
	Local bOk		:= {||lOkEnt:=.T.,If(ADBROTOK(oSelfBr),If(!Obrigatorio(aGets,aTela),lOkEnt:=.F.,oDlg:End()),nOpcA:=0)}
	Local bCancel	:= {||lOkEnt:=.F.,oDlg:End()}
	Local aButtons	:= oSelfBr:aBotones

	Private aTela	:= Array(0,0)
	Private aGets	:= Array(0)
	Private bCampo	:= { |nCPO| Field(nCPO) }

	Private lRefresh:= .T.
	
	PRIVATE VISUAL	:= (aRotina[nOpcX,4] == 2)
	PRIVATE INCLUI	:= (aRotina[nOpcX,4] == 3)
	PRIVATE ALTERA	:= (aRotina[nOpcX,4] == 4)
	PRIVATE DELETA	:= (aRotina[nOpcX,4] == 5)

	//-----------------
	// Monto Enchoice
	//-----------------
	RegToMemory(cTabla, INCLUI, .F.)
	
	//-----------------
	// Cargos GetDados
	//-----------------
	For nX := 1 To nMaxGD
		aAdd(aFolders, aGetDados[nX]:cTitulo)
		
		aGetDados[nX]:getDatosTabla()

		If VISUAL .OR. DELETA
			aGetDados[nX]:setAlter(.F.)
		ElseIf lSetAlter
			aGetDados[nX]:setAlter(INCLUI .Or. ALTERA)
		EndIf
		
		If lCopia
			aGetDados[nX]:aRecnos := {}
		EndIf
	Next nX	

	//---------------
	// Cargos Listas
	//---------------
	For nX := 1 To nMaxList
		aAdd(aFolders, aListas[nX]:cTitulo)	
	Next nX		

	//-----------------------------
	// Si es copia, cambia la cosa
	//-----------------------------
	If lCopia
		INCLUI := .T.
	EndIf

	//----------------------------------------------
	// Calculo super numeros para tamaño de ventana
	//----------------------------------------------
	aSize := MsAdvSize()
	aObjects := {}
	AAdd( aObjects, { 100, 100, .t., .t. } )
	AAdd( aObjects, { 100, 100, .t., .t. } )
	aInfo := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 3, 3 }
	aPosObj := MsObjSize( aInfo, aObjects )
	aPosGet := MsObjGetPos(aSize[3]-aSize[1],315,{{003,033,160,200,240,263}} )
	nGetLin := aPosObj[2,1]

	nSup := aPosObj[2,1]
	nIzq := aPosObj[2,2]
	nInf := aPosObj[2,3]
	nDer := aPosObj[2,4]

	//-------------------
	// Inicio de Ventana
	//-------------------
	DEFINE MSDIALOG oDlg TITLE cTitulo FROM 000,000 TO aSize[6],aSize[5] OF oMainWnd PIXEL

	EnChoice(cAlias, nReg, nOpcX,,,,,aPosObj[1],,3,,,,,,lVirtual)

	oFolder := TFolder():New(nSup,nIzq,aFolders,,oDlg,,,,.T.,,nDer,nInf)

	For nX := 1 To Len(oFolder:aDialogs)
		If nX <= nMaxGD
			aGetDados[nX]:getGetDados(oFolder:aDialogs[nX])
		Else
			aListas[nX-nMaxGD]:getTwBrowse(oFolder:aDialogs[nX])
		EndIf
	Next nX

	ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg, bOK, bCancel,, aButtons)
	//-----------------
	// Fin de Ventana
	//-----------------
	
	If lOkEnt .And. DELETA
		lOkEnt := MsgYesNo(OemToAnsi(STR0007))
	EndIf
		
	If lOkEnt

		//-----------------------------
		// Comienzo grabacion de datos
		//-----------------------------
		Begin Transaction
			
			While __lSX8
				ConfirmSX8()
			EndDo		
			
			dbSelectArea(cTabla)
			
			RecLock(cTabla,INCLUI)
			If !DELETA
				For nY := 1 TO FCount()
					FieldPut(nY,M->&(EVAL(bCampo,nY)))
				Next nY
				&(cPref+"_FILIAL") := cSucursal
			Else
				DbDelete()
			EndIf
			MsUnLock()

			If INCLUI .Or. ALTERA .Or. DELETA
				For nX := 1 To nMaxGD
					aGetDados[nX]:grabaDatosTabla(DELETA)
				Next nX
			EndIf
			
			If oSelfBr:bDespGrv <> Nil
				Eval(oSelfBr:bDespGrv)
			EndIf
		
		End Transaction
		
	Else
	
		While __lSX8
			RollBackSX8()
		EndDo
	
	EndIf
	
RETURN Nil

/*=========================================================================
=|=======================================================================|=
=|Programa: ADBROW01     | Autor: Microsiga         | Fecha: 03/05/2019  |=
=|=======================================================================|=
=|Desc: User Function para tratamiento de copia de datos.                |=
=|=======================================================================|=
=========================================================================*/
User Function ADBROW02(cAlias, nReg, nOpcX)

	U_ADBROW01(cAlias, nReg, nOpcX)

RETURN Nil

/*=========================================================================
=|=======================================================================|=
=|Programa: ADBROW01     | Autor: Microsiga         | Fecha: 03/05/2019  |=
=|=======================================================================|=
=|Desc: User Function para tratamiento de copia de datos.                |=
=|=======================================================================|=
=========================================================================*/
Static Function ADBROTOK(oADBro)

	Local lRet 	:= .T.
	Local cCodUn
	Local aArea	

	If INCLUI .And. !Empty(oADBro:cUnico)
		aArea 	:= GetArea()
		cCodUn	:= &(oADBro:cUnico)
		
		dbSelectArea(oADBro:cTabla)
		dbSetOrder(oADBro:nIndice)
		If dbSeek(oADBro:cSucursal+cCodUn)
			MsgStop("Ya existe una registro con la clave '"+cCodUn+"' y no se podrá de dar de alta.","Registro Existente")
			lRet := .F.
		EndIf
		
		RestArea(aArea)
	EndIf
		
	If lRet .And. oADBro:bTudoOk <> Nil
		lRet := Eval(oADBro:bTudoOk)
	EndIf

Return lRet

/*=========================================================================
=|=======================================================================|=
=|Programa: ADLEYE01     | Autor: Microsiga         | Fecha: 03/05/2019  |=
=|=======================================================================|=
=|Desc: User Function para tratamiento de copia de datos.                |=
=|=======================================================================|=
=========================================================================*/
User Function ADLEYE01()

	BrwLegenda("Estados","Leyenda",oSelfBr:aCorLey)

RETURN Nil
