* @ValidationCode : MjotMTcyNjMwMzU2MzpDcDEyNTI6MTc0MjgxNjM2NTA5MDpMb2hpdGg6LTE6LTE6MDowOmZhbHNlOk4vQTpSMjBfU1AzLjA6LTE6LTE=
* @ValidationInfo : Timestamp         : 24 Mar 2025 17:09:25
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

SUBROUTINE NDB.TCIB.BULK.CEFTS.FT.SELECT
*-----------------------------------------------------------------------------
*
*-----------------------------------------------------------------------------
* Modification History :
*-----------------------------------------------------------------------------

*-----------------------------------------------------------------------------

    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_GTS.COMMON

    $INSERT I_NDB.TCIB.BULK.CEFTS.FT.COMMON

*    EB.DataAccess.Readlist(tranSelCmd, tranList, '', tranListCount, tranListErr)
    CALL EB.READLIST(tranSelCmd, tranList, '', tranListCount, tranListErr)
    
    CRT tranSelCmd

    CALL BATCH.BUILD.LIST('',tranList)

END
