* @ValidationCode : MjoxNjM5Nzg4OTE3OkNwMTI1MjoxNzYxNzMxMjk5NjgyOkt1c2FseWE6LTE6LTE6MDowOmZhbHNlOk4vQTpSMjBfU1AzLjA6LTE6LTE=
* @ValidationInfo : Timestamp         : 29 Oct 2025 15:18:19
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
SUBROUTINE NOFILE.NDB.TCIB.HEADER(OUTPUT.DATA)
*-----------------------------------------------------------------------------
*Program Description:
*Purpose   : N
*Author    : kusalya.wijesekara@sysenact.com
*PGM.FILE  : NDB.TCIB.BULK.FT.STAT.UPD
*Date      : 10/27/2025
*-----------------------------------------------------------------------------
*Modification History:-
*-----------------------------------------------------------------------------

    $USING EB.DataAccess
    $USING EB.SystemTables
    $USING EB.ARC
    $USING ST.Customer
    $USING AC.AccountOpening
    $USING EB.Mandate
    $USING EB.Reports
	$INSERT I_F.EB.NDB.TCIB.BULK.HEADERS
	    
	queueFile = ""
	systemDate = EB.SystemTables.getToday()
 
*<tracer>----
	OPENSEQ 'TRACE.BP','AUTH.QUEUE-':systemDate:'.txt' TO queueFile ELSE NULL
    tracerData =  "********Start Tracer Writing********" :CHAR(010)
	tracerData :=  "Tracer Data writing - NDB.TCIB.ACC.LIST.BUILD>":EB.SystemTables.getTimeStamp() :CHAR(010)
	
    GOSUB initialise ; *To initialise the variables
    IF doProcess THEN
        GOSUB getMandateDetails ; *To fetch the mandate details of the account
        GOSUB GetOuputData ; *To perform selection and get the output data
    END
	 
*<tracer>----
    tracerData := "********End Tracer Writing********" :CHAR(010)
    WRITESEQ tracerData APPEND TO queueFile ELSE NULL
    tracerData = ''
*<tracer>----
    
RETURN
*-----------------------------------------------------------------------------

*** <region name= initialise>
initialise:
*** <desc>To initialise the variables </desc>
  
	OUTPUT.DATA = ""
	 
    iPos = ""
    LOCATE "TC.INPUT.NAME" IN EB.Reports.getDFields()<1> SETTING iPos THEN
        externalUser = EB.Reports.getDRangeAndValue()<iPos>
    END
	tracerData := "iPos : ":iPos :CHAR(010)
	tracerData := "externalUser : ":externalUser :CHAR(010)
	
	sdFlagPos = ""
    LOCATE "SD.FLAG" IN EB.Reports.getDFields()<1> SETTING sdFlagPos THEN
        sdFlag = EB.Reports.getDRangeAndValue()<sdFlagPos>
		type    = FIELD(sdFlag,'.',1,4)
    END
	tracerData := "sdFlagPos : ":sdFlagPos :CHAR(010)
	tracerData := "sdFlag : ":sdFlag :CHAR(010)
	
	sdFlagPos = ""
    LOCATE "ERROR.FLAG" IN EB.Reports.getDFields()<1> SETTING errFlagPos THEN
        errFlag = EB.Reports.getDRangeAndValue()<errFlagPos>
		IF errFlag NE '' THEN
			errFlag = ""
		END
    END
	tracerData := "errFlagPos : ":errFlagPos :CHAR(010)
	tracerData := "errFlag : ":errFlag :CHAR(010)
	
    debAcPos = ""
    LOCATE "DEBIT.ACC" IN EB.Reports.getDFields()<1> SETTING debAcPos THEN
        debitAccount = EB.Reports.getDRangeAndValue()<debAcPos>
    END
	tracerData := "debAcPos : ":debAcPos :CHAR(010)
	tracerData := "debitAccount : ":debitAccount :CHAR(010)

    appPos = ""
    IF NOT(externalUser) THEN
        LOCATE "TC.APRV.NAME" IN EB.Reports.getDFields()<1> SETTING appPos THEN
            externalUser = EB.Reports.getDRangeAndValue()<appPos>
        END
    END
	tracerData := "appPos : ":appPos :CHAR(010)
	tracerData := "externalUser : ":externalUser :CHAR(010)
    
    accList = externalUser
    EB.ndbBulkUpload.getExtUserAccts(accList)
    
    tracerData := "accList : ":accList :CHAR(010)
    
    FINDSTR debitAccount IN accList SETTING debitAccountPos THEN
        doProcess = 1
    END ELSE
        debitAccountPos = ''
    END
    
    tracerData := "debitAccountPos : ":debitAccountPos :CHAR(010)
    
    
    fnAcc = 'F.ACCOUNT'
    fpAcc = ''
    EB.DataAccess.Opf(fnAcc, fpAcc)
    
    fnCus = 'F.CUSTOMER'
    fpCus = ''
    EB.DataAccess.Opf(fnCus, fpCus)
    
    fnExtUsr = 'F.EB.EXTERNAL.USER'
    fpExtUsr = ''
    EB.DataAccess.Opf(fnExtUsr, fpExtUsr)
    
    fnSigGrp = 'F.EB.SIGNATORY.GROUP'
    fpSigGrp = ''
    EB.DataAccess.Opf(fnSigGrp, fpSigGrp)
    
    fnMand = 'F.EB.MANDATE'
    fpMand = ''
    EB.DataAccess.Opf(fnMand, fpMand)
   

