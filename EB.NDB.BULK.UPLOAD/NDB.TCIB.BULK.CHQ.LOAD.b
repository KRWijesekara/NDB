* @ValidationCode : MjotMTU1NjQ5NjAyMDpDcDEyNTI6MTc2MDAwMTYwOTg4MDpMb2hpdGg6LTE6LTE6MDowOmZhbHNlOk4vQTpSMjBfU1AzLjA6LTE6LTE=
* @ValidationInfo : Timestamp         : 09 Oct 2025 14:50:09
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

SUBROUTINE NDB.TCIB.BULK.CHQ.LOAD
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
    $INSERT I_NDB.TCIB.BULK.CHQ.COMMON

    fnHeadTable = "F.EB.NDB.TCIB.BULK.HEADERS"
    fpHeadTable = ""
    EB.DataAccess.Opf(fnHeadTable, fpHeadTable)
    
    fnHeadTableNau = "F.EB.NDB.TCIB.BULK.HEADERS$NAU"
    fpHeadTableNau = ""
    EB.DataAccess.Opf(fnHeadTableNau, fpHeadTableNau)

    fnTranTable = "F.EB.NDB.TCIB.BULK.TRANS"
    fpTranTable = ""
    EB.DataAccess.Opf(fnTranTable, fpTranTable)

    fnArcChq = "F.ARC.BULK.CHEQUE.UPLOAD"
    fpArcChq = ""
    EB.DataAccess.Opf(fnArcChq, fpArcChq)

    fnAccount = "FDBU.ACCOUNT"
    fpAccount = ""
    EB.DataAccess.Opf(fnAccount, fpAccount)

    fnParam = "F.NDB.PARAMETER"
    fpParam = ""
    EB.DataAccess.Opf(fnParam, fpParam)
    
    currDate = EB.SystemTables.getToday()

    hdrSelCmd = "SELECT ":fnTranTable:" WITH TC.TXN.STATUS EQ PROCESS.CHQ"

RETURN

END
