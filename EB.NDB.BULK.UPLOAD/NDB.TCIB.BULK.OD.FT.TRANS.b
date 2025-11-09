* @ValidationCode : MjozMjU2NTQyMDY6Q3AxMjUyOjE3NDI5Njk0MTIzMDI6S3VzYWx5YTotMTotMTowOjA6ZmFsc2U6Ti9BOlIyMF9TUDMuMDotMTotMQ==
* @ValidationInfo : Timestamp         : 26 Mar 2025 11:40:12
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : Kusalya
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : N/A
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : R20_SP3.0
$PACKAGE EB.ndbBulkUpload

SUBROUTINE NDB.TCIB.BULK.OD.FT.TRANS
*-----------------------------------------------------------------------------
*
*-----------------------------------------------------------------------------
* Modification History :
*-----------------------------------------------------------------------------

*-----------------------------------------------------------------------------
    $USING EB.SystemTables
    $USING EB.DataAccess
    $USING FT.Contract

    GOSUB INIT ; *
	GOSUB SELECTION
    GOSUB PROCESS ; *
	
    
    $INSERT I_F.EB.NDB.TCIB.BULK.HEADERS
    $INSERT I_F.EB.NDB.TCIB.BULK.TRANS

RETURN


*-----------------------------------------------------------------------------

*** <region name= INIT>
INIT:
*** <desc> </desc>
    ftNum            = EB.SystemTables.getIdNew() ;* get the version @id
    atId = EB.SystemTables.getRNew(FT.Contract.FundsTransfer.DebitTheirRef)
    
    fnHeaderTable = "F.EB.NDB.TCIB.BULK.HEADERS"
    fpHeaderTable = ""
    EB.DataAccess.Opf(fnHeaderTable, fpHeaderTable)
    
    fnTranTable = "F.EB.NDB.TCIB.BULK.TRANS"
    fpTranTable = ""
    EB.DataAccess.Opf(fnTranTable, fpTranTable)

RETURN
*** </region>




*-----------------------------------------------------------------------------

*** <region name= INIT>
SELECTION:
*** <desc> </desc>

	selCmd = "SELECT ":fnHeaderTable:" WITH FT.NUMBER EQ ":ftNum;* select records
    EB.DataAccess.Readlist(selCmd, headerId, '', hdrCount, Er)


    selCmd = "SELECT ":fnTranTable:" WITH FT.NUMBER EQ ":ftNum
    EB.DataAccess.Readlist(selCmd, transactionId, '', tranCount, Er)
		
RETURN
*** </region>


*-----------------------------------------------------------------------------

*** <region name= PROCESS>
PROCESS:
*** <desc> </desc>
    endChars= RIGHT(atId,5)
	

    IF headerId EQ '' THEN
        EB.DataAccess.FRead(fnTranTable, transactionId, transRec, fpTranTable, Er)
        transRec<EB.NDB16.TC.TXN.STATUS>    = "FT.SUCCES"
        transRec<EB.NDB16.RECORD.STATUS>     = "BANK.APPROVED"
        WRITE transRec TO fpTranTable,transactionId
        
    END ELSE
        EB.DataAccess.FRead(fnHeaderTable, headerId, headerRec, fpHeaderTable, Er)
        headerRec<EB.NDB21.TC.TXN.STATUS>    = "BANK.APPROVED"
        headerRec<EB.NDB21.REC.STATUS>    = "PROCESSING"
        
        WRITE headerRec TO fpHeaderTable,headerId
        
        GOSUB UPDATE.TRANSACTIONS ; *
    END

RETURN
*** </region>


*-----------------------------------------------------------------------------

*** <region name= UPDATE.TRANSACTIONS>
UPDATE.TRANSACTIONS:
*** <desc> </desc>
    tranTableSel = "SELECT ":fnTranTable:" WITH @ID LIKE ":headerId:"..."
    EB.DataAccess.Readlist(tranTableSel, tranList, '', tranListCount, tranListErr)
    
    FOR tID = 1 TO tranListCount
        tranId = tranList<tID>
        EB.DataAccess.FRead(fnTranTable, tranId, tranRec, fpTranTable, Er)
        tranRec<EB.NDB16.TC.TXN.STATUS> = "PROCESS.FT"
        WRITE tranRec TO fpTranTable, tranId
    NEXT tID
    
RETURN
*** </region>

END



