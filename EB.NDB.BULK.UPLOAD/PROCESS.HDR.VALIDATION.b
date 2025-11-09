* @ValidationCode : MjoxNDkzMjMwNzQ3OkNwMTI1MjoxNzQ3NTUyNjIwMzgwOkxvaGl0aDotMTotMTowOjA6ZmFsc2U6Ti9BOlIyMF9TUDMuMDotMTotMQ==
* @ValidationInfo : Timestamp         : 18 May 2025 12:47:00
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

SUBROUTINE PROCESS.HDR.VALIDATION(DATA.LIST)
*-----------------------------------------------------------------------------
*
*-----------------------------------------------------------------------------
* Modification History :
*-----------------------------------------------------------------------------

*-----------------------------------------------------------------------------
    
    $USING EB.SystemTables
    $USING EB.DataAccess

    currDate = EB.SystemTables.getToday()

    fnCurr = 'F.CURRENCY' ; fpCurr = ''
    EB.DataAccess.Opf(fnCurr, fpCurr)

    fileDate = FIELD(DATA.LIST, "~", 1)
    fileTotAmt = FIELD(DATA.LIST, "~", 2)
    fileCur = FIELD(DATA.LIST, "~", 3)
    fileTotTran = FIELD(DATA.LIST, "~", 4)
    recCount = FIELD(DATA.LIST, "~", 5)
    i = 1
    
    DATA.LIST = ''

    totRecords = recCount-1;* Get number of records in the body

    IF fileTotAmt EQ '' OR fileTotAmt LE 0 THEN
        errMsg<-1> = i:'~Error in Amount Field~':fileTotAmt
        errFlag  = 'Y'
    END
    
    IF fileCur THEN
        EB.DataAccess.FRead(fnCurr, fileCur, currRec, fpCurr, currEr)
        IF currRec EQ '' THEN
            errMsg<-1> = i:'~Invalid Currency~':fileCur
            errFlag  = 'Y'
        END
    END ELSE
        errMsg<-1> = i:'~Missing Currency~':fileCur
        errFlag  = 'Y'
    END

    IF fileTotTran NE totRecords THEN
        errMsg<-1> = i:'~Total Transaction Count Mismatch~':fileTotTran
        errFlag  = 'Y'
    END
    
    IF fileDate LT currDate THEN
        errMsg<-1> = i:'~Date not equal Today~':fileDate
        errFlag  = 'Y'
    END

    DATA.LIST = errMsg:'~':errFlag
    
RETURN
END
