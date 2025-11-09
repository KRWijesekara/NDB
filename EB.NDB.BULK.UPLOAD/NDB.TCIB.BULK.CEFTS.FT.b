* @ValidationCode : MjoxMTI3NDU4ODUxOkNwMTI1MjoxNzUyNjcxNjg1MzEzOkt1c2FseWE6LTE6LTE6MDowOmZhbHNlOk4vQTpSMjBfU1AzLjA6LTE6LTE=
* @ValidationInfo : Timestamp         : 16 Jul 2025 18:44:45
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

SUBROUTINE NDB.TCIB.BULK.CEFTS.FT(ID)
*-----------------------------------------------------------------------------
*
*-----------------------------------------------------------------------------
* Modification History :
*-----------------------------------------------------------------------------

*-----------------------------------------------------------------------------

    $USING EB.SystemTables
    $USING EB.DataAccess
    $USING AC.AccountOpening
    $USING ST.CompanyCreation
    $USING ST.CurrencyConfig
	
    $INSERT I_F.EB.NDB.TCIB.BULK.TRANS
    $INSERT I_NDB.TCIB.BULK.CEFTS.FT.COMMON
	 
	
    fnCompChk = 'F.COMPANY.CHECK'; fpCompChk = ''
    EB.DataAccess.Opf(fnCompChk, fpCompChk)

    fnCcy = 'FBNK.CURRENCY'; fpCcy = ''
    EB.DataAccess.Opf(fnCcy, fpCcy)

    dlm = '|'
    
    curFunc = EB.SystemTables.getVFunction()
    jPackCls = "com.temenos.ndb.ceft.client.CEFTClient"
    jMetho = "sendData"
    
    tranId = ID
    EB.DataAccess.FRead(fnTranTable, tranId, tranRec, fpTranTable, Er)
    
    sdFlag = tranRec<EB.NDB16.SINGLE.DEBIT.FLAG>
    IF sdFlag EQ 'NDB.TCIB.BULK.SD' THEN
        drAc = controlGlAcc
		CHNL_TYP          = 'teller'
    END ELSE
        drAc = tranRec<EB.NDB16.DEB.ACC>
		CHNL_TYP          = 'ibank'
    END

    drCcy = tranRec<EB.NDB16.DEB.CURR>

    EB.DataAccess.FRead(fnCcy, drCcy, ccyRec, fpCcy, ccyEr)
    drCcyCd =  ccyRec<ST.CurrencyConfig.Currency.EbCurNumericCcyCode>

    
    EB.DataAccess.FRead(fnCompChk, 'FIN.FILE', cmpChkRec, fpCompChk, compChkEr)
    comCode = cmpChkRec<ST.CompanyCreation.CompanyCheck.EbCocCompanyCode>
    compMne = cmpChkRec<ST.CompanyCreation.CompanyCheck.EbCocCompanyMne>
    
    compList = compMne
    CHANGE @VM TO @FM IN compList
    compCnt = DCOUNT(compList,@FM)
    
    FOR AA = 1 TO compCnt

        comMne = compList<AA>
        Y.AC.VAL = 0

        fnAc = "F":comMne:".ACCOUNT" ; fpAc = ''
        EB.DataAccess.Opf(fnAc, fpAc)

        EB.DataAccess.FRead(fnAc, drAc, acRec, fpAc, acEr)
        drAcCat   =  acRec<AC.AccountOpening.Account.Category>
        BREAK

    NEXT AA
    
    BEGIN CASE
        CASE drAcCat LE 1000 OR drAcCat GE 1999
            drAcTyp =  'sa'
        CASE drAcCat LE 6000 OR drAcCat GE 6599
            drAcTyp =  'ca'
        CASE 1
            drAcTyp =  'na'
    END CASE
     
    crAc       = tranRec<EB.NDB16.BEN.ACC.NUM>
    bnkCode    = tranRec<EB.NDB16.BEN.BANK.CODE>
	firstIndex = LEFT(bnkCode,1)
	IF firstIndex EQ '7' THEN
		bnkCode    = '6':RIGHT(bnkCode,3)
	END
    coCode     = tranRec<EB.NDB16.CO.CODE>[5,3]
    coCode     = FMT(coCode,"R%04")
    brnCode    = tranRec<EB.NDB16.BEN.BRANCH>
    amt        = tranRec<EB.NDB16.DEB.AMOUNT>
    crAcName   = tranRec<EB.NDB16.BEN.NAME>
    cusRef     = tranRec<EB.NDB16.CUST.REF>
    drAcName   = tranRec<EB.NDB16.DEB.ACC.NAME>
    tranCode   = tranRec<EB.NDB16.TRAN.CODE>
    
    uploadId          = FIELD(tranId,'-',1)
    tranNum           = RIGHT(tranId,5)
    tranLineNum       = TRIM(tranNum, '0', 'L')
    amt				  = amt*100
    amt 			  = FIELD(amt,'.',1)
    AUX_NO            = uploadId:'-':tranLineNum
    MESSAGE_ID        = 'ibft_debit'
    MESSAGE_GRP_ID    = 'ib'
    CARD_NO           = 'null'
    FR_ACC_ID         = drAc
    FR_ACC_LBL        = drAcTyp
    TO_ACC_ID         = crAc
    TO_ACC_LBL        = 'na'
    ORG_BNK_CODE      = '6214'
    DEST_BNK_CODE     = bnkCode
    ORG_BRCH_CODE     = '001'