RETURN
*** </region>


*-----------------------------------------------------------------------------

*** <region name= getMandateDetails>
getMandateDetails:
*** <desc>To fetch the mandate details of the account </desc>
  
    rAccount = ""
    EB.DataAccess.FRead(fnAcc, debitAccount, rAccount, fpAcc, accEr)
    cusId = rAccount<AC.AccountOpening.Account.Customer>
    tracerData := "cusId : ":cusId :CHAR(010)
    
    rCustomer = ""
    EB.DataAccess.FRead(fnCus, cusId, rCustomer, fpCus, cusEr)
    mandAppList = rCustomer<ST.Customer.Customer.EbCusMandateAppl>
    CHANGE @VM TO @FM IN mandAppList
    CHANGE @SM TO @FM IN mandAppList
    
    tracerData := "mandAppList : ":mandAppList :CHAR(010)
    
    manApPos = ""
    amount = ""
    LOCATE 'EB.NDB.TCIB.BULK.HEADERS' IN mandAppList SETTING manApPos ELSE
        manApPos = ""
    END
    
    IF manApPos THEN
        cusManId = rCustomer<ST.Customer.Customer.EbCusMandateRecord,manApPos>
        tracerData := "mandAppList : ":mandAppList :CHAR(010)
    
        EB.DataAccess.FRead(fnMand, cusManId, cusManRec, fpMand, cusManEr)
        cusManSigGrpLst = cusManRec<EB.Mandate.Mandate.MandSignatoryGroup>
        tracerData := "cusManSigGrpLst : ":cusManSigGrpLst :CHAR(010)
    
        rExternalUser = ""
        EB.DataAccess.FRead(fpExtUsr, externalUser, rExternalUser, fpExtUsr, extUsrEr)
        extUsrCusId = rExternalUser<EB.ARC.ExternalUser.XuCustomer>
        tracerData := "extUsrCusId : ":extUsrCusId :CHAR(010)
    
        selCmd = "SELECT ":fnSigGrp:" WITH SIGNATORY.CUSTOMER EQ ":extUsrCusId
    
        tracerData := "selCmd : ":selCmd :CHAR(010)
        EB.DataAccess.Readlist(selCmd, sigGrpList, '', sigGrpListCnt, sigGrpListEr)
        tracerData := "sigGrpList : ":sigGrpList :CHAR(010)
        tracerData := "sigGrpListCnt : ":sigGrpListCnt :CHAR(010)
    
        FOR sigGrpCnt=1 TO sigGrpListCnt
            sigGrp = sigGrpList<sigGrpCnt>
            sigGrpPosF = ""
            sigGrpPosV = ""
            sigGrpPosS = ""
            FIND sigGrp IN cusManSigGrpLst SETTING sigGrpPosF, sigGrpPosV, sigGrpPosS ELSE NULL
            tracerData := "sigGrpCnt : ":sigGrpCnt :CHAR(010)
            tracerData := "sigGrp : ":sigGrp :CHAR(010)
            tracerData := "sigGrpPosF : ":sigGrpPosF :CHAR(010)
            tracerData := "sigGrpPosV : ":sigGrpPosV :CHAR(010)
            tracerData := "sigGrpPosS : ":sigGrpPosS :CHAR(010)
        
            IF sigGrpPosV AND cusManRec<EB.Mandate.Mandate.MandUpToAmount,sigGrpPosV> GE amount THEN
                amount = cusManRec<EB.Mandate.Mandate.MandUpToAmount,sigGrpPosV>
            END
            tracerData := "amount : ":amount :CHAR(010)
        NEXT sigGrpCnt

    END

