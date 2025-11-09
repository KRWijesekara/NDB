* @ValidationCode : Mjo4OTQ4NTc3Nzg6Q3AxMjUyOjE3NjAwNzU0Njc3MzU6S3VzYWx5YTotMTotMTowOjA6ZmFsc2U6Ti9BOlIyMF9TUDMuMDotMTotMQ==
* @ValidationInfo : Timestamp         : 10 Oct 2025 11:21:07
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

SUBROUTINE NDB.TCIB.BULK.FT.SERVICE.LOAD
*-----------------------------------------------------------------------------
*
*-----------------------------------------------------------------------------
* Modification History :
*-----------------------------------------------------------------------------

*-----------------------------------------------------------------------------

    $USING EB.DataAccess
    $USING EB.Service
    $USING EB.SystemTables
    $USING AC.AccountOpening
    $USING FT.Contract
    $USING EB.Foundation
    $USING EB.Interface
    $USING ST.CompanyCreation
    $USING EB.API

    $INSERT I_F.EB.NDB.TCIB.BULK.HEADERS
    $INSERT I_F.EB.NDB.TCIB.BULK.TRANS
    $INSERT I_NDB.TCIB.BULK.FT.SERVICE.COMMON
	DEBUG
    fnTranTable = "F.EB.NDB.TCIB.BULK.TRANS"
    fpTranTable = ""
    EB.DataAccess.Opf(fnTranTable, fpTranTable)
	
	fnHeadTable = "F.EB.NDB.TCIB.BULK.HEADERS"
    fpHeadTable = ""
    EB.DataAccess.Opf(fnHeadTable, fpHeadTable)

    fnParam = "F.NDB.PARAMETER"
    fpParam = ""
    EB.DataAccess.Opf(fnParam, fpParam)
     
    fnAccount = "FDBU.ACCOUNT"
    fpAccount = ""
    EB.DataAccess.Opf(fnAccount, fpAccount)
    
    fnPpClientCharges = "FBNK.PP.CLIENTCHARGES"
    fpPpClientCharges = ""
    EB.DataAccess.Opf(fnPpClientCharges, fpPpClientCharges)
    
    fnCustomerAccount = "F.CUSTOMER.ACCOUNT"
    fpCustomerAccount = ""
    EB.DataAccess.Opf(fnCustomerAccount, fpCustomerAccount)
    
    fnTcPerm = 'F.AA.ARR.TC.PERMISSIONS'
    fpTcPerm = ''
    EB.DataAccess.Opf(fnTcPerm, fpTcPerm)
    
    fnDbTcPerm = 'FDBU.AA.ARR.TC.PERMISSIONS'
    fpDbTcPerm = ''
    EB.DataAccess.Opf(fnDbTcPerm, fpDbTcPerm)
    
    fnEbExtUsr = 'F.EB.EXTERNAL.USER'
    fbEbExtUsr = ''
    EB.DataAccess.Opf(fnEbExtUsr, fpEbExtUsr)

    GOSUB READ.PARAM ; *Read Parameter Table to Get GL Accounts

    currDate = EB.SystemTables.getToday()
    currComp = EB.SystemTables.getIdCompany()
    tranSelCmd = ""
    recs = ""
    
    tranSelCmd = "SELECT ":fnTranTable:" WITH TC.TXN.STATUS EQ PROCESS.FT"

    CRT tranSelCmd
    
RETURN


*-----------------------------------------------------------------------------

*** <region name= READ.PARAM>
READ.PARAM:
*** <desc>Read Parameter Table to Get GL Accounts </desc>
    DEBUG
    paramId = "NDB.TCIB.BULK.UPLD"
    EB.DataAccess.FRead(fnParam, paramId, paramRec, fpParam, paramEr)

    paramField = paramRec<2>
    paramValue = paramRec<3>

    LOCATE "CONTROLGL" IN paramField<1,1> SETTING conGlPos THEN
        controlGlAcc = paramValue<1,conGlPos>
    END

    LOCATE "SLIPSGL" IN paramField<1,1> SETTING conSlPos THEN
        slipsGlAcc = paramValue<1,conSlPos>
    END

    LOCATE "CEFTSGL" IN paramField<1,1> SETTING conCefPos THEN
        ceftsGlAcc = paramValue<1,conCefPos>
    END
    
    LOCATE "SLIPS.CHARGEGL" IN paramField<1,1> SETTING conCefPos THEN
        slipsChargeGlAcc = paramValue<1,conCefPos>
    END

    LOCATE "CEFTS.COM.TYPE" IN paramField<1,1> SETTING conCefPos THEN
        ceftsComType = paramValue<1,conCefPos>
    END
     
    LOCATE "SLIPS.COM.TYPE" IN paramField<1,1> SETTING slipChargePos THEN
        slipsComType = paramValue<1,slipChargePos>
    END
    
    LOCATE "SLIP.GENERAL.CHARGE" IN paramField<1,1> SETTING slipsGenPos THEN
        slipsGenCharge = paramValue<1,slipsGenPos>
    END
    
    LOCATE "CEFT.GENERAL.CHARGE" IN paramField<1,1> SETTING conCefPos THEN
        ceftsGenCharge = paramValue<1,conCefPos>
    END
    
    LOCATE "APP.NAME" IN paramField<1,1> SETTING appNamePos THEN
        appName = paramValue<1,appNamePos>
    END
    
    LOCATE "OFS.VERSION" IN paramField<1,1> SETTING versionPos THEN
        ofsVersion = paramValue<1,versionPos>
    END
    
    LOCATE "TRANSACTION.TYPE" IN paramField<1,1> SETTING tranTypenPos THEN
        transactionType = paramValue<1,tranTypenPos>
    END
    
    LOCATE "OFS.SOURCE" IN paramField<1,1> SETTING ofsSourcePos THEN
        ofsSource = paramValue<1,ofsSourcePos>
    END
    
    LOCATE "SLIPS.TRAN.TYPE" IN paramField<1,1> SETTING versionPos THEN
        slipsTranType = paramValue<1,versionPos>
    END
    
    LOCATE "INT.TRAN.TYPE.OWN" IN paramField<1,1> SETTING tranTypenPos THEN
        intTranTypeOwn = paramValue<1,tranTypenPos>
    END
    
    LOCATE "INT.TRAN.TYPE" IN paramField<1,1> SETTING ofsSourcePos THEN
        intTranType = paramValue<1,ofsSourcePos>
    END
    
RETURN
*** </region>

END

