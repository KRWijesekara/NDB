* @ValidationCode : MjotMTA5MTczNjkwMTpDcDEyNTI6MTc1MjgxMzU5MTQyMTpMb2hpdGg6LTE6LTE6MDowOmZhbHNlOk4vQTpSMjBfU1AzLjA6LTE6LTE=
* @ValidationInfo : Timestamp         : 18 Jul 2025 10:09:51
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : Lohith
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : N/A
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : R20_SP3.0
$PACKAGE EB.ndbBulkUpload

SUBROUTINE NOFILE.NDB.TCIB.SLIPS(DATA.LIST)
*-----------------------------------------------------------------------------
*
*-----------------------------------------------------------------------------
* Modification History :
*-----------------------------------------------------------------------------

*-----------------------------------------------------------------------------

    $USING EB.DataAccess
    $USING EB.API
    $USING EB.SystemTables

    $INSERT I_F.EB.NDB.TCIB.BULK.HEADERS
    $INSERT I_F.EB.NDB.TCIB.BULK.TRANS

    GOSUB INIT ; *Inititalize Variables
    IF slipRecCnt NE 0 THEN
        GOSUB PROCESS ; *Starting the Process
    END

RETURN

*-----------------------------------------------------------------------------

*** <region name= INIT>
INIT:
*** <desc>Inititalize Variables </desc>

    fnTranTable = "F.EB.NDB.TCIB.BULK.TRANS"
    fpTranTable = ""
    EB.DataAccess.Opf(fnTranTable, fpTranTable)
    
    fnSlipConc  = "F.NDB.TCIB.SLIPS.DET"
    fpSlipConc = ""
    EB.DataAccess.Opf(fnSlipConc, fpSlipConc)
    
    currdate = EB.SystemTables.getToday()
    julDate = ''
    totTranAmt = '0'
    hashTot = '0'
    fileName = ''
    bankCode = '21'
    seqNo = '50'
    dlm = '~'
    
    EB.API.Juldate(currdate, julDate)
    julDate = RIGHT(julDate, 5)
    
    selCmd = "SELECT ":fpTranTable:" WITH TYPE EQ SLIPS AND TC.TXN.STATUS EQ FT.SUCCESS OR TC.TXN.STATUS LIKE ...DOWNLOAD.STARTED..."
    EB.DataAccess.Readlist(selCmd, slipRecs, '', slipRecCnt, slipEr)

RETURN
*** </region>


*-----------------------------------------------------------------------------

*** <region name= PROCESS>
PROCESS:
*** <desc>Starting the Process </desc>
 
    GOSUB FILE.NAME ; *Generate Slip FIle Name

    FOR slipCnt=1 TO slipRecCnt
        tranId = slipRecs<slipCnt>
        EB.DataAccess.FRead(fnTranTable, tranId, tranRec, fpTranTable, tranEr)
        tranAmount = tranRec<EB.NDB16.DEB.AMOUNT>
        totTranAmt = totTranAmt + tranAmount
        benAcc = tranRec<EB.NDB16.BEN.ACC.NUM>
        hashTot = hashTot + benAcc
        tranRec<EB.NDB16.TC.TXN.STATUS> = "FILE.DOWNLOAD.STARTED"
        WRITE tranRec TO fpTranTable, tranId
        
    NEXT slipCnt

    FINDSTR '.' IN totTranAmt SETTING totamtPos ELSE totamtPos=''
    IF totamtPos NE '' THEN
        totTranAmt = totTranAmt*100
    END ELSE
        totTranAmt = totTranAmt:'00'
    END

    dataList = currdate     :dlm
    dataList := slipRecCnt  :dlm
    dataList := totTranAmt  :dlm
    dataList := fileName    :dlm
    dataList := hashTot     :dlm
    dataList := "FILE.DOWNLOAD.STARTED"
    DATA.LIST<-1>   = dataList
     
    WRITE dataList TO fpSlipConc,fileName
    
RETURN
*** </region>


*-----------------------------------------------------------------------------

*** <region name= FILE.NAME>
FILE.NAME:
*** <desc>Generate Slip FIle Name </desc>
 
    selId = "OWD":bankCode:julDate
        
    selSlipConc = "SELECT ":fpSlipConc:" WITH @ID LIKE ":selId:"..."
    EB.DataAccess.Readlist(selSlipConc, concRecs, '', concRecCnt, concErr)

    IF concRecs THEN
        concRecId = concRecs<concRecCnt>
        EB.DataAccess.FRead(fnSlipConc,concRecId,concRec,fpSlipConc,err)
        status = FIELD(concRec,'~',6)
        IF status EQ "FILE.DOWNLOAD.STARTED" THEN
            fileName = concRecId
        END ELSE
            seqNo = seqNo+concRecCnt
            fileName = "OWD":bankCode:julDate:seqNo
        END
    END ELSE
        fileName = "OWD":bankCode:julDate:seqNo
    END

RETURN
*** </region>

END
 


