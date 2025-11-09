* @ValidationCode : MjotNTM0NDkzMDgyOkNwMTI1MjoxNzYwNjk3NzU5Njk2OkxvaGl0aDotMTotMTowOjA6ZmFsc2U6Ti9BOlIyMF9TUDMuMDotMTotMQ==
* @ValidationInfo : Timestamp         : 17 Oct 2025 16:12:39
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

SUBROUTINE NOFILE.NDB.TCIB.ERR.VALI(DATA.LIST)
*-----------------------------------------------------------------------------
*Program Description:
*Purpose : Triggers validations for the files display the status of the uploaded file. Updates the local
*          tables and error concat table.
*Author  : Lohith Gunawardena | lohith.gunawardene@sysenact.com
*Date    : 03/05/2025
*Incoming: Uplaod Id
*Outgoing: A success message for success trans and display the details for error trans
*-----------------------------------------------------------------------------
* Modification History :
*-----------------------------------------------------------------------------

*-----------------------------------------------------------------------------

    $USING EB.DataAccess
    $USING EB.SystemTables
    $USING EB.FileUpload
    $USING AC.AccountOpening
    $USING EB.Reports
    $USING EB.API
    $USING EB.LocalReferences
    $USING AA.PaymentSchedule
    $USING ST.CompanyCreation
    $USING ST.Customer
    $USING AC.Config
    $USING AA.ModelBank
    $USING PP.FeeDeterminationService
    $USING EB.Foundation
    $USING EB.Interface
    $INSERT I_F.EB.NDB.TCIB.BULK.TRANS
    $INSERT I_F.EB.NDB.TCIB.BULK.HEADERS
	
    GOSUB INIT ; *Initialize Variables
    
    IF fileDataList EQ '' THEN
        DATA.LIST = '':"~Error in File Read~":''
        RETURN
    END
    
    IF errRec EQ '' THEN
        GOSUB PROCESS ; *Process Start
    END ELSE
        GOSUB ERR.LIST ; *View error list
        IF errRecList NE '' THEN
            DATA.LIST = errRecList
        END ELSE
            DATA.LIST = '':"~No Errors to Rectify~":''
        END
    END

RETURN
*-----------------------------------------------------------------------------

