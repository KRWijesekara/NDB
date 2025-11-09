* @ValidationCode : MjotMTc4MjIwOTA0NzpDcDEyNTI6MTc2MDA3NTY0OTYwMTpLdXNhbHlhOi0xOi0xOjA6MDpmYWxzZTpOL0E6UjIwX1NQMy4wOi0xOi0x
* @ValidationInfo : Timestamp         : 10 Oct 2025 11:24:09
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
SUBROUTINE NDB.TCIB.BULK.FT.SERVICE(ID)
*-----------------------------------------------------------------------------
*
*-----------------------------------------------------------------------------
* Modification History :
*-----------------------------------------------------------------------------

*-----------------------------------------------------------------------------
    
    $USING EB.DataAccess
    $USING EB.SystemTables
    $USING EB.ErrorProcessing
    $USING EB.Updates
    $USING EB.Reports
    $USING AC.AccountOpening
    $USING FT.Contract
    $USING ST.CompanyCreation
    $USING EB.Foundation
    $USING EB.Interface
    $USING AA.ModelBank
    $USING PP.FeeDeterminationService
    $USING EB.ARC
    $USING AO.Framework

    $INSERT I_F.EB.NDB.TCIB.BULK.HEADERS
    $INSERT I_F.EB.NDB.TCIB.BULK.TRANS
    $INSERT I_NDB.TCIB.BULK.FT.SERVICE.COMMON
      
    tranId = ID
    seqNo = RIGHT(tranId,5)
    upldId = FIELD(ID,"-",1)
    tranIdlen = LEN(tranId)
    headerId = LEFT(tranId,tranIdlen-6)

    EB.DataAccess.FRead(fnTranTable, tranId, tranRec, fpTranTable, Er)
    tranType = tranRec<EB.NDB16.TYPE>
    IF tranType EQ "CEFTS" THEN
        RETURN
    END
    
    tranRec<EB.NDB16.TC.TXN.STATUS> = "PROCESSING"
    WRITE tranRec TO fpTranTable, tranId
    headerFlag = tranRec<EB.NDB16.SINGLE.DEBIT.FLAG>
    debCurr = tranRec<EB.NDB16.DEB.CURR>
    amount = tranRec<EB.NDB16.DEB.AMOUNT>
    tcTxnStat = tranRec<EB.NDB16.TC.TXN.STATUS>
    
    
    IF headerFlag EQ 'NDB.TCIB.BULK.SD' THEN
        debitAcc = controlGlAcc
        GOSUB GET.TRANSACTIONS ; *Read Trans ETD and Process FT
    END ELSE
        debitAcc = tranRec<EB.NDB16.DEB.ACC>
        GOSUB ACC.CHECK ; *Account Check
        oData = debitAcc:"~AVAILABLE"
        EB.Reports.setOData(oData)
        AA.ModelBank.EAaConvGetBalances()
        availBal = EB.Reports.getOData()
        
        IF availBal LT totaldebAmount THEN
            flag = 'Y'
            IF AcFlag EQ 'Y' THEN
                debitRef = upldId
                GOSUB GET.TRANSACTIONS ; *Read Trans ETD and Process FT
                IF chrAvl EQ 'Y' THEN
                    amount = slipsCharge
                    creditAc =  slipsChargeGlAcc
                    debitRef = 'SLIPS-charges'
                    GOSUB PROCESS.FT ; *Read Trans ETD and Process FT
                END
            END
            tranRec<EB.NDB16.TC.TXN.STATUS> = "FT.FAILED - Insufficient Funds"
            WRITE tranRec TO fpTranTable, tranId
        END ELSE
            flag = ''
            debitRef = upldId
            GOSUB GET.TRANSACTIONS
            IF chrAvl EQ 'Y' THEN
                amount = slipsCharge
                debitRef = 'SLIPS-charges'
                creditAc =  slipsChargeGlAcc
                GOSUB PROCESS.FT ; *Read Trans ETD and Process FT
            END
        END
    END

RETURN
*** </region>


