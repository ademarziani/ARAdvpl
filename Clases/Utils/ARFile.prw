#INCLUDE "PROTHEUS.CH"
#INCLUDE "FILEIO.CH"
/*/
 CLASS:  fT
 Autor:  Marinaldo de Jesus
 Data:  01/05/2011
 Descricao: Alternativa aas funcoes tipo FT_F* devido as limitacoes apontadas em (http://tdn.totvs.com.br/kbm#9734)
 Sintaxe: ARFile():New() : Objeto do Tipo fT
/*/
CLASS ARFile FROM LongClassName

    DATA aLines

    DATA cCRLF
    DATA cFile
    DATA cLine  
    DATA cClassName 
    DATA nRecno
    DATA nfHandle
    DATA nFileSize
    DATA nLastRecno
    DATA nBufferSize    

    METHOD New()  CONSTRUCTOR
    METHOD ClassName()  
    METHOD ft_fUse( cFile )
    METHOD ft_fOpen( cFile )
    METHOD ft_fClose()

    METHOD ft_fAlias()

    METHOD ft_fExists( cFile )

    METHOD ft_fRecno()
    METHOD ft_fSkip( nSkipper )
    METHOD ft_fGoTo( nGoTo )
    METHOD ft_fGoTop()
    METHOD ft_fGoBottom()
    METHOD ft_fLastRec()
    METHOD ft_fRecCount()   
    METHOD ft_fEof()
    METHOD ft_fBof()    
    METHOD ft_fReadLn()
    METHOD ft_fReadLine()

    METHOD ft_fError( cError )  
    METHOD ft_fSetCRLF( cCRLF )
    METHOD ft_fSetBufferSize( nBufferSize )

END CLASS

/*/
 METHOD:  New
 Autor:  Marinaldo de Jesus
 Data:  01/05/2011
 Descricao: CONSTRUCTOR
 Sintaxe: ARFile():New() : Object do Tipo fT    
/*/
METHOD New() CLASS ARFile

    Self:aLines   := Array(0)   
    Self:cFile   := ""
    Self:cLine   := ""  
    Self:cClassName  := "FT"    
    Self:nRecno   := 0
    Self:nLastRecno  := 0
    Self:nfHandle  := -1
    Self:nFileSize  := 0    
    Self:ft_fSetCRLF()
    Self:ft_fSetBufferSize()

Return( Self )

/*/
 METHOD:  ClassName
 Autor:  Marinaldo de Jesus
 Data:  01/05/2011
 Descricao: Retornar o Nome da Classe
 Sintaxe: ARFile():ClassName() : Retorna o Nome da Classe
/*/
METHOD ClassName() CLASS ARFile
Return( Self:cClassName )

/*/
 METHOD:  ft_fUse
 Autor:  Marinaldo de Jesus
 Data:  01/05/2011
 Descricao: Abrir o Arquivo Passado como Parametro
 Sintaxe: ARFile():ft_fUse( cFile ) : nfHandle ( nfHandle > 0 True, False)
/*/
METHOD ft_fUse( cFile ) CLASS ARFile

    If Self:ft_fExists( cFile ) 
        Self:ft_fOpen( cFile )
    EndIf

Return( Self:nfHandle )

/*/
 METHOD:  ft_fOpen
 Autor:  Marinaldo de Jesus
 Data:  01/05/2011
 Descricao: Abrir o Arquivo Passado como Parametro
 Sintaxe: ARFile():ft_fOpen( cFile ) : nfHandle ( nfHandle > 0 True, False)
/*/
METHOD ft_fOpen( cFile ) CLASS ARFile

    If Self:ft_fExists( cFile )
        Self:cFile  := cFile
        Self:nfHandle := fOpen( Self:cFile , FO_READ )  

        If Self:nfHandle != -1
            Self:nFileSize := fSeek( Self:nfHandle , 0 , FS_END )
            fSeek( Self:nfHandle , 0 , FS_SET )
            Self:nFileSize := ReadFile( @Self:aLines , @Self:nfHandle , @Self:nBufferSize , @Self:nFileSize , @Self:cCRLF )
            Self:ft_fGoTop()
        EndIf
    EndIf
 
Return( Self:nfHandle )