*** <region name= INIT>
INIT:
*** <desc>Initialize Variables </desc>
                              
    upldId = EB.Reports.getEnqSelection()<4,1>
    fileUpldRec = EB.FileUpload.FileUpload.Read(upldId, ebFileUploadErr)

    IF fileUpldRec EQ '' THEN
        fnFileUpldNau = 'F.EB.FILE.UPLOAD$NAU'
        fpFileUpldNau = ''
        EB.DataAccess.Opf(fnFileUpldNau, fpFileUpldNau)
        EB.DataAccess.FRead(fnFileUpldNau,upldId,fileUpldRec,fpFileUpldNau,err)
    END

    currDate = EB.SystemTables.getToday()
    getOperator = EB.SystemTables.getOperator()
    company = EB.SystemTables.getIdCompany()
    tno = EB.SystemTables.getTno()
    
    currentDate = OCONV(DATE(),"D-")
    timeStamp=TIMEDATE();*14:32:31 18 FEB 2020
    dateTime = currentDate[9,2]:currentDate[1,2]:currentDate[4,2]:timeStamp[1,2]:timeStamp[4,2]
        
    uploadFileName = fileUpldRec<EB.FileUpload.FileUpload.UfFileName>
    sysFileName = fileUpldRec<EB.FileUpload.FileUpload.UfSystemFileName>
    externaluser = fileUpldRec<EB.FileUpload.FileUpload.UfExternalUser>
    upldType = fileUpldRec<EB.FileUpload.FileUpload.UfUploadType>
    activityStatus = fileUpldRec<EB.FileUpload.FileUpload.UfRecordStatus>
    EB.LocalReferences.GetLocRef('EB.FILE.UPLOAD', 'UPLD.ACCT.NO', upldAcNoPos)
    upldAc = fileUpldRec<EB.FileUpload.FileUpload.UfLocalRef,upldAcNoPos>

    fnDir = "/Temenos/T24/bnk/UD/FILE.UPLOAD/BROWSER"
    fpDir = ""
    EB.DataAccess.Opf(fnDir, fpDir)
        
    FileName = uploadFileName[1, LEN(uploadFileName)-4]
    errId = upldId:'-':FileName
    headerId = errId
    fileDataList = ''
    errRec = ''
    
    READ fileDataList FROM fpDir,sysFileName ELSE
        RETURN
    END
    
    recCount = DCOUNT(fileDataList,@FM)

    fnErrTab = "F.NDB.TCIB.UPL.ERR"
    fpErrTab = ""
    EB.DataAccess.Opf(fnErrTab, fpErrTab)
    
    fnHeaderTable = "F.EB.NDB.TCIB.BULK.HEADERS$NAU"
    fpHeaderTable = ""
    EB.DataAccess.Opf(fnHeaderTable, fpHeaderTable)
    
    fnTransTable = "F.EB.NDB.TCIB.BULK.TRANS"
    fpTransTable = ""
    EB.DataAccess.Opf(fnTransTable, fpTransTable)
    
    paramRecName = "NDB.TCIB.BULK.UPLD"
    fnParam      = "F.NDB.PARAMETER"
    fpParam      = ""
    EB.DataAccess.Opf(fnParam, fpParam)
    
    fnPpClientCharges = "FBNK.PP.CLIENTCHARGES"
    fpPpClientCharges = ""
    EB.DataAccess.Opf(fnPpClientCharges, fpPpClientCharges)

    EB.DataAccess.FRead(fnParam,paramRecName,paramRec,fpParam,err);* get parameter record
    
    paramField   = paramRec<2>
    paramValue   = paramRec<3>
    
    LOCATE "FILE.ALLOWED.CHARS" IN paramField<1,1> SETTING pos THEN
        charList    = paramValue<1,pos>
    END

    LOCATE "TRANSACTION.TYPES" IN paramField<1,1> SETTING pos THEN
        txnTypes = paramValue<1,pos>
    END
       
    LOCATE "TRANSACTION.CODES" IN paramField<1,1> SETTING pos THEN
        transactionCodes = paramValue<1,pos>
    END
    
    LOCATE "LEAD.COMPANIES" IN paramField<1,1> SETTING pos THEN
        LeadCompanies = paramValue<1,pos>
    END
    
    LOCATE "SLIP.GENERAL.CHARGE" IN paramField<1,1> SETTING slipsGenPos THEN
        slipsGenCharge = paramValue<1,slipsGenPos>
    END
    
    LOCATE "CEFT.GENERAL.CHARGE" IN paramField<1,1> SETTING conCefPos THEN
        ceftsGenCharge = paramValue<1,conCefPos>
    END
    
    READ errRec FROM fpErrTab,errId ELSE recErr=1
    
    CHANGE @SM TO '' IN charList
    CHANGE @SM TO '' IN LeadCompanies
    CHANGE '^' TO @FM IN LeadCompanies
    CHANGE ',' TO @VM IN txnTypes
    
    errMsg          = ''
    mVErFlag        = 'N'
    subErrFlag      = 'N'
    errFlag         = 'N'
    startLine       = ''
    totTranAmount   = 0
    endErr          = ''
    errLine         = ''
    
    finalDataList   = ''
    finalErrList    = ''
    fileErr         = ''
    ceftCnt         = 0
    slipsCnt        = 0
    internalCnt     = 0
    tranTypeCnt     = ''
    pRDescription   = ''
    
RETURN
*** </region>


*-----------------------------------------------------------------------------

