* @ValidationCode : MjotMjc1NTc0MDMxOkNwMTI1MjoxNzQwNzMwMDA1Mjg2OkxvaGl0aDotMTotMTowOjA6ZmFsc2U6Ti9BOlIyMF9TUDMuMDotMTotMQ==
* @ValidationInfo : Timestamp         : 28 Feb 2025 13:36:45
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

SUBROUTINE NDB.TCIB.BULK.FT.SERVICE.SELECT
*-----------------------------------------------------------------------------
*
*-----------------------------------------------------------------------------
* Modification History :
*-----------------------------------------------------------------------------

*-----------------------------------------------------------------------------

*    $USING EB.DataAccess
*    $USING EB.Service
*    $USING AC.AccountOpening
*    $USING FT.Contract
*    $USING EB.Foundation
*    $USING EB.Interface
*    $USING ST.CompanyCreation
*    $USING EB.API

    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_GTS.COMMON
    
    $INSERT I_NDB.TCIB.BULK.FT.SERVICE.COMMON
    
    tranList = ""
*    EB.DataAccess.Readlist(selTranCmd, tranList, '', tranListCount, tranListErr)
    
    CALL EB.READLIST(tranSelCmd, tranList, '', tranListCount, tranListErr)
    
    CRT tranSelCmd
    CRT tranList

    CALL BATCH.BUILD.LIST('',tranList)
    
*    IF tranList THEN
*        EB.Service.BatchBuildList(ListParameters, tranList)
*    END ELSE
*        errMsgList = "No Records Found"
*        WRITE errMsgList TO fpErrTab,headerId
*        RETURN
*    END


RETURN

END

