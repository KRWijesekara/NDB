* @ValidationCode : MjoxNzcxNzYwMDUxOkNwMTI1MjoxNzQ4MTE2ODQ1MTk4OkxvaGl0aDotMTotMTowOjA6ZmFsc2U6Ti9BOlIyMF9TUDMuMDotMTotMQ==
* @ValidationInfo : Timestamp         : 25 May 2025 01:30:45
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

SUBROUTINE NDB.TCIB.HDR.AUTH
*-----------------------------------------------------------------------------
*Program Description:
*Purpose : Update the status of Bulk Header records.
*Author  : Lohith Gunawardena | lohith.gunawardene@sysenact.com
*Date    : 23/05/2025
*-----------------------------------------------------------------------------
* Modification History :
*-----------------------------------------------------------------------------

*-----------------------------------------------------------------------------

    $USING EB.SystemTables
    $USING EB.DataAccess
    $INSERT I_F.EB.NDB.TCIB.BULK.TRANS
    $INSERT I_F.EB.NDB.TCIB.BULK.HEADERS
    
    hdrId = EB.SystemTables.getIdNew()
    recStat = EB.SystemTables.getRNew(EB.NDB21.RECORD.STATUS)
    
    IF recStat='' OR recStat='INAO' THEN
        EB.SystemTables.setRNew(EB.NDB21.REC.STATUS, 'READY.TO.PROCESS')
        EB.SystemTables.setRNew(EB.NDB21.TC.TXN.STATUS, 'CUSTOMER.APPROVED')
    END
    
RETURN
END
