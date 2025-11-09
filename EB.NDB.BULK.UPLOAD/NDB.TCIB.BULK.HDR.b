* @ValidationCode : MjoyMTA0MDIyNjQ2OkNwMTI1MjoxNzUzMTczMDUwMzQ3Okt1c2FseWE6LTE6LTE6MDowOmZhbHNlOk4vQTpSMjBfU1AzLjA6LTE6LTE=
* @ValidationInfo : Timestamp         : 22 Jul 2025 14:00:50
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

SUBROUTINE NDB.TCIB.BULK.HDR(ID)
*-----------------------------------------------------------------------------
*
*-----------------------------------------------------------------------------
* Modification History :
*-----------------------------------------------------------------------------

*-----------------------------------------------------------------------------

    $USING EB.DataAccess
    $USING EB.API
    $USING EB.SystemTables
    $USING EB.Reports
    $USING AA.ModelBank
    $USING EB.OverrideProcessing
    $USING FT.Contract
    $USING EB.Foundation
    $USING EB.Interface
    $USING AC.AccountOpening
    $USING PP.FeeDeterminationService
	$USING EB.LocalReferences
    $INSERT I_F.EB.NDB.TCIB.BULK.HEADERS
    $INSERT I_F.EB.NDB.TCIB.BULK.TRANS
    $INSERT I_NDB.TCIB.BULK.HDR.COMMON
	 
    hdrId = ID
    upldId = FIELD(hdrId,"-",1)

    EB.DataAccess.FRead(fnHeadTable, hdrId, headerRec, fpHeadTable, Er)
    
    IF headerRec<EB.NDB21.SD.FLAG> EQ 'NDB.TCIB.BULK.SD' THEN
        GOSUB GET.HDR.DETAILS ; *

        oData = hdrDebAccNo:"~AVAILABLE"
        EB.Reports.setOData(oData)
        AA.ModelBank.EAaConvGetBalances()
        availBal = EB.Reports.getOData()
        
        balFlag = ''
        IF availBal LT totaldebAmount THEN
            balFlag = 'Y'
            IF AcFlag EQ 'Y' THEN
                txnCom   = 1
                tranIdH1 = ''
                headerRec<EB.NDB21.REC.STATUS> = "PROCESSING"
                WRITE headerRec TO fpHeadTable, hdrId
            END ELSE
                errResp = "Insufficient Funds"
                GOSUB UPD.STATUS ; *Update Status for Header Record
                RETURN
            END
        END
        GOSUB PROCESS.FT ; *Process FT for Single Debit Transaction
        GOSUB UPD.STATUS ; *Update Status for Header Record
        
    END ELSE
        headerRec<EB.NDB21.REC.STATUS> = "PROCESSING"
        WRITE headerRec TO fpHeadTable, hdrId
        GOSUB UPD.TRAN.STATUS
    END

RETURN

*-----------------------------------------------------------------------------

