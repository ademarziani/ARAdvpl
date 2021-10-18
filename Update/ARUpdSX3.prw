#include 'protheus.ch'
#include 'colors.ch'

#DEFINE USADO01 Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
				Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
				Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128)	
				
#DEFINE USADO02 Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
				Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
				Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)

//#DEFINE RESERV01 Chr(254) + Chr(192)
#DEFINE RESERV01 Chr(13) + Chr(0)

#DEFINE OBRIGAT01 '€'

#DEFINE	TABLA	    01
#DEFINE	ORDEN	    02
#DEFINE	CAMPO	    03
#DEFINE	TIPO	    04
#DEFINE	TAM	        05
#DEFINE	DEC	        06
#DEFINE	PICT	    07
#DEFINE	TIT	        08
#DEFINE	DESCRIP	    09
#DEFINE	CONTEXT	    10
#DEFINE	USADO	    11
#DEFINE	BROWSE	    12
#DEFINE	OBLIG	    13
#DEFINE	VISUAL	    14
#DEFINE	INICIA	    15
#DEFINE	F3	        16
#DEFINE	VALID	    17
#DEFINE	VLDUSER	    18
#DEFINE	CBOX	    19
#DEFINE	FOLDER	    20
#DEFINE	WHEN	    21
#DEFINE	INIBROW	    22
#DEFINE	GRPSXG	    23

#DEFINE SIMPLES Char( 39 )
#DEFINE DUPLAS  Char( 34 )

#DEFINE CSSBOTAO	"QPushButton { color: #024670; "+;
"    border-image: url(rpo:fwstd_btn_nml.png) 3 3 3 3 stretch; "+;
"    border-top-width: 3px; "+;
"    border-left-width: 3px; "+;
"    border-right-width: 3px; "+;
"    border-bottom-width: 3px }"+;
"QPushButton:pressed {	color: #FFFFFF; "+;
"    border-image: url(rpo:fwstd_btn_prd.png) 3 3 3 3 stretch; "+;
"    border-top-width: 3px; "+;
"    border-left-width: 3px; "+;
"    border-right-width: 3px; "+;
"    border-bottom-width: 3px }"

//--------------------------------------------------------------------
/*/{Protheus.doc} ARUpdSX3
Função de update de dicionários para compatibilização

@author TOTVS Protheus
@since  15/11/2017
@obs    Gerado por EXPORDIC - V.5.4.1.2 EFS / Upd. V.4.21.17 EFS
@version 1.0
/*/
//--------------------------------------------------------------------
User Function ARUpdSX3( cEmpAmb, cFilAmb )

Local   aSay      := {}
Local   aButton   := {}
Local   aMarcadas := {}
Local   cTitulo   := "Actualización de diccionario de datos."

Local   cDesc1    := "Esta rutina tiene como funcionalidad realizar la actualización del diccionario de datos."
Local   cDesc2    := "Este proceso deberá ser ejecutado en modo EXCLUSIVO; ningún usuario deberá estar"
Local   cDesc3    := "dentro del sistema."
Local   cDesc4    := ""
Local   cDesc5    := ""
Local   lOk       := .F.
Local   lAuto     := ( cEmpAmb <> NIL .or. cFilAmb <> NIL )

Private oMainWnd  := NIL
Private oProcess  := NIL
Private lDicBD    := ( FindFunction( "MPDicInDB" ) .AND. MPDicInDB() )
Private	aSX3	  := {}

#IFDEF TOP
    TCInternal( 5, "*OFF" ) // Desliga Refresh no Lock do Top
#ENDIF

__cInterNet := NIL
__lPYME     := .F.

Set Dele On

// Mensagens de Tela Inicial
aAdd( aSay, cDesc1 )
aAdd( aSay, cDesc2 )
aAdd( aSay, cDesc3 )
aAdd( aSay, cDesc4 )
aAdd( aSay, cDesc5 )
//aAdd( aSay, cDesc6 )
//aAdd( aSay, cDesc7 )

// Botoes Tela Inicial
aAdd(  aButton, {  1, .T., { || lOk := .T., FechaBatch() } } )
aAdd(  aButton, {  2, .T., { || lOk := .F., FechaBatch() } } )

If lAuto
	lOk := .T.
Else
	FormBatch(  cTitulo,  aSay,  aButton )
EndIf

If lOk
	If lAuto
		aMarcadas :={{ cEmpAmb, cFilAmb, "" }}
	Else
		/*
		If FindFunction("FWAuthAdmin")
			If !FWAuthAdmin()
				Final( "Actualización no realizada." )
			EndIf
		EndIf
		*/
		
		aMarcadas := EscEmpresa()
	EndIf

	If !Empty( aMarcadas )
		If lAuto .OR. MsgNoYes( "¿Confirma la actualización del diccionario de datos?", cTitulo )
			oProcess := MsNewProcess():New( { | lEnd | lOk := FSTProc( @lEnd, aMarcadas, lAuto ) }, "Actualizando", "Aguarde, actualizando ...", .F. )
			oProcess:Activate()

			If lAuto
				If lOk
					MsgStop( "Actualización realizada.", "ARUpdSX3" )
				Else
					MsgStop( "Actualización no realizada.", "ARUpdSX3" )
				EndIf
				dbCloseAll()
			Else
				If lOk
					Final("Actualización realizada.")
				Else
					Final("Actualización no realizada.")
				EndIf
			EndIf

		Else
			Final("Actualización no realizada.")
		EndIf
	Else
		Final("Actualización no realizada.")
	EndIf

