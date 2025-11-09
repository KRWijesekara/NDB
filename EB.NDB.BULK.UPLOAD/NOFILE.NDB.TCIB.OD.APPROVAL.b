* @ValidationCode : Mjo5OTAwNTE2MjY6Q3AxMjUyOjE3NDI5NzQyMzAwNzk6S3VzYWx5YTotMTotMTowOjA6ZmFsc2U6Ti9BOlIyMF9TUDMuMDotMTotMQ==
* @ValidationInfo : Timestamp         : 26 Mar 2025 13:00:30
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
SUBROUTINE NOFILE.NDB.TCIB.OD.APPROVAL(DATA.LIST)
*-----------------------------------------------------------------------------
*
*-----------------------------------------------------------------------------
* Modification History :
*-----------------------------------------------------------------------------

*-----------------------------------------------------------------------------
    $USING EB.Reports
    $USING EB.DataAccess
    $USING EB.SystemTables
    $USING FT.Contract
    $INSERT I_F.EB.NDB.TCIB.BULK.TRANS
    $INSERT I_F.EB.NDB.TCIB.BULK.HEADERS

    GOSUB INIT ; *
    GOSUB PROCESS ; *
    
RETURN

*-----------------------------------------------------------------------------

*** <region name= INIT>
INIT:
*** <desc> </desc>
 
    upldId = EB.Reports.getEnqSelection()<4,1>
    enqName = EB.Reports.getEnqSelection()<1,1>
    fnFundTransfer = "FDBU.FUNDS.TRANSFER$NAU"
    fpFundTransfer = ""
    EB.DataAccess.Opf(fnFundTransfer, fpFundTransfer)
    
    fnHeaderTable = "F.EB.NDB.TCIB.BULK.HEADERS"
    fpHeaderTable = ""
    EB.DataAccess.Opf(fnHeaderTable, fpHeaderTable)
    
    fnTranTable = "F.EB.NDB.TCIB.BULK.TRANS"
    fpTranTable = ""
    EB.DataAccess.Opf(fnTranTable, fpTranTable)


RETURN
*** </region>

*-----------------------------------------------------------------------------

*** <region name= PROCESS>
PROCESS:
*** <desc> </desc>

    GOSUB SELECT.TABLE.RECORD ; *
    IF headerIds NE "" THEN
            
        FOR hdrId = 1 TO hdrCount
            headerId = headerIds<hdrId>
            EB.DataAccess.FRead(fnHeaderTable,headerId,headerRec,fpHeaderTable,err)
                
            fileName      = FIELD(headerId,'-',2)
            fileDate      = headerRec<EB.NDB21.UPLD.DATE>
            noTrans       = headerRec<EB.NDB21.UPLD.RECS>
            amount        = headerRec<EB.NDB21.UPLD.AMOUNT>
            currency      = headerRec<EB.NDB21.UPLD.CCY>
            debitAc       = headerRec<EB.NDB21.DEBIT.ACC>
            type          = ''
            section       = "H"
            sdFlag        = headerRec<EB.NDB21.SD.FLAG>
            ftNum         = headerRec<EB.NDB21.FT.NUMBER>
                
            EB.DataAccess.FRead(fnFundTransfer,ftNum,ftRec,fpFundTransfer,err)
            ftStatus      = ftRec<FT.Contract.FundsTransfer.RecordStatus>
            IF enqName EQ "NOFILE.NDB.TCIB.GET.OD.TRANSACTIONS" AND ftStatus EQ "IHLD" THEN
                DATA.LIST<-1> = fileName:'*':fileDate:'*':amount:'*':currency:'*':type:'*':section:'*':noTrans:'*':sdFlag:'*':debitAc:'*':headerId:'*':ftNum
            END ELSE IF enqName EQ "NOFILE.NDB.TCIB.GET.OD.APPROVAL" THEN
                IF  ftStatus EQ "INAO" OR ftStatus EQ "INAU" THEN
                    DATA.LIST<-1> = fileName:'*':fileDate:'*':amount:'*':currency:'*':type:'*':section:'*':noTrans:'*':sdFlag:'*':debitAc:'*':headerId:'*':ftNum
                END
            END
        NEXT hdrId
                
    END ELSE IF transactionIds NE '' THEN
            
        FOR trnId = 1 TO tranCount
            transactionId = transactionIds<trnId>
            EB.DataAccess.FRead(fnTranTable,transactionId,transactionRec,fpTranTable,err)
                
            atId          = FIELD(transactionId,'-',2)
            fileName      = LEFT(atId,LEN(atId)-6)
            fileDate      = transactionRec<EB.NDB16.DEB.VAL.DATE>
            noTrans       = ''
            amount        = transactionRec<EB.NDB16.DEB.AMOUNT>
            currency      = transactionRec<EB.NDB16.DEB.CURR>
            debitAc       = transactionRec<EB.NDB16.DEB.ACC>
            type          = transactionRec<EB.NDB16.TYPE>
            section       = "T"
            sdFlag        = transactionRec<EB.NDB16.SINGLE.DEBIT.FLAG>
            ftNum         = transactionRec<EB.NDB16.FT.NUMBER>
                
            EB.DataAccess.FRead(fnFundTransfer,ftNum,ftRec,fpFundTransfer,err)
            ftStatus      = ftRec<FT.Contract.FundsTransfer.RecordStatus>
            IF enqName EQ "NOFILE.NDB.TCIB.GET.OD.TRANSACTIONS" AND ftStatus EQ "IHLD" THEN
                DATA.LIST<-1> = fileName:'*':fileDate:'*':amount:'*':currency:'*':type:'*':section:'*':noTrans:'*':sdFlag:'*':debitAc:'*':transactionId:'*':ftNum
            END ELSE IF enqName EQ "NOFILE.NDB.TCIB.GET.OD.APPROVAL" THEN
                IF  ftStatus EQ "INAO" OR ftStatus EQ "INAU" THEN
                    DATA.LIST<-1> = fileName:'*':fileDate:'*':amount:'*':currency:'*':type:'*':section:'*':noTrans:'*':sdFlag:'*':debitAc:'*':headerId:'*':ftNum
                END
            END
        NEXT trnId
    END
 
RETURN
*** </region>


*-----------------------------------------------------------------------------

*** <region name= PROCESS>
SELECT.TABLE.RECORD:
*** <desc> </desc>
    IF upldId NE '' THEN
    
        selCmd = "SELECT ":fnHeaderTable:" WITH UPLD.ID EQ ":upldId:" AND REC.STATUS LIKE ...Insufficient..."
        EB.DataAccess.Readlist(selCmd, headerIds, '', hdrCount, Er)

        selCmd = "SELECT ":fnTranTable:" WITH UPL.ID EQ ":upldId:" AND TC.TXN.STATUS LIKE ...Insufficient..."
        EB.DataAccess.Readlist(selCmd, transactionIds, '', tranCount, Er)
    
    END ELSE
  
        selCmd = "SELECT ":fnHeaderTable:" REC.STATUS LIKE ...Insufficient..."
        EB.DataAccess.Readlist(selCmd, headerIds, '', hdrCount, Er)

        selCmd = "SELECT ":fnTranTable:" TC.TXN.STATUS LIKE ...Insufficient..."
        EB.DataAccess.Readlist(selCmd, transactionIds, '', tranCount, Er)
    
    END

RETURN
*** </region>

END


