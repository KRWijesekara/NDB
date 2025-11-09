* @ValidationCode : MjotMTQwMDM1OTY5NDpDcDEyNTI6MTc1MjU1OTMzNDY2NzpLdXNhbHlhOi0xOi0xOjA6MDpmYWxzZTpOL0E6UjIwX1NQMy4wOi0xOi0x
* @ValidationInfo : Timestamp         : 15 Jul 2025 11:32:14
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
 
SUBROUTINE NDB.UPLOAD.FILE.VALIDATION
*-----------------------------------------------------------------------------
*
*-----------------------------------------------------------------------------
* Modification History :
*-----------------------------------------------------------------------------

*-----------------------------------------------------------------------------

    $USING EB.DataAccess
    $USING EB.SystemTables
    $USING EB.FileUpload
    $USING EB.ErrorProcessing
	$USING EB.LocalReferences
	$USING AA.ModelBank
	$USING EB.Reports
	$USING AC.AccountOpening
	$USING PP.FeeDeterminationService
    $INSERT I_F.EB.NDB.TCIB.BULK.TRANS
    $INSERT I_F.EB.NDB.TCIB.BULK.HEADERS
         
	  
    GOSUB INIT ; *Initializing Variables
    GOSUB PROCESS ; *Process Amendments

RETURN

*-----------------------------------------------------------------------------

*** <region name= INIT>
INIT:
*** <desc>Initializing Variables </desc>
           
    currDate = EB.SystemTables.getToday()
    tranTblId= EB.SystemTables.getIdNew() ;* get the version @id
    errId = FIELD(tranTblId,RIGHT(tranTblId,6),1)
    upldId = FIELD(errId,'-',1)
	headerId = errId
    
    fnErrTab = "F.NDB.TCIB.UPL.ERR"
    fpErrTab = ""
    EB.DataAccess.Opf(fnErrTab, fpErrTab)
     
    fnHeaderTable = "F.EB.NDB.TCIB.BULK.HEADERS$NAU"
    fpHeaderTable = ""
    EB.DataAccess.Opf(fnHeaderTable, fpHeaderTable)
	
    paramRecName = "NDB.TCIB.BULK.UPLD"
    fnParam      = "F.NDB.PARAMETER"
	fpParam      = ""
	EB.DataAccess.Opf(fnParam, fpParam)
	
	fnPpClientCharges = "FBNK.PP.CLIENTCHARGES"
    fpPpClientCharges = ""
    EB.DataAccess.Opf(fnPpClientCharges, fpPpClientCharges)
	
	EB.DataAccess.FRead(fnParam,paramRecName,paramRec,fpParam,err);* get parameter record
	
    fileUpldRec = EB.FileUpload.FileUpload.Read(upldId, ebFileUploadErr)
    EB.LocalReferences.GetLocRef('EB.FILE.UPLOAD', 'UPLD.ACCT.NO', upldAcNoPos)
	upldAc = fileUpldRec<EB.FileUpload.FileUpload.UfLocalRef,upldAcNoPos>
    
    EB.DataAccess.FRead(fnErrTab,errId,errRec,fpErrTab,err)
    
    FINDSTR "Transaction Type is Mandatory~" IN errRec SETTING txnTypPos ELSE txnTypPos=''
    IF txnTypPos EQ '' THEN
        FINDSTR "Invalid Transaction Type~" IN errRec SETTING txnTypPos ELSE txnTypPos=''
    END
	
    paramField   = paramRec<2>
    paramValue   = paramRec<3>
    
    LOCATE "FILE.ALLOWED.CHARS" IN paramField<1,1> SETTING pos THEN
        charList    = paramValue<1,pos>
    END

    LOCATE "TRANSACTION.CODES" IN paramField<1,1> SETTING pos THEN
        transactionCodes = paramValue<1,pos>
    END
    
    LOCATE "TRANSACTION.TYPES" IN paramField<1,1> SETTING pos THEN
        txnTypes = paramValue<1,pos>
    END
	
	LOCATE "SLIP.GENERAL.CHARGE" IN paramField<1,1> SETTING slipsGenPos THEN
        slipsGenCharge = paramValue<1,slipsGenPos>
    END
	
	LOCATE "CEFT.GENERAL.CHARGE" IN paramField<1,1> SETTING conCefPos THEN
        ceftsGenCharge = paramValue<1,conCefPos>
    END
    
    CHANGE @SM TO "" IN charList
    CHANGE ',' TO @VM IN txnTypes
    
    tranCusRef    = ''
    tranDrAc      = ''
    tranDate      = ''
    tranAmount    = ''
    tranCurr      = ''
    tranDrAcNm    = ''
    tranBenAc     = ''
    tranBenAcNm   = ''
    tranBnkCode   = ''
    tranBrnCode   = ''
    tranNarr      = ''
    tranBenEm     = ''
    tranCode      = ''
    benBankSwift  = ''
    charge        = ''
    BenAdd1       = ''
    BenAdd2       = ''
    BenAdd3       = ''
    Purpose1      = ''
    Purpose2      = ''
    Purpose3      = ''
    transType     = ''
    errMsg        = ''
    mVEFlag       = ''
    subErrFlag    = 'N'
    errFlag       = 'N'
    startLine     = ''
    totTranAmount = 0
    sdFlag        = 'N'
    endErr        = ''
    finalErrList  = ''
    upldId        = ''
    upldType      = ''
    