*-----------------------------------------------------------------------------

*** <region name= PROCESS.FT>
PROCESS.FT:
*** <desc>Initiate Fund Transfers </desc>
      
    
    appName   = "FUNDS.TRANSFER"
    ofsFunct  = "I"
    process = "PROCESS"
    ofsVersion  = "FUNDS.TRANSFER,NDB.TCIB.BULK"
    gtsMode = ""
    noOfAuth  = "0"
    IF flag EQ 'Y' THEN
        gtsMode = "2"
        noOfAuth  = "1"
    END
    transactionId  = ""
    record = ""
    ofsRecord = ""
    ofsSource = "NDB.GEFU"
    IF tranType EQ "SLIPS" THEN
        record<FT.Contract.FundsTransfer.TransactionType>   = slipsTranType
    END ELSE IF tranType EQ "INTERNAL" THEN
        GOSUB CHECK.OWN.FT ; *check if the internal transfer for own accounts
        record<FT.Contract.FundsTransfer.TransactionType>   = intType
    END ELSE
        record<FT.Contract.FundsTransfer.TransactionType>   = transactionType
    END
    record<FT.Contract.FundsTransfer.DebitAcctNo>       = debitAcc
    record<FT.Contract.FundsTransfer.DebitCurrency>     = debCurr
    record<FT.Contract.FundsTransfer.DebitAmount>       = amount
    record<FT.Contract.FundsTransfer.CreditAcctNo>      = creditAc
    record<FT.Contract.FundsTransfer.CreditCurrency>    = "LKR"
    record<FT.Contract.FundsTransfer.DebitValueDate>    = currDate
    record<FT.Contract.FundsTransfer.OrderingBank>      = "NDB"
    record<FT.Contract.FundsTransfer.DebitTheirRef>     = debitRef

    EB.Foundation.OfsBuildRecord(appName, ofsFunct, process, ofsVersion, gtsMode, noOfAuth, transactionId, record, ofsRecord)
    EB.Interface.OfsCallBulkManager(ofsSource, ofsRecord, response, txnCom)

*    CALL JOURNAL.UPDATE('')
    
RETURN
*** </region>


*-----------------------------------------------------------------------------

*** <region name= GET.TRANSACTIONS>
GET.TRANSACTIONS:
*** <desc>Read Trans ETD and Process FT </desc>
      

    BEGIN CASE
        CASE tranType EQ "CEFTS"
            creditAc = ceftsGlAcc
        CASE tranType EQ "SLIPS"
            creditAc = slipsGlAcc
        CASE 1
            creditAc = tranRec<EB.NDB16.BEN.ACC.NUM>
    END CASE
            
    GOSUB PROCESS.FT ; *Initiate Fund Transfers
    GOSUB STAT.UPD.TRAN ; *Update FT status

RETURN
*** </region>

 
*-----------------------------------------------------------------------------

*** <region name= STAT.UPD.TRAN>
STAT.UPD.TRAN:
*** <desc>Update FT status </desc>
     
    tranIdFt = ''
    IF txnCom EQ '1' THEN
        tranRec<EB.NDB16.TC.TXN.STATUS> = "FT.SUCCESS"
        tranIdFt = FIELD(response,"/",1)
        tranIdFt = FIELD(tranIdFt,"<request>",2)
        tranRec<EB.NDB16.FT.NUMBER> = tranIdFt
        tranRec<EB.NDB16.FT.PROCESS.DATE> = currDate
        WRITE tranRec TO fpTranTable, tranId
        CRT tranIdFt
    END ELSE
        tranRec<EB.NDB16.TC.TXN.STATUS> = "FT.FAILED -":response
        WRITE tranRec TO fpTranTable, tranId
    END

RETURN
*** </region>


*-----------------------------------------------------------------------------