EndIf

Return NIL


//--------------------------------------------------------------------
/*/{Protheus.doc} FSTProc
Função de processamento da gravação dos arquivos

@author TOTVS Protheus
@since  15/11/2017
@obs    Gerado por EXPORDIC - V.5.4.1.2 EFS / Upd. V.4.21.17 EFS
@version 1.0
/*/
//--------------------------------------------------------------------
Static Function FSTProc( lEnd, aMarcadas, lAuto )
Local   aInfo     := {}
Local   aRecnoSM0 := {}
Local   cFile     := ""
Local   cMask     := "Archivos Texto" + "(*.TXT)|*.txt|"
Local   cTCBuild  := "TCGetBuild"
Local   cTexto    := ""
Local   cTopBuild := ""
Local   lOpen     := .F.
Local   lRet      := .T.
Local   nI        := 0
Local   nPos      := 0
Local   nX        := 0
Local   oDlg      := NIL
Local   oFont     := NIL
Local   oMemo     := NIL
Local 	lActSX3

Private aArqUpd   := {}

If ( lOpen := MyOpenSm0(.T.) )

	dbSelectArea( "SM0" )
	dbGoTop()

	While !SM0->( EOF() )
		// Só adiciona no aRecnoSM0 se a empresa for diferente
		If aScan( aRecnoSM0, { |x| x[2] == SM0->M0_CODIGO } ) == 0 ;
		   .AND. aScan( aMarcadas, { |x| x[1] == SM0->M0_CODIGO } ) > 0
			aAdd( aRecnoSM0, { Recno(), SM0->M0_CODIGO } )
		EndIf
		SM0->( dbSkip() )
	End

	SM0->( dbCloseArea() )

	If lOpen

		For nI := 1 To Len( aRecnoSM0 )

			If !( lOpen := MyOpenSm0(.F.) )
				MsgStop( "Actualización de la empresa " + aRecnoSM0[nI][2] + " no efectuada." )
				Exit
			EndIf

			SM0->( dbGoTo( aRecnoSM0[nI][1] ) )

			RpcSetType( 3 )
			RpcSetEnv( SM0->M0_CODIGO, SM0->M0_CODFIL )

			lMsFinalAuto := .F.
			lMsHelpAuto  := .F.

			lActSX3 := FGetCpos()

			If lActSX3
				AutoGrLog( Replicate( "-", 128 ) )
				AutoGrLog( Replicate( " ", 128 ) )
				AutoGrLog( "Log de actualización de diccionarios" )
				AutoGrLog( Replicate( " ", 128 ) )
				AutoGrLog( Replicate( "-", 128 ) )
				AutoGrLog( " " )
				AutoGrLog( " Dados Ambiente" )
				AutoGrLog( " --------------------" )
				AutoGrLog( " Empresa / Sucursal.: " + cEmpAnt + "/" + cFilAnt )
				AutoGrLog( " Nombre Empresa.....: " + Capital( AllTrim( GetAdvFVal( "SM0", "M0_NOMECOM", cEmpAnt + cFilAnt, 1, "" ) ) ) )
				AutoGrLog( " Nombre Sucursal....: " + Capital( AllTrim( GetAdvFVal( "SM0", "M0_FILIAL" , cEmpAnt + cFilAnt, 1, "" ) ) ) )
				AutoGrLog( " DataBase...........: " + DtoC( dDataBase ) )
				AutoGrLog( " Data / Hora Ínicio.: " + DtoC( Date() )  + " / " + Time() )
				AutoGrLog( " Environment........: " + GetEnvServer()  )
				AutoGrLog( " StartPath..........: " + GetSrvProfString( "StartPath", "" ) )
				AutoGrLog( " RootPath...........: " + GetSrvProfString( "RootPath" , "" ) )
				AutoGrLog( " Versão.............: " + GetVersao(.T.) )
				AutoGrLog( " Usuário TOTVS .....: " + __cUserId + " " +  cUserName )
				AutoGrLog( " Computer Name......: " + GetComputerName() )

				aInfo   := GetUserInfo()
				If ( nPos    := aScan( aInfo,{ |x,y| x[3] == ThreadId() } ) ) > 0
					AutoGrLog( " " )
					AutoGrLog( " Dados Thread" )
					AutoGrLog( " --------------------" )
					AutoGrLog( " Usuário de red.....: " + aInfo[nPos][1] )
					AutoGrLog( " Estació............: " + aInfo[nPos][2] )
					AutoGrLog( " Programa Inicial...: " + aInfo[nPos][5] )
					AutoGrLog( " Environment........: " + aInfo[nPos][6] )
					AutoGrLog( " Conexión...........: " + AllTrim( StrTran( StrTran( aInfo[nPos][7], Chr( 13 ), "" ), Chr( 10 ), "" ) ) )
				EndIf
				AutoGrLog( Replicate( "-", 128 ) )
				AutoGrLog( " " )

				If !lAuto
					AutoGrLog( Replicate( "-", 128 ) )
					AutoGrLog( "Empresa : " + SM0->M0_CODIGO + "/" + SM0->M0_NOME + CRLF )
				EndIf

				oProcess:SetRegua1( 8 )
			
				//------------------------------------
				// Atualiza o dicionário SX3
				//------------------------------------
				FSAtuSX3()

				oProcess:IncRegua1( "Diccionario de datos" + " - " + SM0->M0_CODIGO + " " + SM0->M0_NOME + " ..." )
				oProcess:IncRegua2( "Actualizando campos/índices" )

				// Alteração física dos arquivos
				__SetX31Mode( .F. )

				If FindFunction(cTCBuild)
					cTopBuild := &cTCBuild.()
				EndIf

				For nX := 1 To Len( aArqUpd )

					If cTopBuild >= "20090811" .AND. TcInternal( 89 ) == "CLOB_SUPPORTED"
						If ( ( aArqUpd[nX] >= "NQ " .AND. aArqUpd[nX] <= "NZZ" ) .OR. ( aArqUpd[nX] >= "O0 " .AND. aArqUpd[nX] <= "NZZ" ) ) .AND.;
							!aArqUpd[nX] $ "NQD,NQF,NQP,NQT"
							TcInternal( 25, "CLOB" )
						EndIf
					EndIf

					If Select( aArqUpd[nX] ) > 0
						dbSelectArea( aArqUpd[nX] )
						dbCloseArea()
					EndIf

					X31UpdTable( aArqUpd[nX] )

					If __GetX31Error()
						Alert( __GetX31Trace() )
						MsgStop( "Ocurrión un error desconocido durante la actualización de la tabla : " + aArqUpd[nX] + ". Verifique la integridad del diccionario y la tabla.", "Atención" )
						AutoGrLog( "Ocurrión un error desconocido durante la actualización de la tabla : " + aArqUpd[nX] )
					EndIf

					If cTopBuild >= "20090811" .AND. TcInternal( 89 ) == "CLOB_SUPPORTED"
						TcInternal( 25, "OFF" )
					EndIf

				Next nX
				
				AutoGrLog( Replicate( "-", 128 ) )
				AutoGrLog( " Fecha / Hora Final.: " + DtoC( Date() ) + " / " + Time() )
				AutoGrLog( Replicate( "-", 128 ) )
			EndIf

			RpcClearEnv()

		Next nI

		If !lAuto

			cTexto := LeLog()

			Define Font oFont Name "Mono AS" Size 5, 12

			Define MsDialog oDlg Title "Actualización finalizada." From 3, 0 to 340, 417 Pixel

			@ 5, 5 Get oMemo Var cTexto Memo Size 200, 145 Of oDlg Pixel
			oMemo:bRClicked := { || AllwaysTrue() }
			oMemo:oFont     := oFont

			Define SButton From 153, 175 Type  1 Action oDlg:End() Enable Of oDlg Pixel // Apaga
			Define SButton From 153, 145 Type 13 Action ( cFile := cGetFile( cMask, "" ), If( cFile == "", .T., ;
			MemoWrite( cFile, cTexto ) ) ) Enable Of oDlg Pixel

			Activate MsDialog oDlg Center

		EndIf

	EndIf