*** <region name= PROCESS>
PROCESS:
*** <desc>Process Start </desc>
	 
    GOSUB GET.ACC.DETAILS ; *Get Account Details

    IF AcDetailRec THEN
        AcStaus = AcDetailRec<AA.PaymentSchedule.AccountDetails.AdArrDormancyStatus>
        IF AcStaus NE '' THEN
            DATA.LIST = '1~Account not Active~'
            RETURN
        END
        
    END ELSE
        DATA.LIST = '1~Account not Active~'
        RETURN
    END
    
    IF pRDescription NE '' AND postingRestrict NE 21 THEN
        DATA.LIST = '1~':pRDescription:'~'
        RETURN
    END
    
    GOSUB MAIN.VALIDATION ; **Execture General File Validations   ***file.format, old.date, duplicate, empty.file
    IF mVErFlag EQ 'Y' THEN
        DATA.LIST = 'FILE NAME':'~':mainEr1:'~':''
        RETURN
    END

    GOSUB FETCH.HDR ; **Get Values in File Header if Available
    GOSUB VALIDATE.HEADER ; **Validate the data inputted in Header
    IF errFlag EQ 'Y' THEN
        IF noErrs GT 1 THEN
            RETURN
        END ELSE
            DATA.LIST = errMsg
            RETURN
        END
    END
    
    GOSUB UPDATE.TRAN.LT ; *Update Tran Table

    IF fileErr EQ '' THEN
        DATA.LIST<-1> = '':'~File Upload Success~':''
    END

RETURN
*** </region>


*-----------------------------------------------------------------------------

*** <region name= MAIN.VALIDATION>
MAIN.VALIDATION:
*** <desc>*Execture General File Validations   ***file.format, old.date, duplicate, empty.file </desc>
 
    mainValArray = FileName:'~':charList
    EB.ndbBulkUpload.processMainValidation(mainValArray)

    IF mainValArray NE '' THEN
        mainEr1 = FIELD(mainValArray,'~',2)
        mVErFlag = FIELD(mainValArray,'~',3)
    END

RETURN
*** </region>


*-----------------------------------------------------------------------------

*** <region name= FETCH.HDR>
FETCH.HDR:
*** <desc>*Get Values in File Header if Available </desc>

    fileDate    = FIELD(fileDataList<1>,',',1)
    fileTotAmt  = FIELD(fileDataList<1>,',',2)
    fileCur     = FIELD(fileDataList<1>,',',3)
    fileTotTran = FIELD(fileDataList<1>,',',4)
    
RETURN
*** </region>


*-----------------------------------------------------------------------------

*** <region name= VALIDATE.HEADER>
VALIDATE.HEADER:
*** <desc>*Validate the data inputted in Header </desc>
 
    hdrArray = fileDate:'~':fileTotAmt:'~':fileCur:'~':fileTotTran:'~':recCount
 
    EB.ndbBulkUpload.processHdrValidation(hdrArray)
 
    IF hdrArray NE '' THEN
        noErrs = DCOUNT(hdrArray,@FM)
        IF noErrs GT 1 THEN
            FOR err = 1 TO noErrs
                hdrError = hdrArray<err>
                IF err EQ noErrs THEN
                    errFlag = FIELD(hdrError,'~',4)
                END
                errLine = FIELD(hdrError,'~',1)
                errData = FIELD(hdrError,'~',2)
                errMsg = errLine:'~':errData:'~'
                DATA.LIST<-1> = errMsg
            NEXT err
        
        END ELSE
            errLine = FIELD(hdrArray,'~',1)
            errData = FIELD(hdrArray,'~',2)
            errMsg = errLine:'~':errData:'~'
            errFlag = FIELD(hdrArray,'~',4)
        END
    END
    
RETURN
*** </region>


*-----------------------------------------------------------------------------

