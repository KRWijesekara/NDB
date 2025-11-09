* @ValidationCode : MjoxNjg5NjM2NjA6Q3AxMjUyOjE3NjAwMDI0MjMwNTk6TG9oaXRoOi0xOi0xOjA6MDpmYWxzZTpOL0E6UjIwX1NQMy4wOi0xOi0x
* @ValidationInfo : Timestamp         : 09 Oct 2025 15:03:43
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

SUBROUTINE PROCESS.TRAN.VALIDATION(DATA.LIST)
*-----------------------------------------------------------------------------
*
*-----------------------------------------------------------------------------
* Modification History :
*-----------------------------------------------------------------------------

*-----------------------------------------------------------------------------

    $USING EB.DataAccess
    $USING EB.SystemTables
    $USING AA.Framework
    
    fnCurr = 'F.CURRENCY'
    fpCurr = ''
    EB.DataAccess.Opf(fnCurr, fpCurr)
    
    fnAcc = 'FDBU.ACCOUNT'
    fpAcc = ''
    EB.DataAccess.Opf(fnAcc, fpAcc)
    
    fnSwift = 'F.DE.BIC'
    fpSwift = ''
    EB.DataAccess.Opf(fnSwift, fpSwift)
    
    currDate = EB.SystemTables.getToday()
    tranErrMsg = ''
    
    tranCusRef      = FIELD(DATA.LIST,'~',1)
    tranDrAc        = FIELD(DATA.LIST,'~',2)
    tranDrAcNm      = FIELD(DATA.LIST,'~',3)
    tranDate        = FIELD(DATA.LIST,'~',4)
    tranCurr        = FIELD(DATA.LIST,'~',5)
    tranBenAc       = FIELD(DATA.LIST,'~',6)
    tranBenAcNm     = FIELD(DATA.LIST,'~',7)
    tranBnkCode     = FIELD(DATA.LIST,'~',8)
    tranBrnCode     = FIELD(DATA.LIST,'~',9)
    tranNarr        = FIELD(DATA.LIST,'~',10)
    tranBenEm       = FIELD(DATA.LIST,'~',11)
    tranCode        = FIELD(DATA.LIST,'~',12)
    benBankSwift    = FIELD(DATA.LIST,'~',13)
    charge          = FIELD(DATA.LIST,'~',14)
    BenAdd1         = FIELD(DATA.LIST,'~',15)
    BenAdd2         = FIELD(DATA.LIST,'~',16)
    BenAdd3         = FIELD(DATA.LIST,'~',17)
    Purpose1        = FIELD(DATA.LIST,'~',18)
    Purpose2        = FIELD(DATA.LIST,'~',19)
    Purpose3        = FIELD(DATA.LIST,'~',20)
    transType       = FIELD(DATA.LIST,'~',21)
    tranAmount      = FIELD(DATA.LIST,'~',22)
    currDate        = FIELD(DATA.LIST,'~',23)
    upldId          = FIELD(DATA.LIST,'~',24)
    upldType        = FIELD(DATA.LIST,'~',25)
    tranTblId       = FIELD(DATA.LIST,'~',26)
    tranLine        = FIELD(DATA.LIST,'~',27)
    transacCodes    = FIELD(DATA.LIST,'~',28)
    txnTypes        = FIELD(DATA.LIST,'~',29)
	debAc        = FIELD(DATA.LIST,'~',30)

    DATA.LIST = ''
    
    FINDSTR tranCode IN transacCodes SETTING transpos ELSE transpos=''

*transaction ref validation
*ceftsMand = 'Y' ; slipsMand = 'Y' ; rtgsMand = 'Y' ; chq = 'Y'
    IF tranCusRef EQ '' THEN
        tranErrMsg<-1>  = "Missing customer reference~"
    END
    
*debit acc validation
*ceftsMand = 'Y' ; slipsMand = 'Y' ; rtgsMand = 'Y' ; chq = 'Y'

    IF tranDrAc EQ '' THEN
        tranErrMsg<-1> = "Missing debit account number~":tranDrAc
    END ELSE IF tranDrAc NE debAc THEN
        tranErrMsg<-1> = "Invalid Debit Account~":tranDrAc
    END

*date validation
*ceftsMand = 'Y' ; slipsMand = 'Y' ; rtgsMand = 'Y' ; chq = 'Y'
    IF tranDate LT currDate THEN
        tranErrMsg<-1> = "Date not equal Today~":tranDate
    END ELSE IF tranDate GT currDate+7 THEN
        tranErrMsg<-1> = "Invalid Future Date~":tranDate
    END

*tran amount validation
*ceftsMand = 'Y' ; slipsMand = 'Y' ; rtgsMand = 'Y' ; chq = 'Y'
    trnAmtVal = tranAmount*1
    IF trnAmtVal LE 0 THEN
        tranErrMsg<-1> = "Invalid Amount~":tranAmount
    END

*currency validation
*ceftsMand = 'Y' ; slipsMand = '' ; rtgsMand = '' ; chq = 'Y'
    IF tranCurr THEN
        EB.DataAccess.FRead(fnCurr, tranCurr, currRec, fpCurr, currEr)
        IF currRec EQ '' THEN
            tranErrMsg<-1> = 'Invalid Currency~':tranCurr
        END
    END ELSE
        tranErrMsg<-1> = 'Missing Currency~':tranCurr
    END

