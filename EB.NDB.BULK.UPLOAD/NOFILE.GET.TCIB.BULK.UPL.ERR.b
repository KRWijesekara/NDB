* @ValidationCode : MjoxNTY5MDM3MzQ2OkNwMTI1MjoxNzQ3NTY0MjI1ODU3OkxvaGl0aDotMTotMTowOjA6ZmFsc2U6Ti9BOlIyMF9TUDMuMDotMTotMQ==
* @ValidationInfo : Timestamp         : 18 May 2025 16:00:25
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

SUBROUTINE NOFILE.GET.TCIB.BULK.UPL.ERR(DATA.LIST)

*-----------------------------------------------------------------------------
*
*-----------------------------------------------------------------------------
* Modification History :
*-----------------------------------------------------------------------------

*-----------------------------------------------------------------------------
    $USING EB.FileUpload
    $USING EB.Reports
    $USING EB.DataAccess
      
     
    
    GOSUB INIT ; *
    GOSUB PROCESS ; *
    

RETURN
*-----------------------------------------------------------------------------

*** <region name= INIT>
INIT:
*** <desc> </desc>
  
    upldId = EB.Reports.getEnqSelection()<4,1>
    fileUpldRec = EB.FileUpload.FileUpload.Read(upldId, ebFileUploadErr)
    
    
    FN.TCIB.BULK.CONCAT = 'F.NDB.TCIB.UPL.ERR';FP.TCIB.BULK.CONCAT = ''
    EB.DataAccess.Opf(FN.TCIB.BULK.CONCAT,FP.TCIB.BULK.CONCAT)
    
    FN.FILE.UPLOAD = 'F.EB.FILE.UPLOAD$NAU';FP.FILE.UPLOAD = ''
    EB.DataAccess.Opf(FN.FILE.UPLOAD,FP.FILE.UPLOAD)
    
    IF fileUpldRec EQ '' THEN
        EB.DataAccess.FRead(FN.FILE.UPLOAD,upldId,fileUpldRec,FP.FILE.UPLOAD,err)
    END
    uploadFileName = fileUpldRec<EB.FileUpload.FileUpload.UfFileName>
        
    FileName = uploadFileName[1, LEN(uploadFileName)-4]
    
    errId = upldId:'-':FileName
    
*EB.DataAccess.CacheRead(FN.TCIB.BULK.CONCAT, errId, Rec, Er);*
    EB.DataAccess.FRead(FN.TCIB.BULK.CONCAT,errId,Rec,FP.TCIB.BULK.CONCAT,err)
    
RETURN
*** </region>


*-----------------------------------------------------------------------------

*** <region name= PROCESS>
PROCESS:
*** <desc> </desc>
   
    recCount = DCOUNT(Rec,@FM)
    FOR I=1 TO recCount
        line = Rec<I>
        lineNO<-1> = line<1,1,1>
        errors = line<1,2>
        errData = line<1,3>
        errCount = DCOUNT(errors,@SM)
        
        FOR J=1 TO errCount
            error = errors<1,1,J>
            errorData= errData<1,1,J>
            DATA.LIST<-1> = lineNO:'*':error:'*':errorData
           
            error = ''
            errorData = ''

        NEXT J
        lineNO = ''
    NEXT I
RETURN
*** </region>

END



