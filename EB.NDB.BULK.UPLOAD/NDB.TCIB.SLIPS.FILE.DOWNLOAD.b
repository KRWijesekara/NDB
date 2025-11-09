* @ValidationCode : MjotMTQ3MzU1NDE1MDpDcDEyNTI6MTc1NTg1MDI5MzQyOTpMb2hpdGg6LTE6LTE6MDowOmZhbHNlOk4vQTpSMjBfU1AzLjA6LTE6LTE=
* @ValidationInfo : Timestamp         : 22 Aug 2025 13:41:33
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

SUBROUTINE NDB.TCIB.SLIPS.FILE.DOWNLOAD
*-----------------------------------------------------------------------------
*
*-----------------------------------------------------------------------------
* Modification History :
*-----------------------------------------------------------------------------

*-----------------------------------------------------------------------------

    $USING EB.DataAccess
    $USING EB.API
    $USING EB.SystemTables
    $USING FT.Contract
	 
    $INSERT I_F.EB.NDB.TCIB.BULK.HEADERS
    $INSERT I_F.EB.NDB.TCIB.BULK.TRANS
     
    GOSUB INIT ; *Initialize Variables
    IF concRec THEN
        GOSUB BUILD.HEADER ; *Build Header for SLIPS OWD File
        GOSUB BUILD.SUB.HEADER ; *Build Sub Header for SLIPS File
        GOSUB BUILD.BODY ; *Build transactions for the body
        GOSUB GEN.FILE ; *Generate OWD file
    END

RETURN

*-----------------------------------------------------------------------------

*** <region name= INIT>
INIT:
*** <desc>Initialize Variables </desc>
	 
    fnTranTable = "F.EB.NDB.TCIB.BULK.TRANS"
    fpTranTable = ""
    EB.DataAccess.Opf(fnTranTable, fpTranTable)
    
    fnSlipConc  = "F.NDB.TCIB.SLIPS.DET"
    fpSlipConc = ""
    EB.DataAccess.Opf(fnSlipConc, fpSlipConc)
    
    fnClrConf = "F.NDB.H.CHEQUES.CLEARING.CONFIGS"
    fpClrConf = ""
    EB.DataAccess.Opf(fnClrConf, fpClrConf)
    
    fnFundTran = "F.FUNDS.TRANSFER"
    fpFundTran = ""
    EB.DataAccess.Opf(fnFundTran, fpFundTran)
	
	fnPpClearingNonworkingday = "F.PP.CLEARING.NONWORKINGDAY"
    fpPpClearingNonworkingday = ""
    EB.DataAccess.Opf(fnPpClearingNonworkingday, fpPpClearingNonworkingday)
    
    fnPath = "/Temenos/T24/bnk/UD/FILE.UPLOAD/SLIP.FILE"
    fpPath = ""
    EB.DataAccess.Opf(fnPath, fpPath)
    
    paramRecId = "SYSTEM"
    
    EB.DataAccess.FRead(fnClrConf, paramRecId, clrConfRec, fpClrConf, clrConfEr)
    
    bankPas     = clrConfRec<1>
    lnkClrPas   = clrConfRec<2>
    
    spc   = ""
    bnkCode = "7214"
    brnCode = "900"
    slpTranId = "0000"
    file    =   ""
    
    ftNum = EB.SystemTables.getIdNew()
    fileName = EB.SystemTables.getRNew(FT.Contract.FundsTransfer.DebitTheirRef) ;* pass filename from the nofile when executing FT
    
    READ concRec FROM fpSlipConc,fileName ELSE concErr=1
    
    slipRecCnt = FIELD(concRec,'~',2)
    slipRecCnt = FMT(slipRecCnt, "R%6")
    
    totTranAmt = FIELD(concRec,'~',3)
	totTranAmt = totTranAmt*100
    totTranAmt = FMT(totTranAmt, "R%15")
	
    
    hashTot = FIELD(concRec,'~',5)
    hashTot = FMT(hashTot, "R%18")
    
    currdate = EB.SystemTables.getToday()
	time	 = EB.SystemTables.getTimeStamp()
	year     = FIELD(time," ",4)
	time     = FIELD(time," ",1)
	
	pcnwdRecId = "LNKCLR.":year
	EB.DataAccess.FRead(fnPpClearingNonworkingday, pcnwdRecId, pcnwdRec, fpPpClearingNonworkingday, clrConfEr)
	pcnwdRec = pcnwdRec<4>
	CHANGE @VM TO @FM IN pcnwdRec
    julDate = ''
    EB.API.Juldate(currdate, julDate)
    julDate = RIGHT(julDate,5)
    
RETURN
*** </region>


*-----------------------------------------------------------------------------

*** <region name= BUILD.HEADER>
BUILD.HEADER:
*** <desc>Build Header for SLIPS OWD File </desc>
  
