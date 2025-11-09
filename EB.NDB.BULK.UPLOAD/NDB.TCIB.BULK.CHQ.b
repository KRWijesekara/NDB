* @ValidationCode : MjotMzQxODQzMjM1OkNwMTI1MjoxNzYwMDA4NTMxNzEyOkxvaGl0aDotMTotMTowOjA6ZmFsc2U6Ti9BOlIyMF9TUDMuMDotMTotMQ==
* @ValidationInfo : Timestamp         : 09 Oct 2025 16:45:31
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

SUBROUTINE NDB.TCIB.BULK.CHQ(ID)
*-----------------------------------------------------------------------------
*
*-----------------------------------------------------------------------------
* Modification History :
*-----------------------------------------------------------------------------

*-----------------------------------------------------------------------------

    $USING EB.SystemTables
    $USING EB.DataAccess
    $USING AC.AccountOpening
    $USING ST.CompanyCreation
    $USING ST.CurrencyConfig
    $USING EB.NDBChequePrinting
    $USING EB.LocalReferences
    $USING EB.Foundation
    $USING EB.Interface
    
    $INSERT I_F.EB.NDB.TCIB.BULK.HEADERS
    $INSERT I_F.EB.NDB.TCIB.BULK.TRANS
    $INSERT I_NDB.TCIB.BULK.CHQ.COMMON
    
    tranTbId = ID
    seqNo = RIGHT(tranTbId,6)
    headId = FIELD(tranTbId,seqNo,1)
    
    EB.DataAccess.FRead(fnTranTable, tranTbId, tranRec, fpTranTable, tranEr)
    EB.DataAccess.FRead(fnHeadTable, headId, headRec, fpHeadTable, headEr)
    IF headEr THEN
        EB.DataAccess.FRead(fnHeadTableNau, headId, headRec, fpHeadTableNau, headNauEr)
    END

    tranCusRef  = tranRec<EB.NDB16.CUST.REF>
    tranDrAc    = tranRec<EB.NDB16.DEB.ACC>
    fileTranAmt = tranRec<EB.NDB16.DEB.AMOUNT>
    tranCurr    = tranRec<EB.NDB16.DEB.CURR>
    tranDate    = tranRec<EB.NDB16.DEB.VAL.DATE>
    tranBenAcNm = tranRec<EB.NDB16.BEN.NAME>
    tranNarr    = tranRec<EB.NDB16.NARRATIVE>
    tranBenEm   = tranRec<EB.NDB16.BEN.EMAIL>
    benAdd1     = tranRec<EB.NDB16.BEN.ADD1>
    benAdd2     = tranRec<EB.NDB16.BEN.ADD2>
    benAdd3     = tranRec<EB.NDB16.BEN.ADD3>
    currDate    = tranRec<EB.NDB16.SYSTEM.DATE>
    upldId      = tranRec<EB.NDB16.UPL.ID>
    signatList  = headRec<EB.NDB21.SIGNATORY>
    CHANGE @VM TO @FM IN signatList
    CHANGE @SM TO @FM IN signatList
    signatCnt   = DCOUNT(signatList,@FM)
    
    EB.LocalReferences.GetLocRef('ARC.BULK.CHEQUE.UPLOAD', 'BEN.ADDRESS.1', benA1Pos)
    EB.LocalReferences.GetLocRef('ARC.BULK.CHEQUE.UPLOAD', 'BEN.ADDRESS.2', benA2Pos)
    EB.LocalReferences.GetLocRef('ARC.BULK.CHEQUE.UPLOAD', 'NDB.BULK.REF.ID', uIdPos)
    
    EB.DataAccess.FRead(fnAccount, tranDrAc, accRec, fpAccount, accEr)
    IF accRec THEN
        cusId = accRec<AC.AccountOpening.Account.Customer>
        coCode= accRec<AC.AccountOpening.Account.CoCode>
    END
    
    GOSUB INIT.OFS ; *Initiate OFS to update ARC.BULK.CHEQUE.UPLOAD table
    GOSUB STAT.UPD ; *Update status