*** <region name= UPDATE.TRAN.LT>
UPDATE.TRAN.LT:
*** <desc>Update Tran Table </desc>
	  
    ceftsTranExceed = ''
    slipsTranExceed = ''

    FOR tranLine = 2 TO recCount
        seqNo = FMT(tranLine-1, 'R%5')
        tranTblId = headerId:".":seqNo ;* headerid:00001
        
        lineData = fileDataList<tranLine>
        GOSUB FETCH.TRANS ; **Fetch Transactions in the Body
        IF transType EQ "CHQ" AND upldType EQ "NDB.TCIB.BULK.SD" THEN
            DATA.LIST = '1~Cheque Bulks should uploaded through Multi Debit~'
            BREAK
        END
        GOSUB SUB.VALIDATION ; *
        IF transType EQ 'CEFTS' THEN
            ceftCnt = ceftCnt+1
        END ELSE IF transType EQ 'SLIPS' THEN
            slipsCnt = slipsCnt+1
        END ELSE IF transType EQ 'INTERNAL' THEN
            internalCnt = internalCnt+1
        END
        decimalchk = ''
        decimalchk = FIELD(tranAmount,'.',2)
        IF decimalchk NE '' THEN
            IF LEN(decimalchk) LT 2 THEN
                fileTranAmount =tranAmount:'0'
            END ELSE IF LEN(decimalchk) EQ 2 THEN
                fileTranAmount =tranAmount
            END
        END ELSE
            fileTranAmount =tranAmount:'.00'
        END
        
        IF transType EQ "CEFTS" AND fileTranAmount GT "5000000.00" THEN
            ceftsTranExceed = 'Y'
            ceftsTranAmnt = fileTranAmount
            BREAK
        END
    
        IF transType EQ "SLIPS" AND fileTranAmount GT "10000000.00" THEN
            slipsTranExceed = 'Y'
            slipsTranAmnt   = fileTranAmount
            BREAK
        END
        
        BODY.REC<EB.NDB16.CUST.REF> = tranCusRef
        BODY.REC<EB.NDB16.DEB.ACC>  = tranDrAc
        BODY.REC<EB.NDB16.DEB.ACC.NAME> = tranDrAcNm
        BODY.REC<EB.NDB16.DEB.AMOUNT> = fileTranAmount
        BODY.REC<EB.NDB16.DEB.CURR> = tranCurr
        BODY.REC<EB.NDB16.DEB.VAL.DATE> = tranDate
        BODY.REC<EB.NDB16.BEN.ACC.NUM> = tranBenAc
        BODY.REC<EB.NDB16.BEN.NAME> = tranBenAcNm
        BODY.REC<EB.NDB16.BEN.BANK.CODE> = tranBnkCode
        BODY.REC<EB.NDB16.BEN.BRANCH> = tranBrnCode
        BODY.REC<EB.NDB16.NARRATIVE> = tranNarr
        BODY.REC<EB.NDB16.BEN.EMAIL> = tranBenEm
        BODY.REC<EB.NDB16.TRAN.CODE> = tranCode
        BODY.REC<EB.NDB16.BEN.BANK.SWIFT> = benBankSwift
        BODY.REC<EB.NDB16.CHARGE.OP> = charge
        BODY.REC<EB.NDB16.BEN.ADD1> = BenAdd1
        BODY.REC<EB.NDB16.BEN.ADD2> = BenAdd2
        BODY.REC<EB.NDB16.BEN.ADD3> = BenAdd3
        BODY.REC<EB.NDB16.PURPOSE1> = Purpose1
        BODY.REC<EB.NDB16.PURPOSE2> = Purpose2
        BODY.REC<EB.NDB16.PURPOSE3> = Purpose3
        BODY.REC<EB.NDB16.SYSTEM.DATE> = currDate
        BODY.REC<EB.NDB16.UPL.ID> = upldId
        BODY.REC<EB.NDB16.TYPE> = transType
        BODY.REC<EB.NDB16.SINGLE.DEBIT.FLAG> = upldType
        totTranAmount = totTranAmount+tranAmount
        WRITE BODY.REC TO fpTransTable,tranTblId
        tranErrMsg  = ''
        tranErrData = ''
         
    NEXT tranLine
         
    tranTypeCnt   = ceftCnt:';':slipsCnt:';':internalCnt
    GOSUB GET.CUS.CHARGES ; *Get Customer Charges

    IF fileTotAmt NE totTranAmount THEN
        IF fileErr NE 'Y' THEN
            fileErr = 'Y'
        END
        IF ceftsTranExceed THEN
            DATA.LIST = '1~CEFTS maximum transaction amount exceeded~':ceftsTranAmnt
			
        END ELSE IF slipsTranExceed THEN
            DATA.LIST = '1~SLIPS maximum transaction amount exceeded~':slipsTranAmnt
			
        END ELSE
            DATA.LIST = '1~Total Amount Missmatch~':fileTotAmt
        END
		RETURN
    END ELSE IF totAmnt GT availBal THEN
        IF AcFlag EQ 'Y' THEN
            IF ceftCnt NE 0 OR internalCnt NE 0 THEN
                IF fileErr NE 'Y' THEN
                    fileErr = 'Y'
                END
                DATA.LIST = '1~Insufficient Funds~':fileTotAmt
            END ELSE
                IF fileErr EQ 'Y' THEN
                    GOSUB WRITE.ERR.CONCAT ; *Write error data to concat file
                    DATA.LIST = finalDataList
                END
            END
                RETURN
        END ELSE
            IF fileErr NE 'Y' THEN
                fileErr = 'Y'
            END
            DATA.LIST = '1~Insufficient Funds~':fileTotAmt
        END
		RETURN
    END ELSE
        IF fileErr EQ 'Y' THEN
            GOSUB WRITE.ERR.CONCAT ; *Write error data to concat file
        END
        DATA.LIST = finalDataList
    END
    GOSUB UPDATE.HEADET.LT ; **Update Header Details in EB.NDB.TCIB.BULK.HEADER
    