*** <region name= PROCESS.FT>
PROCESS.FT:
*** <desc>Process FT for Single Debit Transaction </desc>
 
    ofsFunct  = "I"
    process = "PROCESS"
    gtsMode = ""
    noOfAuth  = "0"
    IF balFlag EQ 'Y' THEN
        gtsMode = "4"
        noOfAuth  = "1"
    END
    transactionId  = ""
    record = ""
    ofsRecord = ""
	EB.LocalReferences.GetLocRef(appName, 'TC.BULK.INPUTT', inputterPos)
    EB.LocalReferences.GetLocRef(appName, 'TC.BULK.AUTH', authorisorPos)
    
    IF totalCharge NE '' THEN
	    IF ceftChargeTotal NE 0 THEN
			record<FT.Contract.FundsTransfer.ChargesAcctNo>    = hdrDebAccNo
            record<FT.Contract.FundsTransfer.CommissionType,1> = ceftsComType
            record<FT.Contract.FundsTransfer.CommissionAmt,1>  = 'LKR ':ceftChargeTotal:'.':'00'
            IF slipsChargeTotal NE 0 THEN
				record<FT.Contract.FundsTransfer.ChargesAcctNo>    = hdrDebAccNo
                record<FT.Contract.FundsTransfer.CommissionType,2> = slipsComType
                record<FT.Contract.FundsTransfer.CommissionAmt,2>  = 'LKR ':slipsChargeTotal:'.':'00'
            END
	    END ELSE IF slipsChargeTotal NE 0 THEN
			record<FT.Contract.FundsTransfer.ChargesAcctNo>    = hdrDebAccNo
	        record<FT.Contract.FundsTransfer.CommissionType> = slipsComType
	        record<FT.Contract.FundsTransfer.CommissionAmt>  = 'LKR ':slipsChargeTotal:'.':'00'
	    END
    END
    record<FT.Contract.FundsTransfer.TransactionType> 		 	= TransactionType
    record<FT.Contract.FundsTransfer.DebitAcctNo>      			= hdrDebAccNo
    record<FT.Contract.FundsTransfer.DebitCurrency>  	    	= debCurr
    record<FT.Contract.FundsTransfer.DebitAmount>    			= debAmount
    record<FT.Contract.FundsTransfer.CreditAcctNo>      		= creditAc
    record<FT.Contract.FundsTransfer.CreditCurrency>    		= "LKR"
    record<FT.Contract.FundsTransfer.DebitValueDate>    		= currDate
    record<FT.Contract.FundsTransfer.OrderingBank>      		= "NDB"
    record<FT.Contract.FundsTransfer.DebitTheirRef>     		= debitRef
    record<FT.Contract.FundsTransfer.PaymentDetails>        	= paymentDetails
    record<FT.Contract.FundsTransfer.LocalRef,authorisorPos>    = autherisors
    record<FT.Contract.FundsTransfer.LocalRef,inputterPos,1>    = tcibInputter
	FOR index=count-1 TO 1 STEP -1
		intputters = FIELD(inputter<index>,'_',2)
		IF tcibInputter NE intputters THEN
            record<FT.Contract.FundsTransfer.LocalRef,inputterPos,count+1-index>     	= intputters
		END
		
	NEXT index
    EB.Foundation.OfsBuildRecord(appName, ofsFunct, process, ofsVersion, gtsMode, noOfAuth, transactionId, record, ofsRecord)
    EB.Interface.OfsCallBulkManager(ofsSource, ofsRecord, response, txnCom)
        
RETURN
*** </region>


*-----------------------------------------------------------------------------

*** <region name= UPD.STATUS>
UPD.STATUS:
*** <desc>Update Status for Header Record </desc>
   
    IF txnCom EQ '1' THEN
        tranIdH1 = FIELD(response,"/",1)
        tranIdH  = FIELD(tranIdH1,">",3)
        IF balFlag EQ 'Y' THEN
            headerRec<EB.NDB21.FT.NUMBER> = tranIdH1
            headerRec<EB.NDB21.REC.STATUS> = "FT.FAILED - Insufficient Funds"
            WRITE headerRec TO fpHeadTable, hdrId
        END ELSE
            headerRec<EB.NDB21.FT.NUMBER> = tranIdH
            headerRec<EB.NDB21.REC.STATUS> = "PROCESSING"
            WRITE headerRec TO fpHeadTable, hdrId
            GOSUB UPD.TRAN.STATUS ; *Update Status of Transaction Table as Ready to Porcess
        END
    END ELSE
        errResp = FIELD(response,",",2)
        headerRec<EB.NDB21.REC.STATUS> = "SINGLE.DEBIT.FAILED -":errResp
        WRITE headerRec TO fpHeadTable, hdrId
        RETURN
    END

RETURN
*** </region>


*-----------------------------------------------------------------------------

*** <region name= UPD.TRAN.STATUS>
UPD.TRAN.STATUS:
*** <desc>Update Status of Transaction Table as Ready to Porcess </desc>
   
    tranTableSel = "SELECT ":fnTranTable:" WITH @ID LIKE ":hdrId:"..."
    EB.DataAccess.Readlist(tranTableSel, tranList, '', tranListCount, tranListErr)
    
    FOR tID = 1 TO tranListCount
        tranId = tranList<tID>
        EB.DataAccess.FRead(fnTranTable, tranId, tranRec, fpTranTable, Er)
        tranRec<EB.NDB16.TC.TXN.STATUS> = "PROCESS.FT"
        IF headerRec<EB.NDB21.SD.FLAG> EQ 'NDB.TCIB.BULK.SD' THEN
            tranRec<EB.NDB16.SINGLE.DEBIT.FLAG> = 'NDB.TCIB.BULK.SD'
        END ELSE
            tranRec<EB.NDB16.SINGLE.DEBIT.FLAG> = 'NDB.TCIB.BULK.MD'
        END
        WRITE tranRec TO fpTranTable, tranId
    NEXT tID
    