RETURN

*-----------------------------------------------------------------------------

*** <region name= INIT.OFS>
INIT.OFS:
*** <desc>Initiate OFS to update ARC.BULK.CHEQUE.UPLOAD table </desc>

    appName   = "ARC.BULK.CHEQUE.UPLOAD"
    ofsFunct  = "I"
    process = "PROCESS"
    ofsVersion  = "ARC.BULK.CHEQUE.UPLOAD,OFS"
    gtsMode = ""
    noOfAuth  = "0"
    transactionId  = ""
    record = ""
    ofsRecord = ""
    ofsSource = "NDB.GEFU"
    
    recode<EB.NDBChequePrinting.ArcBulkChqueUpload.ArcBulkCustomerRef>          = tranCusRef
    record<EB.NDBChequePrinting.ArcBulkChqueUpload.ArcBulkCustomerReferenceNo>  = cusId
    record<EB.NDBChequePrinting.ArcBulkChqueUpload.ArcBulkAccountNo>            = tranDrAc
    record<EB.NDBChequePrinting.ArcBulkChqueUpload.ArcBulkBenName>              = tranBenAcNm
    record<EB.NDBChequePrinting.ArcBulkChqueUpload.ArcBulkLocalRef,benA1Pos>    = benAdd1
    record<EB.NDBChequePrinting.ArcBulkChqueUpload.ArcBulkLocalRef,benA2Pos>    = benAdd2
    record<EB.NDBChequePrinting.ArcBulkChqueUpload.ArcBulkPaymentDetails>       = tranNarr
    record<EB.NDBChequePrinting.ArcBulkChqueUpload.ArcBulkValueDate>            = tranDate
    record<EB.NDBChequePrinting.ArcBulkChqueUpload.ArcBulkChequeAmount>         = fileTranAmt
    record<EB.NDBChequePrinting.ArcBulkChqueUpload.ArcBulkDeliveryMode>         = "OC"
    record<EB.NDBChequePrinting.ArcBulkChqueUpload.ArcBulkInvoiceDetails>       = tranNarr
    record<EB.NDBChequePrinting.ArcBulkChqueUpload.ArcBulkPrintLocation>        = "LK0010900"
    record<EB.NDBChequePrinting.ArcBulkChqueUpload.ArcBulkLocalRef,uIdPos>      = upldId
    FOR sigCnt=1 TO signatCnt
        signatory = signatList<sigCnt>
        record<EB.NDBChequePrinting.ArcBulkChqueUpload.ArcBulkSignatory,sigCnt> = signatory
    NEXT sigCnt

    ST.CompanyCreation.LoadCompany(coCode)

    EB.Foundation.OfsBuildRecord(appName, ofsFunct, process, ofsVersion, gtsMode, noOfAuth, transactionId, record, ofsRecord)
    EB.Interface.OfsCallBulkManager(ofsSource, ofsRecord, response, txnCom)

RETURN
*** </region>


*-----------------------------------------------------------------------------

*** <region name= STAT.UPD>
STAT.UPD:
*** <desc>Update status </desc>

    tranRef = ''
    IF txnCom EQ '1' THEN
        tranRec<EB.NDB16.TC.TXN.STATUS> = "UPLD.SUCCESS"
        tranRef = FIELD(response,"/",1)
        tranRef = FIELD(tranIdFt,"<request>",2)
        tranRec<EB.NDB16.FT.NUMBER> = tranRef
        tranRec<EB.NDB16.FT.PROCESS.DATE> = currDate
        WRITE tranRec TO fpTranTable, tranTbId
        CRT tranIdFt
    END ELSE
        tranRec<EB.NDB16.TC.TXN.STATUS> = "UPLD.FAILED -":response
        WRITE tranRec TO fpTranTable, tranTbId
    END

RETURN
*** </region>

END