RETURN
*** </region>


*-----------------------------------------------------------------------------

*** <region name= FETCH.TRANS>
FETCH.TRANS:
*** <desc>*Fetch Transactions in the Body </desc>

    tranCusRef    = FIELD(lineData,',',1)
    tranDrAc      = FIELD(lineData,',',2)
    tranDate      = FIELD(lineData,',',3)
    tranAmount    = FIELD(lineData,',',4)
    tranCurr      = FIELD(lineData,',',5)
    tranDrAcNm    = FIELD(lineData,',',6)
    tranBenAc     = FIELD(lineData,',',7)
    tranBenAcNm   = FIELD(lineData,',',8)
    tranBnkCode   = FIELD(lineData,',',9)
    tranBrnCode   = FIELD(lineData,',',10)
    tranNarr      = FIELD(lineData,',',11)
    tranBenEm     = FIELD(lineData,',',12)
    tranCode      = FIELD(lineData,',',13)
    benBankSwift  = FIELD(lineData,',',14)
    charge        = FIELD(lineData,',',15)
    BenAdd1       = FIELD(lineData,',',16)
    BenAdd2       = FIELD(lineData,',',17)
    BenAdd3       = FIELD(lineData,',',18)
    Purpose1      = FIELD(lineData,',',19)
    Purpose2      = FIELD(lineData,',',20)
    Purpose3      = FIELD(lineData,',',21)
    transType     = FIELD(lineData,',',22)

RETURN
*** </region>


*-----------------------------------------------------------------------------

*** <region name= SUB.VALIDATION>
SUB.VALIDATION:
*** <desc> </desc>
	 
    bdyTranArray = tranCusRef:'~':tranDrAc:'~':tranDrAcNm:'~':tranDate:'~':tranCurr:'~':tranBenAc:'~':tranBenAcNm:'~':tranBnkCode:'~':tranBrnCode:'~':tranNarr:'~':tranBenEm:'~':tranCode:'~':benBankSwift:'~':charge:'~':BenAdd1:'~':BenAdd2:'~':BenAdd3:'~':Purpose1:'~':Purpose2:'~':Purpose3:'~':transType:'~':tranAmount:'~':currDate:'~':upldId:'~':upldType:'~':tranTblId:'~':tranLine:'~':transactionCodes:'~':txnTypes
    newbdyTranArray = bdyTranArray
    bdyTranArray = bdyTranArray:'~':upldAc
    EB.ndbBulkUpload.processTranValidation(bdyTranArray)
    
    IF bdyTranArray NE '' THEN
        fileErr = 'Y'
        bdyTranCnt = DCOUNT(bdyTranArray,@FM)
        FOR bdyCnt=1 TO bdyTranCnt
            finalErrList<-1> = tranLine:'~':bdyTranArray<bdyCnt>:'~':tranTblId
            finalDataList<-1> = tranLine:'~':bdyTranArray<bdyCnt>:'~':tranTblId:'~':newbdyTranArray
        NEXT bdyCnt
    END