/*/
 Funcao:  ReadFile
 Autor:  Marinaldo de Jesus
 Data:  01/05/2011
 Descricao: Percorre o Arquivo a ser lido e alimento o Array aLines
 Sintaxe: ReadFile( aLines , nfHandle , nBufferSize , nFileSize , cCRLF ) : nLines Read
/*/
Static Function ReadFile( aLines , nfHandle , nBufferSize , nFileSize , cCRLF )
    
 Local cLine   := ""
 Local cBuffer  := ""

 Local nLines  := 0
 Local nAtPlus  := ( Len( cCRLF ) -1 )
 Local nBytesRead := 0

 While ( nBytesRead <= nFileSize )
  cBuffer   += fReadStr( @nfHandle , @nBufferSize )
  nBytesRead  += nBufferSize
  While ( cCRLF $ cBuffer )
   ++nLines
   cLine   := SubStr( cBuffer , 1 , ( AT( cCRLF , cBuffer ) + nAtPlus ) )
   cBuffer  := SubStr( cBuffer , Len( cLine ) + 1 )
   cLine  := StrTran( cLine , cCRLF , "" )
   aAdd( aLines , cLine )
   cLine  := ""
  End While
 End While

 IF !Empty( cBuffer )
  ++nLines
  aAdd( aLines , cBuffer )
  cBuffer := ""
 EndIF

Return( nLines )

/*/
 METHOD:  ft_fClose
 Autor:  Marinaldo de Jesus
 Data:  01/05/2011
 Descricao: Fechar o Arquivo aberto pela ft_fOpen ou ft_fUse
 Sintaxe: ARFile():ft_fClose() : NIL
/*/
METHOD ft_fClose() CLASS ARFile

 IF ( Self:nfHandle > 0 )
  fClose( Self:nfHandle )
 EndIF

 aSize( Self:aLines , 0 )

 Self:cFile   := ""
 Self:cLine   := ""

 Self:nRecno   := 0
 Self:nfHandle  := -1
 Self:nFileSize  := 0
 Self:nLastRecno  := 0

Return( NIL )

/*/
 METHOD:  ft_fAlias
 Autor:  Marinaldo de Jesus
 Data:  01/05/2011
 Descricao: Retornar o Nome do Arquivo Atualmente Aberto
 Sintaxe: ARFile():ft_fAlias() : cFile
/*/
METHOD ft_fAlias() CLASS ARFile
Return( Self:cFile )

/*/
 METHOD:  ft_fExists
 Autor:  Marinaldo de Jesus
 Data:  01/05/2011
 Descricao: Verifica se o Arquivo Existe
 Sintaxe: ARFile():ft_fExists( cFile ) : lExists
/*/
METHOD ft_fExists(cFile) CLASS ARFile
Return !Empty(cFile) .And. File(cFile)

/*/
 METHOD:  ft_fRecno
 Autor:  Marinaldo de Jesus
 Data:  01/05/2011
 Descricao: Retorna o Recno Atual
 Sintaxe: ARFile():ft_fRecno() : nRecno
/*/
METHOD ft_fRecno() CLASS ARFile
Return( Self:nRecno )

/*/
 METHOD:  ft_fSkip
 Autor:  Marinaldo de Jesus
 Data:  01/05/2011
 Descricao: Salta n Posicoes 
 Sintaxe: ARFile():ft_fSkip( nSkipper ) : nRecno
/*/
METHOD ft_fSkip( nSkipper ) CLASS ARFile

 DEFAULT nSkipper := 1

 Self:nRecno += nSkipper

Return( Self:nRecno )

/*/
 METHOD:  ft_fGoTo
 Autor:  Marinaldo de Jesus
 Data:  01/05/2011
 Descricao: Salta para o Registro informando em nGoto
 Sintaxe: ARFile():ft_fGoTo( nGoTo ) : nRecno
/*/
METHOD ft_fGoTo( nGoTo ) CLASS ARFile

 Self:nRecno := nGoTo

Return( Self:nRecno )

/*/
 METHOD:  ft_fGoTop
 Autor:  Marinaldo de Jesus
 Data:  01/05/2011
 Descricao: Salta para o Inicio do Arquivo
 Sintaxe: ARFile():ft_fGoTo( nGoTo ) : nRecno
/*/
METHOD ft_fGoTop() CLASS ARFile
Return( Self:ft_fGoTo( 1 ) )

