* @ValidationCode : Mjo1NzIxNzY2MzpDcDEyNTI6MTc0NzUwMzUyMTAxNTpMb2hpdGg6LTE6LTE6MDowOmZhbHNlOk4vQTpSMjBfU1AzLjA6LTE6LTE=
* @ValidationInfo : Timestamp         : 17 May 2025 23:08:41
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

SUBROUTINE PROCESS.MAIN.VALIDATION(DATA.LIST)
*-----------------------------------------------------------------------------
*
*-----------------------------------------------------------------------------
* Modification History :
*-----------------------------------------------------------------------------

*-----------------------------------------------------------------------------

    $USING EB.DataAccess
    $USING EB.SystemTables
    $USING EB.FileUpload
    $USING EB.API

    fileName = FIELD(DATA.LIST,'~',1)
    charList = FIELD(DATA.LIST,'~',2)
    fileNameLen = LEN(fileName)
    
    DATA.LIST = ''
    
    FOR index = 1 TO fileNameLen
        character = fileName[index,1]
        IF INDEX(charList,character,1)=0 THEN
            invalid = 1
            BREAK
        END
    NEXT index
    
    BEGIN CASE
        CASE invalid EQ 1
            mVError = 'File name cannot contain spacial caracters'
            DATA.LIST = 'File Name':'~':mVError:'~':'Y'
        CASE fileNameLen GT 43
            mVError = 'File name exceed 43 characters'
            DATA.LIST = 'File Name':'~':mVError:'~':'Y'
        CASE 1
            RETURN
    END CASE
    
RETURN
END
