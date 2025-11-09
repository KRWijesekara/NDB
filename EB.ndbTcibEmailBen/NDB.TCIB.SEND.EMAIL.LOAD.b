* @ValidationCode : Mjo5ODA1MzE2MzpDcDEyNTI6MTc2MjQyNTkwODM4ODpLdXNhbHlhOi0xOi0xOjA6MDpmYWxzZTpOL0E6UjIwX1NQMy4wOi0xOi0x
* @ValidationInfo : Timestamp         : 06 Nov 2025 16:15:08
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
SUBROUTINE NDB.TCIB.SEND.EMAIL.LOAD
*-----------------------------------------------------------------------------
*Program Description:
*Purpose : To Send Emails to Benficiaries
*Author  : kusalya.wijesekara@sysenact.com
*EB API  : NDB.TCIB.SEND.EMAIL.LOAD
*Date    : 06/30/2025
*-----------------------------------------------------------------------------
*Modification History:-
*-----------------------------------------------------------------------------

    $USING EB.DataAccess
    $USING EB.SystemTables

    $INSERT I_NDB.TCIB.SEND.EMAIL.COMMON
    
    fnNdbTcibEmail = "F.EB.NDB.TCIB.SEND.EMAIL"
    fpNdbTcibEmail = ""
    EB.DataAccess.Opf(fnNdbTcibEmail, fpNdbTcibEmail)
    
    fnNdbParameter = "F.NDB.PARAMETER"
    fpNdbParameter = ""
    EB.DataAccess.Opf(fnNdbParameter, fpNdbParameter)
    
    currDate = EB.SystemTables.getToday()

END