RETURN
*** </region>


*-----------------------------------------------------------------------------

*** <region name= UPDATE.HEADET.LT>
UPDATE.HEADET.LT:
*** <desc>*Update Header Details in EB.NDB.TCIB.BULK.HEADER </desc>
	 
    decimalchk = ''
    decimalchk = FIELD(fileTotAmt,'.',2)
    IF decimalchk NE '' THEN
        IF LEN(decimalchk) LT 2 THEN
            fileHTotal =fileTotAmt:'0'
        END ELSE IF LEN(decimalchk) EQ 2 THEN
            fileHTotal =fileTotAmt
        END
    END ELSE
        fileHTotal =fileTotAmt:'.00'
    END

    appName     = "EB.NDB.TCIB.BULK.HEADERS"
    ofsFunct    = "I"
    process     = "PROCESS"
    ofsVersion  = "EB.NDB.TCIB.BULK.HEADERS,OFS"
    gtsMode     = ""
    noOfAuth    = "1"
    tranId      = headerId
    record      = ""
    ofsRecord   = ""
    ofsSource   = "NDB.GEFU"

    HEADER.REC<EB.NDB21.UPLD.DATE>      = fileDate
    HEADER.REC<EB.NDB21.SYS.DATE>       = currDate
    HEADER.REC<EB.NDB21.UPLD.CUS.ID>    = drCusId
    HEADER.REC<EB.NDB21.DEBIT.ACC>      = tranDrAc
    HEADER.REC<EB.NDB21.UPLD.RECS>      = fileTotTran
    HEADER.REC<EB.NDB21.UPLD.AMOUNT>    = fileHTotal
    HEADER.REC<EB.NDB21.UPLD.CCY>       = fileCur
    HEADER.REC<EB.NDB21.UPLD.ID>        = upldId
    HEADER.REC<EB.NDB21.REC.STATUS>     = "INPUTTED"
    HEADER.REC<EB.NDB21.SD.FLAG>        = upldType
    HEADER.REC<EB.NDB21.TC.INPUT.NAME>  = externaluser
    HEADER.REC<EB.NDB21.TRANSACTION.COUNT>  = tranTypeCnt
    HEADER.REC<EB.NDB21.TOTAL.CHARGE.TYPE>  = chargefType
    HEADER.REC<EB.NDB21.RECORD.STATUS>  = 'INAU'
    HEADER.REC<EB.NDB21.INPUTTER>       = tno:'_':getOperator
    HEADER.REC<EB.NDB21.DATE.TIME>      = dateTime
    HEADER.REC<EB.NDB21.CO.CODE>        = company
    HEADER.REC<EB.NDB21.DEPT.CODE>      = '1'
    HEADER.REC<EB.NDB21.CURR.NO>        = '1'

    IF fileErr EQ 'Y' THEN
        HEADER.REC<EB.NDB21.ERROR.FLAG>    = 'Y'		
    END

    ST.CompanyCreation.LoadCompany(company)

*    EB.Foundation.OfsBuildRecord(appName, ofsFunct, process, ofsVersion, gtsMode, noOfAuth, tranId, HEADER.REC, ofsRecord)
*    EB.Interface.OfsCallBulkManager(ofsSource, ofsRecord, response, txnCom)

*    CALL JOURNAL.UPDATE('')

