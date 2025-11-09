* @ValidationCode : MjotMTMwMzc2MzI4NTpDcDEyNTI6MTc2MTU1MzAzMjgyNzpLdXNhbHlhOi0xOi0xOjA6MDpmYWxzZTpOL0E6UjIwX1NQMy4wOi0xOi0x
* @ValidationInfo : Timestamp         : 27 Oct 2025 13:47:12
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
SUBROUTINE NDB.TCIB.BULK.FT.STAT.UPD.SELECT
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
    
    tranList = ""
	hdrSelCmd = "SELECT ":fnHeadTable:" WITH REC.STATUS EQ 'PROCESSING' OR REC.STATUS EQ 'INPUTTED' OR REC.STATUS EQ 'DELETE'"
    unHdrSelCmd = "SELECT ":fnUnathHTable:" WITH REC.STATUS EQ 'DELETE' OR (REC.STATUS EQ 'INPUTTED' AND RECORD.STATUS EQ 'INAO')"
	
    EB.DataAccess.Readlist(hdrSelCmd, hdrRecs, '', noOfHdrRecs, hdrEr)
    EB.DataAccess.Readlist(unHdrSelCmd, unHdrRecs, '', unNoOfHdrRecs, hdrEr)
	IF hdrRecs THEN
		tranList = hdrRecs
		IF unHdrRecs THEN
			tranList = tranList:@FM:unHdrRecs
		END
	END ELSE
		tranList =unHdrRecs
	END
    CALL BATCH.BUILD.LIST('',tranList)
    
RETURN
END