*Bank control Id(5555) / Field Id(OUT) / Date(YYDDD) / Bank Code / No. of Batches or Branches / No. of Transactions / Blank
    hCtrlId = "5555"
    fldId   = "OUT"
    noOfBrn = "001"
    hdrBlank = FMT(spc, "R#155")

    hdr = hCtrlId:fldId:julDate:bnkCode:noOfBrn:slipRecCnt:hdrBlank
    finFile := hdr

RETURN
*** </region>


*-----------------------------------------------------------------------------

*** <region name= BUILD.SUB.HEADER>
BUILD.SUB.HEADER:
*** <desc>Build Sub Header for SLIPS File </desc>
  
    shCtrlId = "4444"
    fldId   = "OUT"
    debTot = ""
    debTot = FMT(debTot, "R%15")
    debCnt = ""
    debCnt = FMT(debCnt, "R%6")
    dirDeb = FMT(spc, "R%21")
    shdrBlank = FMT(spc, "R#101")

    subHdr = shCtrlId:fldId:julDate:bnkCode:brnCode:totTranAmt:slipRecCnt:debTot:debCnt:hashTot:shdrBlank
    finFile := subHdr

RETURN
*** </region>


*-----------------------------------------------------------------------------

*** <region name= BUILD.BODY>
BUILD.BODY:
*** <desc>Build transactions for the body </desc>
 
    selCmd = "SELECT ":fpTranTable:" WITH TC.TXN.STATUS EQ FILE.DOWNLOAD.STARTED"
    EB.DataAccess.Readlist(selCmd, slipRecs, '', slipRecCnt, slipEr)

    FOR slipCnt=1 TO slipRecCnt
        tranId = slipRecs<slipCnt>
        EB.DataAccess.FRead(fnTranTable, tranId, tranRec, fpTranTable, Er)
        
        desBnk  = tranRec<EB.NDB16.BEN.BANK.CODE>
        desBrn  = tranRec<EB.NDB16.BEN.BRANCH>
        desAcc  = tranRec<EB.NDB16.BEN.ACC.NUM>
        desAcc  = FMT(desAcc, "R%12")
        desAcNm = tranRec<EB.NDB16.BEN.NAME>
        desAcNm = FMT(desAcNm, "L#20")
        trnCode = tranRec<EB.NDB16.TRAN.CODE>
        retCode = "00"
        filler  = "0"
        orTrVD  = "000000"
        amt     = tranRec<EB.NDB16.DEB.AMOUNT>
        FINDSTR '.' IN amt SETTING amtPos ELSE amtPos=''
        IF amtPos NE '' THEN
            amt = amt*100
        END ELSE
            amt = amt:'00'
        END
        amt     = FMT(amt, "R%12")
        curr    = "SLR"
        debAc   = tranRec<EB.NDB16.DEB.ACC>
        debAcNm = tranRec<EB.NDB16.DEB.ACC.NAME>
        debAcNm = FMT(debAcNm, "L#20")
        prtic   = tranRec<EB.NDB16.FT.NUMBER>
        prtic   = FMT(prtic, "L#15")
        ref     = tranRec<EB.NDB16.CUST.REF>
        ref     = FMT(ref, "L#15")
		IF time GT "13.30.00" THEN
			currdate = currdate+1
		END
		LOCATE currdate IN pcnwdRec SETTING holiday ELSE holiday = ""
		IF holiday NE "" THEN
			currdate = currdate+1
			nextHolyDay = pcnwdRec<holiday+1>
			LOOP WHILE currdate LE nextHolyDay
			
				IF nextHolyDay EQ currdate THEN
				I = 2
					nextHolyDay = pcnwdRec<holiday+I>
					currdate = currdate+1
				I = I+1
				END ELSE
					BREAK
				END
			REPEAT
		END
		
        *valDate = tranRec<EB.NDB16.DEB.VAL.DATE>
		valDate = currdate
        valDate = RIGHT(valDate,6)
        GOSUB SEC.CHECK ; *Security Check Field Calculation
        secChk  = secField
        secChk  = FMT(secChk, "R%6")
        tranBlank = FMT(spc, "R#30")
        
        bdy = slpTranId:desBnk:desBrn:desAcc:desAcNm:trnCode:retCode:filler:orTrVD:amt:curr:bnkCode:brnCode:debAc:debAcNm:prtic:ref:valDate:secChk:tranBlank
        bdyRec := bdy
        
        tranRec<EB.NDB16.TC.TXN.STATUS> = "FILE.DOWNLOADED"
        WRITE tranRec TO fpTranTable, tranId
        
    NEXT slipCnt
    
    finFile := bdyRec
    TRIM(finFile, ' ', 'T')

RETURN
*** </region>


*-----------------------------------------------------------------------------

*** <region name= GEN.FILE>
GEN.FILE:
*** <desc>Generate OWD file </desc>

    path = "/Temenos/T24/bnk/UD/FILE.UPLOAD/SLIP.FILE"
    compFile = path:'/':fileName
    OPENSEQ path ,fileName TO point.file ELSE CREATE point.file

    WRITEBLK finFile TO point.file
    finFile = ''

    CHANGE "FILE.DOWNLOAD.STARTED" TO "FILE.DOWNLOADED" IN concRec
    WRITE concRec TO fpSlipConc,fileName
    
