* @ValidationCode : MjoxMjQ5NjQzNzE1OkNwMTI1MjoxNzQ3MzkzMDc0NzMyOkxvaGl0aDotMTotMTowOjA6ZmFsc2U6Ti9BOlIyMF9TUDMuMDotMTotMQ==
* @ValidationInfo : Timestamp         : 16 May 2025 16:27:54
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

SUBROUTINE GET.EXT.USER.ACCTS(DATA.LIST)
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
          
    GOSUB INIT ; *Initialize Variables
    GOSUB SELECT ; *Execusting select command
    IF ltPermiId NE '' THEN
        GOSUB PROCESS ; *Processing data and building account list
    END

RETURN

*-----------------------------------------------------------------------------

*** <region name= INIT>
INIT:
*** <desc>Initialize Variables </desc>
 
    extUser = DATA.LIST
    curComp = EB.SystemTables.getIdCompany()

    fnEbExtUsr = 'F.EB.EXTERNAL.USER'
    fbEbExtUsr = ''
    EB.DataAccess.Opf(fnEbExtUsr, fpEbExtUsr)

    fnTcPerm = 'F.AA.ARR.TC.PERMISSIONS'
    fpTcPerm = ''
    EB.DataAccess.Opf(fnTcPerm, fpTcPerm)
    
    fnDbTcPerm = 'FDBU.AA.ARR.TC.PERMISSIONS'
    fpDbTcPerm = ''
    EB.DataAccess.Opf(fnDbTcPerm, fpDbTcPerm)

    fnAaCusArr = 'FDBU.AA.CUSTOMER.ARRANGEMENT'
    fpAaCusArr = ''
    EB.DataAccess.Opf(fnAaCusArr, fpAaCusArr)
	
	fnIslAaCusArr = 'FISL.AA.CUSTOMER.ARRANGEMENT'
    fpIslAaCusArr = ''
    EB.DataAccess.Opf(fnIslAaCusArr, fpIslAaCusArr)
    
    fnAaArr = 'F.AA.ARRANGEMENT'
    fpAaArr = ''
    EB.DataAccess.Opf(fnAaArr, fpAaArr)
    
    fnIslAaArr = 'FISL.AA.ARRANGEMENT'
    fpIslAaArr = ''
    EB.DataAccess.Opf(fnIslAaArr, fpIslAaArr)
    
    EB.DataAccess.FRead(fnEbExtUsr, extUser, extUsrRec, fpEbExtUsr, extEr)
    extUsrArr = extUsrRec<EB.ARC.ExternalUser.XuArrangement>
    extUsrComp = extUsrRec<EB.ARC.ExternalUser.XuCompany>
    
    cusArrList = ''
    defiCust = ''
    tcPermId = ''
    ltPermiId = ''
    arrList = ''
    
RETURN
*** </region>


*-----------------------------------------------------------------------------

*** <region name= SELECT>
SELECT:
*** <desc>Execusting select command </desc>
     
    ST.CompanyCreation.LoadCompany(extUsrComp)
    
    tcPermId = extUsrArr:'-TCPERMISSIONS'

    selCmd = "SELECT ":fnTcPerm:" WITH @ID LIKE ":tcPermId:"..."
    EB.DataAccess.Readlist(selCmd, recList, recName, recCount, recErr)
    
    IF recList EQ '' THEN
        selCmd = "SELECT ":fnDbTcPerm:" WITH @ID LIKE ":tcPermId:"..."
        EB.DataAccess.Readlist(selCmd, recList, recName, recCount, recErr)
    END
    
    ltPermiId = recList<recCount>

RETURN
*** </region>


*-----------------------------------------------------------------------------

*** <region name= PROCESS>
PROCESS:
*** <desc>Processing data and building account list </desc>
  
    EB.DataAccess.FRead(fnTcPerm, ltPermiId, permiRec, fpTcPerm, Er)

    defiCust = permiRec<AO.Framework.TcPermissions.AaTcPermDefinedCustomers>

    IF defiCust EQ '' THEN
        EB.DataAccess.FRead(fnDbTcPerm, ltPermiId, permiRec, fpDbTcPerm, Er)
        defiCust = permiRec<AO.Framework.TcPermissions.AaTcPermDefinedCustomers>
    END
    
    CHANGE @VM TO @FM IN defiCust
    CHANGE @SM TO @FM IN defiCust

    defiCuCnt = DCOUNT(defiCust,@FM)

    FOR defiCusNo=1 TO defiCuCnt
		arrList		= ""
		prodGrpList = ""
        cusId = defiCust<defiCusNo>
    
        EB.DataAccess.FRead(fnAaCusArr, cusId, cusDbuArrRec, fpAaCusArr, Er)
		IF cusDbuArrRec THEN
			arrList = cusDbuArrRec<AA.Framework.CustomerArrangement.CusarrArrangement>
			prodGrpList = cusDbuArrRec<AA.Framework.CustomerArrangement.CusarrProductGroup>
		END
		EB.DataAccess.FRead(fnIslAaCusArr, cusId, cusIslArrRec, fpIslAaCusArr, Er)
		IF cusIslArrRec THEN
			IF arrList THEN
				arrList = arrList:@FM:cusIslArrRec<AA.Framework.CustomerArrangement.CusarrArrangement>
				prodGrpList = prodGrpList:@FM:cusIslArrRec<AA.Framework.CustomerArrangement.CusarrProductGroup>
			END ELSE
				arrList = cusIslArrRec<AA.Framework.CustomerArrangement.CusarrArrangement>
				prodGrpList = cusIslArrRec<AA.Framework.CustomerArrangement.CusarrProductGroup>
			END
		END

        
        CHANGE @VM TO @FM IN arrList
        CHANGE @SM TO @FM IN arrList
        CHANGE @VM TO @FM IN prodGrpList
        CHANGE @SM TO @FM IN prodGrpList
                
        cusArrCnt = DCOUNT(arrList,@FM)

        FOR cusArrNo=1 TO cusArrCnt
         
            cusArr = arrList<cusArrNo>
            EB.DataAccess.FRead(fnAaArr, cusArr, cusArrRec, fpAaArr, cusArrEr)
            IF cusArrRec EQ '' THEN
                EB.DataAccess.FRead(fnIslAaArr, cusArr, cusArrRec, fpIslAaArr, cusArrEr)
            END
            accNo = cusArrRec<AA.Framework.Arrangement.ArrLinkedApplId>
            prdGrp = prodGrpList<cusArrNo>

            IF accNo THEN
                IF prdGrp EQ 'CURRENT.ACCOUNTS' OR prdGrp EQ 'SAVINGS.ACCOUNTS' OR prdGrp EQ 'IS.CA.ACCOUNT' OR prdGrp EQ 'IS.SB.ACCOUNT' THEN
                    cusArrList<-1> = accNo
                END
            END
    
        NEXT cusArrNo
    
    NEXT defiCusNo

    DATA.LIST = cusArrList

RETURN
*** </region>

END
