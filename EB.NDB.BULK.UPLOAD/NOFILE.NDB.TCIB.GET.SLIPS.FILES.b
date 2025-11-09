* @ValidationCode : MjoxNTQyOTk3Mzk5OkNwMTI1MjoxNzQ4NDA4MzI4Njk2OkxvaGl0aDotMTotMTowOjA6ZmFsc2U6Ti9BOlIyMF9TUDMuMDotMTotMQ==
* @ValidationInfo : Timestamp         : 28 May 2025 10:28:48
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
SUBROUTINE NOFILE.NDB.TCIB.GET.SLIPS.FILES(DATA.LIST)
*-----------------------------------------------------------------------------
*
*-----------------------------------------------------------------------------
* Modification History :
*-----------------------------------------------------------------------------

*-----------------------------------------------------------------------------

    $USING EB.Reports
    $USING EB.SystemTables
    $USING EB.DataAccess

    GOSUB INIT ; *
    GOSUB PROCESS ; *
RETURN

*-----------------------------------------------------------------------------

*** <region name= INIT>
INIT:
*** <desc> </desc>
    owdFile = EB.Reports.getEnqSelection()<4,1>

    fnSlipConc  = "F.NDB.TCIB.SLIPS.DET"
    fpSlipConc = ""
    EB.DataAccess.Opf(fnSlipConc, fpSlipConc)
    
    currdate = EB.SystemTables.getToday()
    path = "/Temenos/T24/bnk/UD/FILE.UPLOAD/SLIP.FILE"

RETURN
*** </region>


*-----------------------------------------------------------------------------

*** <region name= PROCESS>
PROCESS:
*** <desc> </desc>
    IF owdFile EQ '' THEN
        selSlipConc = "SELECT ":fpSlipConc
        EB.DataAccess.Readlist(selSlipConc, concRecs, '', concRecCnt, concErr)
        
        FOR fileCnt=1 TO concRecCnt
            owdFile = concRecs<fileCnt>
            EB.DataAccess.FRead(fnSlipConc,owdFile,fileRec,fpSlipConc,err)
            curDate   = FIELD(fileRec,'~',1)
            totRecs   = FIELD(fileRec,'~',2)
            totAmount = FIELD(fileRec,'~',3)
            
            IF curDate EQ currdate THEN
                downloadPath = path:'/':owdFile
                DATA.LIST<-1> = owdFile:'*':curDate:'*':totRecs:'*':totAmount:'*':downloadPath
            END
        
        NEXT fileCnt
        
    END ELSE
        EB.DataAccess.FRead(fnSlipConc,owdFile,fileRec,fpSlipConc,err)
        curDate   = FIELD(fileRec,'~',1)
        totRecs   = FIELD(fileRec,'~',2)
        totAmount = FIELD(fileRec,'~',3)
            
        downloadPath = path:'/':owdFile
        DATA.LIST<-1> = owdFile:'*':curDate:'*':totRecs:'*':totAmount:'*':downloadPath

    END
    

RETURN
*** </region>

END