RETURN
*** </region>


*-----------------------------------------------------------------------------

*** <region name= SEC.CHECK>
SEC.CHECK:
*** <desc>Security Check Field Calculation </desc>

    arr1 = lnkClrPas
    arr2 = bankPas

    lp1 = arr1[1,1]
    lp2 = arr1[2,1]
    lp3 = arr1[3,1]
    lp4 = arr1[4,1]
    lp5 = arr1[5,1]
    lp6 = arr1[6,1]
    lp7 = arr1[7,1]
    lp8 = arr1[8,1]

    bp1 = arr2[1,1]
    bp2 = arr2[2,1]
    bp3 = arr2[3,1]
    bp4 = arr2[4,1]
    bp5 = arr2[5,1]
    bp6 = arr2[6,1]
    bp7 = arr2[7,1]
    bp8 = arr2[8,1]

    tempAr1 = (lp1:lp2:lp3:lp4)+(bp5:bp6:bp7:bp8)
    IF LEN(tempAr1) GT 4 THEN
        tempAr1 = RIGHT(tempAr1,4)
    END
    tempAr2 = (lp5:lp6:lp7:lp8)+(bp1:bp2:bp3:bp4)
    IF LEN(tempAr2) GT 4 THEN
        tempAr2 = RIGHT(tempAr2,4)
    END
    
    lp9  = tempAr1[1,1]
    lp10 = tempAr1[2,1]
    lp11 = tempAr1[3,1]
    lp12 = tempAr1[4,1]

    bp9  = tempAr2[1,1]
    bp10 = tempAr2[2,1]
    bp11 = tempAr2[3,1]
    bp12 = tempAr2[4,1]

    tempAr3 = arr1:lp9:lp10:lp11:lp12
    tempAr4 = arr2:bp9:bp10:bp11:bp12

    tempAr5 = tempAr3 + tempAr4
    IF LEN(tempAr5) GT 12 THEN
        tempAr5 = RIGHT(tempAr5,12)
    END
    
*tempAr6 = tempAr5[1,1]:tempAr5[2,1]:tempAr5[3,1]:tempAr5[4,1]
*tempAr7 = tempAr5[5,1]:tempAr5[6,1]:tempAr5[7,1]:tempAr5[8,1]
*tempAr8 = tempAr5[9,1]:tempAr5[10,1]:tempAr5[11,1]:tempAr5[12,1]

    tempAr6 = (tempAr5[1,1]:tempAr5[2,1]:tempAr5[3,1]:tempAr5[4,1])+(tempAr5[5,1]:tempAr5[6,1]:tempAr5[7,1]:tempAr5[8,1])+(tempAr5[9,1]:tempAr5[10,1]:tempAr5[11,1]:tempAr5[12,1])
    IF LEN(tempAr6) GT 4 THEN
        tempAr6 = RIGHT(tempAr6,4)
    END

    f1 = tempAr6[1,1]
    f2 = tempAr6[2,1]
    f3 = tempAr6[3,1]
    f4 = tempAr6[4,1]
    amount  = amt
    origAcc = debAc
    benAcc  = desAcc
    dataArr = desBnk:desBrn:filler:retCode:trnCode
    
    at = amount+tempAr5
    ot = origAcc+tempAr5
    bt = benAcc+tempAr5
    dt = dataArr+tempAr5

    tempAr7  = at[1,4] + at[5,4] + at[9,4]
    tempAr8  = ot[1,4] + ot[5,4] + ot[9,4]
    tempAr9  = bt[1,4] + bt[5,4] + bt[9,4]
    tempAr10 = dt[1,4] + dt[5,4] + dt[9,4]

    arrMu1 = tempAr6*tempAr7
    IF LEN(arrMu1) GT 9 THEN
        arrMu1 = RIGHT(arrMu1,9)
    END
    arrMu2 = tempAr6*tempAr8
    IF LEN(arrMu2) GT 9 THEN
        arrMu2 = RIGHT(arrMu2,9)
    END
    arrMu3 = tempAr6*tempAr9
    IF LEN(arrMu3) GT 9 THEN
        arrMu3 = RIGHT(arrMu3,9)
    END
    arrMu4 = tempAr6*tempAr10
    IF LEN(arrMu4) GT 9 THEN
        arrMu4 = RIGHT(arrMu4,9)
    END
    
    fArr1 = arrMu1[1,3] + arrMu1[4,3] + arrMu1[7,3]
    fArr2 = arrMu2[1,3] + arrMu2[4,3] + arrMu2[7,3]
    fArr3 = arrMu3[1,3] + arrMu3[4,3] + arrMu3[7,3]
    fArr4 = arrMu4[1,3] + arrMu4[4,3] + arrMu4[7,3]
    
    secField = fArr1+fArr2+fArr3+fArr4
    IF LEN(secField) GT 6 THEN
        secField = RIGHT(secField,9)
    END

RETURN
*** </region>

END