*ben account number validation
*ceftsMand = 'Y' ; slipsMand = 'Y' ; rtgsMand = 'Y' ; chq = ''
    IF transType NE 'CHQ' THEN
        IF tranBenAc EQ '' THEN
            tranErrMsg<-1> = "Missing beneficiary account~"
        END
    END
    
*ben account name validation
*ceftsMand = 'Y' ; slipsMand = 'Y' ; rtgsMand = '' ; chq = 'Y'
    IF tranBenAcNm EQ '' THEN
        IF transType EQ 'CEFTS' OR transType EQ 'SLIPS' OR transType EQ 'CHQ' THEN
            tranErrMsg<-1> = "Beneficiary account name is mandatory~"
        END
    END

*bank code validation
*ceftsMand = 'Y' ; slipsMand = 'Y' ; rtgsMand = '' ; chq = ''
    IF tranBnkCode NE '' THEN
        IF NUM(tranBnkCode) THEN
            IF LEN(tranBnkCode) NE 4 THEN
                tranErrMsg<-1> = "Bank code should contain 4 digits~":tranBnkCode
            END
        END ELSE
            tranErrMsg<-1> = "Bank code should only contain numbers~":tranBnkCode
        END
    END ELSE
        IF transType EQ 'CEFTS' OR transType EQ 'SLIPS' THEN
            tranErrMsg<-1> = "Bank code is mandatory~"
        END
    END

*branch code validation
*ceftsMand = '' ; slipsMand = 'Y' ; rtgsMand = '' ; chq = ''
    IF tranBrnCode NE '' THEN
        IF NUM(tranBrnCode) THEN
            IF LEN(tranBrnCode) NE 3 THEN
                tranErrMsg<-1> = "Branch code should contain 3 digits~":tranBrnCode
            END
        END ELSE
            tranErrMsg<-1> = "Branch code should only contain numbers~":tranBrnCode
        END
    END ELSE
        IF transType EQ 'SLIPS' THEN
            tranErrMsg<-1> = "Branch code is mandatory~"
        END
    END

*email validation
*ceftsMand = '' ; slipsMand = '' ; rtgsMand = 'Y' ; chq = ''
    IF tranBenEm NE '' THEN
        atPos = INDEX(tranBenEm,'@',1)
        IF atPos EQ 0 THEN
            tranErrMsg<-1> = "Invalid email address~":tranBenEm
        END
    END ELSE
        IF transType EQ 'RTGS' THEN
            tranErrMsg<-1> = "Email is mandatory~"
        END
    END

*transaction code validation
*ceftsMand = '' ; slipsMand = 'Y' ; rtgsMand = '' ; chq = ''
    IF tranCode EQ '' THEN
        IF transType EQ 'SLIPS' THEN
            tranErrMsg<-1> = "Transaction Code is Mandatory~"
        END
    END ELSE
        IF transpos EQ '' THEN
            tranErrMsg<-1> = "Invalid Transaction Code~"
        END
    END
* ELSE check slips codes from param table

*SWIFT validation
*ceftsMand = '' ; slipsMand = '' ; rtgsMand = 'Y' ; chq = ''
    IF benBankSwift EQ '' THEN
        IF transType EQ 'RTGS' THEN
            tranErrMsg<-1> = "SWIFT Code is Mandatory~"
        END
    END ELSE
        EB.DataAccess.FRead(fnSwift, benBankSwift, swiftRec, fpSwift, swiftEr)
        IF swiftEr THEN
            tranErrMsg<-1> = "Invalid SWIFT Code~"
        END
    END
    
*ben address 3 validation
*ceftsMand = '' ; slipsMand = '' ; rtgsMand = 'Y' ; chq = ''
    IF BenAdd3 EQ '' THEN
        IF transType EQ 'RTGS' THEN
            tranErrMsg<-1> = "Beneficiary Address 3 is Mandatory~"
        END
    END

*purpose1 validation
*ceftsMand = '' ; slipsMand = '' ; rtgsMand = 'Y' ; chq = ''
    IF Purpose1 EQ '' THEN
        IF transType EQ 'RTGS' THEN
            tranErrMsg<-1> = "Purpose 1 is Mandatory~"
        END
    END

*purpose2 validation
*ceftsMand = '' ; slipsMand = '' ; rtgsMand = 'Y' ; chq = ''
    IF Purpose2 EQ '' THEN
        IF transType EQ 'RTGS' THEN
            tranErrMsg<-1> = "Purpose 2 is Mandatory~"
        END
    END

*purpose3 validation
*ceftsMand = '' ; slipsMand = '' ; rtgsMand = 'Y' ; chq = ''
    IF Purpose3 EQ '' THEN
        IF transType EQ 'RTGS' THEN
            tranErrMsg<-1> = "Purpose 3 is Mandatory~"
        END
    END

*transaction type validation
*ceftsMand = 'Y' ; slipsMand = 'Y' ; rtgsMand = 'Y' ; chq = 'Y'
        
    IF transType EQ '' THEN
        tranErrMsg<-1> = "Transaction Type is Mandatory~"
    END ELSE
*        LOCATE transType IN txnTypes SETTING txnTypPos ELSE txnTypPos=''
        FINDSTR transType IN txnTypes SETTING txnTypPos ELSE txnTypPos=''
        IF txnTypPos EQ '' THEN
            tranErrMsg<-1> = "Invalid Transaction Type~":transType
        END
    END
    
    DATA.LIST = tranErrMsg

RETURN

END