/*/
 METHOD:  ft_fGoBottom
 Autor:  Marinaldo de Jesus
 Data:  01/05/2011
 Descricao: Salta para o Final do Arquivo
 Sintaxe: ARFile():ft_fGoBottom() : nRecno
/*/
METHOD ft_fGoBottom() CLASS ARFile
Return( Self:ft_fGoTo( Self:nFileSize ) )

/*/
 METHOD:  ft_fLastRec
 Autor:  Marinaldo de Jesus
 Data:  01/05/2011
 Descricao: Retorna o Numero de Registro do Arquivo
 Sintaxe: ARFile():ft_fLastRec() : nRecCount
/*/
METHOD ft_fLastRec() CLASS ARFile
Return( Self:nFileSize )

/*/
 METHOD:  ft_fRecCount
 Autor:  Marinaldo de Jesus
 Data:  01/05/2011
 Descricao: Retorna o Numero de Registro do Arquivo
 Sintaxe: ARFile():ft_fRecCount() : nRecCount
/*/
METHOD ft_fRecCount() CLASS ARFile
Return( Self:nFileSize )

/*/
 METHOD:  ft_fEof
 Autor:  Marinaldo de Jesus
 Data:  01/05/2011
 Descricao: Verifica se Atingiu o Final do Arquivo
 Sintaxe: ARFile():ft_fEof() : lEof
/*/
METHOD ft_fEof() CLASS ARFile
Return( Self:nRecno > Self:nFileSize )

/*/
 METHOD:  ft_fBof
 Autor:  Marinaldo de Jesus
 Data:  01/05/2011
 Descricao: Verifica se Atingiu o Inicio do Arquivo
 Sintaxe: ARFile():ft_fBof() : lBof
/*/
METHOD ft_fBof() CLASS ARFile
Return( Self:nRecno < 1 )

/*/
 METHOD:  ft_fReadLine
 Autor:  Marinaldo de Jesus
 Data:  01/05/2011
 Descricao: Le a Linha do Registro Atualmente Posicionado
 Sintaxe: ARFile():ft_fReadLine() : cLine
/*/
METHOD ft_fReadLine() CLASS ARFile

    Self:nLastRecno   := Self:nRecno
    Self:cLine        := Self:aLines[ Self:nRecno ]

Return( Self:cLine )

/*/
 METHOD:  ft_fReadLn
 Autor:  Marinaldo de Jesus
 Data:  01/05/2011
 Descricao: Le a Linha do Registro Atualmente Posicionado
 Sintaxe: ARFile():ft_fReadLn() : cLine
/*/
METHOD ft_fReadLn() CLASS ARFile
Return( Self:ft_fReadLine() )

/*/
 METHOD:  ft_fError
 Autor:  Marinaldo de Jesus
 Data:  01/05/2011
 Descricao: Retorna o Ultimo erro ocorrido
 Sintaxe: ARFile():ft_fError( @cError ) : nDosError
/*/
METHOD ft_fError( cError ) CLASS ARFile
 cError := CaptureError()
Return( fError() )

/*/
 METHOD:  ft_fSetBufferSize
 Autor:  Marinaldo de Jesus
 Data:  01/05/2011
 Descricao: Redefine nBufferSize
 Sintaxe: ARFile():ft_fSetBufferSize( nBufferSize ) : nLastBufferSize
/*/
METHOD ft_fSetBufferSize( nBufferSize ) CLASS ARFile

 Local nLastBufferSize := Self:nBufferSize

 DEFAULT nBufferSize := 1024
 
 Self:nBufferSize := nBufferSize
 Self:nBufferSize := Max( Self:nBufferSize , 1 )

Return( nLastBufferSize )

/*/
 METHOD:  ft_fSetCRLF
 Autor:  Marinaldo de Jesus
 Data:  01/05/2011
 Descricao: Redefine cCRLF
 Sintaxe: ARFile():ft_fSetCRLF( cCRLF ) : nLastCRLF
/*/
METHOD ft_fSetCRLF( cCRLF ) CLASS ARFile

 Local cLastCRLF := Self:cCRLF
 
 DEFAULT cCRLF := CRLF
 
 Self:cCRLF  := cCRLF

Return( cLastCRLF )
