* @ValidationCode : MjoxNzI5MDI5MzUxOkNwMTI1MjoxNzUxMjU2OTgyODI2Okt1c2FseWE6LTE6LTE6MDowOmZhbHNlOk4vQTpSMjBfU1AzLjA6LTE6LTE=
* @ValidationInfo : Timestamp         : 30 Jun 2025 09:46:22
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
SUBROUTINE NDB.BULK.GET.DATE.TIME
*-----------------------------------------------------------------------------
*Program Description:
*Purpose : To get latest date time in bulk
*Author  : kusalya.wijesekara@sysenact.com
*EB API  : NDB.BULK.GET.DATE.TIME
*Date    : 06/30/2025
*-----------------------------------------------------------------------------
*Modification History:-
*-----------------------------------------------------------------------------

    $USING AA.Framework
    $USING EB.Reports
    $USING EB.DataAccess
    
    GOSUB INIT ; * Initializing variables
    GOSUB PROCESS ; * Starting the process

RETURN

*-----------------------------------------------------------------------------

*** <region name= INIT>
INIT:
*** <desc> </desc>

    data = EB.Reports.getOData() ;* Get data

RETURN
*** </region>


*-----------------------------------------------------------------------------

*** <region name= PROCESS>
PROCESS:
*** <desc> </desc>
    
    EB.Reports.setOData(data) ;*set data
    
RETURN
*** </region>

END


