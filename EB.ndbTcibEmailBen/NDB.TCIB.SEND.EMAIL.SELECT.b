* @ValidationCode : MjotNTgxNDM2NjA6Q3AxMjUyOjE3NjI0MjkxNDczMTQ6S3VzYWx5YTotMTotMTowOjA6ZmFsc2U6Ti9BOlIyMF9TUDMuMDotMTotMQ==
* @ValidationInfo : Timestamp         : 06 Nov 2025 17:09:07
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : Kusalya
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : N/A
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : R20_SP3.0
$PACKAGE EB.ndbTcibEmailBen
SUBROUTINE NDB.TCIB.SEND.EMAIL.SELECT
*-----------------------------------------------------------------------------
*Program Description:
*Purpose : To Send Emails to Benficiaries
*Author  : kusalya.wijesekara@sysenact.com
*EB API  : NDB.TCIB.SEND.EMAIL.SELECT
*Date    : 06/30/2025
*-----------------------------------------------------------------------------
*Modification History:-
*-----------------------------------------------------------------------------
    $USING EB.DataAccess
    $USING EB.Service
    $INSERT I_NDB.TCIB.SEND.EMAIL.COMMON
    
    jobName = EB.Service.TsaRunningService.CurrentJob
    SelCmd = "SELECT ":fnNdbTcibEmail:" WITH EMAIL.TYPE ":jobName:" AND (STATUS EQ 'INAO' OR STATUS EQ 'AUTH')"
    EB.DataAccess.Readlist(SelCmd, tranList, '', noRecs, Er)
    EB.Service.BatchBuildList('', tranList)
* CALL BATCH.BUILD.LIST('',tranList)

END
