* @ValidationCode : MjotMTQ5NDQ0OTM0OkNwMTI1MjoxNzUzMDgyNjY5MTI3Okt1c2FseWE6LTE6LTE6MDowOmZhbHNlOk4vQTpSMjBfU1AzLjA6LTE6LTE=
* @ValidationInfo : Timestamp         : 21 Jul 2025 12:54:29
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

SUBROUTINE NDB.TCIB.BULK.HDR.LOAD
*-----------------------------------------------------------------------------
*
*-----------------------------------------------------------------------------
* Modification History :
*-----------------------------------------------------------------------------

*-----------------------------------------------------------------------------

    $USING EB.DataAccess
    $USING EB.API
    $USING EB.SystemTables

    $INSERT I_F.EB.NDB.TCIB.BULK.HEADERS
    $INSERT I_F.EB.NDB.TCIB.BULK.TRANS
    $INSERT I_NDB.TCIB.BULK.HDR.COMMON
	 
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

    GOSUB READ.PARAM ; *Read Parameter Table to Get GL Accounts

    currDate = EB.SystemTables.getToday()

    hdrSelCmd = ""
    hdrRecs = ""
    noOfHdrRec = ""
    hdrEr = ""

    hdrSelCmd = "SELECT ":fnHeadTable:" WITH REC.STATUS EQ READY.TO.PROCESS AND TC.TXN.STATUS EQ CUSTOMER.APPROVED"

RETURN


*-----------------------------------------------------------------------------

*** <region name= READ.PARAM>
READ.PARAM:
*** <desc>Read Parameter Table to Get GL Accounts </desc>
 
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
        TransactionType = paramValue<1,tranTypenPos>
    END
    
    LOCATE "OFS.SOURCE" IN paramField<1,1> SETTING ofsSourcePos THEN
        ofsSource = paramValue<1,ofsSourcePos>
    END
     
RETURN
*** </region>

END