Else

	lRet := .F.

EndIf

Return lRet

//--------------------------------------------------------------------
/*/{Protheus.doc} FSAtuSX3
Função de processamento da gravação do SX3 - Campos

@author TOTVS Protheus
@since  15/11/2017
@obs    Gerado por EXPORDIC - V.5.4.1.2 EFS / Upd. V.4.21.17 EFS
@version 1.0
/*/
//--------------------------------------------------------------------
Static Function FSAtuSX3()
Local aEstrut   := {}
Local cAlias    := ""
Local cAliasAtu := ""
Local cSeqAtu   := ""
Local nI        := 0
Local nJ        := 0
Local nPosArq   := 0
Local nPosCpo   := 0
Local nPosOrd   := 0
Local nPosSXG   := 0
Local nPosTam   := 0
Local nPosVld   := 0
Local nSeqAtu   := 0
Local nPosTit1  := 0
Local nPosTit2  := 0
Local nPosTit3  := 0
Local nTamSeek  := Len( SX3->X3_CAMPO )
Local aHlpPor   := {}
Local aHlpEng   := {}
Local aHlpSpa   := {}

AutoGrLog( "Inicio Actualización" + " SX3" + CRLF )

aEstrut := { { "X3_ARQUIVO", 0 }, { "X3_ORDEM"  , 0 }, { "X3_CAMPO"  , 0 }, { "X3_TIPO"   , 0 }, { "X3_TAMANHO", 0 }, { "X3_DECIMAL", 0 }, { "X3_TITULO" , 0 }, ;
             { "X3_TITSPA" , 0 }, { "X3_TITENG" , 0 }, { "X3_DESCRIC", 0 }, { "X3_DESCSPA", 0 }, { "X3_DESCENG", 0 }, { "X3_PICTURE", 0 }, { "X3_VALID"  , 0 }, ;
             { "X3_USADO"  , 0 }, { "X3_RELACAO", 0 }, { "X3_F3"     , 0 }, { "X3_NIVEL"  , 0 }, { "X3_RESERV" , 0 }, { "X3_CHECK"  , 0 }, { "X3_TRIGGER", 0 }, ;
             { "X3_PROPRI" , 0 }, { "X3_BROWSE" , 0 }, { "X3_VISUAL" , 0 }, { "X3_CONTEXT", 0 }, { "X3_OBRIGAT", 0 }, { "X3_VLDUSER", 0 }, { "X3_CBOX"   , 0 }, ;
             { "X3_CBOXSPA", 0 }, { "X3_CBOXENG", 0 }, { "X3_PICTVAR", 0 }, { "X3_WHEN"   , 0 }, { "X3_INIBRW" , 0 }, { "X3_GRPSXG" , 0 }, { "X3_FOLDER" , 0 }, ;
             { "X3_CONDSQL", 0 }, { "X3_CHKSQL" , 0 }, { "X3_IDXSRV" , 0 }, { "X3_ORTOGRA", 0 }, { "X3_TELA"   , 0 }, { "X3_POSLGT" , 0 }, { "X3_IDXFLD" , 0 }, ;
             { "X3_AGRUP"  , 0 }, { "X3_MODAL"  , 0 }, { "X3_PYME"   , 0 } }