**<tracer>----
*    OPENSEQ 'TRACE.BP','NOFILE.NDB.TCIB.ERR.VALI-OFS.txt' TO MYFILE ELSE NULL
*    ARR = "Tracer Data Writing - NOFILE.NDB.TCIB.ERR.VALI":CHAR(010)
*    ARR := "headerId    :":headerId     :CHAR(010)
*    ARR := "ofsSource   :":ofsSource    :CHAR(010)
*    ARR := "ofsRecord   :":ofsRecord    :CHAR(010)
*    ARR := "response    :":response     :CHAR(010)
*    ARR := ".........................:" :CHAR(010)
*    WRITESEQ ARR APPEND TO MYFILE ELSE NULL
**<tracer>----
*
*    IF txnCom NE 1 THEN
*        fileErr = 'Y'
*    END

    WRITE HEADER.REC TO fpHeaderTable,headerId
    
RETURN
*** </region>


*-----------------------------------------------------------------------------

*** <region name= ERR.LIST>
ERR.LIST:
*** <desc>View error list </desc>

    EB.DataAccess.FRead(fnErrTab,errId,errRec,fpErrTab,err)
    recCount = DCOUNT(errRec,@FM)
    
    FOR rcCnt=1 TO recCount
        tranTblId = FIELD(errRec<rcCnt>,'~',4)
        EB.DataAccess.FRead(fnTransTable, tranTblId, tranTblRec, fpTransTable, tranTblEr)
        errFlg = tranTblRec<EB.NDB16.ERROR.FLAG>
        IF errFlg EQ 'CLEARED' THEN
            CONTINUE
        END ELSE
            errRecList<-1> = errRec<rcCnt>
        END
    NEXT rcCnt

RETURN
*** </region>


*-----------------------------------------------------------------------------

*** <region name= READ.TRAN.TBL>
READ.TRAN.TBL:
*** <desc> </desc>

    EB.DataAccess.FRead(fnTransTable, bulkTranId, tranRec,fpTransTable, tranErr)
   
    tranCusRef = tranRec<EB.NDB16.CUST.REF>
    tranDrAc = tranRec<EB.NDB16.DEB.ACC>
    tranDrAcNm = tranRec<EB.NDB16.DEB.ACC.NAME>
    tranAmt = tranRec<EB.NDB16.DEB.AMOUNT>
    tranDate = tranRec<EB.NDB16.DEB.VAL.DATE>
    tranCurr = tranRec<EB.NDB16.DEB.CURR>
    tranBenAc = tranRec<EB.NDB16.BEN.ACC.NUM>
    tranBenAcNm = tranRec<EB.NDB16.BEN.NAME>
    tranBnkCode = tranRec<EB.NDB16.BEN.BANK.CODE>
    tranBrnCode = tranRec<EB.NDB16.BEN.BRANCH>
    tranNarr = tranRec<EB.NDB16.NARRATIVE>
    tranBenEm = tranRec<EB.NDB16.BEN.EMAIL>
    tranCode = tranRec<EB.NDB16.TRAN.CODE>
    benBankSwift = tranRec<EB.NDB16.BEN.BANK.SWIFT>
    charge = tranRec<EB.NDB16.CHARGE.OP>
    BenAdd1 = tranRec<EB.NDB16.BEN.ADD1>
    BenAdd2 = tranRec<EB.NDB16.BEN.ADD2>
    BenAdd3 = tranRec<EB.NDB16.BEN.ADD3>
    Purpose1 = tranRec<EB.NDB16.PURPOSE1>
    Purpose2 = tranRec<EB.NDB16.PURPOSE2>
    Purpose3 = tranRec<EB.NDB16.PURPOSE3>
    transType = tranRec<EB.NDB16.TYPE>
            
RETURN
*** </region>


*-----------------------------------------------------------------------------

*** <region name= WRITE.ERR.CONCAT>
WRITE.ERR.CONCAT:
*** <desc>Write error data to concat file </desc>

    WRITE finalDataList TO fpErrTab,errId

RETURN
*** </region>


*-----------------------------------------------------------------------------