RETURN
*** </region>


*-----------------------------------------------------------------------------

*** <region name= GET.HDR.DETAILS>
GET.HDR.DETAILS:
*** <desc> </desc>
   
    hdrDebAccNo    = headerRec<EB.NDB21.DEBIT.ACC>
    debAmount      = headerRec<EB.NDB21.UPLD.AMOUNT>
    debCurr        = headerRec<EB.NDB21.UPLD.CCY>
    tcTxnStat      = headerRec<EB.NDB21.TC.TXN.STATUS>
    tranTypeCnt    = headerRec<EB.NDB21.TRANSACTION.COUNT>
    tcibInputter   = headerRec<EB.NDB21.TC.INPUT.NAME>
    inputter      = headerRec<EB.NDB21.INPUTTER>
    autherisors    = headerRec<EB.NDB21.AUTHORISER>
	CHANGE @VM TO @FM IN inputter
    count = DCOUNT(inputter,@FM)
	autherisors    = FIELD(autherisors,'_',2)
    ceftCnt        = FIELD(tranTypeCnt,';',1)
    slipsCnt       = FIELD(tranTypeCnt,';',2)
    creditAc       = controlGlAcc
    GOSUB GET.ACT.CAT ; *
    GOSUB GET.CUS.CHARGES ; *
    IF ceftCharge EQ '' THEN
        ceftCharge          = ceftsGenCharge
	END
	IF slipsCharge EQ '' THEN
        slipsCharge         = slipsGenCharge
	END
	ceftChargeTotal     = ceftCharge*ceftCnt
    slipsChargeTotal    = slipsCharge*slipsCnt
    totalCharge         = ceftChargeTotal+slipsChargeTotal
    totaldebAmount      = debAmount+totalCharge
    debitRef            = upldId
    paymentDetails      = upldId
    
RETURN
*** </region>


*-----------------------------------------------------------------------------

*** <region name= GET.CUS.CHARGES>
GET.CUS.CHARGES:
*** <desc> </desc>
   
    SelCmd = "SELECT ":fnPpClientCharges:" WITH ClientID EQ ":customerId
    EB.DataAccess.Readlist(SelCmd, ppClientRecId, '', '', err)
    EB.DataAccess.FRead(fnPpClientCharges, ppClientRecId, ppClientRec, fpPpClientCharges, err)
    feeType         = ppClientRec<PP.FeeDeterminationService.Clientcharges.CcFeetype>
    fixedChargeAmts = ppClientRec<PP.FeeDeterminationService.Clientcharges.CcFixedchargeamount>
	
	FINDSTR "CEFT" IN feeType SETTING ceftPos ELSE ceftPos=''
	FINDSTR "SLIPS" IN feeType SETTING slipsPos ELSE slipsPos=''
    IF ceftPos EQ '' THEN
		IF slipsPos EQ '' THEN
			ceftCharge  = ''
			slipsCharge = ''
		END ELSE
			slipsCharge = fixedChargeAmts
		END
	END ELSE
		ceftCharge = fixedChargeAmts
		IF slipsPos NE '' THEN
			slipsCharge = fixedChargeAmts
		END
    END
	
RETURN
*** </region>


*-----------------------------------------------------------------------------

*** <region name= GET.ACT.CAT>
GET.ACT.CAT:
*** <desc> </desc>

    EB.DataAccess.FRead(fnAccount,hdrDebAccNo,AcRec,fpAccount,err)
    AcCat      = AcRec<AC.AccountOpening.Account.Category>
    customerId = AcRec<AC.AccountOpening.Account.Customer>
    IF AcCat LT 2000 OR AcCat GT 999 THEN
        AcFlag = 'Y'
    END
    
RETURN
*** </region>

END


