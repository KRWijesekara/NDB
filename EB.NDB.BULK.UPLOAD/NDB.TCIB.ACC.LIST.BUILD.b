* @ValidationCode : MjoyMTE3NTI5MzUxOkNwMTI1MjoxNzYwNjAzNzc2ODA0OkxvaGl0aDotMTotMTowOjA6ZmFsc2U6Ti9BOlIyMF9TUDMuMDotMTotMQ==
* @ValidationInfo : Timestamp         : 16 Oct 2025 14:06:16
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

SUBROUTINE NDB.TCIB.ACC.LIST.BUILD(ENQ.DATA)
*-----------------------------------------------------------------------------
*
*-----------------------------------------------------------------------------
* Modification History :
*-----------------------------------------------------------------------------

*-----------------------------------------------------------------------------

    $USING EB.DataAccess
    $USING EB.SystemTables
    $USING EB.ARC
    $USING AA.Framework
    $USING ST.CompanyCreation
    $USING EB.API
    $USING AO.Framework
    $USING ST.Customer
    $USING AC.AccountOpening
    $USING EB.Mandate
    
    LOCATE 'DEBIT.ACC' IN ENQ.DATA<2,1> SETTING debAcPos ELSE debAcPos=0
    LOCATE 'TC.INPUT.NAME' IN ENQ.DATA<2,1> SETTING tcInpNm ELSE tcInpNm=0
    
    IF tcInpNm EQ '0' THEN
        LOCATE 'TC.APRV.NAME' IN ENQ.DATA<2,1> SETTING tcInpNm ELSE tcInpNm=0
    END
    
    extUsr = ENQ.DATA<4,tcInpNm>
    externalUsr = ENQ.DATA<4,tcInpNm>
    debAcc = ENQ.DATA<4,debAcPos>
    tempEnqData = ENQ.DATA
        amount = ''
    
    fnAcc = 'F.ACCOUNT'
    fpAcc = ''
    EB.DataAccess.Opf(fnAcc, fpAcc)
    
    fnCus = 'F.CUSTOMER'
    fpCus = ''
    EB.DataAccess.Opf(fnCus, fpCus)
    
    fnExtUsr = 'F.EB.EXTERNAL.USER'
    fpExtUsr = ''
    EB.DataAccess.Opf(fnExtUsr, fpExtUsr)
    
    fnSigGrp = 'F.EB.SIGNATORY.GROUP'
    fpSigGrp = ''
    EB.DataAccess.Opf(fnSigGrp, fpSigGrp)
    
    fnMand = 'F.EB.MANDATE'
    fpMand = ''
    EB.DataAccess.Opf(fnMand, fpMand)
    
    EB.DataAccess.FRead(fnAcc, debAcc, accRec, fpAcc, accEr)
    cusId = accRec<AC.AccountOpening.Account.Customer>
    
    EB.DataAccess.FRead(fnCus, cusId, cusRec, fpCus, cusEr)
    mandAppList = cusRec<ST.Customer.Customer.EbCusMandateAppl>
        CHANGE @VM TO @FM IN mandAppList
    CHANGE @SM TO @FM IN mandAppList
    
    LOCATE 'EB.NDB.TCIB.BULK.HEADERS' IN mandAppList SETTING manApPos ELSE manApPos=''
    cusManId = cusRec<ST.Customer.Customer.EbCusMandateRecord,manApPos>
    
    EB.DataAccess.FRead(fnMand, cusManId, cusManRec, fpMand, cusManEr)
    cusManSigGrpLst = cusManRec<EB.Mandate.Mandate.MandSignatoryGroup>
    
    EB.DataAccess.FRead(fpExtUsr, externalUsr, extUsrRec, fpExtUsr, extUsrEr)
    extUsrCusId = extUsrRec<EB.ARC.ExternalUser.XuCustomer>
    
    selCmd = "SELECT ":fnSigGrp:" WITH SIGNATORY.CUSTOMER EQ ":extUsrCusId
    EB.DataAccess.Readlist(selCmd, sigGrpList, '', sigGrpListCnt, sigGrpListEr)
    
    FOR sigGrpCnt=1 TO sigGrpListCnt
        sigGrp = sigGrpList<sigGrpCnt>
        FIND sigGrp IN cusManSigGrpLst SETTING sigGrpPosF, sigGrpPosV, sigGrpPosS ELSE NULL
        IF sigGrpPosV THEN
            amount = cusManRec<EB.Mandate.Mandate.MandUpToAmount,sigGrpPosV>
        END
    NEXT sigGrpCnt

    EB.ndbBulkUpload.getExtUserAccts(extUsr)
    
    accList = extUsr
    
    FINDSTR debAcc IN accList SETTING debAccPos ELSE debAccPos=''
    
    IF tcInpNm AND debAcPos THEN
        tempEnqData<2,1>= "DEBIT.ACC"
        tempEnqData<3,1>= "CT"
        tempEnqData<4,1>= debAcc
        
        tempEnqData<2,2>= "AUTHORISER"
        tempEnqData<3,2>= "NC"
        tempEnqData<4,2>= externalUsr
        
        tempEnqData<2,3>= "REC.STATUS"
        tempEnqData<3,3>= "NE"
        tempEnqData<4,3>= "DELETE"
        
        tempEnqData<2,4>= "UPLD.AMOUNT"
        tempEnqData<3,4>= "LT"
        tempEnqData<4,4>= amount
        
        ENQ.DATA = tempEnqData
    END
    
RETURN
END