aEval( aEstrut, { |x| x[2] := SX3->( FieldPos( x[1] ) ) } )

//
// Atualizando dicionário
//
nPosArq := aScan( aEstrut, { |x| AllTrim( x[1] ) == "X3_ARQUIVO" } )
nPosOrd := aScan( aEstrut, { |x| AllTrim( x[1] ) == "X3_ORDEM"   } )
nPosCpo := aScan( aEstrut, { |x| AllTrim( x[1] ) == "X3_CAMPO"   } )
nPosTam := aScan( aEstrut, { |x| AllTrim( x[1] ) == "X3_TAMANHO" } )
nPosSXG := aScan( aEstrut, { |x| AllTrim( x[1] ) == "X3_GRPSXG"  } )
nPosVld := aScan( aEstrut, { |x| AllTrim( x[1] ) == "X3_VALID"   } )
nPosTit1 := aScan( aEstrut, { |x| AllTrim( x[1] ) == "X3_TITULO" } )
nPosTit2 := aScan( aEstrut, { |x| AllTrim( x[1] ) == "X3_TITSPA" } )
nPosTit3 := aScan( aEstrut, { |x| AllTrim( x[1] ) == "X3_TITENG" } )

aSort( aSX3,,, { |x,y| x[nPosArq]+x[nPosOrd]+x[nPosCpo] < y[nPosArq]+y[nPosOrd]+y[nPosCpo] } )

oProcess:SetRegua2( Len( aSX3 ) )

dbSelectArea( "SX3" )
dbSetOrder( 2 )
cAliasAtu := ""

For nI := 1 To Len( aSX3 )

	//
	// Verifica se o campo faz parte de um grupo e ajusta tamanho
	//
	If !Empty( aSX3[nI][nPosSXG] )
		SXG->( dbSetOrder( 1 ) )
		If SXG->( MSSeek( aSX3[nI][nPosSXG] ) )
			If aSX3[nI][nPosTam] <> SXG->XG_SIZE
				aSX3[nI][nPosTam] := SXG->XG_SIZE
				AutoGrLog( "O tamanho do campo " + aSX3[nI][nPosCpo] + " NÃO atualizado e foi mantido em [" + ;
				AllTrim( Str( SXG->XG_SIZE ) ) + "]" + CRLF + ;
				" por pertencer ao grupo de campos [" + SXG->XG_GRUPO + "]" + CRLF )
			EndIf
		EndIf
	EndIf

	SX3->( dbSetOrder( 2 ) )

	If !( aSX3[nI][nPosArq] $ cAlias )
		cAlias += aSX3[nI][nPosArq] + "/"
		aAdd( aArqUpd, aSX3[nI][nPosArq] )
	EndIf

	If !SX3->( dbSeek( PadR( aSX3[nI][nPosCpo], nTamSeek ) ) )

		//
		// Busca ultima ocorrencia do alias
		//
		If ( aSX3[nI][nPosArq] <> cAliasAtu )
			cSeqAtu   := "00"
			cAliasAtu := aSX3[nI][nPosArq]

			dbSetOrder( 1 )
			SX3->( dbSeek( cAliasAtu + "ZZ", .T. ) )
			dbSkip( -1 )

			If ( SX3->X3_ARQUIVO == cAliasAtu )
				cSeqAtu := SX3->X3_ORDEM
			EndIf

			nSeqAtu := Val( RetAsc( cSeqAtu, 3, .F. ) )
		EndIf

		nSeqAtu++
		cSeqAtu := RetAsc( Str( nSeqAtu ), 2, .T. )

		RecLock( "SX3", .T. )
		For nJ := 1 To Len( aSX3[nI] )
			If     nJ == nPosOrd  // Ordem
				SX3->( FieldPut( FieldPos( aEstrut[nJ][1] ), cSeqAtu ) )

			ElseIf aEstrut[nJ][2] > 0
				SX3->( FieldPut( FieldPos( aEstrut[nJ][1] ), aSX3[nI][nJ] ) )

			EndIf
		Next nJ

		dbCommit()
		MsUnLock()

		AutoGrLog( "Campo Creado " + aSX3[nI][nPosCpo] )

	Else
	
		AutoGrLog( "Campo Modificado " + aSX3[nI][nPosCpo] )
		
		RecLock( "SX3", .F. )
		For nJ := 1 To Len( aSX3[nI] )		
			If !(AllTrim(aEstrut[nJ][1]) $ "X3_TIPO/X3_TAMANHO/X3_DECIMAL/X3_CONTEXT")
				SX3->( FieldPut( FieldPos( aEstrut[nJ][1] ), aSX3[nI][nJ] ) )
			EndIf
		Next nJ
		MsUnLock()
		
	EndIf
	
	aHlpPor := {}
	aHlpSpa := {}
	aHlpEng := {}
	
	aAdd( aHlpPor, aSX3[nI][nPosTit1] )
	aAdd( aHlpSpa, aSX3[nI][nPosTit2] )
	aAdd( aHlpEng, aSX3[nI][nPosTit3] )
	
	PutHelp( "P"+aSX3[nI][nPosCpo], aHlpPor, aHlpEng, aHlpSpa, .T. )
	AutoGrLog( "Help actualizado " + aSX3[nI][nPosCpo] )

	oProcess:IncRegua2( "Actualizando Campos de Tablas (SX3)..." )	
	