RETURN
*** </region>


*-----------------------------------------------------------------------------

*** <region name= GetOuputData>
GetOuputData:
*** <desc>To perform selection and get the output data </desc>
   

    fnNdbTcibBulkHeaderNau = "F.EB.NDB.TCIB.BULK.HEADERS$NAU"
    fvNdbTcibBulkHeaderNau = ""
    EB.DataAccess.Opf(fnNdbTcibBulkHeaderNau, fvNdbTcibBulkHeaderNau)
    selectCmd = "SELECT ": fnNdbTcibBulkHeaderNau :" WITH DEBIT.ACC EQ " :debitAccount: " AND AUTHORISER UNLIKE ..." :externalUser: "... AND TC.INPUT.NAME UNLIKE ..." :externalUser: "..."
    HeaderNauList = ""
    selectCnt = ""
    EB.DataAccess.Readlist(selectCmd, HeaderNauList, "", selectCnt, "")
	IF HeaderNauList ELSE
		fnNdbTcibBulkHeaderNau = "FISL.EB.NDB.TCIB.BULK.HEADERS$NAU"
		fvNdbTcibBulkHeaderNau = ""
		EB.DataAccess.Opf(fnNdbTcibBulkHeaderNau, fvNdbTcibBulkHeaderNau)
		selectCmd = "SELECT ": fnNdbTcibBulkHeaderNau :" WITH DEBIT.ACC EQ " :debitAccount: " AND AUTHORISER UNLIKE ..." :externalUser: "... AND TC.INPUT.NAME UNLIKE ..." :externalUser: "..."
		HeaderNauList = ""
		selectCnt = ""
		EB.DataAccess.Readlist(selectCmd, HeaderNauList, "", selectCnt, "")
	END
	tracerData := "selectCmd: ":selectCmd :CHAR(010)
	tracerData := "HeaderNauList: ":HeaderNauList :CHAR(010)

    GOSUB FormData ; *From the selected data, get the required details to form the output array.

RETURN
*** </region>


*-----------------------------------------------------------------------------