RETURN
*** </region>


**-----------------------------------------------------------------------------

*** <region name= SUB.VALIDATION>
SUB.VALIDATION:
*** <desc>Transaction Level Validations </desc>
          
	   
    bdyTranArray    = tranCusRef:'~':tranDrAc:'~':tranDrAcNm:'~':tranDate:'~':tranCurr:'~':tranBenAc:'~':tranBenAcNm:'~':tranBnkCode:'~':tranBrnCode:'~':tranNarr:'~':tranBenEm:'~':tranCode:'~':benBankSwift:'~':charge:'~':BenAdd1:'~':BenAdd2:'~':BenAdd3:'~':Purpose1:'~':Purpose2:'~':Purpose3:'~':transType:'~':tranAmount:'~':currDate:'~':upldId:'~':upldType:'~':tranTblId:'~':tranLine:'~':transactionCodes:'~':txnTypes
    newbdyTranArray = bdyTranArray
    bdyTranArray    = bdyTranArray:'~':upldAc
	
    EB.ndbBulkUpload.processTranValidation(bdyTranArray)
	
	 IF txnTypPos NE '' THEN;* get tran type count
        EB.DataAccess.FRead(fnHeaderTable,headerId,headerRec,fpHeaderTable,err);* get unauth hdr record
        tranTypeCnt    = headerRec<EB.NDB21.TRANSACTION.COUNT>
		chargefType    = headerRec<EB.NDB21.TOTAL.CHARGE.TYPE>
		fileTotAmt	   = headerRec<EB.NDB21.UPLD.AMOUNT>
        ceftCnt        = FIELD(tranTypeCnt,';',1)
        slipsCnt       = FIELD(tranTypeCnt,';',2)
        internalCnt    = FIELD(tranTypeCnt,';',3)
		totSlipsCharge = FIELD(chargefType,';',1)
		totCeftCharge  = FIELD(chargefType,';',2)
          
        IF transType EQ 'CEFTS' THEN
            ceftCnt = ceftCnt+1
        END ELSE IF transType EQ 'SLIPS' THEN
            slipsCnt = slipsCnt+1
        END ELSE IF transType EQ 'INTERNAL' THEN
            internalCnt = internalCnt+1
        END
		GOSUB GET.ACC.DETAILS
		GOSUB GET.CUS.CHARGES
		
        tranTypeCnt = ceftCnt:';':slipsCnt:';':internalCnt
        headerRec<EB.NDB21.TRANSACTION.COUNT> = tranTypeCnt
		headerRec<EB.NDB21.TOTAL.CHARGE.TYPE> = chargefType
        WRITE headerRec TO fpHeaderTable,headerId
    END 

    fileErr = ''
		errCount = DCOUNT(errRec,@FM)
		IF errCount GT 1 THEN
			FOR errLine = 1 TO errCount
				tranErrLine   = errRec<errLine>
				erLine 		  = tranErrLine
				CHANGE '~' TO @FM IN erLine
				tranErrLineNo = erLine<1>
				IF tranLine EQ tranErrLineNo THEN
					IF errLine EQ '1' THEN
						IF bdyTranArray NE '' THEN
							fileErr = 'Y'
							bdyTranCnt = DCOUNT(bdyTranArray,@FM)
							FOR bdyCnt=1 TO bdyTranCnt
								finalErrList<-1> = tranLine:'~':bdyTranArray<bdyCnt>:'~':tranTblId
								finalDataList<-1> = tranLine:'~':bdyTranArray<bdyCnt>:'~':tranTblId:'~':newbdyTranArray
							NEXT bdyCnt
							fullErrRec = FIELD(errRec,@FM,2,errCount)
							errRec     = finalDataList:@FM:fullErrRec
						END ELSE
							errRec = FIELD(errRec,@FM,2,errCount)
						END
						DELETE fpErrTab, errId
						WRITE errRec TO fpErrTab, errId
					END ELSE IF errLine EQ errCount THEN
						IF bdyTranArray NE '' THEN
							fileErr = 'Y'
							bdyTranCnt = DCOUNT(bdyTranArray,@FM)
							FOR bdyCnt=1 TO bdyTranCnt
								finalErrList<-1> = tranLine:'~':bdyTranArray<bdyCnt>:'~':tranTblId
								finalDataList<-1> = tranLine:'~':bdyTranArray<bdyCnt>:'~':tranTblId:'~':newbdyTranArray
							NEXT bdyCnt
							fullErrRec = FIELD(errRec,@FM,1,errCount-1)
							errRec     = fullErrRec:@FM:finalDataList
						END ELSE
							errRec = FIELD(errRec,@FM,1,errCount-1)
						END
						DELETE fpErrTab, errId
						WRITE errRec TO fpErrTab, errId
					END ELSE
						IF bdyTranArray NE '' THEN
							fileErr = 'Y'
							bdyTranCnt = DCOUNT(bdyTranArray,@FM)
							FOR bdyCnt=1 TO bdyTranCnt
								finalErrList<-1> = tranLine:'~':bdyTranArray<bdyCnt>:'~':tranTblId
								finalDataList<-1> = tranLine:'~':bdyTranArray<bdyCnt>:'~':tranTblId:'~':newbdyTranArray
							NEXT bdyCnt
							firstHalf  = FIELD(errRec,@FM,1,errLine-1)
							secondHalf = FIELD(errRec,@FM,errLine+1,errCount)
							errRec     = firstHalf:@FM:finalDataList:@FM:secondHalf
						END ELSE
							firstHalf  = FIELD(errRec,@FM,1,errLine-1)
							secondHalf = FIELD(errRec,@FM,errLine+1,errCount)
							errRec     = firstHalf:@FM:secondHalf
						END
						DELETE fpErrTab, errId
						WRITE errRec TO fpErrTab, errId
					END
				END
			NEXT errLine
		END ELSE
			headerRec = ""
			EB.DataAccess.FRead(fnHeaderTable,headerId,headerRec,fpHeaderTable,err);* get unauth hdr record
			headerRec<EB.NDB21.ERROR.FLAG>    = ''
			WRITE headerRec TO fpHeaderTable,headerId
		END
	
	IF totAmnt GT availBal THEN
		IF AcFlag EQ 'Y' THEN
			IF ceftCnt NE 0 OR internalCnt NE 0 THEN
				fileErr = 'Y'
				finalDataList= '1~Insufficient Funds~':totAmnt
				DELETE fpErrTab, errId
				WRITE finalDataList TO fpErrTab, errId
			END
		END ELSE
			fileErr = 'Y'
			finalDataList= '1~Insufficient Funds~':totAmnt
			DELETE fpErrTab, errId
			WRITE finalDataList TO fpErrTab, errId
		END
    END
    