Next nI

AutoGrLog( CRLF + "Fin Actualización" + " SX3" + CRLF + Replicate( "-", 128 ) + CRLF )

Return NIL

Static Function EscEmpresa()

//---------------------------------------------
// Parâmetro  nTipo
// 1 - Monta com Todas Empresas/Filiais
// 2 - Monta só com Empresas
// 3 - Monta só com Filiais de uma Empresa
//
// Parâmetro  aMarcadas
// Vetor com Empresas/Filiais pré marcadas
//
// Parâmetro  cEmpSel
// Empresa que será usada para montar seleção
//---------------------------------------------
Local   aRet      := {}
Local   aSalvAmb  := GetArea()
Local   aSalvSM0  := {}
Local   aVetor    := {}
Local   cMascEmp  := "??"
Local   cVar      := ""
Local   lChk      := .F.
Local   lTeveMarc := .F.
Local   oNo       := LoadBitmap( GetResources(), "LBNO" )
Local   oOk       := LoadBitmap( GetResources(), "LBOK" )
Local   oDlg, oChkMar, oLbx, oMascEmp, oSay
Local   oButDMar, oButInv, oButMarc, oButOk, oButCanc

Local   aMarcadas := {}

If !MyOpenSm0(.F.)
	Return aRet
EndIf

dbSelectArea( "SM0" )
aSalvSM0 := SM0->( GetArea() )
dbSetOrder( 1 )
dbGoTop()

While !SM0->( EOF() )

	If aScan( aVetor, {|x| x[2] == SM0->M0_CODIGO} ) == 0
		aAdd(  aVetor, { aScan( aMarcadas, {|x| x[1] == SM0->M0_CODIGO .and. x[2] == SM0->M0_CODFIL} ) > 0, SM0->M0_CODIGO, SM0->M0_CODFIL, SM0->M0_NOME, SM0->M0_FILIAL } )
	EndIf

	dbSkip()
End

RestArea( aSalvSM0 )

Define MSDialog  oDlg Title "" From 0, 0 To 280, 395 Pixel

oDlg:cToolTip := "Pantalla para múltiple selección de Empresa/Sucursal"

oDlg:cTitle   := "Seleccione la empresa para actualización"

@ 10, 10 Listbox  oLbx Var  cVar Fields Header " ", " ", "Empresa" Size 178, 095 Of oDlg Pixel
oLbx:SetArray(  aVetor )
oLbx:bLine := {|| {IIf( aVetor[oLbx:nAt, 1], oOk, oNo ), ;
aVetor[oLbx:nAt, 2], ;
aVetor[oLbx:nAt, 4]}}
oLbx:BlDblClick := { || aVetor[oLbx:nAt, 1] := !aVetor[oLbx:nAt, 1], VerTodos( aVetor, @lChk, oChkMar ), oChkMar:Refresh(), oLbx:Refresh()}
oLbx:cToolTip   :=  oDlg:cTitle
oLbx:lHScroll   := .F. // NoScroll

@ 112, 10 CheckBox oChkMar Var  lChk Prompt "Todos" Message "Marca / Desmarca"+ CRLF + "Todos" Size 40, 007 Pixel Of oDlg;
on Click MarcaTodos( lChk, @aVetor, oLbx )

// Marca/Desmarca por mascara
@ 113, 51 Say   oSay Prompt "Empresa" Size  40, 08 Of oDlg Pixel
@ 112, 80 MSGet oMascEmp Var  cMascEmp Size  05, 05 Pixel Picture "@!"  Valid (  cMascEmp := StrTran( cMascEmp, " ", "?" ), oMascEmp:Refresh(), .T. ) ;
Message "Máscara Empresa ( ?? )"  Of oDlg
oSay:cToolTip := oMascEmp:cToolTip