*** <region name= FormData>
FormData:
*** <desc>From the selected data, get the required details to form the output array. </desc>
   
    FOR pos = 1 TO selectCnt
        HeaderId = HeaderNauList<pos>
		tracerData := "HeaderId: ":HeaderId :CHAR(010)
		NdbTcibBulkHeaderNau = ""
		EB.DataAccess.FRead(fnNdbTcibBulkHeaderNau, HeaderId, rNdbTcibBulkHeaderNau, fvNdbTcibBulkHeaderNau, "")
		recStatus  = rNdbTcibBulkHeaderNau<EB.NDB21.REC.STATUS>
		recErrFlag = rNdbTcibBulkHeaderNau<EB.NDB21.ERROR.FLAG>
		recSdFlag  = rNdbTcibBulkHeaderNau<EB.NDB21.SD.FLAG>
		recAmount  = rNdbTcibBulkHeaderNau<EB.NDB21.UPLD.AMOUNT>
		
		
		IF (recStatus NE "DELETE" AND recErrFlag EQ errFlag) AND (recSdFlag EQ sdFlag AND recAmount LE amount) THEN
			currentRecord = HeaderId:"*":rNdbTcibBulkHeaderNau<EB.NDB21.UPLD.DATE>:"*":rNdbTcibBulkHeaderNau<EB.NDB21.SYS.DATE>:"*":rNdbTcibBulkHeaderNau<EB.NDB21.UPLD.CUS.ID>
			currentRecord := "*":rNdbTcibBulkHeaderNau<EB.NDB21.DEBIT.ACC>:"*":rNdbTcibBulkHeaderNau<EB.NDB21.UPLD.RECS>:"*":rNdbTcibBulkHeaderNau<EB.NDB21.UPLD.ID>
			currentRecord := "*":rNdbTcibBulkHeaderNau<EB.NDB21.REC.STATUS>:"*":rNdbTcibBulkHeaderNau<EB.NDB21.UPLD.AMOUNT>:"*":rNdbTcibBulkHeaderNau<EB.NDB21.UPLD.CCY>
			currentRecord := "*":rNdbTcibBulkHeaderNau<EB.NDB21.SD.FLAG>:"*":rNdbTcibBulkHeaderNau<EB.NDB21.SIGNATORY>:"*":rNdbTcibBulkHeaderNau<EB.NDB21.TC.TXN.STATUS>
			currentRecord := "*":rNdbTcibBulkHeaderNau<EB.NDB21.TC.INPUT.NAME>:"*":rNdbTcibBulkHeaderNau<EB.NDB21.TC.CHCKR.FLAG>:"*":rNdbTcibBulkHeaderNau<EB.NDB21.TC.CHCKR.NAME>
			currentRecord := "*":rNdbTcibBulkHeaderNau<EB.NDB21.TC.CHCKR.STATUS>:"*":rNdbTcibBulkHeaderNau<EB.NDB21.TC.APRV.NAME>:"*":rNdbTcibBulkHeaderNau<EB.NDB21.TC.APRV.STATUS>
			currentRecord := "*":rNdbTcibBulkHeaderNau<EB.NDB21.FT.NUMBER>:"*":rNdbTcibBulkHeaderNau<EB.NDB21.ERROR.FLAG>:"*":rNdbTcibBulkHeaderNau<EB.NDB21.PROCESSING.COUNT>
			currentRecord := "*":rNdbTcibBulkHeaderNau<EB.NDB21.FAILED.COUNT>:"*":rNdbTcibBulkHeaderNau<EB.NDB21.SUCCESS.COUNT>:"*":rNdbTcibBulkHeaderNau<EB.NDB21.RECORD.STATUS>
			currentRecord := "*":rNdbTcibBulkHeaderNau<EB.NDB21.OVERRIDE>:"*":rNdbTcibBulkHeaderNau<EB.NDB21.CURR.NO>:"*":rNdbTcibBulkHeaderNau<EB.NDB21.INPUTTER>
			currentRecord := "*":rNdbTcibBulkHeaderNau<EB.NDB21.DATE.TIME>:"*":rNdbTcibBulkHeaderNau<EB.NDB21.AUTHORISER>:"*":rNdbTcibBulkHeaderNau<EB.NDB21.CO.CODE>:"*":rNdbTcibBulkHeaderNau<EB.NDB21.DEPT.CODE>
			IF OUTPUT.DATA EQ '' THEN
*id*uploadDate*sysdate*customerId*debitAccount*upldRecords*amount*currency*uploadId*recStatus*sdFlag*signatory*transactionStatus*inputterName*checkerFlag*checkerName*chekerStatus*approverName*aprvStatus*ftNumber*errorFlag*processingCount*failedCount*successCount*override*recordStatus*currNo*inputter*dateTime*authoriser*coCode*deptCode*uploadDoc
				OUTPUT.DATA = currentRecord
				tracerData := "OUTPUT.DATA: ":OUTPUT.DATA :CHAR(010)
			END ELSE
				OUTPUT.DATA<-1> = currentRecord
				tracerData := "OUTPUT.DATA: ":OUTPUT.DATA :CHAR(010)
				END
			END
		
    NEXT pos
RETURN
*** </region>

END





