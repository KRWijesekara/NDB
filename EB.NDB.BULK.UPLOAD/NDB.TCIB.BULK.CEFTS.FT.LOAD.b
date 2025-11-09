* @ValidationCode : MjoyOTQ4ODE5NTE6Q3AxMjUyOjE3NTQzNzcxMjU1MTk6S3VzYWx5YTotMTotMTowOjA6ZmFsc2U6Ti9BOlIyMF9TUDMuMDotMTotMQ==
* @ValidationInfo : Timestamp         : 05 Aug 2025 12:28:45
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

SUBROUTINE NDB.TCIB.BULK.CEFTS.FT.LOAD
*-----------------------------------------------------------------------------
*
*-----------------------------------------------------------------------------
* Modification History :
*-----------------------------------------------------------------------------

*-----------------------------------------------------------------------------

    $USING EB.DataAccess
    $INSERT I_F.EB.NDB.TCIB.BULK.TRANS
    $INSERT I_NDB.TCIB.BULK.CEFTS.FT.COMMON
	
    fnHeadTable = "F.EB.NDB.TCIB.BULK.HEADERS"
    fpHeadTable = ""
    EB.DataAccess.Opf(fnHeadTable, fpHeadTable)
    
    fnTranTable = "F.EB.NDB.TCIB.BULK.TRANS"
    fpTranTable = ""
    EB.DataAccess.Opf(fnTranTable, fpTranTable)

    fnParam = "F.NDB.PARAMETER"
    fpParam = ""
    EB.DataAccess.Opf(fnParam, fpParam)
    
    fnAccount = "FDBU.ACCOUNT"
    fpAccount = ""
    EB.DataAccess.Opf(fnAccount, fpAccount)
    
    fnPpClientCharges = "FBNK.PP.CLIENTCHARGES"
    fpPpClientCharges = ""
    EB.DataAccess.Opf(fnPpClientCharges, fpPpClientCharges)
    
    paramId= "NDB.TCIB.BULK.UPLD"
    EB.DataAccess.FRead(fnParam, paramId, paramRec, fpParam, paramEr)

    paramField = paramRec<2>
    paramValue = paramRec<3>

    LOCATE "CONTROLGL" IN paramField<1,1> SETTING conGlPos THEN
        controlGlAcc = paramValue<1,conGlPos>
    END
    
    LOCATE "CEFTS.COM.TYPE" IN paramField<1,1> SETTING conCefPos THEN
        ceftsComType = paramValue<1,conCefPos>
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
        TransactionType = paramValue<1,tranTypenPos>
    END
    
    LOCATE "OFS.SOURCE" IN paramField<1,1> SETTING ofsSourcePos THEN
        ofsSource = paramValue<1,ofsSourcePos>
    END

    tranSelCmd = "SELECT ":fnTranTable:" WITH TC.TXN.STATUS EQ PROCESS.FT AND TYPE EQ CEFTS"

END