@ 128, 10 Button oButInv    Prompt "&Invertir"  Size 32, 12 Pixel Action ( InvSelecao( @aVetor, oLbx, @lChk, oChkMar ), VerTodos( aVetor, @lChk, oChkMar ) ) ;
Message "Invertir Selección" Of oDlg
oButInv:SetCss( CSSBOTAO )
@ 128, 50 Button oButMarc   Prompt "&Marcar"    Size 32, 12 Pixel Action ( MarcaMas( oLbx, aVetor, cMascEmp, .T. ), VerTodos( aVetor, @lChk, oChkMar ) ) ;
Message "Marcar usando" + CRLF + "Máscara ( ?? )"    Of oDlg
oButMarc:SetCss( CSSBOTAO )
@ 128, 80 Button oButDMar   Prompt "&Desmarcar" Size 32, 12 Pixel Action ( MarcaMas( oLbx, aVetor, cMascEmp, .F. ), VerTodos( aVetor, @lChk, oChkMar ) ) ;
Message "Desmarcar usando" + CRLF + "máscara ( ?? )" Of oDlg
oButDMar:SetCss( CSSBOTAO )
@ 112, 157  Button oButOk   Prompt "Procesar"  Size 32, 12 Pixel Action (  RetSelecao( @aRet, aVetor ), IIf( Len( aRet ) > 0, oDlg:End(), MsgStop( "Ao menos um grupo deve ser selecionado", "ARUpdSX3" ) ) ) ;
Message "Confirma la selección y efectúa el procesamiento" Of oDlg
oButOk:SetCss( CSSBOTAO )
@ 128, 157  Button oButCanc Prompt "Cancelar"   Size 32, 12 Pixel Action ( IIf( lTeveMarc, aRet :=  aMarcadas, .T. ), oDlg:End() ) ;
Message "Cancela el procesamiento y cierra la aplicación" Of oDlg
oButCanc:SetCss( CSSBOTAO )

Activate MSDialog  oDlg Center

RestArea( aSalvAmb )
dbSelectArea( "SM0" )
dbCloseArea()

Return  aRet


//--------------------------------------------------------------------
/*/{Protheus.doc} MarcaTodos
Função auxiliar para marcar/desmarcar todos os ítens do ListBox ativo

@param lMarca  Contéudo para marca .T./.F.
@param aVetor  Vetor do ListBox
@param oLbx    Objeto do ListBox

@author Ernani Forastieri
@since  27/09/2004
@version 1.0
/*/
//--------------------------------------------------------------------
Static Function MarcaTodos( lMarca, aVetor, oLbx )
Local  nI := 0

For nI := 1 To Len( aVetor )
	aVetor[nI][1] := lMarca
Next nI

oLbx:Refresh()

Return NIL


//--------------------------------------------------------------------
/*/{Protheus.doc} InvSelecao
Função auxiliar para inverter a seleção do ListBox ativo

@param aVetor  Vetor do ListBox
@param oLbx    Objeto do ListBox

@author Ernani Forastieri
@since  27/09/2004
@version 1.0
/*/
//--------------------------------------------------------------------
Static Function InvSelecao( aVetor, oLbx )
Local  nI := 0

For nI := 1 To Len( aVetor )
	aVetor[nI][1] := !aVetor[nI][1]
Next nI

oLbx:Refresh()

Return NIL


//--------------------------------------------------------------------
/*/{Protheus.doc} RetSelecao
Função auxiliar que monta o retorno com as seleções

@param aRet    Array que terá o retorno das seleções (é alterado internamente)
@param aVetor  Vetor do ListBox

@author Ernani Forastieri
@since  27/09/2004
@version 1.0
/*/
//--------------------------------------------------------------------
Static Function RetSelecao( aRet, aVetor )
Local  nI    := 0

aRet := {}
For nI := 1 To Len( aVetor )
	If aVetor[nI][1]
		aAdd( aRet, { aVetor[nI][2] , aVetor[nI][3], aVetor[nI][2] +  aVetor[nI][3] } )
	EndIf
Next nI

Return NIL


//--------------------------------------------------------------------
/*/{Protheus.doc} MarcaMas
Função para marcar/desmarcar usando máscaras

@param oLbx     Objeto do ListBox
@param aVetor   Vetor do ListBox
@param cMascEmp Campo com a máscara (???)
@param lMarDes  Marca a ser atribuída .T./.F.

@author Ernani Forastieri
@since  27/09/2004
@version 1.0
/*/
//--------------------------------------------------------------------
Static Function MarcaMas( oLbx, aVetor, cMascEmp, lMarDes )
Local cPos1 := SubStr( cMascEmp, 1, 1 )
Local cPos2 := SubStr( cMascEmp, 2, 1 )
Local nPos  := oLbx:nAt
Local nZ    := 0

For nZ := 1 To Len( aVetor )
	If cPos1 == "?" .or. SubStr( aVetor[nZ][2], 1, 1 ) == cPos1
		If cPos2 == "?" .or. SubStr( aVetor[nZ][2], 2, 1 ) == cPos2
			aVetor[nZ][1] := lMarDes
		EndIf
	EndIf
Next

oLbx:nAt := nPos
oLbx:Refresh()

Return NIL