RETURN
*** </region>

*** <region name= FTCH.TRANS.ETD>
FTCH.TRANS.ETD:
*** <desc>Fetch New Body Table Records </desc>

    tranCusRef    = EB.SystemTables.getRNew(EB.NDB16.CUST.REF)
    tranDrAc      = EB.SystemTables.getRNew(EB.NDB16.DEB.ACC)
    tranDate      = EB.SystemTables.getRNew(EB.NDB16.DEB.VAL.DATE)
    tranAmount    = EB.SystemTables.getRNew(EB.NDB16.DEB.AMOUNT)
    tranCurr      = EB.SystemTables.getRNew(EB.NDB16.DEB.CURR)
    tranDrAcNm    = EB.SystemTables.getRNew(EB.NDB16.DEB.ACC.NAME)
    tranBenAc     = EB.SystemTables.getRNew(EB.NDB16.BEN.ACC.NUM)
    tranBenAcNm   = EB.SystemTables.getRNew(EB.NDB16.BEN.NAME)
    tranBnkCode   = EB.SystemTables.getRNew(EB.NDB16.BEN.BANK.CODE)
    tranBrnCode   = EB.SystemTables.getRNew(EB.NDB16.BEN.BRANCH)
    tranNarr      = EB.SystemTables.getRNew(EB.NDB16.NARRATIVE)
    tranBenEm     = EB.SystemTables.getRNew(EB.NDB16.BEN.EMAIL)
    tranCode      = EB.SystemTables.getRNew(EB.NDB16.TRAN.CODE)
    benBankSwift  = EB.SystemTables.getRNew(EB.NDB16.BEN.BANK.SWIFT)
    charge        = EB.SystemTables.getRNew(EB.NDB16.CHARGE.OP)
    BenAdd1       = EB.SystemTables.getRNew(EB.NDB16.BEN.ADD1)
    BenAdd2       = EB.SystemTables.getRNew(EB.NDB16.BEN.ADD2)
    BenAdd3       = EB.SystemTables.getRNew(EB.NDB16.BEN.ADD3)
    Purpose1      = EB.SystemTables.getRNew(EB.NDB16.PURPOSE1)
    Purpose2      = EB.SystemTables.getRNew(EB.NDB16.PURPOSE2)
    Purpose3      = EB.SystemTables.getRNew(EB.NDB16.PURPOSE3)
    transType     = EB.SystemTables.getRNew(EB.NDB16.TYPE)
    upldId        = EB.SystemTables.getRNew(EB.NDB16.UPL.ID)
    upldType      = EB.SystemTables.getRNew(EB.NDB16.SINGLE.DEBIT.FLAG)

