* @ValidationCode : MjoxNjk5NjkyNjkxOkNwMTI1MjoxNzYyNDk3MjkzNDE1Okt1c2FseWE6LTE6LTE6MDowOmZhbHNlOk4vQTpSMjBfU1AzLjA6LTE6LTE=
* @ValidationInfo : Timestamp         : 07 Nov 2025 12:04:53
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : Kusalya
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : N/A
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : R20_SP3.0
$PACKAGE EB.ndbTcibEmailBen
SUBROUTINE NDB.TCIB.SET.EMAIL.REC
*-----------------------------------------------------------------------------
*
*-----------------------------------------------------------------------------
* Modification History :
*-----------------------------------------------------------------------------

*-----------------------------------------------------------------------------
    $USING FT.Contract
    $USING PI.Contract
    $USING EB.SystemTables
    $USING EB.LocalReferences
    $USING EB.DataAccess
    
    $INSERT I_F.EB.NDB.TCIB.SEND.EMAIL
     
    currDate     = EB.SystemTables.getToday()
*<tracer>----
    OPENSEQ 'TRACE.BP','EMAIL.BEN-':currDate:'.txt' TO queueFile ELSE NULL
    tracerData =  "********Start Tracer Writing********" :CHAR(010)
    tracerData :=  "Tracer Data writing - NDB.VIP.CRE.DEB.REF.DEF>":EB.SystemTables.getTimeStamp() :CHAR(010)
    
    fnNdbSendEmail = "F.EB.NDB.TCIB.SEND.EMAIL"
    fpNdbSendEmail  = ""
    EB.DataAccess.Opf(fnNdbSendEmail,fpNdbSendEmail)


    Application = EB.SystemTables.getApplication()
    Id           = EB.SystemTables.getIdNew()       ;* get the upld @id
    function     = EB.SystemTables.getVFunction()   ;* get the function
    currDate     = EB.SystemTables.getToday()       ;* get today
    sendEmailId  = Id                               ;* set @id for local table
    benEmailIds = ''
        
*<tracer>----
    tracerData := "Application : ":Application :CHAR(010)
    tracerData := "Id          : ":Id :CHAR(010)
    tracerData := "function    : ":function :CHAR(010)
    tracerData := "currDate    : ":currDate :CHAR(010)

    WRITESEQ tracerData APPEND TO queueFile ELSE NULL
    tracerData = ''
*<tracer>----

    IF Application EQ "PAYMENT.ORDER" THEN
        recordStatus    = EB.SystemTables.getRNew(PI.Contract.PaymentOrder.PoRecordStatus);* get record recordStatus
        debCustName     = EB.SystemTables.getRNew(PI.Contract.PaymentOrder.PoOrderingCustName)
        debitAcNo       = EB.SystemTables.getRNew(PI.Contract.PaymentOrder.PoDebitAccount)
        debAmnt         = EB.SystemTables.getRNew(PI.Contract.PaymentOrder.PoDebitAmount)
        debCurr         = EB.SystemTables.getRNew(PI.Contract.PaymentOrder.PoDebitCcy)
        valueDate       = EB.SystemTables.getRNew(PI.Contract.PaymentOrder.PoPaymentExecutionDate)
        EB.LocalReferences.GetLocRef('PAYMENT.ORDER', 'TC.UPLD.DOC', upldDocPos)
        EB.LocalReferences.GetLocRef('PAYMENT.ORDER', 'BEN.EMAIL.ID', benEmailIdpos)
        benEmailIds     = EB.SystemTables.getRNew(PI.Contract.PaymentOrder.PoLocalRef)<1,benEmailIdpos>
        
    END ELSE

        recordStatus = EB.SystemTables.getRNew(FT.Contract.FundsTransfer.RecordStatus) ;* get record recordStatus
        debitAcNo    = EB.SystemTables.getRNew(FT.Contract.FundsTransfer.DebitAcctNo)
        debAmnt      = EB.SystemTables.getRNew(FT.Contract.FundsTransfer.DebitAmount)
        debCurr      = EB.SystemTables.getRNew(FT.Contract.FundsTransfer.DebitCurrency)
        valueDate    = EB.SystemTables.getRNew(FT.Contract.FundsTransfer.DebitValueDate)
        EB.LocalReferences.GetLocRef('FUNDS.TRANSFER', 'L.CORP.MAIL', ftFromMailPos)
        EB.LocalReferences.GetLocRef('FUNDS.TRANSFER', 'BEN.EMAIL.ID', ftToMailPos)
        fromMailid   = EB.SystemTables.getRNew(FT.Contract.FundsTransfer.LocalRef)<1,ftFromMailPos>
        benEmailIds  = EB.SystemTables.getRNew(FT.Contract.FundsTransfer.LocalRef)<1,ftToMailPos>
    END
    
*<tracer>----
    tracerData := "recordStatus : ":recordStatus :CHAR(010)
    tracerData := "fromMailid   : ":fromMailid :CHAR(010)
    tracerData := "benEmailIds  : ":benEmailIds :CHAR(010)

    WRITESEQ tracerData APPEND TO queueFile ELSE NULL
    tracerData = ''
*<tracer>----

    
    sendEmailRec = ''
    IF recordStatus EQ "INAO" AND function EQ 'A' THEN
        IF benEmailIds THEN
            sendEmailRec<EB.NDB18.TRANSACTION.ID>   = sendEmailId
            sendEmailRec<EB.NDB18.EMAIL.TYPE>       = 'BENEFICIARY.EMAIL'
            sendEmailRec<EB.NDB18.ORG.DATE>         = currDate
            sendEmailRec<EB.NDB18.STATUS>           = recordStatus
            sendEmailRec<EB.NDB18.CUS.ACC.NO>       = debitAcNo
            sendEmailRec<EB.NDB18.AMOUNT>           = debAmnt
            sendEmailRec<EB.NDB18.CUS.NAME>         = debCustName
            sendEmailRec<EB.NDB18.FROM.EMAIL>       = fromMailid
            sendEmailRec<EB.NDB18.TO.EMAIL>         = benEmailIds
            WRITE sendEmailRec TO fpNdbSendEmail,sendEmailId
        END
    END
    
*<tracer>----

    tracerData := "sendEmailId  : ":sendEmailId :CHAR(010)
    tracerData := "sendEmailRec : ":sendEmailRec :CHAR(010)
    tracerData := "********End Tracer Writing********" :CHAR(010)
    WRITESEQ tracerData APPEND TO queueFile ELSE NULL
    tracerData = ''
*<tracer>----

RETURN
END