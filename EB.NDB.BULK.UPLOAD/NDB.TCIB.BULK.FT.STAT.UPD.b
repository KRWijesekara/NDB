* @ValidationCode : MjotMTY0NjY4MjQzODpDcDEyNTI6MTc2MTU2MDEyNzA4OTpLdXNhbHlhOi0xOi0xOjA6MDpmYWxzZTpOL0E6UjIwX1NQMy4wOi0xOi0x
* @ValidationInfo : Timestamp         : 27 Oct 2025 15:45:27
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
SUBROUTINE NDB.TCIB.BULK.FT.STAT.UPD(ID)
*-----------------------------------------------------------------------------
*Program Description:
*Purpose   : Multi thread service for delete rejected transactions, Process single autherisor bulks,Update statuses of completed bulks
*Author    : kusalya.wijesekara@sysenact.com
*PGM.FILE  : NDB.TCIB.BULK.FT.STAT.UPD
*Date      : 10/27/2025
*-----------------------------------------------------------------------------
*Modification History:-
*-----------------------------------------------------------------------------

    $USING EB.API
    $USING EB.SystemTables
    $USING EB.DataAccess
    $INSERT I_F.EB.NDB.TCIB.BULK.HEADERS
    $INSERT I_F.EB.NDB.TCIB.BULK.TRANS
    $INSERT I_NDB.TCIB.BULK.FT.STAT.UPD.COMMON
      
	 
    hdrId = ID
    EB.DataAccess.FRead(fnHeadTable, hdrId, hdrRec, fpHeadTable, hdrEr)
    IF hdrRec THEN
        GOSUB PROCESS.AUTH.HEADER ; *Delete last authorisor reject transactions and update status of completed Bulk files 
    END ELSE
        EB.DataAccess.FRead(fnUnathHTable, hdrId, hdrRec, fpUnathHTable, hdrEr)
        GOSUB PROCESS.UNATUH.HEADER ; *Delete Rejected transactions and change status of partaily approved transactions 
    END
    
RETURN

*-----------------------------------------------------------------------------

*** <region name= PROCESS.UNATH.HEADER>
PROCESS.UNATUH.HEADER:
*** <desc>Delete Rejected transactions and change status of partaily approved transactions </desc>
	 
	
	headerStat = hdrRec<EB.NDB21.REC.STATUS>
	headerRecStat = hdrRec<EB.NDB21.RECORD.STATUS>
	            
	IF headerStat EQ "DELETE" THEN
	   GOSUB DELETE.TRANS ; *Delete header and Body transaction of the bulk 
	END ELSE IF headerStat EQ "INPUTTED" AND headerRecStat EQ "INAO" THEN
	   hdrRec<EB.NDB21.REC.STATUS> = 'PARTIALY APPROVED'
	   WRITE hdrRec TO fpUnathHTable, hdrId
	END
    
RETURN
*** </region>

*-----------------------------------------------------------------------------

*** <region name= PROCESS.AUTH.HEADER>
PROCESS.AUTH.HEADER:
*** <desc>Delete last authorisor reject transactions and update status of completed Bulk files </desc>
	 
    tranCount    = hdrRec<EB.NDB21.UPLD.RECS>
    uplId        = hdrRec<EB.NDB21.UPLD.ID>
    headerStat = hdrRec<EB.NDB21.REC.STATUS>
    
     IF headerStat EQ "PROCESSING" THEN
        tranSelCmd = "SELECT ":fnTranTable:" WITH UPL.ID EQ ":uplId
        EB.DataAccess.Readlist(tranSelCmd, tranRecs, '', noOfTranRecs, hdrEr)
            
        FOR tranCnt=1 TO noOfTranRecs
            tranId = tranRecs<tranCnt>
            EB.DataAccess.FRead(fnTranTable, tranId, tranRec, fpTranTable, tranEr)
            tranStat = tranRec<EB.NDB16.TC.TXN.STATUS>
                    
            BEGIN CASE
                CASE tranStat EQ "FT.SUCCESS"
                    sucCnt = sucCnt+1
                    hdrRec<EB.NDB21.SUCCESS.COUNT> = sucCnt
                CASE tranStat EQ "FT.FAILED"
                    failCnt = failCnt+1
                    hdrRec<EB.NDB21.FAILED.COUNT> = failCnt
                CASE tranStat EQ "PROCESS.FT"
                    procCnt = procCnt+1
                    hdrRec<EB.NDB21.PROCESSING.COUNT> = procCnt
                CASE tranStat EQ "FILE.DOWNLOAD.STARTED"
                    sucCnt = sucCnt+1
                    hdrRec<EB.NDB21.SUCCESS.COUNT> = sucCnt
                CASE tranStat EQ "FILE.DOWNLOADED"
                    sucCnt = sucCnt+1
                    hdrRec<EB.NDB21.SUCCESS.COUNT> = sucCnt
                CASE 1
                    CONTINUE
            END CASE           
        NEXT tranCnt
           
        compTranCnt = sucCnt + failCnt
		IF compTranCnt EQ tranCount THEN
		    IF procCnt EQ 0 THEN
		        hdrRec<EB.NDB21.REC.STATUS> = "INTERNAL.PROCESS.COMPLETE"           
		    END
		END
        WRITE hdrRec TO fpHeadTable, hdrId
        
    END ELSE IF headerStat EQ "INPUTTED" THEN
        hdrRec<EB.NDB21.REC.STATUS> = 'READY.TO.PROCESS'
        hdrRec<EB.NDB21.TC.TXN.STATUS> = 'CUSTOMER.APPROVED'
        WRITE hdrRec TO fpHeadTable, hdrId   
        
    END ELSE IF headerStat EQ "DELETE" THEN
        GOSUB DELETE.TRANS ; *Delete header and Body transaction of the bulk 
    END
    
RETURN
*** </region>

*-----------------------------------------------------------------------------

*** <region name= DELETE.TRANS>
DELETE.TRANS:
*** <desc>Delete header and Body transaction of the bulk </desc>
	 
	
    uplId = FIELD(hdrId,'-',1)
    tranSelCmd = "SELECT ":fnTranTable:" WITH UPL.ID EQ ":uplId:""
    EB.DataAccess.Readlist(tranSelCmd, tranRecs, '', noOfTranRecs, hdrEr)
    DELETE fpUnathHTable,hdrId
    
    FOR tranCnt=1 TO noOfTranRecs
        tranrId = tranRecs<tranCnt>
        DELETE fpTranTable,tranrId
    NEXT tranCnt

RETURN
*** </region>

END