*** <region name= ACC.CHECK>
ACC.CHECK:
*** <desc>Account Check </desc>

    EB.DataAccess.FRead(fnAccount,debitAcc,AcRec,fpAccount,err)
    AcCat      = AcRec<AC.AccountOpening.Account.Category>
    customerId = AcRec<AC.AccountOpening.Account.Customer>
    IF AcCat LT 2000 OR AcCat GT 999 THEN
        AcFlag = 'Y'
    END
    IF tranType EQ 'SLIPS' THEN
        chrAvl = 'Y'
        GOSUB GET.CUS.CHARGES ; *Get Charges
    END

    totaldebAmount      = amount+slipsCharge

RETURN
*** </region>


*-----------------------------------------------------------------------------

*** <region name= GET.CUS.CHARGES>
GET.CUS.CHARGES:
*** <desc>Get Charges </desc>

    SelCmd = "SELECT ":fnPpClientCharges:" WITH ClientID EQ ":customerId
    EB.DataAccess.Readlist(SelCmd, ppClientRecId, '', '', err)
    EB.DataAccess.FRead(fnPpClientCharges, ppClientRecId, ppClientRec, fpPpClientCharges, err)
    feeType         = ppClientRec<PP.FeeDeterminationService.Clientcharges.CcFeetype>
    fixedChargeAmts = ppClientRec<PP.FeeDeterminationService.Clientcharges.CcFixedchargeamount>

    FINDSTR "SLIPS" IN feeType SETTING slipsPos ELSE slipsPos=''
    IF slipsPos EQ '' THEN
        slipsCharge = slipsGenCharge
    END ELSE
        slipsCharge = fixedChargeAmts
    END
    
RETURN
*** </region>


*-----------------------------------------------------------------------------

*** <region name= CHECK.OWN.FT>
CHECK.OWN.FT:
*** <desc>check if the internal transfer for own accounts </desc>
 
    intType = ''
    EB.DataAccess.FRead(fnHeadTable, headerId, hdrRec, fpHeadTable, extEr)
    extUser         = hdrRec<EB.NDB21.TC.INPUT.NAME>
    EB.DataAccess.FRead(fnEbExtUsr, extUser, extUsrRec, fpEbExtUsr, extEr)
    extUsrArr = extUsrRec<EB.ARC.ExternalUser.XuArrangement>
    extUsrComp = extUsrRec<EB.ARC.ExternalUser.XuCompany>
    ST.CompanyCreation.LoadCompany(extUsrComp)
    
    tcPermId = extUsrArr:'-TCPERMISSIONS'
    selCmd = "SELECT ":fnTcPerm:" WITH @ID LIKE ":tcPermId:"..."
    EB.DataAccess.Readlist(selCmd, recList, recName, recCount, recErr)
    
    IF recList EQ '' THEN
        selCmd = "SELECT ":fnDbTcPerm:" WITH @ID LIKE ":tcPermId:"..."
        EB.DataAccess.Readlist(selCmd, recList, recName, recCount, recErr)
    END
    
    ltPermiId = recList<recCount>
    EB.DataAccess.FRead(fnTcPerm, ltPermiId, permiRec, fpTcPerm, Er)
    defiCust = permiRec<AO.Framework.TcPermissions.AaTcPermDefinedCustomers>
    
    IF defiCust EQ '' THEN
        EB.DataAccess.FRead(fnDbTcPerm, ltPermiId, permiRec, fpDbTcPerm, Er)
        defiCust = permiRec<AO.Framework.TcPermissions.AaTcPermDefinedCustomers>
    END
    
    CHANGE @VM TO @FM IN defiCust
    CHANGE @SM TO @FM IN defiCust
    defiCuCnt = DCOUNT(defiCust,@FM)

    FOR defiCusNo=1 TO defiCuCnt
        
        cusId = defiCust<defiCusNo>
        EB.DataAccess.FRead(fnCustomerAccount,cusId,customerAcRec,fpCustomerAccount,err)
        LOCATE creditAc IN customerAcRec SETTING creditAccPos THEN
            intType = intTranTypeOwn
            RETURN
        END
    NEXT defiCusNo
    intType = intTranType

RETURN
*** </region>

END