//--------------------------------------------------------------------
/*/{Protheus.doc} VerTodos
Função auxiliar para verificar se estão todos marcados ou não

@param aVetor   Vetor do ListBox
@param lChk     Marca do CheckBox do marca todos (referncia)
@param oChkMar  Objeto de CheckBox do marca todos

@author Ernani Forastieri
@since  27/09/2004
@version 1.0
/*/
//--------------------------------------------------------------------
Static Function VerTodos( aVetor, lChk, oChkMar )
Local lTTrue := .T.
Local nI     := 0

For nI := 1 To Len( aVetor )
	lTTrue := IIf( !aVetor[nI][1], .F., lTTrue )
Next nI

lChk := IIf( lTTrue, .T., .F. )
oChkMar:Refresh()

Return NIL


//--------------------------------------------------------------------
/*/{Protheus.doc} MyOpenSM0
Função de processamento abertura do SM0 modo exclusivo

@author TOTVS Protheus
@since  15/11/2017
@obs    Gerado por EXPORDIC - V.5.4.1.2 EFS / Upd. V.4.21.17 EFS
@version 1.0
/*/
//--------------------------------------------------------------------
Static Function MyOpenSM0(lShared)
Local lOpen := .F.
Local nLoop := 0

If FindFunction( "OpenSM0Excl" ) .And. AllTrim(GetVersao(.F.)) <> "P10"
	For nLoop := 1 To 20
		If OpenSM0Excl(,.F.)
			lOpen := .T.
			Exit
		EndIf
		Sleep( 500 )
	Next nLoop
Else
	For nLoop := 1 To 20
		dbUseArea( .T., , "SIGAMAT.EMP", "SM0", lShared, .F. )

		If !Empty( Select( "SM0" ) )
			lOpen := .T.
			dbSetIndex( "SIGAMAT.IND" )
			Exit
		EndIf
		Sleep( 500 )
	Next nLoop
EndIf

If !lOpen
	MsgStop( "Não foi possível a abertura da tabela " + ;
	IIf( lShared, "de empresas (SM0).", "de empresas (SM0) de forma exclusiva." ), "ATENÇÃO" )
EndIf

Return lOpen


//--------------------------------------------------------------------
/*/{Protheus.doc} LeLog
Função de leitura do LOG gerado com limitacao de string

@author TOTVS Protheus
@since  15/11/2017
@obs    Gerado por EXPORDIC - V.5.4.1.2 EFS / Upd. V.4.21.17 EFS
@version 1.0
/*/
//--------------------------------------------------------------------
Static Function LeLog()
Local cRet  := ""
Local cFile := NomeAutoLog()
Local cAux  := ""

FT_FUSE( cFile )
FT_FGOTOP()

While !FT_FEOF()

	cAux := FT_FREADLN()

	If Len( cRet ) + Len( cAux ) < 1048000
		cRet += cAux + CRLF
	Else
		cRet += CRLF
		cRet += Replicate( "=" , 128 ) + CRLF
		cRet += "Tamanho de exibição maxima do LOG alcançado." + CRLF
		cRet += "LOG Completo no arquivo " + cFile + CRLF
		cRet += Replicate( "=" , 128 ) + CRLF
		Exit
	EndIf

	FT_FSKIP()
End

FT_FUSE()

Return cRet