RETURN
*** </region>


*-----------------------------------------------------------------------------

*** <region name= PROCESS>
PROCESS:
*** <desc>Process Amendments </desc>
	   
    tranNum  = RIGHT(tranTblId,5)
    tranLine = TRIM(tranNum, "L", "0")
    tranLine = tranLine +1
    
    GOSUB FTCH.TRANS.ETD ; *Fetch New Body Table Records
    GOSUB SUB.VALIDATION
        
    IF fileErr EQ 'Y' THEN
        EB.SystemTables.setAf(EB.NDB16.OVERRIDE)
        EB.SystemTables.setEtext(finalErrList)
    END ELSE
        EB.SystemTables.setRNew(EB.NDB16.SYSTEM.DATE, currDate)
        EB.SystemTables.setRNew(EB.NDB16.ERROR.FLAG, 'CLEARED')
    END

RETURN
*** </region>



*-----------------------------------------------------------------------------

*** <region name= GET.ACC.DETAILS>
GET.ACC.DETAILS:
*** <de sc>GEt Account details </desc>
			
			AcRec   = AC.AccountOpening.Account.Read(upldAc,Err)
			AcCat   = AcRec<AC.AccountOpening.Account.Category>
			drCusId = AcRec<AC.AccountOpening.Account.Customer>
			oData = upldAc:"~AVAILABLE"
			EB.Reports.setOData(oData)
			AA.ModelBank.EAaConvGetBalances()
			availBal = EB.Reports.getOData()
			
			IF AcCat LT 2000 OR AcCat GT 999 THEN
				AcFlag = 'Y'
			END
		
        RETURN
*** </region>


*-----------------------------------------------------------------------------


*** <region name= GET.CUS.CHARGES>
GET.CUS.CHARGES:
*** <desc> </desc>

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
	totCharge 	   = totSlipsCharge+totCeftCharge
	chargefType    = totSlipsCharge:';':totCeftCharge
	totAmnt 	   = fileTotAmt+totCharge
	
RETURN
*** </region>

END