*** <region name= GET.ACC.DETAILS>
GET.ACC.DETAILS:
*** <desc>Get Account Details </desc>

    LeadCompaniesCnt = DCOUNT(LeadCompanies, @FM)
    FOR LoopCnt = 1 TO LeadCompaniesCnt
        CurrLeadCompany = LeadCompanies<LoopCnt>
        ST.CompanyCreation.LoadCompany(CurrLeadCompany) ;* Switch company
        
        fnAccount = "F.ACCOUNT"
        fpAccount = ""
        EB.DataAccess.Opf(fnAccount, fpAccount)

        fnAcDetail = 'F.AA.ACCOUNT.DETAILS'
        fpAcDetail = ''
        EB.DataAccess.Opf(fnAcDetail, fpAcDetail)
        
        EB.DataAccess.FRead(fnAccount,upldAc,upldAcRec,fpAccount,err);* get account record
        upldAcArr       = upldAcRec<AC.AccountOpening.Account.ArrangementId>
        drCusId         = upldAcRec<AC.AccountOpening.Account.Customer>
        postingRestrict = upldAcRec<AC.AccountOpening.Account.PostingRestrict>
        workingBalance  = upldAcRec<AC.AccountOpening.Account.WorkingBalance>
        AcCat      = upldAcRec<AC.AccountOpening.Account.Category>
        oData = upldAc:"~AVAILABLE"
        EB.Reports.setOData(oData)
        AA.ModelBank.EAaConvGetBalances()
        availBal = EB.Reports.getOData()
            
        IF AcCat GT 999 AND AcCat LT 2000 THEN
            AcFlag = 'Y'
        END
            
        EB.DataAccess.FRead(fnAcDetail,upldAcArr,AcDetailRec,fpAcDetail,err)
        
        IF AcDetailRec NE '' THEN
            IF postingRestrict EQ '' THEN
                customerRec     = ST.Customer.Customer.Read(drCusId,CusErr)
                postingRestrict = customerRec<ST.Customer.Customer.EbCusPostingRestrict>
            END
            pRRecord        = AC.Config.PostingRestrict.Read(postingRestrict, Error)
            pRDescription   = pRRecord<AC.Config.PostingRestrict.PosDescription>
                
            RETURN
        END
        
    NEXT LoopCnt
        
RETURN

RETURN
*** </region>


*-----------------------------------------------------------------------------

*** <region name= GET.CUS.CHARGES>
GET.CUS.CHARGES:
*** <desc>Get Customer Charges </desc>

    SelCmd = "SELECT ":fnPpClientCharges:" WITH ClientID EQ ":drCusId
    EB.DataAccess.Readlist(SelCmd, ppClientRecId, '', '', err)
    EB.DataAccess.FRead(fnPpClientCharges, ppClientRecId, ppClientRec, fpPpClientCharges, err)
    feeType         = ppClientRec<PP.FeeDeterminationService.Clientcharges.CcFeetype>
    fixedChargeAmts = ppClientRec<PP.FeeDeterminationService.Clientcharges.CcFixedchargeamount>

    FINDSTR "CEFT" IN feeType SETTING ceftPos ELSE ceftPos=''
    FINDSTR "SLIPS" IN feeType SETTING slipsPos ELSE slipsPos=''
    IF ceftPos EQ '' THEN
        IF slipsPos EQ '' THEN
            ceftCharge  = ceftsGenCharge
            slipsCharge = slipsGenCharge
        END ELSE
            slipsCharge = fixedChargeAmts
            ceftCharge  = ceftsGenCharge
        END
    END ELSE
        ceftCharge = fixedChargeAmts
        IF slipsPos NE '' THEN
            slipsCharge = fixedChargeAmts
        END ELSE
            slipsCharge = slipsGenCharge
        END
    END
    
    totSlipsCharge = slipsCnt*slipsCharge
    totCeftCharge  = ceftCnt*ceftCharge
    totCharge      = totSlipsCharge+totCeftCharge
    chargefType    = totSlipsCharge:';':totCeftCharge
    totAmnt        = fileTotAmt+totCharge
    
RETURN
*** </region>

END