/*=====================================================================
|---------------------------------------------------------------------|
| Programa | FGetCpos | Autor: Andres Demarziani | Fecha: 15/02/2019  |
|---------------------------------------------------------------------|
======================================================================*/
Static Function FGetCpos()

	Local lRet  	:= .F.
	Local cTitulo	:= "Importación de Archivo SX3"
    Local oArchivo 	:= INFARCHI():New()
	Local cMsgError	:= ""
    Local cCpo
	Local oDlg
	Local oRuta
	Local cRuta
	Local aLin
    Local cReserv   := IIF(lDicBD, Bin2Str(RESERV01), Chr(254) + Chr(192))
    Local cNoUsa    := IIF(lDicBD, Bin2Str(USADO01), USADO01)
    Local cSiUsa    := IIF(lDicBD, Bin2Str(USADO02), USADO02)
    Local cObrg     := IIF(lDicBD, Bin2Str(OBRIGAT01), OBRIGAT01)
	Local nLin		:= 1

	DEFINE MSDIALOG oDlg TITLE cTitulo FROM 000, 000  TO 120, 700 COLORS 0, 16777215 PIXEL

		@ 011, 008 MSGET oRuta VAR cRuta SIZE 303, 010 OF oDlg COLORS 0, 16777215 PIXEL 

		TBtnBmp2():New(022,630,026,026,"INF_FOLDER2",,,, {|| fSelFile(@oRuta, @cRuta, .T.)}, oDlg, "Archivo...")

		DEFINE SBUTTON FROM 035, 284 TYPE 1 ACTION (lRet := .T., oDlg:End()) ENABLE
		DEFINE SBUTTON FROM 035, 318 TYPE 2 ACTION oDlg:End() ENABLE

	ACTIVATE MSDIALOG oDlg CENTERED

	If lRet
        oArchivo:setToken("|")

        If oArchivo:AbreTxt(cRuta, @cMsgError)
            oArchivo:AvLinTxt()

            While !oArchivo:EOFTxt()
                aLin := oArchivo:LinToArr()
				nLin++

                If Len(aLin) < GRPSXG
                    lRet := .F.
                    AutoGrLog("Linea nro. "+cValToChar(nLin)+": La cantidad de columnas del archivo no puede ser menor a "+cValToChar(GRPSXG))
                EndIf

                If Empty(aLin[TABLA])
                    lRet := .F.
                    AutoGrLog("Linea nro. "+cValToChar(nLin)+": No se informo la tabla a actualizar.")
                EndIf

                If !SX2->(dbSeek(aLin[TABLA]))
                    lRet := .F.
                    AutoGrLog("Linea nro. "+cValToChar(nLin)+": La tabla informada no existe.")
                EndIf

				If lRet
                	cCpo := IIf(Left(aLin[TABLA],1)=="S", SubStr(aLin[TABLA],2,2), SubStr(aLin[TABLA],1,3))
                	cCpo += "_"
                	cCpo += aLin[CAMPO]
					cCpo := Left(cCpo, 10)

                	aAdd( aSX3, { ;
                	    aLin[TABLA]																, ; //X3_ARQUIVO
                	    aLin[ORDEN]																, ; //X3_ORDEM
                	    cCpo    	        													, ; //X3_CAMPO
                	    aLin[TIPO]																, ; //X3_TIPO
                	    Val(aLin[TAM])															, ; //X3_TAMANHO
                	    Val(aLin[DEC])															, ; //X3_DECIMAL
                	    aLin[TIT]																, ; //X3_TITULO
                	    aLin[TIT]	    														, ; //X3_TITSPA
                	    aLin[TIT]																, ; //X3_TITENG
                	    aLin[DESCRIP]	    													, ; //X3_DESCRIC
                	    aLin[DESCRIP]	        												, ; //X3_DESCSPA
                	    aLin[DESCRIP]		        											, ; //X3_DESCENG
                	    aLin[PICT]																, ; //X3_PICTURE
                	    aLin[VALID]																, ; //X3_VALID
                	    IIf(Lower(aLin[USADO])=="x", cSiUsa, cNoUsa)							, ; //X3_USADO
                	    aLin[INICIA]															, ; //X3_RELACAO
                	    aLin[F3]																, ; //X3_F3
                	    1																		, ; //X3_NIVEL
                	    cReserv                                         						, ; //X3_RESERV
                	    ''																		, ; //X3_CHECK
                	    ''																		, ; //X3_TRIGGER
                	    'U'																		, ; //X3_PROPRI
                	    IIf(Lower(aLin[BROWSE])=="x","S","N")									, ; //X3_BROWSE
                	    IIf(Lower(aLin[VISUAL])=="x","V","A")									, ; //X3_VISUAL
                	    IIf(Upper(aLin[CONTEXT])=="V", "V", "R")    							, ; //X3_CONTEXT
                	    IIf(Lower(aLin[OBLIG])=="x", cObrg, "")                                 , ; //X3_OBRIGAT
                	    aLin[VLDUSER]															, ; //X3_VLDUSER
                	    aLin[CBOX]  															, ; //X3_CBOX
                	    aLin[CBOX]																, ; //X3_CBOXSPA
                	    aLin[CBOX]																, ; //X3_CBOXENG
                	    ''																		, ; //X3_PICTVAR
                	    aLin[WHEN]																, ; //X3_WHEN
                	    aLin[INIBROW]   														, ; //X3_INIBRW
                	    aLin[GRPSXG]															, ; //X3_GRPSXG
                	    ''																		, ; //X3_FOLDER
                	    ''																		, ; //X3_CONDSQL
                	    ''																		, ; //X3_CHKSQL
                	    ''																		, ; //X3_IDXSRV
                	    ''																		, ; //X3_ORTOGRA
                	    ''																		, ; //X3_TELA
                	    ''																		, ; //X3_POSLGT
                	    ''																		, ; //X3_IDXFLD
                	    ''																		, ; //X3_AGRUP
                	    ''																		, ; //X3_MODAL
                	    ''																		} ) //X3_PYME
				EndIf

                oArchivo:AvLinTxt()
            EndDo

            oArchivo:CierraArch()
        Else
            lRet := .F.
            AutoGrLog(cMsgError)
        EndIf                
	Else
		AutoGrLog("No se ha seleccionado ningun Archivo")
	EndIf

Return lRet

/*=====================================================================
|---------------------------------------------------------------------|
| Programa | fSelFile | Autor: Andres Demarziani | Fecha: 15/02/2019  |
|---------------------------------------------------------------------|
======================================================================*/
Static Function fSelFile(oRuta, cRuta, lImporta)

	Local cMascara 	:= IIf(lImporta, "Archivo TXT|*.txt", "")
	Local nTipo		:= IIf(lImporta, GETF_LOCALHARD, GETF_LOCALHARD+GETF_RETDIRECTORY )
					
	cPath := cGetFile(cMascara,;
				"Seleccione el archivo",;
				Nil,;
				Nil,;
				lImporta,;
				nTipo,;
				.F.)

	cRuta := cPath
	oRuta:Refresh()

Return Nil
