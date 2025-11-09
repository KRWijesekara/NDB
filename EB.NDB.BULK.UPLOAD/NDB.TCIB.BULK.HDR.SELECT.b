* @ValidationCode : MjotMzgyNTkzMzU2OkNwMTI1MjoxNzQwNjU2ODM4ODMxOkxvaGl0aDotMTotMTowOjA6ZmFsc2U6Ti9BOlIyMF9TUDMuMDotMTotMQ==
* @ValidationInfo : Timestamp         : 27 Feb 2025 17:17:18
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

SUBROUTINE NDB.TCIB.BULK.HDR.SELECT
*-----------------------------------------------------------------------------
*
*-----------------------------------------------------------------------------
* Modification History :
*-----------------------------------------------------------------------------

*-----------------------------------------------------------------------------

    $INSERT I_F.EB.NDB.TCIB.BULK.HEADERS
    $INSERT I_F.EB.NDB.TCIB.BULK.TRANS
    $INSERT I_NDB.TCIB.BULK.HDR.COMMON

    CALL EB.READLIST(hdrSelCmd, hdrRecs, '', noOfHdrRec, hdrEr)

    CRT hdrSelCmd
    CRT hdrRecs
    
    IF hdrRecs EQ '' THEN
        CRT "No Header Records Selected"
        RETURN
    END
    
    CALL BATCH.BUILD.LIST('',hdrRecs)
        
RETURN
END
