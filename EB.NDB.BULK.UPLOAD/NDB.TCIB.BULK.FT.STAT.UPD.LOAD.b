* @ValidationCode : MjotMTY3NjcyODU4OkNwMTI1MjoxNzYxNTUzMDQzNTA2Okt1c2FseWE6LTE6LTE6MDowOmZhbHNlOk4vQTpSMjBfU1AzLjA6LTE6LTE=
* @ValidationInfo : Timestamp         : 27 Oct 2025 13:47:23
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
SUBROUTINE NDB.TCIB.BULK.FT.STAT.UPD.LOAD
*-----------------------------------------------------------------------------
*Program Description:
*Purpose   : Multi thread service for delete rejected transactions, Process single autherisor bulks,Update statuses of completed bulks
*Author    : kusalya.wijesekara@sysenact.com
*PGM.FILE  : NDB.TCIB.BULK.FT.STAT.UPD
*Date      : 10/27/2025
*-----------------------------------------------------------------------------
*Modification History:-
*-----------------------------------------------------------------------------

    $USING EB.DataAccess
    $INSERT I_NDB.TCIB.BULK.FT.STAT.UPD.COMMON
    
    fnUnathHTable = "F.EB.NDB.TCIB.BULK.HEADERS$NAU"
    fpUnathHTable = ""
    EB.DataAccess.Opf(fnUnathHTable, fpUnathHTable)
    
    fnHeadTable = "F.EB.NDB.TCIB.BULK.HEADERS"
    fpHeadTable = ""
    EB.DataAccess.Opf(fnHeadTable, fpHeadTable)
    
    fnTranTable = "F.EB.NDB.TCIB.BULK.TRANS"
    fpTranTable = ""
    EB.DataAccess.Opf(fnTranTable, fpTranTable)
    

RETURN
END