*ORG_BRCH_CODE    = coCode
    DEST_BRCH_CODE    = brnCode
    TXN_AMOUNT        = amt
    TXN_CUR           = drCcyCd
    DR_AC_NAME        = drAcName
    TRX_COD           = tranCode
    REFERANCE         = cusRef
    CR_AC_NAME        = crAcName

    callJResp = ""

    callJArg = AUX_NO:dlm:MESSAGE_ID:dlm:MESSAGE_GRP_ID:dlm:CARD_NO:dlm:FR_ACC_ID:dlm:FR_ACC_LBL:dlm:TO_ACC_ID:dlm:TO_ACC_LBL:dlm:ORG_BNK_CODE:dlm:DEST_BNK_CODE:dlm:ORG_BRCH_CODE:dlm:DEST_BRCH_CODE:dlm:TXN_AMOUNT:dlm:TXN_CUR:dlm:CHNL_TYP:dlm:DR_AC_NAME:dlm:TRX_COD:dlm:REFERANCE:dlm:CR_AC_NAME:dlm
   

    CALLJ jPackCls, jMetho, callJArg SETTING callJResp ON ERROR
        CALLJ.ERROR = SYSTEM(0)
        BEGIN CASE
            CASE CALLJ.ERROR = 1
                ETEXT = "CALLJ Fatal error creating thread."
                CALL STORE.END.ERROR
            CASE CALLJ.ERROR = 2
                ETEXT = "Cannot find the JVM.dll"
                CALL STORE.END.ERROR
            CASE CALLJ.ERROR = 3
                ETEXT = "Class " : jPackCls : " doesn't exist."
                CALL STORE.END.ERROR
            CASE CALLJ.ERROR = 4
                ETEXT = "CALLJ Unicode conversion error."
                CALL STORE.END.ERROR
            CASE CALLJ.ERROR = 5
                ETEXT = "Method " : jMetho : " doesn't exist."
                CALL STORE.END.ERROR
            CASE CALLJ.ERROR = 6
                ETEXT = "Cannot find " : jPackCls: "'s constructor."
                CALL STORE.END.ERROR
            CASE CALLJ.ERROR = 7
                ETEXT = "Cannot instantiate " : jPackCls
                CALL STORE.END.ERROR
            CASE 1
                ETEXT = "Unknown error!"
                CALL STORE.END.ERROR
        END CASE
    END

    Y.RES.CODE = FIELD(callJResp,"|",1)
    Y.ERROR = ""

*        LOCATE Y.RES.CODE IN Y.ATTRIBUTE<1,1> SETTING CODE.POS ELSE CODE.POS = "NULL"
*        Y.ERROR = Y.VALUE.1<1,CODE.POS,1>
*
    BEGIN CASE
        CASE Y.RES.CODE = "00"
            status    = "FT.SUCCESS"
            GOSUB WRITE.CEFT
        CASE Y.ERROR NE ""
            
            ETEXT  = Y.ERROR
            status = "FT.FAILED"
            GOSUB WRITE.CEFT
            CALL STORE.END.ERROR
            RETURN

        CASE 1
            ETEXT = "Sending CEFT Transaction failed"
            status = "FT.FAILED"
            GOSUB WRITE.CEFT
            CALL STORE.END.ERROR
            RETURN

    END CASE
* END

RETURN

*-----------------------------------------------------------------------------
WRITE.CEFT:
*-----------------------------------------------------------------------------
  
    tranRec<EB.NDB16.TC.TXN.STATUS> = status
    IF Y.RES.CODE NE "00" THEN
        tranRec<EB.NDB16.RECORD.STATUS> = Y.RES.CODE
    END
    WRITE tranRec TO fpTranTable, tranId
RETURN

END