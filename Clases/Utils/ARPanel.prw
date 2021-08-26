#include "Protheus.ch"

/*=========================================================================
=|=======================================================================|=
=|Programa: ARPanel      | Autor: Microsiga       | Fecha: 03/05/2019    |=
=|=======================================================================|=
=|Desc: Arma un listbox segun los array que envie el demandante.         |=
=|=======================================================================|=
=========================================================================*/
CLASS ARPanel
	
	DATA aPaneles
	
	METHOD New() CONSTRUCTOR 
	METHOD setPaneles()
	METHOD getPanel()

ENDCLASS

/*=========================================================================
=|=======================================================================|=
=|Programa: New          | Autor: Microsiga         | Fecha: 03/05/2019  |=
=|=======================================================================|=
=========================================================================*/
METHOD New() CLASS ARPanel

	::aPaneles := {}

RETURN SELF

/*=========================================================================
=|=======================================================================|=
=|Programa: setTam       | Autor: Microsiga         | Fecha: 03/05/2019  |=
=|=======================================================================|=
=========================================================================*/
METHOD setPaneles(oDlg, aLineas, aColumnas) CLASS ARPanel

	Local nX
	Local nPor, cLin, cCol, cWin
	Local oFWLayer

	oFWLayer := FWLayer():New()
	oFWLayer:init(oDlg, .F.)

	For nX := 1 To Len(aLineas)	
		nPor := aLineas[nX]
		cLin := 'Lin'+cValToChar(nX)
		oFWLayer:addLine(cLin, nPor,.T.)
	Next nX

	For nX := 1 To Len(aColumnas)
		nPor := aColumnas[nX][1]
		cLin := "Lin"+cValToChar(aColumnas[nX][2])
		cCol := "Col"+cValToChar(nX)
		cWin := "Win00"+cValToChar(aColumnas[nX][2])+"00"+cValToChar(nX)

		oFWLayer:addCollumn(cCol, nPor, .F., cLin)
		oFWLayer:addWindow(cCol, cWin, aColumnas[nX][3], 100, .F., .F., Nil, cLin)

		aAdd(::aPaneles, {aColumnas[nX][4], oFWLayer:getWinPanel(cCol, cWin, cLin)})
	Next nX

RETURN ::aPaneles

/*=========================================================================
=|=======================================================================|=
=|Programa: setTam       | Autor: Microsiga         | Fecha: 03/05/2019  |=
=|=======================================================================|=
=========================================================================*/
METHOD getPanel(cPanel) CLASS ARPanel
Local nPos := aScan(::aPaneles, {|x| x[1]==cPanel})
RETURN IIf(nPos>0, ::aPaneles[nPos][2], Nil)

